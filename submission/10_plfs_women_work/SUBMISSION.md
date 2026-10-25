# Paper 10: PLFS women's work, 2017-18 to 2023-24: submission notes (DRAFT; nothing submitted)

**Title:** Counting more women's work: unpaid helpers, subsidiary activity and the rise in women's employment in India, 2017–18 to 2023–24
**Short title:** Counting more women's work in India (35 characters)
**Target:** *Population Studies* (Taylor & Francis / Routledge, for the Population Investigation Committee), original article.

- ABDC Journal Quality List: **A** (ISSN 0032-4728, FoR 3599), verified 25 Oct 2026 on the primary list: ABDC-JQL-2025-v3-210926.xlsx (https://abdc.edu.au/wp-content/uploads/2026/09/ABDC-JQL-2025-v3-210926.xlsx), A in both the 2025 and 2022 sheets.
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


## Pre-submission review, 25 Oct 2026
- Own review plus a Claude second read (15 flags; all spot-checked). Accepted: wording on survey framing and the 2022-23 note (Boxes 9 and 10 only), net-change wording in 4.3, seasons caveat in 4.4, item-missingness of the destination question computed in R, working-age (15-59) check in 4.6, state heterogeneity caveat in 4.7 (Kerala, Tamil Nadu, Delhi), annual WPR series from the NSO press note in the Discussion, ethics sentence in 3.1, fuller AI declaration. Rejected: new demographic section (out of scope; referee risk), changes to 84 per cent and 163,000 (correct from unrounded R output), NIC and NSO/NSSO wording (intentional).
- Figure 2: hand-placed labels with leaders; Table A2 split into A2 (Panels A, B) and new Table A3 (state values). Duplicate figure captions removed (knit.R plot hook).
- EPW references (jha2026, goldar2026, ara2025): no page numbers on EPW or Crossref; kept without pages, consistently.
- Fees: none (T&F instructions, updated 20 Aug 2026), except optional OA / colour print.
- **Pending: re-knit on the Mac (needs plfs10_results.rds) and rebuild PDFs; check Fig 2 labels, abstract <=150 words, word count in title_page.md.** PDFs in package/ predate these edits.
