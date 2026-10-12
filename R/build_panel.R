# =============================================================================
# build_panel.R -- activity-level microdata  ->  person-day analysis panel.
#
# Design rules (each one fixes a bug present in the legacy papers):
#   1. Use ALL rows. Never sample activity rows: a 10% row sample keeps ~2 of
#      a person's ~21 activity records and destroys every per-day quantity.
#      (Optional household-level subsampling is provided for quick drafts.)
#   2. The unit of analysis is the person-day (one diary per respondent).
#      Minutes come from MAJOR activities only, so each diary sums to 1,440.
#   3. Major/minor flag is 1 = major, 2 = minor (dictionary), not 1/0.
#   4. Activity categories come from codes.R (ICATUS 3-digit), never ad hoc.
#   5. Persons are identified by FSU x household x person serial number.
#   6. Every number is survey-weighted; inference clusters on the FSU (PSU).
# =============================================================================

# ---- Column resolution -------------------------------------------------------
# Candidate names per concept, matched case-insensitively after stripping
# non-alphanumerics. The first match wins. Required concepts stop the build.
TUS_COLS <- list(
  fsu        = c("FSU_Serial_No", "fsu_serial_no", "FSU_No", "FSU"),
  hh         = c("Sample_HH_No", "sample_household_number", "Sample_Household_No", "HH_No"),
  person     = c("Person_Serial_No", "Person_Srl_No", "person_serial_number", "Member_Srl_No"),
  gender     = c("Gender", "Sex"),
  age        = c("Age"),
  act3       = c("Activity_Code_3Digit", "activity_code_3digit", "Activity_Code"),
  time       = c("time_spent", "Time_Spent", "Duration"),
  weight     = c("Weight", "MULT", "Multiplier", "wgt"),
  major      = c("Major_Activity_Flag", "major_minor_activity", "Major_Minor_Activity"),
  # optional
  act2       = c("Activity_Code_2Digit"),
  marital    = c("Marital_Status"),
  edu        = c("Highest_Education", "highest_level_of_education"),
  pas        = c("Principal_Activity_Status", "principal_activity_status"),
  rel        = c("Relationship_to_Head", "Relation_to_Head", "Rel_to_Head",
                 "Relationship_To_Head", "relationship_to_head"),
  sector     = c("Sector"),
  state      = c("State", "State_Code", "state_ut"),
  district   = c("District", "District_Code"),
  stratum    = c("Stratum"),
  sub_round  = c("Sub_Round", "Subround", "Quarter"),
  paid_status = c("Unpaid_Paid_Status", "unpaid_paid_status"),
  dow        = c("Day_of_Week", "Day_Of_Week", "day_of_week"),
  type_day   = c("Type_of_Day", "type_of_day"),
  informant  = c("Informant_Serial_No", "srl_no_informant_member", "Informant_Srl_No", "Srl_No_Informant"),
  multiple   = c("Multiple_Activity_Flag", "multiple_activity", "Multiple_Activity"),
  simult     = c("Simultaneous_Activity_Flag", "simultaneous_activity", "Simultaneous_Activity"),
  location   = c("Location_of_Activity", "activity_location", "Activity_Location"),
  enterprise = c("Enterprise_Type", "enterprise_type", "Type_of_Enterprise"),
  time_from  = c("Time_From", "time_from", "Start_Time", "Slot_From"),
  religion   = c("Religion"),
  social_group = c("Social_Group"),
  hh_size    = c("Household_Size", "household_size_main", "HH_Size", "Household_Size_Main"),
  umpce      = c("umpce_item10", "UMPCE", "Monthly_Consumption", "HH_UMCE", "Usual_Monthly_Consumer_Expenditure"),
  cooking    = c("primary_energy_cooking", "Primary_Energy_Cooking", "Cooking_Energy"),
  lighting   = c("primary_energy_lighting", "Primary_Energy_Lighting"),
  washing    = c("type_of_washing", "Type_of_Washing"),
  sweeping   = c("type_of_sweeping", "Type_of_Sweeping"),
  special_care = c("special_care_needed", "Special_Care_Needed"),
  caregiver  = c("care_giver_available", "Care_Giver_Available"),
  land       = c("land_possessed", "Land_Possessed"),
  dwelling   = c("dwelling_unit_structure", "Dwelling_Unit_Structure")
)
TUS_REQUIRED <- c("fsu", "hh", "person", "gender", "age", "act3", "time", "weight", "major")

norm_name <- function(x) tolower(gsub("[^A-Za-z0-9]", "", x))

