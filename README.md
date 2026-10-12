# Gender and Time in India: A Research Programme on the Time Use Survey 2024

Eight journal-targeted papers on unpaid work, care and free time in India, built on one audited data pipeline for the National Statistics Office's **Time Use Survey (January–December 2024)**: about 10.2 million activity records, about 450,000 person-day diaries, about 139,500 households, every state and union territory.

**Author:** Dr Preet Deep Singh, Blue Machines (preetdeepsingh111@yahoo.com)

> **Status (October 2026).** The pipeline and all eight manuscripts knit end to end. Every number is computed from the data at knit time, and every sentence that depends on a result is chosen by the estimates. **The manuscripts have been tested on synthetic data built to match the real file's structure.** The real 2024 file has been probed (aggregate counts only). It is the complete person file, but it carries no household-schedule variables, so the papers were redesigned around what it does contain (see [`docs/STRATEGY_2024_FILE.md`](docs/STRATEGY_2024_FILE.md)). Next: run on the real file, read each paper's `SUBMISSION.md`, then submit. All earlier papers are retired because their estimates are invalid (see [`docs/AUDIT.md`](docs/AUDIT.md)).

---

## The portfolio

Each folder holds `manuscript.Rmd` and `SUBMISSION.md`, which gives the target journal, fallbacks, a pre-submission checklist and a draft cover letter.

