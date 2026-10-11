# =============================================================================
# codes.R -- single source of truth for every code used in the papers.
#
# All activity categories are defined on the ICATUS 2016 3-digit code
# (Activity_Code_3Digit), checked against docs/DataDictionaryTimeUseSurvey.xlsx.
# The 2-digit code in the microdata is the first two digits of the 3-digit
# code (verified on the real file: 2-digit 91 has mean episode length 222 min,
# i.e. night sleep 911). Papers must never hard-code activity codes; they use
# the vectors below.
#
# Legacy papers mis-mapped these codes (e.g. 31 = childcare, 71 = exercise,
# 81/82 = in-person/remote socialising, 1 = sleep, 9 = religion). All of those
# are wrong. See docs/AUDIT.md, Section 2.
# =============================================================================

source(file.path(TUS_ROOT, "R", "icatus_labels.R"))

# ---- ICATUS major divisions (1-digit) --------------------------------------
icatus_division <- c(
  "1" = "Employment and related activities",
  "2" = "Production of goods for own final use",
  "3" = "Unpaid domestic services for household members",
  "4" = "Unpaid caregiving services for household members",
  "5" = "Unpaid volunteer, trainee and other unpaid work",
  "6" = "Learning",
  "7" = "Socialising, communication, community participation, religious practice",
  "8" = "Culture, leisure, mass media and sports",
  "9" = "Self-care and maintenance"
)

# ---- Activity categories (3-digit codes) -----------------------------------
# Each element: integer vector of 3-digit codes. Categories within a block are
# mutually exclusive; blocks nest inside divisions.
rng <- function(a, b) seq.int(a, b)

ACT <- list(
  # Division 1: employment (SNA production for pay or profit)
  paid_work        = c(110, rng(121, 129), rng(131, 139), 141, 142, 150, 160, 170),
  work_travel      = c(181, 182),            # employment-related travel + commuting
  commuting        = 182,

  # Division 2: own-use production of goods (SNA, unpaid)
  ownuse_goods     = c(rng(211, 218), rng(221, 229), 230, 241, 242, 250),
  water_fuel       = c(241, 242),            # firewood + water fetching

  # Division 3: unpaid domestic services (non-SNA)
  dom_food         = rng(311, 319),
  dom_cleaning     = rng(321, 329),
  dom_repair       = rng(331, 339),
  dom_textiles     = rng(341, 349),
  dom_management   = rng(351, 359),          # bills, budgeting, planning
  dom_petcare      = rng(361, 369),
  dom_shopping     = c(371, 372),
  dom_travel       = 380,
  dom_other        = 390,

  # Division 4: unpaid caregiving for household members (non-SNA)
  care_child       = c(rng(411, 419), 442),  # incl. accompanying own children
  care_child_active  = rng(411, 415),        # physical, medical, teaching, talking, playing
  care_child_passive = 416,                  # minding children
  care_dep_adult   = c(rng(421, 429), 443),  # dependent adults (sick, elderly, disabled)
  care_nondep_adult = c(rng(431, 439), 444),
  care_other       = c(441, 490),

  # Division 5: volunteer and other unpaid work
  volunteer        = c(rng(511, 519), rng(521, 529), 530, 540, 590),

  # Division 6: learning
  learning         = c(rng(611, 619), 620, 630, 640, 690),

  # Division 7: socialising, community, religion
  socialising      = rng(711, 719),          # talking, getting together, mail
  community        = c(rng(721, 729), 730),
  religious        = rng(741, 749),
  social_other     = c(750, 790),

  # Division 8: culture, leisure, mass media, sports
  culture_events   = rng(811, 819),
  hobbies_games    = rng(821, 829),
  exercise_sport   = c(831, 832),            # participating in sports, exercising
  mass_media       = rng(841, 849),
  resting          = 850,
  leisure_other    = c(860, 890),

  # Division 9: self-care and maintenance
  sleep            = rng(911, 919),
  eating           = c(921, 922),
  hygiene          = rng(931, 939),
  receiving_care   = rng(941, 949),
  selfcare_other   = c(950, 990)
)

