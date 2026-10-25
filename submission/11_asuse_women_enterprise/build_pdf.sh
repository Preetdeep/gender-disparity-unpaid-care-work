#!/usr/bin/env bash
# Markdown -> PDF for both versions. Run after Rscript knit.R. Needs pandoc >= 3 and xelatex.
# DRAFT=1 adds a "DRAFT - results pending" watermark (use until the unit data have been run).
set -euo pipefail
mkdir -p package
WM=""; [ "${DRAFT:-0}" = "1" ] && WM='\SetWatermarkText{DRAFT - results pending}'
printf '%s\n' "$WM" > build/wm.inc
for v in anonymised author; do
  ( cd build/$v && pandoc manuscript.md --citeproc --bibliography=../../refs_local.bib --csl=../../apa.csl \
      -H ../../preamble.inc -H ../wm.inc -N --pdf-engine=xelatex -V fontsize=12pt -V geometry:margin=1in -V linestretch=1.5 \
      -V colorlinks=true -o ../../package/manuscript_$v.pdf )
done
pandoc package/title_page.md -V geometry:margin=1in --pdf-engine=xelatex -o package/title_page.pdf
pandoc package/cover_letter.md -V geometry:margin=1in --pdf-engine=xelatex -o package/cover_letter.pdf
