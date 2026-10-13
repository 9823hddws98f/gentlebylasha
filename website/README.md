# Gentle website

Statische marketingsite voor Gentle in het Nederlands (`/`) en Engels (`/en/`). Geen framework, geen dependencies.

```
src/partials/   head, header, footer (gedeeld door alle pagina's)
src/pages/nl/   Nederlandse pagina's, één bestand per pagina met een meta-blok bovenaan
src/pages/en/   Engelse pagina's (meta `key:` koppelt aan de NL-pagina)
tools/          images.py (fotovarianten) en subset_icons.py (Phosphor-iconen)
public/         gebouwde site + assets (css, js, fonts, img)
build.py        bouwt public/*.html en public/en/*.html, plus sitemap.xml en robots.txt.
                Teksten van header en footer staan in STRINGS, URL's per taal in SLUGS.
```

## Werken

```bash
python3 build.py
python3 -m http.server 4173 --directory public
```

Pas pagina's aan in `src/pages/`, nooit in `public/*.html` (wordt overschreven). Interne links in pagina's mogen `{{href.<key>}}` gebruiken, dan klopt de link in elke taal. De build stopt met een fout als er een token niet is ingevuld.

## Pagina's

Home, Slapen, Meditatie, Geluiden, Prijzen (hoofdmenu) en Over, Help, Privacy, Voorwaarden, 404 (footer). In het Engels: Home, Sleep, Meditation, Sounds, Pricing, About, Help, Privacy, Terms.

Talen: elke pagina heeft hreflang-links en een taalwissel in footer en mobiel menu. Wie een andere browsertaal heeft, krijgt één keer een kleine hint om de andere taal te openen. Er wordt nooit automatisch doorgestuurd, zodat Google beide versies netjes indexeert.

## Ontwerp

- Eén thema: nacht. Kleuren uit de app (`#0e1529`, `#1a2034`, groen `#52b788` uit het logo).
- Lettertype Matter (merkfont uit `assets/fonts/matter`), gesubset naar woff2.
- Radius-regel: knoppen pill, media en panelen 22px, kleine elementen 10px.
- Iconen: Phosphor Light, lokaal en gesubset in `public/assets/vendor/phosphor`. Nieuw icoon gebruikt? Draai na de build `python3 tools/subset_icons.py` (vereist `pip install fonttools brotli`), anders blijft het icoon leeg.
- Geluiden op de site worden live gesynthetiseerd met Web Audio (`assets/js/site.js`), er zijn geen audiobestanden.
- Foto's: eigen app-foto (`fuji-nacht`) en Unsplash (vrij te gebruiken). Bewaar een nieuwe foto als `naam-<breedte>.jpg` en draai `python3 tools/images.py` (vereist ffmpeg): dat maakt 640/1200/2400-varianten in JPEG en WebP. De build zet elke `<img>` dan automatisch om naar een `<picture>` met srcset. Geef full-bleed foto's `sizes="100vw"`.
- Lighthouse (mobiel): live op Vercel performance 98-100; accessibility en best practices 100; SEO 100 zodra `noindex` weg is.

## Nog in te vullen voor livegang

- `SITE_URL`, `APP_URL` en `CONTACT_EMAIL` in `build.py`.
- `noindex`-header uit `public/vercel.json` halen en het domein aan het Vercel-project koppelen.
- Echte prijzen in `src/pages/nl/prijzen.html` en `src/pages/en/pricing.html` (nu voorbeeldbedragen).
- Privacy en Voorwaarden zijn concepten: laten controleren en bedrijfsgegevens toevoegen.
- Playlistnamen op Slapen/Sleep zijn voorbeelden: vervangen door echte titels uit de catalogus.
- App Store / Google Play-knoppen zodra de app live staat.

## Deploy

Vercel-project `gentle-website` (team Tein brouwer's projects), live op https://gentle-website.vercel.app. Geen build-stap: draai lokaal `python3 build.py` en deploy de map `public`:

```bash
cd website/public
vercel deploy --prod --scope tein-brouwers-projects-79faf9ea
```

`public/vercel.json` zet nette URL's aan (`/slapen` in plaats van `/slapen.html`), lange cache op assets en voorlopig `X-Robots-Tag: noindex` op alles, zodat zoekmachines de conceptversie niet indexeren. Haal die header weg bij livegang op het echte domein (Lighthouse SEO gaat dan van 69 naar 100). `.vercelignore` houdt `.env*` en `.vercel` buiten de deploy.
