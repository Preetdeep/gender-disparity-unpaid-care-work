# Paper 11, outside-option benchmark from PLFS 2023-24 (first-visit person file).
# Women's casual (non-public-works) daily wage and self-employment earnings in CWS,
# by quarter and sector, to validate against the PLFS Annual Report 2023-24
# (Statements 11 and 12) and to benchmark ASUSE returns.
# Data stay OUTSIDE the repo. Usage: Rscript plfs_benchmark.R
suppressMessages(library(data.table))
RAW <- Sys.getenv("PLFS_RAW", path.expand("~/GResearcher_runs/data_raw"))
OUT <- Sys.getenv("P11_OUT", path.expand("~/GResearcher_runs/data_derived/p11"))
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
num <- function(x) suppressWarnings(as.numeric(x))
rd <- function(f) { d <- fread(f, colClasses = "character", showProgress = FALSE)
  setnames(d, tolower(sub("_perv1$|_perrv$", "", names(d), ignore.case = TRUE))); d }
p1 <- rd(file.path(RAW, "plfs2324/CSV_data_PLFS_2023_2024/perv1.csv"))
pr <- rd(file.path(RAW, "plfs2324/CSV_data_PLFS_2023_2024/perrv.csv"))

# day-level casual wage records. The CSV header has a few names without the
# file suffix and two irregular ones (see layout); resolve by pattern.
gv <- function(d, item, day, act2 = FALSE) {
  pat <- if (act2) sprintf("^b6q%d_act2_3pt%d", item, day) else sprintf("^b6q%d_3pt%d$", item, day)
  nm <- grep(pat, names(d), value = TRUE)
  if (!length(nm)) stop("missing ", pat); d[[nm[1]]]
}
casual <- function(d, vis) {
  w <- ifelse(num(d$nss) == num(d$nsc), num(d$mult) / 100, num(d$mult) / 200)
  base <- data.table(vis = vis, qtr = d$qtr, sector = as.integer(d$b1q3), sex = as.integer(d$b4q5),
                     age = as.integer(d$b4q6), w = w, cws = num(d$b6q5),
                     ern_self = num(d$b6q10), ern_reg = num(d$b6q9))
  rows <- list()
  for (day in 1:7) for (a2 in c(FALSE, TRUE)) {
    st <- num(gv(d, 4, day, a2)); hr <- num(gv(d, 6, day, a2)); wg <- num(gv(d, 9, day, a2))
    rows[[length(rows) + 1]] <- data.table(id = seq_len(nrow(d)), day = day, st = st, hr = hr, wg = wg)
  }
  R <- rbindlist(rows)[st == 51]
  # NSO convention: a day with 4+ hours in the activity counts as a full day, 1 to <4 hours as half
  R[, dayeq := fifelse(!is.na(hr) & hr >= 4, 1, 0.5)]
  R <- R[, .(wage = sum(wg, na.rm = TRUE), days = sum(dayeq)), by = id]
  list(base = base, cas = cbind(base[R$id], R[, .(wage, days)]))
}
A1 <- casual(p1, "fv"); Ar <- casual(pr, "rv")
# Rural: first visit only. Urban: first visit plus the three revisits in the quarter;
# each visit set is weighted to the full urban population, so urban weights are
# divided by 4 (one first-visit set plus three revisit sets) before pooling with rural.
cas <- rbind(A1$cas, Ar$cas[sector == 2])
cas[sector == 2, w := w / 4]
cas_tab <- function(d) d[, .(wage_per_day = sum(w * wage) / sum(w * days)), by = .(qtr, sector, sex)]
T11 <- rbind(cas_tab(cas), cas[, .(wage_per_day = sum(w * wage) / sum(w * days), sector = 0L), by = .(qtr, sex)], fill = TRUE)
# self-employment earnings, last 30 days, CWS self-employed (11, 12, 21 per Statement 12 note: zero or not reported excluded)
se <- rbind(A1$base, Ar$base[sector == 2])
se[sector == 2, w := w / 4]
se <- se[cws %in% c(11, 12, 21) & !is.na(ern_self) & ern_self > 0]
T12 <- rbind(se[, .(earn30 = sum(w * ern_self) / sum(w)), by = .(qtr, sector, sex)],
             se[, .(earn30 = sum(w * ern_self) / sum(w), sector = 0L), by = .(qtr, sex)], fill = TRUE)

pub11 <- data.table(qtr = rep(c("Q1","Q2","Q3","Q4"), each = 6), sector = rep(c(1L,1L,2L,2L,0L,0L), 4), sex = rep(1:2, 12),
  pub = c(423,289,520,345,439,293, 435,287,530,348,451,293, 437,286,529,358,451,293, 444,299,537,364,459,306))
pub12 <- data.table(qtr = rep(c("Q1","Q2","Q3","Q4"), each = 6), sector = rep(c(1L,1L,2L,2L,0L,0L), 4), sex = rep(1:2, 12),
  pub = c(13269,4719,22371,8600,15317,5297, 13501,4810,22793,8323,15654,5384, 14295,4883,23077,8541,16334,5503, 14564,5218,23480,8492,16723,5803))
setkey(T11, qtr, sector, sex); setkey(T12, qtr, sector, sex)
V11 <- merge(pub11, T11, by = c("qtr","sector","sex"), all.x = TRUE)[, diff := round(wage_per_day - pub, 1)]
V12 <- merge(pub12, T12, by = c("qtr","sector","sex"), all.x = TRUE)[, diff := round(earn30 - pub, 0)]
print(V11); print(V12)
# annual female benchmark (average of the four quarterly estimates, as NSO quarterly tables)
BEN <- list(
  cas_f_rural = mean(T11[sex == 2 & sector == 1, wage_per_day]), cas_f_urban = mean(T11[sex == 2 & sector == 2, wage_per_day]),
  cas_f_all = mean(T11[sex == 2 & sector == 0, wage_per_day]), cas_m_all = mean(T11[sex == 1 & sector == 0, wage_per_day]),
  se_f_all = mean(T12[sex == 2 & sector == 0, earn30]), se_m_all = mean(T12[sex == 1 & sector == 0, earn30]))
print(BEN)
saveRDS(list(T11 = T11, T12 = T12, V11 = V11, V12 = V12, BEN = BEN, run = Sys.time()), file.path(OUT, "plfs_benchmark.rds"))
cat("Saved", file.path(OUT, "plfs_benchmark.rds"), "\n")
