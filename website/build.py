#!/usr/bin/env python3
"""Build the static Gentle website in Dutch and English.

Pages live in src/pages/<lang>/*.html and start with a meta block:

    <!--
    key: slapen            (page id shared by both languages, defaults to the file name)
    title: Slapen
    description: ...
    nav: slapen
    header: overlay | solid
    image: /assets/img/...  (optional Open Graph image)
    -->

Dutch is built to public/, English to public/en/. Partials use tokens:
{{t.name}} for strings, {{href.key}} and {{nav.key}} for links, {{BASE}} for
the path back to the site root. Run: python3 build.py
"""
import json
import re
from datetime import date
from pathlib import Path

ROOT = Path(__file__).parent
SRC = ROOT / "src"
OUT = ROOT / "public"

SITE_URL = "https://gentle.example"  # TODO: vervangen zodra het domein bekend is
APP_URL = "https://gentle-mu.vercel.app"  # wordt app.<domein>
CONTACT_EMAIL = "hallo@gentle.example"  # TODO: echt supportadres

LANGS = {
    "nl": {"dir": "", "og": "nl_NL"},
    "en": {"dir": "en/", "og": "en_GB"},
}

# Page key -> file name per language. Keys are the Dutch file names.
SLUGS = {
    "index": {"nl": "index", "en": "index"},
    "slapen": {"nl": "slapen", "en": "sleep"},
    "meditatie": {"nl": "meditatie", "en": "meditation"},
    "geluiden": {"nl": "geluiden", "en": "sounds"},
    "prijzen": {"nl": "prijzen", "en": "pricing"},
    "over": {"nl": "over", "en": "about"},
    "help": {"nl": "help", "en": "help"},
    "privacy": {"nl": "privacy", "en": "privacy"},
    "voorwaarden": {"nl": "voorwaarden", "en": "terms"},
    "404": {"nl": "404"},
}

NAV_KEYS = ["slapen", "meditatie", "geluiden", "prijzen"]

STRINGS = {
    "nl": {
        "nav.slapen": "Slapen", "nav.meditatie": "Meditatie", "nav.geluiden": "Geluiden", "nav.prijzen": "Prijzen",
        "t.skip": "Naar de inhoud",
        "t.home_label": "Gentle, naar de homepage",
        "t.main_menu": "Hoofdmenu",
        "t.mobile_menu": "Mobiel menu",
        "t.menu_open": "Menu openen",
        "t.menu_close": "Menu sluiten",
        "t.login": "Inloggen",
        "t.cta": "Gratis beginnen",
        "t.footer_tagline": "Slaapverhalen, meditaties en zachte geluiden voor rustige avonden en betere nachten.",
        "t.discover": "Ontdek",
        "t.about": "Over Gentle",
        "t.help": "Help en veelgestelde vragen",
        "t.legal": "Juridisch",
        "t.privacy": "Privacy",
        "t.terms": "Voorwaarden",
        "t.delete": "Account verwijderen",
        "t.delete_anchor": "account-verwijderen",
        "t.disclaimer": "Gentle is geen vervanging voor medisch advies.",
        "home_title": "Gentle: slaapverhalen, meditatie en rustgevende geluiden",
        "label": "Nederlands",
        "hint": "Deze pagina is ook in het Nederlands te lezen",
        "hint_close": "Sluiten",
    },
    "en": {
        "nav.slapen": "Sleep", "nav.meditatie": "Meditation", "nav.geluiden": "Sounds", "nav.prijzen": "Pricing",
        "t.skip": "Skip to content",
        "t.home_label": "Gentle, go to the homepage",
        "t.main_menu": "Main menu",
        "t.mobile_menu": "Mobile menu",
        "t.menu_open": "Open menu",
        "t.menu_close": "Close menu",
        "t.login": "Log in",
        "t.cta": "Start for free",
        "t.footer_tagline": "Sleep stories, meditations and soft sounds for calmer evenings and better nights.",
        "t.discover": "Discover",
        "t.about": "About Gentle",
        "t.help": "Help and FAQ",
        "t.legal": "Legal",
        "t.privacy": "Privacy",
        "t.terms": "Terms",
        "t.delete": "Delete account",
        "t.delete_anchor": "delete-account",
        "t.disclaimer": "Gentle is not a substitute for medical advice.",
        "home_title": "Gentle: sleep stories, meditation and calming sounds",
        "label": "English",
        "hint": "Read this page in English",
        "hint_close": "Close",
    },
}


