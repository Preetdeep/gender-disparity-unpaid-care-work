# =============================================================================
# build_panel_2019.R -- TUS 2019 unit-level data -> person-day panel harmonised
# with the TUS 2024 panel built by build_panel.R.
#
# Input: the five data levels of the NSO TUS 2019 release (Nesstar file
# DDI-IND-CSO-TUS-2019-19_r), extracted once to .rds outside the repository
# (TUS2019_DIR, default ~/GResearcher_runs/tus2019/ds{2,3,4,6}.rds) with the
# open-source nesstarR reader. Nothing here writes unit-level rows into the repo:
# the output goes to data/derived/ (git-ignored).
#
#   ds2 = Block 3, demographic particulars (all members, any age)
#   ds3 = Block 4, household characteristics
#   ds4 = Block 5, diary-day particulars (day of week, type of day, informant)
#   ds6 = Block 6, time disposition: one row per activity in each time slot
#
# Same rules as 2024: MAJOR activity of each slot only (b6q9 == 1), so each diary
# sums to 1,440 minutes; ICATUS 2016 categories from codes.R (the 2019 and 2024
# releases use the identical set of 3-digit codes); persons identified by FSU x
# household x person serial number; survey weights (MULT); FSU clusters.
# =============================================================================

build_panel_2019 <- function(dir = Sys.getenv("TUS2019_DIR", path.expand("~/GResearcher_runs/tus2019")),
                             out = file.path(TUS_DERIVED, "person_day_2019.rds")) {
  rd <- function(i) data.table::as.data.table(readRDS(file.path(dir, sprintf("ds%d.rds", i))))
  num <- function(x) suppressWarnings(as.numeric(trimws(as.character(x))))
  V <- list(source = "TUS 2019 (NSO), Nesstar release DDI-IND-CSO-TUS-2019-19_r", built = format(Sys.time()))

  # ---- Activities (Block 6) --------------------------------------------------
  a <- rd(6)[, .(fsu = trimws(fsu), hh = trimws(b1q4), person = trimws(b6q1),
                 from = b6q4, to = b6q5, major = trimws(b6q9), act3 = num(b6q10))]
  V$n_activity_rows <- nrow(a)
  V$major_flag_values <- sort(unique(a$major))
  tm <- function(s) (as.integer(substr(s, 1, 2)) * 60 + as.integer(substr(s, 4, 5)) - 240) %% 1440
  a[, `:=`(t0 = tm(from), t1 = tm(to))]
  a[t1 == 0, t1 := 1440]
  a[, time := t1 - t0]
  a[, pid := paste(fsu, hh, person, sep = "_")]
  V$invalid_act3_codes <- setdiff(unique(a$act3), as.integer(names(icatus_labels)))
  mj <- a[major == "1"]
  agg <- mj[, .(m = sum(time)), by = .(pid, act3)]
  pdy <- data.table::data.table(pid = unique(a$pid))
  for (k in names(ACT)) {
    s <- agg[act3 %in% ACT[[k]], .(v = sum(m)), by = pid]
    pdy[s, on = "pid", (k) := i.v]
    pdy[is.na(get(k)), (k) := 0]
  }
  tot <- agg[, .(day_total = sum(m)), by = pid]
  pdy[tot, on = "pid", day_total := i.day_total]
  # Minor (secondary) childcare, kept for a robustness check only.
  s <- a[major != "1" & act3 %in% ACT$care_child, .(v = sum(time)), by = pid]
  pdy[s, on = "pid", sec_care_child := i.v]; pdy[is.na(sec_care_child), sec_care_child := 0]
  rm(a, mj, agg); invisible(gc())

  # ---- Persons (Block 3), all ages --------------------------------------------
  p <- rd(2)[, .(fsu = trimws(fsu), hh = trimws(b1q4), person = trimws(b3q1),
                 rel = num(b3q3), gender = num(b3q4), age = num(b3q5), marital = num(b3q6),
                 edu = num(b3q7), pas = num(b3q8), sector = num(sector),
                 state = as.integer(substr(trimws(nss_region), 1, 2)), district = trimws(district),
                 stratum = trimws(stratum), sub_round = num(subround), weight = num(mult))]
  p[, `:=`(hh_id = paste(fsu, hh, sep = "_"), pid = paste(fsu, hh, person, sep = "_"))]
  V$n_roster <- nrow(p); V$n_roster_6plus <- sum(p$age >= 6, na.rm = TRUE)
  hhc <- p[, .(hh_n_under6 = sum(age < 6, na.rm = TRUE), hh_n_roster = .N,
               hh_n_60plus = sum(age >= 60, na.rm = TRUE),
               hh_n_women_15plus = sum(gender == 2 & age >= 15, na.rm = TRUE)), by = hh_id]
  # ---- Diary day (Block 5) ------------------------------------------------------
  d <- rd(4)[, .(pid = paste(trimws(fsu), trimws(b1q4), trimws(b5q1), sep = "_"),
                 dow = num(b5q5), type_day = num(b5q6), informant_rel = num(b5q4))]
  d <- unique(d, by = "pid")
  # ---- Household (Block 4) ------------------------------------------------------
  h <- rd(3)[, .(hh_id = paste(trimws(fsu), trimws(b1q4), sep = "_"), hh_size = num(b4q1),
                 religion = num(b4q2), social_group = num(b4q3), land = num(b4q4),
                 umpce = num(b4q9), cooking = num(b4q10), washing = num(b4q12), sweeping = num(b4q13))]
  h <- unique(h, by = "hh_id")

  X <- merge(pdy, p, by = "pid")
  V$n_diaries_unmatched_to_roster <- nrow(pdy) - nrow(X)
  X <- merge(X, d, by = "pid", all.x = TRUE)
  X <- merge(X, h, by = "hh_id", all.x = TRUE)
  X <- merge(X, hhc, by = "hh_id", all.x = TRUE)
  V$n_diarists <- nrow(X)
  # Residual under-6 count, the only method available in the 2024 file (which has no
  # members under 6): household size minus diarists. Kept alongside the direct count so
  # the two years can be harmonised and the residual method checked against the truth.
  X[, hh_n_diarists := .N, by = hh_id]
  X[, hh_n_under6_resid := pmax(hh_size - hh_n_diarists, 0)]
  V$share_hh_under6_resid_agrees <- X[, mean((hh_n_under6_resid > 0) == (hh_n_under6 > 0), na.rm = TRUE)]
  V$share_diaries_1440 <- mean(X$day_total == 1440)
  V$n_missing_dow <- sum(is.na(X$dow))

  # ---- Derived variables, same definitions as build_panel.R ----------------------
  et <- CODE$edu_tier
  X[, `:=`(
    female = as.integer(gender == CODE$gender["female"]),
    sex = factor(fcase(gender == 1, "Men", gender == 2, "Women", gender == 3, "Transgender"),
                 levels = c("Men", "Women", "Transgender")),
    urban = as.integer(sector == CODE$sector["urban"]),
    married = as.integer(marital == CODE$marital["married"]),
    edu_tier = factor(fcase(edu %in% et[[1]], names(et)[1], edu %in% et[[2]], names(et)[2],
                            edu %in% et[[3]], names(et)[3], edu %in% et[[4]], names(et)[4]), levels = names(et)),
    employed = as.integer(pas %in% CODE$pas_employed),
    pas_group = factor(fcase(pas %in% CODE$pas_self_emp, "Self-employed", pas %in% CODE$pas_helper, "Unpaid family helper",
                             pas %in% CODE$pas_regular, "Regular wage/salaried", pas %in% CODE$pas_casual, "Casual labour",
                             pas %in% CODE$pas_unemployed, "Unemployed", pas %in% CODE$pas_student, "Student",
                             pas %in% CODE$pas_domestic, "Domestic duties", default = "Other not working"),
                       levels = c("Self-employed", "Unpaid family helper", "Regular wage/salaried", "Casual labour",
                                  "Unemployed", "Student", "Domestic duties", "Other not working")),
    sunday = as.integer(dow == 7), saturday = as.integer(dow == 6),
    has_under6 = as.integer(hh_n_under6 > 0),
    mpce = umpce / hh_size)]
  V$code_scheme_check <- detect_code_scheme(X$pas, X$cooking)
  attr(X, "validation") <- V
  saveRDS(X, out)
  message(sprintf("2019 panel: %s diaries; %.2f%% sum to 1,440; %s diaries without day of week",
                  format(nrow(X), big.mark = ","), 100 * V$share_diaries_1440, V$n_missing_dow))
  invisible(X)
}

load_panel_2019 <- function(rebuild = FALSE) {
  f <- file.path(TUS_DERIVED, "person_day_2019.rds")
  X <- if (rebuild || !file.exists(f)) build_panel_2019() else readRDS(f)
  V <- attr(X, "validation"); n3 <- sum(X$gender %in% 3)
  X <- X[!(gender %in% 3)]                      # third gender: excluded, as in 2024
  V$n_third_gender_excluded <- n3; attr(X, "validation") <- V
  X
}
