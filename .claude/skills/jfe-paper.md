# JFE Academic Paper Writing & Review Skill

## Purpose
This skill provides a comprehensive workflow for writing, reviewing, and publishing academic papers in Journal of Financial Economics (JFE) format. Use this skill when working on academic papers to ensure completeness, quality, and consistency.

## Activation
Invoke this skill when:
- Starting a new academic paper
- Reviewing an existing paper for submission
- Ensuring JFE formatting compliance
- Conducting editorial reviews
- Managing multi-paper projects

---

## Core Principles

### 1. ONE PAPER AT A TIME
- Complete each paper fully before moving to the next
- Push all changes to git before switching papers
- Create a status document tracking paper sequence
- Never leave a paper partially completed

### 2. ALWAYS CLEAR CACHE FOR PDFS
**CRITICAL**: Before reviewing any PDF or compiled document:
```r
# In R Markdown chunks, set:
cache = FALSE
```
- Never trust cached results
- Always verify you're looking at the UPDATED document
- Recompile PDFs before each review session
- Check modification timestamps to confirm updates

### 3. GIT WORKFLOW
After every significant change:
```bash
git add .
git commit -m "Clear, descriptive message about changes"
git push -u origin <branch-name>
```
- Commit after each section completion
- Push before ending sessions
- Use descriptive commit messages following existing patterns
- Branch naming: `claude/<descriptive-name>-<session-id>`

---

## JFE Format Requirements

### Document Structure
1. **Title**: Results-focused, quantitative findings in title when possible
   - Example: "Marriage Reduces Women's Social Time by 52%, Men's by 23%"
   - Not: "The Impact of Marriage on Social Activities"

2. **Abstract**: 150-200 words
   - Main finding in first sentence
   - Method in second sentence
   - Key results (2-3 sentences)
   - Implication in final sentence
   - Include JEL codes and keywords

3. **Introduction** (3-4 pages)
   - Hook with compelling statistic
   - Research question clearly stated
   - Literature review integrated (not separate section)
   - Contribution explicitly stated
   - Roadmap of paper at end

4. **Data and Methods** (2-3 pages)
   - Data source with full citation
   - Sample description with summary statistics
   - Variable definitions (link to data dictionary)
   - Estimation strategy
   - Identification assumptions

5. **Results** (4-6 pages)
   - Main findings first
   - Tables and figures referenced in text
   - Detailed interpretation (not just "Table 1 shows...")
   - Heterogeneity analysis
   - Robustness checks

6. **Discussion and Conclusion** (2-3 pages)
   - Mechanisms explaining findings
   - Policy implications
   - Limitations
   - Future research directions

7. **References**: Use standard economics format
   - Author (Year). "Title." *Journal* Volume(Issue): Pages.
   - Alphabetical order
   - DOIs when available

### Formatting Specifications
- Font: 11pt or 12pt, Times New Roman or similar
- Margins: 1 inch all sides
- Line spacing: Double-spaced
- Tables: Professional formatting, clear labels, notes at bottom
- Figures: High-resolution, clear labels, legends when needed
- Equations: Numbered if referenced
- Footnotes: Minimal, substantive only

---

## Completeness Checklist

### Before Declaring Paper "Complete"
- [ ] Title includes quantitative finding or clear hook
- [ ] Abstract follows 5-sentence structure
- [ ] Introduction has clear research question and contribution
- [ ] Literature review cites at least 15-20 relevant papers
- [ ] Data section includes summary statistics table
- [ ] All variables defined in text or data dictionary
- [ ] Main results table included with proper formatting
- [ ] At least 2-3 high-quality figures
- [ ] Heterogeneity analysis by key subgroups
- [ ] Robustness checks conducted
- [ ] Discussion addresses mechanisms
- [ ] Policy implications clearly stated
- [ ] References properly formatted
- [ ] All numbers soft-coded (no hard-coded values in text)
- [ ] All code chunks have `cache=FALSE`
- [ ] Paper compiles without errors
- [ ] PDF reviewed for formatting issues
- [ ] Git commit with descriptive message
- [ ] Changes pushed to remote

