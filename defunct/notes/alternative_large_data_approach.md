# ALTERNATIVE: If full dataset won't knit, use this sampling approach

# Add to load_data chunk:

# Option 1: Random sample (faster knitting, still representative)
set.seed(123)
sample_prop <- 0.1  # Use 10% of data
data_full <- read_dta("TimeUse106PER.dta", 
                      col_select = c(Gender, Unpaid_Paid_Status, time_spent, Weight, 
                                    Major_Activity_Flag, Age, Marital_Status, 
                                    Highest_Education, Sector, Principal_Activity_Status,
                                    Activity_Code_2Digit, State, FSU_Serial_No, 
                                    Sample_HH_No))
data <- data_full %>% slice_sample(prop = sample_prop)
rm(data_full)
gc()

# Adjust weights for sampling
data <- data %>% mutate(Weight = Weight / sample_prop)

# Then continue with major_only filtering as before...

# Option 2: Analyze on full data in R, export summary stats, knit from summaries only
# This is the most reliable approach for large datasets

# Run this script first to generate summary datasets:
```{r eval=FALSE}
library(haven)
library(dplyr)

# Load and process
data <- read_dta("TimeUse106PER.dta")
major_only <- data %>% filter(Major_Activity_Flag == 1)

# Generate all summary statistics
participation_summary <- major_only %>%
  filter(Gender %in% c(1, 2)) %>%
  group_by(Gender) %>%
  summarise(
    N = n(),
    care_activities = sum(Unpaid_Paid_Status == "02"),
    participation_rate = care_activities / n() * 100,
    minutes_per_participant = weighted.mean(time_spent[Unpaid_Paid_Status == "02"], 
                                            Weight[Unpaid_Paid_Status == "02"], 
                                            na.rm = TRUE),
    minutes_per_person = weighted.mean(ifelse(Unpaid_Paid_Status == "02", time_spent, 0),
                                       Weight, na.rm = TRUE)
  )

# Save summaries
saveRDS(participation_summary, "participation_summary.rds")

# Repeat for all other analyses (by_education, by_sector, regressions, etc.)
# Save each as .rds file

# Then in RMD:
```{r load_data}
participation_summary <- readRDS("participation_summary.rds")
by_education_summary <- readRDS("by_education_summary.rds")
# etc.
```

# This approach:
# 1. Runs heavy computation once
# 2. Saves small summary objects
# 3. RMD loads only summaries (fast, low memory)
# 4. Knitting succeeds every time
