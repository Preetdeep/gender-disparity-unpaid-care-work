## LaTeX tables and Figure 1 from output/results.json (no hand-typed numbers).
source(file.path(Sys.getenv("P12_CODE", "/workspace/papers/P12/repo/code"), "00_config.R"))
R <- fromJSON(file.path(OUT, "results.json"), simplifyVector = FALSE)
pp <- function(x, d = 2) formatC(100 * x, format = "f", digits = d)
f1 <- function(x, d = 1) formatC(x, format = "f", digits = d)
pv <- function(p) if (is.null(p)) "--" else if (p < 0.001) "<0.001" else formatC(p, format = "f", digits = 3)
ci <- function(e) sprintf("[%s, %s]", pp(e$lo), pp(e$hi))
big <- function(n) formatC(n, big.mark = ",", format = "d")
wr <- function(x, f) writeLines(x, file.path(TABLES, f))

## Table 1
d1 <- R$desc$D1; d0 <- R$desc$D0; m <- R$main
row <- function(l, a, b) sprintf("%s & %s & %s \\\\", l, a, b)
wr(c("\\begin{tabular}{lrr}", "\\toprule", " & Husband stops working & Husband stays employed \\\\", "\\midrule",
  row("Wife's age (years)", f1(d1$w_age), f1(d0$w_age)),
  row("Wife is a graduate (\\%)", f1(d1$w_grad), f1(d0$w_grad)),
  row("Child aged 0--5 in household (\\%)", f1(d1$child05), f1(d0$child05)),
  row("Household size", f1(d1$hhsize, 2), f1(d0$hhsize, 2)),
  row("Husband regular salaried at $t-1$ (\\%)", f1(d1$h_regular), f1(d0$h_regular)),
  row("Husband casual labourer at $t-1$ (\\%)", f1(d1$h_casual), f1(d0$h_casual)),
  row("Husband self-employed or helper at $t-1$ (\\%)", f1(d1$h_self), f1(d0$h_self)),
  row("Wife in labour force at $t$ (\\%, raw)", f1(m$raw_entry_D1, 2), f1(m$raw_entry_D0, 2)),
  row("Wife employed at $t$ (\\%, raw)", f1(m$raw_empentry_D1, 2), f1(m$raw_empentry_D0, 2)),
  row("Couple-quarter transitions", big(d1$n), big(d0$n)),
  "\\bottomrule", "\\end{tabular}"), "table1.tex")

## Table 2
r <- R$rep1718
cols <- list(m$entry_lf, m$entry_emp, m$exit, m$placebo, m$pretrend, r$entry_lf, r$exit)
ev <- c(m$n_events_entry, m$n_events_entry, m$n_events_exit, m$n_placebo_events, m$n_pretrend_events, r$n_events_entry, r$n_events_exit)
cells <- function(fun) paste(sapply(cols, fun), collapse = " & ")
wr(c("\\begin{tabular}{lccccccc}", "\\toprule",
  " & \\multicolumn{5}{c}{2022--23 and 2023--24 pooled} & \\multicolumn{2}{c}{2017--18} \\\\", "\\cmidrule(lr){2-6}\\cmidrule(lr){7-8}",
  " & (1) & (2) & (3) & (4) & (5) & (6) & (7) \\\\",
  " & Enters LF & Enters work & Leaves work & Lead placebo & Pre-trend & Enters LF & Leaves work \\\\", "\\midrule",
  paste("Husband stops working &", cells(function(e) pp(e$b)), "\\\\"),
  paste(" &", cells(function(e) sprintf("(%s)", pp(e$se))), "\\\\"),
  paste("95\\% CI &", cells(ci), "\\\\"),
  paste("$p$-value &", cells(function(e) pv(e$p)), "\\\\"),
  paste("Transitions &", cells(function(e) big(e$n)), "\\\\"),
  paste("Stop events &", paste(sapply(ev, big), collapse = " & "), "\\\\"),
  "\\bottomrule", "\\end{tabular}"), "table2.tex")

