# Paper 10: Counting women's work in India, PLFS 2017-18 vs 2023-24
# Reads unit-level PLFS first-visit files (kept OUTSIDE the repo) and writes
# all estimates used in the manuscript to an .rds file (also outside the repo).
# Usage: Rscript analysis.R   (env PLFS_RAW, PLFS_OUT optional)
suppressMessages({library(data.table); library(survey)})
options(survey.lonely.psu = "adjust")
RAW <- Sys.getenv("PLFS_RAW", path.expand("~/GResearcher_runs/data_raw"))
OUT <- Sys.getenv("PLFS_OUT", path.expand("~/GResearcher_runs/data_derived/plfs10"))
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

rd <- function(f, suf) {
  d <- fread(f, colClasses = "character", showProgress = FALSE)
  setnames(d, tolower(sub(paste0(suf, "$"), "", names(d), ignore.case = TRUE)))
  d
}
num <- function(x) suppressWarnings(as.numeric(x))

# ---------- person files (first visit: all rural + urban first-visit households) ----------
p17 <- rd(file.path(RAW, "plfs1718/CSV_PLFS_July2017_June2018/hh_per_fv_2017-18.csv"), "_per_fv")
p23 <- rd(file.path(RAW, "plfs2324/CSV_data_PLFS_2023_2024/perv1.csv"), "_perv1")
h17 <- rd(file.path(RAW, "plfs1718/CSV_PLFS_July2017_June2018/hhfv_2017-18.csv"), "_hh_fv")
h23 <- rd(file.path(RAW, "plfs2324/CSV_data_PLFS_2023_2024/hhv1.csv"), "_hhv1")
setnames(p17, c("fsu", "quarter"), c("b1q1", "qtr"))

prep <- function(p, h, year) {
  hk <- c("qtr", "b1q3", "b1q1", "b1q13", "b1q14", "b1q15")
  hcons <- if ("b3q5pt6" %in% names(h)) "b3q5pt6" else "b3q5"
  hh <- h[, c(hk, "b3q1", "b3q2", "b3q3", "b3q4", hcons), with = FALSE]
  setnames(hh, c(hk, "hhsize", "hhtype", "relig", "socgrp", "hce"))
  p <- merge(p, hh, by = hk, all.x = TRUE)
  hrs <- paste0("b6q7_3pt", 1:7)
  d <- data.table(
    year = year, qtr = p$qtr, sector = as.integer(p$b1q3), state = as.integer(p$state),
    strat = paste(p$state, p$b1q3, p$b1q5, p$b1q6, sep = "_"),
    psu = paste(year, p$qtr, p$b1q1, sep = "_"),
    hhid = paste(year, p$qtr, p$b1q1, p$b1q13, p$b1q14, p$b1q15, sep = "_"),
    sex = as.integer(p$b4q5), age = as.integer(p$b4q6), marst = as.integer(p$b4q7),
    gedu = as.integer(p$b4q8),
    pas = num(p$b5pt1q3), ind_pas = substr(p$b5pt1q5, 1, 2), has_sas = num(p$b5pt1q7),
    sas = num(p$b5pt2q3), ind_sas = substr(p$b5pt2q5, 1, 2),
    eco_pas = if ("b5pt1q14" %in% names(p)) num(p$b5pt1q14) else NA_real_,
    eco_sas = if ("b5pt2q13" %in% names(p)) num(p$b5pt2q13) else NA_real_,
    cws = num(p$b6q5),
    hours = rowSums(sapply(hrs, function(v) { x <- num(p[[v]]); x[is.na(x)] <- 0; x })),
    hhsize = num(p$hhsize), hhtype = num(p$hhtype), socgrp = num(p$socgrp), relig = num(p$relig), hce = num(p$hce),
    nss = num(p$nss), nsc = num(p$nsc), mult = num(p$mult), noq = num(p$no_qtr))
  d[, w := ifelse(nss == nsc, mult / 100, mult / 200) / noq]
  d
}
D <- rbind(prep(p17, h17, 2017L), prep(p23, h23, 2023L))
rm(p17, p23, h17, h23); invisible(gc())
stopifnot(!anyNA(D$w), !anyNA(D$sex), !anyNA(D$age))

