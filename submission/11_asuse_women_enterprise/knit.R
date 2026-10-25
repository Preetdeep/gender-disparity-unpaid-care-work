# Knit manuscript.Rmd to Markdown for the anonymised and the author versions, and the cover letter.
# Numbers come only from p11_results.rds and plfs_benchmark.rds (env P11_OUT, default
# ~/GResearcher_runs/data_derived/p11). The cover letter reuses the manuscript's helpers.
suppressMessages(library(knitr))
for (v in c("anonymised", "author")) {
  od <- file.path("build", v); dir.create(od, recursive = TRUE, showWarnings = FALSE)
  e <- new.env(); assign("params", list(blind = (v == "anonymised")), envir = e)
  render_markdown(); opts_knit$set(rmarkdown.pandoc.to = "latex", out.format = "markdown")
  knit("manuscript.Rmd", output = file.path(od, "manuscript.md"), envir = e, quiet = TRUE)
}
knit("package/cover_letter.Rmd", output = "package/cover_letter.md", envir = e, quiet = TRUE)
