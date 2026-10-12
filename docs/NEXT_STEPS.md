# Next steps (hand-off, 12 October 2026)

## State of play

- **Pipeline.** `R/` is adapted to the real 2024 file (`TimeUse106PER.dta`):
  - roster-only rows;
  - household size and children under 6 counted from the roster;
  - roster SES proxies;
  - diary-based care need;
  - district fixed effects;
  - code-scheme detection (nso).
  See `docs/STRATEGY_2024_FILE.md`.
- **Papers 02 to 08** are adapted to the real file and knit cleanly on synthetic data with no household variables (`TUS_SYNTHETIC=1 TUS_SYNTH_HH=0`).
- **Paper 01** is redesigned as water and fuel collection (`submission/01_water_fuel_collection`, *World Development*). The old technology design needed household Block 4 items, which the file lacks, so it was moved to `defunct/`. Collection codes 241 and 242 are diary codes, so the new design needs nothing absent from the file.
- **Latest probe.** The probe the author sent last (no `FEASIBILITY COUNTS` section) came from an older copy of `probe_data.R`. Its structural results match the earlier probe:
  - Survey_Year 2024;
  - 1,440-minute diaries for 100% of diarists;
  - nso code scheme;
  - district and sub-round present;
  - no household variables.

## To do, in order

1. **Author:**
   - Run `git pull` in `~/gdw-papers`.
   - Rerun `source("R/probe_data.R")` and send `docs/probe_report.txt`. It must contain `FEASIBILITY COUNTS`.
   - Run `source("run_all.R")` on the real file.
   - Send `data/derived/validation.txt` and the eight PDFs.
   - Step-by-step instructions are in `README.md`, under "Running on a Mac with RStudio".
2. **Numerical pass.**
   - Check `validation.txt`: spouse-link rate, under-6 counts, district count, absent-variable list.
   - Check every table for implausible values: zero variance, sample sizes, first-stage F.
   - Compare headline SDG 5.4.1 means with NSO's published 2024 figures.
3. **Wording pass.**
   - Titles, abstracts, discussions and highlights must follow the real estimates.
   - Re-read every `iff()` branch as rendered.
4. **References.** Verify every entry in `submission/references.bib` and each `refs_local.bib` against the source. None is verified yet.
5. **Submit** one paper per journal, following each `SUBMISSION.md`.

## Optional shared-code improvements (low priority)

- `hh_n_disabled`, and adult (18+) maximum education.
- `ses_label()`, `lincom()` and `and_list()` helpers.
- A map from state codes to state names.
- `fe()` support for interactions.
- A notes-escape option in `tab()`.
- A mother link for children.
