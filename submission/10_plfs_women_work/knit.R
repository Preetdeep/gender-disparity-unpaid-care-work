# Knit manuscript.Rmd to Markdown for both versions (numbers and tables from the results file).
# PDF conversion with pandoc + xelatex is done by build_pdf.sh (pandoc is not installed on this Mac).
suppressMessages(library(knitr))
for (v in c("anonymised", "author")) {
  od <- file.path("build", v); dir.create(od, recursive = TRUE, showWarnings = FALSE)
  e <- new.env(); assign("params", list(blind = (v == "anonymised")), envir = e)
  render_markdown()
  opts_knit$set(rmarkdown.pandoc.to = "latex", out.format = "markdown")
  opts_chunk$set(fig.path = file.path(od, "fig-"))
  knit("manuscript.Rmd", output = file.path(od, "manuscript.md"), envir = e, quiet = TRUE)
}
