# How to Run the Marriage Penalty Analysis in RStudio

## File Location

The RMD file is already in your repository:
```
marriage_care_penalty.Rmd
```

## Prerequisites

### 1. Install Required R Packages

Open RStudio and run:

```r
# Install packages if not already installed
install.packages(c(
  "haven",        # Read Stata .dta files
  "dplyr",        # Data manipulation
  "ggplot2",      # Visualization
  "knitr",        # RMarkdown
  "tidyr",        # Data reshaping
  "fixest",       # Fast fixed effects regression
  "modelsummary", # Regression tables
  "kableExtra"    # Table formatting
))
```

### 2. Install LaTeX (for PDF generation)

If you don't have LaTeX installed:

```r
# Install TinyTeX (recommended for RMarkdown)
install.packages("tinytex")
tinytex::install_tinytex()
```

Alternatively, install a full LaTeX distribution:
- **Windows**: MiKTeX (https://miktex.org/)
- **Mac**: MacTeX (https://www.tug.org/mactex/)
- **Linux**: TeX Live (`sudo apt-get install texlive-full`)

### 3. Place Data File

Ensure `TimeUse106PER.dta` is in the same directory as the RMD file:
```
/path/to/gender-disparity-unpaid-care-work/TimeUse106PER.dta
```

## How to Run

### Option A: Using RStudio GUI (Recommended)

1. Open RStudio
2. File → Open File → Select `marriage_care_penalty.Rmd`
3. Click the **"Knit"** button at the top of the editor
4. Wait for compilation (may take 5-15 minutes with 10M observations)
5. PDF will be generated: `marriage_care_penalty.pdf`

### Option B: Using R Console

```r
# Set working directory
setwd("/path/to/gender-disparity-unpaid-care-work")

# Render the RMarkdown
rmarkdown::render("marriage_care_penalty.Rmd")
```

### Option C: Command Line

```bash
cd /path/to/gender-disparity-unpaid-care-work
R -e "rmarkdown::render('marriage_care_penalty.Rmd')"
```

## Memory Considerations

The code is optimized for large datasets (10M+ observations):

1. **Selective column loading**: Only loads necessary columns
2. **Memory cleanup**: Uses `rm()` and `gc()` to free memory
3. **Caching**: Results are cached to speed up re-runs

If you encounter memory errors:

### Solution 1: Sample the Data (Recommended)

Add this to the `load_data` chunk (after line 60):

```r
# Sample 10% of data for faster processing
set.seed(123)
data <- data %>% slice_sample(prop = 0.1)
# Adjust weights for sampling
data <- data %>% mutate(Weight = Weight / 0.1)
```

### Solution 2: Increase Memory Limit (Windows only)

Add to the `setup` chunk:

```r
memory.limit(size = 16000)  # 16GB
```

### Solution 3: Process in Batches

If still having issues, you can pre-compute summaries and save as RDS files.

## Expected Output

The PDF will contain:

### Tables
1. Sample descriptive statistics
2. Care work by gender and marital status
3. Main regression results (4 models)
4. Age heterogeneity analysis (by age group)
5. Triple interaction regressions (3 models)
6. Alternative age cutoffs robustness
7. By education level
8. Urban vs Rural comparison
9. By employment status
10. Alternative care work definitions
11. Subsample regressions (4 models)

### Figures
1. Marriage penalty visualization (bar chart)
2. Additional figures for heterogeneity analysis

## Customization

### Change Author Name

Line 4:
```yaml
author:
  - "Your Name^[Your Affiliation, your.email@institution.edu]"
```

### Change Age Cutoff

The main analysis uses age ≤ 25. To change:

Line 82:
```r
age_group = ifelse(Age <= 30, "30 and below", "Above 30"),
```

And update throughout the document.

### Add More Controls

In regression models, add variables to the formula. For example:

```r
m4 <- feols(care_work ~ female + married + female_married +
              Age + I(Age^2) + higher_ed + employed + urban +
              YOUR_NEW_VARIABLE | State,
            data = reg_data, weights = ~Weight, vcov = "HC1")
```

## Troubleshooting

### Error: "Package 'xyz' not found"
**Solution**: Install the package: `install.packages("xyz")`

### Error: "Cannot find file TimeUse106PER.dta"
**Solution**: Ensure data file is in the same directory as RMD file

### Error: "LaTeX not found"
**Solution**: Install TinyTeX: `tinytex::install_tinytex()`

### Error: "Out of memory"
**Solution**: Use the sampling approach described above

### Warning: "Font not found"
**Solution**: The code uses xelatex engine which handles fonts better. If issues persist, change to:
```yaml
output:
  pdf_document:
    latex_engine: pdflatex
```

### Code runs but tables look weird
**Solution**: Ensure `kableExtra` package is installed and loaded

## Verification Checklist

Before running, verify:

- [ ] All R packages installed
- [ ] LaTeX installed (run `tinytex::install_tinytex()`)
- [ ] Data file `TimeUse106PER.dta` in same directory
- [ ] RStudio or R version ≥ 4.0
- [ ] At least 8GB RAM available (16GB recommended)

## Performance Tips

1. **First run**: Will be slow (10-20 minutes) due to data loading
2. **Subsequent runs**: Faster due to caching (2-5 minutes)
3. **To force fresh run**: Delete the `marriage_care_penalty_cache/` folder
4. **To keep intermediate files**: Set `keep_tex: true` in YAML header (already enabled)

## Output Files

After successful compilation:
```
marriage_care_penalty.pdf          # Final paper
marriage_care_penalty.tex          # LaTeX source
marriage_care_penalty_cache/       # Cached R objects
marriage_care_penalty_files/       # Figures and tables
```

## Getting Help

If you encounter issues:

1. Check the R console for specific error messages
2. Ensure all prerequisites are met
3. Try the sampling approach if memory errors occur
4. Check that variable names match the TUS 2024 data structure

## Code Quality Checks Performed

✅ All package dependencies declared
✅ Memory management included (gc(), rm())
✅ Survey weights properly applied
✅ Robust standard errors (HC1)
✅ State fixed effects included
✅ Caching enabled for large data
✅ Multiple robustness checks included
✅ Professional formatting (JFE-style)

## Expected Runtime

- **Full data (10M obs)**: 10-20 minutes
- **10% sample (1M obs)**: 3-5 minutes
- **Subsequent knits (cached)**: 2-3 minutes

---

**Last Updated**: October 28, 2025
**RMD Version**: 1.0
**Compatible with**: R ≥ 4.0, RStudio ≥ 1.4
