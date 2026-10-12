#!/usr/bin/env python3
"""Rebuild the Phosphor Light icon subset from the icons used on the site.

Scans public/**/*.html and public/assets/js/site.js for `ph-light ph-<name>`,
downloads the full Phosphor Light CSS and font, and writes a CSS file and a
woff2 font that contain only those icons.

Needs fonttools + brotli:  pip install fonttools brotli
Run from the website folder:  python3 tools/subset_icons.py
"""
import re
import subprocess
import tempfile
import urllib.request
from pathlib import Path

VERSION = "2.1.1"
CDN = f"https://unpkg.com/@phosphor-icons/web@{VERSION}/src/light"
ROOT = Path(__file__).resolve().parent.parent
PUBLIC = ROOT / "public"
OUT = PUBLIC / "assets" / "vendor" / "phosphor"


def used_icons():
    files = list(PUBLIC.rglob("*.html")) + [PUBLIC / "assets" / "js" / "site.js"]
    names = set()
    for f in files:
        names |= set(re.findall(r"ph-light ph-([a-z0-9-]+)", f.read_text()))
    return names


def main():
    names = used_icons()
    css = urllib.request.urlopen(f"{CDN}/style.css").read().decode()
    rules = dict((n, r) for r, n in re.findall(r"(\.ph-light\.ph-([a-z0-9-]+):before\s*\{[^}]*\})", css))
    missing = names - rules.keys()
    if missing:
        raise SystemExit(f"Unknown icons: {sorted(missing)}")

    head = css.split(".ph-light.ph-")[0]
    head = re.sub(r"src:\s*url\([^;]*;", 'src: url("./Phosphor-Light.woff2") format("woff2");', head, count=1, flags=re.S)
    keep = [rules[n] for n in sorted(names)]
    codepoints = [re.search(r'content:\s*"\\([0-9a-f]+)"', r).group(1) for r in keep]

    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "style.css").write_text(head + "\n".join(keep) + "\n")
    with tempfile.TemporaryDirectory() as tmp:
        full = Path(tmp) / "full.woff2"
        full.write_bytes(urllib.request.urlopen(f"{CDN}/Phosphor-Light.woff2").read())
        subprocess.run([
            "pyftsubset", str(full),
            "--unicodes=" + ",".join("U+" + c for c in codepoints),
            "--flavor=woff2",
            f"--output-file={OUT / 'Phosphor-Light.woff2'}",
        ], check=True)
    print(f"{len(keep)} icons: {', '.join(sorted(names))}")


if __name__ == "__main__":
    main()
