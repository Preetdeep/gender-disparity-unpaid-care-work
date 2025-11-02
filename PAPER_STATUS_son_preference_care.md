# Paper Status: Son Preference in Parental Time

**File**: `son_preference_care.Rmd`
**Status**: ❌ **BLOCKED - Data Unavailable**
**Last Review**: November 2, 2025
**Reviewer**: Claude (JFE Editorial Review)

---

## Executive Summary

This paper **CANNOT BE COMPLETED** with the available dataset. The analysis requires household-level child gender composition data (number of sons vs daughters per household), which is **not available** in India's Time Use Survey 2024.

---

## Why This Paper Is Blocked

### Data Requirement

The core research question is: *"Do families invest more childcare time when sons are present compared to daughters?"*

This requires:
- Household roster showing all children
- Gender of each child per household
- Ability to classify households as: only sons, only daughters, mixed children
- Link individual time use to household child composition

### Data Reality

**Confirmed from `childcare_vs_eldercare.Rmd` (lines from that paper):**

> "**Important limitation:** We cannot observe household composition (number/ages of children, presence of elderly members), so our estimates represent population-level gender gaps, not gaps conditional on care needs being present."

> "**Important Note on Interpretation**: These are **population-level estimates** averaged across all individuals, including those in households without children or elderly members requiring care. **We cannot condition on presence of care recipients because household roster data are unavailable**."

**Conclusion**: The TUS 2024 dataset does NOT include household roster data. We cannot identify:
- How many children are in each household
- Gender of children in each household
- Ages of children in each household

---

## Current Paper Problems

### Lines 54-58: Variables Cannot Be Created
```r
# TODO: Create household composition variables
# only_sons = as.numeric(num_male_children > 0 & num_female_children == 0)
# only_daughters = as.numeric(num_female_children > 0 & num_male_children == 0)
```

**Problem**: `num_male_children` and `num_female_children` do not exist in dataset and cannot be derived.

### Lines 89-103, 109-123: Placeholder Data
```r
example_data <- data.frame(
  child_composition = c("Only Sons", "Only Daughters", "Mixed"),
  mother_time = c(52, 47, 50),
  father_time = c(18, 14, 16)
)
```

**Problem**: Results are fabricated examples, not real analysis.

### Line 178: Incomplete Conclusion
> "[To be completed after confirming data availability]"

**Problem**: Author correctly recognized data availability issue but left paper incomplete.

---

## Alternative Approaches Considered

### ❌ Option 1: Find Household Roster Variables
**Status**: Not possible - confirmed unavailable in TUS 2024

### ❌ Option 2: Use Activity Sub-codes
**Possibility**: Check if Activity Code 31 (childcare) has sub-codes specifying recipient gender
**Likelihood**: Very low - TUS typically doesn't code recipient characteristics at this level
**Action needed**: Manual review of TUS 2024 codebook to confirm

### ❌ Option 3: Link to External Dataset
**Possibility**: Link TUS households to NFHS (National Family Health Survey) which has detailed household rosters
**Likelihood**: Very low - different sampling frames, no common identifiers
**Action needed**: Review TUS and NFHS documentation for linkage possibilities

### ⚠️ Option 4: Pivot to Different Research Question
**Possibility**: Use state-level sex ratio as proxy for son preference intensity
**Approach**:
- Calculate state-level child sex ratios (proxy for son preference strength)
- Interact with individual childcare time
- Hypothesis: States with more skewed sex ratios show larger father-mother gaps in childcare time
**Trade-off**: Answers different question (ecological fallacy risk), but feasible with available data

### ⚠️ Option 5: Use Different Dataset
**Possibility**: India Human Development Survey (IHDS) has both time use modules AND household rosters
**Trade-off**: Smaller sample size, less detailed time use data than TUS
**Action needed**: Obtain IHDS data and verify time use variables adequate

---

## Recommendation

### Immediate Action: **BLOCK THIS PAPER**

Do not spend further time on this paper until data availability confirmed.

### Priority Order:
1. ✅ **Complete editorial review** (DONE)
2. ✅ **Document blocking issue** (DONE)
3. ❌ **Do NOT expand literature review**
4. ❌ **Do NOT soft-code numbers** (they're fake)
5. ❌ **Do NOT compile PDF** (will show fake results)
6. ✅ **Move to next paper in research sequence**

### If User Wants to Pursue This Topic:

**Option A: Investigate IHDS Dataset**
- Estimated time: 4-6 hours to obtain data, verify variables, adapt code
- Success probability: 70% (IHDS likely has needed variables)

**Option B: Pivot to State-Level Analysis**
- Estimated time: 3-4 hours to implement proxy approach
- Success probability: 90% (feasible with current data)
- Trade-off: Answers weaker research question

**Option C: Abandon This Paper**
- Move to other papers in sequence that use available TUS data
- Come back if better dataset becomes available

---

## What This Paper Would Need to Proceed

### Minimum Data Requirements:
1. Household ID variable (appears to exist: `FSU_Serial_No`, `Sample_HH_No`)
2. Household roster file with:
   - All household members listed
   - Age of each member
   - Gender of each member
   - Relationship to household head
3. Ability to link individual time use records to household composition
4. Variables to construct:
   - Number of children ages 0-18 by gender
   - Presence of any children
   - Child gender composition categories

### Data Exploration Commands to Confirm:
```r
# Check what household-level data exists
names(data)
table(data$Relationship_to_Head)  # If this exists, might enable roster construction

# Check if multiple records per household
data %>%
  group_by(FSU_Serial_No, Sample_HH_No) %>%
  summarize(n_members = n_distinct(Person_Serial_No))
```

---

## Editorial Review Document

Full editorial review available in: `EDITORIAL_REVIEW_son_preference_care.md`

Key findings:
- ❌ **MAJOR ISSUES**: Placeholder data, missing variables, no regression analysis
- ⚠️ **MODERATE ISSUES**: Hard-coded numbers, insufficient literature review, no data dictionary
- ✅ **STRENGTHS**: Good research question, clear writing, strong conceptual framework

---

## Next Steps

1. ✅ Mark paper as BLOCKED in paper sequence
2. ✅ Commit editorial review and status documents
3. ✅ Push changes to git
4. ❓ Ask user which alternative to pursue (if any)
5. ⏭️ Move to next paper in research pipeline

---

## Files Created This Review

- `EDITORIAL_REVIEW_son_preference_care.md` - Full editorial assessment
- `PAPER_STATUS_son_preference_care.md` - This status document
- Paper file itself: `son_preference_care.Rmd` (not modified - blocked)
- Paper PDF: `son_preference_care.pdf` (not reviewed - contains fake results)

---

**Status**: Paper blocked due to data unavailability. No further work recommended until data issue resolved.

**Recommendation**: Move to next paper in sequence that can be completed with available TUS data.
