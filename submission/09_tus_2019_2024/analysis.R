# =============================================================================
# Paper 09: India TUS 2019 vs 2024. All estimates for the manuscript.
# Reads the harmonised person-day panels (2024: build_panel.R; 2019:
# build_panel_2019.R), writes AGGREGATES ONLY to data/derived/tus1924_results.rds.
# Usage (from repo root): Rscript submission/09_tus_2019_2024/analysis.R
# =============================================================================
if (!exists("TUS_ROOT")) TUS_ROOT <- normalizePath(".")
source(file.path(TUS_ROOT, "R", "setup.R")); source(file.path(TUS_ROOT, "R", "build_panel_2019.R"))
set.seed(20191924)

OUT <- c("employment", "ownuse_goods", "sna", "unpaid_domestic", "unpaid_care", "care_child", "care_dep_adult",
         "unpaid_total", "volunteer", "total_work", "learning", "social_all", "leisure_all", "free_time",
         "mass_media", "selfcare_all", "sleep", "eating", "hygiene", "water_fuel", "dom_food", "dom_cleaning")
keep <- c("pid", "hh_id", "fsu", "female", "age", "urban", "married", "marital", "edu_tier", "pas_group", "employed",
          "state", "dow", "type_day", "sub_round", "hh_size", "hh_n_under6", "has_under6", "umpce", "mpce",
          "social_group", "religion", "weight", "rel", setdiff(OUT, "sna"))
Y <- load_panel()[, intersect(keep, names(load_panel())), with = FALSE]
Y[, self_report := NA_integer_]; Y[, year := 2024L]
Y24p <- load_panel(); Y[, self_report := as.integer(Y24p$proxy_report == 0)]; V24 <- panel_validation(Y24p); rm(Y24p)
X0 <- load_panel_2019(); V19 <- attr(X0, "validation")
X0[, `:=`(hh_n_under6_direct = hh_n_under6, has_under6_direct = has_under6)]
X0[, `:=`(hh_n_under6 = hh_n_under6_resid, has_under6 = as.integer(hh_n_under6_resid > 0))]  # harmonised with 2024
keep <- c(keep, "has_under6_direct")
X <- X0[, intersect(keep, names(X0)), with = FALSE]; X[, self_report := as.integer(X0$informant_rel == 1)]; X[, year := 2019L]; rm(X0)
X[, `:=`(fsu = as.character(fsu))]; Y[, fsu := as.character(fsu)]
X[, state := as.integer(state)]; Y[, state := as.integer(state)]
# Harmonise state codes to 2019 boundaries: Ladakh (37, from Oct 2019) -> J&K (1);
# Dadra & Nagar Haveli (26) and Daman & Diu (25) merged in 2020 -> 25.
Y[state == 37, state := 1L]; X[state == 26, state := 25L]; Y[state == 26, state := 25L]
P <- rbind(X, Y, fill = TRUE); rm(X, Y); invisible(gc())
P[, sna := employment + ownuse_goods]
P[, `:=`(cl = paste(year, fsu), y24 = as.integer(year == 2024L))]
P <- P[age >= 15 & !is.na(dow) & weight > 0]
P[, w := weight / mean(weight), by = year]                  # each year keeps its own sample size
P[, age_g := cut(age, c(14, 29, 44, 59, Inf), labels = c("15-29", "30-44", "45-59", "60+"))]
P[, edu_g := fcase(edu_tier %in% c("Not literate / below primary"), "Below primary",
                   edu_tier %in% c("Primary / middle"), "Primary or middle",
                   edu_tier %in% c("Secondary / higher secondary"), "Secondary",
                   edu_tier %in% c("Graduate and above"), "Graduate", default = NA_character_)]
