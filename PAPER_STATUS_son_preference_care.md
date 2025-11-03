# Paper Status: Son Preference in Parental Time - UPDATED

**File**: `son_preference_care.Rmd`
**Status**: ⚠️ **INVESTIGATION REQUIRED - May Be Unblockable**
**Last Review**: November 2, 2025 (Updated after data dictionary investigation)
**Reviewer**: Claude (JFE Editorial Review)

---

## MAJOR UPDATE: Potential Path Forward Discovered

### New Findings from Data Dictionary Investigation

The TUS 2024 `Variables` file documents a **`Relationship_to_Head`** variable that includes:
- Code 5 = **unmarried child**
- Code 6 = **grandchild**
- Combined with **Gender** (1=Male, 2=Female) and **Age** variables

**Implication**: If these variables exist in the person-level file (TimeUse106PER.dta), we CAN construct household child composition!

---

## Two Scenarios

### ✅ **SCENARIO A: Variables in TimeUse106PER.dta** (PAPER IS UNBLOCKABLE!)

**If** `Relationship_to_Head`, `Gender`, and `Age` exist in the person-level time use file, we can:

**Step 1: Construct Household Composition**
```r
# Group by household and count children by gender
household_composition <- data %>%
  filter(Relationship_to_Head %in% c(5, 6),  # unmarried child or grandchild
         Age < 18) %>%  # children under 18
  group_by(FSU_Serial_No, Sample_HH_No) %>%
  summarize(
    num_sons = sum(Gender == 1),
    num_daughters = sum(Gender == 2),
    total_children = n()
  ) %>%
  mutate(
    only_sons = as.numeric(num_sons > 0 & num_daughters == 0),
    only_daughters = as.numeric(num_daughters > 0 & num_sons == 0),
    mixed_children = as.numeric(num_sons > 0 & num_daughters > 0),
    any_sons = as.numeric(num_sons > 0),
    any_daughters = as.numeric(num_daughters > 0)
  )

# Merge back to time use data
data_with_composition <- data %>%
  left_join(household_composition, by = c("FSU_Serial_No", "Sample_HH_No"))
```

**Step 2: Conduct Son Preference Analysis**
```r
# Compare childcare time by household composition
results <- data_with_composition %>%
  filter(Activity_Code_2Digit == 31,  # childcare
         !is.na(only_sons)) %>%  # households with children
  group_by(Gender, only_sons, only_daughters, mixed_children) %>%
  summarize(
    participation_rate = weighted.mean(childcare == 1, Weight),
    mean_time = weighted.mean(childcare_minutes, Weight)
  )
```

**Action Required:**
1. Load full dataset: `data <- read_dta("TimeUse106PER.dta")` (no col_select)
2. Check if column exists: `"Relationship_to_Head" %in% names(data)`
3. If YES → **Paper is UNBLOCKABLE!** Proceed with analysis
4. If NO → See Scenario B

---

### ❌ **SCENARIO B: Variables in Separate Household Roster File**

The TUS documentation mentions "Block 3: Household Member Listing" which suggests household roster data may be in a **separate file**.

**Possible filenames:**
- `TimeUse106HH.dta` (household-level file)
- `TimeUse106ROSTER.dta` (household member roster)
- `TUS_Block3.dta` (block-specific file)

**Action Required:**
1. Check what other .dta files exist in the data folder
2. Load any household/roster files
3. If household composition data exists, merge to TimeUse106PER.dta by household ID
4. If YES → **Paper is UNBLOCKABLE!** Proceed with analysis
5. If NO → Paper remains blocked (see original assessment below)

---

## Why This Variable Wasn't Detected Earlier

**Evidence suggesting variables NOT in PER file:**
- **None of 10+ existing papers use `Relationship_to_Head`**
- `childcare_vs_eldercare.Rmd` explicitly states: "household roster data are unavailable"
- `gender_disparity_clean.Rmd` loads ALL variables but still can't condition on children
- If easily available, authors would have used it

**Counter-evidence suggesting variables MIGHT be in PER file:**
- Variables file documents them as part of TUS 2024
- Listed alongside other person-level variables (Gender, Age, Marital_Status)
- User suggested investigation possible

**Conclusion**: Most likely in separate roster file, but **worth checking PER file first**.

---

## Original Assessment (If Investigation Fails)

### Data Requirement

The core research question is: *"Do families invest more childcare time when sons are present compared to daughters?"*

