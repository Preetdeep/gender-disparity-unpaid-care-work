# Paper 03: Who Cares When Care Is Needed?

**Target journal:** *Feminist Economics* (double-anonymised review). Its core subject is the measurement and gendering of care, and it publishes Indian time-use work (Hirway and Jose 2011).
**Fallbacks:** *Population and Development Review*, *Journal of Aging & Social Policy*, *Ageing & Society*.

## Contribution in one line

Conditioning on the survey's own care-need and caregiver-availability questions separates the gender division of care from household composition, and gives diary-based estimates of who provides dependent-adult care in Indian households (by sex, age, relationship and spouse status) and what it costs working-age women.

## What the manuscript now contains (October 2026 revision)

- Literature review to *Feminist Economics* standard: care-economy theory (Folbre, Himmelweit, England, Tronto, Kittay, Daly and Lewis, Razavi, Elson), measurement of care in ICATUS/time-use data, informal adult care and labour supply (Wolf and Soldo through Schmitz and Westphal), the life course and spousal care (Brody, Arber and Gilbert), and kinship and care in South Asia (Dyson and Moore, Kandiyoti, Das Gupta, Lamb, Chen, Palriwala and Neetha). New references are in `refs_local.bib`.
- A conceptual framework with four questions (division conditional on need, response and cost, capacity, position and life course).
- Analyses: women's share of care conditional on need (household and aggregate ratios, Division 4 robustness); need x gender regressions with women's total response and SE (`lincom`); costs to women and men 15-64 split by caregiver availability, incl. usual-status employment; relationship-to-head distribution of all adult-care minutes; life-course profile (figure); spouses caring for a spouse flagged as recipient, and older couple-only households; men's care when no non-recipient adult woman is present; the sandwich interaction.
- Plain-language summary (after the abstract) and a policy-implications subsection (recognise / reduce / redistribute / older couples). All results-dependent sentences use `iff()`.

### Code fixes made in this revision

- The person who needs special care also keeps a diary and was counted among potential carers, biasing the cost estimates (the recipient's own non-employment looked like a cost to carers). Probable recipients (usual status 65 "not able to work owing to disability", or any receiving-care minutes, ICATUS 941-949) are now excluded from person-level carer analyses; the paper reports the employment estimate with them included as a check.
- `special_care_needed` refers to any member aged 5+, not to adults: the variable is renamed `need_sc` and the text says "special-care need", not "adult-care need". Division 4 totals are reported because a disabled child's care is coded as childcare.
- `care_giver_available` is asked only when item 17 = yes; coded explicitly as NA otherwise, and split into `need_cg` / `need_nocg` indicators with no-need households as the reference.
- Cost regressions now also control for members 60+ (as in Table 2) so that need is not confounded with an older household.
- Abstract no longer states a signed number with a direction word; intro no longer indexes `who[...][2]` without a guard.

## Before submitting

- [ ] Real-data run: `TUS_DTA=/path/TimeUse106PER.dta Rscript run_all.R 03`.
- [ ] Confirm that `special_care` and `caregiver` resolve in `validation.txt` (`columns_found`).
- [ ] Check cell sizes the text reports and treat as indicative if small: women in need households with no caregiver available (`n_W_ncg`), spouse carers (`n_sc_m`, `n_sc_w`), men in need households without a woman (`n_nw_men`), older couple-only need households (`OCn`). The text adds caution sentences automatically below 30.
- [ ] Check the share of need households with a flagged probable recipient (`pr_recip_flag`). If it is low, the flag misses most recipients; say so in Section 4.3.
- [ ] Read the whole PDF once on real data: every `iff()` branch was tested (both branches forced on synthetic data), but wording should be checked against the actual magnitudes.
- [ ] *Feminist Economics* word limit and abstract length: check the current author guidelines (the abstract is about 190 words; trim if the limit is 150). Check whether the journal wants the plain-language summary in the manuscript or only in the submission form, and whether it requires "highlights".
- [ ] Verify every reference against the published source, especially page ranges in `refs_local.bib` (Palriwala and Neetha 2010; Bauer and Sousa-Poza 2015; Esquivel et al. 2008; NSO 2019 report number 583).

## Anonymised version (double-anonymised review)

- Build: `rmarkdown::render('submission/03_care_need/manuscript.Rmd', params = list(anonymised = TRUE))`. The author line becomes "Anonymised for review", and the `\thanks{}` footnote (affiliation, email, NSO acknowledgement) is removed. Tested on synthetic data: the PDF text contains no name, affiliation or email.
- The manuscript has no self-citations and no "in earlier work I..." references. The first-person singular ("I") is kept; it reveals only that there is one author.
- Check the PDF metadata of the anonymised file (`pdfinfo`): the Author field should read "Anonymised for review". Do not upload the `.tex` or `.Rmd` with the non-anonymised YAML.
- Upload a separate title page with the author name, affiliation, email and the acknowledgement to the NSO.
- Data and code availability statement for the title page: TUS 2024 unit-level data are distributed by MoSPI; code is available from the author (do not put a GitHub link that identifies the author in the anonymised file).

## Cover letter (draft)

> Dear Editors,
>
> I submit "Who Cares When Care Is Needed? Childcare, Dependent-Adult Care, and Gender in Indian Households" for consideration in *Feminist Economics*.
>
> Population averages of care time mix the gender division of care with differences in who lives with someone who needs care. India's Time Use Survey 2024 asks each household whether a member needs special care and whether a caregiver is available among its members, and records diaries for every member aged six and above. This lets me compare childcare and dependent-adult care in the households that need each, measure women's share of each, show who provides adult care by sex, age and position in the household (including spouses and men in households without an adult woman), and estimate the cost of care need in women's paid work, leisure and sleep, separately by whether the household reports a caregiver available. With India ageing quickly and formal long-term care minimal, the results describe who will absorb the coming growth in care demand, and the paper closes with policy implications framed by the recognise-reduce-redistribute agenda.
>
> The manuscript is original and not under review elsewhere.
>
> Sincerely,
> Preet Deep Singh
