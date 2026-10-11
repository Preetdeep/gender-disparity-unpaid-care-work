# Editorial Review: Marriage Care Penalty Paper

**Reviewer:** Claude (as JFE Editor)
**Date:** November 1, 2025
**Paper:** "The Marriage Care Penalty: How Marriage Increases Women's Unpaid Work While Men's Remains Unchanged"

---

## EXECUTIVE SUMMARY

**Recommendation:** REJECT and REVISE with MAJOR corrections required

**Critical Issues Found:** 2 fatal errors, 3 major issues, multiple moderate issues

This paper addresses an important research question but contains **FATAL CODING ERRORS** that invalidate the entire empirical analysis. The manuscript requires substantial revision before it can be considered for publication.

---

## PART 1: FATAL ERRORS (Must Fix Immediately)

### 🚨 CRITICAL ERROR 1: Wrong Gender in Men's Married Participation Calculation

**Location:** Lines 141-143 of marriage_care_penalty.Rmd

**The Bug:**
```r
men_married_participation <- major_only %>%
  filter(Gender == 2, Marital_Status == 2) %>%  # ← WRONG! Gender == 2 is FEMALE!
  summarise(rate = weighted.mean(care_work, Weight, na.rm = TRUE)) %>%
  pull(rate) * 100
```

**What it should be:**
```r
men_married_participation <- major_only %>%
  filter(Gender == 1, Marital_Status == 2) %>%  # ← CORRECT: Gender == 1 is Male
  summarise(rate = weighted.mean(care_work, Weight, na.rm = TRUE)) %>%
  pull(rate) * 100
```

**Impact:**
- This variable calculates **women's** married participation rate instead of **men's** married participation
- The entire claim that "Men experience no marriage effect" is based on **comparing two women's rates**
- The marriage penalty calculation is completely invalid
- **ALL empirical results are unreliable** until this is fixed

**How this happened:** Classic copy-paste error. Lines 131-133 (women_married_participation) were copied to create lines 141-143, but Gender == 2 was not changed to Gender == 1.

---

### 🚨 CRITICAL ERROR 2: Sample Size Ambiguity in Abstract

**Location:** Line 7 (Abstract)

**Current Text:**
> "Using India's 2024 Time Use Survey (10.2 million observations, 139,489 households)"

**The Problem:**
- Abstract claims 10.2 million observations
- Code uses **10% random sample** (line 65: `slice_sample(prop = 0.1)`)
- Actual analysis sample ≈ 836,156 observations
- Introduction correctly states sample size using dynamic `total_obs` variable
- **Abstract contradicts the actual methodology**

**What it should say:**
> "Using a 10% random sample of India's 2024 Time Use Survey (approximately 836,000 person-day observations from 9,969 households)"

OR if you want to emphasize full survey scope:
> "Using a 10% random sample of India's 2024 Time Use Survey (10.2 million total observations, analysis sample: ~836,000 observations from 9,969 households)"

**Impact:**
- Misleads readers about sample size and statistical power
- Violates transparency standards
- May appear as intentional inflation of sample size

---

## PART 2: MAJOR ISSUES

### Issue 3: Missing "Major Activities" Explanation in Abstract

**Problem:** Abstract doesn't mention that analysis restricts to "Major_Activity_Flag == 1" which reduces the sample from 10.2M to ~8.4M before the 10% sampling.

**Fix:** Add brief methodological note:
> "Using a 10% random sample of major activity observations from India's 2024 Time Use Survey..."

---

### Issue 4: Inconsistent Activity Definition

**Problem:** The paper analyzes "unpaid care work" (Unpaid_Paid_Status == "02") but other papers in your repository analyze specific activity codes (31, 32, 33-35).

**Questions to address:**
- What does code "02" include exactly?
- How does this differ from the childcare (code 31) + adult care (code 32) definition used in childcare_vs_eldercare.Rmd?
- Are you capturing the same phenomenon or something broader?

**Recommendation:** Add explicit table showing which ICATUS activity codes fall under Unpaid_Paid_Status == "02" for transparency.

---

### Issue 5: Gender Coding Assumption Not Verified

**Location:** Lines 74-78

**Current Code:**
```r
gender_label = case_when(
  Gender == 1 ~ "Male",
  Gender == 2 ~ "Female",
  Gender == 3 ~ "Transgender"
),
```

**Problem:** You assume Gender variable codes 1=Male, 2=Female without verification from the data dictionary. While this is likely correct (matching the other papers), it should be explicitly stated or verified.

