# Paper 09 — TUS 2019 vs 2024: submission notes (DRAFT; nothing submitted)

**Title:** More Paid Work, the Same Unpaid Load: Gender Gaps in Time Use in India, 2019–2024
**Target:** *Population and Development Review* (Wiley, for the Population Council), Research Article.
- ABDC 2022 Journal Quality List: **A** (Population and Development Review, Wiley-Blackwell, ISSN 0098-7921, FoR 3599).
- Fees: author guidelines state "Required Author Fees for Submission and Publication: None." Hybrid; open access optional (not chosen). Source: https://onlinelibrary.wiley.com/page/journal/17284457/homepage/forauthors.html (loaded 25 Oct 2026).
- Retargeted from World Development (reserved for paper 01 by Doc). Excluded by Doc: Demographic Research, J Population Economics, Feminist Economics, J Development Studies, World Development, Venture Capital, JTUR, JBV Insights, J Sports Economics, Strategic Entrepreneurship Journal. Not used because planned for other papers in this repo: Review of Economics of the Household (paper 04), Social Indicators Research (paper 08), Journal of Marriage and Family (paper 05 earlier plan).
- Fallbacks (one at a time, only after a decision): Population Studies (A; 7,500-word and 150-word-abstract limits), Population Research and Policy Review (A).

## PDR requirements applied
- Free Format first submission: any consistent reference style (APA kept); figures/tables with legends.
- Double-anonymised: anonymised manuscript + separate title page with author details and statements (data availability, funding, conflict of interest, ethics approval, participant consent, permission to reproduce).
- Wiley AI guidance: AI disclosure in Methods (code/analysis) and Acknowledgments (drafting).
- Length: PDR papers typically 8,000–10,000 words; this one is about 7,400 words (main text incl. tables and captions); 28 pp. Abstract 214 words (PDR states no abstract limit).
- Cover letter must confirm authorship (ICMJE criteria): included.
- No highlights (not required by PDR). Opposed reviewers optional: none.

## Files
- `manuscript.Rmd` (params: blind TRUE/FALSE), `refs_local.bib`, `apa.csl`, `analysis.R`
- `package/manuscript_anonymised.pdf`, `package/manuscript_author.pdf`, `package/title_page.md`, `package/cover_letter.md`

## Build
    source ../env.sh
    Rscript R/build_panel_2019.R
    Rscript submission/09_tus_2019_2024/analysis.R
    cd submission/09_tus_2019_2024
    Rscript -e "rmarkdown::render('manuscript.Rmd', params=list(blind=TRUE))"

## Before submission (Doc)
- Approve text, cover letter and target. Submit via https://authors.wiley.com/journal/PADR (not done).
- No microdata or .dta in the repo.
