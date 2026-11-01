## Couple transitions and all estimates. Writes output/results.json (every number used in the paper).
source(file.path(Sys.getenv("P12_CODE", "/workspace/papers/P12/repo/code"), "00_config.R"))
setFixest_notes(FALSE)
R <- list()

make_couples <- function(p) {
  p <- copy(p)
  hd <- p[rel == 1 & visit == 1, .N, by = hid][N == 1, hid]; sp <- p[rel == 2 & visit == 1, .N, by = hid][N == 1, hid]
  ok <- intersect(hd, sp)
  h <- p[hid %in% ok & rel == 1 & sex == 1]; w <- p[hid %in% ok & rel == 2 & sex == 2]
  keep <- intersect(h[visit == 1 & age1 %between% c(18, 59), hid], w[visit == 1 & age1 %between% c(18, 59), hid])
  h <- h[hid %in% keep]; w <- w[hid %in% keep]
  hv <- h[, .(hid, visit, cq, h_emp = emp, h_lf = lf, h_cws = cws, h_jt = jt, h_educ = educ1, h_earn = earn)]
  wv <- w[, .(hid, visit, cq, year, state, district = district1, fsu, cq1, w = w1, w_age = age1, w_educ = educ1, w_emp = emp, w_lf = lf,
              w_cws = cws, w_jt = jt, w_earn = earn, social, religion, hce, hhsize, child05)]
  cv <- merge(wv, hv, by = c("hid", "visit", "cq"))
  # other members aged 15-64 (not head/spouse), employment by visit
  o <- p[hid %in% keep & !rel %in% 1:2 & age1 %between% c(15, 64), .(hid, pid, visit, emp)]
  cv[, cl := paste(state, fsu, cq1, sep = ":")]
  list(cv = cv, o = o)
}
transitions <- function(cv, o) {
  a <- cv; b <- copy(cv); b[, visit := visit - 1L]
  nm <- c("cq", "h_emp", "h_lf", "h_cws", "h_jt", "h_earn", "w_emp", "w_lf", "w_cws", "w_jt", "w_earn")
  setnames(b, nm, paste0(nm, "_1"))
  tr <- merge(a, b[, c("hid", "visit", paste0(nm, "_1")), with = FALSE], by = c("hid", "visit"))
  stopifnot(all(tr$cq_1 == tr$cq + 1))
  setnames(tr, c("visit", nm), c("k0", paste0(nm, "_0")))
  # lead (husband status at t+1) and lag (wife LF at t-2)
  ld <- cv[, .(hid, k0 = visit - 2L, h_emp_lead = h_emp)]; tr <- merge(tr, ld, by = c("hid", "k0"), all.x = TRUE)
  lg <- cv[, .(hid, k0 = visit + 1L, w_lf_lag = w_lf)]; tr <- merge(tr, lg, by = c("hid", "k0"), all.x = TRUE)
  # other members' transitions
  o2 <- merge(o, o[, .(pid, visit = visit - 1L, emp1 = emp)], by = c("pid", "visit"))
  oo <- o2[, .(o_enter = as.integer(any(emp == 0 & emp1 == 1)), o_n = .N), by = .(hid, k0 = visit)]
  tr <- merge(tr, oo, by = c("hid", "k0"), all.x = TRUE); tr[is.na(o_n), `:=`(o_n = 0L, o_enter = 0L)]
  tr[, `:=`(D = as.integer(h_emp_0 == 1 & h_emp_1 == 0), cqt = cq_1)]
  tr[, D_lead := fifelse(h_emp_1 == 1 & !is.na(h_emp_lead), as.integer(h_emp_lead == 0), NA_integer_)]
  tr[, `:=`(
    w_agegp = as.character(cut(w_age, c(17, 29, 44, 59), labels = c("18-29", "30-44", "45-59"))),
    w_edgp = fcase(w_educ <= 5, "below_primary", w_educ <= 7, "primary_middle", w_educ <= 11, "secondary", default = "graduate"),
    h_edgp = fcase(h_educ <= 5, "below_primary", h_educ <= 7, "primary_middle", h_educ <= 11, "secondary", default = "graduate"),
    socgp = fcase(social %in% 1:2, "ST_SC", social == 3, "OBC", default = "other"),
    relgp = fcase(religion == 1, "Hindu", religion == 2, "Muslim", default = "other"),
    hjt = fcase(h_jt_0 == "regular", "regular", h_jt_0 == "casual", "casual", default = "self"),
    dest = fcase(D == 0, "none", h_cws_1 %in% c(81, 82), "unemployed", h_cws_1 %in% c(94, 95, 98), "pension_disab_sick", default = "other_olf"))]
  tr[, pce := hce / hhsize]; tr[, cons3 := cut(frank(pce, ties.method = "average") / .N, c(0, 1/3, 2/3, 1), labels = c("T1", "T2", "T3")), by = year]
  tr
}
FE <- "state^cqt + k0 + w_agegp + w_edgp + h_edgp + child05 + socgp + relgp + cons3 + hhsize"
est <- function(f, d, ...) feols(as.formula(f), data = d, weights = ~w, cluster = ~cl, ...)
co <- function(m, v = "D") { ct <- coeftable(m); ci <- confint(m)[v, ]
  list(b = unname(ct[v, 1]), se = unname(ct[v, 2]), t = unname(ct[v, 3]), p = unname(ct[v, 4]), lo = unname(ci[[1]]), hi = unname(ci[[2]]), n = nobs(m)) }

