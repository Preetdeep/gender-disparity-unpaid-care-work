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
  say("\n== WHICH ROUND IS THIS FILE? ==")
  ref19 <- c(FSUs = 9945, Households = 138799, Persons_6plus = 447250)   # NSO, Time Use in India 2019, Table 1
  have <- c(FSUs = uniqueN(d$fsu), Households = uniqueN(d$hh_id), Persons_6plus = uniqueN(d$pid[d$age >= 6]))
  for (k in names(ref19)) say("%-14s file: %s   NSO 2019 report: %s   ratio: %.3f", k, format(have[[k]], big.mark = ","),
                              format(ref19[[k]], big.mark = ","), have[[k]] / ref19[[k]])
  close19 <- all(abs(have / ref19 - 1) < 0.01)
  say("%s", if (close19) "WARNING: counts match the 2019 round within 1%. This may be the 2019 file, not 2024."
            else "Counts differ from the 2019 round by more than 1% on at least one measure (consistent with a different round).")
  yr <- grep("year", names(hdr), ignore.case = TRUE, value = TRUE)
  if (length(yr)) { say("Survey-year column(s) found: %s", paste(yr, collapse = ", "))
    for (v in yr) say("%s:\n%s", v, tbl(haven::read_dta(TUS_DTA, col_select = dplyr::all_of(v))[[1]], 5)) }
  else say("No survey-year column in the file. Confirm the round from the file name, its folder and the counts above.")
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
  det <- detect_code_scheme(unique(d, by = "pid")$pas, unique(d, by = "pid")$cooking)
  say("\n== CODE SCHEME ==\nDetected: %s (%s)\nMarker evidence: %s", det$scheme,
      if (det$conflicting) "CONFLICT" else if (det$undetermined) "UNDETERMINED" else "clear",
      paste(names(det$evidence), det$evidence, sep = "=", collapse = ", "))
  say("Principal activity status (persons):\n%s", tbl(unique(d, by = "pid")$pas, 30))
  say("Cooking fuel (persons):\n%s", tbl(unique(d, by = "pid")$cooking, 30))
  if ("lighting" %in% names(d)) say("Lighting (persons):\n%s", tbl(unique(d, by = "pid")$lighting, 30))
  # ---- Feasibility counts for redesigned papers (persons, unweighted) ----
  say("\n== FEASIBILITY COUNTS (persons) ==")
  P1 <- unique(d, by = "pid")
  cnt <- function(lbl, ids) {
    g <- P1[pid %in% ids, .N, by = gender]
    say("%-62s total %8s | men %7s | women %7s", lbl, format(length(unique(ids)), big.mark = ","),
        format(sum(g[gender == 1]$N), big.mark = ","), format(sum(g[gender == 2]$N), big.mark = ","))
  }
  mj <- d[!is.na(act3) & major == 1]
  cnt("Did paid domestic services (ICATUS 136) on diary day", mj[act3 == 136, unique(pid)])
  if ("nic" %in% names(d)) cnt("Industry NIC 97 (households as employers of domestic staff)", P1[nic == 97, pid])
  if ("enterprise" %in% names(d)) cnt("Worked for an employer's household (enterprise type 8)", d[enterprise == 8, unique(pid)])
  cnt("Fetched water (242) on diary day", mj[act3 == 242, unique(pid)])
  cnt("Gathered firewood/fuel (241) on diary day", mj[act3 == 241, unique(pid)])
  cnt("Received personal/health care from others (941-949)", mj[act3 >= 941 & act3 <= 949, unique(pid)])
  cnt("Gave care to a dependent adult (421-429, 443)", mj[(act3 >= 421 & act3 <= 429) | act3 == 443, unique(pid)])
  cnt("Usual status: not able to work owing to disability (code 95)", P1[pas == 95, pid])
  cnt("Aged 80 or above", P1[age >= 80, pid])
  cnt("Live-in non-relative (relationship code 9)", P1[rel == 9, pid])
  if ("district" %in% names(d)) say("Districts (state x district): %s", format(uniqueN(P1[, paste(state, district)]), big.mark = ","))
  for (v in intersect(c("sector", "marital", "rel", "dow", "special_care", "caregiver", "cooking", "washing",
                        "sweeping", "religion", "social_group", "sub_round"), names(d)))
    say("%s (persons):\n%s", v, tbl(unique(d, by = "pid")[[v]], 12))
  if ("hh_size" %in% names(d)) {
    p <- unique(d, by = "pid"); p[, diar := .N, by = hh_id]
    say("Households where household size < number of diarists: %.2f%%", 100 * mean(p$hh_size < p$diar, na.rm = TRUE))
  }
  say("Survey year field present: %s", any(grepl("year", names(hdr), ignore.case = TRUE)))
}
# ---- Optional household file ----------------------------------------------------
if (nzchar(TUS_HH_DTA) && file.exists(TUS_HH_DTA)) {
  say("\n\n== HOUSEHOLD FILE: %s (%.2f GB) ==", basename(TUS_HH_DTA), file.size(TUS_HH_DTA) / 1e9)
  hh <- read_household_file(TUS_HH_DTA)
  hdrh <- if (grepl("\\.csv$", TUS_HH_DTA, ignore.case = TRUE)) as.data.frame(hh$data[0]) else haven::read_dta(TUS_HH_DTA, n_max = 5)
  say("Columns: %d   Rows: %s", ncol(hdrh), format(nrow(hh$data), big.mark = ","))
  for (v in names(hdrh)) { lab <- attr(hdrh[[v]], "label"); say("%-34s %-10s %s", v, class(hdrh[[v]])[1], if (is.null(lab)) "" else lab) }
  say("\nMatched concepts:")
  for (k in names(hh$col)) say("%-14s -> %s", k, ifelse(is.na(hh$col[k]), "(not found)", hh$col[k]))
  for (k in c("hh_size", "religion", "social_group", "cooking", "lighting", "washing", "sweeping", "special_care", "caregiver", "dwelling")) {
    v <- hh$col[k]; if (!is.na(v)) say("%s (%s):\n%s", k, v, tbl(hh$data[[v]], 15))
  }
  v <- hh$col["umpce"]
  if (!is.na(v)) say("umpce (%s): summary\n%s", v, paste(utils::capture.output(print(summary(as_num(hh$data[[v]])))), collapse = "\n"))
} else say("\n\nNo household file supplied (TUS_HH_DTA is empty). Household characteristics are NOT in the person file.")

f <- file.path(TUS_ROOT, "docs", "probe_report.txt")
writeLines(out, f); cat(out, sep = "\n"); message("\nWritten to ", f)
