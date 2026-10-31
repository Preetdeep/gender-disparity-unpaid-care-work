#!/usr/bin/env python3
"""Cross-check running-text numbers against LaTeX tables.

Usage: python3 textnum_check.py MAIN.tex [SUPPLEMENT.tex ...]
       [--abstract-only] [--json OUT.json] [--strict]
Table numbers are collected from every input; text numbers come from the first.
"""
import argparse
import json
import re
import sys
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP
from pathlib import Path

NUM = re.compile(r'(?<![\w.])(?:\$?\s*[−–-]\s*)?\$?\s*(?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d+)?(?:\s*\\?%)?')
ENV = re.compile(r'\\(begin|end)\s*\{([^}]+)\}')
SKIP_ENVS = {'figure', 'equation', 'align', 'gather', 'multline', 'displaymath', 'math'}

def mask(s, pattern):
    return pattern.sub(lambda m: re.sub(r'[^\n]', ' ', m.group()), s)

def env_spans(s, names):
    stack, spans = [], []
    for m in ENV.finditer(s):
        action, name = m.groups()
        if action == 'begin':
            if name in names: stack.append((name, m.start()))
        else:
            for i in range(len(stack)-1, -1, -1):
                if stack[i][0] == name:
                    _, start = stack.pop(i)
                    spans.append((start, m.end()))
                    break
    return spans

def numeric_value(raw):
    t = raw.strip().replace('−', '-').replace('–', '-')
    t = t.replace('$', '').replace('\\%', '%').replace('%', '').replace(',', '')
    t = re.sub(r'\s+', '', t)
    return Decimal(t), '%' in raw, len(t.partition('.')[2]) if '.' in t else 0

def token_parts(raw):
    t = raw.strip().replace('−', '-').replace('–', '-')
    t = t.replace('$', '').replace('\\%', '%').replace('%', '').replace(',', '')
    t = re.sub(r'\s+', '', t)
    return t, '%' in raw, len(t.partition('.')[2]) if '.' in t else 0

def get_table_text(s):
    spans = env_spans(s, {'table', 'table*'})
    spans += env_spans(s, {'tabular', 'tabular*', 'longtable', 'longtable*'})
    chars = [' '] * len(s)
    for a, b in spans: chars[a:b] = s[a:b]
    return ''.join(chars), spans

def strip_commands(s):
    # Remove citation/reference commands and their braced arguments.
    s = mask(s, re.compile(r'\\(?:cite|citep|citet|ref|label|eqref)\*?(?:\[[^\]]*\])*(?:\{[^{}]*\})+'))
    s = mask(s, re.compile(r'\\(?:begin|end)\s*\{(?:figure\*?|equation\*?|align\*?|gather\*?|multline\*?|displaymath|math)\}'))
    return s

def ignored(raw, s, a, b):
    t, pct, decs = token_parts(raw)
    try: d = Decimal(t)
    except InvalidOperation: return True
    before, after = s[max(0,a-35):a], s[b:b+35]
    if d == d.to_integral_value() and not decs:
        n = int(d)
        if 0 <= n <= 10: return True
        if n < 100 and (re.search(r'(?:aged|age)\s*$', before, re.I) or re.match(r'\s*to\s+\d+', after)): return True
        if re.search(r'ICATUS\s*$', s[max(0,a-30):a], re.I): return True
        if re.search(r'\b\d{3}\s+to\s*$', before) or re.match(r'\s*to\s+\d{3}\b', after): return True
        if re.search(r'\(\s*$', before) and re.match(r'\s*\)', after) and 100 <= n <= 999: return True
    if re.match(r'\s*(?:years\b|-year\b|a\.m\.|p\.m\.)', after, re.I): return True
    if re.search(r'\b(?:Table|Fig\.|Section|equation|Online\s+Resource)\s*\(?\s*$', before, re.I): return True
    if not pct and d == d.to_integral_value() and 1900 <= d <= 2099: return True
    return False

