# Replication package: When Husbands Stop Working, Do Wives Start? Evidence from India's Urban Labour Force Panel

Code only. The PLFS unit-level data are distributed by MoSPI and are not included.

## Data (obtain from https://microdata.gov.in, MoSPI microdata portal)
| Round | Files used | Folder expected under `$PLFS_DIR` |
|---|---|---|
| PLFS July 2022-June 2023 (CSV release) | `perv1.csv`, `perrv.csv`, `hhv1.csv` | `d2223/Data_in_CSV/` |
| PLFS July 2023-June 2024 (CSV release) | `perv1.csv`, `perrv.csv`, `hhv1.csv` | `CSV_data_PLFS_2023_2024/` |
| PLFS July 2017-June 2018 (CSV release) | `hh_per_fv_2017-18.csv`, `hh_per_rv_2017-18.csv`, `hhfv_2017-18.csv` | `CSV_PLFS_July2017_June2018/` |
| PLFS calendar 2024 (CSV release), check only | `cperv1.csv` | `d2024/` |

The calendar-2024 file is read only to document that it holds first visits only and that its quarters 3-4 duplicate the 2023-24 first visits (Table S4); it is not used in estimation.

## Software
R 4.x with data.table, fixest, ggplot2, jsonlite. LaTeX (pdflatex) for the paper.

## Run
```
export PLFS_DIR=/path/to/plfs P12_ROOT=/path/to/P12   # P12_ROOT contains repo/ and derived/
Rscript repo/code/run_all.R > repo/output/run_log.txt 2>&1
python3 paper/build.py                                # assembles and compiles the LaTeX files
```
Runtime is about two minutes on a laptop-class machine.

## Scripts
- `00_config.R`: paths, CWS status codes, the calendar-quarter mapping, helpers.
- `01_build.R`: reads person files, keeps the urban panel, links revisits to first visits by person identifiers plus first-visit quarter (`cq1 = cq - visit + 1`), including across the 2022-23 and 2023-24 files; merges household variables; writes linkage diagnostics (`output/build_diagnostics.json`).
- `02_validate.R`: reproduces the 24 published CWS LFPR/WPR figures (MoSPI press note, 23 Sep 2024, Tables 4-5) and checks the calendar-2024 file.
- `03_analysis.R`: builds couples and consecutive-quarter transitions, estimates all models, writes `output/results.json`.
- `04_tables_figs.R`: writes every table (`output/tables/*.tex`) and Figure 1 from `results.json`.

## Map from exhibits to code
Table 1, 2, 3, 4 and Figure 1: `04_tables_figs.R` from `results.json` keys `desc`, `main`/`rep1718`, `layoff`/`het`, `entry_type`/`other_members`, `event`. Supplement Tables S1-S4: same script, from `build_diagnostics.json`, `validation.tsv`, `results.json` (`rob`, `event`, `attrition`) and `plfs2024_check.json`.

## Layoff-interpretation rule
The paper describes estimates as responses to job loss only if (i) the lead placebo has |t| < 1.96 and (ii) the stop coefficient for husbands who were regular salaried employees is positive with p < 0.05. This rule was written into the analysis code (`03_analysis.R`, `layoff`) together with the estimates; it was not registered before estimation, so the paper does not call it pre-specified. The project plan (PLAN.md) stated the looser criterion "associations around job loss unless the displacement subsample and placebos hold". In the 2022-24 data the rule fails: the regular-salaried cell has 4 wives entering after a stop (p = 0.403).
