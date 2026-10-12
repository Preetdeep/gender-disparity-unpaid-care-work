# Audit of the legacy papers (October 2026)

Scope: the 73 R Markdown files (about 37 distinct papers) that sat in the repository root, plus their PDFs, HTML files and process memos. All of them now live in `defunct/`. I read the code, the dictionary (`docs/DataDictionaryTimeUseSurvey.xlsx`) and the PDF output that was knitted on the real microdata. The real `.dta` file is not in this repository, so this audit identifies errors from code and from real-data output already in the PDFs. It does not re-estimate anything.

**Verdict: no legacy number can be cited.** Three bugs run through almost every paper. Each one alone invalidates the published estimates. The text built on those estimates (titles, abstracts, mechanisms, policy claims) is invalid with them.

---

## 1. Systemic error A: 10% sample of activity rows

63 of 73 files run `slice_sample(prop = 0.1)` on the activity-level file and then multiply weights by 10.

The file has one row per activity record, about 21 major records per person-day (10.2 million rows, about 450,000 diarists). A random 10% of rows keeps about 2 records per person. `master_descriptive_statistics.pdf` confirms this on the real data: "Unique Individuals 394,405. Average observations per person 2.1."

Consequences:

* Every per-person daily quantity (minutes of care, sleep, leisure; "any participation today") is computed from a random tenth of the diary. Minutes per day are understated about tenfold. Participation is badly understated, and it is understated by different amounts for people with many short episodes versus few long ones. This is why the papers report effects of "0.04 minutes (2 to 3 seconds)" (weekend), "0.3 minutes" (son preference) and "+0.05 minutes" (grandparents).
* Household composition built from the sample (who lives with whom, number of children, presence of grandparents or servants) misses about 90% of members' records, so a member with no sampled row disappears.
* Reweighting by 1/0.1 restores population totals, not person-level distributions.

Fix: `R/build_panel.R` reads every row. Optional subsampling is by household, never by row.

## 2. Systemic error B: activity codes mapped wrongly

The microdata's 2-digit code is the first two digits of the ICATUS 2016 3-digit code. The real-data PDF confirms it: 2-digit 91 has a mean episode of 222 minutes, which is night sleep (911), not "personal hygiene" as the legacy label says. The legacy papers used an invented 2-digit scheme. The correct meanings, from the dictionary:

| Legacy code and meaning assumed | What the code actually is | Papers affected |
|---|---|---|
| 31 = childcare | Food and meals (cooking, serving, cleaning up) | childcare_vs_eldercare, son_preference, servant_paradox, class_gradient, third_shift (original), income_religion, gender_disparity (supplementary) |
| 32 = adult/elder care | Cleaning and upkeep of dwelling | childcare_vs_eldercare, servant_paradox, third_shift (original), income_religion |
| 33 = cooking/cleaning or "non-household care" | DIY decoration, maintenance and repair | class_gradient, servant_paradox, third_shift (both versions), income_religion, gender_disparity, sleep_penalty |
| 34 = shopping | Care of textiles and footwear (laundry) | shopping_mental_load, servant_paradox, class_gradient, third_shift (both versions) |
| 35 = household management | Household management (correct) | |
| 36 = household administration | Pet care | third_shift (corrected version) |
| 37 to 39 | Shopping (37), domestic travel (38), other (39): omitted from "domestic work" everywhere | class_gradient, urban_progressive, income_religion |
| 41, 42 | Childcare, dependent-adult care (correct only in third_shift corrected, grandparent, eating, simultaneous) | |
| 71 = physical exercise | Socialising and communication (talking, getting together) | exercise_marriage_premium, widowhood_exercise, master_descriptives |
| 81 = in-person socialising, 82 = remote socialising | Attending cultural events (81); hobbies and games (82) | digital_socializing (whole paper) |
| 81 to 89 = social life | Culture, leisure, mass media (incl. TV, 84), sports, resting (85) | friendship_penalty, master_descriptives |
| 1 = sleep | Does not exist (sleep is 91), so sleep minutes are always 0 | sleep_penalty |
| 9 = religion | Does not exist (religion is 74); the PDF shows 0 observations | master_descriptives |
| 21 to 29 = education | Own-use production of goods (farming, water, fuel) | master_descriptives |
| 3-digit 312 to 314 = food preparation | Excludes 311 "preparing meals", the main cooking code | technology_time_paradox |
| 3-digit 331 = laundry, 341 = shopping | DIY repair (331); hand/machine washing (341) | technology_time_paradox |

So "childcare" in five papers was cooking time, "exercise" in two was conversation time, "friendship" was mostly television, "remote socialising" was hobbies, and "sleep" was zero. The `CRITICAL_BUG_REPORT_THIRD_SHIFT.md` "fix" corrected 41 and 42 but introduced new errors (33 = laundry, 34 = shopping, 36 = administration).

Fix: `R/codes.R` defines every category once, from the dictionary, and checks at load time that the categories partition all 165 dictionary codes exactly.

