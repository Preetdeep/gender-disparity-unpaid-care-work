## Build person-visit records for urban PLFS panels; link first visits to revisits.
source(file.path(Sys.getenv("P12_CODE", "/workspace/papers/P12/repo/code"), "00_config.R"))

col <- function(d, stems) {          # first column matching any stem, ignoring the file suffix
  nm <- names(d); s <- tolower(sub("_(perv1|perrv|pervv|per_fv|per_rv|hhv1|hh_fv)$", "", nm))
  for (st in tolower(stems)) { i <- which(s == st); if (length(i)) return(d[[nm[i[1]]]]) }
  stop("missing column ", paste(stems, collapse = "/"))
}
read_people <- function(y, kind) {
  Y <- YEARS[[y]]; d <- fread(file.path(Y$dir, Y$files[[kind]]), showProgress = FALSE)
  is18 <- Y$layout == "1718"
  wage_cols <- grep("^b6q9_(.*3pt|act)", names(d), value = TRUE, ignore.case = TRUE)
  out <- data.table(
    year = y, kind = kind,
    qtr = as.integer(sub("Q", "", col(d, c("qtr", "quarter")))),
    visit = as.integer(sub("V", "", col(d, "visit"))),
    sector = num(col(d, "b1q3")), state = num(col(d, "state")),
    district = num(col(d, c("distcode", "dist_code", "district", "b1q4"))),
    fsu = num(col(d, c("b1q1", "fsu"))), seg = num(col(d, "b1q13")), sss = num(col(d, "b1q14")), hh = num(col(d, "b1q15")),
    srl = num(col(d, "b4q1")), rel = num(col(d, "b4q4")), sex = num(col(d, "b4q5")), age = num(col(d, "b4q6")),
    educ = num(col(d, "b4q8")), cws = num(col(d, "b6q5")),
    ern_reg = num(col(d, "b6q9")), ern_self = num(col(d, "b6q10")),
    wage7 = if (length(wage_cols)) rowSums(as.matrix(d[, lapply(.SD, num), .SDcols = wage_cols]), na.rm = TRUE) else NA_real_,
    NSS = num(col(d, "NSS")), NSC = num(col(d, "NSC")), mult = num(col(d, "mult")), noq = num(col(d, "no_qtr")))
  out[, w := fifelse(NSS == NSC, mult / 100, mult / 200) / noq]
  off <- if (kind == "rv") Y$q0rv else Y$q0; out[, cq := off + qtr]                               # calendar quarter index
  out
}
read_hh <- function(y) {
  Y <- YEARS[[y]]; d <- fread(file.path(Y$dir, Y$files[["h1"]]), showProgress = FALSE)
  is18 <- Y$layout == "1718"
  data.table(year = y, state = num(col(d, "state")), fsu = num(col(d, c("b1q1", "fsu"))),
             seg = num(col(d, "b1q13")), sss = num(col(d, "b1q14")), hh = num(col(d, "b1q15")),
             cq = YEARS[[y]]$q0 + as.integer(sub("Q", "", col(d, "qtr"))),
             social = num(col(d, "b3q4")), religion = num(col(d, "b3q3")),
             hce = if (is18) num(col(d, "b3q5")) else num(col(d, "b3q5pt6")))
}

build_panel <- function(years) {
  p <- rbindlist(lapply(years, function(y) rbind(read_people(y, "v1"), read_people(y, "rv"))))
  p <- p[sector == 2]                                    # urban rotational panel only
  p[, key := paste(state, fsu, seg, sss, hh, srl, sep = ":")]
  p[, cq1 := cq - (visit - 1L)]                          # quarter of the person's first visit
  p[, pid := paste(key, cq1, sep = "@")]
  diag <- list(records = nrow(p))
  dup <- p[, .N, by = .(pid, visit)][N > 1, unique(pid)]
  diag$dup_pid <- length(dup); p <- p[!pid %in% dup]
  has1 <- p[visit == 1, unique(pid)]
  diag$revisit_records_without_first_visit <- p[!pid %in% has1, .N]
  p <- p[pid %in% has1]
  bad <- p[, .(sx = uniqueN(sex), ag = max(age) - min(age)), by = pid][sx > 1 | ag > 2 | ag < 0, pid]
  diag$persons <- uniqueN(p$pid); diag$inconsistent_persons <- length(bad)
  p <- p[!pid %in% bad]
  # first-visit attributes carried to all visits
  f <- p[visit == 1, .(pid, w1 = w, age1 = age, educ1 = educ, district1 = district)]
  p <- f[p, on = "pid"]
  p[, hid := paste(state, fsu, seg, sss, hh, cq1, sep = ":")]
  h <- rbindlist(lapply(years, read_hh))
  h[, hid := paste(state, fsu, seg, sss, hh, cq, sep = ":")]
  h <- unique(h, by = "hid")
  p <- h[, .(hid, social, religion, hce)][p, on = "hid"]
  ros <- p[visit == 1, .(child05 = as.integer(any(age <= 5)), hhsize = .N), by = hid]
  p <- ros[p, on = "hid"]
  p[, `:=`(emp = as.integer(cws %in% EMP), lf = as.integer(cws %in% LF), jt = jobtype(cws))]
  p[, earn := fcase(cws %in% c(31, 71, 72), ern_reg, cws %in% c(11, 12, 61, 62), ern_self,
                    cws %in% c(41, 42, 51), wage7 * 30 / 7, default = NA_real_)]
  diag$persons_kept <- uniqueN(p$pid)
  diag$visits_per_person <- as.list(table(p[, .N, by = pid]$N))
  list(p = p, diag = diag)
}

if (sys.nframe() == 0L || identical(Sys.getenv("P12_RUN_BUILD"), "1")) {
  main <- build_panel(c("2022-23", "2023-24")); rep <- build_panel("2017-18")
  saveRDS(main$p, file.path(DERIVED, "persons_main.rds")); saveRDS(rep$p, file.path(DERIVED, "persons_1718.rds"))
  # cross-year linkage: revisits in the 2023-24 file whose first visit is in the 2022-23 file
  main$diag$cross_year_revisits <- main$p[year == "2023-24" & visit > 1 & cq1 <= 4, .N]
  write_json(list(main_2223_2324 = main$diag, replication_1718 = rep$diag), file.path(OUT, "build_diagnostics.json"), auto_unbox = TRUE, pretty = TRUE)
  print(main$diag); print(rep$diag)
}
