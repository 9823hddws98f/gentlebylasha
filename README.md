# Gentle

Slaap- en ontspanningsapp met audio (tracks, playlists) en een premium-abonnement.

| Map | Wat |
|---|---|
| `lib/`, `ios/`, `android/`, `web/` | Flutter-app voor iOS en Android. De webbuild is de klant-webapp. |
| `functions/` | Firebase Cloud Functions (TypeScript): codes, aankopen, push, admin-acties. |
| `apps/admin/` | Admin-webapp (Next.js): content, gebruikers, codes, push, statistieken. |
| `website/` | Marketingwebsite (statisch). Zie `website/README.md`. |
| `firestore.rules`, `storage.rules` | Security rules, getest in `functions/test-rules/`. |

Achtergrond: [ontwerp](docs/superpowers/specs/2026-10-11-gentle-platform-design.md), [product](PRODUCT.md), [lanceer-checklist](docs/launch-checklist.md).

## Werken

```bash
# App
flutter pub get
flutter run                       # of: flutter run -d chrome
flutter analyze && flutter test

# Functions
npm --prefix functions install
npm --prefix functions test       # unit tests
npm --prefix functions run test:rules   # security rules op de emulators (Java nodig)

# Admin
npm --prefix apps/admin install
npm --prefix apps/admin run dev
```

De app leest `SITE_URL` en `APP_URL` uit `--dart-define`. Zonder die waarden gebruikt hij de huidige `*.vercel.app`-adressen.

## Deploy

- Backend: `firebase deploy --only firestore:rules,firestore:indexes,storage,functions`.
- Webapp, admin en website: op Vercel. Zie de [lanceer-checklist](docs/launch-checklist.md) voor de projectinstellingen, secrets en wat er in de stores moet gebeuren.