This requires:
- Household roster showing all children
- Gender of each child per household
- Ability to classify households as: only sons, only daughters, mixed children
- Link individual time use to household child composition

### Evidence of Data Unavailability

**From `childcare_vs_eldercare.Rmd`:**
> "We cannot observe household composition (number/ages of children, presence of elderly members), so our estimates represent population-level gender gaps, not gaps conditional on care needs being present."

> "We cannot condition on presence of care recipients because household roster data are unavailable."

### Current Paper Problems

**Lines 54-58**: Variables cannot be created without household roster
```r
# TODO: Create household composition variables
# only_sons = ... # Cannot create without data
# only_daughters = ... # Cannot create without data
```

**Lines 89-103, 109-123**: Uses placeholder/fabricated data
```r
example_data <- data.frame(
  child_composition = c("Only Sons", "Only Daughters", "Mixed"),
  mother_time = c(52, 47, 50),  # FAKE NUMBERS
  father_time = c(18, 14, 16)   # FAKE NUMBERS
)
```

**Line 178**: Conclusion incomplete
> "[To be completed after confirming data availability]"

---

## Immediate Action Plan

### Priority 1: Check TimeUse106PER.dta (5 minutes)
```r
# Load full dataset
data <- read_dta("TimeUse106PER.dta")

# Check for relationship variable
if ("Relationship_to_Head" %in% names(data)) {
  cat("✅ UNBLOCKED! Relationship_to_Head exists in PER file\n")
  cat("Proceed with household composition analysis\n")
} else {
  cat("❌ Variable not in PER file\n")
  cat("Proceed to Priority 2\n")
}

# List all column names for investigation
cat("\nAvailable columns:\n")
print(names(data))
```

### Priority 2: Check for Household Roster Files (5 minutes)
```bash
# List all .dta files in data directory
ls -la *.dta

# Look for household or roster files
ls -la *HH*.dta *ROSTER*.dta *Block3*.dta 2>/dev/null
```

### Priority 3: Decision Point (After Investigation)

**If household composition variables found:**
1. Update son_preference_care.Rmd with real data loading code
2. Remove placeholder data (lines 89-123)
3. Implement household composition construction
4. Conduct real analysis
5. Soft-code all results
6. Complete conclusion
7. Expand literature review (3 → 15-20 citations)
8. Add data dictionary
9. Run regressions with proper specifications

**Estimated time to completion**: 6-8 hours

**If household composition variables NOT found:**
1. Mark paper as permanently BLOCKED
2. Consider alternative research questions feasible with available data
3. Or pursue Option 4/5 from alternatives below

---

## Alternative Approaches (If Still Blocked)

### Option 1: State-Level Sex Ratio Proxy ⚠️
- Use state-level child sex ratios as proxy for son preference intensity
- Interact with childcare time at individual level
- **Trade-off**: Weaker research question, ecological fallacy risk
- **Feasibility**: HIGH (can do with current data)

### Option 2: India Human Development Survey (IHDS) ⚠️
- IHDS has household rosters AND time use modules
- **Trade-off**: Smaller sample, less detailed time use than TUS
- **Feasibility**: MEDIUM (requires new data access)

### Option 3: Link to NFHS ❌
- National Family Health Survey has detailed child data
- **Trade-off**: Different sampling frames, no common identifiers
- **Feasibility**: LOW (likely impossible to link)

### Option 4: Activity Sub-Codes ❓
- Check if Activity Code 31 (childcare) has recipient-specific sub-codes
- E.g., separate codes for "childcare for son" vs "daughter"
- **Feasibility**: LOW (unlikely TUS codes recipient characteristics)

---

## Documents Created

- `EDITORIAL_REVIEW_son_preference_care.md` - Comprehensive JFE review
- `PAPER_STATUS_son_preference_care.md` - This status document (updated)
- Paper file: `son_preference_care.Rmd` (currently has placeholder data)

---

## Summary

**Current Status**: Investigation Required
**Next Step**: Check if `Relationship_to_Head` exists in TimeUse106PER.dta
**If YES**: Paper is UNBLOCKABLE → Proceed with analysis (6-8 hours)
**If NO**: Check for household roster file
**If neither**: Paper remains BLOCKED → Consider alternatives or move to next paper

---

**Updated**: November 2, 2025 after data dictionary investigation
**Original Review**: November 2, 2025