**Fix:** Add comment referencing TUS codebook or verify with `count(Gender)` output in supplementary materials.

---

## PART 3: MODERATE ISSUES

### Issue 6: Line 295-298 Recalculates Men's Rate (Correctly This Time)

**Location:** Lines 295-298

```r
men_married_rate <- major_only %>%
  filter(Gender == 1, Marital_Status == 2) %>%  # ← Correctly uses Gender == 1 here
  summarise(rate = weighted.mean(care_work, Weight, na.rm = TRUE)) %>%
  pull(rate) * 100
```

**Observation:** This code snippet later in the file **correctly** filters for Gender == 1 (Male). This suggests:
- The error in lines 141-143 was indeed a copy-paste mistake
- The descriptive text using `men_married_rate` in line 308 may be correct IF it uses this recalculated variable
- **However**, the variables calculated in lines 135-143 may still be used elsewhere

**Action needed:**
1. Fix lines 141-143
2. Search entire file for uses of `men_married_participation` to see if the bug propagated to tables/figures
3. Delete the incorrect variable to prevent future confusion

---

### Issue 7: Household ID Construction Not Verified Unique

**Location:** Line 122

```r
total_households <- length(unique(paste(major_only$FSU_Serial_No, major_only$Sample_HH_No)))
```

**Problem:** You assume concatenating FSU_Serial_No + Sample_HH_No creates unique household IDs but don't verify. If FSU_Serial_No is not unique across sampling stages, you could be undercounting households.

**Fix:** Add verification check or use interaction:
```r
major_only <- major_only %>%
  mutate(household_id = paste(FSU_Serial_No, Sample_HH_No, sep = "_"))

# Verify uniqueness
stopifnot(length(unique(major_only$household_id)) ==
          length(unique(interaction(major_only$FSU_Serial_No, major_only$Sample_HH_No))))
```

---

### Issue 8: Age Cutoff of 25 Not Justified

**Location:** Line 87-89

You split at age 25 but don't justify this choice. Why not 20? 30? Median marriage age for women in India?

**Fix:** Add justification in text:
- State median/mean marriage age in India
- Explain that 25 approximates this threshold
- Show robustness to alternative cutoffs (you do this in lines 595-628, which is good!)

---

### Issue 9: Standard Errors Use HC1 Not Household Clustering

**Location:** Lines 348-349, and throughout

```r
m1 <- feols(care_work ~ female + married + female_married,
            data = reg_data, weights = ~Weight, vcov = "HC1")
```

**Problem:** You use heteroskedasticity-robust SEs (HC1) but **don't cluster at household level** like the other papers in your repository do.

**Why this matters:**
- Multiple individuals from same household have correlated errors
- Not accounting for this **understates standard errors** and **overstates significance**
- Other papers use `vcov = ~household_id` for clustering

**Fix:** Change to:
```r
m1 <- feols(care_work ~ female + married + female_married,
            data = reg_data, weights = ~Weight,
            vcov = ~household_id)  # ← Cluster at household level
```

**Do this for ALL regression models** throughout the paper.

---

### Issue 10: Missing R² Interpretation

**Problem:** You report regression results but don't discuss model fit (R²). If R² is very low (< 0.05), you should acknowledge that most variation is unexplained.

**Fix:** Add brief discussion after Table 3 or 4 noting model fit and what this implies about unexplained variation.

---

## PART 4: MINOR ISSUES & SUGGESTIONS

### Issue 11: Data Availability Statement Incomplete

**Current:** "Analysis code and documentation available upon request."

**Better:**
> "Analysis code available upon request. Original data from National Statistical Office Time Use Survey 2024, available at [URL or contact info]."

---

### Issue 12: Figure Captions Could Be More Informative

Example: Line 658 caption is generic. Better caption:

> "Figure 2: Marriage increases women's care work participation by 8-9 percentage points across all education levels, showing that the marriage penalty persists even among college-educated women. Based on 10% random sample of TUS 2024 major activities."

---

### Issue 13: Missing Robustness Check - Alternative Marital Status Definitions

You exclude widowed and divorced. Briefly justify or show robustness:
- What % of sample is excluded?
- Would including widowed/divorced change results?

---

### Issue 14: Conclusion Overclaims Causality

**Location:** Throughout Conclusion section

**Problem:** Paper correctly states "we do not claim causal identification" in methods but then conclusion uses causal language:
- "marriage activates gender-specific norms"
- "marriage generates gender disparities"

**Fix:** Use correlational language:
- "marriage is associated with..."
- "married women show higher..."
- "the data suggest marriage may activate..."

---

