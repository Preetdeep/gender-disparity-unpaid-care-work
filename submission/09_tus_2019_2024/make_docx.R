# Build an anonymised Word version of manuscript.Rmd (same source, same content as the blind PDF).
# Usage (from submission/09_tus_2019_2024): Rscript make_docx.R <output_dir>
args <- commandArgs(TRUE); out <- if (length(args)) args[1] else "/tmp/b09docx"
dir.create(out, showWarnings = FALSE, recursive = TRUE)
s <- paste(readLines("manuscript.Rmd", warn = FALSE), collapse = "\n")
tabs <- c("tab-comp", "tab-sample", "tab-main", "tab-margins", "tab-shift", "tab-het", "tab-dfl", "tab-rob", "tab-all", "tab-within")
figs <- c("div", "age")
for (i in seq_along(tabs)) s <- gsub(paste0("\\ref{tab:", tabs[i], "}"), i, s, fixed = TRUE)
for (i in seq_along(figs)) s <- gsub(paste0("\\ref{fig:", figs[i], "}"), i, s, fixed = TRUE)
# YAML: Word output
s <- sub("output:\n  pdf_document:\n    number_sections: true\n    keep_tex: true\n    fig_caption: true\n    includes:\n      in_header: ../_common/preamble.tex\n",
         "output:\n  word_document:\n    number_sections: true\n    fig_caption: true\n", s, fixed = TRUE)
stopifnot(grepl("word_document", s))
# abstract and keywords
s <- sub('cat("\\\\begin{abstract}\\n\\\\noindent ",', 'cat("**Abstract.** ",', s, fixed = TRUE)
s <- sub('\\n\\\\end{abstract}\\n", sep = "")', '\\n", sep = "")', s, fixed = TRUE)
s <- gsub('\\\\%', '%', s, fixed = TRUE)
s <- sub("\\keywords{", "**Keywords:** ", s, fixed = TRUE)
s <- sub("**Keywords:** time use; unpaid care work; female labour force participation; gender gaps; India; time diaries}",
         "**Keywords:** time use; unpaid care work; female labour force participation; gender gaps; India; time diaries", s, fixed = TRUE)
s <- gsub("\n\\newpage\n", "\n", s, fixed = TRUE); s <- gsub("\n\\appendix\n", "\n", s, fixed = TRUE)
# figure captions: explicit numbers, no LaTeX labels
s <- sub('fig.cap="Change in minutes', 'fig.cap="Figure 1. Change in minutes', s, fixed = TRUE)
s <- sub('fig.cap="Women\'s mean minutes', 'fig.cap="Figure 2. Women\'s mean minutes', s, fixed = TRUE)
s <- gsub("\\\\\\\\label\\{fig:[a-z]+\\}", "", s)
s <- gsub("\\\\label\\{fig:[a-z]+\\}", "", s)
# Word table shims, inserted after the setup chunk
shim <- '
```{r docx-shims, include=FALSE}
.tabno <- 0
knitr::opts_chunk$set(dpi = 300)
.clean <- function(x) { x <- gsub("\\\\\\\\quad ", "\\u00a0\\u00a0\\u00a0\\u00a0", x); x <- gsub("\\\\\\\\&", "&", x); x <- gsub("\\\\\\\\%", "%", x); gsub("--", "\\u2013", x, fixed = TRUE) }
kbl <- function(x, format = NULL, caption = NULL, col.names = NULL, ...) {
  x <- as.data.frame(x); if (!is.null(col.names)) names(x) <- col.names
  structure(list(df = x, cap = caption, hdr = NULL, note = NULL, packs = list()), class = "dkbl") }
kable_styling <- function(k, ...) k; column_spec <- function(k, ...) k; row_spec <- function(k, ...) k
add_header_above <- function(k, header, ...) { k$hdr <- header; k }
footnote <- function(k, general = NULL, ...) { k$note <- general; k }
pack_rows <- function(k, group_label = NULL, start_row = NULL, end_row = NULL, index = NULL, ...) {
  if (!is.null(index)) { st <- 1; for (nm in names(index)) { k$packs[[length(k$packs) + 1]] <- list(nm, st); st <- st + index[[nm]] } }
  else k$packs[[length(k$packs) + 1]] <- list(group_label, start_row); k }
knit_print.dkbl <- function(k, ...) {
  .tabno <<- .tabno + 1; df <- k$df; cn <- names(df)
  if (!is.null(k$hdr)) { lab <- rep(names(k$hdr), k$hdr); cn <- ifelse(trimws(lab) == "", cn, paste0(lab, ": ", cn)) }
  df[] <- lapply(df, function(v) .clean(as.character(v)))
  if (length(k$packs)) { ord <- order(sapply(k$packs, `[[`, 2), decreasing = TRUE)
    for (p in k$packs[ord]) { blank <- as.data.frame(as.list(c(paste0("**", p[[1]], "**"), rep("", ncol(df) - 1)))); names(blank) <- names(df)
      st <- p[[2]]; df <- rbind(if (st > 1) df[seq_len(st - 1), , drop = FALSE], blank, df[st:nrow(df), , drop = FALSE]) } }
  names(df) <- .clean(cn)
  tb <- knitr::kable(df, format = "pipe", caption = paste0("Table ", .tabno, ". ", .clean(k$cap)), row.names = FALSE)
  txt <- paste(c(tb, "", if (!is.null(k$note)) paste0("*Note:* ", .clean(k$note)), ""), collapse = "\\n")
  knitr::asis_output(txt) }
registerS3method("knit_print", "dkbl", knit_print.dkbl, envir = asNamespace("knitr"))
```
'
i <- regexpr("```\n\n```\\{r abstract", s)
stopifnot(i > 0)
s <- paste0(substr(s, 1, i + 3), shim, substr(s, i + 4, nchar(s)))
tmp <- "manuscript_docx_tmp.Rmd"; writeLines(s, tmp)
on.exit(unlink(tmp))
rmarkdown::render(tmp, output_file = "manuscript_anonymised.docx", output_dir = out, intermediates_dir = out,
                  params = list(blind = TRUE), quiet = TRUE)
# strip author metadata (core.xml creator/lastModifiedBy, custom.xml properties)
system2("python3", c("anonymise_docx.py", file.path(out, "manuscript_anonymised.docx")))
