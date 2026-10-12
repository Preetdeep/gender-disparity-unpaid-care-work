# Harmonised 2019 vs 2024 headline comparisons for papers 03, 05, 06, 07.
# Reads the 2019 person-day file built outside the repository from the TUS 2019
# unit-level data (never committed) and the 2024 panel; writes aggregates only.
# Usage: Rscript R/compare_2019.R   (env TUS2019_RDS points to the 2019 person-day .rds)
suppressMessages({library(data.table); library(fixest)})
TUS_ROOT <- getwd(); source("R/setup.R")
pd <- load_panel()
Y24 <- pd[sex %in% c("Men", "Women"), .(year = 2024, hh = hh_id, fsu = as.character(fsu), female, age, mar = as.integer(marital), rel = as.integer(rel),
          regular = as.integer(pas_group == "Regular wage/salaried"), dow = as.integer(dow), urban, state = as.character(state), w = weight,
          paid = employment, dom = unpaid_domestic, care = unpaid_care, cc = care_child, ac = care_dep_adult,
          free = free_time, sleep, n_u6 = hh_n_under6)]
X <- readRDS(Sys.getenv("TUS2019_RDS", path.expand("~/GResearcher_runs/tus2019/tus2019_personday.rds")))
Y19 <- X[, .(year = 2019, hh, fsu = substr(hh, 1, 5), female, age, mar, rel, regular, dow, urban, state, w,
             paid, dom, care, cc, ac, free, sleep, n_u6)]
A <- rbind(Y24, Y19)
A[, `:=`(unpaid = dom + care, sunday = as.integer(dow == 7), saturday = as.integer(dow == 6))]
out <- list()
add <- function(paper, stat, year, est, se = NA_real_, n = NA_integer_)
  out[[length(out) + 1]] <<- data.table(paper, stat, year, est, se, n)
for (y in c(2019, 2024)) {
  D <- A[year == y]
  # 05: married minus never-married unpaid minutes, ages 20-39
  for (s in 0:1) {
    d <- D[female == s & age >= 20 & age <= 39 & mar %in% 1:2]
    m <- feols(unpaid ~ I(mar == 2) + urban | age + state + dow, d, weights = ~w, cluster = ~fsu)
    add("05", paste0("married_gap_", ifelse(s == 1, "women", "men")), y, coef(m)[1], se(m)[1], nobs(m))
  }
  # 06: girls minus boys domestic minutes, children of the head aged 10-17, within household
  d <- D[age >= 10 & age <= 17 & rel %in% c(3, 5)]
  d <- d[, if (uniqueN(female) == 2) .SD, by = hh]
  m <- feols(dom ~ female | hh + age + dow, d, weights = ~w, cluster = ~fsu)
  add("06", "girl_gap_domestic_sibfe", y, coef(m)[1], se(m)[1], nobs(m))
  # 07: Sunday IV for regular salaried men 20-59
  d <- D[female == 0 & regular == 1 & age >= 20 & age <= 59]
  fs <- feols(paid ~ sunday + saturday + urban | age + state, d, weights = ~w, cluster = ~fsu)
  add("07", "first_stage_sunday", y, coef(fs)["sunday"], se(fs)["sunday"], nobs(fs))
  for (v in c("unpaid", "free", "sleep")) {
    iv <- feols(as.formula(paste(v, "~ saturday + urban | age + state | paid ~ sunday")), d, weights = ~w, cluster = ~fsu)
    add("07", paste0("per100_", v), y, -100 * coef(iv)["fit_paid"], 100 * se(iv)["fit_paid"], nobs(iv))
  }
  # 03: women's share of care minutes (15+)
  d <- D[age >= 15]
  add("03", "women_share_adultcare_all", y, d[, sum(ac * w * female) / sum(ac * w)], NA, nrow(d))
  add("03", "women_share_childcare_u6hh", y, d[n_u6 > 0, sum(cc * w * female) / sum(cc * w)], NA, d[n_u6 > 0, .N])
  add("03", "share_any_adultcare_women", y, d[female == 1, weighted.mean(ac > 0, w)], NA, d[female == 1, .N])
  add("03", "share_any_adultcare_men", y, d[female == 0, weighted.mean(ac > 0, w)], NA, d[female == 0, .N])
  add("all", "n_persondays", y, nrow(D), NA, nrow(D))
}
R <- rbindlist(out)
fwrite(R, "submission/_common/tus_2019_2024_compare.csv")
print(R)
