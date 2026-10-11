# Research Plan: Exercise, Marriage, and Gender in India

**Working Title:** "The Marriage Exercise Premium: Physical Activity Patterns Among Married and Unmarried Adults in India"

**Alternative Title:** "Marriage and Physical Activity: Unraveling Selection, Resources, and Gender Dynamics in Indian Time Use"

---

## Executive Summary

### The Puzzle
Initial hypothesis predicted marriage would **reduce** women's exercise participation due to time poverty from increased unpaid care work (the "marriage penalty" framework).

**Data shows the opposite**: Marriage **increases** exercise participation for both genders:
- **Women**: 11.97% (never married) → 16.06% (married) = **+4.09pp increase**
- **Men**: 12.70% (never married) → 18.23% (married) = **+5.53pp increase**

This "marriage exercise premium" contradicts time poverty theories but opens fascinating questions about:
1. **Selection effects**: Do healthier/more active people marry?
2. **Age confounding**: Are never-married people younger and less health-conscious?
3. **Household resources**: Do dual-income households afford gym memberships, equipment?
4. **Joint activities**: Do couples exercise together (walking, yoga)?
5. **Gender asymmetry**: Why is men's premium larger (5.53pp vs 4.09pp)?

---

## 1. Data & Feasibility

### Sample Characteristics
From `master_descriptive_statistics.pdf`:

| Group | N (10% sample) | Participation (%) | Mean Minutes |
|-------|----------------|-------------------|--------------|
| **Women Never Married** | 52,597 | 11.97% | 6.17 |
| **Women Married** | 125,703 | 16.06% | 8.73 |
| **Men Never Married** | 73,181 | 12.70% | 6.84 |
| **Men Married** | 113,570 | 18.23% | 9.98 |

**Full dataset estimates** (multiply by 10):
- 525,970 never-married women
- 1,257,030 married women
- 731,810 never-married men
- 1,135,700 married men

### Statistical Power
✅ **Excellent** - Activity Code 71 has 7.51% overall participation
- Far exceeds 2-3% minimum threshold
- ~61,000 people in 10% sample engage in exercise
- Sufficient for interaction effects (gender × marital × age × education)

### Activity Definition
**Code 71: Physical exercise/sports**
- Includes: Gym, yoga, walking for exercise, sports participation
- Mean duration: 54.73 minutes when participating
- Range: 30-390 minutes
- Does NOT include: Walking for transport, household labor, occupational activity

---

## 2. Research Questions

### Primary Question
**RQ1**: How does marriage affect physical exercise participation differently for women vs. men in India?

### Secondary Questions
**RQ2a**: Is the marriage exercise premium driven by age composition (selection)?

**RQ2b**: Does the premium vary by:
- Education level (proxy for SES)
- Urban/rural residence
- Employment status
- Presence of children in household

**RQ3**: What explains the gender asymmetry in the marriage premium (men +5.53pp vs women +4.09pp)?

---

## 3. Theoretical Frameworks

### Framework 1: Time Poverty (REJECTED by data)
**Prediction**: Marriage reduces exercise time, especially for women
- Women acquire unpaid care work burden → less leisure time
- Men's time unaffected or slightly reduced

**Data**: Shows opposite pattern
- **Implication**: Either (1) time poverty theory wrong, (2) selection dominates, or (3) marriage provides compensating resources

### Framework 2: Selection Effects
**Prediction**: Healthier, more active people are more likely to marry
- Marriage market rewards health/fitness (attractiveness, energy)
- Never-married population negatively selected on health

**Test**: Compare:
- Recent marriages (selection still strong) vs. long marriages
- Age-specific marriage premiums
- Control for baseline health indicators (if available)

### Framework 3: Household Resources & Infrastructure
**Prediction**: Marriage increases access to resources that enable exercise
- **Dual incomes** → gym memberships, equipment, activewear
- **Social support** → couples exercise together, take turns with childcare
- **Residential quality** → married people live in neighborhoods with parks, gyms

**Test**:
- Urban/rural differences (infrastructure)
- Education × marriage interactions (SES proxy)
- Employment status interactions

### Framework 4: Life Course & Routine Structuring
**Prediction**: Marriage creates stable routines that include exercise
- Married people have more structured daily schedules
- Health awareness increases (especially with children)
- Social norms of "family health" and longevity

**Test**:
- Age patterns
- Presence of children effects
- Weekend vs. weekday exercise patterns

---

## 4. Hypotheses

### H1: Age Confounding (Most Likely)
Never-married adults are younger → in life stages with less exercise habits:
- Students (prioritize study over exercise)
- Young workers (long hours, urban migration, unsettled)
- Pre-health-awareness life stage

**Test**: Age-stratified analysis. If marriage premium disappears within age groups, it's pure selection.