## 3. Systemic error C: wrong unit of analysis

Most papers compute `weighted.mean(indicator, Weight)` over activity rows. "Participation of 4.7%" (weekend paper) is the share of activity records that are care records, not the share of people who did care. "Conditional on participation, men and women spend 50.7 vs 47.4 minutes" (participation puzzle) is the mean length of a single episode, not minutes per day among doers. The headline finding of the participation-puzzle paper, and the claim in marriage_care_penalty of "no gender difference in intensity", are artifacts of this.

Person identifiers are also wrong in places. `gender_disparity_*` builds `person_id = FSU + HH + Gender + Age`, which merges same-sex, same-age household members, and reports "households" as `unique(FSU_Serial_No)`, which counts FSUs, not households.

Fix: one row per person-day. Minutes come from major activities only, and every diary sums to 1,440. The person key is FSU x household x person serial.

## 4. Other code errors

| Error | Where | Consequence |
|---|---|---|
| Major/minor flag tested as `== 0`; the dictionary codes minor as 2 | eating_while_working | Concluded "no secondary eating in the data". The real PDF shows about 12,000 eating records that are neither 1 nor 0, i.e. minor records exist |
| `Unpaid_Paid_Status == "02"` compared as a string | gender_disparity, marriage_care_penalty, weekend | If the column is numeric, `2 == "02"` is FALSE in R and care is identically 0 |
| Text says status 02 "includes housework, meal preparation, and shopping" | marriage_care_penalty | Wrong: status 2 is care for persons; domestic services are status 3 |
| "Employed" includes status 51 (unemployed) | digital_socializing verification script | Misclassifies job seekers |
| Children aged 0 to 5 counted from the diary file | child_penalty, first_child_shock, golden_years, others | Diaries are kept only by members aged 6+. "Has child 0 to 5" is (near) always 0. The new pipeline recovers under-6 members as household size minus diarists |
| Grandparents defined only as `Relationship_to_Head == 7` | grandparent_care_economy | Misses the dominant patrilocal case: when the mother is the head's daughter-in-law (rel 4), the grandparents are the head and spouse (rel 1, 2) |
| "Household help" = live-in servant (rel 9, 0.08% of persons) | working_women_third_shift | Misses non-resident domestic workers. The data have better outsourcing measures (`type_of_washing`, `type_of_sweeping` = 3 "by outsourcing") that no paper used |
| "Household help and consumption are not available" | servant_paradox | False: relationship code 9, outsourcing variables and UMPCE (item 10) are in the dictionary |
| `cleaning = Activity_Code_2Digit %in% c(311, 312)` | servant_paradox | A 2-digit code is never 311, so cleaning is identically 0 |
| Household size column assumed `Household_Size`; the real file has no such column (PDF: "No household size column found") | many | Silent NA or crash |
| Mixed names `Day_of_Week` / `Day_Of_Week`, `Relationship_to_Head` / `Relation_to_Head` / `Rel_to_Head` | many | Crashes or silently missing variables. The new resolver maps every concept to the real column once |
| No clustering, or clustering on households after row sampling | most | SEs too small. The new standard clusters on FSU (the PSU) |

## 5. Contradictions across papers and memos

1. **Survey year.** Some abstracts were edited to "2019" (shopping_mental_load still says "2019 Time Use Survey" while citing 2024 sample sizes); the rest say 2024. Fact: the microdata are TUS January to December 2024, NSO, released 2025. The 2019 TUS is a separate round.
2. **Sample size.** "10.2 million person-day observations" (these are activity records), "approximately 1 million person-day observations", "840,000", "836,000 from 9,969 households" (9,969 is the FSU count, not households), "8.4 million observations from 394,405 individuals", and "1.4 million households" (REPLICATION_README) against 139,489 households elsewhere. Correct framing: about 10.2 million activity records, about 450,000 person-day diaries, about 139,500 households.
3. **Friendship penalty.** The status memo says women -52%, men -23%, 0.8 vs 3.2 minutes; the paper says -42%, -18%, and 45%. Neither measures social time (see Section 2).
4. **Childcare vs eldercare.** The memo says "men do 22% of childcare but 8% of elder care, 58 vs 16 minutes"; the paper says a 3.5 pp and 0.9 pp gap. Both measure cooking and cleaning.
5. **Who multitasks.** simultaneous_activities finds men multitask more; eating_while_working and multitasking_penalty argue women's time is the fragmented one. The eating paper also says secondary activities are unobservable; the multitasking paper uses them.
6. **Household help.** servant_paradox says household help is not observable; working_women_third_shift says it is "directly observed".
7. **Class gradient.** class_gradient says the "richer is more unequal" pattern is a statistical illusion; servant_paradox and third_shift build mechanisms ("management penalty", "third shift") on the same miscoded categories.
8. **Exercise.** exercise_marriage_premium finds marriage lowers exercise; widowhood_exercise finds widowhood raises it. Both measure socialising (code 71).
9. **Quality memos vs reality.** `PAPER_QUALITY_REPORT.md` scored papers 90 to 98/100, "submit to top journal immediately". Those reviews checked structure and prose, never codes, units or sampling.

