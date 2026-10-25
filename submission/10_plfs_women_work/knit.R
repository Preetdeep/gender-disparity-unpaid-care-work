# Knit manuscript.Rmd to Markdown for both versions (numbers and tables from the results file).
# PDF conversion with pandoc + xelatex is done by build_pdf.sh.
suppressMessages(library(knitr))
for (v in c("anonymised", "author")) {
  od <- file.path("build", v); dir.create(od, recursive = TRUE, showWarnings = FALSE)
  e <- new.env(); assign("params", list(blind = (v == "anonymised")), envir = e)
  render_markdown()
  # Plain Markdown images (pandoc turns them into LaTeX figures with one caption); the default hook writes an HTML div whose caption pandoc prints twice.
  knit_hooks$set(plot = function(x, options) sprintf("\n![%s](%s){width=90%%}\n\n", options$fig.cap, x))
  opts_knit$set(rmarkdown.pandoc.to = "latex", out.format = "markdown")
  opts_chunk$set(fig.path = file.path(od, "fig-"))
  knit("manuscript.Rmd", output = file.path(od, "manuscript.md"), envir = e, quiet = TRUE)
}
