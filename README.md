# Gender and Time in India: A Research Programme on the Time Use Survey 2024

Eight journal-targeted papers on unpaid work, care and free time in India, built on one audited data pipeline for the National Statistics Office's **Time Use Survey (January–December 2024)**: about 10.2 million activity records, about 450,000 person-day diaries, about 139,500 households, every state and union territory.

**Author:** Dr Preet Deep Singh, Blue Machines (preetdeepsingh111@yahoo.com)

> **Status (October 2026).** The pipeline and all eight manuscripts are complete and knit end to end. Every number in every manuscript is computed from the data at knit time, and every sentence that depends on a result is chosen by the estimates. **The manuscripts have been tested on synthetic data only.** Run them on the real microdata, read the checklist in each paper's `SUBMISSION.md`, then submit. All earlier papers are retired: their estimates are invalid (see [`docs/AUDIT.md`](docs/AUDIT.md)).

---

## The portfolio

Ranked by expected publishability. Each folder holds `manuscript.Rmd` and `SUBMISSION.md`, which gives the target journal, fallbacks, a pre-submission checklist and a draft cover letter.

| # | Paper | Question | Target journal | Fallbacks |
|---|---|---|---|---|
| 01 | [Machines, Maids, and Money](submission/01_outsourcing_domestic_work) | Do clean fuel, laundry and sweeping outsourcing, and live-in help reduce women's time in the specific task each replaces? Where does released time go? | ***World Development*** | Feminist Economics; J. Development Studies; Energy Policy |
| 02 | [Co-resident Grandmothers](submission/02_grandparent_care) | Do grandmothers in three-generation households substitute for mothers' childcare, or add constraints? Diaries for both generations | ***Journal of Population Economics*** | Demography; Population and Development Review; Feminist Economics |
| 03 | [Who Cares When Care Is Needed?](submission/03_care_need) | The gender division of childcare vs dependent-adult care, conditional on the household actually needing each | ***Feminist Economics*** | Population and Development Review; J. Aging & Social Policy; Ageing & Society |
| 04 | [The Care Hidden in the Margins](submission/04_multitasking_secondary_care) | How much women's work is missed by single-activity accounting: secondary childcare, eating while working, leisure shared with care | ***Review of Economics of the Household*** | Feminist Economics; J. Time Use Research; Social Indicators Research |
| 05 | [Where Do the Minutes Come From?](submission/05_marriage_time_reallocation) | A 1,440-minute decomposition of marriage's effect on women's and men's days, within-couple gaps, and widowhood | ***Journal of Marriage and Family*** | Demographic Research; Population Studies; Rev. Econ. Household |
| 06 | [Daughters' Days](submission/06_son_preference_time) | Son preference in children's own time: sisters vs brothers in the same household (sibling fixed effects) | ***Journal of Development Studies*** | Econ. Development and Cultural Change; PDR; World Development |
| 07 | [What Men Do with a Day Off](submission/07_weekend_care_division) | IV from the quasi-random diary day: how much paid-work time men give up on Sunday goes to unpaid work? | ***Journal of Time Use Research*** | J. Population Economics; Rev. Econ. Household; Feminist Economics |
| 08 | [The Free-Time Gap over the Life Course](submission/08_life_course_free_time) | Free time and time poverty by family stage vs education, consumption, caste, religion | ***Social Indicators Research*** | J. Time Use Research; Feminist Economics; Asian Population Studies |

Submit one paper per journal at a time. Papers 05 and 08 share descriptive material; cite the first accepted one in the other.

---

## Repository layout

```
.
├── README.md                  this file
├── run_all.R                  build panel + knit every manuscript (or selected ones)
├── R/                         the shared, audited pipeline
│   ├── setup.R                the only file a manuscript sources
│   ├── codes.R                every ICATUS and roster code, checked against the dictionary
│   ├── icatus_labels.R        165 activity labels transcribed from the dictionary
│   ├── build_panel.R          activity records -> person-day panel (+ validation report)
│   ├── helpers.R              weighted estimates, FSU-clustered SEs, tables, text helpers
│   └── make_synthetic_data.R  schema-identical fake data for test knitting
├── submission/
│   ├── references.bib         curated bibliography shared by all papers
│   ├── _common/preamble.tex   shared LaTeX preamble
│   └── NN_<paper>/            manuscript.Rmd + SUBMISSION.md
├── docs/
│   ├── AUDIT.md               what was wrong with the legacy papers, and the merge map
│   ├── DataDictionaryTimeUseSurvey.xlsx
│   └── variables_dictionary.txt
├── defunct/                   all legacy papers, PDFs and memos (not citable)
└── data/                      git-ignored: microdata, derived panel, synthetic test data
```

---

## Reproducing the papers

**1. Get the data.** The unit-level file (`TimeUse106PER.dta`, activity level) is distributed by MoSPI/NSO on request (<https://www.mospi.gov.in/>). It is not in this repository.

**2. Install requirements.** R ≥ 4.3 with `data.table haven dplyr tidyr ggplot2 fixest knitr rmarkdown kableExtra`, pandoc, and a LaTeX distribution (TeX Live or TinyTeX with `booktabs threeparttable threeparttablex makecell draftwatermark titling adjustbox`).

**3. Smoke-test on synthetic data** (about one minute, no microdata needed):

```bash
TUS_SYNTHETIC=1 Rscript run_all.R            # watermarked PDFs in data/synthetic/pdf/
```

**4. Probe the real file first** (aggregate counts only; no microdata rows are written):

```bash
TUS_DTA=/path/to/TimeUse106PER.dta Rscript R/probe_data.R    # writes docs/probe_report.txt
```

**5. Run on the real data:**

```bash
TUS_DTA=/path/to/TimeUse106PER.dta Rscript run_all.R        # all eight papers
TUS_DTA=/path/to/TimeUse106PER.dta Rscript run_all.R 01 03  # selected papers
```

The first run builds `data/derived/person_day.rds` and `data/derived/validation.txt`. **Read the validation report before anything else.** It lists which columns were found under which names, the share of diaries summing to 1,440 minutes, the major/minor flag values, invalid codes, weight constancy, the spouse-link rate and the under-6 method. If a column has a different name in your release, add it to `TUS_COLS` in `R/build_panel.R`. Nothing else needs to change.

---

## What the pipeline guarantees

These rules are enforced in code because breaking them invalidated every legacy estimate:

1. **All rows, no row sampling.** Optional subsampling is by household (`build_panel(hh_sample_frac = 0.2)`) and rescales weights.
2. **Person-day unit of analysis.** Minutes come from major activities, so each diary sums to 1,440. Participation means a person did the activity that day, not that an activity row has that code.
3. **One code map.** `R/codes.R` defines every category from ICATUS 2016 three-digit codes and checks at load time that the nine top-level categories partition all 165 dictionary codes exactly.
4. **Correct flags.** Major = 1 and minor = 2 (not 1/0). Yes/no = 1/2. Diary day: Monday = 1 to Sunday = 7, referring to the day before the interview.
5. **Household structure from the roster.** Persons are FSU × household × serial number. Children under 6 keep no diary and are counted as household size minus diarists. Spouses are linked head ↔ spouse and married child ↔ child's spouse. Grandparents are identified for both head-level and daughter-in-law mothers.
6. **Inference.** Every estimate uses the survey multiplier; standard errors are clustered on the FSU, the primary sampling unit.
7. **No hard-coded results.** Every number in the text is inline R, and every interpretive sentence that depends on a sign or significance level is chosen by `iff()` from the estimate.

### Core activity categories (ICATUS 2016)

| Category | Codes | Category | Codes |
|---|---|---|---|
| Employment incl. travel | 110–182 | Childcare | 411–419, 442 |
| Commuting | 182 | Dependent-adult care | 421–429, 443 |
| Own-use goods | 211–250 | Unpaid domestic + care (SDG 5.4.1) | 311–390, 411–490 |
| Water and fuel collection | 241–242 | Socialising and communication | 711–719 |
| Food and meals | 311–319 | Religious practice | 741–749 |
| Cleaning dwelling | 321–329 | Exercise and sport | 831–832 |
| Laundry and textiles | 341–349 | Mass media | 841–849 |
| Household management | 351–359 | Free time | divisions 7 + 8 |
| Shopping | 371–372 | Sleep | 911–919 |

---

## Why the earlier papers were retired

The 37 earlier papers (73 `.Rmd` variants) shared three fatal errors: a **10% sample of activity rows**, which kept about 2 of a person's about 21 records; **mis-mapped activity codes**, e.g. "childcare" = cooking, "exercise" = conversation, "sleep" = nothing; and **activity-row averages reported as participation**. They also contradicted each other on the survey year, the sample size and several headline findings. [`docs/AUDIT.md`](docs/AUDIT.md) documents every error, every contradiction, and how the 37 papers map onto the eight above. The originals are in [`defunct/`](defunct/), grouped by topic.

---

## Citing the data

National Statistics Office (2025). *Time Use Survey (January–December 2024)*. Ministry of Statistics and Programme Implementation, Government of India.