# ---- Aggregates ------------------------------------------------------------
ACT$employment       <- c(ACT$paid_work, ACT$work_travel)            # division 1
ACT$unpaid_domestic  <- c(ACT$dom_food, ACT$dom_cleaning, ACT$dom_repair,
                          ACT$dom_textiles, ACT$dom_management, ACT$dom_petcare,
                          ACT$dom_shopping, ACT$dom_travel, ACT$dom_other)  # division 3
ACT$unpaid_care      <- c(ACT$care_child, ACT$care_dep_adult,
                          ACT$care_nondep_adult, ACT$care_other)     # division 4
ACT$unpaid_total     <- c(ACT$unpaid_domestic, ACT$unpaid_care)      # SDG 5.4.1
ACT$routine_housework <- c(ACT$dom_food, ACT$dom_cleaning, ACT$dom_textiles)
ACT$social_all       <- c(ACT$socialising, ACT$community, ACT$religious, ACT$social_other)
ACT$leisure_all      <- c(ACT$culture_events, ACT$hobbies_games, ACT$exercise_sport,
                          ACT$mass_media, ACT$resting, ACT$leisure_other)
ACT$free_time        <- c(ACT$social_all, ACT$leisure_all)           # divisions 7 + 8
ACT$selfcare_all     <- c(ACT$sleep, ACT$eating, ACT$hygiene,
                          ACT$receiving_care, ACT$selfcare_other)    # division 9
ACT$total_work       <- c(ACT$employment, ACT$ownuse_goods,
                          ACT$unpaid_total, ACT$volunteer)           # SNA + non-SNA work

# Categories that must partition the day (used for the 1,440-minute check).
PARTITION <- c("employment", "ownuse_goods", "unpaid_domestic", "unpaid_care",
               "volunteer", "learning", "social_all", "leisure_all", "selfcare_all")

# ---- Codes for person and household attributes ------------------------------
CODE <- list(
  gender   = c(male = 1, female = 2, transgender = 3),
  sector   = c(rural = 1, urban = 2),
  marital  = c(never_married = 1, married = 2, widowed = 3, div_sep = 4),
  relation = c(head = 1, spouse = 2, married_child = 3, child_spouse = 4,
               unmarried_child = 5, grandchild = 6, parent_or_inlaw = 7,
               other_relative = 8, servant_nonrelative = 9),
  major_minor = c(major = 1, minor = 2),          # NOT 1/0
  yes_no      = c(yes = 1, no = 2),               # multiple/simultaneous flags
  day_of_week = c(Mon = 1, Tue = 2, Wed = 3, Thu = 4, Fri = 5, Sat = 6, Sun = 7),
  type_of_day = c(normal = 1, other = 2),
  location    = c(inside_dwelling = 1, outside_fixed = 2, outside_nonfixed = 3),
  washing     = c(mechanical = 1, manual = 2, outsourced = 3),
  sweeping    = c(mechanical = 1, manual = 2, outsourced = 3),
  religion = c(Hindu = 1, Muslim = 2, Christian = 3, Sikh = 4, Jain = 5,
               Buddhist = 6, Other = 7),
  social_group = c(ST = 1, SC = 2, OBC = 3, Other = 9),
  # Usual principal activity status, cooking and lighting fuel: scheme-dependent,
  # set by apply_code_scheme() (defaults to the official-dictionary scheme).
  # Highest education (dictionary has no code 09)
  edu_tier = list(
    "Not literate / below primary" = c(1, 2),
    "Primary / middle"             = c(3, 4),
    "Secondary / higher secondary" = c(5, 6, 7, 8),
    "Graduate and above"           = c(10, 11, 12)
  ),
  # Enterprise type (paid activities only)
  ent_formal    = c(3, 4, 5, 7),   # government, autonomous, ltd company, trust/NPI
  ent_informal  = c(1, 2, 6, 9),   # proprietary, partnership, co-op, others
  ent_household = 8                # employer's household (domestic workers)
)