run_set <- function(tr, tag) {
  S <- list()
  e <- tr[h_emp_0 == 1 & w_lf_0 == 0]
  S$n_trans_entry <- nrow(e); S$n_events_entry <- sum(e$D); S$n_couples_entry <- uniqueN(e$hid)
  S$raw_entry_D1 <- 100 * wmean(e[D == 1, w_lf_1], e[D == 1, w]); S$raw_entry_D0 <- 100 * wmean(e[D == 0, w_lf_1], e[D == 0, w])
  S$raw_empentry_D1 <- 100 * wmean(e[D == 1, w_emp_1], e[D == 1, w]); S$raw_empentry_D0 <- 100 * wmean(e[D == 0, w_emp_1], e[D == 0, w])
  S$entry_lf <- co(est(paste("w_lf_1 ~ D |", FE), e)); S$entry_emp <- co(est(paste("w_emp_1 ~ D |", FE), e))
  S$entry_lf_nocontrols <- co(est("w_lf_1 ~ D | state^cqt + k0", e))
  x <- tr[h_emp_0 == 1 & w_emp_0 == 1]; x[, w_exit := 1L - w_emp_1]
  S$n_trans_exit <- nrow(x); S$n_events_exit <- sum(x$D); S$exit <- co(est(paste("w_exit ~ D |", FE), x))
  pl <- e[!is.na(D_lead) & h_emp_1 == 1]; S$placebo <- co(est(paste("w_lf_1 ~ D_lead |", FE), pl), "D_lead"); S$n_placebo_events <- sum(pl$D_lead)
  pt <- tr[h_emp_0 == 1 & w_lf_0 == 0 & !is.na(w_lf_lag)]; S$pretrend <- co(est(paste("w_lf_lag ~ D |", FE), pt)); S$n_pretrend <- nrow(pt); S$n_pretrend_events <- sum(pt$D)
  S
}

## ---------- main pooled sample (2022-23 + 2023-24) ----------
p <- readRDS(file.path(DERIVED, "persons_main.rds")); C <- make_couples(p); tr <- transitions(C$cv, C$o); rm(p); gc()
R$main <- run_set(tr, "main")
R$main$n_couples <- uniqueN(C$cv$hid); R$main$n_transitions <- nrow(tr); R$main$n_husband_emp0 <- tr[h_emp_0 == 1, .N]
R$main$n_events_entry_2324file_only <- tr[h_emp_0 == 1 & w_lf_0 == 0 & cq1 >= 5, sum(D)]
R$main$n_events_all <- tr[h_emp_0 == 1, sum(D)]
R$main$events_by_year_of_t <- as.list(tr[h_emp_0 == 1, .(ev = sum(D)), by = .(y = fifelse(cqt <= 4, "Jul2022-Jun2023", "Jul2023-Jun2024"))][, setNames(ev, y)])
e <- tr[h_emp_0 == 1 & w_lf_0 == 0]
## descriptives (Table 1): weighted means at t-1 for entry sample
desc <- function(d) list(w_age = wmean(d$w_age, d$w), h_regular = 100 * wmean(d$h_jt_0 == "regular", d$w), h_casual = 100 * wmean(d$h_jt_0 == "casual", d$w),
  h_self = 100 * wmean(d$h_jt_0 %in% c("self", "helper"), d$w), w_grad = 100 * wmean(d$w_edgp == "graduate", d$w), child05 = 100 * wmean(d$child05, d$w),
  hhsize = wmean(d$hhsize, d$w), n = nrow(d))
