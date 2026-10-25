# Smoke test for analysis_asuse.R on SYNTHETIC data (random numbers in the MoSPI CSV release
# formats: ASUSE 2023-24 "LEVEL - NN (...).csv", NSS 73 "(Semi-Round-k)- Block N.csv").
# Checks that the readers, merges and outputs run end to end. Not real data.
suppressMessages(library(data.table)); set.seed(11)
T <- Sys.getenv("P11_TEST_DIR", file.path(tempdir(), "p11syn")); A <- file.path(T, "asuse2324"); N <- file.path(T, "nss73")
dir.create(A, recursive = TRUE, showWarnings = FALSE); dir.create(N, recursive = TRUE, showWarnings = FALSE)
n <- 3000
fsu <- 10001 + (seq_len(n) - 1) %/% 50; est <- (seq_len(n) - 1) %% 50 + 1
K <- data.table(fsu_serial_no = fsu, segment_no = 1, second_stage_stratum_no = 1, sample_est_no = est)
K2 <- copy(K); setnames(K2, "second_stage_stratum_no", "second_stage_stratum")   # name used in levels 08 and 09
nic2 <- sample(c(10, 14, 47, 56, 96), n, TRUE); con <- sample(1:2, n, TRUE, c(.1, .9)); mf <- nic2 < 34
own <- sample(c(1, 2, 4), n, TRUE, c(.7, .25, .05)); mlt <- round(runif(n, 500, 5000) * 100, 2)
l02 <- cbind(K, data.table(nss_region = sample(c(91, 101, 271), n, TRUE), sector = sample(1:2, n, TRUE), stratum = 1, sub_stratum = 1,
  major_nic_2dig = nic2, major_nic_5dig = sprintf("%05d", nic2 * 1000 + 1), ownership_type = own, location = sample(1:6, n, TRUE),
  est_type = sample(1:2, n, TRUE, c(.15, .85)), nature_of_operation = 1, months_operated = 12, daily_work_hours = 8, non_profit = 2,
  used_internet = 2, registered = 2,
  contract_manuf_service = ifelse(mf, con, NA), contract_type = ifelse(mf & con == 1, sample(1:3, n, TRUE), NA),
  equipment_by_contractor = ifelse(mf & con == 1, 2, NA), other_contract_services = ifelse(!mf, con, NA),
  other_contract_type = ifelse(!mf & con == 1, sample(1:3, n, TRUE), NA), mlt = mlt))
l03 <- cbind(K, data.table(ref_period_type = 1, mlt = mlt))
l08 <- cbind(K2, data.table(item_no = 769, value_rs = round(rlnorm(n, 9, 1)), mlt = mlt))
wo <- pmax(1, rpois(n, 1))
mk9 <- function(item) cbind(K2, data.table(item_no = item, full_time_male = ifelse(own == 1, wo, 0), full_time_female = ifelse(own == 2, wo, 0),
  part_time_male = 0, part_time_female = 0, total_workers = wo, mlt = mlt))
l09 <- rbind(mk9(781), mk9(789))
nm <- c(`2` = "Block 2", `3` = "Block 3", `8` = "Block 7", `9` = "Block 8")
for (lv in c(2, 3, 8, 9)) fwrite(get(sprintf("l%02d", lv)), file.path(A, sprintf("LEVEL - %02d (%s) (1).csv", lv, nm[[as.character(lv)]])), na = "")
for (sr in 1:2) {
  m <- n / 2; id <- paste0(sr, formatC(1:m, width = 8, flag = "0"))
  b2 <- data.table(ENTID = id, Vill_Blk_Slno = sample(20001:20200, m, TRUE), Sector = sample(1:2, m, TRUE), State_Region = sample(c(91, 101, 271), m, TRUE),
    Stratum = 1, SubStratumNo = 1, b2_q202 = sample(c(10001, 14101, 47211, 56101, 96021), m, TRUE), b2_q204 = sample(c(1, 2, 4), m, TRUE, c(.75, .2, .05)),
    b2_q205 = 2, b2_q210 = sample(1:6, m, TRUE), b2_q211 = sample(1:2, m, TRUE, c(.85, .15)), b2_q213 = 1, b2_q214 = 12, b2_q215 = 8,
    b2_q219 = 2, b2_q227 = 2, b2_q237 = sample(1:2, m, TRUE, c(.1, .9)), b2_q238 = sample(1:3, m, TRUE), b2_q239 = 1,
    NSS = 1, NSC = 2, MLT = 2000, Weight_SS = 20, Weight_SC = runif(m, 5, 50))
  b7 <- data.table(ENTID = id, b7_q2 = 779, b7_q3 = round(rlnorm(m, 8.8, 1)))
  b8 <- data.table(ENTID = rep(id, 2), b8_q2 = rep(c(801, 809), each = m), b8_q3 = 1, b8_q4 = 0, b8_q6 = 0, b8_q7 = 0, b8_q9 = 1)
  fwrite(b2, file.path(N, sprintf("(Semi-Round-%d)- Block 2.csv", sr))); fwrite(b7, file.path(N, sprintf("(Semi-Round-%d)-Block 7.csv", sr)))
  fwrite(b8, file.path(N, sprintf("(Semi-Round-%d)-Block 8.csv", sr)))
  fwrite(b2[, .(ENTID)], file.path(N, sprintf("(Semi-Round-%d)-Block 2pt1.csv", sr)))   # decoy: must not match "Block 2"
}
OUT <- file.path(T, "out"); dir.create(OUT, showWarnings = FALSE)
# synthetic stand-in for plfs_benchmark.rds with the same structure (never the real one)
V <- CJ(qtr = c("Q1","Q2","Q3","Q4"), sector = 0:2, sex = 1:2)[, `:=`(pub = 300, wage_per_day = 301, diff = 1)]
V2 <- copy(V)[, `:=`(pub = 5000, earn30 = 5010, diff = 10)]
saveRDS(list(V11 = V, V12 = V2, BEN = list(cas_f_rural = 290, cas_f_urban = 360, cas_f_all = 300, cas_m_all = 450, se_f_all = 5500, se_m_all = 16000)), file.path(OUT, "plfs_benchmark.rds"))
Sys.setenv(ASUSE_RAW = A, NSS73_RAW = N, P11_OUT = OUT)
if (!file.exists("analysis_asuse.R")) stop("run from the paper folder")
source("analysis_asuse.R")
r <- readRDS(file.path(OUT, "p11_results.rds")); str(r, max.level = 1)
stopifnot(nrow(r$val) == 13, all(r$nraw == c(n, n)), nrow(r$totals) == 2)
print(r$totals); print(r$shiftshare); print(head(r$decomp_count)); print(r$reg$m3)
cat("SYNTHETIC SMOKE TEST PASSED; results in", OUT, "\n")
