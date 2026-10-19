# Gentle admin

Beheeromgeving van Gentle. Hiermee beheer je de content van de app (tracks, playlists, pagina's en rijen), geef je toegangscodes uit aan Artazest-klanten, bekijk en help je gebruikers (premium geven, admin maken, account verwijderen), verstuur je pushberichten en bekijk je statistieken.

Next.js (App Router) met de Firebase client SDK. Gevoelige acties lopen via callable Cloud Functions in `functions/` die de `admin`-claim controleren en in `admin_log` schrijven.

## Lokaal draaien

Vanuit de root van de repo:

```bash
npm --prefix apps/admin install
npm --prefix apps/admin run dev
```

Open daarna http://localhost:3000. `localhost` staat standaard al bij de toegestane domeinen van Firebase Auth.

### Tegen de Firebase-emulators

Zo test je zonder productiedata. De admin praat dan met het demo-project `demo-gentle`.

1. Zet `NEXT_PUBLIC_FIREBASE_EMULATORS=1` in `apps/admin/.env.development.local`.
2. Bouw de functions: `npm --prefix functions run build`.
3. Zet nep-secrets in `functions/.secret.local`, bijvoorbeeld `SENDGRID_API_KEY=dummy` (één regel per secret uit `functions/.env.example`).
4. Start de emulators:
   ```bash
   firebase emulators:start --project demo-gentle --only auth,firestore,storage,functions
   ```
5. Maak een gebruiker aan in de Auth-emulator en geef die de claim `{"admin": true}`, met de Admin SDK en `FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099`.

## Deployen op Vercel

1. Importeer de repo in Vercel en zet **Root Directory** op `apps/admin`.
2. Environment variables zijn niet nodig: de (publieke) Firebase-webconfig staat in `src/lib/firebase.ts`. Alleen voor App Check zet je later `NEXT_PUBLIC_RECAPTCHA_SITE_KEY` (zie de lanceer-checklist).
3. Voeg het domein van de admin toe in Firebase Console → Authentication → Settings → **Authorized domains** (bijv. het `*.vercel.app`-domein en een eigen domein).
4. Zet in Firebase Console → Authentication → **Sign-in method** de providers **Email/Password** en **Google** aan.

## Eerste admin aanmaken

Admins herken je aan de custom claim `admin`. De eerste zet je vanaf je eigen machine:

```bash
GOOGLE_APPLICATION_CREDENTIALS=/pad/naar/service-account.json \
  npm --prefix functions run set-admin -- naam@voorbeeld.nl
```

Het account moet al bestaan (eerst één keer inloggen of registreren). Daarna kan elke admin andere admins maken onder **Gebruikers**.

Na het krijgen (of verliezen) van de claim moet de persoon **uit- en weer inloggen**; pas dan zit de nieuwe claim in het token.