# ---------- usual status (ps+ss) classification, following the NSO estimation procedure ----------
D[, ps_work := pas >= 11 & pas <= 51]
D[, ss_only := !ps_work & has_sas == 1 & !is.na(sas) & sas >= 11 & sas <= 51]
D[, worker := ps_work | ss_only]
D[, unemp := !worker & pas == 81]
D[, inlf := worker | unemp]
D[, st := fifelse(ps_work, pas, fifelse(ss_only, sas, NA_real_))]
D[, ind2 := fifelse(ps_work, ind_pas, fifelse(ss_only, ind_sas, NA_character_))]
D[, agri := worker & as.integer(ind2) %in% 1:3]
D[, status := fcase(st %in% c(11, 12), "own", st == 21, "help", st == 31, "reg", st %in% c(41, 51), "cas", default = NA_character_)]
D[, eco := fifelse(ps_work, eco_pas, fifelse(ss_only, eco_sas, NA_real_))]
# indicators (0/1), each a share of the population
for (s in c("own", "help", "reg", "cas")) {
  D[, paste0("s_", s) := as.numeric(worker & status == s)]
  D[, paste0("s_", s, "_ps") := as.numeric(ps_work & status == s)]
  D[, paste0("s_", s, "_ss") := as.numeric(ss_only & status == s)]
  D[, paste0("s_", s, "_ag") := as.numeric(worker & status == s & agri)]
  D[, paste0("s_", s, "_na") := as.numeric(worker & status == s & !agri)]
}
D[, `:=`(lfpr = as.numeric(inlf), wpr = as.numeric(worker), ps = as.numeric(ps_work), ss = as.numeric(ss_only),
         ag = as.numeric(agri), nag = as.numeric(worker & !agri),
         d92 = as.numeric(pas == 92), d93 = as.numeric(pas == 93), edu = as.numeric(pas == 91),
         cws_emp = as.numeric(!is.na(cws) & cws >= 11 & cws <= 72),
         cws_lf = as.numeric(!is.na(cws) & cws >= 11 & cws <= 82))]
D[, agegrp := cut(age, c(-1, 14, 24, 34, 44, 59, 200), labels = c("0-14", "15-24", "25-34", "35-44", "45-59", "60+"))]
D[, edu4 := fcase(gedu <= 5, "Below primary", gedu %in% 6:7, "Primary or middle",
                  gedu %in% c(8, 10, 11), "Secondary or higher secondary", gedu >= 12, "Graduate or above")]
D[, sexl := fifelse(sex == 1, "Men", fifelse(sex == 2, "Women", "Other"))]
D[, secl := fifelse(sector == 1, "Rural", "Urban")]
# household monthly per capita consumption quintile (within year x sector, person-weighted)
D[, mpce := hce / hhsize]
wq <- function(x, w) { o <- order(x); cw <- cumsum(w[o]) / sum(w[o]); q <- integer(length(x)); q[o] <- pmin(5L, 1L + floor(cw * 5 - 1e-9)); q }
D[!is.na(mpce), mpceq := wq(mpce, w), by = .(year, sector)]
D[, socl := fcase(socgrp == 1, "Scheduled Tribe", socgrp == 2, "Scheduled Caste", socgrp == 3, "Other Backward Class", socgrp == 9, "Others")]

A <- D[age >= 15 & sex %in% 1:2]
A[, state := fifelse(state == 37L, 1L, fifelse(state == 26L, 25L, state))]
N <- A[, .(n = .N, popm = sum(w) / 1e6), by = .(year, secl, sexl)]

# ---------- survey design and estimates ----------
inds <- c("lfpr", "wpr", "ps", "ss", "ag", "nag", "d92", "d93", "edu", "cws_emp", "cws_lf",
          grep("^s_", names(D), value = TRUE))
