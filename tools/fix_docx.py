#!/usr/bin/env python3
"""Post-process the Word file for Demographic Research: 1-inch margins, NO page numbers/headers/footers, anonymous metadata, tables single-spaced."""
import sys
from docx import Document
from docx.shared import Inches, Pt
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.enum.text import WD_ALIGN_PARAGRAPH
d = Document(sys.argv[1])
for sec in d.sections:
    sec.left_margin = sec.right_margin = sec.top_margin = sec.bottom_margin = Inches(1)
    # Demographic Research: no page numbers, headers or footers (the editorial office adds them).
    sec.different_first_page_header_footer = False
    for part in (sec.header, sec.footer, sec.first_page_header, sec.first_page_footer, sec.even_page_header, sec.even_page_footer):
        part.is_linked_to_previous = True       # removes the header/footer definition from the section
    for tag in ('w:headerReference', 'w:footerReference'):
        for e in sec._sectPr.findall(qn(tag)): sec._sectPr.remove(e)
# double-blind: no author metadata in the file properties
cp = d.core_properties
cp.author = ''; cp.last_modified_by = ''; cp.title = 'Manuscript anonymized for review'; cp.comments = ''; cp.keywords = ''
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

# Number the table captions ("Table 1: ...") so they match the in-text citations (Demographic Research: captions in the text file)
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from number_captions_docx import number_captions
number_captions(sys.argv[1])
