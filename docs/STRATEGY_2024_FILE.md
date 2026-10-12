# Strategy for the 2024 person-level file (October 2026)

The author confirmed that `TimeUse106PER.dta` (TUS 2024) is the only data file available. The probe showed what it contains.

## What the file has

- Every household member: diarists (aged 6+) and roster-only members (children under 6 and a few non-respondents).
- Roster: relationship to head, sex, age, marital status, education, usual principal activity status, 2-digit NIC industry.
- Diary: day of week, type of day, informant serial number, time slots, the major/minor flag, multiple and simultaneous flags, ICATUS 3-digit
  activity, location, paid/unpaid status, enterprise type.
- Design: sector, state, district, NSS region, stratum, sub-stratum, sub-round (quarter), FSU, `MULT`, `Weight`.

## What the file does not have (household questionnaire, Block 4)

Religion, social group (caste), household consumption expenditure, cooking fuel, lighting, the mode of laundry and sweeping
(mechanical, manual, outsourced), whether a member needs special care, caregiver availability, land and dwelling.

## How the pipeline handles it

| Need | Built from | Variable(s) |
|---|---|---|
| Household size | Count of listed members, all ages | `hh_size` |
| Children under 6 | Roster ages | `hh_n_under6`, `has_under6` |
| Socioeconomic status (no consumption) | Head's education; highest education among members 15+; any member regular salaried | `head_edu_tier`, `hh_max_edu_tier`, `hh_any_regular`, `hh_n_employed` |
| Local income, caste and infrastructure | District fixed effects | `dist_id` (default in `fe()`) |
| Care need (no special-care question) | Usual status "unable to work owing to disability", or the member's own diary records receiving care (941-949); members 80+ | `care_recipient`, `hh_n_recipients`, `hh_n_80plus` |
| Season | Sub-round (quarter) | `sub_round` |
| Proxy reporting | Informant serial number differs from the person's | `proxy_report` |

Every manuscript must include `r data_disclosure(V)` in its Data section, so readers know exactly how household variables were built.

## Paper-by-paper decisions

| Paper | Decision |
|---|---|
| 01 Water and fuel collection | Original technology design impossible (no fuel, laundry or sweeping mode); retired to `defunct/legacy_papers/`. Rebuilt on diary codes 241 and 242: burden by sex and age, within-household allocation (household FE, position of daughters-in-law), and seasonal displacement (rural sub-round 2 within district, reduced form and 2SLS with first-stage F, agricultural-seasonality checks). Target *World Development*. |
| 02 Grandmothers | Keep. Drop consumption, caste and religion controls; use the SES proxies and district fixed effects. Drop `special_care`; use `hh_n_recipients`. |
| 03 Care need | Keep with need redefined: probable care recipients from the roster and diaries (above), members 80+, children under 6. Caregiver-availability analyses are removed. |
| 04 Secondary care | Keep. SES proxies replace consumption. |
| 05 Marriage | Keep. Drop caste and religion controls; SES proxies; district fixed effects. |
| 06 Son preference | Keep. The sibling fixed-effects design is unaffected; cross-sectional controls use SES proxies. |
| 07 Sunday IV | Keep. Add sub-round fixed effects. District fixed effects. |
| 08 Free time | Keep. The time-and-income poverty cross is dropped (no consumption). Use time poverty by SES proxy instead. |

## Methods standard for every paper

Survey weights; FSU-clustered SEs; district and diary-day fixed effects (sub-round where relevant); household or sibling fixed effects
where the question allows; Oster (2019) bounds for headline associations; results-dependent text through `iff()`; no claim beyond what is
estimated; all limitations stated, including the absence of consumption, caste and religion.