R$desc <- list(D1 = desc(e[D == 1]), D0 = desc(e[D == 0]))
R$main$stop_rate <- 100 * wmean(tr[h_emp_0 == 1, D], tr[h_emp_0 == 1, w])
R$main$dest_shares <- as.list(e[D == 1, .(s = 100 * sum(w)), by = dest][, s := s / sum(s) * 100][, setNames(s / 100, dest)])

## layoff checks (D by husband's prior job type, by destination, excluding 94/95/98)
m <- est(paste("w_lf_1 ~ i(hjt, D) |", FE, "+ hjt"), e); ct <- coeftable(m); ci <- confint(m)
R$layoff$by_jobtype <- lapply(setNames(nm = c("regular", "casual", "self")), function(g) { v <- paste0("hjt::", g, ":D")
  list(b = ct[v, 1], se = ct[v, 2], t = ct[v, 3], p = ct[v, 4], lo = ci[v, 1], hi = ci[v, 2], events = e[hjt == g, sum(D)]) })
e[, `:=`(D_u = as.integer(dest == "unemployed"), D_o = as.integer(dest == "other_olf"), D_s = as.integer(dest == "pension_disab_sick"))]
m <- est(paste("w_lf_1 ~ D_u + D_o + D_s |", FE), e)
R$layoff$by_dest <- list(unemployed = co(m, "D_u"), other_olf = co(m, "D_o"), pension_disab_sick = co(m, "D_s"))
R$layoff$by_dest$unemployed$events <- sum(e$D_u); R$layoff$by_dest$other_olf$events <- sum(e$D_o); R$layoff$by_dest$pension_disab_sick$events <- sum(e$D_s)
R$layoff$excl_949598 <- co(est(paste("w_lf_1 ~ D |", FE), e[dest != "pension_disab_sick"]))
hold <- abs(R$main$placebo$t) < 1.96 && R$layoff$by_jobtype$regular$b > 0 && R$layoff$by_jobtype$regular$p < 0.05
R$layoff$verdict_hold <- hold
R$layoff$rule <- "placebo |t|<1.96 AND regular-salaried coefficient > 0 with p<0.05"

## heterogeneity with BH q-values
H <- list(w_edgp = "Wife education", w_agegp = "Wife age", child05 = "Child aged 0-5", socgp = "Social group", cons3 = "Consumption tercile", hjt = "Husband prior job")
het <- rbindlist(lapply(names(H), function(g) { d <- copy(e); d[, G := as.character(get(g))]
  m <- est(paste("w_lf_1 ~ i(G, D) |", FE, "+ G"), d); ct <- as.data.table(coeftable(m), keep.rownames = "term"); ci <- as.data.table(confint(m), keep.rownames = "term")
  ct <- merge(ct, ci, by = "term"); setnames(ct, c("term", "b", "se", "t", "p", "lo", "hi"))
  ct[, `:=`(dim = H[[g]], group = sub(":D$", "", sub("^G::", "", term)))]
  ev <- d[, .(events = sum(D), event_entrants = sum(D * w_lf_1)), by = .(group = G)]; merge(ct, ev, by = "group") }))
het[, degenerate := event_entrants < 5]            # fewer than 5 wives entered after a stop: SE not informative, not tested
het[degenerate == TRUE, `:=`(p = NA_real_, t = NA_real_, lo = NA_real_, hi = NA_real_)]
het[, q := p.adjust(p, "BH")]; R$het <- het; R$het_n_tests <- nrow(het)

