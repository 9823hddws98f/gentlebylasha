#!/usr/bin/env python3
"""Build the static Gentle website.

Pages live in src/pages/*.html and start with a meta block:

    <!--
    title: Slapen
    description: ...
    nav: slapen
    header: overlay | solid
    -->

The build wraps each page with the shared head, header and footer partials and
writes the result to public/. Run: python3 build.py
"""
import re
from datetime import date
from pathlib import Path

ROOT = Path(__file__).parent
SRC = ROOT / "src"
OUT = ROOT / "public"

SITE_URL = "https://gentle.example"  # TODO: vervangen zodra het domein bekend is
APP_URL = "https://gentle-mu.vercel.app"  # wordt app.<domein>
CONTACT_EMAIL = "hallo@gentle.example"  # TODO: echt supportadres

NAV = [
    ("slapen", "Slapen", "slapen.html"),
    ("meditatie", "Meditatie", "meditatie.html"),
    ("geluiden", "Geluiden", "geluiden.html"),
    ("prijzen", "Prijzen", "prijzen.html"),
]


def partial(name):
    return (SRC / "partials" / f"{name}.html").read_text()


def parse(page):
    m = re.match(r"\s*<!--(.*?)-->\s*", page, re.S)
    meta = {}
    for line in m.group(1).strip().splitlines():
        key, _, value = line.partition(":")
        meta[key.strip()] = value.strip()
    return meta, page[m.end():]


def nav_links(active, cls=""):
    # Relative .html links work locally, as a published preview and on Vercel (cleanUrls).
    out = []
    for key, label, href in NAV:
        current = ' aria-current="page"' if key == active else ""
        out.append(f'<a href="{href}"{current}{cls}>{label}</a>')
    return "\n        ".join(out)


def build():
    head, header, footer = partial("head"), partial("header"), partial("footer")
    pages = sorted((SRC / "pages").glob("*.html"))
    for path in pages:
        meta, body = parse(path.read_text())
        slug = path.stem
        url_path = "/" if slug == "index" else f"/{slug}"
        title = meta["title"]
        full_title = "Gentle: slaapverhalen, meditatie en rustgevende geluiden" if slug == "index" else f"{title} | Gentle"
        html = (
            head.replace("{{TITLE}}", full_title)
            .replace("{{DESCRIPTION}}", meta["description"])
            .replace("{{CANONICAL}}", SITE_URL + url_path)
            .replace("{{OG_IMAGE}}", SITE_URL + meta.get("image", "/assets/img/meer-nacht-1200.jpg"))
            + header.replace("{{NAV}}", nav_links(meta.get("nav", "")))
            .replace("{{SOLID}}", " data-solid" if meta.get("header") == "solid" else "")
            + body
            + footer.replace("{{YEAR}}", str(date.today().year))
        ).replace("{{APP_URL}}", APP_URL).replace("{{CONTACT_EMAIL}}", CONTACT_EMAIL)
        (OUT / f"{slug}.html").write_text(html)
        print(f"built {slug}.html")

    urls = "\n".join(
        f"  <url><loc>{SITE_URL}{'/' if p.stem == 'index' else '/' + p.stem}</loc></url>"
        for p in pages if p.stem != "404"
    )
    (OUT / "sitemap.xml").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' + urls + "\n</urlset>\n"
    )
    (OUT / "robots.txt").write_text(f"User-agent: *\nAllow: /\nSitemap: {SITE_URL}/sitemap.xml\n")


if __name__ == "__main__":
    build()
