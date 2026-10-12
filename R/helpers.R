# =============================================================================
# helpers.R -- estimation and reporting helpers shared by every manuscript.
#
# Inference: all means, gaps and regressions are survey-weighted and use
# standard errors clustered on the First Stage Unit (FSU), the primary
# sampling unit of the NSS design. This is conservative relative to
# household clustering and nests it. Strata are not used because the public
# file does not identify them consistently; this makes SEs conservative.
# =============================================================================

wmean <- function(x, w) { ok <- !is.na(x) & !is.na(w); sum(x[ok] * w[ok]) / sum(w[ok]) }

# Weighted mean with FSU-clustered SE, optionally by group.
# Returns data.frame(group, est, se, n).
est_mean <- function(d, y, by = NULL, cluster = "fsu", weight = "weight") {
  d <- as.data.frame(d)
  d <- d[!is.na(d[[y]]) & !is.na(d[[weight]]), , drop = FALSE]
  if (is.null(by)) {
    m <- feols(as.formula(paste(y, "~ 1")), data = d, weights = d[[weight]],
               cluster = d[[cluster]])
    return(data.frame(group = "All", est = unname(coef(m)), se = unname(se(m)), n = nrow(d)))
  }
  d <- d[!is.na(d[[by]]), , drop = FALSE]
  d$.g <- droplevels(as.factor(d[[by]]))
  m <- feols(as.formula(paste(y, "~ 0 + .g")), data = d, weights = d[[weight]],
             cluster = d[[cluster]])
  data.frame(group = sub("^\\.g", "", names(coef(m))), est = unname(coef(m)),
             se = unname(se(m)), n = as.vector(table(d$.g)))
}

# Difference in weighted means between two groups (b - a), clustered SE.
est_gap <- function(d, y, by, a, b, cluster = "fsu", weight = "weight") {
  d <- as.data.frame(d)
  d <- d[!is.na(d[[y]]) & d[[by]] %in% c(a, b), , drop = FALSE]
  d$.t <- as.integer(d[[by]] == b)
  m <- tryCatch(feols(as.formula(paste(y, "~ .t")), data = d, weights = d[[weight]],
                      cluster = d[[cluster]]), error = function(e) NULL)
  if (is.null(m) || !".t" %in% rownames(coeftable(m)))
    return(list(est = NA, se = NA, p = NA, base = NA, n = nrow(d)))
  ct <- coeftable(m)[".t", ]
  list(est = unname(ct[1]), se = unname(ct[2]), p = unname(ct[4]),
       base = unname(coef(m)[1]), n = nrow(d))
}

# Extract one coefficient from a fixest model.
coef_of <- function(m, term) {
  if (is.null(m)) return(list(est = NA, se = NA, p = NA))
  ct <- coeftable(m)
  if (!term %in% rownames(ct)) return(list(est = NA, se = NA, p = NA))
  list(est = unname(ct[term, 1]), se = unname(ct[term, 2]), p = unname(ct[term, 4]))
}

# Participation decomposition: mean = participation rate x mean among doers.
decompose_participation <- function(d, y, by, weight = "weight") {
  d <- as.data.frame(d)
  d$.p <- as.integer(d[[y]] > 0)
  split(d, d[[by]]) |>
    lapply(function(g) data.frame(
      mean = wmean(g[[y]], g[[weight]]),
      participation = wmean(g$.p, g[[weight]]),
      mean_doers = wmean(g[[y]][g$.p == 1], g[[weight]][g$.p == 1]),
      n = nrow(g))) |>
    dplyr::bind_rows(.id = "group")
}

# ---- Formatting --------------------------------------------------------------
.fmt <- function(x, d, suffix = "") {
  x <- suppressWarnings(as.numeric(x)); x[!is.finite(x)] <- NA
  ifelse(is.na(x), "--", paste0(formatC(x, format = "f", digits = d, big.mark = ","), suffix))
}
f0  <- function(x) .fmt(x, 0)
f1  <- function(x) .fmt(x, 1)
f2  <- function(x) .fmt(x, 2)
pct <- function(x, d = 1) .fmt(100 * as.numeric(x), d, "%")
pp  <- function(x, d = 1) .fmt(100 * as.numeric(x), d, " percentage points")
fn  <- function(n) .fmt(n, 0)
hrs <- function(m) f1(as.numeric(m) / 60)

stars <- function(p) ifelse(is.na(p), "", ifelse(p < .01, "***", ifelse(p < .05, "**", ifelse(p < .1, "*", ""))))

