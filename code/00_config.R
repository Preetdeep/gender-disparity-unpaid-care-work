## P12 configuration: paths, status codes, helpers. Real PLFS unit data only.
suppressPackageStartupMessages({library(data.table); library(fixest); library(ggplot2); library(jsonlite)})
ROOT    <- Sys.getenv("P12_ROOT", "/workspace/papers/P12")
REPO    <- file.path(ROOT, "repo"); OUT <- file.path(REPO, "output")
DERIVED <- Sys.getenv("P12_DERIVED", file.path(ROOT, "derived"))
TABLES  <- file.path(OUT, "tables"); FIGURES <- file.path(OUT, "figures")
for (d in c(DERIVED, TABLES, FIGURES)) dir.create(d, recursive = TRUE, showWarnings = FALSE)
PLFS <- Sys.getenv("PLFS_DIR", "/workspace/plfs")
## Calendar-quarter index cq: 2022-23 files label Jul-Sep 2022 as Q5 (panel numbering), so cq = qtr - 4 (1..4);
## 2023-24 labels Q1..Q4, cq = qtr + 4 (5..8). In 2017-18 revisit files the quarter label runs one ahead of the
## first-visit label (empirical lag = visit number), so revisits get q0rv = q0 - 1. Verified in 01_build diagnostics.
YEARS <- list(
  `2022-23` = list(dir = file.path(PLFS, "d2223/Data_in_CSV"), files = c(v1 = "perv1.csv", rv = "perrv.csv", h1 = "hhv1.csv"), layout = "2324", q0 = -4L, q0rv = -4L),
  `2023-24` = list(dir = file.path(PLFS, "CSV_data_PLFS_2023_2024"), files = c(v1 = "perv1.csv", rv = "perrv.csv", h1 = "hhv1.csv"), layout = "2324", q0 = 4L, q0rv = 4L),
  `2017-18` = list(dir = file.path(PLFS, "CSV_PLFS_July2017_June2018"), files = c(v1 = "hh_per_fv_2017-18.csv", rv = "hh_per_rv_2017-18.csv", h1 = "hhfv_2017-18.csv"), layout = "1718", q0 = 100L, q0rv = 99L)
)
EMP  <- c(11, 12, 21, 31, 41, 42, 51, 61, 62, 71, 72)   # CWS employed
LF   <- c(EMP, 81, 82)                                   # CWS labour force
num  <- function(x) suppressWarnings(as.numeric(as.character(x)))
wmean <- function(x, w) { ok <- is.finite(x) & is.finite(w); sum(x[ok] * w[ok]) / sum(w[ok]) }
jobtype <- function(s) fcase(s %in% c(11, 12, 61, 62), "self", s == 21, "helper", s %in% c(31, 71, 72), "regular",
                             s %in% c(41, 42, 51), "casual", s %in% c(81, 82), "unemployed", default = "out")
