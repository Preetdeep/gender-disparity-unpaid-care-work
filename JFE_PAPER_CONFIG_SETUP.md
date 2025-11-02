# JFE Paper Configuration & Skill System - Setup Complete

**Date**: 2025-11-02
**Session**: claude/jfe-paper-config-skill-011CUif6CjNKq3fZUFYcLTM8
**Purpose**: Comprehensive configuration for writing JFE-format academic papers

---

## What Was Created

A complete skill and configuration system for academic paper writing in Journal of Financial Economics (JFE) format, with quality controls, templates, and workflows.

---

## 📁 File Structure

```
.claude/
├── skills/
│   ├── jfe-paper.md          # Main skill file (comprehensive workflow)
│   └── README.md              # Skill documentation
├── commands/
│   └── paper.md               # Slash command: /paper
└── templates/
    ├── session-handoff-template.md      # For session transitions
    └── editorial-review-template.md     # For paper reviews
```

---

## 🎯 Core Components

### 1. JFE Paper Skill (`.claude/skills/jfe-paper.md`)

**Purpose**: Comprehensive workflow guide for writing publication-ready papers

**Contains**:
- ✅ JFE format requirements (title, abstract, sections, references)
- ✅ Completeness checklist (20+ quality gates)
- ✅ Soft-coding requirements (no hard-coded numbers)
- ✅ Literature review standards (15-20+ citations)
- ✅ Data dictionary requirements
- ✅ Variable naming conventions (snake_case, descriptive names)
- ✅ Editorial review checklist (major/moderate/minor issues)
- ✅ Git workflow integration (commit after each major change)
- ✅ PDF cache clearing protocols (CRITICAL: cache=FALSE)
- ✅ Session handoff procedures
- ✅ Example workflow for new papers (7 steps)
- ✅ Common pitfalls to avoid (8 key issues)
- ✅ Quick reference commands

**Key Principles**:
1. **ONE PAPER AT A TIME** - Complete fully before moving to next
2. **ALWAYS CLEAR CACHE** - Set `cache=FALSE` in all R chunks
3. **GIT WORKFLOW** - Commit and push after each major change

---

### 2. Paper Command (`.claude/commands/paper.md`)

**Usage**: Type `/paper` in chat to activate JFE workflow

**What it does**:
- Loads JFE paper writing mode
- Prompts for paper details (name, status, task)
- Applies quality gates
- Executes appropriate workflow
- Commits and pushes changes when complete

**Example**:
```
User: /paper
Claude: Which paper are we working on?
User: friendship_penalty.Rmd - need editorial review
Claude: [Loads file, clears cache, runs editorial checklist, creates review]
```

---

### 3. Session Handoff Template (`.claude/templates/session-handoff-template.md`)

**Purpose**: Transfer work between sessions when token limit approached

**When to use**:
- Token usage > 80% of limit
- Long analysis session ending
- Need to switch contexts
- Before critical breaks in work

**What it captures**:
- Session info (ID, branch, token usage)
- Current status (paper, section, completion %)
- Outstanding tasks (prioritized)
- Files modified (new, changed, deleted)
- Important context (decisions, issues, approaches)
- Git status (commits, uncommitted changes)
- Resume instructions (exact steps to continue)

**How to use**:
1. Copy template to `SESSION_HANDOFF_[YYYY-MM-DD].md`
2. Fill in all sections
3. Commit and push to git
4. New session reads handoff and continues seamlessly

---

### 4. Editorial Review Template (`.claude/templates/editorial-review-template.md`)

**Purpose**: Systematic review of papers as if evaluating for journal submission

**When to use**:
- Paper draft complete
- Before declaring paper "ready"
- After major revisions
- Quality assurance check

**What it evaluates**:
- **Contribution**: Research question, novelty, relevance
- **Methodology**: Approach, identification, data quality
- **Results**: Clarity, tables, figures, robustness
- **Writing Quality**: Abstract, intro, literature, discussion

**Outputs**:
- Overall recommendation (Accept/Minor/Major/Reject)
- Major comments (must fix)
- Moderate comments (should fix)
- Minor comments (polish)
- Specific line-by-line feedback
- Action plan with priorities
- Timeline estimate

**How to use**:
1. Copy template to `EDITORIAL_REVIEW_[paper_name].md`
2. Compile paper with `cache=FALSE`
3. Review PDF systematically
4. Fill in template sections
5. Address issues in priority order
6. Commit review and fixes to git

---

## 🚀 Quick Start Guide

### For New Papers

```bash
# 1. Activate paper mode
/paper

# 2. Specify task
"New paper on [research question]"

# 3. Claude will:
#    - Create .Rmd file with JFE template
#    - Create data dictionary
#    - Update PAPER_SEQUENCE_STATUS.md
#    - Guide you through 7-step workflow
```

### For Reviewing Existing Papers