P[, edu_g := factor(edu_g, c("Below primary", "Primary or middle", "Secondary", "Graduate"))]
P[, hhs_g := pmin(hh_size, 8)]
# Consumption quintiles within year (household per-capita usual monthly expenditure, person-weighted)
for (yy in c(2019L, 2024L)) {
  h <- unique(P[year == yy & !is.na(mpce), .(hh_id, mpce, ww = weight * hh_size)], by = "hh_id")
  br <- wquantile(h$mpce, h$ww, seq(0, 1, .2)); br[1] <- -Inf; br[6] <- Inf
  P[year == yy, mpce_q := cut(mpce, br, labels = paste0("Q", 1:5), include.lowest = TRUE)]
}
P[, sex := factor(ifelse(female == 1, "Women", "Men"), c("Women", "Men"))]
P[, status4 := fcase(pas_group %in% c("Self-employed"), "Self-employed",
                     pas_group %in% c("Unpaid family helper"), "Unpaid family helper",
                     pas_group %in% c("Regular wage/salaried"), "Regular wage/salaried",
                     pas_group %in% c("Casual labour"), "Casual labour",
                     pas_group %in% c("Domestic duties"), "Domestic duties",
                     pas_group %in% c("Student"), "Student",
                     default = "Other (unemployed, not working)")]
P[, status4 := factor(status4, c("Self-employed", "Unpaid family helper", "Regular wage/salaried", "Casual labour",
                                 "Domestic duties", "Student", "Other (unemployed, not working)"))]
R <- list()
R$N <- P[, .N, by = .(year, sex)]
R$N_hh <- P[, uniqueN(hh_id), by = year]; R$N_fsu <- P[, uniqueN(fsu), by = year]
R$V19 <- V19[c("share_hh_under6_resid_agrees", "n_activity_rows", "n_roster", "n_roster_6plus", "n_diarists", "share_diaries_1440", "n_missing_dow", "n_third_gender_excluded")]
R$V24 <- V24[c("n_rows", "n_roster_6plus", "n_diarists", "share_diaries_1440", "n_third_gender")]

# ---- helpers -------------------------------------------------------------------
wm <- function(x, w) sum(x * w) / sum(w)
yr_diff <- function(d, y) {      # 2024 minus 2019, survey-weighted, FSU-clustered
  m <- feols(as.formula(paste(y, "~ y24")), d, weights = ~w, cluster = ~cl)
  ct <- coeftable(m)
  list(m19 = unname(coef(m)[1]), m24 = unname(coef(m)[1] + coef(m)[2]), d = unname(ct[2, 1]), se = unname(ct[2, 2]), p = unname(ct[2, 4]))
}
did <- function(d, y) {          # change in the women-minus-men gap
  m <- feols(as.formula(paste(y, "~ female * y24")), d, weights = ~w, cluster = ~cl)
  ct <- coeftable(m)
  list(gap19 = unname(coef(m)["female"]), gap24 = unname(coef(m)["female"] + coef(m)["female:y24"]),
       d = unname(ct["female:y24", 1]), se = unname(ct["female:y24", 2]), p = unname(ct["female:y24", 4]))
}

# ---- 1. Sample composition --------------------------------------------------------
comp <- function(d) d[, .(N = .N, age = wm(age, w), urban = wm(urban, w), married = wm(married == 1, w),
                          graduate = wm(edu_g %in% "Graduate", w), below_primary = wm(edu_g %in% "Below primary", w),
                          employed = wm(employed == 1, w), under6 = wm(has_under6 %in% 1, w),
                          normal_day = wm(type_day == 1, w), self_report = wm(self_report %in% 1, w),
                          sunday = wm(dow == 7, w)), by = .(sex, year)]
R$comp <- comp(P)

# ---- 2. Mean minutes, change by sex, and change in the gender gap ---------------------
tab_change <- function(d) rbindlist(lapply(OUT, function(y) {
  w_ <- yr_diff(d[female == 1], y); m_ <- yr_diff(d[female == 0], y); g <- did(d, y)
  data.table(var = y, w19 = w_$m19, w24 = w_$m24, wd = w_$d, wse = w_$se, wp = w_$p,
             m19 = m_$m19, m24 = m_$m24, md = m_$d, mse = m_$se, mp = m_$p,
             gap19 = g$gap19, gap24 = g$gap24, gd = g$d, gse = g$se, gp = g$p)
}))
R$change <- tab_change(P)
R$change_1559 <- tab_change(P[age <= 59])
R$change_normal <- tab_change(P[type_day == 1])
R$change_self <- tab_change(P[self_report == 1])
R$change_weekday <- tab_change(P[dow <= 5])

