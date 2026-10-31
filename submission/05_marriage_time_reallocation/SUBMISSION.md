# Paper 05: Married and Never-Married Days

**Target journal:** *Demographic Research* (retargeted from the *Journal of Marriage and Family* on 17 Oct 2026, because JMF's latest Wiley notice lists a $35 submission fee). Demographic Research has no fees of any kind (platinum open access) and uses double-blind review. Portal: https://www.demographic-research.org/authors/submission
**Fallbacks:** *Journal of Family Issues* (no fees; unstructured abstract of 150 to 200 words, separate title page), *Journal of Family and Economic Issues*.

## Contribution in one line

One time-budget decomposition of the married versus never-married difference replaces separate "penalties" for housework, sleep, social life and exercise. It adds four checks on selection into marriage, heterogeneity by patrilocal co-residence, and within-couple gaps by wife's employment, relative education, residence and the spousal age gap.

## Format (Demographic Research)

Structured abstract of at most 250 words (BACKGROUND, OBJECTIVE, METHODS, RESULTS, CONCLUSIONS, CONTRIBUTION; CONTRIBUTION is mandatory) -> Introduction -> Background -> Hypotheses H1 to H4 -> Method -> Results -> Discussion (limitations, conclusion) -> declarations (generative AI use, data and code availability) -> References. American spelling, 12 pt, double-spaced, no page numbers, headers or footers, confidence intervals instead of significance stars. See `package/PORTAL_CHECKLIST.md` for the measured counts and the web-form fields, and `docs/SUBMISSION_PRECHECK.md` for the guideline table.

## Files

- `manuscript.Rmd`: the paper. `params: blind: true` (default) prints "Manuscript anonymized for review" as author; `params = list(blind = FALSE)` gives the author version.
- `refs_local.bib` and `../references.bib`: references (verification: `docs/REFERENCE_CHECK.md`). `apa.csl`: APA 7 modified to use "et al." from four authors and to list all authors in the reference list.
- `package/`: `manuscript_anonymised.docx` (upload first), `online_supplement.pdf`, `code_replication.zip` (replicability material), `manuscript_anonymised.pdf` (check copy), `title_page.md`, `cover_letter.md` (draft), `PORTAL_CHECKLIST.md`.
- `replication/`: sources of the readme, the data meta-information file and the runner that go into the zip (`tools/build_code_zip_05.sh` builds it).

## Before submitting

- [ ] Doc approves; nothing has been submitted or paid.
- [ ] Open the docx once in Word: tables fit the page, captions read Table 1 to Table 4, File > Info shows no author name.
- [ ] Cover letter: Roo's version or the draft in `package/cover_letter.md`; it must disclose the SSRN preprint (abstract 5677063).
- [ ] Web form: authors and affiliation ("Independent Researcher, New Delhi, India"), funding (none), competing interests (none), keywords (up to 10), word counts with and without references, data availability statement, list of attachments.
- [ ] Do not submit paper 05 to any other journal while it is under review at Demographic Research.
