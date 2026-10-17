README -- replication archive for "Married and Never-Married Days: Marriage, Gender and the Full
Time Budget in India, 2024" (author identity withheld for double-blind review).

WHAT THIS ARCHIVE CONTAINS
  readme.txt                         this file
  meta_information.txt               data meta-information (source, licence, records, variables)
  run_05.R                           one-command runner (see HOW TO RUN)
  R/setup.R                          loads packages and the other R files
  R/codes.R                          ICATUS 2016 activity-code groups used to build the nine divisions
  R/build_panel.R                    builds the person-day panel from the activity-level microdata
  R/icatus_labels.R                  ICATUS 2016 division labels
  R/helpers.R                        formatting, estimation and table helpers
  R/make_synthetic_data.R            generates FAKE data with the same structure as the real file
  R/compare_2019.R                   harmonised 2019 vs 2024 comparison (needs the 2019 unit-level data;
                                     its aggregate output is supplied, see next line)
  submission/_common/tus_2019_2024_compare.csv
                                     aggregate 2019 vs 2024 coefficients (no unit records)
  submission/_common/preamble.tex    LaTeX preamble used when knitting the PDF
  submission/05_marriage_time_reallocation/analysis_05.R
                                     all analysis code of the paper, extracted from the manuscript
                                     source. Every chunk header is a comment that names the table or
                                     figure it produces (tab-decomp = Table 2, tab-selection = Table 3,
                                     tab-couple = Table 4, tab-desc = Table 1; fig-* and the other tab-*
                                     chunks produce the online-supplement items).
  sample_data/sample_synthetic_activity_records.csv
                                     small FAKE sample (same columns as the real file) so that readers
                                     can see the layout. It has no relation to real respondents.

DATA (NOT INCLUDED)
  India's Time Use Survey 2024 unit-level data are produced by the National Statistics Office (NSO),
  Ministry of Statistics and Programme Implementation, Government of India, and are distributed to
  registered users through microdata.gov.in (catalog 236) under the portal's terms of use, which do not
  allow redistribution. No microdata file is therefore included. meta_information.txt states how to
  obtain the files and which records and variables were used.

HOW TO RUN
  1. With the real data (after downloading it from the NSO portal):
       TUS_DTA=/path/to/TimeUse106PER.dta Rscript run_05.R
     Optional: TUS_HH_DTA=/path/to/household-file.dta if household characteristics are in a separate file.
  2. Smoke test without the restricted data (numbers are meaningless, outputs are watermarked):
       TUS_SYNTHETIC=1 Rscript run_05.R
  Run time: a few minutes for the real data on a laptop with 16 GB of memory. Tables 1-4 and the
  supplement tables are produced as LaTeX objects in the session; run_05.R prints the headline
  coefficients to the console and writes them to results_05_headline.csv.

SOFTWARE (versions used to produce the reported results)
  R 4.6.1 (2026-06-24); data.table 1.18.6.1; haven 2.5.5; dplyr 1.2.1; tidyr 1.3.2; ggplot2 4.0.3;
  fixest 0.14.2; knitr 1.52; kableExtra 1.4.1; rmarkdown 2.32. Open-source software only.

NOTES
  * Estimation: survey multipliers as weights, standard errors clustered on the first-stage unit (FSU).
    95% confidence intervals are estimate +/- 1.96 standard errors.
  * The results in the paper are computed at knit time from the microdata; no number is typed by hand.
  * The code will also be made public on acceptance and is available from the author on request.
