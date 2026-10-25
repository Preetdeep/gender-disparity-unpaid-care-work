# Smoke test for analysis_asuse.R on SYNTHETIC data (random numbers in the published file
# formats). Checks that the readers, merges and outputs run end to end. Not real data.
suppressMessages(library(data.table)); set.seed(11)
T <- Sys.getenv("P11_TEST_DIR", file.path(tempdir(), "p11syn")); A <- file.path(T, "asuse2324"); N <- file.path(T, "nss73")
dir.create(A, recursive = TRUE); dir.create(N, recursive = TRUE)
n <- 3000
pad <- function(x, w) formatC(as.character(x), width = w, flag = " ")
z <- function(x, w) formatC(as.integer(x), width = w, flag = "0")
fsu <- z(10001 + (seq_len(n) - 1) %/% 50, 5); seg <- "1"; sss <- "01"; est <- z((seq_len(n) - 1) %% 50 + 1, 2)
sector <- sample(1:2, n, TRUE); reg <- paste0(z(sample(c(9, 10, 19, 27, 33), n, TRUE), 2), "1")
key <- function(lv) paste0(fsu, "ESU", sector, reg, "01", "001", "01", "1", "0101", seg, sss, est, z(lv, 2))
mult <- z(round(runif(n, 500, 5000) * 100), 10)
own <- sample(c(1, 2, 4), n, TRUE, c(.7, .25, .05)); loc <- sample(1:6, n, TRUE); typ <- sample(1:2, n, TRUE, c(.15, .85))
nic2 <- sample(c(10, 14, 47, 56, 96), n, TRUE); con <- sample(1:2, n, TRUE, c(.1, .9))
put <- function(x, from, val) { val <- as.character(val); substr(x, from, from + nchar(val) - 1) <- val; x }
blank <- function(len, lv) { x <- rep(strrep(" ", len), n); put(x, 1, key(lv)) }
l02 <- blank(103, 2)
for (f in list(list(32, "2"), list(33, z(nic2, 2)), list(35, z(nic2 * 1000 + 1, 5)), list(47, own), list(48, "6"), list(50, "1"),
               list(53, "2"), list(56, loc), list(57, typ), list(63, "1"), list(64, "12"), list(66, "08"), list(70, "2"), list(74, "2"),
               list(94, mult))) l02 <- put(l02, f[[1]], f[[2]])
mf <- nic2 < 34
l02[mf] <- put(put(put(put(l02[mf], 87, "1"), 88, con[mf]), 89, ifelse(con[mf] == 1, "1", " ")), 90, ifelse(con[mf] == 1, "2", " "))
l02[!mf] <- put(put(l02[!mf], 91, con[!mf]), 92, ifelse(con[!mf] == 1, "2", " "))
stopifnot(all(nchar(l02) == 103))
l03 <- put(put(blank(64, 3), 46, "1"), 55, mult)
l08 <- put(put(put(blank(56, 8), 32, "769"), 35, pad(round(rlnorm(n, 9, 1)), 12)), 47, mult)
wo <- pmax(1, rpois(n, 1))
mk9 <- function(item) { x <- blank(79, 9); x <- put(x, 32, item); x <- put(x, 35, z(ifelse(own == 1, wo, 0), 5))
  x <- put(x, 40, z(ifelse(own == 2, wo, 0), 5)); for (p in c(45, 50, 55, 60)) x <- put(x, p, "00000"); x <- put(x, 65, z(wo, 5)); put(x, 70, mult) }
l09 <- c(mk9("781"), mk9("789"))
for (lv in c(2, 3, 8, 9)) writeLines(get(sprintf("l%02d", lv)), file.path(A, sprintf("asuse_2324_esu_l%02d.txt", lv)))
for (sr in 1:2) {
  m <- n / 2; id <- paste0(sr, z(1:m, 8))
  b2 <- data.table(ENTID = id, Vill_Blk_Slno = sample(20001:20200, m, TRUE), Sector = sample(1:2, m, TRUE), State_Region = sample(c(91, 101, 271), m, TRUE),
    Stratum = 1, SubStratumNo = 1, b2_q202 = sample(c(10001, 14101, 47211, 56101, 96021), m, TRUE), b2_q204 = sample(c(1, 2, 4), m, TRUE, c(.75, .2, .05)),
    b2_q205 = 2, b2_q210 = sample(1:6, m, TRUE), b2_q211 = sample(1:2, m, TRUE, c(.85, .15)), b2_q213 = 1, b2_q214 = 12, b2_q215 = 8,
    b2_q219 = 2, b2_q227 = 2, b2_q237 = sample(1:2, m, TRUE, c(.1, .9)), b2_q238 = sample(1:3, m, TRUE), b2_q239 = 1, Weight_SC = runif(m, 5, 50))
  b7 <- data.table(ENTID = id, b7_q2 = 779, b7_q3 = round(rlnorm(m, 8.8, 1)))
  b8 <- data.table(ENTID = rep(id, 2), b8_q2 = rep(c(801, 809), each = m), b8_q3 = 1, b8_q4 = 0, b8_q6 = 0, b8_q7 = 0, b8_q9 = 1)
  fwrite(b2, file.path(N, sprintf("Semi-Round-%d Block 2.csv", sr))); fwrite(b7, file.path(N, sprintf("Semi-Round-%d Block 7.csv", sr)))
  fwrite(b8, file.path(N, sprintf("Semi-Round-%d Block 8.csv", sr)))
}
OUT <- file.path(T, "out"); dir.create(OUT)
pb <- path.expand("~/GResearcher_runs/data_derived/p11/plfs_benchmark.rds")
if (file.exists(pb)) file.copy(pb, OUT) else {   # synthetic stand-in with the same structure
  V <- CJ(qtr = c("Q1","Q2","Q3","Q4"), sector = 0:2, sex = 1:2)[, `:=`(pub = 300, wage_per_day = 301, diff = 1)]
  V2 <- copy(V)[, `:=`(pub = 5000, earn30 = 5010, diff = 10)]
  saveRDS(list(V11 = V, V12 = V2, BEN = list(cas_f_rural = 290, cas_f_urban = 360, cas_f_all = 300, cas_m_all = 450, se_f_all = 5500, se_m_all = 16000)), file.path(OUT, "plfs_benchmark.rds")) }
Sys.setenv(ASUSE_RAW = A, NSS73_RAW = N, P11_OUT = OUT)
src <- if (file.exists("analysis_asuse.R")) "analysis_asuse.R" else stop("run from the paper folder")
source(src)
r <- readRDS(file.path(OUT, "p11_results.rds")); str(r, max.level = 1)
print(r$totals); print(r$shiftshare); print(head(r$decomp_count)); print(r$reg$m3)
cat("SYNTHETIC SMOKE TEST PASSED; results in", OUT, "\n")
