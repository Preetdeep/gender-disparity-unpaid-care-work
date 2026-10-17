#!/usr/bin/env python3
"""Post-process the JMF Word file: 1-inch margins, centred page numbers (from page 1), Times New Roman 12pt, double spacing."""
import sys
from docx import Document
from docx.shared import Inches, Pt
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.enum.text import WD_ALIGN_PARAGRAPH
d = Document(sys.argv[1])
for sec in d.sections:
    sec.left_margin = sec.right_margin = sec.top_margin = sec.bottom_margin = Inches(1)
    sec.footer_distance = Inches(0.5)
    sec.different_first_page_header_footer = False
    f = sec.footer; f.is_linked_to_previous = False
    p = f.paragraphs[0] if f.paragraphs else f.add_paragraph()
    for r in list(p.runs): r._r.getparent().remove(r._r)
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.line_spacing = 1.0
    run = p.add_run()
    for t, txt in (('begin', None), (None, 'PAGE'), ('end', None)):
        if t:
            e = OxmlElement('w:fldChar'); e.set(qn('w:fldCharType'), t)
        else:
            e = OxmlElement('w:instrText'); e.set(qn('xml:space'), 'preserve'); e.text = txt
        run._r.append(e)
    run.font.name = 'Times New Roman'; run.font.size = Pt(12)
d.save(sys.argv[1])

# Tables: single-spaced (JMF presents full tables single-spaced on one page), autofit to the text width
d = Document(sys.argv[1])
for t in d.tables:
    tblPr = t._tbl.tblPr
    for tag in ('w:tblW', 'w:tblLayout'):
        for e in tblPr.findall(qn(tag)): tblPr.remove(e)
    w = OxmlElement('w:tblW'); w.set(qn('w:type'), 'pct'); w.set(qn('w:w'), '5000'); tblPr.append(w)
    lay = OxmlElement('w:tblLayout'); lay.set(qn('w:type'), 'autofit'); tblPr.append(lay)
    grid = t._tbl.find(qn('w:tblGrid'))
    if grid is not None:
        for gc in grid.findall(qn('w:gridCol')): gc.attrib.pop(qn('w:w'), None)
    for row in t.rows:
        for c in row.cells:
            tcPr = c._tc.get_or_add_tcPr()
            for e in tcPr.findall(qn('w:tcW')): tcPr.remove(e)
            for p in c.paragraphs:
                p.paragraph_format.line_spacing = 1.0
                p.paragraph_format.space_after = Pt(0); p.paragraph_format.space_before = Pt(0)
d.save(sys.argv[1])

# Let the abstract flow on the title page instead of being kept together on its own page
d = Document(sys.argv[1])
for name in ('Abstract', 'Abstract Title', 'Author', 'Date', 'Title'):
    try:
        st = d.styles[name]; st.paragraph_format.keep_with_next = False; st.paragraph_format.keep_together = False
    except KeyError:
        pass
d.save(sys.argv[1])
