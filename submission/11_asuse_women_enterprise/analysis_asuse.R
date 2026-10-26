# Paper 11: Women's enterprise ownership in India, NSS 73rd round (2015-16) vs ASUSE 2023-24.
# Reads unit-level data kept OUTSIDE the repo and writes every estimate used in the
# manuscript to an .rds file (also outside the repo). No numbers are typed by hand.
#
# Expected inputs (see SUBMISSION.md "Data"), as released on microdata.gov.in:
#   ~/GResearcher_runs/data_raw/asuse2324/  ASUSE 2023-24 (catalog 238) CSV release, files
#                                           "LEVEL - 02(Block 2).csv" etc. (levels 02, 03, 08, 09 used)
#   ~/GResearcher_runs/data_raw/nss73/      NSS 73rd round Sch. 2.34 (catalog 139) CSV release, files
#                                           "(Semi-Round-1)- Block 2.csv" etc. (Blocks 2, 7, 8 used)
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
# MoSPI CSV release (one file per level, variable names as in the CSV header). All fields read as
# character (README 5d). Final weight = MLT/100 (README 9). Establishment key = FSU, segment,
# second-stage stratum, establishment serial no. (README; serial nos above 99 are alphabetic).
read_level <- function(dir, lv) {
  f <- list.files(dir, sprintf("^LEVEL - %02d.*\\.csv$", lv), full.names = TRUE, recursive = TRUE, ignore.case = TRUE)
  if (!length(f)) stop("ASUSE 2023-24 level ", lv, " CSV not found under ", dir)
  d <- fread(f[1], colClasses = "character", showProgress = FALSE)
  sss <- intersect(c("second_stage_stratum_no", "second_stage_stratum"), names(d))[1]
  d[, key := paste(fsu_serial_no, segment_no, get(sss), sample_est_no, sep = "_")]
  d
}