def partial(name):
    return (SRC / "partials" / f"{name}.html").read_text()


def parse(page):
    m = re.match(r"\s*<!--(.*?)-->\s*", page, re.S)
    meta = {}
    for line in m.group(1).strip().splitlines():
        key, _, value = line.partition(":")
        meta[key.strip()] = value.strip()
    return meta, page[m.end():]


def url_path(lang, key):
    slug = SLUGS[key][lang]
    prefix = "/" + LANGS[lang]["dir"]
    return prefix if slug == "index" else f"{prefix}{slug}"


def href(lang, key, base):
    # Relative .html links work locally, as a published preview and on Vercel (cleanUrls).
    return f"{base}{LANGS[lang]['dir']}{SLUGS[key][lang]}.html"


def nav_links(lang, active, base):
    out = []
    for key in NAV_KEYS:
        current = ' aria-current="page"' if key == active else ""
        out.append(f'<a href="{href(lang, key, base)}"{current}>{STRINGS[lang]["nav." + key]}</a>')
    return "\n        ".join(out)


IMG_DIR = OUT / "assets" / "img"
DEFAULT_SIZES = "(max-width: 900px) 100vw, 50vw"


def responsive(body):
    """Turn <img src="assets/img/name-W.jpg"> into a <picture> with WebP and JPEG
    srcsets built from the variants tools/images.py generated."""

    def widths(name, ext):
        found = [int(m.group(1)) for f in IMG_DIR.glob(f"{name}-*.{ext}")
                 if (m := re.fullmatch(rf"{re.escape(name)}-(\d+)\.{ext}", f.name))]
        return sorted(found)

    def replace(m):
        tag, name = m.group(0), m.group(1)
        jpgs, webps = widths(name, "jpg"), widths(name, "webp")
        if len(jpgs) < 2:
            return tag
        sizes_m = re.search(r'\ssizes="([^"]*)"', tag)
        sizes = sizes_m.group(1) if sizes_m else DEFAULT_SIZES
        srcset = lambda ws, ext: ", ".join(f"assets/img/{name}-{w}.{ext} {w}w" for w in ws)
        fallback = min((w for w in jpgs if w >= 1200), default=jpgs[-1])
        img = re.sub(r'\s(srcset|sizes)="[^"]*"', "", tag)
        img = re.sub(r'src="[^"]*"', f'src="assets/img/{name}-{fallback}.jpg" srcset="{srcset(jpgs, "jpg")}" sizes="{sizes}"', img, count=1)
        source = f'<source type="image/webp" srcset="{srcset(webps, "webp")}" sizes="{sizes}">' if webps else ""
        return f"<picture>{source}{img}</picture>"

    return re.sub(r'<img\b[^>]*\bsrc="assets/img/([a-z-]+)-\d+\.jpg"[^>]*>', replace, body)


def rebase(body, base):
    """Point root-relative asset paths in a page body at the site root."""
    if not base:
        return body
    return re.sub(r'(["\s,])assets/', lambda m: f"{m.group(1)}{base}assets/", body)


def json_ld(lang):
    return (
        '  <script type="application/ld+json">'
        + json.dumps({
            "@context": "https://schema.org",
            "@type": "SoftwareApplication",
            "name": "Gentle",
            "applicationCategory": "HealthApplication",
            "operatingSystem": "iOS, Android, Web",
            "inLanguage": lang,
            "url": SITE_URL + url_path(lang, "index"),
            "offers": {"@type": "Offer", "price": "0", "priceCurrency": "EUR"},
        }, ensure_ascii=False)
        + "</script>"
    )