## Table 3: layoff checks and heterogeneity
lj <- R$layoff$by_jobtype; ld <- R$layoff$by_dest
lr <- function(l, e, evn) sprintf("%s & %s & %s & %s & -- & %s \\\\", l, pp(e$b), ci(e), pv(e$p), big(evn))
het <- R$het; ntest <- sum(sapply(het, function(h) !is.null(h$p)))
lab <- function(g, dm) { if (dm == "Child aged 0-5") return(ifelse(g == "1", "Yes", "No"))
  c(below_primary = "Below primary", primary_middle = "Primary or middle", secondary = "Secondary to diploma", graduate = "Graduate or above",
    `18-29` = "18--29", `30-44` = "30--44", `45-59` = "45--59", ST_SC = "ST or SC", OBC = "OBC", other = "Other", casual = "Casual",
    regular = "Regular salaried", self = "Self-employed or helper", T1 = "Lowest", T2 = "Middle", T3 = "Highest")[[g]] }
hr <- function(h) if (is.null(h$p)) sprintf("\\quad %s & %s & \\multicolumn{3}{c}{not tested (%d entrant%s after a stop)} & %s \\\\",
  lab(h$group, h$dim), pp(h$b), h$event_entrants, ifelse(h$event_entrants == 1, "", "s"), big(h$events)) else
  sprintf("\\quad %s & %s & [%s, %s] & %s & %s & %s \\\\", lab(h$group, h$dim), pp(h$b), pp(h$lo), pp(h$hi), pv(h$p), formatC(h$q, format = "f", digits = 3), big(h$events))
dims <- unique(sapply(het, `[[`, "dim"))
hl <- unlist(lapply(dims, function(dm) c(sprintf("\\multicolumn{6}{l}{\\textit{%s}} \\\\", sub("0-5", "0--5", dm)), sapply(Filter(function(h) h$dim == dm, het), hr))))
wr(c("\\begin{tabular}{lrcccr}", "\\toprule", " & Estimate & 95\\% CI & $p$ & BH $q$ & Events \\\\", "\\midrule",
  "\\multicolumn{6}{l}{\\textbf{A. Layoff checks}} \\\\",
  lr("\\quad Husband was regular salaried", lj$regular, lj$regular$events), lr("\\quad Husband was casual", lj$casual, lj$casual$events),
  lr("\\quad Husband was self-employed", lj$self, lj$self$events),
  lr("\\quad Husband becomes unemployed (81/82)", ld$unemployed, ld$unemployed$events),
  lr("\\quad Husband leaves labour force, other", ld$other_olf, ld$other_olf$events),
  lr("\\quad Husband pensioner/disabled/sick (94/95/98)", ld$pension_disab_sick, ld$pension_disab_sick$events),
  lr("\\quad Excluding codes 94/95/98", R$layoff$excl_949598, m$n_events_entry - ld$pension_disab_sick$events),
  "\\midrule", sprintf("\\multicolumn{6}{l}{\\textbf{B. Heterogeneity} (%d tests, Benjamini--Hochberg)} \\\\", ntest), hl,
  "\\bottomrule", "\\end{tabular}"), "table3.tex")

