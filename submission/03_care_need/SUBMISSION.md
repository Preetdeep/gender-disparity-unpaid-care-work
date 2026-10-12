# Paper 03: Who Cares When Care Is Needed? Measuring Care Need and Its Gender Division with Indian Time-Use Diaries

**Target journal:** *Feminist Economics* (double-anonymised review). Its core subject is the measurement and gendering of care, and it publishes Indian time-use work (Hirway and Jose 2011).
**Fallbacks:** *Population and Development Review*, *Journal of Aging & Social Policy*, *Ageing & Society*.

## Contribution in one line

Need is not asked in the person-level TUS 2024 file, so the paper builds it from the roster and the diaries (a child under six; an adult with disability as usual status or who records receiving care; a member aged 80+). It then measures women's share of childcare and dependent-adult care in the households that need each, shows how the result depends on the marker of need, estimates what adult-care need costs working-age women, and shows who provides adult care by sex, age, relationship and spouse status.

## Design (October 2026 redesign for the real 2024 file)

The real file has no special-care-need question, no caregiver-availability question, and no consumption, caste, religion, cooking, laundry, sweeping or land items (see `docs/STRATEGY_2024_FILE.md`). The earlier design relied on the first two, so it was rebuilt:

- **Child-care need:** `hh_n_under6 > 0` (counted from roster ages; children under six keep no diary).
- **Adult-care need**, for each person counting members *other than* that person:
  (a) a member 15+ with usual status "not able to work owing to disability" (`CODE$pas_disabled`);
  (b) a member 15+ whose own diary records receiving personal or health care (ICATUS 941-949);
  (c) a member aged 80+ (full roster, `hh_n_80plus`).
  (a) or (b) = probable care recipient; the combined indicator is (a), (b) or (c).
- New Table "The markers of care need compared": number of households, weighted share, women's share of care, men's and women's response, and the employment association, for each marker separately and combined. Appendix Table "Care need in the sample households" gives overlaps, the share of households where all diarists share a diary day (the source of a mechanical link for marker (b)), and the households whose only recipient is a child aged 6-14 or a non-diarist.
- Cost table: columns are combined need, the three markers entered jointly, and men. Text compares the received-care and disability coefficients (larger (b) = mechanical-link warning). Oster (2019) bias-adjusted coefficients are reported for women's adult care and employment.
- Probable recipients (shared `care_recipient`, any age) are excluded from all carer analyses. Members 80+ who are not recipients stay in the carer sample.
- Kept with the new definitions: life-course figure, relationship-to-head table, spouse carers (spouse is a probable recipient), older couple-only households, men without a woman carer (now: woman 15-79 who is not a recipient), the sandwich interaction.
- Removed: all caregiver-availability analyses and text (the old Q3), and every use of `special_care`, `caregiver`, `mpce`/quintile, religion, social group, cooking, washing, sweeping, land.
- Controls: age band, education, marital status, urban, household size, members 60+, proxy report, plus the SES proxies `head_edu_tier`, `hh_max_edu_tier` and `hh_any_regular`. Fixed effects: district (`dist_id`), day of week and, where present, sub-round. The text says so.
- The Data section includes `r data_disclosure(V)`. The Limitations section has a paragraph on what each marker misses (recipients who do not record received care; frail older people without disability status; unmet need; no severity; no recipient link) and on the absence of consumption, caste and religion.
- Title, abstract, introduction, framework (now three questions) and policy section rewritten so they promise only what the new design delivers. All numbers are inline and results-dependent text uses `iff()`.

## What cannot be estimated

- Caregiver availability or care capacity as reported by the household.
- The household's own report of special-care need, its severity or type, and the identity of the recipient of each care episode (need is linked to care at the household level).
- Care burdens by household consumption, caste or religion.
- Unmet need: households with a frail member who received no care, has no recorded disability and is under 80 are classified as having no need.

## Before submitting

- [ ] Real-data run: `TUS_DTA=/path/TimeUse106PER.dta Rscript run_all.R 03`.
- [ ] Check the household counts in Table "markers compared" and the appendix (especially marker (b), and the "all diarists report the same day" share). If (b) flags few households or the same-day share is high, make the status and age markers the headline in the abstract.
- [ ] Check cell sizes the text reports and treat as indicative if small: spouse carers (`n_sc_m`, `n_sc_w`), men in need households without a woman carer (`n_nw_men`), older couple-only need households (`OCn`). The text adds caution sentences automatically below 30.
- [ ] Read the whole PDF once on real data. Every `iff()` branch was tested (alternative branches forced on synthetic data), but the wording should be checked against the actual magnitudes. The synthetic data have no members aged 80+ and no receiving-care minutes, so markers (b) and (c) show "--" there. That is expected.
- [ ] *Feminist Economics* word limit and abstract length: check the current author guidelines (the abstract is about 200 words; trim if the limit is 150). Check whether the journal wants the plain-language summary in the manuscript or only in the submission form, and whether it requires "highlights".
- [ ] References were entered from memory and have NOT been verified against sources. Verify every entry before submission, especially the page ranges in `refs_local.bib` (Palriwala and Neetha 2010; Bauer and Sousa-Poza 2015; Esquivel et al. 2008; NSO 2019 report number 583).

## Anonymised version (double-anonymised review)

- Build: `rmarkdown::render('submission/03_care_need/manuscript.Rmd', params = list(anonymised = TRUE))`. The author line becomes "Anonymised for review", and the `\thanks{}` footnote (affiliation, email, NSO acknowledgement) is removed. Tested on synthetic data in October 2026 after the redesign: the PDF text contains no name, affiliation or email, and the PDF Author field reads "Anonymised for review".
- The manuscript has no self-citations and no "in earlier work I..." references. The first-person singular ("I") is kept; it reveals only that there is one author.
- Do not upload the `.tex` or `.Rmd` with the non-anonymised YAML.
- Upload a separate title page with the author name, affiliation, email and the acknowledgement to the NSO.
- Data and code availability statement for the title page: TUS 2024 unit-level data are distributed by MoSPI; code is available from the author (do not put a GitHub link that identifies the author in the anonymised file).

## Cover letter (draft)

> Dear Editors,
>
> I submit "Who Cares When Care Is Needed? Measuring Care Need and Its Gender Division with Indian Time-Use Diaries" for consideration in *Feminist Economics*.
>
> Population averages of care time mix the gender division of care with differences in who lives with someone who needs care. India's Time Use Survey 2024 records a full-day diary for every household member aged six and above, but the unit-level file does not say which households need care. I identify need from what the roster and diaries do record: a child under six; an adult whose usual status is disability, or whose own diary records receiving personal or health care; and a member aged 80 or above. I report results for each marker separately and combined, and set out what each captures and misses. This lets me measure women's share of childcare and of dependent-adult care in the households that need each, show how much that measurement depends on how need is identified, show who provides adult care by sex, age and position in the household (including spouses and men in households without a woman carer), and estimate the association of adult-care need with women's paid work, leisure and sleep. With India ageing quickly and formal long-term care minimal, the results describe who will absorb the coming growth in care demand. The paper closes with policy implications framed by the recognise-reduce-redistribute agenda, including the case for releasing household care-need items with the diaries.
>
> The manuscript is original and not under review elsewhere.
>
> Sincerely,
> Preet Deep Singh
