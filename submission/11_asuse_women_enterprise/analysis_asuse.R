# Paper 11: Women's enterprise ownership in India, NSS 73rd round (2015-16) vs ASUSE 2023-24.
# Reads unit-level data kept OUTSIDE the repo and writes every estimate used in the
# manuscript to an .rds file (also outside the repo). No numbers are typed by hand.
#
# Expected inputs (see SUBMISSION.md "Data"):
#   ~/GResearcher_runs/data_raw/asuse2324/  asuse_2324_esu_l01.txt ... l16.txt (fixed width, MoSPI
#                                           layout NSS_ASUSE_23_24_Layout_mult_post.xlsx), or the
#                                           .csv files produced by MoSPI's txt2csv converter
#   ~/GResearcher_runs/data_raw/nss73/      NSS 73rd round Sch. 2.34 unit data, either the NADA
#                                           export (one file per block and semi-round, DDI names
#                                           b2_q204, Weight_SC, ...) as .dta/.csv, or the fixed-width
#                                           R73234SM?L?? files plus Data_Layout73234.xls (not yet coded)
# Usage: Rscript analysis_asuse.R      (env ASUSE_RAW, NSS73_RAW, P11_OUT optional)
suppressMessages(library(data.table)); if (requireNamespace("survey", quietly = TRUE)) suppressMessages(library(survey))
options(survey.lonely.psu = "adjust")
RAWA <- Sys.getenv("ASUSE_RAW", path.expand("~/GResearcher_runs/data_raw/asuse2324"))
RAWN <- Sys.getenv("NSS73_RAW", path.expand("~/GResearcher_runs/data_raw/nss73"))
OUT  <- Sys.getenv("P11_OUT", path.expand("~/GResearcher_runs/data_derived/p11"))
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
num <- function(x) suppressWarnings(as.numeric(x))
# make sure every worker-item column exists (an item with no records in a file would be absent)
ensure_cols <- function(E, items) { for (v in c("tot", "ft_f", "pt_f", "ft_m", "pt_m")) for (i in items) {
  nm <- paste(v, i, sep = "_"); if (!nm %in% names(E)) set(E, j = nm, value = 0) }; E }

# ---------------------------------------------------------------- ASUSE 2023-24
# Byte positions from NSS_ASUSE_23_24_Layout_mult_post.xlsx (common key fields are identical
# across levels; README: key = FSU 1-5, segment 25, SSS 26-27, establishment no. 28-29;
# final weight = MLT/100).
KEYPOS <- list(fsu = c(1, 5), sector = c(9, 9), nss_region = c(10, 12), district = c(13, 14),
               stratum = c(15, 17), sub_stratum = c(18, 19), segment = c(25, 25), sss = c(26, 27), est = c(28, 29))
L02 <- c(KEYPOS, list(i201 = c(32, 32), nic2 = c(33, 34), nic5 = c(35, 39), own = c(47, 47), edu = c(48, 48),
  socgrp = c(50, 50), npi = c(53, 53), loc = c(56, 56), esttype = c(57, 57), nature = c(63, 63), months = c(64, 65),
  hours = c(66, 67), internet = c(70, 70), registered = c(74, 74), mfg_service = c(87, 87), mfg_contract = c(88, 88),
  mfg_contract_type = c(89, 89), mfg_equip = c(90, 90), svc_contract = c(91, 91), svc_contract_type = c(92, 92),
  mult = c(94, 103)))
L03 <- c(KEYPOS, list(refp = c(46, 46), mult = c(55, 64)))
L08 <- c(KEYPOS, list(item = c(32, 34), value = c(35, 46), mult = c(47, 56)))
L09 <- c(KEYPOS, list(item = c(32, 34), ft_m = c(35, 39), ft_f = c(40, 44), ft_t = c(45, 49), pt_m = c(50, 54),
  pt_f = c(55, 59), pt_t = c(60, 64), tot = c(65, 69), mult = c(70, 79)))
CSVNAME <- c(fsu = "fsu", sector = "sector", nss_region = "nss_region", district = "district", stratum = "stratum",
  sub_stratum = "sub_stratum", segment = "segment", sss = "SSS_no", est = "est_no", i201 = "item_201",
  nic2 = "item_202_a", nic5 = "item_202_b", own = "item_204", edu = "item_205", socgrp = "item_207", npi = "item_209",
  loc = "item_212", esttype = "item_213", nature = "item_216", months = "item_217", hours = "item_218",
  internet = "item_223", registered = "item_227", mfg_service = "item_238", mfg_contract = "item_239",
  mfg_contract_type = "item_240", mfg_equip = "item_241", svc_contract = "item_242", svc_contract_type = "item_243",
  refp = "item_265", item = "item_no_08", value = "value_08", mult = "mult")