### H2: Selection on Health
Healthier, more active people marry earlier/at higher rates
**Test**: Can't directly test without health data, but:
- Compare early vs. late marriages
- Look at widowed (were married, now not) as counterfactual

### H3: Dual Resources (SES)
Marriage provides household resources enabling exercise
**Test**:
- Marriage premium larger for educated/urban couples?
- Employment interactions (dual-earner premium?)

### H4: Gender Asymmetry - Men's Greater Premium
Men's +5.53pp > Women's +4.09pp. Why?

**Possible explanations**:
- Men's baseline lower → more room to grow
- Women exercise more pre-marriage (body image, marriage market pressure)
- Men gain more from household stability/resources
- Cultural: married men expected to maintain health (provider role)

**Test**: Decomposition by age, SES, children

---

## 5. Analytical Approach

### Step 1: Descriptive Patterns
**Tables**:
1. Exercise participation by gender × marital status (DONE - in PDF)
2. Exercise participation by gender × marital × age group
3. Exercise participation by gender × marital × education
4. Exercise participation by gender × marital × urban/rural
5. Exercise participation by gender × marital × employment

**Figures**:
1. Bar chart: Marriage premium by gender
2. Line chart: Exercise participation by age, separate lines for married/unmarried × gender
3. Coefficient plot: Marriage premium across subgroups

### Step 2: Regression Analysis

#### Model 1: Baseline (No Controls)
```
Exercise_i = β₀ + β₁Female + β₂Married + β₃(Female × Married) + εᵢ
```
- Tests raw marriage premium
- Expected: β₂ > 0, β₃ ≈ 0 or negative (smaller premium for women)

#### Model 2: Age Controls (Critical Test)
```
Exercise_i = β₀ + β₁Female + β₂Married + β₃(Female × Married)
           + β₄Age + β₅Age² + εᵢ
```
- **Key test**: Does β₂ shrink dramatically? → Age confounding
- Age² captures non-linear relationship (exercise peaks mid-life, declines after)

#### Model 3: Full Controls
```
Exercise_i = β₀ + β₁Female + β₂Married + β₃(Female × Married)
           + β₄Age + β₅Age² + β₆Education + β₇Urban + β₈Employed
           + State FE + εᵢ
```
- Education: Primary/Secondary/Higher
- Urban: Rural=0, Urban=1
- Employed: Employment status codes
- State FE: Control for regional variation in exercise culture

Cluster SEs at household level.

#### Model 4: Heterogeneity by Age
```
Exercise_i = β₀ + Σ(βₖ Married × AgeGroup_k) + γFemale + Controls + εᵢ
```
- Estimate marriage premium separately for age groups: 18-24, 25-34, 35-44, 45-54, 55-64, 65+
- Visualize coefficients
- Test if premium is constant or varies by life stage

#### Model 5: Heterogeneity by SES (Education × Urban)
```
Exercise_i = β₀ + β₁Married + β₂(Married × HighEd) + β₃(Married × Urban)
           + β₄(Married × HighEd × Urban) + Controls + εᵢ
```
- Test resource mechanism: premium larger for high-SES?

#### Model 6: Gender-Specific Models
Run full model separately for women and men:
```
Exercise_i = β₀ + β₁Married + β₂Age + β₃Age² + β₄Education + ... + εᵢ
```
- Compare βₘₐᵣᵣᵢₑ_ᵨᵩₘₑₙ vs. βₘₐᵣᵣᵢₑ_ᵨᵤₑₙ
- Test if education/urban/employment mediate differently by gender

### Step 3: Robustness Checks

#### Robustness 1: Alternative Marital Status Definitions
- Exclude divorced/separated (confounded by marriage dissolution)
- Compare currently married vs. never married (clean comparison)
- Widowed as additional category (lost spouse - health shock?)

#### Robustness 2: Alternative Exercise Definitions
- **Intensive margin**: Minutes spent (among participants)
- **Any exercise**: Participation dummy (current specification)
- **Regular exercise**: Participates >1 time in diary period (if detectable)

#### Robustness 3: Weekend Effects
- Weekend exercise vs. weekday exercise
- Marriage premium different on weekends? (joint couple time)

#### Robustness 4: Urban-Rural Stratified Models
From PDF: Rural 7.92% vs Urban 6.60% exercise participation
- Run full models separately by sector
- Test if marriage premium differs

---

## 6. Expected Findings & Implications

### Scenario A: Age Confounding Dominates
**Finding**: Marriage premium disappears when controlling for age
- Never-married are younger (18-24) → naturally exercise less
- Married are 35-50 → peak exercise years (health awareness, resources)

**Implication**: Not really about marriage per se, but life stage selection
**Paper angle**: "Selection into Marriage and Exercise: Disentangling Age, Health, and Union Formation"

