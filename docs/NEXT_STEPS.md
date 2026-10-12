# Next steps (hand-off, 12 October 2026)

State of play:
- Pipeline (`R/`) is adapted to the real 2024 file (`TimeUse106PER.dta`): roster-only rows, under-6 counted from the roster,
  household size from the roster, roster SES proxies, diary-based care need, district FE, code-scheme detection.
  See `docs/STRATEGY_2024_FILE.md`.
- Papers 02, 04, 06 adapted to the real file and committed. Papers 03, 05, 07, 08 were being adapted by agents; the last
  checkpoint commit holds their in-progress state. Re-knit each on synthetic data (TUS_SYNTHETIC=1 TUS_SYNTH_HH=0) and fix.
- Paper 01: original design impossible (no fuel/laundry/sweeping mode in the file). Choose a redesign from the probe's
  FEASIBILITY COUNTS section: (a) paid domestic workers' double day (ICATUS 136, enterprise 8, NIC 97) or (b) water/fuel
  collection (ICATUS 241-242).

To do, in order:
1. Author: `git pull` in the local clone (~/gdw-papers), rerun `source("R/probe_data.R")`, send the new probe report
   (it must contain "FEASIBILITY COUNTS").
2. Finish 03/05/07/08 adaptation; decide and write Paper 01; manager audit; full synthetic run of `run_all.R`.
3. Synthetic generator: add a Sub_Round column so sub-round FE are exercised in tests.
4. Author runs `source("run_all.R")` on the real file; send `data/derived/validation.txt` and the 8 PDFs.
5. Wording pass on real results: titles, abstracts, discussions; verify all references.
