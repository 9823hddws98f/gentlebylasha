# Gentle website

Statische marketingsite voor Gentle (NL). Geen framework, geen dependencies.

```
src/partials/   head, header, footer (gedeeld door alle pagina's)
src/pages/      één bestand per pagina, met een meta-blok bovenaan
public/         gebouwde site + assets (css, js, fonts, img)
build.py        zet src/pages + partials om naar public/*.html, plus sitemap.xml en robots.txt
```

## Werken

```bash
python3 build.py
python3 -m http.server 4173 --directory public
```

Pas pagina's aan in `src/pages/`, nooit in `public/*.html` (wordt overschreven).

## Pagina's

Home, Slapen, Meditatie, Geluiden, Prijzen (hoofdmenu) en Over, Help, Privacy, Voorwaarden, 404 (footer).

## Ontwerp

- Eén thema: nacht. Kleuren uit de app (`#0e1529`, `#1a2034`, groen `#52b788` uit het logo).
- Lettertype Matter (merkfont uit `assets/fonts/matter`), gesubset naar woff2.
- Radius-regel: knoppen pill, media en panelen 22px, kleine elementen 10px.
- Iconen: Phosphor Light, lokaal en gesubset in `public/assets/vendor/phosphor`. Nieuw icoon nodig? Haal de volledige `style.css` en `Phosphor-Light.woff2` opnieuw op van `@phosphor-icons/web@2.1.1` en subset opnieuw, anders blijft het icoon leeg.
- Geluiden op de site worden live gesynthetiseerd met Web Audio (`assets/js/site.js`), er zijn geen audiobestanden.
- Foto's: eigen app-foto (`fuji-nacht`) en Unsplash (vrij te gebruiken).

## Nog in te vullen voor livegang

- `SITE_URL`, `APP_URL` en `CONTACT_EMAIL` in `build.py`.
- Echte prijzen in `src/pages/prijzen.html` (nu voorbeeldbedragen).
- Privacy en Voorwaarden zijn concepten: laten controleren en bedrijfsgegevens toevoegen.
- Playlistnamen op Slapen zijn voorbeelden: vervangen door echte titels uit de catalogus.
- App Store / Google Play-knoppen zodra de app live staat.
- Engelse versie (`/en`) volgens de platformspec.

## Deploy

Vercel-project met root directory `website/public`, zonder build-stap. `public/vercel.json` zet nette URL's aan (`/slapen` in plaats van `/slapen.html`) en lange cache op assets.
