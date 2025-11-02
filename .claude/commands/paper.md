---
description: "Start or review JFE-format academic paper with quality checks"
---

# JFE Paper Workflow Activation

You are now in **JFE Academic Paper Writing & Review Mode**.

## Your Mission

Follow the comprehensive workflow in `.claude/skills/jfe-paper.md` to ensure publication-ready quality.

## Immediate Actions Required

1. **Identify Current Task**:
   - [ ] Starting new paper?
   - [ ] Reviewing existing paper?
   - [ ] Continuing paper in progress?
   - [ ] Conducting editorial review?

2. **CRITICAL: Clear Cache**
   - Before reviewing any PDF, verify cache settings
   - Ensure all R Markdown chunks have `cache=FALSE`
   - Recompile from scratch before review

3. **Check Git Status**
   ```bash
   git status
   git branch
   ```
   - Confirm on correct branch
   - Verify no uncommitted changes from previous work

4. **Review Paper Sequence**
   - Check `PAPER_SEQUENCE_STATUS.md` for current position
   - ONE PAPER AT A TIME rule applies

## Quality Gates

Before declaring any paper complete, verify:
- [ ] All numbers soft-coded (no hard-coded values)
- [ ] Literature review: 15-20+ citations
- [ ] Data dictionary exists and is linked
- [ ] Variable names follow conventions
- [ ] Compiles without errors
- [ ] PDF reviewed (fresh compile, cache cleared)
- [ ] Editorial review passed
- [ ] Changes committed and pushed to git

## Next Steps

Ask the user:

**"Which paper are we working on? Please specify:**
1. **Paper name/title** (if existing)
2. **Research question** (if new)
3. **Current status** (draft, review, revision?)
4. **Specific task** (write intro, fix tables, editorial review?)

**I will then:**
- Load the relevant files
- Review current state
- Clear cache and verify PDFs if needed
- Apply JFE formatting standards
- Execute the appropriate workflow
- Commit and push changes when complete

---

**Reference**: See `.claude/skills/jfe-paper.md` for complete workflow documentation.
