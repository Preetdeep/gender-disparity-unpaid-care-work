# Build reference.docx for pandoc: Times New Roman 12 pt, 1.5 spacing, automatic page numbers in the footer.
import subprocess, sys
from docx import Document
from docx.shared import Pt
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
out = sys.argv[1]
open(out, "wb").write(subprocess.run(["pandoc", "--print-default-data-file", "reference.docx"], capture_output=True).stdout)
d = Document(out)
for s in d.styles:
    try:
        if s.font is not None:
            s.font.name = "Times New Roman"; s.font.color.rgb = None
            rpr = s.element.get_or_add_rPr(); rf = rpr.find(qn("w:rFonts"))
            if rf is None: rf = OxmlElement("w:rFonts"); rpr.append(rf)
            for a in ("w:ascii", "w:hAnsi", "w:eastAsia", "w:cs"): rf.set(qn(a), "Times New Roman")
            for t in ("w:asciiTheme", "w:hAnsiTheme", "w:eastAsiaTheme", "w:cstheme"):
                if rf.get(qn(t)) is not None: del rf.attrib[qn(t)]
    except Exception: pass
for n in ("Normal", "Body Text", "First Paragraph", "Compact"):
    try:
        st = d.styles[n]; st.font.size = Pt(12)
        if n != "Compact": st.paragraph_format.line_spacing = 1.5
    except KeyError: pass
for n, sz in (("Heading 1", 14), ("Heading 2", 12), ("Heading 3", 12), ("Title", 16)):
    try: st = d.styles[n]; st.font.size = Pt(sz); st.font.bold = True
    except KeyError: pass
for n in ("Table", "Compact"):
    try: d.styles[n].font.size = Pt(10)
    except KeyError: pass
sec = d.sections[0]
p = sec.footer.paragraphs[0] if sec.footer.paragraphs else sec.footer.add_paragraph()
p.alignment = 1
r = p.add_run()
for kind, txt in (("begin", None), (None, " PAGE "), ("end", None)):
    if kind:
        e = OxmlElement("w:fldChar"); e.set(qn("w:fldCharType"), kind); r._r.append(e)
    else:
        e = OxmlElement("w:instrText"); e.set(qn("xml:space"), "preserve"); e.text = txt; r._r.append(e)
d.core_properties.author = ""; d.core_properties.last_modified_by = ""; d.core_properties.title = ""
d.save(out)