read_level <- function(dir, lv, pos) {
  ftxt <- list.files(dir, sprintf("asuse_2324_esu_l%02d\\.txt$", lv), full.names = TRUE, recursive = TRUE, ignore.case = TRUE)
  fcsv <- list.files(dir, sprintf("asuse_2324_esu_l%02d\\.csv$", lv), full.names = TRUE, recursive = TRUE, ignore.case = TRUE)
  if (length(ftxt)) {
    x <- fread(ftxt[1], sep = "\n", header = FALSE, colClasses = "character", strip.white = FALSE, showProgress = FALSE)[[1]]
    x <- sub("\r$", "", x)
    d <- as.data.table(lapply(pos, function(p) trimws(substr(x, p[1], p[2]))))
  } else if (length(fcsv)) {
    d <- fread(fcsv[1], colClasses = "character", showProgress = FALSE)
    nm <- CSVNAME; if (lv == 9) nm <- c(nm[setdiff(names(nm), c("item", "value"))], item = "item_no_09",
      ft_m = "Workers_Full_time_male", ft_f = "Workers_Full_time_female", ft_t = "Workers_Full_time_transgender",
      pt_m = "Workers_Part_time_male", pt_f = "Workers_Part_time_female", pt_t = "Workers_Part_time_transgender", tot = "Workers_Total")
    keep <- intersect(names(pos), names(nm)); miss <- setdiff(names(pos), keep)
    if (length(miss)) stop("CSV level ", lv, ": no mapping for ", paste(miss, collapse = ","))
    d <- d[, nm[keep], with = FALSE]; setnames(d, keep)
  } else stop("ASUSE 2023-24 level ", lv, " not found under ", dir)
  d[, key := paste(fsu, segment, sss, est, sep = "_")]
  d
}

prep_asuse <- function(dir) {
  b2 <- read_level(dir, 2, L02); b3 <- read_level(dir, 3, L03)[, .(key, refp = num(refp))]
  b8 <- read_level(dir, 8, L08); b9 <- read_level(dir, 9, L09)
  stopifnot(!anyDuplicated(b2$key))
  E <- b2[, .(key, fsu, stratum = paste(nss_region, sector, stratum, sub_stratum, sep = "_"),
    sector = as.integer(sector), state = as.integer(substr(nss_region, 1, 2)), nic2 = as.integer(nic2), nic5,
    own = as.integer(own), loc = as.integer(loc), oae = as.integer(esttype) == 2L,   # ASUSE: HWE 1, OAE 2
    nature = as.integer(nature), months = num(months), hours = num(hours), npi = as.integer(npi),
    contract_any = (as.integer(mfg_contract) %in% 1L) | (as.integer(svc_contract) %in% 1L),
    contract_type = fifelse(as.integer(mfg_contract) %in% 1L, as.integer(mfg_contract_type), as.integer(svc_contract_type)),
    equip_by_contractor = as.integer(mfg_equip), internet = as.integer(internet) == 1L,
    registered = as.integer(registered) == 1L, w = num(mult) / 100)]
  E <- merge(E, b3, by = "key", all.x = TRUE)
  g <- b8[item == "769", .(key, gva_m = num(value))]                     # GVA, reference period (item 769)
  E <- merge(E, g, by = "key", all.x = TRUE)
  # README C: annual GVA = item 769 x m; m = 12 perennial (216 = 1, 265 != 4), item 217 otherwise, 1 if 265 = 4
  E[, m := fifelse(refp %in% 4, 1, fifelse(nature %in% 1, 12, months))]
  E[, gva_y := gva_m * m]
  E[, gva_month := fifelse(refp %in% 4, gva_m / pmax(months, 1), gva_m)]  # per month of operation
  wk <- b9[, .(key, item, ft_m = num(ft_m), ft_f = num(ft_f), pt_m = num(pt_m), pt_f = num(pt_f), tot = num(tot))]
  W <- dcast(wk[item %in% c("781", "782", "783", "784", "785", "789")], key ~ item, value.var = c("tot", "ft_f", "pt_f", "ft_m", "pt_m"), fill = 0)
  E <- ensure_cols(merge(E, W, by = "key", all.x = TRUE), c("781", "782", "783", "784", "785", "789"))
  for (v in grep("^(tot|ft_|pt_)", names(E), value = TRUE)) set(E, which(is.na(E[[v]])), v, 0)
  E[, `:=`(workers = tot_789, owners = tot_781, hired = tot_782 + tot_783, unpaid_family = tot_784,
           fem_workers = ft_f_789 + pt_f_789)]
  E[, market := !(npi %in% 1L) & !(nic5 %in% "70100")]
  E[, year := 2023L]
  E
}