```bash
# 1. Activate paper mode
/paper

# 2. Specify task
"Review friendship_penalty.Rmd for submission"

# 3. Claude will:
#    - Clear cache and recompile
#    - Run editorial review checklist
#    - Create EDITORIAL_REVIEW_friendship_penalty.md
#    - Provide prioritized fix list
```

### For Session Handoffs

```bash
# When approaching token limit:
# 1. Create handoff document
cp .claude/templates/session-handoff-template.md SESSION_HANDOFF_2025-11-02.md

# 2. Fill in details (Claude can help)
# 3. Commit and push
git add SESSION_HANDOFF_2025-11-02.md
git commit -m "Session handoff: [paper name] in progress"
git push

# 4. In new session:
cat SESSION_HANDOFF_2025-11-02.md  # Read and continue
```

---

## 📋 Quality Gates (Must Pass Before Paper "Complete")

From `.claude/skills/jfe-paper.md`, every paper must pass:

1. ✅ Compiles without errors (`rmarkdown::render("paper.Rmd")`)
2. ✅ PDF reviewed and formatting verified (cache cleared first!)
3. ✅ All numbers soft-coded (no hard-coded values in text)
4. ✅ Literature review comprehensive (15-20+ citations)
5. ✅ Data dictionary created and linked
6. ✅ Variable names follow conventions (snake_case, descriptive)
7. ✅ Editorial review passed with minor issues only
8. ✅ All changes committed and pushed to git
9. ✅ PAPER_SEQUENCE_STATUS.md updated
10. ✅ Ready for human review and potential submission

---

## 🔧 Key Technical Requirements

### R Markdown Chunks Must Have:
```r
{r chunk-name, cache=FALSE, echo=FALSE, message=FALSE, warning=FALSE}
```

**Critical**: `cache=FALSE` prevents stale results

### All Numbers Must Be Soft-Coded:
```r
# Store results
results <- list(
  mean_female = weighted.mean(...),
  mean_male = weighted.mean(...),
  ratio = mean_female / mean_male
)

# Reference inline
Women spend `r sprintf("%.0f", results$mean_female)` minutes per day.
This is `r sprintf("%.1f", results$ratio)` times more than men.
```

**Never**: "Women spend 58 minutes per day" (hard-coded)

### Git Workflow:
```bash
# After each major change:
git add .
git commit -m "Descriptive message following existing patterns"
git push -u origin [branch-name]

# Branch must start with 'claude/' and end with session ID
```

---

## 📚 Integration with Existing Documents

This skill system complements:

### Existing Documentation
- `prompt_template_for_future_threads.md` - Initial conversation setup
- `PAPER_SEQUENCE_STATUS.md` - Multi-paper project tracking
- `EDITORIAL_REVIEW_*.md` - Paper-specific reviews

### How They Work Together

**Starting New Project**:
1. Use `prompt_template_for_future_threads.md` to set up conversation
2. Activate `/paper` command for JFE workflow
3. Follow `jfe-paper.md` skill for quality standards

**Managing Multiple Papers**:
1. Update `PAPER_SEQUENCE_STATUS.md` with priorities
2. Use `/paper` for each paper one at a time
3. Create editorial reviews for each completed paper

**Session Transitions**:
1. Create handoff using template when needed
2. New session loads handoff and continues
3. Git maintains full history and state

---

## 🎓 Example Workflow: Complete New Paper

**Scenario**: Write new paper on shopping and mental load

### Step 1: Activation (2 minutes)
```
User: /paper
Claude: Which paper are we working on?
User: New paper - "Shopping and the Mental Load"
```

### Step 2: Setup (10 minutes)
Claude creates:
- `shopping_mental_load.Rmd` with JFE template
- `data_dictionary_shopping_mental_load.md`
- Updates `PAPER_SEQUENCE_STATUS.md`

### Step 3: Data Analysis (2-4 hours)
Claude writes code for:
- Load data (10% sample, seed=123)
- Calculate participation rates and time intensity
- Create main comparison tables
- Generate 3 compelling figures
- Run regressions with state fixed effects
- Heterogeneity analysis
- Robustness checks

All results stored in list objects for inline reference.

### Step 4: Write Draft (2-3 hours)
Claude writes:
- Abstract (150-200 words, JEL codes, keywords)
- Introduction with literature review (15-20 citations)
- Data and Methods section
- Results with detailed interpretation
- Discussion with mechanisms and policy implications
- References in economics format

All numbers referenced via `r sprintf(...)` - no hard-coding.

### Step 5: Editorial Review (1 hour)
Claude:
- Compiles with `cache=FALSE`
- Creates `EDITORIAL_REVIEW_shopping_mental_load.md`
- Identifies major/moderate/minor issues
- Fixes all major and moderate issues