def render(lang, key, meta, body):
    other = "en" if lang == "nl" else "nl"
    s = STRINGS[lang]
    if key == "404":
        base = "/"  # served at any depth
    else:
        base = "../" * LANGS[lang]["dir"].count("/")
    has_other = other in SLUGS[key]
    other_key = key if has_other else "index"

    alternates = ""
    if has_other:
        alternates = "\n".join(
            f'  <link rel="alternate" hreflang="{l}" href="{SITE_URL + url_path(l, key)}">' for l in LANGS
        ) + f'\n  <link rel="alternate" hreflang="x-default" href="{SITE_URL + url_path("nl", key)}">'

    title = s["home_title"] if key == "index" else f"{meta['title']} | Gentle"
    html = (
        partial("head")
        + partial("header").replace("{{NAV}}", nav_links(lang, meta.get("nav", ""), base))
        + rebase(responsive(body), base)
        + partial("footer")
    )
    tokens = {
        "{{LANG}}": lang,
        "{{TITLE}}": title,
        "{{DESCRIPTION}}": meta["description"],
        "{{CANONICAL}}": SITE_URL + url_path(lang, key) if key != "404" else SITE_URL + "/",
        "{{ALTERNATES}}": alternates,
        "{{OG_LOCALE}}": LANGS[lang]["og"],
        "{{OG_IMAGE}}": SITE_URL + meta.get("image", "/assets/img/meer-nacht-1200.jpg"),
        "{{JSONLD}}": json_ld(lang) if key == "index" else "",
        "{{SOLID}}": " data-solid" if meta.get("header") == "solid" else "",
        "{{OTHER_HREF}}": href(other, other_key, base),
        "{{OTHER_LANG}}": other,
        "{{OTHER_LABEL}}": STRINGS[other]["label"],
        "{{OTHER_HINT}}": STRINGS[other]["hint"],
        "{{OTHER_HINT_CLOSE}}": STRINGS[other]["hint_close"],
        "{{YEAR}}": str(date.today().year),
        "{{BASE}}": base,
        "{{APP_URL}}": APP_URL,
        "{{CONTACT_EMAIL}}": CONTACT_EMAIL,
    }
    for k in SLUGS:
        if lang in SLUGS[k]:
            tokens["{{href.%s}}" % k] = href(lang, k, base)
    for k, v in s.items():
        if k.startswith(("t.", "nav.")):
            tokens["{{%s}}" % k] = v
    for k, v in tokens.items():
        html = html.replace(k, v)
    left = re.findall(r"\{\{[^}]+\}\}", html)
    if left:
        raise SystemExit(f"{lang}/{key}: unresolved tokens {sorted(set(left))}")
    return html


def build():
    sitemap = []
    for lang, cfg in LANGS.items():
        out_dir = OUT / cfg["dir"]
        out_dir.mkdir(parents=True, exist_ok=True)
        for path in sorted((SRC / "pages" / lang).glob("*.html")):
            meta, body = parse(path.read_text())
            key = meta.get("key", path.stem)
            if SLUGS.get(key, {}).get(lang) != path.stem:
                raise SystemExit(f"{path}: file name does not match SLUGS[{key!r}][{lang!r}]")
            (out_dir / f"{path.stem}.html").write_text(render(lang, key, meta, body))
            print(f"built {cfg['dir']}{path.stem}.html")
            if key != "404":
                sitemap.append(SITE_URL + url_path(lang, key))

    (OUT / "sitemap.xml").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
        + "\n".join(f"  <url><loc>{u}</loc></url>" for u in sitemap)
        + "\n</urlset>\n"
    )
    (OUT / "robots.txt").write_text(f"User-agent: *\nAllow: /\nSitemap: {SITE_URL}/sitemap.xml\n")


if __name__ == "__main__":
    build()