| # | Paper | Question | Target journal | Fallbacks |
|---|---|---|---|---|
| 01 | [Carrying the Household](submission/01_water_fuel_collection) | Who fetches water and gathers fuel, how households allocate the burden, and what seasonal rises in collection displace from women's and girls' days | ***World Development*** | J. Development Studies; Feminist Economics; Water Resources and Economics |
| 02 | [Co-resident Grandmothers](submission/02_grandparent_care) | Do grandmothers in three-generation households substitute for mothers' childcare, or add constraints? Diaries for both generations | ***Journal of Population Economics*** | Demography; Population and Development Review; Feminist Economics |
| 03 | [Who Cares When Care Is Needed?](submission/03_care_need) | The gender division of childcare and dependent-adult care in households that need each, with need built from the roster and the diaries | ***Feminist Economics*** | Population and Development Review; J. Aging & Social Policy; Ageing & Society |
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
│   ├── make_synthetic_data.R  schema-identical fake data for test knitting
│   └── probe_data.R           aggregate-only first look at the real file
├── submission/
│   ├── references.bib         curated bibliography shared by all papers
│   ├── _common/preamble.tex   shared LaTeX preamble
│   └── NN_<paper>/            manuscript.Rmd + SUBMISSION.md
├── docs/
│   ├── AUDIT.md               what was wrong with the legacy papers, and the merge map
│   ├── STRATEGY_2024_FILE.md  what the real file contains and how each paper uses it
│   ├── NEXT_STEPS.md          hand-off: what is done and what is left
│   ├── WORKLOG.md             shared log of rules and recurring errors
│   ├── nso_reference/         NSO 2019 layout, estimation procedure, official tables
│   ├── DataDictionaryTimeUseSurvey.xlsx
│   └── variables_dictionary.txt
├── defunct/                   all legacy papers, PDFs and memos (not citable)
└── data/                      git-ignored: microdata, derived panel, synthetic test data
```

---

## Reproducing the papers

### The data

The unit-level file `TimeUse106PER.dta` (activity level, about 1.2 GB) is distributed by MoSPI/NSO on request (<https://www.mospi.gov.in/>). It is restricted data. It is never committed: `.gitignore` blocks `*.dta` and `data/`.

What the file contains, from the probe of the real file (`docs/probe_report.txt` on the author's machine):

- 10,211,478 records, 9,969 FSUs, 139,487 households, 533,719 roster persons, 454,192 persons aged 6 and above. `Survey_Year` is 2024.
- Every major-activity diary sums to 1,440 minutes. The major/minor flag is 1/2; roster-only rows (children under 6 and non-respondents) carry no diary and a missing flag.
- Person variables: sex, age, marital status, education, principal activity status (NSO codes), NIC industry, relation to head, sector, state, district, stratum, sub-round, diary day, type of day, weights.
- **Not in the file:** religion, social group, household size as asked, consumption (MPCE), cooking fuel, lighting, laundry and sweeping arrangements, special-care need and caregiver. No separate household file exists for this release. Household size and children under 6 are therefore built from the roster, socio-economic status is proxied by roster education and employment, and care need is built from the roster and diaries. Each paper discloses this.

### Running on a Mac with RStudio (the author's setup)

Do this once. Keep the repository **outside Google Drive**: Drive sync corrupts git lock files.

1. **Copy the data out of Drive.** In the RStudio console:
   ```r
   dir.create("~/tusdata", showWarnings = FALSE)
   src <- list.files("~/Library/CloudStorage", "TimeUse106PER\\.dta$", recursive = TRUE, full.names = TRUE)
   src                                   # must show the 2024 file; pick the right one if there are two
   file.copy(src[1], "~/tusdata/TimeUse106PER.dta", overwrite = TRUE)
   ```
2. **Get the code.** In the Terminal app (not the R console):
   ```bash
   cd ~ && git clone https://github.com/Preetdeep/gender-disparity-unpaid-care-work.git gdw-papers
   cd ~/gdw-papers && git checkout claude/practical-cannon-22g8yg
   ```
   If the clone already exists, run `cd ~/gdw-papers && git pull` instead. Always pull before running anything.
3. **Open the project.** RStudio, File > Open Project, choose `~/gdw-papers`. The working directory is then the repository root; do not `setwd()` anywhere else.
4. **Install packages once:**
   ```r
   install.packages(c("data.table","haven","dplyr","tidyr","ggplot2","fixest","knitr","rmarkdown","kableExtra"))
   ```
   A LaTeX distribution must be installed (MacTeX, or `tinytex::install_tinytex()`).
5. **Point R at the data:**
   ```r
   Sys.setenv(TUS_DTA = path.expand("~/tusdata/TimeUse106PER.dta"))
   file.exists(Sys.getenv("TUS_DTA"))   # must print TRUE
   ```
6. **Probe the file** (several minutes; writes only aggregate counts):
   ```r
   source("R/probe_data.R")
   ```
   Check that `docs/probe_report.txt` contains a section headed `FEASIBILITY COUNTS`. If it does not, the pull in step 2 did not complete. Upload the report (it is a few KB).
7. **Run the papers:**
   ```r
   source("run_all.R")                 # all eight papers
   PAPERS <- c("01", "03"); source("run_all.R"); rm(PAPERS)   # selected papers only
   ```
   The first run builds the person-day panel (about 10 to 20 minutes) and caches it in `data/derived/`. Later runs reuse it unless the `.dta` changes.
8. **Send back** `data/derived/validation.txt` and the PDFs (`submission/NN_*/manuscript.pdf`). Each is far below 30 MB. Never upload the `.dta` or anything else in `data/derived/`.

### From a shell (any machine)

```bash
TUS_SYNTHETIC=1 Rscript R/make_synthetic_data.R      # synthetic test file, no microdata needed
TUS_SYNTHETIC=1 Rscript run_all.R                    # watermarked PDFs in data/synthetic/pdf/
TUS_DTA=/path/to/TimeUse106PER.dta Rscript R/probe_data.R
TUS_DTA=/path/to/TimeUse106PER.dta Rscript run_all.R 01 03
```

Requirements: R 4.3 or later with the packages above, pandoc, and LaTeX with `booktabs threeparttable threeparttablex makecell draftwatermark titling`.

### Read the validation report first

The first run writes `data/derived/validation.txt`. It lists which columns were found under which names, the share of diaries summing to 1,440 minutes, the major/minor flag values, invalid codes, weight constancy, the detected code scheme, the spouse-link rate, the number of districts and the household variables that are absent. If a column has a different name in a future release, add it to `TUS_COLS` in `R/build_panel.R`. Nothing else needs to change.

---

## What the pipeline guarantees

These rules are enforced in code because breaking them invalidated every legacy estimate:

1. **All rows, no row sampling.** Optional subsampling is by household (`build_panel(hh_sample_frac = 0.2)`) and rescales weights.
2. **Person-day unit of analysis.** Minutes come from major activities, so each diary sums to 1,440. Participation means a person did the activity that day, not that an activity row has that code.
3. **One code map.** `R/codes.R` defines every category from ICATUS 2016 three-digit codes and checks at load time that the nine top-level categories partition all 165 dictionary codes exactly.
4. **Correct flags.** Major = 1 and minor = 2 (not 1/0). Yes/no = 1/2. Diary day: Monday = 1 to Sunday = 7, referring to the day before the interview.
5. **Household structure from the roster.** Persons are FSU × household × serial number. The file lists every household member, including children under 6, who keep no diary. Household size is the number of roster members, and children under 6 are counted from roster ages. Every paper states this in its data section. Spouses are linked head ↔ spouse and married child ↔ child's spouse. Grandparents are identified for both head-level and daughter-in-law mothers.
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