resolve_columns <- function(available) {
  key <- setNames(available, norm_name(available))
  out <- vapply(names(TUS_COLS), function(concept) {
    hit <- key[norm_name(TUS_COLS[[concept]])]
    hit <- hit[!is.na(hit)]
    if (length(hit)) unname(hit[1]) else NA_character_
  }, character(1))
  miss <- TUS_REQUIRED[is.na(out[TUS_REQUIRED])]
  if (length(miss)) {
    stop("Required columns not found for: ", paste(miss, collapse = ", "),
         "\nColumns in file:\n  ", paste(available, collapse = ", "),
         "\nAdd the correct name to TUS_COLS in R/build_panel.R.")
  }
  out
}

as_num <- function(x) {
  x <- haven::zap_labels(x)
  if (is.character(x)) x <- suppressWarnings(as.numeric(trimws(x)))
  as.numeric(x)
}

# ---- Optional household-characteristics file (Block 4) --------------------------
# The person-level .dta of the 2024 release carries NO household characteristics
# (religion, caste, household size, consumption, cooking fuel, laundry, sweeping,
# special-care need, caregiver). They live in a separate household-level file (Level 03
# of the NSO release). Point TUS_HH_DTA at it (.dta or .csv). Columns are matched on the
# variable name AND its label, so exact names are not needed. The probe prints what
# was matched; adjust HH_PATTERNS if a concept is mismatched.
HH_PATTERNS <- list(
  hh_size      = "household.?size|hh.?size|members",
  religion     = "religion",
  social_group = "social.?group|caste",
  land         = "land",
  umpce        = "consumer.?expend|umpce|umce|mpce|monthly.?expend|consumption",
  cooking      = "cook",
  lighting     = "lighting|light",
  washing      = "wash",
  sweeping     = "sweep",
  dwelling     = "dwelling|structure",
  special_care = "special.?care|needing.?special|needs.?special",
  caregiver    = "care.?giver|caregiver"
)
resolve_hh_columns <- function(hdr) {
  nm  <- names(hdr)
  lab <- vapply(nm, function(v) { l <- attr(hdr[[v]], "label"); if (is.null(l)) "" else as.character(l) }, character(1))
  txt <- tolower(gsub("[_ ]", ".", paste(nm, lab)))
  keys <- list(fsu = TUS_COLS$fsu, hh = TUS_COLS$hh)
  out <- list()
  for (k in names(keys)) {
    hit <- nm[norm_name(nm) %in% norm_name(keys[[k]])]
    out[[k]] <- if (length(hit)) hit[1] else NA_character_
  }
  for (k in names(HH_PATTERNS)) {
    hit <- nm[grepl(HH_PATTERNS[[k]], txt) & !nm %in% unlist(out)]
    if (k == "umpce" && length(hit) > 1) hit <- hit[length(hit)]   # the calculated total comes last
    out[[k]] <- if (length(hit)) hit[1] else NA_character_
  }
  unlist(out)
}
read_household_file <- function(path) {
  stopifnot(file.exists(path))
  if (grepl("\\.csv$", path, ignore.case = TRUE)) {
    h <- data.table::fread(path)
    hdr <- as.data.frame(h[0])
  } else {
    hdr <- haven::read_dta(path, n_max = 5)
    h <- data.table::as.data.table(haven::read_dta(path))
  }
  col <- resolve_hh_columns(hdr)
  list(data = h, col = col)
}
merge_household_file <- function(dt, path) {
  hh <- read_household_file(path)
  col <- hh$col
  if (anyNA(col[c("fsu", "hh")])) stop("Household file: cannot find FSU and household number columns. Columns: ",
                                       paste(names(hh$data), collapse = ", "))
  found <- col[!is.na(col)]
  sub <- hh$data[, unname(found), with = FALSE]
  data.table::setnames(sub, unname(found), names(found))
  for (v in setdiff(names(sub), c("fsu", "hh"))) sub[, (v) := as_num(get(v))]
  sub[, `:=`(fsu = as_num(fsu), hh = as_num(hh))]
  sub <- unique(sub, by = c("fsu", "hh"))
  already <- intersect(setdiff(names(sub), c("fsu", "hh")), names(dt))
  if (length(already)) sub[, (already) := NULL]
  dt <- merge(dt, sub, by = c("fsu", "hh"), all.x = TRUE, sort = FALSE)
  data.table::setattr(dt, "hh_cols", col)
  dt
}