prep_asuse <- function(dir) {
  b2 <- read_level(dir, 2); b3 <- read_level(dir, 3)[, .(key, refp = num(ref_period_type))]
  b8 <- read_level(dir, 8)[, .(key, item = item_no, value = value_rs)]
  b9 <- read_level(dir, 9)[, .(key, item = item_no, ft_m = full_time_male, ft_f = full_time_female,
                               pt_m = part_time_male, pt_f = part_time_female, tot = total_workers)]
  stopifnot(!anyDuplicated(b2$key))
  E <- b2[, .(key, fsu = fsu_serial_no, stratum = paste(nss_region, sector, stratum, sub_stratum, sep = "_"),
    sector = as.integer(sector), state = as.integer(substr(nss_region, 1, 2)), nic2 = as.integer(major_nic_2dig), nic5 = major_nic_5dig,
    own = as.integer(ownership_type), loc = as.integer(location), oae = as.integer(est_type) == 2L,   # ASUSE: HWE 1, OAE 2
    nature = as.integer(nature_of_operation), months = num(months_operated), hours = num(daily_work_hours), npi = as.integer(non_profit),
    contract_any = (as.integer(contract_manuf_service) %in% 1L) | (as.integer(other_contract_services) %in% 1L),
    contract_type = fifelse(as.integer(contract_manuf_service) %in% 1L, as.integer(contract_type), as.integer(other_contract_type)),
    equip_by_contractor = as.integer(equipment_by_contractor), internet = as.integer(used_internet) == 1L,
    manuf_serv = as.integer(manuf_services) %in% 1L,   # item 238: routes the manufacturing contract item 239
    registered = as.integer(registered) == 1L, w = num(mlt) / 100)]
  E <- merge(E, b3, by = "key", all.x = TRUE)
  g <- b8[item == "769", .(key, gva_m = num(value))]                     # GVA, reference period (item 769)
  E <- merge(E, g, by = "key", all.x = TRUE)
  # annual GVA = item 769 x m; m = 12 perennial (nature 1), months operated otherwise, 1 if the
  # reference period is the accounting year (265 = 4). Reproduces the factsheet GVA exactly (VAL).
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
  pat_b <- sprintf("block\\s*%s\\s*(\\.|$)", blk)
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
    E[, `:=`(workers = tot_809, owners = tot_801, hired = tot_802 + tot_803, unpaid_family = tot_804,   # 804 = helper/apprentice in NSS 73
             fem_workers = ft_f_809 + pt_f_809)]
    E[, market := !(npi %in% 1L) & !(nic5 %in% "70100")]   # KI 3.9.2: market producers (non-market have no GVA)
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
# Published: ASUSE 2023-24 factsheet (Table 1 and key indicators; coverage excludes NIC 68108, README 4);
# NSS 73rd round Key Indicators (KI) report, Statements and section 3.9. Female-owned share = female
# proprietary establishments as a share of ALL establishments (this definition reproduces 26.2).
A0 <- A[!(nic5 %in% "68108")]
VAL <- list(
  asuse_estab_crore = c(est = A0[, sum(w)] / 1e7, pub = 7.33995),
  asuse_workers_crore = c(est = A0[, sum(w * workers)] / 1e7, pub = 12.05998),
  asuse_fem_prop_share = c(est = 100 * A0[, sum(w * (own == 2)) / sum(w)], pub = 26.2),
  asuse_gva_total_crore = c(est = A0[market == TRUE, sum(w * gva_y, na.rm = TRUE)] / 1e7, pub = 1797278),
  asuse_gva_per_worker = c(est = A0[market == TRUE, sum(w * gva_y, na.rm = TRUE) / sum(w * workers)], pub = 149742),
  asuse_gva_per_estab  = c(est = A0[market == TRUE, sum(w * gva_y, na.rm = TRUE) / sum(w)], pub = 245687),
  nss73_ent_crore = c(est = N[, sum(w)] / 1e7, pub = 6.34),
  nss73_fem_prop_share = c(est = 100 * N[, sum(w * (own == 2)) / sum(w)], pub = 19.5),
  nss73_fem_share_oae = c(est = 100 * N[oae == TRUE, sum(w * (own == 2)) / sum(w)], pub = 22.3),
  nss73_fem_share_estab = c(est = 100 * N[oae == FALSE, sum(w * (own == 2)) / sum(w)], pub = 4.8),
  nss73_gva_total_crore = c(est = N[market == TRUE, sum(w * gva_y, na.rm = TRUE)] / 1e7, pub = 1152338),
  nss73_gva_per_worker = c(est = N[market == TRUE, sum(w * gva_y, na.rm = TRUE) / sum(w * workers)], pub = 103744),
  nss73_gva_per_ent = c(est = N[market == TRUE, sum(w * gva_y, na.rm = TRUE) / sum(w)], pub = 181908))
# alternative definition, reported for the record: female share of proprietary establishments only
FEMDEF <- c(asuse_all = 100 * A0[, sum(w * (own == 2)) / sum(w)], asuse_proprietary = 100 * A0[own %in% 1:3, sum(w * (own == 2)) / sum(w)],
            nss73_all = 100 * N[, sum(w * (own == 2)) / sum(w)], nss73_proprietary = 100 * N[own %in% 1:3, sum(w * (own == 2)) / sum(w)])
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

RES <- list(val = VAL, femdef = FEMDEF, run = Sys.time(), nsample = D[, .N, by = year],
            nraw = c(nss73 = nrow(N), asuse = nrow(A)))   # unweighted records in the released files
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
  per_hour = sum(w * gva_month) / sum(w * workers * pmax(hours, 1) * 25), n_obs = .N), by = .(owner_type, oae, home, dep)]
RES$returns23 <- ret(R[year == 2023])
RES$returns23_all <- R[year == 2023, .(median_pw = wq(gva_pw_m, w, 0.5), p25 = wq(gva_pw_m, w, 0.25), p75 = wq(gva_pw_m, w, 0.75),
  below_cas25 = sum(w * (gva_pw_m < 25 * B$cas_f_all)) / sum(w), below_cas22 = sum(w * (gva_pw_m < 22 * B$cas_f_all)) / sum(w),
  below_cas30 = sum(w * (gva_pw_m < 30 * B$cas_f_all)) / sum(w), per_hour = sum(w * gva_month) / sum(w * workers * pmax(hours, 1) * 25),
  n_obs = .N, n_nonpos = sum(gva_pw_m <= 0)), by = owner_type]
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

# (7) questionnaire routing: share of women's home-based manufacturing establishments (ASUSE 2023-24)
#     that report providing manufacturing services (item 238), the filter for the contract item 239
RES$ms_home_fem_mfg <- A[nic2 %in% 10:33 & own == 2L & loc %in% 1L, sum(w * manuf_serv) / sum(w)]

saveRDS(RES, file.path(OUT, "p11_results.rds"))
cat("Saved", file.path(OUT, "p11_results.rds"), "\n")
