# Claude Skills for Academic Paper Writing

## Available Skills

### `jfe-paper` - JFE Academic Paper Writing & Review

Comprehensive workflow for writing and reviewing academic papers in Journal of Financial Economics format.

**When to use:**
- Starting a new academic paper
- Reviewing existing papers for submission
- Ensuring formatting compliance
- Managing multi-paper projects

**Key features:**
- JFE format requirements and templates
- Completeness checklist (20+ items)
- Soft-coding verification (no hard-coded numbers)
- Literature review standards (15-20+ citations)
- Data dictionary requirements
- Variable naming conventions
- Editorial review process
- Git workflow integration
- PDF cache clearing protocols
- Session handoff procedures

**Usage:**
```
Load the jfe-paper skill to guide paper writing workflow
```

Or simply reference the skill file directly:
```
Follow .claude/skills/jfe-paper.md for paper requirements
```

---

## Quick Start

### For New Papers
1. Review jfe-paper.md "Example Workflow for New Paper"
2. Follow Step 1-7 checklist
3. Use pre-submission checklist before declaring complete

### For Editorial Reviews
1. Compile paper with `cache=FALSE`
2. Follow "Editorial Review Checklist"
3. Create EDITORIAL_REVIEW_[paper_name].md
4. Fix issues in priority order (Major → Moderate → Minor)

### For Session Handoffs
1. Create SESSION_HANDOFF_[date].md using template
2. Commit and push to git
3. New session can resume from handoff document

---

## Integration with Existing Workflow

This skill complements the existing workflow documented in:
- `prompt_template_for_future_threads.md` - Initial conversation setup
- `PAPER_SEQUENCE_STATUS.md` - Multi-paper project tracking
- `EDITORIAL_REVIEW_*.md` - Paper-specific review notes

---

## Maintenance

Update this skill when:
- JFE submission guidelines change
- New quality issues discovered
- Workflow improvements identified
- Additional paper types needed (AER, QJE, etc.)

Last updated: 2025-11-02