# ---- Scheme-dependent codes ----------------------------------------------------
# docs/DataDictionaryTimeUseSurvey.xlsx ("nso") and docs/variables_dictionary.txt
# ("legacy_txt") disagree on the codes for usual principal activity status,
# cooking fuel and lighting. The microdata settle which one applies. build_panel()
# detects the scheme from the values present (see detect_code_scheme) and records
# it in validation.txt; load_panel() re-applies it. NEVER hard-code these codes in
# a manuscript: use CODE$pas_*, CODE$cooking_* and the factors built in the panel.
CODE_SCHEMES <- list(
  nso = list(                                   # official data dictionary (xlsx), NSS-style codes
    pas_employed = c(11, 12, 21, 31, 41, 51), pas_self_emp = c(11, 12), pas_helper = 21,
    pas_regular = 31, pas_casual = c(41, 51), pas_unemployed = 81, pas_student = 91,
    pas_domestic = c(92, 93), pas_pensioner = 94, pas_disabled = 95,
    cooking_lpg = 2, cooking_clean = c(2, 3, 7, 8, 11),   # LPG, other natural gas, gobar gas, other biogas, electricity
    cooking_solid = c(1, 4, 6, 10),                       # firewood, dung cake, coke/coal, charcoal
    lighting_electric = 1),
  legacy_txt = list(                            # docs/variables_dictionary.txt
    pas_employed = c(11, 12, 13, 21, 31, 41), pas_self_emp = c(11, 12), pas_helper = 13,
    pas_regular = 21, pas_casual = c(31, 41), pas_unemployed = 51, pas_student = 61,
    pas_domestic = c(62, 63), pas_pensioner = 64, pas_disabled = 65,
    cooking_lpg = 6, cooking_clean = c(6, 7, 8), cooking_solid = c(1, 2, 3, 4),
    lighting_electric = 3)
)
apply_code_scheme <- function(scheme) {
  stopifnot(scheme %in% names(CODE_SCHEMES))
  for (k in names(CODE_SCHEMES[[scheme]])) CODE[[k]] <<- CODE_SCHEMES[[scheme]][[k]]
  CODE_SCHEME <<- scheme
  invisible(scheme)
}
# Marker codes exist in only one dictionary. pas: 81/91-97 only in nso; 61-66 and 13
# only in legacy_txt. cooking: 10/11/12/19 only in nso; 9 only in legacy_txt.
detect_code_scheme <- function(pas, cooking = NULL) {
  pv <- unique(pas[!is.na(pas)]); cv <- if (is.null(cooking)) numeric() else unique(cooking[!is.na(cooking)])
  ev <- c(nso_pas = sum(pv %in% c(81, 91, 92, 93, 94, 95, 97)), legacy_pas = sum(pv %in% c(13, 61, 62, 63, 64, 65, 66)),
          nso_cook = sum(cv %in% c(10, 11, 12, 19)), legacy_cook = sum(cv %in% 9))
  n <- ev[["nso_pas"]] + ev[["nso_cook"]]; l <- ev[["legacy_pas"]] + ev[["legacy_cook"]]
  scheme <- if (n > 0 && l == 0) "nso" else if (l > 0 && n == 0) "legacy_txt" else "nso"
  list(scheme = scheme, conflicting = (n > 0 && l > 0), undetermined = (n == 0 && l == 0), evidence = ev)
}
apply_code_scheme("nso")

act_label <- function(code3) unname(icatus_labels[as.character(code3)])

# Ranges above are written as ICATUS blocks (e.g. 311:319); keep only codes that
# exist in the TUS 2024 dictionary, then check that the partition is exact.
ACT <- lapply(ACT, function(v) sort(intersect(v, as.integer(names(icatus_labels)))))
local({
  dict <- as.integer(names(icatus_labels))
  part <- unlist(ACT[PARTITION])
  if (any(duplicated(part))) stop("PARTITION categories overlap")
  missing <- setdiff(dict, part)
  if (length(missing)) stop("PARTITION misses dictionary codes: ",
                            paste(missing, collapse = ", "))
})
