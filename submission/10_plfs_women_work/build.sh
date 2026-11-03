#!/usr/bin/env bash
# Build the PRPR package from the knitted Markdown. Run from this folder after `Rscript knit.R`.
# Outputs: package/manuscript_{anonymised,author}.{docx,pdf}, package/manuscript_anonymised.tex (for textnum_check).
set -euo pipefail
mkdir -p package
python3 make_refdoc.py build/reference.docx
for v in anonymised author; do
  ( cd build/$v
    sed 's#build/'"$v"'/##g' manuscript.md > m.md
    common=(m.md --citeproc --bibliography=../../refs_local.bib --csl=../../apa.csl --metadata link-citations=false)
    pandoc "${common[@]}" --reference-doc=../reference.docx -o ../../package/manuscript_$v.docx
    pandoc "${common[@]}" -H ../../preamble.inc --pdf-engine=xelatex -V mainfont=texgyretermes-regular.otf -V mainfontoptions="BoldFont=texgyretermes-bold.otf,ItalicFont=texgyretermes-italic.otf,BoldItalicFont=texgyretermes-bolditalic.otf" -V fontsize=12pt -V geometry:margin=1in \
      -V linestretch=1.5 -V pagestyle=plain -o ../../package/manuscript_$v.pdf
    pandoc "${common[@]}" -s -H ../../preamble.inc -o ../../package/manuscript_$v.tex )
done
# Strip document metadata from the blind files.
python3 - <<'PY'
from docx import Document
from docx.shared import Pt, Inches
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
for v in ("anonymised", "author"):
    p = f"package/manuscript_{v}.docx"; d = Document(p); c = d.core_properties
    # Table layout: fixed widths (wide first column), 9-pt single-spaced cells.
    for t in d.tables:
        n = len(t.columns); first = (2.0 if n >= 10 else 2.4) if n > 4 else 3.2; rest = (6.5 - first) / max(n - 1, 1)
        t.autofit = False
        tblPr = t._tbl.tblPr
        for el in tblPr.findall(qn("w:tblW")): tblPr.remove(el)
        tw = OxmlElement("w:tblW"); tw.set(qn("w:w"), str(int(6.5 * 1440))); tw.set(qn("w:type"), "dxa"); tblPr.append(tw)
        lay = OxmlElement("w:tblLayout"); lay.set(qn("w:type"), "fixed"); tblPr.append(lay)
        grid = t._tbl.tblGrid
        for i, gc in enumerate(grid.findall(qn("w:gridCol"))): gc.set(qn("w:w"), str(int((first if i == 0 else rest) * 1440)))
        for row in t.rows:
            for i, cell in enumerate(row.cells):
                cell.width = Inches(first if i == 0 else rest)
                for para in cell.paragraphs:
                    para.paragraph_format.line_spacing = 1.0; para.paragraph_format.space_after = Pt(0); para.paragraph_format.space_before = Pt(0)
                    for r in para.runs: r.font.size = Pt(9)
    c.author = "" if v == "anonymised" else "Preet Deep Singh"; c.last_modified_by = ""; c.comments = ""; c.keywords = ""; c.subject = ""
    c.title = "Counting more women's work"; d.save(p)
PY
# Check PDFs are rendered from the .docx itself (what the journal receives).
for v in anonymised author; do soffice --headless --convert-to pdf --outdir package "package/manuscript_${v}.docx" >/dev/null 2>&1; done
