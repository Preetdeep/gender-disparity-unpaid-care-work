# Demographic Research: submission checklist (paper 05)

**Portal:** own site, https://www.demographic-research.org/authors/submission (author account and web form, free; no submission fee, no APC: Platinum open access). Guidelines: https://www.demographic-research.org/authors/submissionguidelines
**Review:** double-blind. **Status:** NOT submitted. Doc must approve and submit. (Retargeted from JMF on 17 Oct 2026: JMF's latest Wiley notice lists a $35 submission fee.)

## Files (up to three uploads; first = abstract + main text)
1. `manuscript_anonymised.docx`: **upload first.** Contains the structured abstract and the main text, with four editable Word tables and no figures (all figures are in the supplement). Times New Roman 12 pt, double-spaced, 1-inch margins, **no page numbers, headers or footers** (verified: no header/footer parts, no PAGE fields), author metadata blank. Supplement items are cited literally (Figure S1, Table S2). One footnote (the data portal URL with access date, as the guidelines ask for URLs). About 35 pages in LibreOffice (the PDF check copy is 34); DR sets no page limit.
2. `online_supplement.pdf`: appendix tables and figures S1 onwards.
3. `code_replication.zip` (replicability material): `readme.txt` (lists every file, run instructions, software versions), `meta_information.txt` (where and how to obtain the data, licence, records and variables used, variable descriptions), R code (`analysis_05.R` with chunk headers naming the table or figure, `R/` helper and panel-building code, `run_05.R`), a synthetic-data generator and a small FAKE sample CSV. **No microdata, no .dta, no .rds.** Open-source software only. Tested: `TUS_SYNTHETIC=1 Rscript run_05.R` runs end to end, and the real-data run reproduces the paper's headline coefficients. Upload at submission to earn the "Replicable" label (DR checklist: code and software versions, meta-information, readme.txt, single zip; desirable: R, commented, cross-referenced to the paper).
- `manuscript_anonymised.pdf`: check copy only (not uploaded). `title_page.md` and `cover_letter.md` hold the web-form details (Roo rewrites the cover letter for DR; it must disclose the SSRN preprint, abstract 5677063, and how this paper differs).

## Measured (final build)
- Abstract: **237 words** (limit 250), structured BACKGROUND / OBJECTIVE / METHODS / RESULTS / CONCLUSIONS / CONTRIBUTION, in this order, data source under METHODS, third person.
- Word count for the web form: **6,877 excluding references and notes** (title, abstract, text, declarations, tables); **8,634 including references**, tables and the one footnote. Main text Introduction to Conclusion: **5,780** (DR recommends at most 8,000).
- Keywords: 6 (limit 10): marriage; time use; unpaid work; gender; patrilocality; India.
- Spelling: American, consistent (DR accepts either).
- Statistics: no asterisks and no "(statistically) significant" anywhere; estimates carry 95% confidence intervals in the text and in all four main tables (and the supplement tables).
- References: author-year, alphabetical, unnumbered; every reference lists all authors (no "et al." in the list); in text, full names for two or three authors and "et al." from four, as DR's reference guidelines say. DR house style for the list is only requested after acceptance.
- Tables: Word tables, no tabs or spaces; notes under each table define symbols.
- AI-use disclosure: section "Declaration of generative AI use" (Claude, Anthropic; how it was used).
- Data availability statement: section "Data and code availability" in the manuscript (required by DR).

## Web-form fields
- [ ] Previously published or builds on previous work: disclose the SSRN preprint (abstract 5677063) and explain the difference in the cover letter
- [ ] Title (includes geographic and temporal focus): Married and Never-Married Days: Marriage, Gender and the Full Time Budget in India, 2024
- [ ] Authors: Dr Preet Deep Singh, Independent Researcher, New Delhi, India; ORCID 0000-0003-3721-7548; corresponding-author address, email and phone as in `title_page.md`
- [ ] Funding: none. Conflicts: none
- [ ] Structured abstract: paste the same text into the form
- [ ] Type: Research Article. Keywords: up to 10 (we have 6)
- [ ] Word counts (both, see above); data availability statement (paste the manuscript text); list of attachments with formats (.docx, .pdf, .zip)
- [ ] Before uploading: open the docx once in Word, check the tables fit and that File > Info shows no author name