---

## Soft-Coding Requirements

### NO HARD-CODED NUMBERS IN TEXT
**Wrong**:
```markdown
Women spend 58 minutes per day on childcare.
```

**Correct**:
```markdown
Women spend `r sprintf("%.0f", results$mean_female_childcare)` minutes per day on childcare.
```

### Store All Results for Inline Reference
```r
# Calculate results
results <- list(
  mean_female = weighted.mean(data$time[data$Gender == 2], data$Weight),
  mean_male = weighted.mean(data$time[data$Gender == 1], data$Weight),
  ratio = weighted.mean(data$time[data$Gender == 2], data$Weight) /
          weighted.mean(data$time[data$Gender == 1], data$Weight)
)

# Store percentage changes
results$pct_change <- (results$mean_female - results$mean_male) / results$mean_male * 100
```

### Use sprintf() for Formatting
```r
# Inline references
`r sprintf("%.1f", results$mean_female)` minutes
`r sprintf("%.0f%%", results$pct_change)`
`r sprintf("%.2f", results$ratio)` times more
```

### Verification Process
1. Search document for standalone numbers: `grep -E "[0-9]+\.[0-9]+" document.Rmd`
2. Verify each number has corresponding calculation
3. Test by changing underlying data slightly - all numbers should update
4. Review compiled PDF to confirm all inline code executed

---

## Literature Review Standards

### Minimum Requirements
- 15-20 citations for main paper
- 5-10 foundational papers (classic studies)
- 5-10 recent papers (last 5 years)
- 3-5 papers on methodology
- Coverage of competing explanations

### Key Topics to Cover
1. **Theoretical foundations**
   - Bargaining models (Becker, Manser & Brown, McElroy)
   - Identity models (Akerlof & Kranton)
   - Time allocation models (Gronau, Becker)

2. **Gender and unpaid work**
   - Classic studies (Folbre, Hochschild)
   - Developing country context (Duflo, Jayachandran)
   - India-specific research (Hirway, Chakraborty)

3. **Relevant mechanisms**
   - Social norms (Bursztyn, Bertrand)
   - Human capital (Goldin, Blau & Kahn)
   - Household bargaining (Lundberg & Pollak)

4. **Policy implications**
   - Care infrastructure (Devercelli & Beaton-Day)
   - Labor market flexibility (Goldin)
   - Paternity leave (Patnaik)

### Integration Style
- Weave citations into narrative flow
- Don't create separate "Literature Review" section
- Each paragraph should advance your argument
- Compare/contrast with your findings
- Explain how your paper contributes

### Citation Management
```r
# In YAML header:
bibliography: references.bib
csl: econometrica.csl  # or journal-of-political-economy.csl
```

---

## Data Dictionary Requirements

### Essential Components
1. **Variable name**: Exact name in dataset
2. **Label**: Human-readable description
3. **Type**: Numeric, categorical, binary
4. **Coding**: Value labels (e.g., 1=Male, 2=Female)
5. **Source**: Original dataset or derived
6. **Notes**: Special considerations

### Example Format
```markdown
| Variable | Label | Type | Coding | Source | Notes |
|----------|-------|------|--------|--------|-------|
| Gender | Respondent gender | Categorical | 1=Male, 2=Female, 3=Transgender | TUS_PER | Use only 1 & 2 |
| time_spent | Minutes on activity | Numeric | 0-1440 | TUS_PER | Sum of all episodes |
| Weight | Survey weight | Numeric | Continuous | TUS_PER | Pre-calculated |
| Major_Activity_Flag | Major activity indicator | Binary | 0/1 | TUS_PER | Filter to 1 only |
```

### Creation Process
1. Document all variables used in analysis
2. Include derived variables with formulas
3. Link to data dictionary in paper's Data section
4. Update dictionary when adding new variables
5. Store as separate file: `data_dictionary_[paper_name].md`

---

## Variable Naming Conventions

### R Code Standards
- **Use snake_case**: `mean_female_time` not `meanFemaleTime`
- **Be descriptive**: `participation_rate` not `pr`
- **Avoid abbreviations**: `married_women` not `mar_wm`
- **Prefix logicals with `is_` or `has_`**: `is_married`, `has_children`

