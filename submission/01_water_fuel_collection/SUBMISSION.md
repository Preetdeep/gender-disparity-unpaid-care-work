# Paper 01: Carrying the Household (water and fuel collection)

**Target journal:** *World Development*. It publishes empirical work on gender, infrastructure and household production in developing countries, including the water-access and time-allocation literature this paper extends (e.g. Ilahi and Grimard; Koolwal and van de Walle in EDCC; Whittington et al. in *World Development*). Its readers include the water, sanitation and clean-energy policy community.
**Fallbacks:** *Journal of Development Studies*, *Feminist Economics*, *Water Resources and Economics*.

## Why this paper replaces the original Paper 01

The original design (cooking fuel, laundry and sweeping technology, live-in help) needs the household questionnaire (Block 4), which the 2024 person-level file does not contain. It is retired to `defunct/legacy_papers/RETIRED_01_outsourcing_domestic_work_2024design/` (see `docs/AUDIT.md`). This paper uses only person-file variables: diary minutes by ICATUS code, sex, age, marital status, education, usual principal activity status, NIC industry, relation to head, sector, state, district, sub-round, diary day, type of day, weights, FSU, and household composition from the roster.

## Contribution in one line

Full-day diaries for every household member measure the water and fuel collection burden (ICATUS 242 and 241) by sex, age and sector, show how it is divided within households (household fixed effects; daughters-in-law vs daughters vs the head's spouse; whether another non-employed woman or an adolescent girl takes the load off the main married woman), and use within-district variation in the survey quarter as a shifter of collection need to account, through the 1,440-minute identity, for what seasonal collection displaces. (No "first" claim.)

## Analyses in the manuscript

- Part A: participation and minutes in water fetching and fuel gathering separately, by girls/boys 6-14 and 15-17, women/men 18+, rural/urban; share of all collection minutes done by female members and by girls under 18 (minute-weighted shares with FSU-clustered SEs); among households in which anyone collected, the share in which only female members collected.
- Part B: within-household female-male gap among members 10+ (household FE, age band and diary-day controls) with a district-FE comparison and a female x urban interaction; women's position (head's spouse, female head, daughter-in-law, daughter, head's mother/mother-in-law) with household FE, with and without age controls, and the daughter-in-law minus daughter contrast; the main married woman's own and others' collection with another non-employed adult woman, a girl 10-17 and a boy 10-17 present (girl minus boy reported).
- Part C: quarter profile of collection (rural, district FE); reduced form of all ten time-use categories on sub-round 2 within district for rural women, men and girls (sums to zero); 2SLS of nine displaced categories on collection minutes instrumented by sub-round x rural, with district-by-sector and sub-round FE (coefficients sum to minus one), cluster-robust first-stage F with iff() wording at F = 10 and at the Lee et al. (2022) 104.7 threshold; joint test of quarter x rural in men's and women's paid work (agricultural-seasonality threat); robustness: usual-status controls, excluding agricultural workers (NIC 01-03), non-employed women, state-by-quarter FE, self-reported diaries, normal days, unweighted.
- Girls: sibling-set FE gap in collection and learning for ages 10-17, with girl x sub-round 2 and girl x rural. Kept short to avoid overlap with Paper 06 (cited only generically as companion work).

## Before submitting

- [ ] Real-data run: `TUS_DTA=/path/TimeUse106PER.dta Rscript run_all.R 01`.
- [ ] Check `validation.txt`: diaries summing to 1,440 near 100%, `household_file` = "NONE", `code_scheme` = "nso" detected from marker codes, `n_districts` plausible.
- [ ] **Sub-round months.** The 2024 data dictionary does not state the months of each sub-round. The text takes them from the 2019 design document (January-March, April-June, July-September, October-December) and says so. Confirm against the 2024 survey documentation; if the calendar differs, change the designated high-need quarter (`hi` in the `sample` chunk) and the text in the Data section.
- [ ] Check that `sub_round` is in the panel and constant within FSU; check the share of districts with FSUs in more than one sub-round (identification of the within-district quarter effects needs it).
- [ ] **NIC code format.** The agricultural-worker check assumes a 2-digit NIC 2008 code (a 5-digit code is cut to 2 digits). Tabulate `nic` on the real file and confirm divisions 01-03 are agriculture, forestry and fishing.
- [ ] Look at the quarter profile figure. If the peak is not sub-round 2, the text says so automatically; decide whether to keep the a priori designation (recommended, to avoid choosing the quarter from the data) and say why.
- [ ] Read every `iff()` branch on real data (abstract, introduction, Sections 5 to 8, conclusion); the wording, including the weak-instrument language, follows the estimates.
- [ ] Check whether travel for own-use production (ICATUS 250) is common among collectors; if so, add it as a sensitivity outcome (collection plus 250).
- [ ] Choose the final title once the headline results are known.
- [ ] References entered from memory; NOT verified against sources. Verify every entry in `refs_local.bib` and every key used from `submission/references.bib` (authors, year, title, journal, volume, issue, pages) before submission, and check that the findings attributed to each work match the publication. In particular check: Meeks (2017) and Gross, Gunther and Schipper (2018) descriptions; Devoto et al. (2012) journal (entered as AEJ: Economic Policy); the Jal Jeevan Mission operational guidelines (title and year); WHO/UNICEF JMP (2017) title.
- [ ] Word count and abstract length against the journal's limits; World Development asks for highlights (3 to 5 bullets, 85 characters or fewer). Draft after the real run, e.g. "Women and girls do [X]% of water and fuel collection minutes in India".
- [ ] Remove the author footnote if the journal requires an anonymised manuscript.
- [ ] Data availability statement: microdata from MoSPI/NSO on request; code at the repository URL.

## Cover letter (draft)

> Dear Editor,
>
> I submit "Carrying the Household: Water and Fuel Collection, Intrahousehold Allocation and Seasonal Time Costs for Women and Girls in India" for consideration in *World Development*.
>
> India's Jal Jeevan Mission aims to bring a tap connection to every rural household, and one of its stated benefits is the time it would release for women and girls. The evidence on that time comes mostly from questions about who usually fetches water and how long a trip takes. I use the Time Use Survey 2024, which records a full-day diary for every household member aged six and above in a national sample, to measure water and fuel collection directly, to show how it is divided among the members of one household, and to account for what it displaces when seasonal need rises.
>
> The paper has three parts. The first measures participation and minutes by sex, age and sector, and the concentration of the work on women and girls at the household level. The second uses household fixed effects to compare female and male members, women in different positions in the household, and the main married woman's collection when another adult woman or an adolescent girl is present. The third uses the survey quarter as a shifter of collection need within districts, with urban areas as a comparison, and the 1,440-minute identity to show which activities absorb extra collection time. I treat the quarter as a shifter of need, not a randomised instrument, and report tests and checks for the main threat, agricultural seasonality.
>
> The paper speaks to the literature on water infrastructure and women's time allocation, to the evaluation of rural water and clean-cooking programmes, and to the study of intrahousehold allocation in patrilocal households.
>
> The manuscript is not under review elsewhere. Replication code is public; the microdata are available from the National Statistics Office.
>
> Sincerely,
> Preet Deep Singh