# ---------------------------------------------------------------- NSS 73rd round (2015-16)
# NADA/Nesstar export: one file per semi-round and block. Names from the DDI (catalog 139).
find_block <- function(dir, sr, blk) {
  f <- list.files(dir, full.names = TRUE, recursive = TRUE)
  f <- f[grepl("\\.(dta|csv|sav)$", f, ignore.case = TRUE)]
  pat_sr <- sprintf("(semi.?round.?%d|sm%d|sr%d)", sr, sr, sr)
  pat_b <- sprintf("block.?%s([^0-9p]|$)", blk)
  hit <- f[grepl(pat_sr, basename(f), ignore.case = TRUE) & grepl(pat_b, basename(f), ignore.case = TRUE)]
  if (!length(hit)) stop("NSS 73: semi-round ", sr, " block ", blk, " not found under ", dir,
                         ". Rename files to contain e.g. 'Semi-Round-1' and 'Block 2'.")
  hit[1]
}
rd_any <- function(f) {
  d <- if (grepl("\\.dta$", f, ignore.case = TRUE)) as.data.table(haven::zap_labels(haven::read_dta(f))) else
       if (grepl("\\.sav$", f, ignore.case = TRUE)) as.data.table(haven::zap_labels(haven::read_sav(f))) else
       fread(f, colClasses = "character", showProgress = FALSE)
  setnames(d, tolower(names(d))); d[, names(d) := lapply(.SD, as.character)]; d
}
prep_nss73 <- function(dir) {
  out <- list()
  for (sr in 1:2) {
    b2 <- rd_any(find_block(dir, sr, "2")); b7 <- rd_any(find_block(dir, sr, "7")); b8 <- rd_any(find_block(dir, sr, "8"))
    # README: combined estimate for the whole round = semi-round sub-sample-combined weight x 0.5
    E <- b2[, .(key = paste(sr, entid, sep = "_"), fsu = paste(sr, vill_blk_slno, sep = "_"),
      stratum = paste(sr, state_region, sector, stratum, substratumno, sep = "_"),
      sector = as.integer(sector), state = as.integer(substr(state_region, 1, 2)),
      nic5 = sprintf("%05d", as.integer(b2_q202)), own = as.integer(b2_q204), loc = as.integer(b2_q210),
      oae = as.integer(b2_q211) == 1L,                                     # NSS 73: OAE 1, establishment 2
      nature = as.integer(b2_q213), months = num(b2_q214), hours = num(b2_q215), npi = as.integer(b2_q205),
      contract_any = as.integer(b2_q237) %in% 1L, contract_type = as.integer(b2_q238),
      equip_by_contractor = as.integer(b2_q239), internet = as.integer(b2_q219) == 1L,
      registered = as.integer(b2_q227) == 1L, w = num(weight_sc) * 0.5)]
    E[, nic2 := as.integer(substr(nic5, 1, 2))]
    g <- b7[b7_q2 %in% c("779", "0779", "00779"), .(key = paste(sr, entid, sep = "_"), gva_m = num(b7_q3))]
    E <- merge(E, g, by = "key", all.x = TRUE)
    # Block 7 refers to the last 30 days / last calendar month. Annualised as in ASUSE:
    # x12 for perennial, x months operated otherwise (validated against KI Statement 14 below).
    E[, m := fifelse(nature %in% 1, 12, months)]
    E[, `:=`(gva_y = gva_m * m, gva_month = gva_m, refp = NA_real_)]
    wk <- b8[, .(key = paste(sr, entid, sep = "_"), item = sub("^0+", "", b8_q2), ft_f = num(b8_q3), ft_m = num(b8_q4),
                 pt_f = num(b8_q6), pt_m = num(b8_q7), tot = num(b8_q9))]
    W <- dcast(wk[item %in% c("801", "802", "803", "804", "805", "809")], key ~ item, value.var = c("tot", "ft_f", "pt_f", "ft_m", "pt_m"), fill = 0)
    E <- ensure_cols(merge(E, W, by = "key", all.x = TRUE), c("801", "802", "803", "804", "805", "809"))
    for (v in grep("^(tot|ft_|pt_)", names(E), value = TRUE)) set(E, which(is.na(E[[v]])), v, 0)
    E[, `:=`(workers = tot_809, owners = tot_801, hired = tot_802 + tot_803, unpaid_family = tot_804,
             fem_workers = ft_f_809 + pt_f_809)]
    E[, market := !is.na(gva_m)]
    out[[sr]] <- E
  }
  E <- rbindlist(out, fill = TRUE); E[, year := 2015L]; E
}

