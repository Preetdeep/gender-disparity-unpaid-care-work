# URGENT: Survey Year Clarification Needed

**Date:** October 31, 2025
**Issue:** Conflicting information about India Time Use Survey year

---

## THE PROBLEM

There is **conflicting information** about when India's Time Use Survey was conducted:

### Evidence for 2019:
1. **Childcare vs Eldercare RMD (Line 181)** - User's own update says:
   ```
   "conducted by the National Statistical Office between January and December 2019"
   ```

2. **Friendship Penalty RMD (Line 267)** - User's update says:
   ```
   "India's Time Use Survey 2019, conducted by the National Statistical Office
   between January and December 2019"
   ```

3. **All abstracts in updated papers** reference "2019"

### Evidence for 2024:
1. **User's recent comment:** "i think the time use survey was from jan 2024 to Dec 2024"

2. **Original PDFs** all said "2024" before updates

3. **Class Gradient RMD** (not yet updated) still says "2024"

---

## WHAT NEEDS TO BE CLARIFIED

**Question:** Was India's Time Use Survey conducted in 2019 or 2024?

**Why it matters:**
- If **2019 is correct**: Continue with current updates, fix Class paper to match
- If **2024 is correct**: REVERT all changes back to 2024, user's previous updates were wrong

---

## CURRENT STATUS OF PAPERS

### Childcare vs Eldercare:
- ✅ RMD says: **2019**
- ✅ Updated and pushed
- Action if 2024: **REVERT**

### Friendship Penalty:
- ✅ RMD says: **2019**
- ⚠️ PDF outdated (shows 2024)
- Action if 2024: **KEEP AS IS, regenerate PDF**

### Class Gradient:
- ⚠️ RMD partially updated: Abstract now says **2019**, but rest says **2024**
- ❌ Inconsistent state
- Action needed: **DECIDE AND COMPLETE UPDATE**

---

## RECOMMENDED NEXT STEPS

### Option A: If Survey was in 2019
1. Complete Class Gradient updates (change all 2024 → 2019)
2. Regenerate PDFs for all three papers
3. Verify everything is consistent
4. Submit papers

### Option B: If Survey was in 2024
1. **REVERT Childcare vs Eldercare RMD** (2019 → 2024)
2. **REVERT Friendship Penalty RMD** (2019 → 2024)
3. **REVERT Class Gradient abstract** (2019 → 2024)
4. Original PDFs are correct as-is
5. Submit papers

---

## HOW TO VERIFY THE CORRECT YEAR

**Check the actual data file:** Look at `TimeUse106PER.dta` metadata or documentation

**Check official sources:**
- National Statistical Office of India website
- Official survey documentation
- Published reports using this survey

**Ask the data provider:** If you obtained this data from someone, ask them

---

## URGENT ACTION REQUIRED

**Before proceeding with any more changes:**
1. ✅ Verify the correct survey year
2. ✅ Inform Claude whether 2019 or 2024 is correct
3. ✅ Claude will then complete the appropriate updates

**Do NOT submit papers until this is resolved** - having the wrong survey year is a fatal error.

---

## CURRENT COMMIT STATUS

**Changes made today:**
- Created EDITORIAL_REVIEW_CLASS_GRADIENT.md
- Partially updated class_gradient_equality.Rmd abstract (2024 → 2019)
- Created UPDATED_FRIENDSHIP_ASSESSMENT.md

**These changes will be committed with note:**
"WIP: Survey year clarification needed - partial updates pending verification"

---

END OF CLARIFICATION REQUEST