sig_phrase <- function(p) {
  if (is.na(p)) return("not estimable")
  if (p < 0.01) "statistically significant at the 1% level"
  else if (p < 0.05) "statistically significant at the 5% level"
  else if (p < 0.10) "significant only at the 10% level"
  else "not statistically distinguishable from zero"
}

# "12.3 minutes (SE 1.1)" style.
est_se <- function(e, digits = 1, unit = "minutes") {
  if (is.null(e$est) || is.na(e$est)) return("not estimable")
  fmt <- function(x) .fmt(x, digits)
  paste0(fmt(e$est), if (nzchar(unit)) paste0(" ", unit) else "", " (SE ", fmt(e$se), ")")
}

# Direction word for a signed estimate.
more_less <- function(x, more = "more", less = "less") ifelse(is.na(x), "[n/a]", ifelse(x >= 0, more, less))
higher_lower <- function(x) more_less(x, "higher", "lower")

# 95% confidence interval text.
ci95 <- function(e, digits = 1) {
  fmt <- function(x) .fmt(x, digits)
  paste0("[", fmt(e$est - 1.96 * e$se), ", ", fmt(e$est + 1.96 * e$se), "]")
}

# ---- Tables ------------------------------------------------------------------
# Means (SE) table: rows = outcomes, columns = groups.
means_table <- function(d, ys, by, labels = ys, digits = 1) {
  out <- lapply(seq_along(ys), function(i) {
    r <- est_mean(d, ys[i], by)
    data.frame(Outcome = labels[i], group = r$group,
               cell = paste0(.fmt(r$est, digits), " (", .fmt(r$se, digits), ")"))
  })
  tidyr::pivot_wider(dplyr::bind_rows(out), names_from = group, values_from = cell)
}

tab <- function(df, caption, label = NULL, align = NULL, notes = NULL, ...) {
  df <- as.data.frame(df); rownames(df) <- NULL
  k <- knitr::kable(df, format = "latex", booktabs = TRUE, caption = caption, row.names = FALSE,
                    label = label, align = align, linesep = "", ...)
  k <- kableExtra::kable_styling(k, latex_options = c("hold_position", "scale_down"),
                                 font_size = 9)
  if (!is.null(notes)) k <- kableExtra::footnote(k, general = notes, threeparttable = TRUE,
                                                 general_title = "Notes:", footnote_as_chunk = TRUE)
  k
}

# fixest regression table in LaTeX (AER style).
reg_table <- function(models, title, label, dict = NULL, keep = NULL, notes = NULL) {
  hdr <- names(models); models <- unname(models)
  args <- list(models, tex = TRUE, title = title, label = label,
               style.tex = style.tex("aer"), fitstat = ~ n + r2, digits = 3,
               se.below = TRUE, depvar = FALSE, float = TRUE, placement = "!htbp",
               fontsize = "small")
  if (!is.null(hdr)) args$headers <- list(hdr)
  if (!is.null(dict)) args$dict <- dict
  if (!is.null(keep)) args$keep <- keep
  out <- unlist(strsplit(paste(do.call(etable, args), collapse = "\n"), "\n"))
  if (!is.null(notes)) {
    i <- max(grep("\\\\end\\{table\\}", out))
    out <- append(out, paste0("\\par\\smallskip{\\footnotesize\\raggedright \\textit{Notes:} ", notes,
                              " * p<0.10, ** p<0.05, *** p<0.01.\\par}"), after = i - 1)
  }
  cat(out, sep = "\n")
  invisible(out)
}

# Synthetic-data stamp for captions.
syn_note <- function() if (TUS_SYNTHETIC) " [SYNTHETIC TEST DATA -- NOT RESULTS]" else ""

# Write the panel validation summary as a LaTeX-safe table (appendix use).
validation_table <- function(pd) {
  V <- panel_validation(pd)
  data.frame(
    Check = c("Activity records", "Person-days (diaries)", "Households", "First Stage Units",
              "Diaries summing to 1,440 minutes", "Records flagged minor (secondary)",
              "Persons with varying weight", "Invalid activity codes",
              "Married persons with linked spouse", "Under-6 count method"),
    Value = c(fn(V$n_rows), fn(if (is.null(V$n_diarists)) V$n_persons else V$n_diarists), fn(V$n_households), fn(V$n_fsu),
              pct(V$share_diaries_1440), pct(V$share_rows_minor),
              pct(V$share_persons_weight_varies, 2),
              if (length(V$invalid_act3_codes)) paste(V$invalid_act3_codes, collapse = ", ") else "None",
              if (is.null(V$share_married_with_linked_spouse)) "n/a" else pct(V$share_married_with_linked_spouse),
              V$under6_method))
}

