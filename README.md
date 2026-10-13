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

## Lokaal testen zonder productie

Alles draait tegen de Firebase-emulators met het demo-project `demo-gentle`. Daarvoor is Java nodig (`brew install openjdk@21`).

1. **Nep-secrets.** Zet ze één keer in `functions/.secret.local`: `SENDGRID_API_KEY`, `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `APPLE_IAP_KEY` en `APPLE_SIGNIN_KEY`, elk met een willekeurige waarde.
2. **Emulators starten:** `npm --prefix functions run emulators`.
3. **Testdata laden**, in een tweede terminal: `npm --prefix functions run seed`. Dat geeft:
   - een gratis track en een premium-track;
   - een homepagina;
   - code `GENTLE-ABCD-EFGH`;
   - admin `admin@gentle.test`, wachtwoord `admin-password`.
4. **App starten:** `flutter run -d chrome --dart-define=FIREBASE_EMULATORS=true`. Maak daarin een account aan.
5. **Admin starten:** zet `NEXT_PUBLIC_FIREBASE_EMULATORS=1` in `apps/admin/.env.development.local` en start dan `npm --prefix apps/admin run dev`.

Op het web raak je in emulatormodus je sessie kwijt bij herladen. Log dan opnieuw in.

## Deploy

- Backend: `firebase deploy --only firestore:rules,firestore:indexes,storage,functions`.
- Webapp, admin en website: op Vercel. Zie de [lanceer-checklist](docs/launch-checklist.md) voor de projectinstellingen, secrets en wat er in de stores moet gebeuren.
