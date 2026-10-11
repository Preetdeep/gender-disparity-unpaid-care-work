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
  m <- feols(as.formula(paste(y, "~ .t")), data = d, weights = d[[weight]],
             cluster = d[[cluster]])
  ct <- coeftable(m)[".t", ]
  list(est = unname(ct[1]), se = unname(ct[2]), p = unname(ct[4]),
       base = unname(coef(m)[1]), n = nrow(d))
}

# Extract one coefficient from a fixest model.
coef_of <- function(m, term) {
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
f0  <- function(x) formatC(x, format = "f", digits = 0, big.mark = ",")
f1  <- function(x) formatC(x, format = "f", digits = 1, big.mark = ",")
f2  <- function(x) formatC(x, format = "f", digits = 2, big.mark = ",")
pct <- function(x, d = 1) paste0(formatC(100 * x, format = "f", digits = d), "%")
pp  <- function(x, d = 1) paste0(formatC(100 * x, format = "f", digits = d), " percentage points")
fn  <- function(n) formatC(n, format = "d", big.mark = ",")
hrs <- function(m) f1(m / 60)

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
  fmt <- function(x) formatC(x, format = "f", digits = digits, big.mark = ",")
  paste0(fmt(e$est), if (nzchar(unit)) paste0(" ", unit) else "", " (SE ", fmt(e$se), ")")
}

# Direction word for a signed estimate.
more_less <- function(x, more = "more", less = "less") ifelse(x >= 0, more, less)
higher_lower <- function(x) more_less(x, "higher", "lower")

# 95% confidence interval text.
ci95 <- function(e, digits = 1) {
  fmt <- function(x) formatC(x, format = "f", digits = digits)
  paste0("[", fmt(e$est - 1.96 * e$se), ", ", fmt(e$est + 1.96 * e$se), "]")
}

# ---- Tables ------------------------------------------------------------------
# Means (SE) table: rows = outcomes, columns = groups.
means_table <- function(d, ys, by, labels = ys, digits = 1) {
  out <- lapply(seq_along(ys), function(i) {
    r <- est_mean(d, ys[i], by)
    data.frame(Outcome = labels[i], group = r$group,
               cell = paste0(formatC(r$est, format = "f", digits = digits),
                             " (", formatC(r$se, format = "f", digits = digits), ")"))
  })
  tidyr::pivot_wider(dplyr::bind_rows(out), names_from = group, values_from = cell)
}

tab <- function(df, caption, label = NULL, align = NULL, notes = NULL, ...) {
  k <- knitr::kable(df, format = "latex", booktabs = TRUE, caption = caption,
                    label = label, align = align, linesep = "", ...)
  k <- kableExtra::kable_styling(k, latex_options = c("hold_position", "scale_down"),
                                 font_size = 9)
  if (!is.null(notes)) k <- kableExtra::footnote(k, general = notes, threeparttable = TRUE,
                                                 general_title = "Notes:", footnote_as_chunk = TRUE)
  k
}

# fixest regression table in LaTeX (AER style).
reg_table <- function(models, title, label, dict = NULL, keep = NULL, notes = NULL, ...) {
  etable(models, tex = TRUE, title = title, label = label, dict = dict, keep = keep,
         style.tex = style.tex("aer"), fitstat = ~ n + r2, digits = 3,
         notes = notes, se.below = TRUE, depvar = TRUE, float = TRUE,
         placement = "!htbp", adjustbox = "max width = \\textwidth", ...)
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
    Value = c(fn(V$n_rows), fn(V$n_persons), fn(V$n_households), fn(V$n_fsu),
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
