import re,sys
p=sys.argv[1]; L=open(p).read().split('\n'); c=False; y=0
for i,l in enumerate(L,1):
    if l.strip()=='---' and y<2: y+=1; continue
    if y<2: continue
    if l.startswith('```'): c=not c; continue
    if c or l.startswith('#') or l.startswith('|') : continue
    t=re.sub(r'`r [^`]*`','',l); t=re.sub(r'\[@[^\]]*\]|@\w+','',t); t=re.sub(r'\\(ref|label)\{[^}]*\}','',t)
    t=re.sub(r'\b(19|20)\d\d\b','',t)
    for m in re.finditer(r'(?<![\w.])\d[\d,]*\.?\d*\s?(%|per cent|percent|minutes?|percentage points|pp)?',t):
        v=m.group(0).strip()
        if re.fullmatch(r'1,440|[0-9]|1[0-9]|[2-9]0|24|60|65|64|100',v.split()[0].rstrip('%')) and not m.group(1): continue
        print(f"{i}: {v} :: {t[max(0,m.start()-50):m.end()+30].strip()}")