## entry job quality (multinomial as separate LPMs) and other members
for (j in c("regular", "casual", "self", "helper", "unemployed")) e[, paste0("ent_", j) := as.integer(w_jt_1 == j)]
R$entry_type <- lapply(setNames(nm = c("regular", "casual", "self", "helper", "unemployed")), function(j) co(est(paste0("ent_", j, " ~ D |", FE), e)))
R$entry_type_share_D1 <- as.list(e[D == 1 & w_lf_1 == 1, .(s = sum(w)), by = w_jt_1][, setNames(100 * s / sum(s), w_jt_1)])
R$entry_type_share_D0 <- as.list(e[D == 0 & w_lf_1 == 1, .(s = sum(w)), by = w_jt_1][, setNames(100 * s / sum(s), w_jt_1)])
R$n_entrants <- list(D1 = e[D == 1 & w_lf_1 == 1, .N], D0 = e[D == 0 & w_lf_1 == 1, .N])
R$entrant_earn_median <- list(D1 = e[D == 1 & w_emp_1 == 1 & w_earn_1 > 0, median(w_earn_1)], D0 = e[D == 0 & w_emp_1 == 1 & w_earn_1 > 0, median(w_earn_1)],
                              n_D1 = e[D == 1 & w_emp_1 == 1 & w_earn_1 > 0, .N])
a <- tr[h_emp_0 == 1 & o_n > 0]; R$other_members <- co(est(paste("o_enter ~ D |", FE), a)); R$other_members$events <- sum(a$D)
R$other_members$mean_D0 <- 100 * wmean(a[D == 0, o_enter], a[D == 0, w])

## robustness (supplement)
FEd <- sub("state\\^cqt", "district^cqt", FE)
R$rob <- list(
  district_qtr_fe = co(feols(as.formula(paste("w_lf_1 ~ D |", sub("state\\^cqt", "state^district^cqt", FE))), e, weights = ~w, cluster = ~cl)),
  unweighted      = co(feols(as.formula(paste("w_lf_1 ~ D |", FE)), e, cluster = ~cl)),
  only_2023_24_t  = co(est(paste("w_lf_1 ~ D |", FE), e[cqt >= 5])),
  file_2023_24_only = co(est(paste("w_lf_1 ~ D |", FE), e[cq1 >= 5])),
  only_2022_23_t  = co(est(paste("w_lf_1 ~ D |", FE), e[cqt <= 4])),
  logit_ame       = { m <- feglm(as.formula(paste("w_lf_1 ~ D |", FE)), e, family = binomial(), weights = ~w, cluster = ~cl)
                      list(b_logodds = unname(coef(m)["D"]), p = unname(pvalue(m)["D"])) })

R$rob_rows <- list(pooled = nrow(e), t2223 = nrow(e[cqt <= 4]), t2324 = nrow(e[cqt >= 5]),
  dropped_2223 = nrow(e[cqt <= 4]) - R$rob$only_2022_23_t$n, dropped_2324 = nrow(e[cqt >= 5]) - R$rob$only_2023_24_t$n, dropped_pooled = nrow(e) - R$main$entry_lf$n)
cat("rob rows:", unlist(R$rob_rows), "\n")

## event study (couples seen in all four visits, husband employed at visit 1)
cv <- C$cv; full <- cv[, .N, by = hid][N == 4, hid]; es <- cv[hid %in% full]
es <- es[hid %in% es[visit == 1 & h_emp == 1, hid]]
g <- es[h_emp == 0, .(g = min(visit)), by = hid]; es <- merge(es, g, by = "hid", all.x = TRUE); es[is.na(g), g := 1000L]
m <- feols(w_lf ~ sunab(g, visit) | hid + state^cq, es, weights = ~w, cluster = ~cl)
ct <- as.data.table(coeftable(m), keep.rownames = "term"); ci <- as.data.table(confint(m), keep.rownames = "term"); ct <- merge(ct, ci, by = "term")
setnames(ct, c("term", "b", "se", "t", "p", "lo", "hi")); ct[, rel := as.integer(sub("visit::", "", term))]
R$event <- list(coefs = ct[order(rel)], n_couples = uniqueN(es$hid), n_treated = uniqueN(es[g < 1000, hid]))
R$event$cohorts <- as.list(es[visit == 1, .N, by = g][, setNames(N, g)])

