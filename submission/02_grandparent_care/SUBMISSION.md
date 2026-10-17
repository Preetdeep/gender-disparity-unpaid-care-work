# Paper 02: Grandmothers' care and mothers' time

**Target journal (revised 17 Oct 2026):** *Ageing & Society* (Cambridge University Press; no submission fee; double-anonymised; British English; 6,000 to 8,000 words; abstract at most 300 words). Previous targets (Demographic Research, Journal of Population Economics) are superseded.
**Fee-free alternatives:** *Journal of Family Issues*, *Journal of Population Economics* (subscription route).

## What changed in this revision (wording only; no result number changed)
- "Precisely estimated null" removed. The pooled childcare and employment estimates are described as fragile, with confidence intervals; the robustness range is soft-coded.
- Claims of "no significant difference" that the standard errors contradicted (food and meals, free time, sleep, secondary childcare, employment status) now follow the estimates and confidence intervals.
- The placebo is described as not fully clean.
- Section 4 and Section 8.3 now say the under-six count is a direct count of roster members (the data file contains members under six). The old text said "household size minus diarists" and printed a stray dash. Appendix Table 9 was right on this point. Table 9's "diaries summing to 1,440 minutes: 100.0%" was rounding; it now reads "not summing to 1,440 minutes: 5 of 450,457".
- Framing moved towards the grandmothers' side; new title.
- Significance stars removed; confidence intervals in text and tables. British spelling, unnumbered sections, tables at the end, eight tables in the main text, figures and the two appendix tables in the online supplement.
- Anonymised: the build with `blind=TRUE` has no author, ORCID, email or repository link.

## Open points for the author and Roo (substantive, not wording)
- The pooled grandmother indicator is closely tied to the household arrangement (junior level or head level), and the pooled estimate averages subgroup estimates of different sign. A specification within arrangement, or by grandmother age and employment, would give a stronger headline than the pooled null.
- The placebo is not clean for domestic work.

## Before submitting
- [ ] Build on the Mac with the real data (`tools/build_package.sh 02`), keeping the data outside the repository; check the page count, the main-text word count (6,000 to 8,000) and the abstract (at most 300 words).
- [ ] Read the built PDF once for the conditional wording and for any stray dash or "NA".
- [ ] AI-use declaration: add tool versions and dates.
- [ ] Confirm that no preprint exists.
- [ ] Check `refs_local.bib` entries against the published versions.
- [ ] Follow `package/PORTAL_CHECKLIST.md`.
