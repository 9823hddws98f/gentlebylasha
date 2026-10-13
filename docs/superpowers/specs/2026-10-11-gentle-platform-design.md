# Gentle platform — ontwerp

Datum: 2026-10-11
Status: in uitvoering — openstaande eigenaarstaken in docs/launch-checklist.md

## Doel

Gentle is een slaap-/ontspanningsapp met audio (tracks, playlists) en een premium-abonnement. Het is het eigen product van de eigenaar. De bestaande Flutter-code (repo `gentlebylasha`, laatst bijgewerkt nov 2024) is niet live in de stores.

Het doel is een compleet, werkend platform:

1. **App + klant-webapp** — de bestaande Flutter-app weer werkend en publiceerbaar (iOS, Android, web).
2. **Admin-webapp** — beheer van content, gebruikers, statistieken en pushberichten.
3. **Website** — marketing, prijzen, blog, juridische pagina's.

### Succescriteria

- App draait op iOS Simulator, Android emulator en in Chrome zonder fouten, op de huidige Flutter stable.
- Een gebruiker kan op iOS, Android of web een abonnement nemen en is daarna overal premium.
- Een admin kan zonder code een track uploaden, in een playlist en op een pagina zetten, en die verschijnt in de app.
- Website scoort Lighthouse ≥ 90 op performance, SEO en accessibility, in EN en NL.
- Geen open Firestore/Storage-data en geen ongeauthenticeerde functions die schade kunnen doen.
- Hostingkosten zo laag mogelijk; Firebase-budgetalarm op €10/maand.

### Buiten scope (YAGNI)

- Nieuwe app-functies of redesign van de app (alleen werkend maken + NL-vertaling).
- Herbouw van de klant-webapp buiten Flutter.
- Rollen binnen admin (alle admins gelijk).
- Blog-CMS in de admin (blog = MDX-bestanden).
- Duitse taal (wordt verwijderd).

## Beslissingen

| Onderwerp | Keuze |
|---|---|
| Backend | Bestaand Firebase-project `sleeptales-4bac2` (Auth, Firestore, Storage, Functions, FCM). Bestaande data blijft. |
| App + klant-webapp | Flutter, één codebase. Webbuild = klant-webapp. |
| Admin + website | Next.js (TypeScript), in dezelfde repo. |
| Hosting web | Vercel Hobby, drie projecten (website, webapp, admin). |
| Betalen | Abonnement maand + jaar. Store-IAP op iOS/Android, Stripe op web. Eén premium-status. |
| Talen | Engels (standaard) en Nederlands. |
| Mail | SendGrid (bestaand), tenzij account niet meer bestaat — dan Resend. |
| Oude Globe-backend | Vervalt; aankoopvalidatie gaat naar Firebase Functions. |

## Architectuur

### Repo-structuur

```
gentlesleep/
  app/                 Flutter-app (verhuisd vanuit root)
  functions/           Firebase Functions, omgezet naar TypeScript
  apps/web/            Next.js website
  apps/admin/          Next.js admin
  packages/shared/     Gedeelde TS-types voor Firestore-documenten
  firestore.rules
  storage.rules
  firebase.json
  package.json         pnpm workspace (functions, apps/*, packages/*)
```

### Hosting

| Onderdeel | Domein | Host |
|---|---|---|
| Website | `<domein>` | Vercel |
| Klant-webapp | `app.<domein>` | Vercel (statische Flutter web build) |
| Admin | `admin.<domein>` | Vercel |
| Backend | — | Firebase (Blaze-plan, budgetalarm €10) |

Domein wordt later ingevuld; tot dan draaien alle drie op `*.vercel.app`.

### Data (Firestore)

Bestaande collecties blijven ongewijzigd: `users`, `tracks`, `playlists`, `pages`, `blocks`, `favorites`, `favorites_playlists`, `activity_log`, `account_deletion`.

Nieuw:

- `subscriptions/{uid}` — `{ active: bool, source: 'apple'|'google'|'stripe'|'manual', productId, expiresAt, originalTransactionId?, stripeCustomerId?, updatedAt }`. Alleen schrijfbaar door functions.
- `admin_log/{id}` — `{ adminUid, action, target, payload, at }`. Alleen schrijfbaar door functions.
- `push_jobs/{id}` — `{ title{en,nl}, body{en,nl}, audience: 'all'|'premium'|'free', sendAt, status }`.

