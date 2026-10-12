# Paper 02: Co-resident Grandmothers and Mothers' Time

**Target journal:** *Journal of Population Economics*. It publishes the grandparent-childcare and family-structure literature this paper extends (Dimova and Wolff 2011; Afridi et al. 2018).
**Fallbacks:** *Demography*, *Population and Development Review*, *Feminist Economics*.

## Contribution in one line

Same-day diaries for mothers and the grandparents who live with them separate the substitution and constraint channels of co-residence. The paper also fixes how grandparents and young children are identified in rosters without parent IDs. Daughters-in-law living with the head and spouse count as having an older generation. Head-level women who live with a junior married couple are treated as grandmothers, not mothers.

## Analyses in the manuscript

Mothers' full-day time use; childcare by every provider and adult-total childcare (no mechanical mother+grandmother sum); the older generation's own trade-offs (grandmothers vs grandfathers, a young grandchild present); gradients by grandmother age (<60 / 60+), grandmother employment, and grandmother vs grandfather; heterogeneity by generation, urban/rural, education and number of under-6s; a placebo on mothers whose youngest child is 6-14; robustness (sole married woman, head-level only, linked husband, self-report, other adult women, household size, generation control, diary-based care recipients, unrestricted regular-employment proxy, state instead of district FE, unweighted, any grandparent, extensive margin, Oster).

## Data constraints (real 2024 file)

The only file is the person-level `TimeUse106PER.dta` (10,211,478 activity records, 139,487 households, 454,192 persons aged 6+). It has no household questionnaire (Block 4): no consumption, caste, religion, special-care need, caregiver availability, fuel, laundry/sweeping mode, land or dwelling. The paper therefore uses: SES proxies (`head_edu_tier`, `hh_max_edu_tier`, and a regular-salaried indicator for members other than the mother and her linked grandparents, built in the Rmd from `pas`); roster-based need (other members with usual status "disabled", `hh_n_80plus`), with `hh_n_recipients` (roster or diary) in a robustness row; district fixed effects (`dist_id`), day-of-week and sub-round fixed effects. Under-6 children are counted directly from the roster. The Data section prints `data_disclosure(V)`, and the limitations state the missing consumption, caste and religion controls.

## Before submitting

- [ ] Real-data run: `TUS_DTA=/path/TimeUse106PER.dta Rscript run_all.R 02`.
- [ ] Check `validation.txt`: `under6_method` must be "direct count (file contains members under 6)", `household_file` = "NONE", `n_roster_only_age6plus` small, and `n_districts` plausible for an all-India sample (several hundred). The Data section prints these through `data_disclosure(V)`.
- [ ] Check that `sub_round` is in the panel (the main specification then includes sub-round FE and the strategy text says so automatically).
- [ ] Check the share of mothers' households with `hh_n_80plus > 0` and other disabled members; if almost none, say so in the text.
- [ ] Check the appendix sample-construction table: how many head-level women were excluded as likely grandmothers, and how many junior-level mothers have no grandmother. The junior-level heterogeneity row is reported only if both cells have at least 30 mothers. Otherwise the text says why it is not estimable.
- [ ] Check that the self-links count is 0 and the link-consistency share is 100% (the "Identifying grandparents" subsection prints both).
- [ ] `employed`, the regular-employment proxy and the disability need count depend on the PAS code scheme; the probe detected the official ("nso") scheme. Confirm `validation$code_scheme == "nso"`.
- [ ] Read every iff() branch once on real data: the abstract, introduction, discussion and conclusion choose their wording from the estimates.
- [ ] Choose the title from the sign of the headline result. The current title is a question.
- [ ] Optional strengthening: an instrument for co-residence (for example grandparent mortality by state and age, or the husband's birth order if the roster ever records it).
- [ ] Check the 31 entries in `refs_local.bib` against the published versions (page ranges especially). Remove the author block if the journal requires anonymity.

## Cover letter (draft)

> Dear Editor,
>
> I submit "Do Co-resident Grandmothers Lighten Mothers' Care Load? Three-Generation Households and Women's Time in India" for consideration in the *Journal of Population Economics*.
>
> Studies of grandparents and maternal employment usually observe proximity and employment but not who does the care. India's Time Use Survey 2024 records diaries for every household member, so I measure mothers' and co-resident grandmothers' childcare, domestic work, paid work and leisure together. In patrilocal households this distinguishes a substitution channel (grandmothers do childcare mothers would otherwise do) from a constraint channel (co-residence brings more domestic work and stricter norms). The answer matters for how far family care can stand in for formal childcare in a country where it is the default.
>
> The manuscript is not under review elsewhere. Code is public; the microdata are available from the National Statistics Office.
>
> Sincerely,
> Preet Deep Singh
