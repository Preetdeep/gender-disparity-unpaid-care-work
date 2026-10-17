# Journal of Population Economics: submission checklist

**Portal:** Springer Nature editorial system, linked from https://link.springer.com/journal/148/submission-guidelines ("Submit manuscript").
**Status:** NOT submitted. Doc must approve, type his own passwords and submit.
**Fees:** no submission fee was found on the guidelines page. Open Choice (open access) is optional and carries an APC; the page points to Springer Compact agreements and the journal's open-access page. Do not choose it unless Doc decides to.

## Rules read on the guidelines page (17 Oct 2026) and how the files meet them
| Rule | Source wording | This package |
|---|---|---|
| Abstract | General rule 150 to 250 words, **but** the journal-specific remark says a maximum of 150 words, non-technical, stating the innovation and contribution | 150 words, no subheadings, no undefined abbreviations, no references |
| Keywords | 4 to 6 | 6 |
| JEL codes | "Only a number of three" | D13, J13, J22 |
| Text file | Word (.docx or .doc) with all editable source files; plain font such as 10-point Times; automatic page numbers; no field functions; tables with the table function; at most three heading levels | `manuscript_anonymised.docx`: Times New Roman 11 pt, 1.5 spacing, footer page numbers, Word tables, two heading levels (LaTeX source is not required; LaTeX is allowed for mathematical content) |
| Citations | Name and year in parentheses | Springer Basic author-date style (`springer-basic-author-date.csl`) |
| Reference list | Alphabetized by first author, then (two authors) co-author, then date; DOIs as full links; journal names abbreviated per ISSN LTWA, **or full titles if unsure** | Full titles used; DOIs as https://doi.org links where the bibliography has one; all authors named |
| Footnotes | Allowed; never only a citation and never bibliographic details; footnotes instead of endnotes | None used |
| Tables and figures | Numbered, cited in order, captions in the text file | 8 tables inline in the text; figures are in the supplement |
| Supplement | PDF, cited in the text as "Online Resource", named ESM_1.pdf; each file should carry article title, journal, author names, affiliation and email | `ESM_1.pdf`, cited as Online Resource 1. It has the anonymized title only: see "To decide" below |
| Declarations | Heading "Statements and Declarations" before the references with Funding, Competing interests, Ethics, Data availability; submissions without them are returned as incomplete | Included in the manuscript |
| AI use | Generative-AI use documented in the Methods; copy-editing help needs no declaration | In the Methods and in `title_page.md` |
| Acknowledgments | Separate section on the title page; should thank the anonymous referees | `title_page.md` |
| Reviewer suggestions | Not accepted; requests to exclude reviewers are accepted | none given |
| Word limit | None found | Main text about 7,000 (6,984 in the docx, excluding tables; about 7,680 with table text) words |

## Differences from the summary Roo wrote
1. **Abstract:** the page gives two rules. The general one is 150 to 250 words, but the journal-specific remark says a maximum of 150 words. Exactly 150 words satisfies both, so the abstract has exactly 150 words (checked on the real-data build). Check the portal counter.
2. The page does not say the review is anonymized or single-blind, and it asks for author names and affiliation on supplementary files. The manuscript is anonymized anyway.
3. Footnotes: allowed, with restrictions (above), as Roo said.
4. Spelling is not stated. Titles on the journal's recent-articles list use American forms ("labor", "behaviors", "aging"), and a 2026 article on coresident grandparents writes "coresident", so the manuscript uses American spelling.
5. Springer abbreviates journal names in the reference list; full titles are allowed "if unsure".
6. Springer also asks authors to check whether cited discussion papers have since been published. The reference list was checked against published versions for the entries marked in `refs_local.bib`, but not re-checked for this submission.

## Files in this folder
- `manuscript_anonymised.pdf` and `manuscript_anonymised.docx`: complete text, no author, no acknowledgments (build: `tools/build_package.sh 02` then `submission/02_grandparent_care/build_docx.sh`).
- `ESM_1.pdf`: Online Resource 1 (Figs S1, S2; Tables S1, S2).
- `title_page.md`: names, affiliation, email, ORCID, acknowledgments, declarations, AI statement (upload as the title page).
- `cover_letter.md`: draft cover letter.

## Counts (real-data build, 17 Oct 2026)
Real-data build counts (built 17 Oct 2026 on the Mac from the real TUS 2024 data held outside the repo; panel `data/derived/person_day.rds`, not committed):

- Abstract: 150 words (counted in `main.tex`).
- Main text, Introduction to Conclusion (docx, paragraphs only, headings and table captions included, tables excluded): 6,984 words. Table cell text adds about 698 words, so about 7,680 with tables.
- Statements and Declarations: 91 words. References: about 1,030 words. No word limit applies.
- Manuscript PDF (11 pt, 1.5 line spacing, 1 inch margins, with inline tables and references): 21 pages.
- Manuscript docx (Times New Roman 11 pt, 1.5 spacing, page numbers in the footer, tables single-spaced at 9 pt): 23 pages when rendered in LibreOffice; not opened in Word, so Word may differ by a page.
- Online Resource 1 (ESM_1.pdf): 2 pages; built from `tools/build_package.sh 02`.
- Key numbers checked against the earlier PDF: 49,992 mothers; 36% live with a grandmother; mothers' childcare -2.1 min/day (SE 1.3, CI -4.6 to 0.4); paid work -0.4 (CI -3.8 to 3.0); grandmothers' childcare 85.9 min/day; household total +88.6. All match.

## Fields the portal asks for
- [ ] Article type: Original paper
- [ ] Title; abstract (paste from the PDF); keywords; JEL codes D13, J13, J22
- [ ] Author: Dr Preet Deep Singh, Independent Researcher, New Delhi, India, preetds@iima.ac.in, ORCID 0000-0003-3721-7548
- [ ] Funding: none. Competing interests: none
- [ ] Data availability statement (required)
- [ ] AI-use declaration: add tool versions and dates if asked (not recorded in the repository)
- [ ] Preprint or working paper: confirm none exists
- [ ] Upload the title page and `ESM_1.pdf` as supplementary material
- [ ] Reviewer suggestions: none; exclusions: none

## To decide
- Springer asks that each supplementary file carry the article title, journal, author names, affiliation and email. `ESM_1.pdf` is anonymized, so if the portal is single-blind, Doc can add that header before uploading.
- Optional: Open Choice (APC) or a Springer Compact agreement.