def matches(raw, tables):
    tv, tpct, td = token_parts(raw)
    try: textv = Decimal(tv)
    except InvalidOperation: return False
    for val, pct, dec in tables:
        if tv == val or tv.lstrip('+') == val.lstrip('+'): return True
        try: tablev = Decimal(val)
        except InvalidOperation: continue
        if abs(tablev).quantize(Decimal(1).scaleb(-td), rounding=ROUND_HALF_UP) == abs(textv): return True
        if td == 1 and abs(tablev * 100).quantize(Decimal(1).scaleb(-td), rounding=ROUND_HALF_UP) == abs(textv): return True
        if tpct and abs(tablev) == abs(textv): return True
    return False

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('files', nargs='+')
    ap.add_argument('--abstract-only', action='store_true')
    ap.add_argument('--json', dest='json_out')
    ap.add_argument('--strict', action='store_true')
    args = ap.parse_args()
    docs = [(Path(p), Path(p).read_text(encoding='utf-8', errors='replace')) for p in args.files]
    tables, table_spans = [], []
    for p, s in docs:
        ttext, spans = get_table_text(s)
        table_spans.append(spans)
        for m in NUM.finditer(ttext):
            try:
                v, pct, dec = numeric_value(m.group())
                tables.append((str(v), pct, dec))
            except InvalidOperation: pass
    p, source = docs[0]
    cut = len(source)
    for pat in (r'\\section\*?\{\s*References\s*\}', r'\\hypertarget\{refs\}', r'\\begin\{CSLReferences\}'):
        found = re.search(pat, source, re.I)
        if found: cut = min(cut, found.start())
    doc_start = source.find('\\begin{document}')
    # Blank the preamble (keeps offsets) so package options are not read as text numbers.
    body = (re.sub(r'[^\n]', ' ', source[:doc_start]) + source[doc_start:cut]) if doc_start > 0 else source[:cut]
    abstract = re.search(r'\\begin\{abstract\}(.*?)\\end\{abstract\}', body, re.S)
    abstract_span = (abstract.start(1), abstract.end(1)) if abstract else None
    body = strip_commands(body)
    body = mask(body, re.compile(r'\\begin\{(?:table\*?|tabular\*?|longtable\*?|figure\*?|equation\*?|align\*?|gather\*?|multline\*?|displaymath|math)\}.*?\\end\{(?:table\*?|tabular\*?|longtable\*?|figure\*?|equation\*?|align\*?|gather\*?|multline\*?|displaymath|math)\}', re.S))
    # Mask each recognized table/figure/equation span, including nested tabular markup.
    for a,b in env_spans(source[:cut], {'table','table*','figure','figure*','equation','equation*','align','align*','gather','gather*','multline','multline*'}):
        body = body[:a] + re.sub(r'[^\n]',' ',body[a:b]) + body[b:]
    body = re.sub(r'(?m)^\s*\\(?:sub)*section\*?(?:\[[^]]*\])?\{[^\n]*\}', lambda m: re.sub(r'[^\n]',' ',m.group()), body)
    body = re.sub(r'(?m)^\s*\d+(?:\.\d+)*\s+(?=[A-Z])', lambda m: re.sub(r'\d',' ',m.group()), body)
    abstracts=[]
    if abstract_span:
        a,b=abstract_span
        # Raw abstract is separately filtered for excluded commands and environments.
        abst=strip_commands(source[a:b])
        for m in NUM.finditer(abst):
            if not ignored(m.group(), abst,m.start(),m.end()): abstracts.append((m.group(),a+m.start(),'abstract'))
    scan = abstract_only_text(body, abstract_span) if args.abstract_only and abstract_span else ('' if args.abstract_only else body)
    unmatched=[]; total=0; abstract_unmatched=0
    for m in NUM.finditer(scan):
        if ignored(m.group(), scan,m.start(),m.end()): continue
        total+=1
        tag='abstract' if abstract_span and m.start() >= abstract_span[0] and m.start() < abstract_span[1] else 'text'
        if not matches(m.group(),tables):
            if tag=='abstract': abstract_unmatched+=1
            line=source.count('\n',0,m.start())+1
            context=' '.join(source[max(0,m.start()-30):m.end()+30].split())[:60]
            unmatched.append({'file':str(p),'line':line,'number':m.group().strip(),'context':context,'tag':tag})
    warn=0
    # Count phrases for a human list check.
    for m in re.finditer(r'(?<!under )(?<!aged )(?<!the )\b(two|three|four|five|six|seven|eight|nine|ten)\s+(?!years|generations|estimates|arrangements|adults)([A-Za-z-]+s)\b',body,re.I):
        line=source.count('\n',0,m.start())+1
        print(f'WARN count phrase {p}:{line} | {" ".join(source[max(0,m.start()-25):m.end()+35].split())[:60]}')
        warn+=1
    # Caption/label reference diagnostics across first-file tables.
    for a,b in env_spans(source, {'table','table*'}):
        block=source[a:b]; startline=source.count('\n',0,a)+1
        if not re.search(r'\\caption(?:\[[^]]*\])?\s*\{',block):
            print(f'WARN missing caption {p}:{startline}'); warn+=1
        for lab in re.finditer(r'\\label\{(tab:[^}]+)\}',block):
            name=lab.group(1); ref=re.search(r'\\ref\{'+re.escape(name)+r'\}',source[:cut])
            if ref:
                rline=source.count('\n',0,ref.start())+1
                if startline-rline>120 or startline<rline:
                    print(f'WARN table reference distance {name}: reference line {rline}, table line {startline}')
                    warn+=1
            else:
                print(f'WARN label {name} has no body reference'); warn+=1
    for item in unmatched:
        print(f"{item['file']}:{item['line']} | {item['number']} | {item['context']}")
    print(f'TEXTNUM_CHECK text_numbers={total} matched={total-len(unmatched)} unmatched={len(unmatched)} abstract_unmatched={abstract_unmatched}')
    if args.json_out:
        Path(args.json_out).write_text(json.dumps(unmatched,indent=2)+'\n',encoding='utf-8')
    return 1 if unmatched or (args.strict and warn) else 0

def abstract_only_text(body, span):
    # Body has unchanged character offsets (all masking preserves newlines but not spaces); retain abstract's source region.
    a,b=span
    return body[a:b]

if __name__ == '__main__':
    sys.exit(main())
