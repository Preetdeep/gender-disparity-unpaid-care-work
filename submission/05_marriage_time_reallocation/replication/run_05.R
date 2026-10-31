# run_05.R -- one-command runner for the replication archive of paper 05.
#   TUS_DTA=/path/to/TimeUse106PER.dta Rscript run_05.R     # real data (obtain from microdata.gov.in)
#   TUS_SYNTHETIC=1 Rscript run_05.R                         # smoke test on FAKE data (meaningless numbers)
# Runs from the archive root. Writes results_05_headline.csv (headline coefficients with 95% CIs).
TUS_ROOT <- normalizePath(".")
source(file.path(TUS_ROOT, "R", "setup.R"))
if (TUS_SYNTHETIC && !file.exists(TUS_DTA)) {
  source(file.path(TUS_ROOT, "R", "make_synthetic_data.R"))
  dir.create(dirname(TUS_DTA), recursive = TRUE, showWarnings = FALSE)
  haven::write_dta(as.data.frame(make_synthetic(4000)), TUS_DTA)
}
message("Building person-day panel from ", TUS_DTA)
build_panel()
old <- setwd(file.path(TUS_ROOT, "submission", "05_marriage_time_reallocation"))
env <- new.env()
sys.source("analysis_05.R", envir = env)           # all models, tables and figures of the paper
setwd(old)
e <- env
hl <- function(label, x) data.frame(estimate = label, minutes = x$est, se = x$se,
                                    ci_low = x$est - 1.96 * x$se, ci_high = x$est + 1.96 * x$se)
res <- rbind(hl("Women: married minus never-married, unpaid domestic + care", e$k_uw),
             hl("Men: married minus never-married, unpaid domestic + care", e$k_um),
             hl("Pooled married x woman, unpaid", e$k_dd),
             hl("Linked couples: wife minus husband, unpaid", list(est = e$cg$est, se = e$cg$se)),
             hl("Married women: daughter-in-law minus no parent generation, unpaid", e$k_dil$unpaid))
print(res, digits = 4)
write.csv(res, file.path(TUS_ROOT, "results_05_headline.csv"), row.names = FALSE)
