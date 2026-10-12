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

## Status 12 Oct 2026, 09:15 IST (GResearcher)
Submission packages built with `tools/build_package.sh NN` (anonymised main PDF + online supplement, cross-references to S-tables resolved via xr) and, for JMF, `tools/tex2docx.py` (Word file with editable tables):

| Paper | Journal | Main text (words incl. refs + tables) | Limit | Abstract | Limit | Package |
|---|---|---|---|---|---|---|
| 05 | J. Marriage and Family | 9,339; about 24 pp double-spaced before refs | about 35 pp | 221 incl. labels, third person, structured | 200–225 | submission/05_marriage_time_reallocation/package |
| 06 | J. Development Studies | 9,897 | 8,000–10,000 (typical; re-confirm) | 149 | 200 | submission/06_son_preference_time/package |
| 07 | J. Time Use Research | 9,786 | 10,000 | 134 | 150 | submission/07_weekend_care_division/package |
| 03 | Feminist Economics | 9,192 | 10,000 | 126 | 150 | submission/03_care_need/package |

Each package has `PORTAL_CHECKLIST.md`, `title_page.md`, `cover_letter.md`. Nothing has been submitted.

Reframes: 02 is now an informative null (new title and abstract, CI from estimates, retargeted to Demographic Research). 04 is retitled as a measurement paper ("Counting Secondary Care"); its abstract conclusion was already conditional. Suggested journals: Review of Economics of the Household, then Feminist Economics. 08 is retitled "A Small Gap in Free Time, a Larger Gap in Work"; suggested journals: Social Indicators Research, then the Journal of Time Use Research. 01 is unchanged.
Hard-coded-number scan (`tools/hardnums.py`) on 03, 05, 06 and 07 found only design constants (1,440, ICATUS codes, age bounds, literature figures).
