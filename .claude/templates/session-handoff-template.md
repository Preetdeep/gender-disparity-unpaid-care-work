# Session Handoff: [YYYY-MM-DD]

## Session Info
- **Session ID**: [Current session ID]
- **Branch**: [Current branch name]
- **Token usage**: [Estimated remaining]
- **Papers completed this session**: [Count]
- **Date/Time**: [Date and time of handoff]

---

## Current Status

### Paper in Progress
- **Paper name**: [Name/title]
- **File**: [Filename.Rmd]
- **Section being worked on**: [Section name]
- **Completion estimate**: [X% complete]

### Last Commit
```bash
[Commit hash]: [Commit message]
```

### Outstanding Tasks
1. [ ] [Task 1 description]
2. [ ] [Task 2 description]
3. [ ] [Task 3 description]

---

## Next Steps

### Immediate Next Task
[Detailed description of what to do first when resuming]

### Following Tasks
1. [Next task after immediate]
2. [Subsequent task]
3. [Final tasks before paper completion]

---

## Files Modified This Session

### New Files Created
- `[filename]`: [Purpose/description]
- `[filename]`: [Purpose/description]

### Files Modified
- `[filename]`: [What changed]
- `[filename]`: [What changed]

### Files Deleted
- `[filename]`: [Why deleted]

---

## Important Context

### Decisions Made
- [Decision 1 and rationale]
- [Decision 2 and rationale]

### Issues Discovered
- [Issue 1 and current status]
- [Issue 2 and current status]

### Non-Standard Approaches
- [Approach 1 and why it was necessary]
- [Approach 2 and why it was necessary]

### Key Results Found
- [Finding 1]
- [Finding 2]

---

## Git Status

### Current Branch Status
```bash
# Run these commands to get status:
git status
git log --oneline -5
git diff --stat
```

### Uncommitted Changes
[List any uncommitted changes and why they weren't committed]

### Push Status
- [ ] All changes pushed to remote
- [ ] Some changes pending push (specify which)
- [ ] Working directory clean

---

## Data & Analysis State

### Datasets Being Used
- `[dataset name]`: [Status - loaded, processed, analyzed]

### Variables Created
- `[variable name]`: [Definition and purpose]

### Results Stored
- `[results object]`: [What it contains]

---

## Quality Checks Completed

- [ ] Cache cleared and PDF recompiled
- [ ] Numbers verified as soft-coded
- [ ] Literature review citations checked
- [ ] Data dictionary updated
- [ ] Variable names follow conventions
- [ ] Git commits descriptive and complete

---

## Quality Checks Still Needed

- [ ] [Check 1]
- [ ] [Check 2]
- [ ] [Check 3]

---

## Known Issues/Blockers

### Critical Issues
- [Issue 1 that blocks progress]

### Non-Critical Issues
- [Issue 1 that can be addressed later]

### Questions for User
- [Question 1]
- [Question 2]

---

## Resume Instructions

### To Continue This Work in New Session:

1. **Fetch latest changes**:
   ```bash
   git fetch origin [branch-name]
   ```

2. **Checkout branch**:
   ```bash
   git checkout [branch-name]
   git pull origin [branch-name]
   ```

3. **Review this handoff**:
   ```bash
   cat SESSION_HANDOFF_[date].md
   ```

4. **Load the paper**:
   ```bash
   # Open in RStudio or review:
   cat [paper_filename.Rmd]
   ```

5. **Continue from**:
   - File: `[specific file]`
   - Section: `[specific section]`
   - Line: `[approximate line number if relevant]`
   - Task: `[specific task description]`

---

## Additional Notes

[Any other important information for the next session]

---

**Created by**: Claude Code
**Handoff from session**: [Session ID]
**Resume in session**: [New session ID - filled by new session]
**Status at handoff**: ⏳ [Paper name] in progress
