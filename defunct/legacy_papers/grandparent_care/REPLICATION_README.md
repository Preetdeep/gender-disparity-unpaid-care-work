# Replication Materials: "The Grandparent Care Economy"

## Author
Dr Preet Deep Singh
Blue Machines
preetdeepsingh111@yahoo.com

## Paper Citation
Singh, P. D. (2025). The Grandparent Care Economy: A Surprising Null Effect on Women's Childcare Burden in Urban India.

## Data Sources

### Primary Data
- **Source**: India Time Use Survey 2024, National Statistical Office, Ministry of Statistics and Programme Implementation, Government of India
- **Access**: Microdata available upon application to NSO India at https://www.mospi.gov.in/
- **Coverage**: Nationally representative household survey with detailed 24-hour time diaries
- **Sample**: ~10.2 million person-day observations from 1.4 million households

### Analysis Sample
- **Subsample**: 10% random sample (seed: 123) used for computational feasibility
- **Validation**: Population statistics compared with subsample (differences < 0.5%)
- **Final sample**: ~1 million person-day observations from ~140,000 households

## Software Requirements

### R Version
- R 4.3.0 (2023-04-21) or later

### Required Packages
Install all packages with:
```r
install.packages(c("haven", "dplyr", "ggplot2", "knitr", "tidyr",
                   "fixest", "modelsummary", "kableExtra", "gridExtra",
                   "Hmisc", "pwr", "MatchIt"))
```

Package versions used:
- haven 2.5.2
- dplyr 1.1.2
- ggplot2 3.4.2
- fixest 0.11.1
- modelsummary 1.4.1
- kableExtra 1.3.4
- pwr 1.3-0
- MatchIt 4.5.3

## Computational Requirements

### Hardware
- **RAM**: 16GB recommended (4GB minimum for 10% subsample)
- **Storage**: ~5GB for data files
- **Runtime**: ~30 minutes for complete analysis pipeline

### Operating System
- Code is platform-independent (tested on Linux, Windows, MacOS)

## File Structure

```
.
├── REPLICATION_README.md          # This file
├── grandparent_care_economy_ClaudeHTML.Rmd  # Main analysis script
├── TimeUse106PER.dta              # Primary data file (obtain from NSO)
├── DataDictionaryTimeUseSurvey.xlsx  # Variable documentation
└── output/
    ├── grandparent_care_economy.html  # HTML output
    ├── grandparent_care_economy.pdf   # PDF output
    └── figures/                   # Generated figures
```

## Replication Steps

### Step 1: Obtain Data
1. Apply for microdata access from NSO India
2. Download `TimeUse106PER.dta` file
3. Place file in project directory

### Step 2: Run Analysis
#### Option A: Knit R Markdown
```r
# In R or RStudio
rmarkdown::render("grandparent_care_economy_ClaudeHTML.Rmd")
```

#### Option B: Run in Separate Scripts
The analysis can be broken into modular scripts:
1. `01_data_cleaning.R`: Load data, create variables
2. `02_descriptive_analysis.R`: Summary statistics, diagnostics
3. `03_main_regressions.R`: Core models (Tables 2-6)
4. `04_robustness_checks.R`: Robustness and sensitivity analyses
5. `05_figures.R`: All visualizations
6. `06_tables.R`: Formatted regression tables

### Step 3: Verify Output
- Check console output for subsample validation diagnostics
- Verify power analysis results
- Compare propensity score overlap
- Review all regression tables

## Key Results to Replicate

### Main Finding
- Urban grandparent effect: β ≈ 0.05 minutes (SE: 0.59, p > 0.10)
- Effect robust across employment status, grandparent gender, household characteristics

### Robustness
- Power analysis: MDE ~5-8 minutes at 80% power
- IPW and matching estimates: remain near zero
- Placebo test (male childcare): no effect
- Oster bounds: coefficient stable to omitted variables

### Rural-Urban Contrast
- Rural effect: positive and significant (+1.74 minutes, p < 0.001)
- Explained by stronger selection on childcare need

## Analytic Decisions

### Pre-Registration
- Study was not pre-registered
- Exploratory analysis informed model specifications

### Sample Restrictions
1. **Urban focus**: Justified by theoretical framework (higher opportunity costs, lack of kin networks)
2. **Age 20-50**: Standard in maternal time use literature
3. **10% subsample**: Computational constraint, validated for representativeness
4. **Households with children**: Required for childcare analysis

### Model Specifications
- **Baseline controls**: Age, age², marital status, employment, education, household size
- **Key addition**: Eldercare minutes (tests offset hypothesis)
- **Fixed effects**: State-level (controls regional heterogeneity)
- **Standard errors**: Clustered at household level

### Alternative Specifications
- Extensive margin (any childcare vs. none): reported in robustness
- Total care time (childcare + eldercare): reported in robustness
- Rural sample: analyzed separately to explain urban-rural contrast

## Troubleshooting

### Common Issues

#### Missing Data File
**Error**: `Error in read_dta("TimeUse106PER.dta"): cannot open file`
**Solution**: Ensure data file is in working directory. Check with `list.files()`

#### Memory Errors
**Error**: `Error: cannot allocate vector of size...`
**Solution**:
- Increase R memory limit: `memory.limit(size = 16000)` (Windows)
- Use 10% subsample (already implemented)
- Close other applications

#### Package Installation Failures
**Error**: Package installation fails
**Solution**:
- Update R to latest version
- Install from CRAN: `install.packages("package_name")`
- For Linux: may need system dependencies (`sudo apt-get install libxml2-dev`)

## Contact

For questions about replication:
- Email: preetdeepsingh111@yahoo.com
- Include "Grandparent Care Replication" in subject line

## License

Replication materials released under MIT License. Original data subject to NSO India terms of use.

## Version History

- v1.0 (2025-11-19): Initial release
- Includes all robustness checks and sensitivity analyses
- Full transparency in analytic decisions

## Acknowledgments

Data source: National Statistical Office, Ministry of Statistics and Programme Implementation, Government of India.