## 6. Literature and citations

The legacy bibliographies contain citations I could not verify and at least one impossibility ("Chakraborty et al. (2018) updated this analysis with 2019 data"). Others ("Raj et al. 2020", "Desai and Joshi 2019", "IHDS 2018: only 2% of children under 6 attend childcare") do not match works I can confirm. Treat every legacy reference as unverified. The new manuscripts cite only from `submission/references.bib`, a curated list of standard works. **Check each entry against the published source before submission.**

## 7. Salami slicing

Fourteen papers were the same regression ("personal well-being minutes on X") with X = children, first child, age, retirement, education, employment, urban, household size, commute, religion, caste, sandwich status, weekend, demographics. Five more were "marriage and Y" for Y in {care, sleep, friendship, exercise, widowhood}. Editors desk-reject this pattern, and a referee who finds two of them will question all of them. They are consolidated below.

---

## 8. Disposition of every legacy paper

Ranking is by expected publishability once re-estimated: novelty of the question, credibility of the design in a single cross-section, and policy weight.

| Rank | Submission paper (`submission/`) | Legacy papers merged into it (`defunct/legacy_papers/`) | Why it can work now |
|---|---|---|---|
| 1 | `01_outsourcing_domestic_work`: machines, maids and money | technology_time_paradox, servant_paradox, working_women_third_shift, class_gradient_equality, urban_progressive_rhetoric, shopping_mental_load | Direct household measures of outsourced washing and sweeping, clean cooking fuel and live-in workers, plus consumption. Task-level ICATUS outcomes. LPG (Ujjwala) is a live policy question |
| 2 | `02_grandparent_care`: do co-resident grandparents lighten mothers' care load? | grandparent_care_economy | Correct three-generation identification (both rel 7 and rel 1/2 above rel 3/4). Grandparents' own diaries show who actually substitutes |
| 3 | `03_care_need`: childcare vs dependent-adult care | childcare_vs_eldercare, eldercare_sandwich_generation | Correct codes (41x vs 42x). Conditions on need using the survey's own "member needing special care" and "caregiver available" questions, which fixes the legacy paper's stated "critical limitation" |
| 4 | `04_multitasking_secondary_care`: hidden care in secondary activities | simultaneous_activities, eating_while_working, multitasking_penalty | Minor-activity records exist (flag = 2). Secondary childcare and eating-while-working are measurable through slot pairing |
| 5 | `05_marriage_time_reallocation`: where women's extra unpaid minutes come from | marriage_care_penalty, sleep_penalty, friendship_penalty, exercise_marriage_premium, widowhood_exercise | A 1,440-minute accounting identity turns five slices into one decomposition; spouse links give within-couple gaps |
| 6 | `06_son_preference_time`: child sex composition and mothers' time | son_preference_care | Correct childcare codes; own children linked to mothers through the roster; sex-composition design with fertility-stopping caveats |
| 7 | `07_weekend_care_division`: Sundays and the gendered division of care | weekend_effect, weekend_effect_wellbeing | The diary day (day before interview) varies across households; within-week contrasts by spouse's employment |
| 8 | `08_life_course_free_time`: free time over the life course | child_penalty_personal_time, first_child_shock, golden_years, retirement_dividend, education_wellbeing, employment_wellbeing, optimal_demographics, urban_rural_wellbeing, household_size_penalty, commuting_cost, religion_personal_time, caste_personal_time | One descriptive paper on the free-time gap by life stage, with the other dimensions as heterogeneity |

Retired (kept in `defunct/legacy_papers/RETIRED_*` for the record):

| Legacy paper | Reason |
|---|---|
| digital_socializing (3 versions + verification script + plan) | Infeasible. ICATUS 2016 as fielded has no in-person vs remote socialising split; the paper compared cultural-event attendance (81) with hobbies (82) |
| gender_disparity_clean / _enhanced (participation puzzle) | The headline is an artifact of per-episode means (Section 3), and the descriptive gender-gap paper already exists as "The Domestic Anchor" in your India-TUS project. A second one would compete with it |
| income_religion_region_intersectionality | Built on miscoded categories; its question (structure vs culture) overlaps paper 08. Revive later as a variance-decomposition note if paper 08 lands |
| master_descriptive_statistics | Replaced by `R/build_panel.R` validation output and each paper's descriptive table. Its activity labels were wrong |
| 01_outsourcing_domestic_work (2024 design; now `RETIRED_01_outsourcing_domestic_work_2024design`) | Infeasible on the real 2024 file: cooking fuel, laundry/sweeping mode and consumption are household-questionnaire (Block 4) items absent from the person file. Replaced by `submission/01_water_fuel_collection` (ICATUS 241/242, intrahousehold allocation, sub-round seasonality) |

Process memos (critiques, status reports, quality scores, plans) are in `defunct/notes/`. They describe the legacy code and should not guide new work.