### Consistency Rules
```r
# Good
data_full <- read_dta("TUS106PER.dta")
data_sample <- data_full %>% sample_frac(0.1)
data_care <- data_sample %>% filter(Activity_Code == 31)

mean_female_childcare <- weighted.mean(data_care$time[data_care$Gender == 2],
                                        data_care$Weight)

# Bad
df <- read_dta("TUS106PER.dta")
d2 <- df %>% sample_frac(0.1)
temp <- d2 %>% filter(Activity_Code == 31)
mfc <- weighted.mean(temp$time[temp$Gender == 2], temp$Weight)
```

### Table and Figure Naming
```r
# Tables
table_summary_stats <- ...
table_main_regression <- ...
table_heterogeneity <- ...
table_robustness <- ...

# Figures
fig_main_comparison <- ...
fig_heterogeneity_age <- ...
fig_mechanism_education <- ...
```

---

## Editorial Review Checklist

### Act as Editor: Review as if Evaluating for Publication

#### MAJOR ISSUES (Reject if present)
- [ ] Research question unclear or unimportant
- [ ] Methodology flawed or inappropriate
- [ ] Data quality concerns or selection bias
- [ ] Results don't support conclusions
- [ ] Contribution not clearly articulated
- [ ] Writing quality poor throughout

#### MODERATE ISSUES (Revise & Resubmit if present)
- [ ] Literature review incomplete
- [ ] Missing key control variables
- [ ] Insufficient robustness checks
- [ ] Heterogeneity analysis limited
- [ ] Mechanisms unexplored
- [ ] Tables/figures poorly formatted
- [ ] Discussion lacks depth

#### MINOR ISSUES (Accept with minor revisions if present)
- [ ] Typos or grammatical errors
- [ ] Inconsistent terminology
- [ ] Reference formatting errors
- [ ] Figure labels unclear
- [ ] Table notes incomplete
- [ ] Abstract needs tightening

### Review Process
1. **First read**: Assess contribution and clarity
2. **Second read**: Check methodology and results
3. **Third read**: Verify all numbers, citations, formatting
4. **Final check**: Read as naive reader - does it convince?

### Editorial Comments Format
Create `EDITORIAL_REVIEW_[paper_name].md` with:
```markdown
# Editorial Review: [Paper Title]

## Overall Assessment
[Accept / Minor Revisions / Major Revisions / Reject]

## Summary
[2-3 sentences on main contribution and quality]

## Major Comments
1. [Issue description and required fix]
2. [Issue description and required fix]

## Minor Comments
1. [Issue description]
2. [Issue description]

## Specific Line-by-Line Comments
- Line X: [Issue]
- Table 2: [Issue]
- Figure 3: [Issue]

## Recommendation
[Final verdict with timeline for revisions]
```

---

## Session Handoff Protocol

### When Session Limit Approaching
Create `SESSION_HANDOFF_[date].md` with:

```markdown
# Session Handoff: [Current Date]

## Session Info
- Session ID: [Current session ID]
- Branch: [Current branch name]
- Token usage: [Estimated remaining]
- Papers completed this session: [Count]

## Current Status
- Paper in progress: [Name]
- Section being worked on: [Section name]
- Last commit: [Commit hash and message]
- Outstanding tasks: [List]

## Next Steps
1. [Immediate next task]
2. [Following task]
3. [Final tasks before paper completion]

## Files Modified This Session
- [File 1]: [What changed]
- [File 2]: [What changed]

## Important Context
- [Any decisions made]
- [Any issues discovered]
- [Any non-standard approaches taken]

## Git Status
```bash
git status
git log --oneline -5
```

## Resume Command
To continue this work in new session:
1. Fetch latest: `git fetch origin [branch]`
2. Checkout branch: `git checkout [branch]`
3. Review handoff: `cat SESSION_HANDOFF_[date].md`
4. Continue from: [Specific file and location]
```

### Commit Handoff Document
```bash
git add SESSION_HANDOFF_[date].md
git commit -m "Session handoff: [paper name] in progress"
git push -u origin [branch]
```