### Step 6: Quality Assurance (30 minutes)
Claude verifies:
- All 10 quality gates pass
- Soft-coding check: `grep -E "[0-9]+\.[0-9]+" shopping_mental_load.Rmd | grep -v "r sprintf"`
- Fresh PDF compile and review
- Data dictionary complete

### Step 7: Finalize (15 minutes)
```bash
git add .
git commit -m "Complete Shopping and Mental Load paper: Women do 85% of shopping, marriage exacerbates gap"
git push -u origin [branch]

# Update PAPER_SEQUENCE_STATUS.md
# Mark paper as ✅ Completed
```

**Total time**: ~6-9 hours for publication-ready paper

---

## 🔍 Cache Clearing Protocol (CRITICAL)

**Problem**: Cached results don't update when code changes

**Solution**: Always clear cache before reviewing

### In R Markdown:
```r
# Set in EVERY chunk:
{r chunk-name, cache=FALSE}
```

### Before Reviewing PDF:
```bash
# Delete cache directories
rm -rf *_cache/
rm -f *.RData

# Recompile from scratch
Rscript -e "rmarkdown::render('paper.Rmd')"

# Verify PDF timestamp
ls -lh paper.pdf
```

### Verification:
```bash
# Check if cache setting present
grep -n "cache" paper.Rmd

# Should see cache=FALSE in all chunks
# If any chunk missing this, add it
```

**This is non-negotiable**: Cached results have caused errors in past papers.

---

## 📊 Soft-Coding Verification Process

### Check for Hard-Coded Numbers:
```bash
grep -E "\b[0-9]+\.[0-9]+\b" paper.Rmd | grep -v "r sprintf"
```

### Expected Output:
Should only show:
- Line numbers in grep context
- R code calculating values (e.g., `sample_frac(0.1)`)
- Intentional constants (e.g., `dpi=300`, `seed=123`)

### Fix Hard-Coded Numbers:
```r
# Before (hard-coded):
Women spend 58 minutes per day on childcare.

# After (soft-coded):
Women spend `r sprintf("%.0f", results$mean_female_childcare)` minutes per day on childcare.
```

### Test Soft-Coding:
1. Change sample size from 10% to 5%
2. Recompile
3. All numbers should update automatically
4. If any number stays same, it's hard-coded - fix it

---

## 🤝 Handoff to New Session Example

**End of Session 1**:
```markdown
# SESSION_HANDOFF_2025-11-02.md

## Current Status
- Paper: shopping_mental_load.Rmd
- Section: Results (50% complete)
- Last commit: abc123 "Add main comparison figures"

## Next Steps
1. Complete results interpretation for Figure 3
2. Write Discussion section (mechanisms)
3. Add policy implications
4. Run editorial review

## Important Context
- Found surprising result: urban women shop 2x rural women
- Need to explore this in heterogeneity analysis
- Education gradient also interesting - add to discussion

## Resume Command
git checkout claude/jfe-paper-config-skill-011CUif6CjNKq3fZUFYcLTM8
cat SESSION_HANDOFF_2025-11-02.md
vim shopping_mental_load.Rmd  # Continue at Results section
```

**Start of Session 2**:
```
User: Continue from SESSION_HANDOFF_2025-11-02.md
Claude: [Reads handoff]
Claude: Resuming shopping_mental_load.Rmd at Results section.
        I see you found urban women shop 2x rural women - interesting finding.
        Picking up at Figure 3 interpretation...
```

---

## 📖 Additional Resources Created

### .claude/skills/README.md
- Overview of all skills
- Quick start instructions
- Maintenance guidelines

### Documentation References
The skill file references:
- JFE submission guidelines
- AER submission guidelines
- Chicago Manual of Style (Economics)
- Essential R packages for academic papers

---

## 🎯 Success Criteria

A paper is considered **publication-ready** when:

1. **Content Quality**:
   - Novel contribution clearly stated
   - Comprehensive literature review (15-20+ citations)
   - Sound methodology with robustness checks
   - Clear results with proper interpretation
   - Discussion addresses mechanisms and policy

2. **Technical Quality**:
   - Compiles without errors or warnings
   - All numbers soft-coded and update automatically
   - Data dictionary complete and linked
   - Variable names follow conventions
   - Fresh PDF (cache cleared) reviewed

3. **Format Quality**:
   - JFE format followed precisely
   - Professional tables and high-res figures
   - Proper citations and references
   - Clean, polished writing

4. **Process Quality**:
   - Editorial review completed
   - All quality gates passed
   - Changes committed to git with descriptive messages
   - PAPER_SEQUENCE_STATUS.md updated
   - Ready for human review

---

## 🚨 Common Pitfalls (Now Addressed)

