# Verification Script for "Digital Distance" Paper

# This script recalculates the key statistics and regression coefficients
# from the `digital_socializing.Rmd` paper. Run this script in your R console
# to get the exact values that should appear in the compiled PDF.

# --- 1. Setup ---
# Install packages if you haven't already
# install.packages(c("haven", "dplyr", "fixest"))

cat("--- Loading necessary packages ---\n")
suppressPackageStartupMessages(library(haven))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(fixest))
cat("Packages loaded successfully.\n\n")

# --- 2. Data Loading and Processing ---
cat("--- Loading and processing data (10% sample) ---\n")
# Load only necessary columns
data <- read_dta("TimeUse106PER.dta",
                 col_select = c(Gender, Activity_Code_2Digit, time_spent, Weight,
                               Major_Activity_Flag, Age, Marital_Status,
                               Highest_Education, Sector, Principal_Activity_Status,
                               State, FSU_Serial_No, Sample_HH_No))

# Use a 10% random sample
set.seed(123)
data <- data %>% slice_sample(prop = 0.1)

# Adjust survey weights
data <- data %>% mutate(Weight = Weight / 0.1)

# Process data
major_only <- data %>%
  filter(Major_Activity_Flag == 1) %>%
  mutate(
    female = as.numeric(Gender == 2),
    married = as.numeric(Marital_Status == 2),
    household_id = paste(FSU_Serial_No, Sample_HH_No, sep = "_"),
    in_person_social = as.numeric(Activity_Code_2Digit == 81),
    remote_social = as.numeric(Activity_Code_2Digit == 82),
    urban = as.numeric(Sector == 2),
    higher_ed = as.numeric(Highest_Education %in% c(7, 8, 10, 11, 12)),
    employed = as.numeric(Principal_Activity_Status %in% c(11, 12, 21, 31, 41, 51)),
    female_married = female * married,
    state_factor = as.factor(State)
  )
cat("Data processing complete.\n\n")

# --- 3. Descriptive Statistics Verification ---
cat("--- VERIFICATION: Descriptive Statistics (Abstract & Introduction) ---\n")
participation_stats <- major_only %>%
  summarise(
    remote_rate = weighted.mean(remote_social, Weight, na.rm = TRUE) * 100,
    in_person_rate = weighted.mean(in_person_social, Weight, na.rm = TRUE) * 100
  )

remote_participation_rate <- participation_stats$remote_rate
in_person_participation_rate <- participation_stats$in_person_rate
ratio_remote_to_in_person <- remote_participation_rate / in_person_participation_rate

cat(sprintf("Remote Socializing Participation Rate: %.2f%%\n", remote_participation_rate))
cat(sprintf("In-Person Socializing Participation Rate: %.2f%%\n", in_person_participation_rate))
cat(sprintf("Ratio of Remote to In-Person: approximately %.0f times\n\n", ratio_remote_to_in_person))


# --- 4. Regression Analysis Verification ---
cat("--- VERIFICATION: Regression Coefficients (Table 2) ---\n")
reg_data <- major_only %>%
  filter(Gender %in% c(1, 2), Marital_Status %in% c(1, 2))

# Model for Remote Socializing
m_remote <- feols(remote_social ~ female + married + female_married + Age + I(Age^2) +
                    higher_ed + employed + urban | state_factor,
                  data = reg_data, weights = ~Weight, cluster = ~household_id)

# Model for In-Person Socializing
m_inperson <- feols(in_person_social ~ female + married + female_married + Age + I(Age^2) +
                      higher_ed + employed + urban | state_factor,
                    data = reg_data, weights = ~Weight, cluster = ~household_id)

cat("--- Model: Predicting Remote Socializing ---\n")
print(summary(m_remote)$coeftable[c("married", "female_married", "urban", "higher_ed"), ], 4)
cat("\n")

cat("--- Model: Predicting In-Person Socializing ---\n")
print(summary(m_inperson)$coeftable[c("married", "female_married", "urban", "higher_ed"), ], 4)
cat("\n")

cat("--- Verification Script Finished ---\n")