## PART 5: STRENGTHS OF THE PAPER

### What Works Well:

1. ✅ **Clear research question** - Well-motivated and policy-relevant
2. ✅ **Age heterogeneity analysis** - Testing young vs. old marriage penalties is novel
3. ✅ **Robustness checks across education, urban/rural, employment** - Comprehensive
4. ✅ **Honest about identification limits** - States clearly "we do not claim causal identification"
5. ✅ **Good use of survey weights** - Consistently applies weights throughout
6. ✅ **Sensitivity analysis on age cutoffs** - Table showing robustness to 20, 22, 25, 27, 30 cutoffs is excellent
7. ✅ **Dynamic calculation of statistics** - Using R inline code to auto-update numbers reduces transcription errors

---

## PART 6: SPECIFIC CORRECTIONS NEEDED

### Priority 1 (Fix Before Any Analysis Can Be Trusted):

1. **Lines 141-143:** Change `Gender == 2` to `Gender == 1` in men_married_participation calculation
2. **Line 7 (Abstract):** Change "10.2 million observations" to "~836,000 observations (10% sample)"
3. **All regression models:** Change `vcov = "HC1"` to `vcov = ~household_id`

### Priority 2 (Fix Before Submission):

4. Add table showing ICATUS codes included in Unpaid_Paid_Status == "02"
5. Justify age 25 cutoff in text
6. Add R² discussion after main regression table
7. Check ALL uses of incorrectly calculated `men_married_participation` variable and replace

### Priority 3 (Improve But Not Critical):

8. Enhance figure captions with substantive interpretation
9. Add robustness check including widowed/divorced or justify exclusion
10. Soften causal language in conclusion
11. Improve data availability statement

---

## PART 7: RECOMMENDED REVISION ROADMAP

### Step 1: Fix Fatal Errors (Do This Now)

```r
# Line 141-143: CRITICAL FIX
men_married_participation <- major_only %>%
  filter(Gender == 1, Marital_Status == 2) %>%  # ← Changed from Gender == 2
  summarise(rate = weighted.mean(care_work, Weight, na.rm = TRUE)) %>%
  pull(rate) * 100
```

**After fixing, verify results make sense:**
- Men's participation should be LOWER than women's
- Marriage effect for men should be small or zero
- If men's participation suddenly equals women's, you still have the bug!

### Step 2: Fix Abstract Sample Size

```yaml
abstract: |
  Using a 10% random sample of India's 2024 Time Use Survey (approximately 836,000 person-day observations from 9,969 households)...
```

### Step 3: Add Household Clustering

Search and replace in all `feols()` calls:
- OLD: `vcov = "HC1"`
- NEW: `vcov = ~household_id`

But first create household_id variable:
```r
major_only <- major_only %>%
  mutate(household_id = paste(FSU_Serial_No, Sample_HH_No, sep = "_"))
```

### Step 4: Recompile and Check ALL Numbers

After fixes, recompile PDF and verify:
- Men's married participation < women's married participation ✓
- Men show small/zero marriage effect ✓
- Women show substantial marriage penalty ✓
- Standard errors slightly larger with clustering ✓
- Significance levels still meaningful ✓

### Step 5: Address Other Issues

Work through Priority 2 and 3 items above.

---

## PART 8: ASSESSMENT

**Grade:** Current manuscript: **D** (Reject - Fatal errors present)
**Grade:** After fixing fatal errors: **B-** (Major revision required)
**Grade:** After all corrections: **A-** (Minor revision, likely accept)

**Target Journal:** After revisions:
- Demography
- Journal of Development Economics
- World Development
- Journal of Marriage and Family

**Current state:** Not submittable due to fatal coding error.

**Estimated revision time:**
- 2-4 hours to fix fatal errors and recompile
- 8-12 hours for comprehensive revision addressing all issues
- 1-2 days for careful verification and sensitivity checks

---

## CONCLUSION

This paper addresses an important and under-researched question about how marriage affects gender inequality in unpaid work. The research design is sound and the heterogeneity analysis (by age, education, sector) is comprehensive. However, **a critical coding error** (wrong gender variable in key calculation) invalidates the current results.

**Action Required:** Fix the fatal error immediately, verify all results make sense, then address the major and moderate issues before considering submission.

The good news: This appears to be a simple copy-paste error, not a fundamental conceptual problem. Once fixed, the paper should produce credible and interesting results suitable for publication in a top field journal.

---

**Reviewer Recommendation:** REJECT current version. Encourage resubmission after major revision addressing fatal errors and other issues detailed above.