A <- prep_asuse(RAWA)
N <- prep_nss73(RAWN)
keep <- c("key", "fsu", "stratum", "year", "sector", "state", "nic2", "nic5", "own", "loc", "oae", "nature", "months",
          "hours", "contract_any", "contract_type", "equip_by_contractor", "internet", "registered", "w", "gva_m",
          "gva_y", "gva_month", "workers", "owners", "hired", "unpaid_family", "fem_workers", "market")
D <- rbind(N[, ..keep], A[, ..keep])
stopifnot(!anyNA(D$w), !anyNA(D$own))

# ---------------------------------------------------------------- validation against published tables
VAL <- list(
  asuse_estab_crore = c(est = A[, sum(w)] / 1e7, pub = 7.34),
  asuse_fem_prop_share = c(est = 100 * A[, sum(w * (own == 2)) / sum(w)], pub = 26.2),
  asuse_gva_per_worker = c(est = A[market == TRUE, sum(w * gva_y, na.rm = TRUE) / sum(w * workers)], pub = 149742),
  asuse_gva_per_estab  = c(est = A[market == TRUE, sum(w * gva_y, na.rm = TRUE) / sum(w)], pub = 245687),
  nss73_ent_crore = c(est = N[, sum(w)] / 1e7, pub = 6.34),
  nss73_fem_prop_share = c(est = 100 * N[, sum(w * (own == 2)) / sum(w)], pub = 19.5),
  nss73_gva_per_worker = c(est = N[market == TRUE, sum(w * gva_y, na.rm = TRUE) / sum(w * workers)], pub = 103744),
  nss73_gva_total_crore = c(est = N[market == TRUE, sum(w * gva_y, na.rm = TRUE)] / 1e7, pub = 1152338))
VAL <- rbindlist(lapply(names(VAL), function(n) data.table(stat = n, est = VAL[[n]][["est"]], pub = VAL[[n]][["pub"]])))
VAL[, pct_diff := 100 * (est / pub - 1)]
print(VAL)

# ---------------------------------------------------------------- harmonised comparison frame
# Common coverage: manufacturing (NIC 10-33), trade (45-47), other services (49-96), excluding
# electricity (35), construction (41-43, not covered), public administration (84) and NIC 68108
# (residential renting, separate table in ASUSE).
D <- D[nic2 %in% c(10:33, 45:47, 49:83, 85:96) & !(nic5 %in% "68108")]
D[, bac := fcase(nic2 <= 33, "Manufacturing", nic2 <= 47, "Trade", default = "Other services")]
D[, owner_type := fcase(own == 2, "Female proprietor", own == 1, "Male proprietor", default = "Other ownership")]
D[, home := loc %in% 1L]
D[, dep := contract_any & contract_type %in% c(1L, 2L)]   # solely or mainly on contract (putting-out)
D[, cell := paste(bac, fifelse(home, "home", "outside"), fifelse(dep, "contract", "own-market"),
                  fifelse(sector == 1, "rural", "urban"), sep = " | ")]
D[, gva_pw_m := fifelse(market & workers > 0, gva_month / workers, NA_real_)]

RES <- list(val = VAL, run = Sys.time())
tot <- D[, .(N = sum(w)), by = year]
RES$totals <- merge(tot, D[own == 2, .(F = sum(w)), by = year], by = "year")[, share := 100 * F / N]

# (1) decomposition of the change in the number of female-proprietor enterprises by cell
C <- dcast(D[own == 2, .(n = sum(w)), by = .(year, cell)], cell ~ year, value.var = "n", fill = 0)
setnames(C, c("2015", "2023"), c("n15", "n23"))
C[, `:=`(d = n23 - n15)][, contrib := 100 * d / sum(d)]
RES$decomp_count <- C[order(-contrib)]

# (2) shift-share of the female share: within-cell change vs reallocation across cells
S <- D[, .(n = sum(w), f = sum(w * (own == 2))), by = .(year, cell)]
S[, `:=`(e = n / sum(n), s = f / n), by = year]
S <- dcast(S, cell ~ year, value.var = c("e", "s"), fill = 0)
S[, `:=`(within = (s_2023 - s_2015) * (e_2015 + e_2023) / 2, between = (e_2023 - e_2015) * (s_2015 + s_2023) / 2)]
RES$shiftshare <- S[, .(dS = 100 * (sum(e_2023 * s_2023) - sum(e_2015 * s_2015)), within = 100 * sum(within), between = 100 * sum(between))]
RES$shiftshare_cells <- S[order(-abs(within + between))]