est <- function(dat, by = c("secl")) {
  out <- list()
  for (y in c(2017L, 2023L)) {
    dd <- dat[year == y]
    des <- svydesign(ids = ~psu, strata = ~strat, weights = ~w, data = dd, nest = TRUE)
    f <- as.formula(paste("~", paste(inds, collapse = "+")))
    r1 <- svyby(f, as.formula(paste("~", paste(by, collapse = "+"))), des, svymean, na.rm = TRUE)
    r2 <- svymean(f, des, na.rm = TRUE)
    m <- as.data.table(r1)
    long <- rbindlist(lapply(inds, function(v) data.table(m[, ..by], var = v, est = m[[v]], se = m[[paste0("se.", v)]])))
    tot <- data.table(var = inds, est = coef(r2), se = SE(r2))
    for (b in by) tot[, (b) := "Total"]
    out[[as.character(y)]] <- rbind(long, tot, use.names = TRUE)[, year := y]
  }
  r <- rbindlist(out)
  w <- dcast(r, as.formula(paste(paste(by, collapse = "+"), "+ var ~ year")), value.var = c("est", "se"))
  setnames(w, c("est_2017", "est_2023", "se_2017", "se_2023"), c("y17", "y23", "se17", "se23"))
  w[, `:=`(d = y23 - y17, se_d = sqrt(se17^2 + se23^2))]
  w[, c("y17", "y23", "d", "se17", "se23", "se_d") := lapply(.SD, function(x) 100 * x), .SDcols = c("y17", "y23", "d", "se17", "se23", "se_d")]
  w[]
}
cat("Estimating women...\n")
EW <- est(A[sex == 2])
cat("Estimating men...\n")
EM <- est(A[sex == 1])
# unemployment rate (UR) = unemployed / labour force
ur <- A[, .(ur = 100 * sum(w * unemp) / sum(w * inlf), ur_cws = 100 * sum(w * (cws >= 81 & cws <= 82), na.rm = TRUE) / sum(w * cws_lf)), by = .(year, sexl, secl)]
ur <- rbind(ur, A[, .(secl = "Total", ur = 100 * sum(w * unemp) / sum(w * inlf), ur_cws = 100 * sum(w * (cws >= 81 & cws <= 82), na.rm = TRUE) / sum(w * cws_lf)), by = .(year, sexl)])

# published PLFS headline figures (NSO press note on the Annual Report July 2023-June 2024, 23 Sep 2024, Tables 1-6; usual status ps+ss and CWS, age 15+)
PUB <- data.table(
  ind = rep(c("LFPR", "WPR", "UR", "LFPR_CWS", "WPR_CWS"), each = 12),
  year = rep(rep(c(2017L, 2023L), each = 6), 5),
  secl = rep(rep(c("Rural", "Rural", "Urban", "Urban", "Total", "Total"), 2), 5),
  sexl = rep(c("Men", "Women"), 30),
  pub = c(76.4, 24.6, 74.5, 20.4, 75.8, 23.3,  80.2, 47.6, 75.6, 28.0, 78.8, 41.7,
          72.0, 23.7, 69.3, 18.2, 71.2, 22.0,  78.1, 46.5, 72.3, 26.0, 76.3, 40.3,
           5.7,  3.8,  6.9, 10.8,  6.1,  5.6,   2.7,  2.1,  4.4,  7.1,  3.2,  3.2,
          75.6, 21.7, 74.1, 19.6, 75.1, 21.1,  78.7, 39.7, 75.0, 26.1, 77.5, 35.6,
          69.1, 20.1, 67.7, 17.1, 68.6, 19.2,  75.3, 38.1, 70.5, 23.9, 73.8, 33.8))