# ---- Main builder ------------------------------------------------------------
build_panel <- function(dta = TUS_DTA, out_dir = TUS_DERIVED, hh_dta = TUS_HH_DTA,
                        hh_sample_frac = 1, seed = 20240101, verbose = TRUE) {
  stopifnot(file.exists(dta))
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  say <- function(...) if (verbose) message(sprintf(...))

  avail <- names(haven::read_dta(dta, n_max = 0))
  col   <- resolve_columns(avail)
  found <- col[!is.na(col)]
  say("Reading %d of %d columns from %s", length(found), length(avail), basename(dta))

  raw <- haven::read_dta(dta, col_select = dplyr::all_of(unname(found)))
  dt  <- data.table::as.data.table(raw)
  rm(raw); invisible(gc())
  data.table::setnames(dt, unname(found), names(found))
  for (v in names(dt)) {
    if (v == "time_from") dt[, (v) := as.character(haven::zap_labels(get(v)))]
    else dt[, (v) := as_num(get(v))]
  }

  hh_cols <- NULL
  if (nzchar(hh_dta) && file.exists(hh_dta)) {
    dt <- merge_household_file(dt, hh_dta)
    hh_cols <- attr(dt, "hh_cols")
    say("Merged household file %s", basename(hh_dta))
  }
  dt[, hh_id := paste(fsu, hh, sep = "_")]
  if (hh_sample_frac < 1) {
    set.seed(seed)
    keep <- sample(unique(dt$hh_id), ceiling(hh_sample_frac * uniqueN(dt$hh_id)))
    dt <- dt[hh_id %in% keep]
    dt[, weight := weight / hh_sample_frac]
    say("Household subsample: %.0f%% of households (weights rescaled)", 100 * hh_sample_frac)
  }
  dt[, pid := paste(hh_id, person, sep = "_")]

  # ---- Flag conventions --------------------------------------------------------
  major_vals <- sort(unique(dt$major))
  if (all(major_vals %in% c(0, 1))) {
    dt[, is_major := major == 1]       # tolerate 1/0 coding if a release uses it
  } else {
    dt[, is_major := major == CODE$major_minor["major"]]
  }
  # Roster-only rows (members with no diary, e.g. children under 6, non-respondents) have
  # no activity code and a missing major flag. They carry roster attributes only.
  dt[, has_act := !is.na(act3)]
  dt[is.na(is_major), is_major := FALSE]
  dt[, is_minor := has_act & !is_major]

  # ---- Validation ----------------------------------------------------------------
  V <- list(file = basename(dta), household_file = if (is.null(hh_cols)) "NONE" else basename(hh_dta),
            household_columns = hh_cols, synthetic = TUS_SYNTHETIC,
            built = format(Sys.time()), columns_found = found,
            columns_missing = names(col)[is.na(col)],
            n_rows = nrow(dt), n_persons = uniqueN(dt$pid),
            n_households = uniqueN(dt$hh_id), n_fsu = uniqueN(dt$fsu),
            major_flag_values = major_vals,
            n_rows_roster_only = sum(!dt$has_act),
            share_rows_minor = mean(dt$is_minor[dt$has_act]))
  bad_codes <- setdiff(unique(dt$act3), as.integer(names(icatus_labels)))
  V$invalid_act3_codes <- bad_codes[!is.na(bad_codes)]
  if ("act2" %in% names(dt)) {
    V$act2_matches_act3_prefix <- mean(floor(dt$act3 / 10) == dt$act2, na.rm = TRUE)
  }

  # ---- Person-level attributes -------------------------------------------------
  person_vars <- intersect(c("pid", "hh_id", "fsu", "person", "gender", "age", "marital",
                             "edu", "pas", "rel", "sector", "state", "district",
                             "stratum", "sub_round", "dow", "type_day", "informant",
                             "religion", "social_group", "hh_size", "umpce", "cooking",
                             "lighting", "washing", "sweeping", "special_care",
                             "caregiver", "land", "dwelling", "weight"), names(dt))
  pdy <- dt[, lapply(.SD, function(z) z[1]), by = pid, .SDcols = setdiff(person_vars, "pid")]
  wsd <- dt[, .(s = if (.N > 1) sd(weight) else 0), by = pid]
  V$share_persons_weight_varies <- mean(wsd$s > 1e-8, na.rm = TRUE)

  # ---- Minutes by category: major activities -------------------------------------
  diar <- unique(dt[has_act == TRUE, pid])
  pdy[, has_diary := pid %in% diar]
  agg <- dt[is_major == TRUE, .(m = sum(time, na.rm = TRUE), n = .N), by = .(pid, act3)]
  cats <- names(ACT)
  for (k in cats) {
    s <- agg[act3 %in% ACT[[k]], .(v = sum(m)), by = pid]
    pdy[s, on = "pid", (k) := i.v]
    pdy[is.na(get(k)), (k) := 0]
  }
  tot <- agg[, .(day_total = sum(m), n_episodes = sum(n)), by = pid]
  pdy[tot, on = "pid", `:=`(day_total = i.day_total, n_episodes = i.n_episodes)]
  pdy[is.na(day_total), `:=`(day_total = 0, n_episodes = 0)]
  V$n_diarists <- sum(pdy$has_diary)
  V$n_roster_only <- sum(!pdy$has_diary)
  V$n_roster_only_age6plus <- sum(!pdy$has_diary & pdy$age >= 6, na.rm = TRUE)
  V$share_diaries_1440 <- mean(abs(pdy$day_total[pdy$has_diary] - 1440) < 1e-6)
  V$day_total_quantiles <- quantile(pdy$day_total[pdy$has_diary], c(0, .01, .5, .99, 1))

  # ---- Secondary (minor) activities ----------------------------------------------
  sec_cats <- c("care_child", "care_dep_adult", "unpaid_care", "unpaid_domestic",
                "dom_food", "eating", "mass_media", "socialising", "free_time",
                "employment", "ownuse_goods", "religious")
  agg2 <- dt[is_minor == TRUE, .(m = sum(time, na.rm = TRUE), n = .N), by = .(pid, act3)]
  for (k in sec_cats) {
    nm <- paste0("sec_", k)
    s <- agg2[act3 %in% ACT[[k]], .(v = sum(m), e = sum(n)), by = pid]
    pdy[s, on = "pid", c(nm, paste0(nm, "_n")) := .(i.v, i.e)]
    pdy[is.na(get(nm)), c(nm, paste0(nm, "_n")) := .(0, 0)]
  }
  sec_tot <- agg2[, .(sec_total = sum(m), sec_episodes = sum(n)), by = pid]
  pdy[sec_tot, on = "pid", `:=`(sec_total = i.sec_total, sec_episodes = i.sec_episodes)]
  pdy[is.na(sec_total), `:=`(sec_total = 0, sec_episodes = 0)]

  # Slot-level multitasking: minutes of major activity recorded in slots that the
  # respondent flagged as containing more than one / simultaneous activities.
  if ("multiple" %in% names(dt)) {
    s <- dt[is_major == TRUE, .(v = sum(time * (multiple == CODE$yes_no["yes"]), na.rm = TRUE)), by = pid]
    pdy[s, on = "pid", min_multiple_slots := i.v]
  }
  if ("simult" %in% names(dt)) {
    s <- dt[is_major == TRUE, .(v = sum(time * (simult == CODE$yes_no["yes"]), na.rm = TRUE)), by = pid]
    pdy[s, on = "pid", min_simult_slots := i.v]
  }

  # Major x minor pairs: a minor record is paired with the major episode whose
  # time interval contains the minor record's start time (interval join), so the
  # pairing does not depend on how the release splits episodes into slots.
  pairs <- NULL
  if ("time_from" %in% names(dt)) {
    dt[, t0 := clock_to_min(time_from)]
    if (mean(is.na(dt$t0)) < 0.01) {
      cat_of <- function(a) {
        out <- rep("other", length(a))
        for (k in c("employment", "ownuse_goods", "unpaid_domestic", "care_child",
                    "care_dep_adult", "care_nondep_adult", "care_other", "volunteer",
                    "learning", "social_all", "leisure_all", "sleep", "eating",
                    "hygiene", "receiving_care", "selfcare_other")) out[a %in% ACT[[k]]] <- k
        out
      }
      mj <- dt[is_major == TRUE, .(pid, s = t0, e = t0 + pmax(time, 1) - 1e-6, major_cat = cat_of(act3))]
      mn <- dt[is_minor == TRUE, .(pid, s = t0, e = t0, minor_cat = cat_of(act3), minor_min = time)]
      setkey(mj, pid, s, e)
      ov <- foverlaps(mn, mj, by.x = c("pid", "s", "e"), type = "within", mult = "first", nomatch = NA)
      V$share_minor_rows_matched_to_major <- mean(!is.na(ov$major_cat))
      pairs <- ov[!is.na(major_cat), .(minutes = sum(minor_min), episodes = .N),
                  by = .(pid, major_cat, minor_cat)]
    } else {
      V$share_minor_rows_matched_to_major <- NA
    }
  }

  # Location: share of minutes spent inside the dwelling.
  if ("location" %in% names(dt)) {
    s <- dt[is_major == TRUE, .(v = sum(time * (location == CODE$location["inside_dwelling"]), na.rm = TRUE)), by = pid]
    pdy[s, on = "pid", min_inside_home := i.v]
  }

  # Paid status of episodes: minutes flagged as care (code 2), a cross-check on Division 4.
  if ("paid_status" %in% names(dt)) {
    s <- dt[is_major == TRUE, .(v = sum(time * (paid_status == 2), na.rm = TRUE)), by = pid]
    pdy[s, on = "pid", min_paidstatus_care := i.v]
  }
  if ("enterprise" %in% names(dt)) {
    ent <- dt[is_major == TRUE & act3 %in% ACT$paid_work & !is.na(enterprise),
              .(m = sum(time)), by = .(pid, enterprise)][order(pid, -m)][, .SD[1], by = pid]
    pdy[ent, on = "pid", enterprise_main := i.enterprise]
  }
  rm(dt, agg, agg2); invisible(gc())

  # Members without a diary have no time-use outcomes: set them to NA so that spouse and
  # household aggregates never treat a missing diary as zero minutes.
  tu_cols <- intersect(c(names(ACT), "day_total", "n_episodes", "sec_total", "sec_episodes",
                         grep("^sec_", names(pdy), value = TRUE), "min_multiple_slots",
                         "min_simult_slots", "min_inside_home", "min_paidstatus_care"), names(pdy))
  for (k in unique(tu_cols)) pdy[has_diary == FALSE, (k) := NA_real_]

  # ---- Code scheme (principal activity status, fuels) ----------------------------
  det <- detect_code_scheme(if ("pas" %in% names(pdy)) pdy$pas else NULL,
                            if ("cooking" %in% names(pdy)) pdy$cooking else NULL)
  apply_code_scheme(det$scheme)
  V$code_scheme <- det$scheme
  V$code_scheme_evidence <- det$evidence
  V$code_scheme_note <- if (det$conflicting) "CONFLICT: markers from both dictionaries present; check the file"
                        else if (det$undetermined) "UNDETERMINED: no marker codes present; defaulted to official dictionary"
                        else "detected from marker codes"
  if (det$conflicting || det$undetermined) warning("Code scheme ", V$code_scheme_note)

  # ---- Derived person variables ----------------------------------------------------
  pdy[, `:=`(
    female   = as.integer(gender == CODE$gender["female"]),
    sex      = factor(fcase(gender == 1, "Men", gender == 2, "Women", gender == 3, "Transgender"),
                      levels = c("Men", "Women", "Transgender")),
    urban    = if ("sector" %in% names(pdy)) as.integer(sector == CODE$sector["urban"]) else NA_integer_,
    married  = if ("marital" %in% names(pdy)) as.integer(marital == CODE$marital["married"]) else NA_integer_,
    age_band = cut(age, c(5, 14, 24, 34, 44, 54, 64, Inf),
                   labels = c("6-14", "15-24", "25-34", "35-44", "45-54", "55-64", "65+"))
  )]
  if ("marital" %in% names(pdy)) {
    pdy[, marital_f := factor(fcase(marital == 1, "Never married", marital == 2, "Married",
                                    marital == 3, "Widowed", marital == 4, "Divorced/separated"),
                              levels = c("Never married", "Married", "Widowed", "Divorced/separated"))]
  }
  if ("edu" %in% names(pdy)) {
    et <- CODE$edu_tier
    pdy[, edu_tier := factor(fcase(edu %in% et[[1]], names(et)[1], edu %in% et[[2]], names(et)[2],
                                   edu %in% et[[3]], names(et)[3], edu %in% et[[4]], names(et)[4]),
                             levels = names(et))]
  }
  if ("pas" %in% names(pdy)) {
    pdy[, `:=`(
      employed = as.integer(pas %in% CODE$pas_employed),
      pas_group = factor(fcase(pas %in% CODE$pas_self_emp, "Self-employed",
                               pas %in% CODE$pas_helper, "Unpaid family helper",
                               pas %in% CODE$pas_regular, "Regular wage/salaried",
                               pas %in% CODE$pas_casual, "Casual labour",
                               pas %in% CODE$pas_unemployed, "Unemployed",
                               pas %in% CODE$pas_student, "Student",
                               pas %in% CODE$pas_domestic, "Domestic duties",
                               default = "Other not working"),
                         levels = c("Self-employed", "Unpaid family helper", "Regular wage/salaried", "Casual labour",
                                    "Unemployed", "Student", "Domestic duties", "Other not working")))]
  }
  if ("dow" %in% names(pdy)) {
    pdy[, `:=`(sunday = as.integer(dow == 7), saturday = as.integer(dow == 6),
               dow_f = factor(dow, 1:7, names(CODE$day_of_week)))]
  }
  if ("informant" %in% names(pdy)) pdy[, proxy_report := as.integer(informant != person)]
  if ("religion" %in% names(pdy)) {
    pdy[, religion_f := factor(fcase(religion == 1, "Hindu", religion == 2, "Muslim",
                                     religion == 3, "Christian", religion == 4, "Sikh",
                                     default = "Other"),
                               levels = c("Hindu", "Muslim", "Christian", "Sikh", "Other"))]
  }
  if ("social_group" %in% names(pdy)) {
    pdy[, social_group_f := factor(fcase(social_group == 1, "ST", social_group == 2, "SC",
                                         social_group == 3, "OBC", default = "Others"),
                                   levels = c("Others", "OBC", "SC", "ST"))]
  }

  # Household characteristics absent from the files supplied: keep the columns (all NA) so
  # downstream code fails with a clear message, or drops them from control sets, never crashes.
  miss_hh <- setdiff(c("religion", "social_group", "umpce", "cooking", "lighting", "washing", "sweeping",
                       "special_care", "caregiver", "land", "dwelling"), names(pdy))
  for (k in miss_hh) pdy[, (k) := NA_real_]
  if (!"religion_f" %in% names(pdy)) pdy[, religion_f := factor(NA_character_, levels = c("Hindu", "Muslim", "Christian", "Sikh", "Other"))]
  if (!"social_group_f" %in% names(pdy)) pdy[, social_group_f := factor(NA_character_, levels = c("Others", "OBC", "SC", "ST"))]
  V$household_vars_missing <- miss_hh

  # ---- Household composition (from every diarist in the household) ---------------
  hhc <- pdy[, .(
    hh_n_diarists   = sum(has_diary),
    hh_n_roster     = .N,
    hh_n_6_14       = sum(age >= 6 & age <= 14),
    hh_n_15_17      = sum(age >= 15 & age <= 17),
    hh_n_60plus     = sum(age >= 60),
    hh_n_75plus     = sum(age >= 75),
    hh_n_women_15plus = sum(female == 1 & age >= 15),
    hh_n_men_15plus   = sum(female == 0 & age >= 15),
    hh_n_employed_women = if ("employed" %in% names(pdy)) sum(female == 1 & employed == 1, na.rm = TRUE) else NA_real_,
    hh_min_age      = min(age)
  ), by = hh_id]
  pdy[hhc, on = "hh_id", names(hhc)[-1] := mget(paste0("i.", names(hhc)[-1]))]
  V$min_age_in_file <- min(pdy$age, na.rm = TRUE)

  # Children under 6 do not keep diaries. If the file holds only diarists (age 6+),
  # the number of under-6 members is household size minus diarists. This assumes
  # every member aged 6+ has a diary; the share of negative residuals tests it.
  if ("hh_size" %in% names(pdy) && V$min_age_in_file >= 6) {
    pdy[, hh_n_under6 := hh_size - hh_n_diarists]
    V$share_hh_negative_under6_residual <- mean(pdy$hh_n_under6 < 0, na.rm = TRUE)
    pdy[hh_n_under6 < 0, hh_n_under6 := NA]
    V$under6_method <- "household size minus diarists (age 6+)"
  } else if (V$min_age_in_file < 6) {
    u6 <- pdy[, .(v = sum(age < 6)), by = hh_id]
    pdy[u6, on = "hh_id", hh_n_under6 := i.v]
    V$under6_method <- "direct count (file contains members under 6)"
    V$share_hh_negative_under6_residual <- NA_real_
  } else {
    pdy[, hh_n_under6 := NA_real_]
    V$under6_method <- "UNAVAILABLE: no household-size column and no members under 6"
  }
  pdy[, has_under6 := as.integer(hh_n_under6 > 0)]
  if (!"hh_size" %in% names(pdy)) pdy[, hh_size := hh_n_roster]   # roster members of all ages
  pdy[, mpce := umpce / hh_size]

  # ---- Relationship-based structure ------------------------------------------------
  if ("rel" %in% names(pdy)) {
    R <- CODE$relation
    rc <- pdy[, .(
      hh_n_parent_gen = sum(rel == R["parent_or_inlaw"]),
      hh_n_servant    = sum(rel == R["servant_nonrelative"]),
      hh_n_child_spouse = sum(rel == R["child_spouse"]),
      hh_n_married_child = sum(rel == R["married_child"]),
      hh_head_female  = as.integer(any(rel == R["head"] & female == 1)),
      hh_three_gen    = as.integer(any(rel == R["grandchild"]) | any(rel == R["parent_or_inlaw"]))
    ), by = hh_id]
    pdy[rc, on = "hh_id", names(rc)[-1] := mget(paste0("i.", names(rc)[-1]))]

    # Spouse link: head <-> spouse of head; married child <-> child's spouse when
    # each is unique in the household and of opposite sex. Other couples unlinked.
    link_pair <- function(r1, r2) {
      a <- pdy[rel == r1, .(hh_id, pid_a = pid, sex_a = female)]
      b <- pdy[rel == r2, .(hh_id, pid_b = pid, sex_b = female)]
      a <- a[, if (.N == 1) .SD, by = hh_id]; b <- b[, if (.N == 1) .SD, by = hh_id]
      m <- merge(a, b, by = "hh_id")[sex_a != sex_b]
      rbind(m[, .(pid = pid_a, spouse_pid = pid_b)], m[, .(pid = pid_b, spouse_pid = pid_a)])
    }
    links <- rbind(link_pair(R["head"], R["spouse"]), link_pair(R["married_child"], R["child_spouse"]))
    sp_vars <- intersect(c("pid", "age", "edu_tier", "employed", "pas_group", "dow", "unpaid_total",
                           "unpaid_domestic", "unpaid_care", "care_child", "employment", "free_time"),
                         names(pdy))
    sp <- pdy[, ..sp_vars]
    data.table::setnames(sp, sp_vars, c("spouse_pid_k", paste0("spouse_", sp_vars[-1])))
    links <- merge(links, sp, by.x = "spouse_pid", by.y = "spouse_pid_k")
    pdy <- merge(pdy, links, by = "pid", all.x = TRUE)
    V$share_married_with_linked_spouse <- pdy[married == 1, mean(!is.na(spouse_pid))]

    # Generation above a person in the household (potential grandparent carers):
    #   head/spouse  -> parents/in-laws (rel 7)
    #   married child/child's spouse -> head and spouse of head (rel 1, 2)
    up <- pdy[, .(
      up_gen_head_level  = sum(rel %in% R[c("head", "spouse")] & age >= 40),
      up_gen_women_head_level = sum(rel %in% R[c("head", "spouse")] & female == 1 & age >= 40),
      up_gen_parent_level = sum(rel == R["parent_or_inlaw"]),
      up_gen_women_parent_level = sum(rel == R["parent_or_inlaw"] & female == 1)
    ), by = hh_id]
    pdy[up, on = "hh_id", names(up)[-1] := mget(paste0("i.", names(up)[-1]))]
    pdy[, `:=`(
      n_older_gen = fcase(rel %in% R[c("head", "spouse")], as.numeric(up_gen_parent_level),
                          rel %in% R[c("married_child", "child_spouse")], as.numeric(up_gen_head_level),
                          default = NA_real_),
      n_older_gen_women = fcase(rel %in% R[c("head", "spouse")], as.numeric(up_gen_women_parent_level),
                                rel %in% R[c("married_child", "child_spouse")], as.numeric(up_gen_women_head_level),
                                default = NA_real_)
    )]
    pdy[, c("up_gen_head_level", "up_gen_women_head_level",
            "up_gen_parent_level", "up_gen_women_parent_level") := NULL]

    # Own children aged 6-17 observed in the diary file, with sex:
    #   head/spouse -> married + unmarried children of head (rel 3, 5)
    #   child's spouse / married child, if the only such couple -> grandchildren (rel 6)
    kids <- pdy[age >= 6 & age <= 17, .(hh_id, rel, female, age)]
    k_head <- kids[rel %in% R[c("married_child", "unmarried_child")],
                   .(k_n = .N, k_sons = sum(female == 0), k_daus = sum(female == 1),
                     k_youngest = min(age)), by = hh_id]
    k_gc <- kids[rel == R["grandchild"], .(g_n = .N, g_sons = sum(female == 0),
                                           g_daus = sum(female == 1), g_youngest = min(age)),
                 by = hh_id]
    pdy[k_head, on = "hh_id", c("k_n", "k_sons", "k_daus", "k_youngest") :=
          .(i.k_n, i.k_sons, i.k_daus, i.k_youngest)]
    pdy[k_gc, on = "hh_id", c("g_n", "g_sons", "g_daus", "g_youngest") :=
          .(i.g_n, i.g_sons, i.g_daus, i.g_youngest)]
    one_couple <- pdy[, .(oc = sum(rel == R["child_spouse"]) == 1), by = hh_id]
    pdy[one_couple, on = "hh_id", one_child_couple := i.oc]
    pdy[, `:=`(
      own_kids_6_17 = fcase(rel %in% R[c("head", "spouse")], fcoalesce(k_n, 0L),
                            rel %in% R[c("married_child", "child_spouse")] & one_child_couple, fcoalesce(g_n, 0L),
                            default = NA_integer_),
      own_sons_6_17 = fcase(rel %in% R[c("head", "spouse")], fcoalesce(k_sons, 0L),
                            rel %in% R[c("married_child", "child_spouse")] & one_child_couple, fcoalesce(g_sons, 0L),
                            default = NA_integer_),
      own_daughters_6_17 = fcase(rel %in% R[c("head", "spouse")], fcoalesce(k_daus, 0L),
                                 rel %in% R[c("married_child", "child_spouse")] & one_child_couple, fcoalesce(g_daus, 0L),
                                 default = NA_integer_),
      youngest_own_kid = fcase(rel %in% R[c("head", "spouse")], as.numeric(k_youngest),
                               rel %in% R[c("married_child", "child_spouse")] & one_child_couple, as.numeric(g_youngest),
                               default = NA_real_)
    )]
    pdy[, c("k_n", "k_sons", "k_daus", "k_youngest", "g_n", "g_sons", "g_daus",
            "g_youngest", "one_child_couple") := NULL]
  }

  # ---- Keep diarists only (household composition above used the full roster) --------
  pdy <- pdy[has_diary == TRUE]

  # ---- Consumption quintile (weighted, all-India, per-capita) -----------------------
  pdy[, mpce_quintile := factor(NA_character_, levels = paste0("Q", 1:5))]
  if (any(!is.na(pdy$mpce))) {
    hhq <- unique(pdy[!is.na(mpce), .(hh_id, mpce, w = weight * hh_size)], by = "hh_id")
    br <- wquantile(hhq$mpce, hhq$w, probs = seq(0, 1, 0.2))
    br[1] <- -Inf; br[6] <- Inf
    pdy[, mpce_quintile := cut(mpce, br, labels = paste0("Q", 1:5), include.lowest = TRUE)]
  }

  data.table::setkey(pdy, pid)
  attr(pdy, "validation") <- V
  saveRDS(pdy, file.path(out_dir, "person_day.rds"))
  if (!is.null(pairs)) saveRDS(pairs, file.path(out_dir, "slot_pairs.rds"))
  writeLines(capture.output(str(V, give.attr = FALSE, vec.len = 10)),
             file.path(out_dir, "validation.txt"))
  say("Panel: %s person-days, %s households. Diaries summing to 1440: %.1f%%",
      format(nrow(pdy), big.mark = ","), format(V$n_households, big.mark = ","),
      100 * V$share_diaries_1440)
  invisible(pdy)
}

