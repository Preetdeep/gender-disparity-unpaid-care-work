# Paper 02: Co-resident Grandmothers and Mothers' Time

**Target journal:** *Journal of Population Economics*. It publishes the grandparent-childcare and family-structure literature this paper extends (Dimova and Wolff 2011; Afridi et al. 2018).
**Fallbacks:** *Demography*, *Population and Development Review*, *Feminist Economics*.

## Contribution in one line

Diaries for both generations in the same household separate the substitution and constraint channels of co-residence. The paper also corrects the identification of grandparents in patrilocal households: daughters-in-law living with the head and spouse.

## Before submitting

- [ ] Real-data run: `TUS_DTA=/path/TimeUse106PER.dta Rscript run_all.R 02`.
- [ ] Check `validation.txt`: `under6_method` must be the household-size residual, and `share_hh_negative_under6_residual` should be about 0. If not, the household-size column is mis-mapped.
- [ ] Check the share of mothers identified as daughters-in-law (`dil`). Patrilocality implies a large share.
- [ ] The daughter-in-law heterogeneity row compares daughters-in-law with and without a co-resident mother-in-law. Most have one, so expect a wide confidence interval. If it is not estimable, drop the row and say so.
- [ ] Choose the title from the sign of the headline result. The current title is a question.
- [ ] Optional strengthening: an instrument for co-residence (for example, whether the husband is the eldest son, if the roster allows it), or grandparent mortality by state-age.
- [ ] Verify the references. Remove the author block if the journal requires anonymity.

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