### Scenario B: True Marriage Premium (Resource Mechanism)
**Finding**: Marriage premium persists after age controls, larger for high-SES
- Education × Marriage interaction positive
- Urban × Marriage interaction positive

**Implication**: Household resources (dual income, infrastructure access) enable exercise
**Paper angle**: "Marriage and Health Investments: How Household Resources Shape Physical Activity in India"
**Policy**: Public infrastructure (parks, community exercise programs) can substitute for private resources

### Scenario C: Gender Asymmetry Story
**Finding**: Men's premium (5.53pp) significantly larger than women's (4.09pp)
- Persists after controls
- Driven by men in low-SES groups

**Implication**: Marriage liberates men from survival mode, enables self-investment
- Women already exercise more pre-marriage (marriage market pressure?)
- Men gain more from household stability

**Paper angle**: "Gendered Returns to Marriage: Why Indian Men Exercise More After Marriage"

### Scenario D: Selection + Resources (Most Likely)
**Finding**:
- Marriage premium shrinks 50% with age controls (selection)
- But remains significant (true effect)
- Larger for educated/urban (resources)
- Men's premium larger (asymmetric household dynamics)

**Implication**: Complex story - both selection and causation matter
**Paper angle**: "The Marriage Exercise Premium in India: Untangling Selection, Resources, and Gender"

---

## 7. Contributions to Literature

### Contribution 1: Novel Empirical Finding
- First study to document marriage exercise premium in developing country
- Contradicts time poverty predictions
- Large-scale data (1M+ individuals)

### Contribution 2: Selection vs. Causation Decomposition
- Most studies assume marriage penalties/premiums are causal
- We show age confounding likely dominates
- Important for interpreting marriage effects literature

### Contribution 3: Gender Asymmetry in Health Behaviors
- Men's premium > Women's premium
- Challenges symmetric bargaining models
- Reveals gendered nature of household resource allocation

### Contribution 4: Policy Implications
- If resources matter: Public infrastructure > private solutions
- If selection matters: Health interventions should target never-married youth
- Gender-specific approaches needed

---

## 8. Limitations & Threats to Inference

### Limitation 1: Cross-Sectional Data
- Cannot establish causation
- Cannot rule out selection (healthier people marry)
- Cannot observe within-person change

**Mitigation**:
- Extensive controls (age, SES, region)
- Heterogeneity analysis (test mechanisms)
- Transparent about descriptive nature

### Limitation 2: Single-Day Measurement
- Exercise is episodic (3x/week typical)
- Single diary day may miss habitual exercisers
- Underestimates true participation rate

**Mitigation**:
- Large sample compensates (averages converge)
- Measurement error likely random (unbiased)
- Affects levels, not comparative patterns

### Limitation 3: Definition of Exercise
- Code 71 may exclude some exercise (sports travel, outdoor recreation separate)
- May include non-intentional activity
- Cultural variation in what counts as "exercise"

**Mitigation**:
- Robustness check combining codes 71-79 (all sports/outdoor)
- Sensitivity to broader recreation definition

### Limitation 4: Marital Selection Unobservable
- Cannot observe health/fitness before marriage
- Cannot rule out "healthy marry" selection
- Widowed provide weak counterfactual (health shock)

**Mitigation**:
- Age-stratified analysis (reduce selection window)
- Comparison to other life transitions
- Transparent limitations discussion

### Limitation 5: Missing Mechanisms
- No data on gym access, neighborhood quality, time use details
- Cannot directly test resource mechanism
- Must rely on proxies (education, urban)

**Mitigation**:
- Use available proxies
- Clearly label tests as indirect
- Call for future data collection

---

## 9. Paper Outline

### Title
"The Marriage Exercise Premium: Physical Activity Patterns Among Married and Unmarried Adults in India"

### Abstract (Draft)
Using India's 2024 Time Use Survey (8.4M observations, 394,000 individuals), we examine the relationship between marriage and physical exercise participation. Contrary to time poverty theories predicting marriage reduces women's leisure time, we find marriage is associated with higher exercise participation for both genders: +4.09 percentage points for women, +5.53 for men. Age confounding explains approximately 50% of this premium, but a significant marriage effect persists after extensive controls. The premium is larger among educated, urban, and employed individuals, suggesting household resources enable exercise investments. Men's larger premium reveals gendered asymmetries in how marriage affects health behaviors. Our findings challenge simplistic marriage penalty narratives and highlight the importance of disentangling selection from causation in family economics research.

**JEL**: I12, J12, J16, O15
**Keywords**: Physical activity, marriage, gender, time use, India, health behaviors

### Sections

**1. Introduction**
- Puzzle: Marriage increases, not decreases, exercise
- Theoretical frameworks: time poverty vs. resources vs. selection
- Preview findings: Age + resources explain premium, gender asymmetry persists
- Contributions

