# defunct/

Nothing here is citable. These files are kept for provenance only.

* `legacy_papers/<topic>/`: every earlier version of each paper (`.Rmd`, `_ClaudeHTML.Rmd`, `_claude.Rmd`, knitted PDF/HTML, critiques), grouped by the submission paper that replaces it. `RETIRED_*` folders hold papers that were dropped.
* `notes/`: process memos (status reports, quality scores, critiques, research-question lists) written about the legacy code.
* `older/`: the former `Depricated/` folder.

Why the legacy work was retired, with the error list and the merge map: `docs/AUDIT.md`.

All legacy estimates share three fatal problems:

1. They sample 10% of activity rows, not households.
2. They mis-map ICATUS activity codes.
3. They average over activity rows instead of person-days.
