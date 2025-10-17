# The Participation Puzzle: Gender Disparities in Unpaid Care Work in India

[![R](https://img.shields.io/badge/R-4.4+-blue.svg)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

This repository contains replication code and analysis for examining gender disparities in unpaid care work using India's Time Use Survey 2024. The project decomposes gender inequality along two critical dimensions:

1. **Participation rates** (who performs care work)
2. **Time intensity** (how long they spend when they do it)

### Key Finding: The Participation Puzzle

Women perform unpaid care work at rates **3.5 times higher** than men, yet conditional on participation, men and women work **statistically indistinguishable durations** (50.7 vs 47.4 minutes per activity). This reveals that gender inequality stems primarily from categorical norms about *who should* perform care work rather than differences in *how* care work is performed.

**Policy implication:** Interventions must target male participation rates rather than simply redistributing hours among current participants.

## Repository Contents

```
├── README.md                                    # This file
├── gender_disparity_enhanced.Rmd                # Main analysis (JFE-style paper)
├── prompt_template_for_future_threads.md        # Instructions for replicating workflow
├── alternative_large_data_approach.md           # Memory optimization strategies
└── data/                                        # [Not included - see Data Access]
    └── TimeUse106PER.dta                        # TUS 2024 person-level data
```

## Data Access

This analysis uses India's **Time Use Survey 2024** conducted by the National Statistical Office. The dataset contains 10,211,478 activity observations from 139,489 households.

**Data availability:** The microdata can be obtained from the [Ministry of Statistics and Programme Implementation](https://mospi.gov.in/) or through authorized research institutions.

**Data not included in this repository** due to size (1GB+) and data use agreements.

## Acknowledgments

We gratefully acknowledge:

- **Dr. Tanu Goel** (ICRIER) for invaluable guidance and support throughout this research
- **Chellsea** (ICRIER) for essential assistance with data access and methodology
- **Indian Council for Research on International Economic Relations (ICRIER)** for institutional support
- **National Statistical Office, India** for conducting and disseminating the Time Use Survey

## Key Results

### Summary Statistics

| Metric | Women | Men | Ratio |
|--------|-------|-----|-------|
| Daily participation rate | 4.78% | 1.56% | 3.1x |
| Minutes per participant | 47.4 | 50.7 | 0.93x |
| Minutes per person (population) | 2.25 | 0.77 | 2.9x |

### The Decomposition

The aggregate 2.9x gender gap in care work time reflects the **participation gap** (3.1x) rather than an intensity gap (which actually slightly favors male intensity conditional on participation).

### Robustness

The participation gap persists across:
- Urban and rural sectors
- All education levels (primary through higher education)
- Employed and non-employed populations
- All age groups
- Households with and without young children

## Methodology

### Data Processing

1. **Load TUS 2024 person-level data** (10.2M observations)
2. **Filter to major activities** (`Major_Activity_Flag == 1` per TUS guidelines)
3. **Identify care work** (Unpaid_Paid_Status code 02: care for children, sick, elderly, differently-abled household members)
4. **Apply survey weights** (Weight = MULT/100 for national representativeness)

### Statistical Analysis

- **Participation decomposition:** Compare participation rates and conditional time intensity by gender
- **Heterogeneity analysis:** Examine gaps across education, sector, household structure
- **Regression analysis:** Linear probability models with demographics, household controls, state fixed effects
- **Robustness:** Alternative activity definitions (codes 31-33 for direct care activities)

### Software Requirements

```r
# Required R packages
library(haven)         # Read Stata .dta files
library(dplyr)         # Data manipulation
library(ggplot2)       # Visualization
library(knitr)         # R Markdown
library(tidyr)         # Data reshaping
library(fixest)        # Fast fixed effects regression
library(modelsummary)  # Regression tables
library(kableExtra)    # Table formatting
```

**R version:** 4.4+ recommended

## Replication Instructions

### Quick Start

1. **Obtain data:** Request TUS 2024 data from NSO India
2. **Place data file:** Save `TimeUse106PER.dta` in working directory
3. **Run analysis:**
   ```r
   rmarkdown::render("gender_disparity_enhanced.Rmd")
   ```

### For Large Datasets

If you encounter memory errors with the full 10M+ observation dataset:

**Option 1: Sample 10% of data** (see `alternative_large_data_approach.md`)
```r
set.seed(123)
data <- data %>% slice_sample(prop = 0.1)
data <- data %>% mutate(Weight = Weight / 0.1)  # Adjust weights
```

**Option 2: Pre-compute summaries** (recommended for production)
1. Run full analysis in separate R script
2. Save summary objects as .rds files
3. Load only summaries in RMD for fast knitting

See `alternative_large_data_approach.md` for detailed instructions.

### Using the Prompt Template

To recreate this analysis workflow in a new conversation with Claude or another LLM:

1. Open `prompt_template_for_future_threads.md`
2. Copy the "Initial Prompt" section
3. Paste into new conversation
4. Follow with specific analysis requests as needed

The template includes:
- Data structure description
- Research question framing
- Communication style preferences
- Follow-up prompts for each analysis stage
- Expected output specifications

## Results Interpretation

### The Participation Puzzle Explained

Traditional gender gap analysis focuses on total time differences, obscuring the underlying mechanism:

```
Aggregate Gap = Participation Gap × Intensity Gap
     2.9x     =      3.1x        ×      0.93x
```

Our decomposition reveals:
- **Large participation gap:** Women 3x more likely to do care work
- **No intensity gap:** Men who participate work similar hours to women
- **Aggregate gap driven by participation:** Few men participate at all

### Why This Matters for Policy

**Wrong approach:** Reduce hours for participating women (e.g., expand formal childcare)
- Problem: Men still don't participate
- Result: Women get some relief but inequality persists

**Right approach:** Normalize male participation (e.g., mandatory paternity leave, workplace flexibility, social campaigns)
- Target: Bring non-participating men into care work
- Result: Fundamental shift in who performs care work

### Theoretical Implications

The participation puzzle is more consistent with **identity/norms models** (Akerlof & Kranton 2000) than **bargaining models** (Becker 1991):

- If care work reflected economic bargaining, we'd see intensity gaps conditional on participation
- Instead, categorical norm ("care work is women's work") explains the pattern
- Men who violate this norm work as hard as women, but very few violate it

## Citation

If you use this code or analysis, please cite:

```bibtex
@unpublished{gendercapre2025,
  title={The Participation Puzzle: Gender Disparities in Unpaid Care Work in India},
  author={[Your Name]},
  year={2025},
  note={Analysis of India Time Use Survey 2024},
  url={https://github.com/[your-username]/[repo-name]}
}
```

## Literature

Key references informing this analysis:

- Akerlof, G.A., and R.E. Kranton. 2000. "Economics and Identity." *Quarterly Journal of Economics* 115(3): 715-753.
- Ferrant, G., L.M. Pesando, and K. Nowacka. 2014. "Unpaid Care Work: The Missing Link in the Analysis of Gender Gaps in Labour Outcomes." OECD Development Centre.
- Folbre, N. 2006. "Measuring Care: Gender, Empowerment, and the Care Economy." *Journal of Human Development* 7(2): 183-199.
- Goldin, C. 2014. "A Grand Gender Convergence: Its Last Chapter." *American Economic Review* 104(4): 1091-1119.
- Hirway, I. 2010. "Understanding Poverty: Insights Emerging from Time Use of the Poor." In *Unpaid Work and the Economy*.
- Jayachandran, S. 2015. "The Roots of Gender Inequality in Developing Countries." *Annual Review of Economics* 7: 63-88.

## Contact

For questions about the analysis or replication:
- Open an issue on this repository
- [Your contact information]

## License

This project is licensed under the MIT License - see below for details.

```
MIT License

Copyright (c) 2025 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

**Repository Status:** Active development | Replication materials available | Data available upon request

**Last Updated:** October 17, 2025
