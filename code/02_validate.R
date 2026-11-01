## Reproduce MoSPI CWS LFPR/WPR (age 15+) from the first-visit files: press note 23 Sep 2024, Tables 4-5.
source(file.path(Sys.getenv("P12_CODE", "/workspace/papers/P12/repo/code"), "01_build.R"))
pub <- fread(text = "year,area,sex,ind,pub
2023-24,rural,male,LFPR,78.7\n2023-24,rural,female,LFPR,39.7\n2023-24,urban,male,LFPR,75.0\n2023-24,urban,female,LFPR,26.1
2023-24,rural,male,WPR,75.3\n2023-24,rural,female,WPR,38.1\n2023-24,urban,male,WPR,70.5\n2023-24,urban,female,WPR,23.9
2022-23,rural,male,LFPR,78.8\n2022-23,rural,female,LFPR,34.6\n2022-23,urban,male,LFPR,73.9\n2022-23,urban,female,LFPR,24.0
2022-23,rural,male,WPR,75.2\n2022-23,rural,female,WPR,33.2\n2022-23,urban,male,WPR,69.3\n2022-23,urban,female,WPR,21.8
2017-18,rural,male,LFPR,75.6\n2017-18,rural,female,LFPR,21.7\n2017-18,urban,male,LFPR,74.1\n2017-18,urban,female,LFPR,19.6
2017-18,rural,male,WPR,69.1\n2017-18,rural,female,WPR,20.1\n2017-18,urban,male,WPR,67.7\n2017-18,urban,female,WPR,17.1")
rep <- rbindlist(lapply(names(YEARS), function(y) {
  d <- read_people(y, "v1")[age >= 15 & sex %in% 1:2]
  d[, .(LFPR = 100 * wmean(cws %in% LF, w), WPR = 100 * wmean(cws %in% EMP, w)),
    by = .(year, area = fifelse(sector == 1, "rural", "urban"), sex = fifelse(sex == 1, "male", "female"))]
}))
rep <- melt(rep, id.vars = c("year", "area", "sex"), variable.name = "ind", value.name = "rep")
v <- merge(pub, rep, by = c("year", "area", "sex", "ind")); v[, rep := round(rep, 1)][, match := abs(rep - pub) < 0.05]
fwrite(v, file.path(TABLES, "validation.tsv"), sep = "\t")
cat("Validation:", sum(v$match), "/", nrow(v), "match\n"); print(v)

## PLFS calendar 2024 file: first visits only? Overlap with 2023-24 first visits?
c24 <- fread(file.path(PLFS, "d2024/cperv1.csv"), select = c("Panel", "Quarter", "Visit", "Sector", "State_UT_Code", "FSU", "Sample_Sg_Sb_No",
  "Second_Stage_Stratum_No", "Sample_Household_Number", "Person_Serial_No"), showProgress = FALSE)
u24 <- c24[Sector == 2]
cnt <- u24[, .N, by = .(Panel, Quarter, Visit)][order(Quarter)]
v23 <- read_people("2023-24", "v1")[sector == 2]
v23[, key := paste(state, fsu, seg, sss, hh, srl, sep = ":")]
u24[, key := paste(num(State_UT_Code), num(FSU), num(Sample_Sg_Sb_No), num(Second_Stage_Stratum_No), num(Sample_Household_Number), num(Person_Serial_No), sep = ":")]
u24[, qn := as.integer(sub("Q", "", Quarter))]
ov <- rbindlist(lapply(c(3L, 4L), function(q) data.table(quarter = q, n_2024 = u24[qn == q, .N], n_2324_v1 = v23[qtr == q, .N],
  keys_in_2324 = u24[qn == q, sum(key %in% v23[qtr == q, key])])))
c24diag <- list(visits_present = sort(unique(u24$Visit)), counts = cnt, overlap = ov)
write_json(c24diag, file.path(OUT, "plfs2024_check.json"), auto_unbox = TRUE, pretty = TRUE)
print(cnt); print(ov)
