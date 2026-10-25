#!/usr/bin/env bash
# Convert the knitted Markdown to PDF. Run from this folder after Rscript knit.R. Needs pandoc >= 3 and xelatex.
set -euo pipefail
mkdir -p package
for v in anonymised author; do
  ( cd build/$v && sed 's#build/'"$v"'/##g' manuscript.md > m.md && \
    pandoc m.md --citeproc --bibliography=../../refs_local.bib --csl=../../apa.csl \
      -H ../../preamble.inc -N --pdf-engine=xelatex -V fontsize=12pt -V geometry:margin=1in -V linestretch=1.5 \
      -V colorlinks=true -o ../../package/manuscript_$v.pdf )
done
