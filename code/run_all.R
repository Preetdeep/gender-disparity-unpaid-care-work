## Full pipeline. Set PLFS_DIR to the folder holding the MoSPI CSV files (see README).
code <- Sys.getenv("P12_CODE", "/workspace/papers/P12/repo/code")
Sys.setenv(P12_RUN_BUILD = "1")
for (s in c("01_build.R", "02_validate.R", "03_analysis.R", "04_tables_figs.R")) { cat("==", s, format(Sys.time()), "\n"); source(file.path(code, s), echo = FALSE) ; Sys.setenv(P12_RUN_BUILD = "0")}
writeLines(capture.output(sessionInfo()), file.path(Sys.getenv("P12_ROOT", "/workspace/papers/P12"), "repo/output/sessionInfo.txt"))