# ---- 3. Participation (extensive) and minutes per participant (intensive) --------------
pi_tab <- rbindlist(lapply(c("employment", "ownuse_goods", "sna", "unpaid_domestic", "unpaid_care", "care_child", "unpaid_total", "free_time"), function(y) {
  P[, .(p = wm(get(y) > 0, w), mpp = sum((get(y)) * w * (get(y) > 0)) / sum(w * (get(y) > 0)), mean = wm(get(y), w)), by = .(sex, year)][, var := y][]
}))
pi_tab <- dcast(pi_tab, var + sex ~ year, value.var = c("p", "mpp", "mean"))
pi_tab[, `:=`(dmean = mean_2024 - mean_2019,
              ext = (p_2024 - p_2019) * (mpp_2024 + mpp_2019) / 2,
              int = (mpp_2024 - mpp_2019) * (p_2024 + p_2019) / 2)]
R$pi <- pi_tab
R$p_emp_se <- list(w = yr_diff(P[female == 1][, pe := as.integer(employment > 0)], "pe"),
                   m = yr_diff(P[female == 0][, pe := as.integer(employment > 0)], "pe"))
R$emp_status_se <- list(w = yr_diff(P[female == 1][, es := as.integer(employed == 1)], "es"),
                        m = yr_diff(P[female == 0][, es := as.integer(employed == 1)], "es"))

# ---- 4. Shift-share by usual principal activity status (women and men) ---------------------
ss <- function(d, y) {
  s <- d[, .(n = .N, sh = sum(w), m = wm(get(y), w)), by = .(year, status4)]
  s[, sh := sh / sum(sh), by = year]
  s <- dcast(s, status4 ~ year, value.var = c("sh", "m", "n"))
  s[, `:=`(between = (sh_2024 - sh_2019) * (m_2024 + m_2019) / 2, within = (m_2024 - m_2019) * (sh_2024 + sh_2019) / 2)]
  s[, var := y][]
}
R$ss_w <- rbindlist(lapply(c("employment", "sna", "unpaid_total", "unpaid_domestic", "unpaid_care", "free_time", "selfcare_all", "total_work"), function(y) ss(P[female == 1], y)))
R$ss_m <- rbindlist(lapply(c("employment", "sna", "unpaid_total", "free_time", "selfcare_all", "total_work"), function(y) ss(P[female == 0], y)))
# within-status changes with SEs, women: employment and unpaid
R$within_w <- rbindlist(lapply(levels(P$status4), function(s) rbindlist(lapply(c("employment", "sna", "unpaid_total"), function(y) {
  r <- yr_diff(P[female == 1 & status4 == s], y); data.table(status4 = s, var = y, d = r$d, se = r$se, p = r$p)
}))))

# ---- 5. Heterogeneity: who changed ------------------------------------------------------
grp <- list(urban = c("Rural" = 0, "Urban" = 1))
het <- function(lab, sub) {
  d <- P[eval(sub)]
  out <- lapply(c("employment", "sna", "unpaid_total", "care_child", "free_time"), function(y) {
    a <- yr_diff(d[female == 1], y); b <- yr_diff(d[female == 0], y); g <- did(d, y)
    data.table(group = lab, var = y, w19 = a$m19, w24 = a$m24, wd = a$d, wse = a$se, m19 = b$m19, m24 = b$m24, md = b$d, mse = b$se, gd = g$d, gse = g$se)
  })
  rbindlist(out)[, n := nrow(d)][]
}
H <- list(
  het("Rural", quote(urban == 0)), het("Urban", quote(urban == 1)),
  het("Age 15-29", quote(age_g == "15-29")), het("Age 30-44", quote(age_g == "30-44")),
  het("Age 45-59", quote(age_g == "45-59")), het("Age 60+", quote(age_g == "60+")),
  het("Below primary", quote(edu_g == "Below primary")), het("Primary or middle", quote(edu_g == "Primary or middle")),
  het("Secondary", quote(edu_g == "Secondary")), het("Graduate", quote(edu_g == "Graduate")),
  het("Married", quote(married == 1)), het("Not married", quote(married == 0)),
  het("Child under 6 in household", quote(has_under6 %in% 1)), het("No child under 6", quote(has_under6 %in% 0)),
  het("Consumption Q1 (poorest)", quote(mpce_q == "Q1")), het("Consumption Q5 (richest)", quote(mpce_q == "Q5")))
R$het <- rbindlist(H)

