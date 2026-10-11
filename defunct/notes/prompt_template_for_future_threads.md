# PROMPT FOR FUTURE CONVERSATIONS: Gender Disparity in Unpaid Care Work Analysis

Use this prompt to recreate the analytical workflow in a new conversation thread.

---

## Initial Prompt

I'm analyzing India's Time Use Survey 2024 to study gender disparities in unpaid care work. I have:

1. **Data file**: TUS106PER.dta (Stata format, 10.2M observations)
2. **Documentation**: README, data layout, code definitions, and instructions PDFs/Excel files

**Key variables in the dataset:**
- `Gender`: 1=male, 2=female, 3=transgender
- `Unpaid_Paid_Status`: Activity classification (02=care work for household members)
- `Activity_Code_2Digit`: Detailed activity codes (31=childcare, 32=adult care, 33=non-household care)
- `time_spent`: Minutes spent on activity
- `Weight`: Survey weight (use for population estimates)
- `Major_Activity_Flag`: 1=major activity (use only these per TUS guidelines)

**My research question:**
Do women spend more time than men on unpaid care work in India? I want to understand both:
1. Participation rates (who does care work)
2. Time intensity (how long they spend when they do it)

**What I need from you:**
1. R code to analyze participation gaps vs. intensity gaps by gender
2. Statistical analysis showing the "participation puzzle" (if men who participate work similar hours to women)
3. Heterogeneity analysis by education, urban/rural, household composition
4. Regression analysis controlling for demographics
5. A publication-ready R Markdown document in JFE/AER journal style with:
   - Two-column format
   - Literature review
   - Regression tables
   - Professional figures
   - Policy discussion
6. Clear, direct commentary without filler

**Your communication style:**
- Blunt, directive phrasing
- No emojis, no hype, no soft language
- Assume I understand concepts; just give me the code and insights
- Small paragraphs, minimal bullet points unless I request them
- Focus on cognitive efficiency

Start by helping me:
1. Load the .dta file in R
2. Verify the data structure
3. Calculate basic participation rates and time intensity by gender
4. Identify if there's a participation gap vs. intensity gap

Then we'll build toward the full analysis and paper.

---

## Follow-up Instructions (use as needed)

### If starting with raw data exploration:
"Show me R code to:
- Load the Stata file
- Filter to major activities only
- Calculate participation rates by gender for care work (code 02)
- Calculate average minutes per participant
- Calculate average minutes per person (including non-participants)
Break down the participation puzzle clearly."

### If moving to heterogeneity analysis:
"Add analysis by:
- Education level (primary/secondary/higher)
- Urban vs rural
- Presence of children under 6
- Presence of elderly (60+)
Show if the participation gap persists across these subgroups."

### If moving to regression analysis:
"Write regression code using fixest package:
- Linear probability model of care work participation
- Controls: age, age^2, education, marital status, employment, sector
- State fixed effects
- Weighted by survey weights
- Heteroskedasticity-robust standard errors
Create a professional regression table."

### If requesting the full paper:
"Create a complete R Markdown document suitable for submission to JFE or AER:
- Abstract with JEL codes and keywords
- Introduction with literature review and contribution
- Data and methods section
- Results with tables and figures
- Discussion with policy implications
- References in standard economics journal format
- Use two-column layout if possible, or professional single-column
- Include all code chunks but set echo=FALSE for final output"

### If needing literature additions:
"Add literature review covering:
- Gender and unpaid work (Folbre, Ferrant et al.)
- Time use in India (Hirway, Chakraborty et al.)
- Bargaining models vs. identity models (Becker, Akerlof & Kranton)
- Policy implications (Goldin on flexibility, Kleven et al. on child penalties)
Integrate these naturally into the introduction and discussion."

---

## Technical Requirements Reminder

**R packages needed:**
```r
library(haven)      # Read .dta files
library(dplyr)      # Data manipulation
library(ggplot2)    # Visualization
library(knitr)      # R Markdown
library(tidyr)      # Data reshaping
library(fixest)     # Fast fixed effects
library(modelsummary) # Regression tables
library(kableExtra) # Table formatting
```

**Weight calculation:**
Final weight = MULT / 100 (but dataset already has `Weight` column calculated)

**Activity filtering:**
Always use `Major_Activity_Flag == 1` per TUS documentation

**Key finding to emphasize:**
Women participate 3.5x more than men, but participating men work similar hours to women. This is the "participation puzzle" - the gap is extensive margin (participation) not intensive margin (hours).

---

## Expected Output

You should produce:
1. Clean, efficient R code for all analyses
2. Tables formatted for academic publication
3. Professional ggplot2 figures
4. A complete R Markdown document that compiles to PDF
5. Clear interpretation of the "participation puzzle" finding
6. Policy implications focused on normalizing male participation
7. Methodological notes on why aggregate measures obscure the true pattern

The final paper should be ready for submission to a top economics journal after adding author names and institutional details.

---

## Notes on Communication Preferences

From my user preferences:
- I prefer direct, technical language without softening
- Skip social niceties and get to the analysis
- Use small paragraphs rather than excessive bullet points
- Don't mirror my language - maintain technical precision
- The goal is cognitive efficiency, not engagement
- Assume high comprehension; explain technical choices, not basics

If I say "this is good" or "looks right," proceed to next analysis stage without asking for confirmation.