---

## Paper Sequence Management

### Multi-Paper Projects
Create `PAPER_SEQUENCE_STATUS.md`:

```markdown
# Research Paper Sequence - Status Update

## Priority Sequence
| Priority | Research Question | Status | File Name |
|----------|------------------|--------|-----------|
| 1 | [Question] | ✅ Completed | file1.Rmd |
| 2 | [Question] | ⏳ In Progress | file2.Rmd |
| 3 | [Question] | ❌ Blocked | file3.Rmd |
| 4 | [Question] | 📋 Pending | file4.Rmd |

## Completed Papers
### Paper 1: [Title]
- Status: ✅
- Key finding: [Summary]
- PDF: [Path]
- Last updated: [Date]

## Current Paper
### Paper 2: [Title]
- Status: ⏳
- Progress: [Section completed]
- Blockers: [If any]
- Next steps: [List]

## Blocked Papers
### Paper 3: [Title]
- Blocker: [Reason]
- Resolution: [What's needed]

## Pending Papers
[List remaining papers]
```

### Update After Each Paper
```bash
git add PAPER_SEQUENCE_STATUS.md
git commit -m "Updated paper sequence: [paper name] completed"
git push
```

---

## Quality Assurance Workflow

### Pre-Submission Checklist
Run through this checklist before declaring paper ready:

1. **Compile Test**
   ```r
   rmarkdown::render("paper.Rmd")
   ```
   - No errors or warnings
   - All inline code executes
   - All figures render
   - All tables format correctly

2. **Cache Verification**
   ```r
   # In each chunk header, verify:
   cache = FALSE
   ```
   - Delete any .RData files
   - Delete any _cache directories
   - Recompile from scratch

3. **Number Verification**
   ```bash
   # Search for hard-coded numbers
   grep -E "[0-9]+\.[0-9]+" paper.Rmd | grep -v "r sprintf"
   ```
   - Verify each match is intentional (e.g., page numbers, dates)
   - Replace any hard-coded results with inline code

4. **Citation Check**
   - All claims supported by citations
   - All citations in references.bib
   - Reference list alphabetically ordered
   - DOIs included when available

5. **Figure Quality**
   - High resolution (dpi = 300)
   - Clear labels and legends
   - Color-blind friendly palette
   - Proper aspect ratio

6. **Table Formatting**
   - Professional appearance
   - Clear column headers
   - Notes at bottom explaining all symbols
   - Significance stars defined
   - Source cited

7. **Git Status**
   ```bash
   git status  # Should show clean working directory
   git log -1  # Verify last commit message is descriptive
   git push    # Ensure remote is up-to-date
   ```

---

## Common Pitfalls to Avoid

### 1. Caching Errors
**Problem**: Results in PDF don't match current code
**Solution**: Always set `cache=FALSE` in all chunks

### 2. Hard-Coded Numbers
**Problem**: Numbers in text don't update when data changes
**Solution**: Store all results in list objects, reference with inline code

### 3. Incomplete Literature Review
**Problem**: Missing key citations in field
**Solution**: Search Google Scholar for "[topic] review" and "[topic] survey"

### 4. Poor Figure Quality
**Problem**: Pixelated or unclear visualizations
**Solution**: Set `dpi=300`, use `ggplot2` with themes, export as PDF when possible

### 5. Weak Contribution Statement
**Problem**: Unclear what paper adds to literature
**Solution**: Explicitly state "This paper contributes by..." in introduction

### 6. Missing Robustness Checks
**Problem**: Results not tested for sensitivity
**Solution**: Add subsample analysis, alternative specifications, placebo tests

### 7. Forgetting to Push to Git
**Problem**: Work lost when session ends
**Solution**: Push after every major change, especially before long analyses

### 8. Skipping Data Dictionary
**Problem**: Variable definitions unclear for reviewers
**Solution**: Create dictionary at start, update throughout

---

## Example Workflow for New Paper