# (3) profile of female- and male-proprietor enterprises
prof <- function(d) d[, .(n = sum(w), oae = sum(w * oae) / sum(w), home = sum(w * home) / sum(w),
  contract = sum(w * contract_any) / sum(w), dep = sum(w * dep) / sum(w),
  equip_contr = sum(w * (contract_any & equip_by_contractor %in% c(1L, 2L))) / sum(w),
  hours = sum(w * hours, na.rm = TRUE) / sum(w[!is.na(hours)]), months = sum(w * months, na.rm = TRUE) / sum(w[!is.na(months)]),
  workers = sum(w * workers) / sum(w), mfg = sum(w * (bac == "Manufacturing")) / sum(w),
  internet = sum(w * internet, na.rm = TRUE) / sum(w), registered = sum(w * registered, na.rm = TRUE) / sum(w)),
  by = .(year, owner_type)]
RES$profile <- prof(D)

# (4) returns: monthly GVA per worker, per worker-day and per worker-hour, market enterprises
B <- readRDS(file.path(OUT, "plfs_benchmark.rds"))$BEN    # from plfs_benchmark.R (PLFS 2023-24)
RES$plfs <- B
DAYS <- c(22, 25, 30)
R <- D[market == TRUE & workers > 0 & !is.na(gva_pw_m)]
wq <- function(x, w, p) { o <- order(x); x <- x[o]; w <- w[o]; cw <- cumsum(w) / sum(w); x[which(cw >= p)[1]] }
ret <- function(d) d[, .(mean_pw = sum(w * gva_month) / sum(w * workers), median_pw = wq(gva_pw_m, w, 0.5),
  p25 = wq(gva_pw_m, w, 0.25), p75 = wq(gva_pw_m, w, 0.75),
  below_cas25 = sum(w * (gva_pw_m < 25 * B$cas_f_all)) / sum(w),
  below_cas22 = sum(w * (gva_pw_m < 22 * B$cas_f_all)) / sum(w),
  below_cas30 = sum(w * (gva_pw_m < 30 * B$cas_f_all)) / sum(w),
  per_hour = sum(w * gva_month) / sum(w * workers * pmax(hours, 1) * 25)), by = .(owner_type, oae, home, dep)]
RES$returns23 <- ret(R[year == 2023])
RES$returns23_all <- R[year == 2023, .(median_pw = wq(gva_pw_m, w, 0.5), below_cas25 = sum(w * (gva_pw_m < 25 * B$cas_f_all)) / sum(w)), by = owner_type]
RES$days <- DAYS

# (5) regressions: log monthly GVA per worker, 2023-24, with survey design
if (requireNamespace("survey", quietly = TRUE)) {
R23 <- R[year == 2023 & gva_pw_m > 0]
R23[, `:=`(lgva = log(gva_pw_m), fem = as.numeric(own == 2), homei = as.numeric(home), depi = as.numeric(dep),
           oaei = as.numeric(oae), nic2f = factor(nic2), statef = factor(state), urban = as.numeric(sector == 2))]
des <- svydesign(ids = ~fsu, strata = ~stratum, weights = ~w, data = R23[own %in% 1:2], nest = TRUE)
m1 <- svyglm(lgva ~ fem + urban + nic2f + statef, design = des)
m2 <- update(m1, . ~ . + homei + depi + oaei + log(pmax(hours, 1)) + log(pmax(months, 1)))
m3 <- update(m2, . ~ . + fem:homei + fem:depi)
tidy <- function(m) { s <- summary(m)$coefficients; s <- s[!grepl("nic2f|statef|Intercept", rownames(s)), , drop = FALSE]
  data.table(term = rownames(s), b = s[, 1], se = s[, 2], p = s[, 4]) }
RES$reg <- list(m1 = tidy(m1), m2 = tidy(m2), m3 = tidy(m3), n = nrow(R23[own %in% 1:2]))
} else warning("package survey not installed: regressions skipped")

# (6) the same profile in 2015-16 and 2023-24 for the growth margin only (female OAEs at home)
RES$growth_margin <- D[own == 2 & oae & home, .(n = sum(w), dep = sum(w * dep) / sum(w), mfg = sum(w * (bac == "Manufacturing")) / sum(w),
  hours = sum(w * hours, na.rm = TRUE) / sum(w[!is.na(hours)])), by = year]

saveRDS(RES, file.path(OUT, "p11_results.rds"))
cat("Saved", file.path(OUT, "p11_results.rds"), "\n")
