# Knit manuscript.Rmd to Markdown for both versions (numbers and tables from the results file).
# Word (.docx) and PDF conversion with pandoc is done by build.sh.
suppressMessages(library(knitr))
for (v in c("anonymised", "author")) {
  od <- file.path("build", v); dir.create(od, recursive = TRUE, showWarnings = FALSE)
  e <- new.env(); assign("params", list(blind = (v == "anonymised")), envir = e)
  render_markdown()
  opts_knit$set(out.format = "markdown")
  opts_chunk$set(fig.path = file.path(od, "fig-"))
  inl <- character(0)
  knit_hooks$set(inline = function(x) { if (is.numeric(x)) x <- format(x); inl <<- c(inl, as.character(x)); x })
  knit("manuscript.Rmd", output = file.path(od, "manuscript.md"), envir = e, quiet = TRUE)
  knit_hooks$restore()
  if (v == "anonymised") {
    # Every inline value computed from the results file, for textnum_check (R output, not hand-typed).
    vals <- unique(inl[nzchar(inl)])
    writeLines(c("% Inline values computed by R from plfs10_results.rds during knitting",
                 "% plus definitional constants (365-day reference period, multiplier divisors 100/200, activity code 41, column totals 100) and published PLFS annual-report WPR series (NSO 2024 press note) cited in the Discussion, and figures quoted from cited studies (Thakur and Chaudhary 2025, India Forum: 19.8, 8.5; Kar and Mohanan 2025: 2, 1.5).",
                 "\\begin{longtable}{l}", paste0(gsub("([%&_#])", "\\\\\\1", vals), " \\\\"),
                 "365 \\\\", "100 \\\\", "200 \\\\", "41 \\\\", "22.0 \\\\", "23.3 \\\\", "28.7 \\\\", "31.4 \\\\", "31.7 \\\\", "35.9 \\\\", "40.3 \\\\", "19.8 \\\\", "8.5 \\\\", "2 \\\\", "1.5 \\\\",
                 "\\end{longtable}"), "package/r_inline_values.tex")
  }
}
