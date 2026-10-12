# GResearcher handoff (updated 12 Oct 2026, 08:30 IST)

Branch `gresearcher-realdata` → PR #119 into main (not merged). PR #116 closed unmerged (its 2019 relabel was wrong; the data are TUS 2024).

## How to run (Doc's Mac)
```
cd ~/GResearcher_runs/repo && source ../env.sh   # sets TUS_DTA, TUS_HH_DTA=~/GResearcher_runs/tus106hh.dta, pandoc, TeX
Rscript run_all.R            # ~15 min; or: Rscript run_all.R 05 07
```
`tus106hh.dta` (13 MB) is microdata: not committed. To regenerate it: `pip install nesstar-converter`, download the DDI from `https://microdata.gov.in/NADA/index.php/metadata/export/236/ddi`, delete the F2 fileDscr and its vars from the DDI, then run `nesstar-converter convert TUS2024.Nesstar ddi_hh.xml out --formats stata`.

## Done
- Smoke test; restored `submission/_common/preamble.tex` (it had been git-ignored).
- Household file extracted; full real-data run; all 8 papers knit; results are in `docs/REALDATA_RESULTS.md`.
- Gender = 3 excluded from contrasts; religion codes per DDI.
- Wording fixes (see REALDATA_RESULTS); typed section numbers replaced by `\ref`.
- References: all 412 entries verified, 325 DOIs added (`docs/REFERENCE_CHECK.md`).
- Author block: independent researcher, ORCID, gmail, AI-assisted editing disclosure, no conflicts. `params$blind` (03: `params$anonymised`) gives an anonymised build.
- Submission packages (title page and cover letter) for 05, 06, 07 and 03 in `submission/NN_*/package/`.

## Journal rules (checked 12 Oct 2026) vs current length
| Paper | Journal | Rules | Current | Gap |
|---|---|---|---|---|
| 05 | JMF | Structured abstract of about 200–225 words, no first person; ≤35 pages excluding references (double-spaced, 12 pt); no footnotes; Word file; Wiley Research Exchange | Abstract 227 words; text about 9.7k words (likely over 35 pages double-spaced) | Trim about 15–20%; remove footnotes; convert to .docx (pandoc) |
| 07 | JTUR | ≤10,000 words including references and tables; abstract ≤150 words (the guidelines also say 250 elsewhere); 5–6 keywords | Text about 10.3k words before references and appendix; abstract 227 | Cut about 3–4k words (move the appendix to an online supplement); shorten the abstract |
| 06 | JDS | Unstructured abstract ≤200 words; anonymised review | Abstract 233 words; about 10.4k words | Shorten the abstract; confirm the JDS word limit on T&F's instructions page |
| 03 | Feminist Economics | ≤10,000 words including references and tables; abstract ≤150 words; anonymised; 1–3 JEL codes; 40–100-word bio | Text about 9.6k words plus references and tables; abstract 184 | Cut about 3k words; abstract to 150 |

## Next steps
1. Knit the box-side edits (author block, 05 abstract) on the Mac; check the PDFs; commit and push.
2. Length and abstract cuts for 05, 07, 06, 03 (above). Abstracts are inline R, so keep the `iff()` branches.
3. Build anonymised PDFs (`rmarkdown::render(..., params = list(blind = TRUE))`) and, for JMF, a .docx.
4. Reframe 01, 02, 04, 08 per REALDATA_RESULTS before choosing their journals.
5. Doc approves each submission. Nothing has been submitted.