# ---- 6. Composition: DFL reweighting of 2019 to the 2024 covariate distribution -----------
dfl <- function(d, y) {
  d <- d[!is.na(edu_g) & !is.na(mpce_q) & !is.na(hh_n_under6)]
  f <- y24 ~ age_g * urban + edu_g * urban + factor(marital) + factor(hhs_g) + has_under6 + factor(state) + mpce_q + factor(sub_round) + factor(dow)
  lg <- feglm(f, d, family = binomial(), weights = ~w)
  ph <- predict(lg, d)
  pbar <- d[, sum(w * y24) / sum(w)]
  d[, wd := ifelse(y24 == 1, w, w * (ph / (1 - ph)) * ((1 - pbar) / pbar))]
  rbindlist(lapply(y, function(v) {
    raw <- feols(as.formula(paste(v, "~ y24")), d, weights = ~w, cluster = ~cl)
    adj <- feols(as.formula(paste(v, "~ y24")), d, weights = ~wd, cluster = ~cl)
    data.table(var = v, raw = coef(raw)[2], raw_se = se(raw)[2], adj = coef(adj)[2], adj_se = se(adj)[2],
               m19_rw = coef(adj)[1], ess_ratio = d[y24 == 0, sum(wd)^2 / sum(wd^2)] / d[y24 == 0, sum(w)^2 / sum(w^2)])
  }))
}
vv <- c("employment", "ownuse_goods", "sna", "unpaid_domestic", "unpaid_care", "care_child", "unpaid_total", "total_work", "free_time", "selfcare_all")
R$dfl_w <- dfl(P[female == 1], vv); R$dfl_m <- dfl(P[female == 0], vv)
R$dfl_note <- "DFL weights from a weighted logit of year on age group x sector, education x sector, marital status, household size, child under 6, state, consumption quintile, sub-round and day of week."

# ---- 7. 1,440-minute accounting: all nine ICATUS divisions ------------------------------
divs <- c("employment", "ownuse_goods", "unpaid_domestic", "unpaid_care", "volunteer", "learning", "social_all", "leisure_all", "selfcare_all")
R$div <- rbindlist(lapply(divs, function(y) {
  a <- yr_diff(P[female == 1], y); b <- yr_diff(P[female == 0], y)
  data.table(var = y, w19 = a$m19, w24 = a$m24, wd = a$d, wse = a$se, m19 = b$m19, m24 = b$m24, md = b$d, mse = b$se)
}))
R$div_check <- R$div[, .(w19 = sum(w19), w24 = sum(w24), m19 = sum(m19), m24 = sum(m24))]

# ---- 8. Women's age profiles for the figure -----------------------------------------------
P[, age5 := cut(age, c(14, 19, 24, 29, 34, 39, 44, 49, 54, 59, 64, Inf), labels = c("15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65+"))]
R$age_prof <- P[, .(employment = wm(employment, w), unpaid_total = wm(unpaid_total, w), sna = wm(sna, w), n = .N), by = .(sex, year, age5)][order(sex, year, age5)]

# ---- 9. Regression: within-household-type change in women's unpaid work vs employment ------------
# Among women, is more employment associated with less unpaid work, and did that trade-off change?
m_tr <- feols(unpaid_total ~ employment * y24 + i(age_g) + urban + i(edu_g) + married + has_under6 + factor(hhs_g) | state^year + dow + sub_round,
              P[female == 1], weights = ~w, cluster = ~cl)
R$tradeoff <- coeftable(m_tr)[c("employment", "employment:y24"), ]
m_tr2 <- feols(sna ~ y24 + i(age_g) + urban + i(edu_g) + married + has_under6 + factor(hhs_g) | state + dow + sub_round, P[female == 1], weights = ~w, cluster = ~cl)
R$sna_cond <- coeftable(m_tr2)["y24", ]

# ---- 10. Benchmarks against published figures, and direct vs residual under-6 in 2019 --------------
R$p_emp_1559 <- P[age <= 59, .(p = wm(employment > 0, w)), by = .(sex, year)]
R$u6_check <- P[year == 2019, .(resid = wm(has_under6, w), direct = wm(has_under6_direct, w))]
R$het_u6_direct <- rbindlist(list(het("Child under 6 (direct count, 2019)", quote(year == 2024 & has_under6 == 1 | year == 2019 & has_under6_direct == 1))))
R$saved <- format(Sys.time())
saveRDS(R, file.path(TUS_DERIVED, "tus1924_results.rds"))
cat("saved\n")
print(R$change[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 1) else x)])
print(R$div_check)