mine <- rbind(
  rbind(EW[, .(sexl = "Women", secl, var, y17, y23)], EM[, .(sexl = "Men", secl, var, y17, y23)])[var %in% c("lfpr", "wpr", "cws_lf", "cws_emp")] |>
    melt(id.vars = c("sexl", "secl", "var"), variable.name = "yy", value.name = "est"),
  melt(ur, id.vars = c("year", "sexl", "secl"), variable.name = "var", value.name = "est")[, yy := fifelse(year == 2017, "y17", "y23")][, year := NULL])
mine[, year := fifelse(yy == "y17", 2017L, 2023L)]
mine[, ind := c(lfpr = "LFPR", wpr = "WPR", cws_lf = "LFPR_CWS", cws_emp = "WPR_CWS", ur = "UR", ur_cws = "UR_CWS")[as.character(var)]]
VAL <- merge(PUB, mine[, .(ind, year, secl, sexl, est)], by = c("ind", "year", "secl", "sexl"))
VAL[, diff := round(est, 1) - pub]

# ---------- intensity: current weekly status and hours actually worked in the reference week ----------
inten <- function(dat) {
  dat[worker == TRUE, .(share_cws = 100 * sum(w * cws_emp) / sum(w), hours = sum(w * hours) / sum(w),
                         hours_cws = sum(w * hours * cws_emp) / sum(w * cws_emp),
                         lt20 = 100 * sum(w * (hours < 20)) / sum(w), popshare = sum(w)), by = .(year, grp)]
}
A[, cap := fifelse(ps_work, "Principal", fifelse(ss_only, "Subsidiary only", NA_character_))]
IW <- rbind(
  inten(A[sex == 2][, grp := paste(status, cap, sep = ":")]),
  inten(A[sex == 2][, grp := paste0("all:", secl)]),
  inten(A[sex == 2][, grp := "all:Total"]),
  inten(A[sex == 1][, grp := "men:Total"]))
# average weekly hours of work per person in the population (workers and non-workers)
HP <- A[, .(hrs_pc = sum(w * hours * cws_emp) / sum(w), wpr = 100 * sum(w * worker) / sum(w), cws = 100 * sum(w * cws_emp) / sum(w)), by = .(year, sexl, secl)]
HP <- rbind(HP, A[, .(secl = "Total", hrs_pc = sum(w * hours * cws_emp) / sum(w), wpr = 100 * sum(w * worker) / sum(w), cws = 100 * sum(w * cws_emp) / sum(w)), by = .(year, sexl)])
# SE for hours per woman (ratio of totals via svyby)
hpse <- rbindlist(lapply(c(2017L, 2023L), function(y) {
  dd <- A[year == y & sex == 2][, hw := hours * cws_emp]
  des <- svydesign(ids = ~psu, strata = ~strat, weights = ~w, data = dd, nest = TRUE)
  r <- svymean(~hw, des); data.table(year = y, hrs = coef(r), se = SE(r))
}))

# ---------- destination of output (2023-24 only; asked of self-employed in NIC divisions 01-09) ----------
ECO <- A[year == 2023 & worker & status %in% c("own", "help") & as.integer(ind2) %in% 1:9 & !is.na(eco),
         .(n = .N, w = sum(w)), by = .(sexl, secl, cap, eco)]
ECO[, pct := 100 * w / sum(w), by = .(sexl, secl, cap)]
ECOt <- A[year == 2023 & worker & status %in% c("own", "help") & as.integer(ind2) %in% 1:9 & !is.na(eco),
          .(n = .N, w = sum(w)), by = .(sexl, eco)][, pct := 100 * w / sum(w), by = sexl][]
ECOcov <- A[year == 2023 & worker & status %in% c("own", "help") & as.integer(ind2) %in% 1:9, .(miss = 100 * sum(w * is.na(eco)) / sum(w)), by = sexl]
# share of the increase in women's WPR accounted for by self-employed in agriculture producing only or mainly for own use (2023 level)
ou <- function(d) d[, .(own1 = 100 * sum(w * (worker & status %in% c("own", "help") & as.integer(ind2) %in% 1:9 & eco %in% 1), na.rm = TRUE) / sum(w),
                        own12 = 100 * sum(w * (worker & status %in% c("own", "help") & as.integer(ind2) %in% 1:9 & eco %in% 1:2), na.rm = TRUE) / sum(w),
                        wpr = 100 * sum(w * worker) / sum(w))]
