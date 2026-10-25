"""Strip identifying metadata from a .docx in place: core.xml creator/lastModifiedBy -> Anonymous,
empty custom.xml properties, drop company/manager from app.xml, remove tracked-change/comment authors."""
import re, sys, zipfile, shutil, os
src = sys.argv[1]; tmp = src + ".tmp"
with zipfile.ZipFile(src) as zin, zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
    for item in zin.infolist():
        data = zin.read(item.filename)
        if item.filename == "docProps/core.xml":
            t = data.decode()
            t = re.sub(r"<dc:creator>.*?</dc:creator>", "<dc:creator>Anonymous</dc:creator>", t)
            t = re.sub(r"<cp:lastModifiedBy>.*?</cp:lastModifiedBy>", "", t)
            t = t.replace("</dc:creator>", "</dc:creator><cp:lastModifiedBy>Anonymous</cp:lastModifiedBy>", 1)
            data = t.encode()
        elif item.filename == "docProps/custom.xml":
            t = data.decode()
            t = re.sub(r"<property .*?</property>", "", t, flags=re.S)
            data = t.encode()
        elif item.filename == "docProps/app.xml":
            t = data.decode()
            t = re.sub(r"<(Company|Manager)>.*?</\1>", "", t)
            data = t.encode()
        elif item.filename.startswith("word/") and item.filename.endswith(".xml"):
            t = data.decode()
            t = re.sub(r'w:author="[^"]*"', 'w:author="Anonymous"', t)
            t = re.sub(r'w:initials="[^"]*"', 'w:initials=""', t)
            data = t.encode()
        zout.writestr(item, data)
shutil.move(tmp, src)
print("anonymised", src)
