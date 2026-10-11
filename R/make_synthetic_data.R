# =============================================================================
# make_synthetic_data.R -- schema-identical FAKE microdata for testing.
#
# Purpose: lets every manuscript knit end-to-end without the restricted NSO
# file, so code errors surface before the real run. The numbers it produces
# mean nothing. Never cite them. PDFs built from it carry a watermark.
#
#   Rscript R/make_synthetic_data.R [n_households]
# =============================================================================

TUS_ROOT <- local({
  d <- normalizePath(getwd())
  while (!file.exists(file.path(d, "R", "setup.R")) && dirname(d) != d) d <- dirname(d)
  d
})
suppressPackageStartupMessages({ library(data.table); library(haven) })

make_synthetic <- function(n_hh = 4000, seed = 7) {
  set.seed(seed)
  n_fsu <- ceiling(n_hh / 8)
  hh <- data.table(
    FSU_Serial_No = sample(10000 + seq_len(n_fsu), n_hh, replace = TRUE),
    Sector = sample(1:2, n_hh, TRUE, c(.68, .32)),
    State = sample(1:36, n_hh, TRUE),
    Religion = sample(c(1, 2, 3, 4, 7), n_hh, TRUE, c(.79, .14, .03, .02, .02)),
    Social_Group = sample(c(1, 2, 3, 9), n_hh, TRUE, c(.09, .2, .44, .27)),
    primary_energy_cooking = sample(c(1, 2, 3, 6, 8), n_hh, TRUE, c(.3, .05, .05, .55, .05)),
    type_of_washing = sample(1:3, n_hh, TRUE, c(.15, .8, .05)),
    type_of_sweeping = sample(1:3, n_hh, TRUE, c(.02, .95, .03)),
    special_care_needed = sample(1:2, n_hh, TRUE, c(.06, .94)),
    land_possessed = sample(c(1:8, 10:12, 99), n_hh, TRUE)
  )
  hh[, Sample_HH_No := seq_len(.N), by = FSU_Serial_No]
  hh[, Day_of_Week := sample(1:7, .N, TRUE)]
  hh[, Weight := round(runif(.N, 500, 5000), 2)]
  hh[, care_giver_available := ifelse(special_care_needed == 1, sample(1:2, .N, TRUE, c(.9, .1)), NA)]

  # Household rosters: head (+ spouse), children, maybe parents, maybe married son.
  mk_person <- function(rel, sex, age, mar) data.table(rel, sex, age, mar)
  people <- vector("list", n_hh)
  for (i in seq_len(n_hh)) {
    hs <- sample(1:2, 1, prob = c(.88, .12))
    ha <- sample(25:75, 1)
    p <- list(mk_person(1, hs, ha, if (hs == 2) sample(2:3, 1, prob = c(.3, .7)) else 2))
    if (p[[1]]$mar == 2) p[[length(p) + 1]] <- mk_person(2, 3 - hs, max(18, ha + sample(-8:2, 1)), 2)
    nk <- if (ha < 60) rpois(1, 1.6) else 0
    for (k in seq_len(nk)) {
      a <- max(0, ha - sample(20:35, 1))
      p[[length(p) + 1]] <- mk_person(5, sample(1:2, 1), a, if (a >= 21) sample(1:2, 1, prob = c(.6, .4)) else 1)
    }
    if (ha < 50 && runif(1) < .25) for (k in seq_len(sample(1:2, 1)))
      p[[length(p) + 1]] <- mk_person(7, k, ha + sample(22:30, 1), sample(2:3, 1))
    if (ha >= 55 && runif(1) < .4) {
      p[[length(p) + 1]] <- mk_person(3, 1, ha - 27, 2)
      p[[length(p) + 1]] <- mk_person(4, 2, ha - 30, 2)
      for (k in seq_len(rpois(1, 1.5))) p[[length(p) + 1]] <- mk_person(6, sample(1:2, 1), sample(0:12, 1), 1)
    }
    if (runif(1) < .01) p[[length(p) + 1]] <- mk_person(9, sample(1:2, 1), sample(18:50, 1), 1)
    people[[i]] <- cbind(hh_row = i, rbindlist(p))
  }
  pp <- rbindlist(people)
  pp[, Person_Serial_No := seq_len(.N), by = hh_row]
  pp[, Household_Size := .N, by = hh_row]
  pp <- cbind(pp, hh[pp$hh_row])
  pp[mar == 2 & age < 18, mar := 1]
  pp[, Highest_Education := fifelse(age < 6, NA_real_,
                                    as.numeric(sample(c(1:8, 10:12), .N, TRUE,
                                                      c(.2, .05, .1, .15, .15, .12, .02, .02, .03, .12, .04))))]
  pp[, Principal_Activity_Status := fcase(
    age < 15, 61,
    sex == 1 & age < 60, sample(c(11, 21, 41, 51, 61), .N, TRUE, c(.35, .25, .25, .05, .1)),
    sex == 2 & age < 60, sample(c(11, 13, 21, 41, 62, 63, 61), .N, TRUE, c(.08, .1, .07, .07, .5, .1, .08)),
    default = sample(c(11, 64, 62, 65, 66), .N, TRUE, c(.2, .2, .4, .1, .1)))]
  pp[, umpce_item10 := round(Household_Size * exp(rnorm(.N, 7.8 + .4 * (Sector == 2), .5)))]
  pp[, umpce_item10 := umpce_item10[1], by = hh_row]
  pp[, srl_no_informant_member := ifelse(runif(.N) < .6, Person_Serial_No, 1)]

  # Only members aged 6+ keep diaries (as in the TUS).
  dia <- pp[age >= 6]
  hh_has_u6 <- pp[, .(u6 = any(age < 6)), by = hh_row]
  dia <- merge(dia, hh_has_u6, by = "hh_row")

  # Build 30-minute-slot diaries starting 04:00, merge runs into episodes.
  slot_codes <- function(r) {
    f <- r$sex == 2; emp <- r$Principal_Activity_Status %in% c(11, 12, 13, 21, 31, 41)
    kid <- r$age < 15; sun <- r$Day_of_Week == 7
    s <- rep(911L, 48)                       # sleep default
    put <- function(code, n, from = 1, to = 48) {
      idx <- which(s == 911L & seq_along(s) >= from & seq_along(s) <= to)
      if (length(idx) > 0 && n > 0) s[sample(idx, min(n, length(idx)))] <<- as.integer(code)
    }
    put(931, 2, 4, 44); put(921, 3, 6, 44)
    if (kid) put(611, sample(10:14, 1) * !sun, 8, 30)
    if (emp && !kid) put(sample(c(110, 121, 131), 1), sample(14:18, 1) * (!sun || runif(1) < .3), 8, 40)
    if (emp && !kid) put(182, 2, 8, 40)
    if (f && !kid) {
      put(311, sample(4:7, 1), 4, 44); put(321, sample(1:3, 1), 4, 40)
      put(341, sample(0:2, 1), 4, 40); put(242, sample(0:2, 1) * (r$Sector == 1), 4, 30)
      if (r$u6 || r$rel %in% c(1, 2, 4) && r$age < 45) put(411, sample(1:5, 1), 4, 44)
      if (r$special_care_needed == 1) put(421, sample(0:3, 1), 4, 44)
    } else if (!kid) {
      put(311, sample(0:1, 1), 4, 44); put(371, sample(0:2, 1), 8, 40)
      if (r$u6) put(415, sample(0:2, 1), 20, 44)
    }
    put(842, sample(2:6, 1) + 2 * sun, 30, 46); put(711, sample(1:3, 1), 20, 46)
    if (!kid && runif(1) < .05) put(sample(c(513, 521), 1), sample(1:3, 1), 8, 40)
    if (!kid && runif(1) < .05) put(630, sample(1:3, 1), 8, 40)
    if (!kid && !f && runif(1) < .1) put(sample(c(241, 242), 1), sample(1:2, 1), 4, 30)
    if (!kid && runif(1) < .3) put(212, sample(1:3, 1), 4, 30)
    if (!kid && runif(1) < .1) put(sample(c(351, 352), 1), 1, 20, 44)
    if (!kid && runif(1) < .05) put(912, 1, 20, 40)
    if (!kid && runif(1) < .04) put(431, 1, 4, 44)
    if (runif(1) < .08) put(832, 1, 3, 10)
    if (runif(1) < .3) put(741, 1, 3, 10)
    put(850, sample(0:2, 1), 20, 40)
    s
  }
  rows <- vector("list", nrow(dia))
  for (i in seq_len(nrow(dia))) {
    r <- dia[i]; s <- slot_codes(r)
    run <- rle(s); ends <- cumsum(run$lengths); starts <- ends - run$lengths + 1
    tf <- (240 + (starts - 1) * 30) %% 1440
    ep <- data.table(Activity_Code_3Digit = run$values, time_spent = 30 * run$lengths,
                     t_from = tf, Major_Activity_Flag = 1)
    # Minor activities: childcare while cooking, eating while TV, talking while cooking.
    mn <- list()
    for (j in seq_len(nrow(ep))) {
      a <- ep$Activity_Code_3Digit[j]
      if (a == 311 && r$sex == 2 && (r$u6) && runif(1) < .5) mn[[length(mn) + 1]] <- data.table(416, 30, ep$t_from[j], 2)
      if (a == 842 && runif(1) < .3) mn[[length(mn) + 1]] <- data.table(921, 30, ep$t_from[j], 2)
      if (a == 311 && runif(1) < .2) mn[[length(mn) + 1]] <- data.table(711, 30, ep$t_from[j], 2)
    }
    ep[, `:=`(Multiple_Activity_Flag = 2, Simultaneous_Activity_Flag = NA_real_)]
    if (length(mn)) {
      mn <- rbindlist(mn); setnames(mn, c("Activity_Code_3Digit", "time_spent", "t_from", "Major_Activity_Flag"))
      ep[t_from %in% mn$t_from, `:=`(Multiple_Activity_Flag = 1, Simultaneous_Activity_Flag = 1)]
      mn[, `:=`(Multiple_Activity_Flag = 1, Simultaneous_Activity_Flag = 1)]
      ep <- rbind(ep, mn)
    }
    ep[, row := i]
    rows[[i]] <- ep
  }
  act <- rbindlist(rows)
  out <- cbind(dia[act$row], act[, !"row"])
  out[, `:=`(
    Activity_Code_2Digit = Activity_Code_3Digit %/% 10,
    Time_From = sprintf("%02d:%02d", (t_from %/% 60), t_from %% 60),
    Location_of_Activity = fifelse(Activity_Code_3Digit %in% c(110, 121, 131, 182, 611, 371), 2, 1),
    Unpaid_Paid_Status = fcase(Activity_Code_3Digit %/% 100 == 4, 2, Activity_Code_3Digit %/% 100 == 3, 3,
                               Activity_Code_3Digit %/% 100 == 1, 14, default = 1),
    Enterprise_Type = fifelse(Activity_Code_3Digit %/% 100 == 1, sample(c(1, 3, 5, 8), .N, TRUE), NA_real_),
    Gender = sex, Age = age, Marital_Status = mar, Relationship_to_Head = rel
  )]
  keep <- c("FSU_Serial_No", "Sample_HH_No", "Person_Serial_No", "Sector", "State",
            "Gender", "Age", "Marital_Status", "Highest_Education", "Principal_Activity_Status",
            "Relationship_to_Head", "Household_Size", "Religion", "Social_Group",
            "umpce_item10", "primary_energy_cooking", "type_of_washing", "type_of_sweeping",
            "special_care_needed", "care_giver_available", "land_possessed",
            "srl_no_informant_member", "Day_of_Week", "Weight", "Time_From", "time_spent",
            "Multiple_Activity_Flag", "Simultaneous_Activity_Flag", "Major_Activity_Flag",
            "Location_of_Activity", "Unpaid_Paid_Status", "Enterprise_Type",
            "Activity_Code_2Digit", "Activity_Code_3Digit")
  res <- out[, ..keep]
  # Recode to the official-dictionary scheme unless TUS_SYNTH_SCHEME=legacy_txt.
  if (!identical(Sys.getenv("TUS_SYNTH_SCHEME"), "legacy_txt")) {
    pas_map <- c("11" = 11, "12" = 12, "13" = 21, "21" = 31, "31" = 41, "41" = 51, "51" = 81, "61" = 91,
                 "62" = 92, "63" = 93, "64" = 94, "65" = 95, "66" = 97)
    cook_map <- c("1" = 1, "2" = 1, "3" = 4, "4" = 6, "5" = 5, "6" = 2, "7" = 7, "8" = 11, "9" = 19)
    res[, Principal_Activity_Status := unname(pas_map[as.character(Principal_Activity_Status)])]
    res[, primary_energy_cooking := unname(cook_map[as.character(primary_energy_cooking)])]
  }
  res
}

if (sys.nframe() == 0) {
  args <- commandArgs(trailingOnly = TRUE)
  n <- if (length(args)) as.integer(args[1]) else 4000
  d <- make_synthetic(n)
  dir.create(file.path(TUS_ROOT, "data", "synthetic"), recursive = TRUE, showWarnings = FALSE)
  f <- file.path(TUS_ROOT, "data", "synthetic", "TimeUse106PER_synthetic.dta")
  haven::write_dta(as.data.frame(d), f)
  message(sprintf("Wrote %s rows (%s persons) to %s", format(nrow(d), big.mark = ","),
                  format(nrow(unique(d[, .(FSU_Serial_No, Sample_HH_No, Person_Serial_No)])), big.mark = ","), f))
}