Tracks en playlists krijgen een veld `premium: bool` (default `false`) als dat nog niet bestaat, en optioneel `titleNl`/`descriptionNl` (rijen: `titleNl`, pagina's: `nameNl`). Het bestaande veld blijft de Engelse standaardtekst; de app toont de NL-tekst als de app in het Nederlands staat en het veld gevuld is.

### Admin-rechten

- Firebase Auth custom claim `admin: true`.
- Eerste admin wordt gezet met een lokaal script (`functions/scripts/set-admin.ts <email>`).
- Daarna kan een admin anderen admin maken via de admin-webapp (function `setAdmin`).
- `UserRole` in de app blijft voor weergave; de claim is de bron van waarheid voor rechten.

### Security rules

- `users/{uid}`, `favorites*`, `activity_log`: alleen eigen documenten lezen/schrijven; admin mag lezen.
- `tracks`, `playlists`, `pages`, `blocks`: iedereen ingelogd mag lezen, alleen admin schrijven.
- `subscriptions/{uid}`: eigenaar en admin lezen, niemand schrijven (alleen Admin SDK).
- `admin_log`, `push_jobs`: alleen admin lezen; schrijven alleen via functions.
- Storage: audio/afbeeldingen lezen voor ingelogde gebruikers; premium-audio alleen met actieve subscription; uploaden alleen admin.

## Onderdeel 1 — App + klant-webapp

### Werkend maken

- Upgrade naar Flutter 3.47 / Dart 3.13; alle dependencies naar compatibele versies.
- Dubbele IAP-packages samenvoegen tot `in_app_purchase`; onderhouden vervangers voor verlaten packages.
- `app_nl.arb` toevoegen, `app_de.arb` verwijderen. Taal volgt toestel, fallback Engels.
- Deep-link basis-URL van `gentle-mu.vercel.app` naar `app.<domein>` (configureerbaar).
- Premium-status lezen uit `subscriptions/{uid}`.
- Web: “Abonneren” opent Stripe Checkout via function `createCheckoutSession`; “Beheer abonnement” opent Stripe Customer Portal.

### Abonnementen

```
iOS/Android: koop in store ─> app stuurt receipt/purchaseToken naar `verifyPurchase`
             ─> function valideert bij Apple (App Store Server API) / Google (Play Developer API)
             ─> schrijft subscriptions/{uid}
Web: Stripe Checkout ─> `stripeWebhook` ─> subscriptions/{uid}
Verlenging/opzegging: Apple Server Notifications v2 (`appleNotifications`),
                      Google RTDN via Pub/Sub (`googleRtdn`), Stripe webhooks
```

- Producten: `gentle_premium_monthly`, `gentle_premium_yearly` (zelfde ID's in alle stores en Stripe-metadata).
- Herstel aankopen: knop in de app roept opnieuw `verifyPurchase` aan.
- Validatie mislukt ⇒ geen premium; app toont foutmelding met “opnieuw proberen”.

### Bestaande bugs die mee opgelost worden

- `sendEmail` callable is zonder auth aanroepbaar ⇒ beperken tot admin, of verwijderen als de app hem niet nodig heeft.
- `onUserCreateOrUpdate` gebruikt `context.data()` (bestaat niet) ⇒ welkomstmail werkt niet ⇒ herschrijven als `onDocumentCreated`.
- Functions van v1 (`functions.config()`) naar v2 met Secret Manager voor sleutels.

## Onderdeel 2 — Admin-webapp

Next.js App Router, Firebase client SDK voor lezen, callable functions voor gevoelige acties. UI met de Gentle-huisstijl; tabellen, formulieren, drag-and-drop voor volgordes.

| Scherm | Functies |
|---|---|
| Inloggen | E-mail/wachtwoord of Google; zonder `admin`-claim ⇒ geen toegang. |
| Tracks | Lijst, zoeken, filters. Aanmaken/bewerken: titel en beschrijving EN/NL, categorie, tags, premium aan/uit, audio + afbeelding uploaden. Duur wordt automatisch uitgelezen, blurhash gegenereerd. |
| Playlists | Tracks toevoegen, volgorde slepen, cover, premium aan/uit. |
| Pagina's & blokken | Pagina's ordenen; per pagina blokken (hero, featured, series, normal) slepen, inhoud kiezen, preview. Schrijft naar bestaande `pages`/`blocks`-structuur. |
| Gebruikers | Zoeken op e-mail, profiel + abonnement bekijken, handmatig premium (`source: 'manual'`, met einddatum), account verwijderen, admin maken. |
| Statistieken | Totaal gebruikers, nieuwe aanmeldingen per week, actieve abonnees per bron, opzeggingen, top-10 tracks. Uit `users`, `subscriptions`, `activity_log` (aggregaties via function `adminStats`, 1 uur gecached). |
| Push | Titel/tekst EN/NL, doelgroep (alle/premium/gratis), nu of gepland. Via FCM-topics; app abonneert op `premium` of `free` en op `lang_en` of `lang_nl`. “Alle” = beide taaltopics. |

Gevoelige acties (verwijderen, premium geven, push, admin maken) alleen via functions met claimcheck; elke actie in `admin_log`.

## Onderdeel 3 — Website

Next.js, statisch gegenereerd waar mogelijk.

- Pagina's: Home, Prijzen, Blog (lijst + artikel), Privacy, Voorwaarden, Account verwijderen.
- Talen: `/en` en `/nl`, hreflang, taaldetectie bij eerste bezoek.
- SEO: sitemap, robots, Open Graph-afbeeldingen per pagina, structured data (`SoftwareApplication`, `Article`).
- Blog: MDX in `apps/web/content/blog/{en,nl}/`.
- Prijzen: haalt prijzen uit Stripe bij build (revalidate dagelijks); knop naar `app.<domein>` om af te rekenen.
- Downloadknoppen naar App Store / Play Store zodra de app live is; tot dan alleen “Open webapp”.
- Design: Gentle-merkstijl (logo `assets/gentle_logo.svg`, kleuren uit `app_theme.dart` tenzij de eigenaar nieuwe aanlevert), rustig en slaperig, geen generiek template.

## Foutafhandeling

- Functions: input valideren (zod), duidelijke `HttpsError`-codes, fouten loggen naar Cloud Logging.
- Webhooks: idempotent (event-ID opslaan), Stripe/Apple/Google herhalen zelf bij fout.
- Admin: toast bij succes/fout; uploads met voortgang en herstart bij mislukken.
- App: bestaande foutweergave; netwerkfouten bij premium-check ⇒ laatst bekende status gebruiken (gecached).

## Testen

- Functions: unit tests + Firebase Emulator Suite; nep-receipts voor Apple/Google; Stripe test-modus.
- Security rules: `@firebase/rules-unit-testing` voor elke regel.
- App: `flutter analyze`, bestaande tests, handmatige run op iOS Simulator, Android emulator, Chrome.
- Admin: kernflows controleren in de browser (track uploaden ⇒ zichtbaar in app).
- Website: `next build`, Lighthouse ≥ 90, linkcheck.
- Store-sandbox-aankopen: door de eigenaar (vereist Apple Developer- en Google Play-account).

## Bouwvolgorde

1. **Fundament** — repo-structuur, functions naar TS/v2, security rules + tests, subscriptions-model.
2. **App werkend** — Flutter upgrade, NL, premium uit `subscriptions`, Stripe op web.
3. **Admin** — inloggen, tracks, playlists, pagina's, gebruikers, statistieken, push.
4. **Website** — pagina's, blog, prijzen, SEO.
5. **Live** — Vercel-projecten, domein, Firebase deploy, store-submissions (door eigenaar).

Elk onderdeel krijgt een eigen implementatieplan.

## Afhankelijkheden van de eigenaar

- Toegang tot Firebase-project `sleeptales-4bac2` (Owner of Editor) en Blaze-plan.
- `sudo xcodebuild -license accept` voor iOS-builds.
- Accounts: Apple Developer, Google Play Console, Stripe, Vercel (apart account), SendGrid (of akkoord voor Resend).
- Domeinnaam en eventuele nieuwe merkstijl.

## Open punten

- Domeinnaam: onbekend; placeholder `<domein>` tot aangeleverd.
- Of de huidige logo/kleuren de definitieve merkstijl zijn.
- Of Firestore nu open staat (controleren zodra er projecttoegang is).
- Exacte prijzen maand/jaar (in te stellen in stores en Stripe, niet in code).
