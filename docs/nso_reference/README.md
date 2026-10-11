# NSO reference documents

Official, public documentation from the National Statistical Office (MoSPI). Note that it describes the **2019** round (Time Use in India 2019). The microdata used by the papers are from the **2024** round. `docs/DataDictionaryTimeUseSurvey.xlsx` follows the 2024 schedule.

| File | Content | Use |
|---|---|---|
| `TUS2019_Data_Layout_Sch10.6.xls` | Fixed-width layout of the raw text data, levels 01–05 (household, roster, household characteristics, member day, activities) | Field names and positions. Needed only if the raw `.txt` files are parsed instead of the `.dta` |
| `TUS2019_Sample_Design_and_Estimation.pdf` | Stratified two-stage design (FSU → household), sub-rounds, strata, multiplier (`MULT`) | Inference choices: FSU clustering, weights |
| `tus2019_official_tables/Table_*.xlsx` | All-India tables from the 2019 report: participation rates and minutes per participant and per person, by sex, sector and age | External benchmark for the pipeline, and the 2019 → 2024 comparison |

Two facts from these documents that the papers rely on:

1. NSO publishes estimates both from **major activities only** (which sum to 1,440 minutes) and from **all activities in each slot**. The panel's main measures are major-only; the `sec_*` columns add minor activities. Compare like with like when benchmarking.
2. 2019 round: 9,945 FSUs, 138,799 households and 447,250 persons aged 6+. The 2024 round has about 139,500 households, the count in the legacy papers, which points to the `.dta` in use being the 2024 file. Confirm this against the survey-year field when the file is loaded.
