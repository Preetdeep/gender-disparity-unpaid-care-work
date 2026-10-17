#!/bin/bash
# Build submission package for paper NN: anonymised main manuscript (no appendix),
# online supplement (appendix, tables S1..), author version, and word counts.
# Usage: tools/build_package.sh 07 [docx]
set -e
NN=$1; ROOT=$(pwd); P=$(ls -d submission/${NN}_*); PK=$ROOT/$P/package; B=/tmp/build_$NN
rm -rf $B && mkdir -p $B $PK
cd $P
PAR=blind; grep -q 'params\$anonymised' manuscript.Rmd && PAR=anonymised
Rscript -e "TUS_ROOT<-normalizePath('../..'); rmarkdown::render('manuscript.Rmd', output_dir='$B', intermediates_dir='$B', params=list($PAR=TRUE), quiet=TRUE)" >/dev/null 2>&1
cd $B
python3 - <<'PY'
import re
s=open('manuscript.tex').read()
pre,body=s.split('\\begin{document}',1)
i=body.index('\\appendix'); main=body[:i]; app=body[i:].replace('\\end{document}','')
labels=set(re.findall(r'\\label\{([^}]+)\}',app))
def fix(t):
    t=re.sub(r'Appendix (Tables?|Figures?) \\ref\{','\\1 \\\\ref{',t)
    for l in labels: t=t.replace('\\ref{%s}'%l,'\\ref{S-%s}'%l)
    return t
main=fix(main)
open('main.tex','w').write(pre.replace('\\documentclass','\\RequirePackage{xr}\n\\documentclass',1)+'\\externaldocument[S-]{supplement}\n\\begin{document}'+main+'\n\\end{document}\n')
sup_pre=pre+('\\RenewDocumentCommand\\citeproc{mm}{#2}\n' if 'NewDocumentCommand\\citeproc' in pre else '')+'\\renewcommand{\\thetable}{S\\arabic{table}}\\renewcommand{\\thefigure}{S\\arabic{figure}}\n'
title=re.search(r'\\title\{(.*?)\}\n',pre,re.S)
app=app.replace('\\appendix','',1)
app=re.sub(r'\\section\*\{Appendix\}\\label\{appendix\}','',app)
open('supplement.tex','w').write(sup_pre+'\\begin{document}\n\\begin{center}\\Large Online Supplement\\\\[4pt]\\normalsize '+(title.group(1) if title else '')+'\\end{center}\n'+app+'\n\\end{document}\n')
PY
for f in supplement main supplement main; do xelatex -interaction=nonstopmode $f.tex >/dev/null 2>&1 || pdflatex -interaction=nonstopmode $f.tex >/dev/null 2>&1 || true; done
cp main.pdf $PK/manuscript_anonymised.pdf; cp supplement.pdf $PK/online_supplement.pdf
if [ "$NN" = "03" ]; then  # Feminist Economics: exhibits as separate files, position markers in text
  python3 $ROOT/tools/separate_floats.py main.tex exhibits >/dev/null
  for f in supplement main supplement main; do xelatex -interaction=nonstopmode $f.tex >/dev/null 2>&1 || true; done
  (cd exhibits && for t in *.tex; do xelatex -interaction=nonstopmode $t >/dev/null 2>&1 || true; done)
  rm -rf $PK/exhibits && mkdir -p $PK/exhibits && cp exhibits/Table*.pdf $PK/exhibits/ && cp main.pdf $PK/manuscript_anonymised.pdf
  # one clearly named Figure 1 upload file: the figure itself (vector PDF, no caption); caption is in the caption list
  cp manuscript_files/figure-latex/fig-lifecourse-1.pdf $PK/exhibits/Figure1.pdf
fi
if [ "$NN" = "05" ]; then  # JMF Word file: Times New Roman 12pt, double-spaced
  PD=$(command -v pandoc || ls /Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/*/pandoc | head -1)
  python3 $ROOT/tools/tex2docx.py main.tex m2.tex && $PD m2.tex --reference-doc $ROOT/tools/jmf_reference.docx -o $PK/manuscript_anonymised.docx
fi
MW=$(pdftotext main.pdf - 2>/dev/null | wc -w || echo NA)
echo "$NN main_pdf_words_incl_refs_tables=$MW refs_unresolved=$(grep -c 'undefined' main.log)"
