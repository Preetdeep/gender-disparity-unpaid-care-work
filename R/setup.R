# =============================================================================
# setup.R -- the only file a manuscript sources.
#
#   TUS_ROOT <- normalizePath("../..")          # from submission/<paper>/
#   source(file.path(TUS_ROOT, "R", "setup.R"))
#   pd <- load_panel()                          # person-day panel
#
# Data location: set the environment variable TUS_DTA to the activity-level
# microdata file (TimeUse106PER.dta). Default: <repo>/data/TimeUse106PER.dta.
# Set TUS_SYNTHETIC=1 to run on the synthetic test file instead; every table,
# figure and PDF produced that way is stamped as synthetic.
# =============================================================================

if (!exists("TUS_ROOT")) {
  TUS_ROOT <- local({
    d <- normalizePath(getwd())
    while (!file.exists(file.path(d, "R", "setup.R")) && dirname(d) != d) d <- dirname(d)
    d
  })
}

suppressPackageStartupMessages({
  library(data.table)
  library(haven)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(fixest)
  library(knitr)
  library(kableExtra)
})

options(dplyr.summarise.inform = FALSE, scipen = 999,
        knitr.kable.NA = "", fixest_notes = FALSE)

TUS_SYNTHETIC <- identical(Sys.getenv("TUS_SYNTHETIC"), "1")
TUS_DTA <- if (TUS_SYNTHETIC) {
  file.path(TUS_ROOT, "data", "synthetic", "TimeUse106PER_synthetic.dta")
} else {
  Sys.getenv("TUS_DTA", file.path(TUS_ROOT, "data", "TimeUse106PER.dta"))
}
TUS_HH_DTA <- Sys.getenv("TUS_HH_DTA", "")   # optional household-characteristics file (Block 4)
TUS_DERIVED <- file.path(TUS_ROOT, "data", if (TUS_SYNTHETIC) "synthetic" else "derived")

source(file.path(TUS_ROOT, "R", "codes.R"))
source(file.path(TUS_ROOT, "R", "build_panel.R"))
source(file.path(TUS_ROOT, "R", "helpers.R"))

theme_set(theme_minimal(base_size = 10) +
            theme(panel.grid.minor = element_blank(),
                  legend.position = "bottom",
                  plot.caption = element_text(hjust = 0, size = 7)))
