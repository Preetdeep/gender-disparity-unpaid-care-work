# Paper 10: PLFS women's work, 2017-18 to 2023-24: submission notes (DRAFT; nothing submitted)

**Title:** Counting more women's work: unpaid helpers, subsidiary activity and the rise in women's employment in India, 2017–18 to 2023–24
**Short title:** Counting more women's work in India (35 characters)
**Target:** *Population Studies* (Taylor & Francis / Routledge, for the Population Investigation Committee), original article.

- ABDC Journal Quality List: **A** (ISSN 0032-4728). Source is secondary (journalindexes.com, which reports A in the 2022 and 2025 lists); the ABDC primary list could not be opened from the box (abdc.edu.au has no searchable list, the IGIDR copy of the 2022 PDF timed out). **Check on the ABDC site before submitting.**
- Fees: Instructions for Authors (page updated 20 Aug 2026) state: "There are no submission fees, publication fees, or page charges for this journal, except where publishing Open Access." Open access is optional and not chosen. Source: https://www.tandfonline.com/action/authorSubmission?show=instructions&journalCode=rpst20 (read 25 Oct 2026).
- Not used: Labour Economics (EUR 100 submission fee for non-members). Excluded by Doc: Demographic Research, J Population Economics, Feminist Economics, JDS, World Development, PDR, Venture Capital, JTUR, JBV Insights, J Sports Economics, Southern Economic Journal, RoEH, SIR, JMF.
- **Overlap to resolve:** paper 09's SUBMISSION.md lists Population Studies as its first fallback after PDR. If paper 09 is rejected by PDR, choose a different fallback for it (for example Population Research and Policy Review) so the two papers do not go to the same journal at the same time.

## Population Studies requirements applied
| Requirement | Status |
|---|---|
| Main text up to 7,500 words | about 5,000 words (Introduction to Conclusion, excluding abstract, tables, captions, notes, references, appendix); about 6,100 with tables and captions |
| Abstract up to 150 words | 135 words |
| Up to 10 keywords | 6 |
| Short title up to 45 characters | 35 |
| Appendix at most 3 tables or figures | 2 tables (A1, A2) |
| No footnotes except under tables | none in text |
| British -ize spelling | yes ("per cent", -ize, single quotes) |
| Double-anonymous: 'Manuscript-anonymous' and 'Manuscript-with author details' | manuscript_anonymised.pdf and manuscript_author.pdf |
| Notes and Acknowledgements with funding, data availability, AI declaration, disclosure, ORCID | in author version; anonymised version has funding, disclosure, data availability, ethics and AI declaration without identifiers |
| CRediT statement | title_page.md |
| Submission via Routledge portal | not done |

## Files
- `analysis.R` (reads PLFS first-visit CSVs, writes plfs10_results.rds outside the repo)
- `manuscript.Rmd` (params: blind TRUE/FALSE), `refs_local.bib`, `apa.csl`, `preamble.inc`, `knit.R`, `build_pdf.sh`
- `package/manuscript_anonymised.pdf`, `package/manuscript_author.pdf`, `package/title_page.md`, `package/cover_letter.md` (draft)

## Build
    # on the Mac (R, data in ~/GResearcher_runs/data_raw/plfs2324 and plfs1718)
    Rscript submission/10_plfs_women_work/analysis.R      # writes ~/GResearcher_runs/data_derived/plfs10/plfs10_results.rds
    cd submission/10_plfs_women_work && Rscript knit.R     # build/{anonymised,author}/manuscript.md and figure PDFs (PLFS10_RDS overrides the rds path)
    # on a machine with pandoc >= 3 and xelatex
    bash build_pdf.sh                                      # package/manuscript_{anonymised,author}.pdf

Note: the final PDFs were built from the 25 Oct knit with two text edits applied directly to the knitted Markdown (one merged citation sentence in the Introduction; "reproduced, to within rounding" in the Conclusion) and figures switched to Markdown images, because the Mac went offline before the re-knit. manuscript.Rmd and knit.R already contain these changes; a re-knit gives the same text.

## Checks done
- Unit-level estimates reproduce 59 of 60 published headline values to one decimal (men's CWS LFPR 2017-18: 75.16 vs 75.1 published; stated in Table 1).
- Anonymised PDF text and metadata contain no name, email, ORCID or GitHub link ("Singh" appears only in the cited Jha, Ghatak and Singh 2026). No "??" references.
- All references checked on Crossref or the issuing body; EPW articles carry no page numbers.

## Before submission (Doc)
- Approve text, cover letter and target; confirm the ABDC rating on the primary list.
- Submit via the Routledge submission portal for Population Studies (not done).
- No microdata, .rds or .dta in the repo.
