# Simplify LaTeX tables/figures so pandoc can produce a Word file with editable tables.
import re,sys,subprocess,os,glob
src,dst=sys.argv[1],sys.argv[2]; s=open(src).read()
s=re.sub(r'\\resizebox\{\\ifdim\\width>\\linewidth\\linewidth\\else\\width\\fi\}\{!\}\{\n','',s)
s=s.replace('\\end{threeparttable}}','\\end{threeparttable}')
s=re.sub(r'\\fontsize\{\d+\}\{\d+\}\\selectfont\n','',s)
def notes(m):
    body=re.sub(r'\\item\s*','',m.group(1)).strip()
    return '\\end{tabular}\n\\end{table}\n\n\\noindent '+body+'\n\n\\begin{table}\\end{table}'
s=re.sub(r'\\end\{tabular\}\s*\\begin\{tablenotes\}(?:\[[^\]]*\])?(.*?)\\end\{tablenotes\}\s*\\end\{threeparttable\}\s*\\end\{table\}',notes,s,flags=re.S)
s=re.sub(r'\\(begin|end)\{threeparttable\}','',s)
s=s.replace('\\begin{table}\\end{table}','')
for f in set(re.findall(r'\\includegraphics(?:\[[^\]]*\])?\{([^}]+)\}',s)):
    pdf=f if f.endswith('.pdf') else f+'.pdf'
    if os.path.exists(pdf):
        subprocess.run(['pdftoppm','-png','-r','200','-singlefile',pdf,pdf[:-4]])
        s=s.replace('{'+f+'}','{'+pdf[:-4]+'.png}')
# Literal supplement numbers for cross-references to the online supplement (xr labels S-...)
aux=os.path.join(os.path.dirname(os.path.abspath(src)),'supplement.aux')
if os.path.exists(aux):
    lab=dict(re.findall(r'\\newlabel\{([^}]+)\}\{\{([^}]*)\}',open(aux).read()))
    s=re.sub(r'\\ref\{S-([^}]+)\}',lambda m:lab.get(m.group(1),m.group(0)),s)
open(dst,'w').write(s)