OWNUSE <- rbind(A[year == 2023, ou(.SD), by = .(sexl, secl)], A[year == 2023, ou(.SD), by = sexl][, secl := "Total"], use.names = TRUE)
OWNUSE[, `:=`(wpr_x1 = wpr - own1, wpr_x12 = wpr - own12)]
own_use_w <- A[year == 2023 & sex == 2, .(own1 = 100 * sum(w * (worker & status %in% c("own", "help") & as.integer(ind2) %in% 1:9 & eco %in% 1), na.rm = TRUE) / sum(w),
                                         own12 = 100 * sum(w * (worker & status %in% c("own", "help") & as.integer(ind2) %in% 1:9 & eco %in% 1:2), na.rm = TRUE) / sum(w)), by = secl]

# ---------- principal-status distribution of women (where did the new workers come from?) ----------
A[, pcat := fcase(pas %in% c(11, 12), "Own-account/employer", pas == 21, "Unpaid helper", pas == 31, "Regular wage",
                  pas %in% c(41, 51), "Casual labour", pas == 81, "Unemployed", pas == 91, "In education",
                  pas == 92, "Domestic duties only", pas == 93, "Domestic duties and free collection", default = "Other not in labour force")]
PD <- A[sex == 2, .(w = sum(w)), by = .(year, secl, pcat)][, pct := 100 * w / sum(w), by = .(year, secl)][]
# subsidiary-only workers: what is their principal status?
SSP <- A[sex == 2 & ss_only == TRUE, .(w = sum(w)), by = .(year, secl, pcat)][, pct := 100 * w / sum(w), by = .(year, secl)][]

# ---------- composition: Kitagawa decomposition of the change in women's WPR ----------
kit <- function(dat, y, cellvars) {
  dat <- copy(dat)[, cell := do.call(paste, c(.SD, sep = "|")), .SDcols = cellvars]
  g <- dat[, .(pop = sum(w), r = sum(w * get(y)) / sum(w)), by = .(year, cell)]
  g[, s := pop / sum(pop), by = year]
  wde <- dcast(g, cell ~ year, value.var = c("s", "r"))
  wde[is.na(s_2017), s_2017 := 0]; wde[is.na(s_2023), s_2023 := 0]
  wde[is.na(r_2017), r_2017 := r_2023]; wde[is.na(r_2023), r_2023 := r_2017]
  data.table(var = y, total = 100 * (sum(wde$s_2023 * wde$r_2023) - sum(wde$s_2017 * wde$r_2017)),
             composition = 100 * sum((wde$s_2023 - wde$s_2017) * (wde$r_2023 + wde$r_2017) / 2),
             rates = 100 * sum((wde$r_2023 - wde$r_2017) * (wde$s_2023 + wde$s_2017) / 2),
             ncell = nrow(wde), unmatched_pop = 100 * (sum(wde$s_2017[wde$s_2023 == 0]) + sum(wde$s_2023[wde$s_2017 == 0])) / 2)
}
W15 <- A[sex == 2 & !is.na(edu4)]
cv <- c("state", "secl", "agegrp", "edu4", "marst")
KIT <- rbindlist(lapply(c("wpr", "s_own", "s_help", "s_reg", "s_cas"), function(v) kit(W15, v, cv)))
KIT2 <- rbindlist(lapply(list(c("secl"), c("state", "secl"), c("secl", "agegrp", "edu4"), cv, c(cv, "socl")), function(cc)
  kit(A[sex == 2 & !is.na(edu4) & !is.na(socl)], "wpr", cc)[, cells := paste(cc, collapse = " x ")]))

