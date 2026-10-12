#!/usr/bin/env python3
"""Generate responsive variants for the photos in public/assets/img.

Every photo is stored as <name>-<width>.jpg. The largest file per name is the
source; this script writes JPEG and WebP versions at 640, 1200 and 2400 px
wide (never wider than the source). build.py turns <img> tags into <picture>
elements that use whatever variants exist.

Needs ffmpeg with libwebp. Run from the website folder: python3 tools/images.py
"""
import re
import subprocess
from collections import defaultdict
from pathlib import Path

IMG = Path(__file__).resolve().parent.parent / "public" / "assets" / "img"
WIDTHS = [640, 1200, 2400]


def ffmpeg(src, dst, width, webp):
    args = ["ffmpeg", "-loglevel", "error", "-y", "-i", str(src), "-vf", f"scale={width}:-2"]
    args += ["-c:v", "libwebp", "-quality", "72"] if webp else ["-q:v", "5"]
    subprocess.run(args + [str(dst)], check=True)


def main():
    sources = defaultdict(list)
    for f in IMG.glob("*.jpg"):
        m = re.fullmatch(r"(.+)-(\d+)\.jpg", f.name)
        if m:
            sources[m.group(1)].append((int(m.group(2)), f))
    for name, files in sorted(sources.items()):
        src_w, src = max(files)
        targets = [w for w in WIDTHS if w < src_w] + [src_w]
        for w in targets:
            jpg, webp = IMG / f"{name}-{w}.jpg", IMG / f"{name}-{w}.webp"
            if not jpg.exists():
                ffmpeg(src, jpg, w, webp=False)
            if not webp.exists() or webp.stat().st_mtime < src.stat().st_mtime:
                ffmpeg(src, webp, w, webp=True)
        print(f"{name}: {', '.join(str(w) for w in targets)}")


if __name__ == "__main__":
    main()
