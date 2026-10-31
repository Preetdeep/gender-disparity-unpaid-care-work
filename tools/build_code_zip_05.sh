#!/bin/bash
# Builds the Demographic Research replication archive for paper 05: code, readme.txt, data meta-information.
# No microdata and no .dta files. Output: submission/05_*/package/code_replication.zip
set -e
ROOT=$(pwd); P=$(ls -d submission/05_*); Z=/tmp/zip05; rm -rf $Z && mkdir -p $Z/R $Z/submission/_common $Z/submission/$(basename $P) $Z/sample_data
cp R/setup.R R/codes.R R/build_panel.R R/helpers.R R/make_synthetic_data.R R/compare_2019.R R/icatus_labels.R $Z/R/
cp submission/_common/preamble.tex submission/_common/tus_2019_2024_compare.csv $Z/submission/_common/
cp $P/replication/readme.txt $P/replication/meta_information.txt $P/replication/run_05.R $Z/
Rscript -e "knitr::purl('$P/manuscript.Rmd', output='$Z/submission/$(basename $P)/analysis_05.R', documentation=1, quiet=TRUE)" >/dev/null
# small FAKE sample (synthetic) as CSV
Rscript -e "source('R/make_synthetic_data.R'); d<-make_synthetic(40); data.table::fwrite(d, '$Z/sample_data/sample_synthetic_activity_records.csv')" >/dev/null 2>&1
find $Z -name '*.dta' -o -name '*.rds' -o -name '*.Nesstar' | grep . && { echo "FORBIDDEN FILE"; exit 1; } || true
grep -rIl "Preet\|preetds\|iima\|ORCID" $Z && { echo "IDENTIFIER FOUND"; exit 1; } || true
rm -f $P/package/code_replication.zip; (cd $Z && zip -qr $ROOT/$P/package/code_replication.zip .)
unzip -l $P/package/code_replication.zip | tail -20