## attrition: probability the couple is missing at the next visit, by husband status
att <- cv[visit < 4]; nx <- cv[, .(hid, visit = visit - 1L, seen = 1L)]; att <- merge(att, nx, by = c("hid", "visit"), all.x = TRUE); att[is.na(seen), seen := 0L]
att <- att[!(cq + 1L > 8)]   # next quarter outside the data window
R$attrition <- list(rate = 100 * wmean(1 - att$seen, att$w), n = nrow(att),
  husband_not_employed = co(feols(I(1 - seen) ~ I(h_jt == "regular") + I(h_emp == 0) | state^cq + visit, att, weights = ~w, cluster = ~cl), "I(h_emp == 0)TRUE"))
## Attrition sensitivity bounds for the entry estimate (PaperChecker round 3).
## Stop-group stayers have mass r1-g; adding back the g extra leavers restores mass r1.
## If all extra leavers entered, this gives the upper bound; if none entered, it gives the lower bound.
## The shift in the stop-group entry rate is added to the regression estimate; control-group attrition is assumed ignorable.
attw <- att[w_lf == 0]; attw[, `:=`(left = as.numeric(1 - seen), hne = as.numeric(h_emp == 0))]
g_m <- co(feols(left ~ hne | state^cq + visit, attw, weights = ~w, cluster = ~cl), "hne")
a1 <- wmean(attw[h_emp == 1, left], attw[h_emp == 1, w]); r1 <- 1 - a1; g <- max(g_m$b, 0)
p1 <- wmean(e[D == 1, w_lf_1], e[D == 1, w]); b0 <- R$main$entry_lf$b
bound_at_gap <- function(gap) {
  gap <- max(gap, 0)
  p_hi <- (p1 * (r1 - gap) + gap) / r1
  p_lo <- (p1 * (r1 - gap)) / r1
  c(upper = 100 * (b0 + p_hi - p1), lower = 100 * (b0 + p_lo - p1))
}
p1_hi <- (p1 * (r1 - g) + g) / r1; p1_lo <- (p1 * (r1 - g)) / r1
g_lo <- max(g_m$lo, 0); g_hi <- max(g_m$hi, 0)
gap_lo_bounds <- bound_at_gap(g_lo); gap_hi_bounds <- bound_at_gap(g_hi)
R$attrition_bounds <- list(gap = 100 * g, gap_se = 100 * g_m$se, gap_p = g_m$p, gap_n = g_m$n, base_attrition = 100 * a1,
  p1 = 100 * p1, p1_all_entered = 100 * p1_hi, p1_none_entered = 100 * p1_lo,
  gap_est = g_m, estimate = 100 * b0, upper = 100 * (b0 + p1_hi - p1), lower = 100 * (b0 + p1_lo - p1),
  upper_at_gap_lo = gap_lo_bounds[["upper"]], upper_at_gap_hi = gap_hi_bounds[["upper"]],
  lower_at_gap_lo = gap_lo_bounds[["lower"]], lower_at_gap_hi = gap_hi_bounds[["lower"]],
  gap_lo = 100 * g_lo, gap_hi = 100 * g_hi)

## ---------- replication: 2017-18 ----------
p <- readRDS(file.path(DERIVED, "persons_1718.rds")); C2 <- make_couples(p); tr2 <- transitions(C2$cv, C2$o)
R$rep1718 <- run_set(tr2, "1718")
saveRDS(list(es = R$event$coefs), file.path(DERIVED, "event.rds"))
write_json(R, file.path(OUT, "results.json"), auto_unbox = TRUE, pretty = TRUE, digits = NA)
cat("wrote", normalizePath(file.path(OUT, "results.json")), "\n")
cat("main entry:", unlist(R$main$entry_lf[c("b", "se", "p", "n")]), "events", R$main$n_events_entry, "\n")
cat("1718 entry:", unlist(R$rep1718$entry_lf[c("b", "se", "p", "n")]), "events", R$rep1718$n_events_entry, "\n")
