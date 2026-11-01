#!/usr/bin/env python3
"""Assemble P12 LaTeX files from src/ and repo/output/tables, then compile PDFs."""
import re, shutil, subprocess, pathlib
P = pathlib.Path(__file__).resolve().parent; T = P.parent / "repo/output/tables"; F = P.parent / "repo/output/figures"
TITLE = "When Husbands Stop Working, Do Wives Start? Evidence from India's Urban Labour Force Panel"
PRE = r"""\documentclass[12pt]{article}
\usepackage[T1]{fontenc}\usepackage{amsmath}\usepackage{mathptmx}\usepackage{caption}
\usepackage[margin=1in]{geometry}\usepackage{setspace}\usepackage{booktabs}\usepackage{graphicx}
\usepackage[hidelinks]{hyperref}\usepackage{url}\usepackage[authoryear,round]{natbib}
\hypersetup{pdfauthor={},pdftitle={%s}}
\doublespacing
\begin{document}
""" % TITLE
body = (P / "src/body.tex").read_text()
for i in range(1, 5):
    body = body.replace(f"%%TABLE{i}%%", (T / f"table{i}.tex").read_text())
body = body.replace("%%REFERENCES%%", (P / "src/refs.tex").read_text())
head_blind = "\\begin{center}{\\Large\\bfseries %s}\\end{center}\n" % TITLE
title_page = ("\\begin{center}{\\Large\\bfseries %s}\\\\[1.5em]\n Preet Deep Singh\\\\ Independent Researcher, New Delhi, India\\\\"
              " Corresponding author: Preet Deep Singh\\\\ Email: preetdeepsingh111@gmail.com\\\\ ORCID: 0000-0003-3721-7548\\end{center}\n\\vspace{1em}\\noindent Short Paper. Main text under 7,000 words; five exhibits.\\\\\n"
              "\\noindent JEL codes: J22, J12, J64, O15.\n") % TITLE
(P / "manuscript_blind.tex").write_text(PRE + head_blind + body + "\\end{document}\n")
(P / "manuscript_author.tex").write_text(PRE + title_page + "\\newpage\n" + head_blind + body + "\\end{document}\n")
(P / "title_page.tex").write_text(PRE + title_page + "\\end{document}\n")
sup = (P / "src/supplement.tex").read_text()
for n in ("S1", "S2", "S3", "S4"):
    sup = sup.replace(f"%%TABLE{n}%%", (T / f"table{n}.tex").read_text())
(P / "supplement.tex").write_text(PRE.replace("\\doublespacing", "\\onehalfspacing") + sup + "\\end{document}\n")
shutil.copy(F / "figure1.pdf", P / "figure1.pdf"); shutil.copy(F / "figure1.png", P / "figure1.png")
for f in ("manuscript_blind", "manuscript_author", "title_page", "supplement", "cover_letter"):
    if not (P / f"{f}.tex").exists(): continue
    for _ in range(2):
        r = subprocess.run(["pdflatex", "-interaction=nonstopmode", f"{f}.tex"], cwd=P, capture_output=True, text=True)
    print(f, "OK" if (P / f"{f}.pdf").exists() and r.returncode == 0 else "ERROR\n" + r.stdout[-1500:])