## Table 4: entry type and other members
et <- R$entry_type; s1 <- R$entry_type_share_D1; s0 <- R$entry_type_share_D0; om <- R$other_members
sh <- function(s, k) if (is.null(s[[k]])) "0.0" else f1(s[[k]])
tr4 <- function(l, k) sprintf("%s & %s & %s & %s & %s & %s \\\\", l, pp(et[[k]]$b), ci(et[[k]]), pv(et[[k]]$p), sh(s1, k), sh(s0, k))
wr(c("\\begin{tabular}{lrcrrr}", "\\toprule", " & & & & \\multicolumn{2}{c}{Share of entrants (\\%)} \\\\", "\\cmidrule(lr){5-6}",
  "Wife's status at $t$ & Estimate & 95\\% CI & $p$ & After stop & No stop \\\\", "\\midrule",
  tr4("Regular salaried", "regular"), tr4("Casual labour", "casual"), tr4("Self-employed", "self"), tr4("Unpaid helper", "helper"), tr4("Unemployed (seeking)", "unemployed"),
  sprintf("Entrants (count) & & & & %s & %s \\\\", big(R$n_entrants$D1), big(R$n_entrants$D0)),
  "\\midrule", sprintf("Another member aged 15--64 starts work & %s & %s & %s & \\multicolumn{2}{c}{mean if no stop: %s\\%%} \\\\", pp(om$b), ci(om), pv(om$p), f1(om$mean_D0, 2)),
  sprintf("\\quad Transitions; stop events & \\multicolumn{3}{l}{%s; %s} & & \\\\", big(om$n), big(om$events)),
  "\\bottomrule", "\\end{tabular}"), "table4.tex")

## Figure 1
es <- rbindlist(lapply(R$event$coefs, as.data.table)); es <- rbind(es[, .(rel, b, lo, hi)], data.table(rel = -1L, b = 0, lo = 0, hi = 0))
g <- ggplot(es, aes(rel, 100 * b)) + geom_hline(yintercept = 0, colour = "grey50") + geom_vline(xintercept = -0.5, linetype = 2, colour = "grey50") +
  geom_errorbar(aes(ymin = 100 * lo, ymax = 100 * hi), width = 0.15) + geom_point(size = 2.5) +
  labs(x = "Quarters relative to the husband's first quarter without work", y = "Wife in labour force (percentage points)") +
  scale_x_continuous(breaks = -3:2) + theme_bw(base_size = 12, base_family = "serif")
ggsave(file.path(FIGURES, "figure1.png"), g, width = 6.5, height = 4, dpi = 300); ggsave(file.path(FIGURES, "figure1.pdf"), g, width = 6.5, height = 4)
cat("tables and figure written\n")

## ---------------- Supplementary tables ----------------
B <- fromJSON(file.path(OUT, "build_diagnostics.json"), simplifyVector = FALSE); bm <- B$main_2223_2324; br <- B$replication_1718
C24 <- fromJSON(file.path(OUT, "plfs2024_check.json"), simplifyVector = FALSE)
r2 <- function(l, a, b) sprintf("%s & %s & %s \\\\", l, a, b)
wr(c("\\begin{tabular}{lrr}", "\\toprule", " & 2022--23 + 2023--24 & 2017--18 \\\\", "\\midrule",
  r2("Urban person-visit records read", big(bm$records), big(br$records)),
  r2("Revisit records whose first visit predates the files (dropped)", big(bm$revisit_records_without_first_visit), big(br$revisit_records_without_first_visit)),
  r2("Duplicate person-visit records", big(bm$dup_pid), big(br$dup_pid)),
  r2("Linked persons", big(bm$persons), big(br$persons)),
  r2("Persons with sex change or age gap $>2$ years (dropped)", big(bm$inconsistent_persons), big(br$inconsistent_persons)),
  r2("Persons seen in all four visits", big(bm$visits_per_person[["4"]]), big(br$visits_per_person[["4"]])),
  r2("2023--24 revisits linked to a 2022--23 first visit", big(bm$cross_year_revisits), "--"),
  r2("Couples (head and wife, both 18--59)", big(R$main$n_couples), "--"),
  r2("Couple transitions between consecutive quarters", big(R$main$n_transitions), "--"),
  r2("\\quad with husband employed at $t-1$", big(R$main$n_husband_emp0), "--"),
  r2("\\quad husband stops working", big(R$main$n_events_all), "--"),
  r2("\\quad weighted stop rate per quarter (\\%)", f1(R$main$stop_rate, 2), "--"),
  r2("Stop events, wife out of labour force at $t-1$", big(R$main$n_events_entry), big(R$rep1718$n_events_entry)),
  r2("\\quad of which from 2023--24 first visits only", big(R$main$n_events_entry_2324file_only), "--"),
  "\\bottomrule", "\\end{tabular}"), "tableS1.tex")