# ---------- heterogeneity among women (change in WPR and its status components) ----------
het <- function(dat, gv) {
  r <- dat[!is.na(get(gv)), lapply(.SD, function(x) 100 * sum(w * x) / sum(w)), by = c("year", gv), .SDcols = c("wpr", "s_own", "s_help", "s_reg", "s_cas", "ss")]
  w <- dcast(melt(r, id.vars = c("year", gv)), as.formula(paste(gv, "+ variable ~ year")), value.var = "value")
  w[, d := `2023` - `2017`]; setnames(w, gv, "level"); w[, group := gv][]
}
HET <- rbindlist(lapply(c("agegrp", "edu4", "mpceq", "socl"), function(g) {
  rbind(het(A[sex == 2 & secl == "Rural"], g)[, secl := "Rural"], het(A[sex == 2 & secl == "Urban"], g)[, secl := "Urban"])
}))
HET[, level := as.character(level)]

# ---------- states ----------
# harmonise boundaries: Ladakh (37, from 2019) folded into Jammu & Kashmir; Dadra & Nagar Haveli (26 in 2017-18) into 25
SNAME <- c(`1` = "Jammu & Kashmir", `2` = "Himachal Pradesh", `3` = "Punjab", `5` = "Uttarakhand", `6` = "Haryana", `7` = "Delhi",
  `8` = "Rajasthan", `9` = "Uttar Pradesh", `10` = "Bihar", `16` = "Tripura", `18` = "Assam", `19` = "West Bengal", `20` = "Jharkhand",
  `21` = "Odisha", `22` = "Chhattisgarh", `23` = "Madhya Pradesh", `24` = "Gujarat", `27` = "Maharashtra", `28` = "Andhra Pradesh",
  `29` = "Karnataka", `32` = "Kerala", `33` = "Tamil Nadu", `36` = "Telangana")
stn <- A[sex == 2 & year == 2023, .(n = .N), by = state]
ST <- A[sex == 2, lapply(.SD, function(x) 100 * sum(w * x) / sum(w)), by = .(year, state), .SDcols = c("wpr", "s_own", "s_help", "s_reg", "s_cas")]
ST <- dcast(melt(ST, id.vars = c("year", "state")), state + variable ~ year)[, d := `2023` - `2017`]
STw <- dcast(ST, state ~ variable, value.var = "d")
popst <- A[sex == 2 & year == 2023, .(pop = sum(w)), by = state]
STw <- merge(merge(STw, popst, by = "state"), stn, by = "state")
big <- STw[order(-pop)][1:20][, name := SNAME[as.character(state)]]
stopifnot(!anyNA(big$name))
st_cor <- cor(big$wpr, big$s_help + big$s_own)
st_cor_help <- cor(big$wpr, big$s_help)

# ---------- robustness: ages 15-59; principal status only; CWS ----------
R1559 <- est(A[sex == 2 & age <= 59])[secl == "Total" & var %in% c("wpr", "s_own", "s_help", "s_reg", "s_cas", "ss")]

# ---------- men: status decomposition (for comparison) ----------
RES <- list(N = N, EW = EW, EM = EM, ur = ur, VAL = VAL, IW = IW, HP = HP, hpse = hpse, ECO = ECO, ECOt = ECOt, ECOcov = ECOcov,
            own_use_w = own_use_w, OWNUSE = OWNUSE, PD = PD, SSP = SSP, KIT = KIT, KIT2 = KIT2, HET = HET, STw = STw, big = big,
            st_cor = st_cor, st_cor_help = st_cor_help, R1559 = R1559, nstates = nrow(STw),
            n_persons = D[, .N, by = year], n_hh = D[, uniqueN(hhid), by = year], n_fsu = D[, uniqueN(psu), by = year],
            created = Sys.time())
saveRDS(RES, file.path(OUT, "plfs10_results.rds"))
cat("Saved", file.path(OUT, "plfs10_results.rds"), "\n")
print(VAL[order(ind, year, secl, sexl)])
print(EW[secl == "Total" & var %in% c("wpr", "s_own", "s_help", "s_reg", "s_cas", "ps", "ss", "ag", "nag")])
print(KIT); print(KIT2)