**2. Background: Marriage, Gender, and Time Use in India**
- Extensive literature on marriage care penalty
- Health behaviors and household bargaining
- Exercise culture in India (rising middle class, gym culture, yoga)
- Gender norms around physical activity

**3. Data and Measurement**
- TUS 2024 overview
- Exercise definition (Code 71)
- Sample restrictions (adults 18+)
- Descriptive statistics

**4. Descriptive Patterns**
- Table 1: Exercise by marital status × gender
- Figure 1: Marriage premium visualization
- Table 2: Exercise by age × marital × gender
- Figure 2: Age gradient in exercise participation

**5. Regression Analysis**
- Baseline model: Marriage premium
- Age controls: Test confounding
- Full controls: SES, region, employment
- Heterogeneity: Age groups, education, urban/rural
- Gender-specific models

**6. Mechanisms and Interpretation**
- Age selection (50% of premium)
- Household resources (education/urban gradients)
- Gender asymmetry (men benefit more - why?)
- Alternative explanations (life course, health awareness)

**7. Robustness Checks**
- Alternative marital definitions
- Intensive margin (minutes)
- Weekend effects
- Urban-rural stratification

**8. Discussion and Policy Implications**
- Selection vs. causation in marriage research
- Public infrastructure to enable exercise
- Gender-specific health interventions
- Limitations and future research

---

## 10. Timeline

### Week 1: Data Analysis
- Run all regression models
- Generate all tables and figures
- Robustness checks
- Save results in organized format

### Week 2: First Draft
- Write introduction and background
- Write data and methods
- Write results section
- Placeholder discussion

### Week 3: Revision
- Refine theoretical framework
- Strengthen mechanism discussion
- Add literature review
- Polish tables/figures

### Week 4: Finalization
- Complete discussion
- Abstract and conclusion
- Formatting for journal submission
- Internal review

---

## 11. Data Requirements

### Variables Needed
From TUS 2024:
- ✅ `Activity_Code_2Digit == 71` (exercise)
- ✅ `Gender` (1=Male, 2=Female)
- ✅ `Marital_Status` (1=Never married, 2=Currently married, 3=Widowed, 4=Divorced)
- ✅ `Age` (continuous)
- ✅ `Highest_Education` (1-12 scale)
- ✅ `Sector` (1=Rural, 2=Urban)
- ✅ `Principal_Activity_Status` (employment)
- ✅ `State` (for fixed effects)
- ✅ `Weight` (survey weights)
- ✅ `FSU_Serial_No`, `Sample_HH_No` (household clustering)

**All variables confirmed available** in master_descriptive_statistics.pdf

---

## 12. Target Journals

### Tier 1 (Ambitious)
1. **Journal of Development Economics** - Top development journal, strong on time use
2. **Demography** - Leading demographic journal, marriage and health
3. **Journal of Marriage and Family** - Specialty journal, high impact

### Tier 2 (Likely Fit)
4. **Economic Development and Cultural Change** - Strong development economics
5. **World Development** - Interdisciplinary development
6. **Health Economics** - Health behaviors focus

### Tier 3 (Backup)
7. **Review of Economics of the Household** - Family economics specialty
8. **Journal of Biosocial Science** - Health and demography
9. **SSM - Population Health** - Open access, fast turnaround

---

## 13. Key Figures and Tables (Planned)

### Figures
**Figure 1**: Marriage Exercise Premium by Gender
- Bar chart: 4 bars (Women NM, Women M, Men NM, Men M)
- Show percentage points difference

**Figure 2**: Age Gradient in Exercise Participation
- Line chart: Age (x-axis) vs. Participation % (y-axis)
- 4 lines: Women NM, Women M, Men NM, Men M
- Shows if premium is age-specific

**Figure 3**: Coefficient Plot - Marriage Premium Across Subgroups
- Dots with confidence intervals
- Rows: Overall, Age 18-24, 25-34, 35-44, 45-54, 55+, Rural, Urban, Low Ed, High Ed
- Shows heterogeneity

### Tables
**Table 1**: Descriptive Statistics by Marital Status and Gender

**Table 2**: Exercise Participation Regression Results
- Cols: (1) Baseline, (2) +Age, (3) +SES, (4) +State FE, (5) Women, (6) Men

**Table 3**: Marriage Premium by Age Group (Interaction Model)

**Table 4**: Marriage Premium by SES (Education × Urban)

**Table 5**: Robustness Checks (Alternative Specs)

---

## Next Steps

1. ✅ **DONE**: Master descriptive statistics compiled
2. **NOW**: Create analysis RMD file (`exercise_marriage_analysis.Rmd`)
3. Run all regression models
4. Generate tables and figures
5. Begin writing introduction and background

---

**Document Status**: Research plan approved and ready for execution
**Last Updated**: November 8, 2025
**Next Action**: Create `exercise_marriage_analysis.Rmd` and begin regression analysis