| Pitfall | Old Approach | New Approach |
|---------|-------------|--------------|
| Stale cached results | Hope for the best | `cache=FALSE` required in all chunks |
| Hard-coded numbers | Manual updates | Soft-coding verification process |
| Incomplete literature | Add citations as afterthought | 15-20+ citation requirement upfront |
| Poor figure quality | Default settings | dpi=300, professional themes required |
| Unclear contribution | Implicit in intro | Explicit "This paper contributes by..." |
| Missing robustness | Only main results | Robustness checks required |
| Git chaos | Sporadic commits | Commit after each major change |
| Lost progress | No handoff mechanism | Session handoff template |

---

## 🔄 Workflow Summary

```
┌─────────────────────────────────────────────────────────────┐
│                     JFE Paper Workflow                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                      ┌───────────────┐
                      │  Type /paper  │
                      └───────┬───────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │ Specify paper and task        │
              │ (new, review, continue)       │
              └───────┬───────────────────────┘
                      │
       ───────────────┴───────────────
       │                             │
       ▼                             ▼
┌──────────────┐            ┌─────────────────┐
│  New Paper   │            │  Review Paper   │
└──────┬───────┘            └────────┬────────┘
       │                             │
       ▼                             ▼
┌──────────────────┐      ┌──────────────────────┐
│ 7-Step Workflow: │      │ Editorial Review:    │
│ 1. Setup         │      │ 1. Clear cache       │
│ 2. Scaffold      │      │ 2. Recompile         │
│ 3. Analysis      │      │ 3. Run checklist     │
│ 4. Write         │      │ 4. Create review doc │
│ 5. Review        │      │ 5. Fix issues        │
│ 6. QA            │      │ 6. Verify fixes      │
│ 7. Finalize      │      └──────────┬───────────┘
└────────┬─────────┘                 │
         │                           │
         └───────────┬───────────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │ 10 Quality Gates      │
         │ Must all pass ✅      │
         └───────────┬───────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │ Git commit & push     │
         │ Update status doc     │
         └───────────┬───────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │ Paper Complete! 🎉    │
         │ Ready for submission  │
         └───────────────────────┘
```

---

## 📝 Usage Examples

### Example 1: Start New Paper
```
You: /paper
Claude: Which paper are we working on?
You: New paper analyzing gender gaps in shopping and household management
Claude: I'll create shopping_mental_load.Rmd following JFE format...
```

### Example 2: Review Existing Paper
```
You: /paper
Claude: Which paper are we working on?
You: friendship_penalty.Rmd - need full editorial review before submission
Claude: I'll clear the cache and compile fresh...
        [Creates EDITORIAL_REVIEW_friendship_penalty.md]
        Found 2 major issues, 5 moderate, 8 minor. Starting fixes...
```

### Example 3: Session Handoff
```
You: We're hitting token limit - create handoff
Claude: I'll create SESSION_HANDOFF_2025-11-02.md...
        [Fills in all sections]
        Ready to commit and push. New session can resume from this.
```

---

## 🎓 Learning Resources

To understand the workflow better, read in order:

1. `.claude/skills/jfe-paper.md` - Main workflow (comprehensive)
2. `.claude/commands/paper.md` - Quick activation guide
3. `.claude/templates/editorial-review-template.md` - Review process
4. `.claude/templates/session-handoff-template.md` - Handoff process
5. `PAPER_SEQUENCE_STATUS.md` - See examples of completed papers

---

## 🔮 Future Enhancements

Potential additions to skill system:

1. **Additional journal formats**: AER, QJE, Econometrica
2. **Co-author collaboration**: Multi-author workflow
3. **Submission checklist**: Journal-specific requirements
4. **Response to reviewers**: R&R template
5. **Pre-submission services**: Language editing checklist
6. **Replication package**: Code and data archiving

---

## ✅ Setup Complete

All files created and ready to use:
- ✅ JFE paper skill: `.claude/skills/jfe-paper.md`
- ✅ Paper command: `.claude/commands/paper.md`
- ✅ Skills README: `.claude/skills/README.md`
- ✅ Session handoff template: `.claude/templates/session-handoff-template.md`
- ✅ Editorial review template: `.claude/templates/editorial-review-template.md`

**Next Steps**:
1. Review this document: `JFE_PAPER_CONFIG_SETUP.md`
2. Try `/paper` command to test activation
3. Use skill for next paper you write
4. Provide feedback for improvements

**Questions?**
- What does `/paper` do? → Activates JFE workflow, guides you through process
- When do I use templates? → Copy when needed (handoff, review)
- How do I verify soft-coding? → `grep -E "[0-9]+\.[0-9]+" paper.Rmd | grep -v "r sprintf"`
- What if I need to switch sessions? → Use handoff template
- How do I know paper is ready? → All 10 quality gates must pass

---

**Created by**: Claude Code
**Session**: claude/jfe-paper-config-skill-011CUif6CjNKq3fZUFYcLTM8
**Date**: 2025-11-02
**Status**: ✅ Complete and ready to use
