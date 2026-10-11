# =============================================================================
# probe_data.R -- first look at the microdata. Writes docs/probe_report.txt.
#
#   TUS_DTA=/path/TimeUse106PER.dta Rscript R/probe_data.R
#
# The report holds column names, labels, row/person/household counts and small
# frequency tables. It contains NO microdata rows, so it is safe to paste or
# commit. Send it back so column mapping (TUS_COLS in R/build_panel.R) can be
# fixed before the full run.
# =============================================================================
TUS_ROOT <- local({
  d <- normalizePath(getwd())
  while (!file.exists(file.path(d, "R", "setup.R")) && dirname(d) != d) d <- dirname(d)
  d
})
source(file.path(TUS_ROOT, "R", "setup.R"))
stopifnot(file.exists(TUS_DTA))

out <- character()
say <- function(...) out <<- c(out, sprintf(...))
tbl <- function(x, n = 15) {
  t <- sort(table(x, useNA = "ifany"), decreasing = TRUE)
  paste(utils::capture.output(print(head(t, n))), collapse = "\n")
}

hdr <- haven::read_dta(TUS_DTA, n_max = 5)
say("File: %s  (%.2f GB)", basename(TUS_DTA), file.size(TUS_DTA) / 1e9)
say("Columns: %d", ncol(hdr))
say("\n== Column names, types, labels ==")
for (v in names(hdr)) {
  lab <- attr(hdr[[v]], "label"); if (is.null(lab)) lab <- ""
  say("%-32s %-10s %s", v, class(hdr[[v]])[1], lab)
}

col <- tryCatch(resolve_columns(names(hdr)), error = function(e) { say("\nRESOLVE FAILED: %s", conditionMessage(e)); NULL })
if (!is.null(col)) {
  say("\n== Resolved concepts ==")
  for (k in names(col)) say("%-14s -> %s", k, ifelse(is.na(col[k]), "(not found)", col[k]))
  keep <- unname(col[!is.na(col)])
  d <- data.table::as.data.table(haven::read_dta(TUS_DTA, col_select = dplyr::all_of(keep)))
  data.table::setnames(d, keep, names(col)[!is.na(col)])
  for (v in names(d)) if (v != "time_from") d[, (v) := as_num(get(v))]
  say("\n== Size ==")
  say("Activity records: %s", format(nrow(d), big.mark = ","))
  d[, hh_id := paste(fsu, hh, sep = "_")][, pid := paste(hh_id, person, sep = "_")]
  say("FSUs: %s  Households: %s  Persons: %s", format(uniqueN(d$fsu), big.mark = ","),
      format(uniqueN(d$hh_id), big.mark = ","), format(uniqueN(d$pid), big.mark = ","))
  say("Records per person: median %.0f, mean %.1f", median(d[, .N, by = pid]$N), mean(d[, .N, by = pid]$N))
  say("\n== Key checks ==")
  say("Major flag values:\n%s", tbl(d$major))
  say("Gender:\n%s", tbl(d$gender))
  say("Age range: %s to %s", min(d$age, na.rm = TRUE), max(d$age, na.rm = TRUE))
  say("Weight: min %.2f  median %.2f  max %.2f  (NA: %d)", min(d$weight, na.rm = TRUE),
      median(d$weight, na.rm = TRUE), max(d$weight, na.rm = TRUE), sum(is.na(d$weight)))
  say("Persons whose weight varies across rows: %.2f%%", 100 * mean(d[, .(s = sd(weight)), by = pid]$s > 1e-8, na.rm = TRUE))
  say("time_spent: min %s  median %s  max %s", min(d$time, na.rm = TRUE), median(d$time, na.rm = TRUE), max(d$time, na.rm = TRUE))
  mj <- d[major == 1 | major == CODE$major_minor["major"]]
  tot <- mj[, .(m = sum(time, na.rm = TRUE)), by = pid]$m
  say("Persons whose major-activity minutes sum to 1440: %.1f%%", 100 * mean(abs(tot - 1440) < 1e-6))
  say("Invalid 3-digit codes (not in dictionary): %s",
      paste(setdiff(unique(d$act3), as.integer(names(icatus_labels))), collapse = ", "))
  if ("act2" %in% names(d)) say("2-digit = floor(3-digit/10): %.2f%%", 100 * mean(floor(d$act3 / 10) == d$act2, na.rm = TRUE))
  for (v in intersect(c("multiple", "simult", "location", "paid_status", "enterprise"), names(d)))
    say("%s (activity records):\n%s", v, tbl(d[[v]], 12))
  for (v in intersect(c("sector", "marital", "rel", "dow", "special_care", "caregiver", "cooking", "washing",
                        "sweeping", "religion", "social_group", "sub_round"), names(d)))
    say("%s (persons):\n%s", v, tbl(unique(d, by = "pid")[[v]], 12))
  if ("hh_size" %in% names(d)) {
    p <- unique(d, by = "pid"); p[, diar := .N, by = hh_id]
    say("Households where household size < number of diarists: %.2f%%", 100 * mean(p$hh_size < p$diar, na.rm = TRUE))
  }
  say("Survey year field present: %s", any(grepl("year", names(hdr), ignore.case = TRUE)))
}
f <- file.path(TUS_ROOT, "docs", "probe_report.txt")
writeLines(out, f); cat(out, sep = "\n"); message("\nWritten to ", f)
