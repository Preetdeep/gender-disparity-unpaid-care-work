# Paper 09 — TUS 2019 vs 2024: submission notes (DRAFT; nothing submitted)

**Title:** More Paid Work, the Same Unpaid Load: Gender Gaps in Time Use in India, 2019–2024
**Target:** World Development (Elsevier). ABDC 2022 Journal Quality List: A (checked in the ABDC 2022 list spreadsheet). No submission fee; hybrid journal, APC (USD 4,910) charged only if gold open access is chosen — choose the subscription route.
**Not used (per instructions):** Demographic Research, J Population Economics, Feminist Economics, J Development Studies. Fallbacks if desk-rejected: Population and Development Review (A), Population Studies (A), Gender & Society (A*). Note: WD was also the planned target for paper 01 — avoid simultaneous submissions that overlap in the same journal if Doc prefers.

## Files
- `manuscript.Rmd` (params: blind TRUE/FALSE), `refs_local.bib` (29 entries, DOIs Crossref-verified), `apa.csl`
- `analysis.R` (pooled 2019+2024 analysis; reads local derived panels, writes `data/derived/tus1924_results.rds`, not committed)
- `package/manuscript_anonymised.pdf` (no name/ORCID/email/GitHub link; PDF Author metadata = "Manuscript anonymised for review")
- `package/manuscript_author.pdf`
- `package/title_page.md`, `package/cover_letter.md` (draft for Doc), `package/highlights.md`

## Build
    source ../env.sh
    Rscript R/build_panel_2019.R      # 2019 diary panel (needs local microdata)
    Rscript submission/09_tus_2019_2024/analysis.R
    cd submission/09_tus_2019_2024
    Rscript -e "rmarkdown::render('manuscript.Rmd', params=list(blind=TRUE))"

## Before submission (Doc)
- Approve text, cover letter and target.
- Upload: anonymised manuscript, title page, highlights, cover letter (editor only). Elsevier portal asks for the generative-AI declaration (already in manuscript and title page).
- No microdata or .dta in the repo.
