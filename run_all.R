# =============================================================================
# run_all.R -- build the person-day panel and knit the submission manuscripts.
#
#   TUS_DTA=/path/to/TimeUse106PER.dta Rscript run_all.R          # all papers
#   TUS_DTA=/path/to/TimeUse106PER.dta Rscript run_all.R 01 05    # selected
#   TUS_SYNTHETIC=1 Rscript run_all.R                             # smoke test
#
# PDFs are written next to each manuscript (submission/<paper>/manuscript.pdf).
# Synthetic-data PDFs go to data/synthetic/pdf/ and are watermarked.
# =============================================================================
TUS_ROOT <- normalizePath(".")
source(file.path(TUS_ROOT, "R", "setup.R"))
args <- commandArgs(trailingOnly = TRUE)

if (TUS_SYNTHETIC && !file.exists(TUS_DTA)) {
  source(file.path(TUS_ROOT, "R", "make_synthetic_data.R"))
  d <- make_synthetic(4000)
  dir.create(dirname(TUS_DTA), recursive = TRUE, showWarnings = FALSE)
  haven::write_dta(as.data.frame(d), TUS_DTA)
}
message("Building person-day panel from ", TUS_DTA)
build_panel()

papers <- sort(list.dirs(file.path(TUS_ROOT, "submission"), recursive = FALSE, full.names = TRUE))
papers <- papers[grepl("^[0-9]{2}_", basename(papers))]
if (length(args)) papers <- papers[substr(basename(papers), 1, 2) %in% args]

status <- sapply(papers, function(p) {
  out <- if (TUS_SYNTHETIC) file.path(TUS_ROOT, "data", "synthetic", "pdf", basename(p)) else p
  tmp <- file.path(tempdir(), basename(p))
  ok <- tryCatch({
    rmarkdown::render(file.path(p, "manuscript.Rmd"), output_dir = out, intermediates_dir = tmp,
                      knit_root_dir = p, envir = new.env(), quiet = TRUE)
    TRUE
  }, error = function(e) { message(basename(p), ": ", conditionMessage(e)); FALSE })
  message(sprintf("%-40s %s", basename(p), if (ok) "OK" else "FAILED"))
  ok
})
if (!all(status)) quit(status = 1)