### Step 1: Setup (10 minutes)
```bash
# Ensure on correct branch
git checkout [branch-name]
git pull origin [branch-name]

# Create paper file
touch new_paper.Rmd

# Create data dictionary
touch data_dictionary_new_paper.md

# Update sequence status
# Edit PAPER_SEQUENCE_STATUS.md
```

### Step 2: Scaffold Paper (15 minutes)
```yaml
---
title: "[Working title with key finding]"
author: "Dr Preet Deep Singh, Blue Machines"
date: "`r Sys.Date()`"
output:
  pdf_document:
    number_sections: true
bibliography: references.bib
---
```

Create section headers:
- Abstract
- Introduction
- Data and Methods
- Results
- Discussion
- References

### Step 3: Data Analysis (2-4 hours)
```r
# Load and prepare data
# Calculate main results
# Create tables and figures
# Store all results in list objects
```

### Step 4: Write Draft (2-3 hours)
- Write introduction with literature review
- Write methods section
- Write results with inline code references
- Write discussion and conclusion

### Step 5: Editorial Review (1 hour)
- Read through as editor
- Create EDITORIAL_REVIEW_[paper_name].md
- Fix all major and moderate issues

### Step 6: Quality Assurance (30 minutes)
- Run pre-submission checklist
- Verify all numbers soft-coded
- Clear cache and recompile
- Review PDF for formatting

### Step 7: Finalize (15 minutes)
```bash
git add .
git commit -m "Complete [paper title]: [brief description of findings]"
git push -u origin [branch-name]

# Update PAPER_SEQUENCE_STATUS.md
# Create handoff document if needed
```

---

## Key Resources

### Style Guides
- JFE: https://www.elsevier.com/journals/journal-of-financial-economics/0304-405X/guide-for-authors
- AER: https://www.aeaweb.org/journals/policies/submission-guidelines
- Chicago Manual of Style (Economics): https://www.chicagomanualofstyle.org/

### R Packages Essential for JFE Papers
```r
library(haven)         # Read Stata files
library(dplyr)         # Data manipulation
library(ggplot2)       # Visualization
library(fixest)        # Fast fixed effects regression
library(modelsummary)  # Professional tables
library(kableExtra)    # Table formatting
library(scales)        # Number formatting
library(tidyr)         # Data reshaping
library(broom)         # Tidy regression output
```

### Citation Tools
- Google Scholar: Quick citation export
- EconPapers: Economics-specific search
- NBER Working Papers: Pre-publication research
- SSRN: Social science pre-prints

---

## Success Criteria

A paper is considered "complete" when:
1. ✅ Compiles without errors
2. ✅ PDF reviewed and formatting verified
3. ✅ All numbers soft-coded
4. ✅ Literature review comprehensive (15-20+ citations)
5. ✅ Data dictionary created and linked
6. ✅ Variable names follow conventions
7. ✅ Editorial review passed with minor issues only
8. ✅ All changes committed and pushed to git
9. ✅ PAPER_SEQUENCE_STATUS.md updated
10. ✅ Ready for human review and potential submission

---

## Quick Reference Commands

### Compile Paper
```r
rmarkdown::render("paper.Rmd")
```

### Clear Cache
```bash
rm -rf *_cache/
rm -f *.RData
```

### Check for Hard-Coded Numbers
```bash
grep -E "\b[0-9]+\.[0-9]+\b" paper.Rmd | grep -v "r sprintf"
```

### Git Workflow
```bash
git add .
git commit -m "Descriptive message"
git push -u origin [branch-name]
```

### View PDF Modification Time
```bash
ls -lh paper.pdf
```

### Count Citations
```bash
grep -o "@[A-Za-z0-9_]*" paper.Rmd | wc -l
```

---

## Final Notes

This skill is designed to be comprehensive and systematic. Follow it rigorously to produce publication-ready papers. When in doubt:

1. **Consult existing completed papers** in the repository for examples
2. **Review editorial feedback** documents to avoid past mistakes
3. **Push to git frequently** to preserve progress
4. **Always verify PDF updates** by clearing cache before review
5. **One paper at a time** - complete before moving to next

The goal is not just to write papers, but to write **publishable** papers that meet top-tier journal standards.