# Standard control sets used across papers (strings for fixest formulas).
CTRL <- list(
  demo   = "i(age_band) + i(edu_tier) + urban",
  hh     = "hh_size + hh_n_60plus + hh_n_6_14",
  fe     = "state + dow"
)

# ---- Specification helpers -----------------------------------------------------
# Keep only controls that exist and vary in d; returns a formula RHS string.
ctrl <- function(d, vars) {
  base <- function(v) sub("^i\\((.*)\\)$", "\\1", v)
  ok <- vapply(vars, function(v) {
    b <- base(v)
    b %in% names(d) && sum(!is.na(d[[b]])) > 0 && data.table::uniqueN(na.omit(d[[b]])) > 1
  }, logical(1))
  if (!any(ok)) "1" else paste(vars[ok], collapse = " + ")
}
fe <- function(d, vars = c("state", "dow")) {
  ok <- vars[vars %in% names(d) & vapply(vars, function(v) v %in% names(d) &&
                                            data.table::uniqueN(na.omit(d[[v]])) > 1, logical(1))]
  if (length(ok)) paste("|", paste(ok, collapse = " + ")) else ""
}

# Stop with a clear message if a paper's essential variables are missing.
require_cols <- function(d, cols, paper) {
  miss <- cols[!cols %in% names(d) | vapply(cols, function(v) !v %in% names(d) || all(is.na(d[[v]])), logical(1))]
  if (length(miss)) stop(paper, " needs variables not found in the panel: ",
                         paste(miss, collapse = ", "),
                         ". Map them in TUS_COLS (R/build_panel.R).", call. = FALSE)
  invisible(TRUE)
}

# Oster (2019) bias-adjusted coefficient under delta = 1 and R_max = mult * R_tilde
# (mult = 1.3 is Oster's recommended default). m0: short regression, m1: long.
oster_beta <- function(m0, m1, term, mult = 1.3) {
  b0 <- coef(m0)[term]; b1 <- coef(m1)[term]
  r0 <- fixest::r2(m0, "r2"); r1 <- fixest::r2(m1, "r2")
  rmax <- min(1, mult * r1)
  unname(b1 - (b0 - b1) * (rmax - r1) / (r1 - r0))
}

# Colours used consistently across papers (colour-blind safe, print safe).
SEX_COLS <- c(Men = "#2C6E9B", Women = "#C2512F")

# feols that returns NULL (with a message) when a model cannot be estimated,
# e.g. a constant outcome in a small subsample. coef_of(NULL, .) gives NA.
reg <- function(fml, data, ...) {
  tryCatch(feols(fml, data, weights = ~weight, cluster = ~fsu, ...),
           error = function(e) { message("reg(): ", conditionMessage(e)); NULL })
}
cf <- function(m, term) if (is.null(m) || !term %in% names(coef(m))) NA_real_ else unname(coef(m)[term])

# Percent for use inside raw LaTeX blocks (abstract), where % must be escaped.
pctx <- function(x, d = 1) gsub("%", "\\\\%", pct(x, d))

# "1.3 minutes (SE 1.1) less" -- magnitude with direction word, for prose.
diff_txt <- function(e, more = "more", less = "less", digits = 1, unit = "minutes") {
  if (is.na(e$est)) return("[not estimable]")
  paste0(.fmt(abs(e$est), digits), if (nzchar(unit)) paste0(" ", unit) else "",
         " (SE ", .fmt(e$se, digits), ") ", more_less(e$est, more, less))
}
# Is an estimate negative and significant at 5%?
is_neg <- function(e) isTRUE(!is.na(e$est) && e$est < 0 && e$p < 0.05)
is_pos <- function(e) isTRUE(!is.na(e$est) && e$est > 0 && e$p < 0.05)
is_sig <- function(e) isTRUE(!is.na(e$p) && e$p < 0.05)
# Pick text by condition (keeps results-dependent prose honest).
iff <- function(cond, yes, no) if (isTRUE(cond)) yes else no

# Difference in a share, in percentage points with SE and direction word.
diff_pp <- function(e, more = "higher", less = "lower", digits = 1) {
  if (is.null(e$est) || is.na(e$est)) return("not estimable")
  paste0(.fmt(100 * abs(e$est), digits), " percentage points (SE ", .fmt(100 * e$se, digits), ") ",
         more_less(e$est, more, less))
}
