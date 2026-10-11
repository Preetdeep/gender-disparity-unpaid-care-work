# Shared work log (temporary)

Agents working on `submission/NN_*/` papers read this first and append to it.
Append with `cat >> docs/WORKLOG.md` (short entries, one line or a few bullets).
Never rewrite other entries. Delete this file once all papers are submitted.

## Ground rules

- Edit only your own paper folder: `submission/NN_*/`. Do NOT edit `R/`, `submission/references.bib`,
  `submission/_common/`, `README.md` or `docs/AUDIT.md`. If shared code needs a change, log it under
  "Requests for shared code" and work around it locally in the Rmd.
- New references go in `submission/NN_*/refs_local.bib`. Add `refs_local.bib` to the YAML:
  `bibliography: [../references.bib, refs_local.bib]`. Cite only works you are certain exist, with correct
  authors, year, journal, volume and pages. Never invent or "approximately" cite. If unsure, leave it out.
- Codes: only `ACT$...` from `R/codes.R`. Unit of analysis: person-day panel from `load_panel()`. No row sampling.
- Every number is inline R. Every results-dependent sentence uses `iff()` (see `R/helpers.R`).
- Inside `\begin{abstract}...\end{abstract}` (raw LaTeX): use `pctx()` not `pct()`, `\emph{}` not `*...*`.
- Test-knit: `cd <repo> && PATH=/usr/bin:/opt/renv/bin:$PATH TUS_SYNTHETIC=1 /opt/renv/bin/Rscript -e "rmarkdown::render('submission/NN_x/manuscript.Rmd', output_dir='/tmp/claude-0/knit/NN', intermediates_dir='/tmp/claude-0/knit/NN', quiet=TRUE)"`
  The synthetic data lack variation in some cells, so "not estimable" there is expected. Errors are not.
- Do not commit or push. The lead session commits.

## Common errors already found (do not repeat)

- Signed estimate followed by a direction word ("-1.3 minutes less"). Use `diff_txt(e)` or `diff_pp(e)`.
- `%` inside the raw-LaTeX abstract comments out the rest of the line. Use `pctx()`.
- Columns added to a parent table after subsetting (`A[, x := ]` after `W <- A[...]`): the subset lacks x.
- A data.table filter using a function argument with the same name as a column (`S[y == y]`) is always TRUE. Rename the arguments.
- `etable` with `adjustbox` plus long notes shrinks the table to nothing. Use `reg_table()`, which places notes outside.
- kable row names leak into LaTeX (underscores break). `tab()` drops row names; do not pass `row.names`.
- Author footnote: use `\thanks{}` in YAML, not `^[...]`.
- Claims of "first" or of statistics not computed in the paper (e.g. coverage of childcare centres) need a citation or must go.
- Cross-references: use `Table \ref{tab:label}` and `Figure \ref{fig:<chunk-label>}`, never a hard-coded number.

## Requests for shared code

(none yet)

## Progress