# Clock time ("04:30", "0430", 430, or minutes) -> minutes since 04:00, the
# start of the TUS diary day.
clock_to_min <- function(x) {
  x <- gsub("[^0-9]", "", as.character(x))
  v <- suppressWarnings(as.numeric(x))
  hh <- floor(v / 100); mm <- v %% 100
  m <- hh * 60 + mm
  ifelse(is.na(m), NA_real_, (m - 240) %% 1440)
}

# Weighted quantile (type-7 style on cumulative weights).
wquantile <- function(x, w, probs) {
  o <- order(x); x <- x[o]; w <- w[o]
  cw <- cumsum(w) / sum(w)
  vapply(probs, function(p) x[which(cw >= p)[1]], numeric(1))
}

# Load the cached panel, rebuilding when the microdata file is newer.
load_panel <- function(rebuild = FALSE) {
  f <- file.path(TUS_DERIVED, "person_day.rds")
  newer <- function(x) nzchar(x) && file.exists(x) && file.mtime(x) > file.mtime(f)
  if (rebuild || !file.exists(f) || newer(TUS_DTA) || newer(TUS_HH_DTA)) {
    if (!file.exists(TUS_DTA)) {
      stop("Microdata not found at ", TUS_DTA,
           ". Set TUS_DTA, or TUS_SYNTHETIC=1 to test on synthetic data.")
    }
    build_panel()
  }
  pd <- readRDS(f)
  sc <- attr(pd, "validation")$code_scheme
  if (!is.null(sc)) apply_code_scheme(sc)       # restore the scheme detected at build time
  pd
}

load_pairs <- function() {
  f <- file.path(TUS_DERIVED, "slot_pairs.rds")
  if (file.exists(f)) readRDS(f) else NULL
}

panel_validation <- function(pd) attr(pd, "validation")