v <- fread(file.path(TABLES, "validation.tsv"))
wr(c("\\begin{tabular}{llllrr}", "\\toprule", "Year & Sector & Sex & Indicator & Published & Reproduced \\\\", "\\midrule",
  v[, sprintf("%s & %s & %s & %s & %s & %s \\\\", sub("-", "--", year), area, sex, ind, f1(pub), f1(rep))], "\\bottomrule", "\\end{tabular}"), "tableS2.tex")
rb <- R$rob; es <- R$event$coefs
rr <- function(l, e) sprintf("%s & %s & (%s) & %s & %s & %s \\\\", l, pp(e$b), pp(e$se), ci(e), pv(e$p), big(e$n))
wr(c("\\begin{tabular}{lrrcrr}", "\\toprule", " & Estimate & SE & 95\\% CI & $p$ & $N$ \\\\", "\\midrule",
  "\\multicolumn{6}{l}{\\textit{A. Wife enters labour force: alternative specifications}} \\\\",
  rr("Baseline (Table 2, col. 1)", R$main$entry_lf), rr("State-by-quarter fixed effects only", R$main$entry_lf_nocontrols),
  rr("District-by-quarter fixed effects", rb$district_qtr_fe), rr("Unweighted", rb$unweighted),
  rr("Transitions ending Jul 2022--Jun 2023", rb$only_2022_23_t), rr("Transitions ending Jul 2023--Jun 2024", rb$only_2023_24_t),
  rr("Households first visited in 2023--24 only", rb$file_2023_24_only),
  sprintf("Logit (log-odds) & %s & & & %s & \\\\", formatC(rb$logit_ame$b_logodds, format = "f", digits = 3), pv(rb$logit_ame$p)),
  "\\multicolumn{6}{l}{\\textit{B. Event study (Figure 1), reference quarter $-1$}} \\\\",
  sapply(es, function(e) sprintf("\\quad Quarter %s & %s & (%s) & %s & %s & \\\\", ifelse(e$rel < 0, paste0("$-$", -e$rel), e$rel), pp(e$b), pp(e$se), ci(e), pv(e$p))),
  sprintf("\\quad Couples; ever-treated couples & \\multicolumn{5}{l}{%s; %s} \\\\", big(R$event$n_couples), big(R$event$n_treated)),
  "\\multicolumn{6}{l}{\\textit{C. Panel attrition}} \\\\",
  sprintf("\\quad Couples missing at next visit (\\%%) & %s & & & & %s \\\\", f1(R$attrition$rate, 2), big(R$attrition$n)),
  rr("\\quad Husband not employed (difference)", R$attrition$husband_not_employed),
  "\\multicolumn{6}{l}{\\textit{D. Husband's status after the stop (share of events, \\%)}} \\\\",
  sprintf("\\quad Unemployed; pensioner/disabled/sick; other out of labour force & \\multicolumn{5}{l}{%s; %s; %s} \\\\", f1(100 * R$main$dest_shares$unemployed), f1(100 * R$main$dest_shares$pension_disab_sick), f1(100 * R$main$dest_shares$other_olf)),
  "\\bottomrule", "\\end{tabular}"), "tableS3.tex")
ov <- C24$overlap
wr(c("\\begin{tabular}{lrrrr}", "\\toprule", "Quarter of the 2024 file & Urban persons & Visit & In 2023--24 first visits & Persons matched by key \\\\", "\\midrule",
  sapply(C24$counts, function(x) { q <- as.integer(sub("Q", "", x$Quarter)); o <- Filter(function(z) z$quarter == q, ov)
    sprintf("%s & %s & %s & %s & %s \\\\", x$Quarter, big(x$N), x$Visit, if (length(o)) big(o[[1]]$n_2324_v1) else "--", if (length(o)) big(o[[1]]$keys_in_2324) else "--") }),
  "\\bottomrule", "\\end{tabular}"), "tableS4.tex")
cat("supplement tables written\n")
