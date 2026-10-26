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
      --columns=150 -V colorlinks=true -V pdfauthor="" -V pdfcreator="" -o ../../package/manuscript_$v.pdf )
done
# word count of the anonymised version (all text incl. references, tables, appendix; and main text up to References)
( cd build/anonymised && pandoc manuscript.md --citeproc --bibliography=../../refs_local.bib --csl=../../apa.csl -t plain --wrap=none -o ../wc.txt )
WC=$(wc -w < build/wc.txt | tr -d ' ')
WCM=$(awk '/^References$/{exit} {print}' build/wc.txt | wc -w | tr -d ' ')
sed -e "s/{{WORDCOUNT}}/$(echo $WC | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')/" -e "s/{{WC_MAIN}}/$(echo $WCM | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')/" package/title_page_tmpl.md > package/title_page.md
echo "word count: total $WC, main text $WCM"
pandoc package/title_page.md -V geometry:margin=1in --pdf-engine=xelatex -o package/title_page.pdf
pandoc package/cover_letter.md -V geometry:margin=1in --pdf-engine=xelatex -o package/cover_letter.pdf
