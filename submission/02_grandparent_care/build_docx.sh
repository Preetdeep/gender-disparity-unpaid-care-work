#!/bin/bash
# Word (.docx) and Springer-named supplement for paper 02 (Journal of Population Economics).
# Run from the repository root AFTER `tools/build_package.sh 02` (which leaves main.tex in /tmp/build_02).
set -e
ROOT=$(pwd); P=$ROOT/submission/02_grandparent_care; PK=$P/package; B=/tmp/build_02
PD=$(command -v pandoc || ls /Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/*/pandoc | head -1)
cd $B
python3 $ROOT/tools/tex2docx.py main.tex m2.tex
$PD m2.tex --reference-doc $ROOT/tools/jmf_reference.docx -o $PK/manuscript_anonymised.docx
python3 $P/docx_postprocess.py $PK/manuscript_anonymised.docx
cp $PK/online_supplement.pdf $PK/ESM_1.pdf && rm -f $PK/online_supplement.pdf
echo "docx and ESM_1.pdf written to $PK"
