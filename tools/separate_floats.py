#!/usr/bin/env python3
"""Move tables and figures out of main.tex into separate exhibit files (Feminist Economics style).
Usage (inside the build dir): separate_floats.py main.tex OUTDIR
Writes OUTDIR/Table<N>.tex / Figure<N>.tex (one exhibit each), replaces each float in main.tex with a
'[Table N about here]' marker that keeps its \\label, and appends a separate list of captions."""
import re, sys, os
src, out = sys.argv[1], sys.argv[2]; os.makedirs(out, exist_ok=True)
s = open(src).read()
pre, body = s.split('\\begin{document}', 1)
ex_pre = pre.replace('\\RequirePackage{xr}\n', '').replace('\\externaldocument[S-]{supplement}', '')
def braced(t, i):
    d = 0
    for j in range(i, len(t)):
        if t[j] == '{': d += 1
        elif t[j] == '}':
            d -= 1
            if d == 0: return t[i+1:j]
    return ''
n = {'table': 0, 'figure': 0}; caps = []
def repl(m):
    env, blk = m.group(1), m.group(0)
    n[env] += 1; k = n[env]; Name = env.capitalize()
    lab = re.search(r'\\label\{([^}]*)\}', blk); lab = lab.group(1) if lab else ''
    c = blk.find('\\caption{'); cap = braced(blk, c + 8) if c >= 0 else ''
    cap = re.sub(r'\\label\{[^}]*\}', '', cap).strip()
    caps.append(f'{Name} {k}: {cap}')
    fl = re.sub(r'\\begin\{' + env + r'\}(\[[^\]]*\])?', r'\\begin{' + env + '}[H]', blk, 1)
    open(f'{out}/{Name}{k}.tex', 'w').write(ex_pre + '\\begin{document}\\pagestyle{empty}\n\\setcounter{' + env + '}{' + str(k-1) + '}\n' + fl + '\n\\end{document}\n')
    size = 'full page' if env == 'table' else 'half page'
    return ('\\begin{center}\\refstepcounter{' + env + '}' + (f'\\label{{{lab}}}' if lab else '') +
            f'\\textbf{{[{Name} \\the{env}{{}} about here; preferred size: {size}]}}\\end{{center}}')
body = re.sub(r'\\begin\{(table|figure)\}.*?\\end\{\1\}', repl, body, flags=re.S)
caplist = '\n\\clearpage\n\\section*{Table and figure captions}\n' + '\n\n'.join('\\noindent ' + c for c in caps) + '\n'
body = body.replace('\\end{document}', caplist + '\\end{document}')
open(src, 'w').write(pre + '\\begin{document}' + body)
print('exhibits:', n)
