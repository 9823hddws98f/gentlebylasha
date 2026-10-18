# Gentle — route naar live

Stand: 18 oktober 2026. Werk de stappen van boven naar beneden af. Bij elke stap staat wie hem doet:

- **Jij:** accounts, betalingen, sleutels, consoles, toestellen.
- **Claude:** kan het doen zodra jij akkoord geeft.

Store-teksten, review notes en privacy-antwoorden staan klaar in [store-listing.md](store-listing.md).

## Waar we staan

**Code:** klaar en getest.

- **Backend:** Cloud Functions, security rules met tests, abonnementen (App Store, Google Play, Stripe) en toegangscodes.
- **Admin:** content, gebruikers, codes, push, statistieken en het activiteitenlog.
- **App:** iOS, Android en web, in het Engels en het Nederlands.
- **Getest:** van begin tot eind tegen de emulators. Een admin zet een track klaar, die verschijnt in de app, een code wordt ingewisseld, en daarna speelt de premium-audio.

**Live gecontroleerd op 18 oktober:**

| | Stand |
|---|---|
| Firebase-project `sleeptales-4bac2` | Heet "Gentle". Je bent ingelogd met de Firebase CLI. |
| Oude functions uit 2024 | Niet meer live. Het lek is dicht. |
| Firestore | Niet publiek leesbaar. |
| Secrets voor functions | Nog geen enkele gezet. |
| Vercel | Alleen `gentle-website` (met noindex). Er is nog geen project voor de webapp en de admin. |
| `gentle-mu.vercel.app` | De **oude** webapp. Die draait nog op een ander Vercel-account, tegen hetzelfde Firebase-project. |

## Stap 1 — Beslissen (jij)

- [ ] **Oude webapp `gentle-mu.vercel.app`.** Wie beheert hem? Die moet offline zodra de nieuwe webapp live staat. Na de nieuwe security rules werkt hij waarschijnlijk niet meer goed.
- [ ] **iOS bundle id.**
  - Nu `io.sleeptales.sleeptales`.
  - Bestaat daar al een App Store-record onder jouw account, houd hem dan.
  - Anders wordt het een nieuwe id. Pas dan ook `APPLE_BUNDLE_ID` en `APPLE_SIGNIN_CLIENT_ID` aan.
  - Android is `com.mezz.gentle`.
- [ ] **Xcode-team.** Het project gebruikt team `AT39BY34V6`. Is dat jouw team?
- [ ] **Code inwisselen op iOS** (richtlijn 3.1.1). Kies één van twee:
  - houden, met de uitleg uit de review notes; of
  - op iOS verbergen, zodat klanten in de webapp inwisselen.
- [ ] **Gratis of premium.** Welke content is gratis en welke premium? Dat zet je per track in de admin.
- [ ] **Prijzen** voor maand en jaar. Die stel je in bij Stripe en in beide stores, niet in de code.
- [ ] **Domein en supportmailadres.** Tot die er zijn, draait alles op `*.vercel.app`.
- [ ] **Buildnummer.** `pubspec.yaml` staat op `1.1.10+1`. Hebben bestaande store-records hogere builds, dan moet het nummer daarboven.

## Stap 2 — Accounts en sleutels (jij)

### Firebase

- [ ] Zet het project op het **Blaze-plan**, met een budgetalarm van €10 per maand (Google Cloud Console → Billing → Budgets).
- [ ] **SendGrid:** maak een nieuwe API-sleutel en trek de oude in. De oude staat in git-commit `da308ba`. Verifieer daarna het afzenderadres of het domein.
- [ ] **Authentication:**
  - Zet de providers E-mail/wachtwoord, Google en Apple aan.
  - Zet het OAuth-toestemmingsscherm op "Gentle".
- [ ] **Cloud Messaging:** upload de APNs-sleutel van Apple.

### Stripe (web)

- [ ] Maak het product "Gentle Premium" met een maandprijs en een jaarprijs. Noteer de price-id's.
- [ ] Sla de instellingen van de Customer Portal één keer op.
- [ ] Optioneel: geef Stripe Tax een vestigingsadres en zet daarna `STRIPE_AUTOMATIC_TAX=true`.

### Apple Developer en App Store Connect

- [ ] **App ID-capabilities:** Sign in with Apple, Push Notifications en Associated Domains.
- [ ] **Sleutels:**
  - Een In-App Purchase-sleutel (Users and Access → Integrations). Noteer de key id en de issuer id.
  - Een Sign in with Apple-sleutel. Noteer de key id en het team id.
- [ ] **App-record:**
  - Maak een abonnementsgroep met `gentle_premium_monthly` en `gentle_premium_yearly`.
  - Teken de Paid Apps-overeenkomst.
  - Noteer het **Apple ID** van de app (een getal) voor `APPLE_APP_ID`.
- [ ] **Mail aan "Verberg mijn e-mail"-gebruikers:** registreer het afzenderdomein bij "Sign in with Apple for Email Communication".

### Google Play

- [ ] **Upload-sleutel:** maak een upload-keystore en `android/key.properties`.
- [ ] **Abonnementen:** maak `gentle_premium_monthly` en `gentle_premium_yearly`, met hun basisabonnementen.
- [ ] **Pub/Sub:**
  - Maak het topic `projects/sleeptales-4bac2/topics/play-rtdn`.
  - Geef `google-play-developer-notifications@system.gserviceaccount.com` daarop de rol Publisher.
  - Zet in Play Console de real-time developer notifications op dat topic.
- [ ] **Toegang voor de functions:**
  - Nodig het service-account van de functions uit, met "Financiële gegevens bekijken" en "Bestellingen beheren".
  - Zet de Android Publisher API aan.
- [ ] **SHA-fingerprints:**
  - Zet de SHA-1 van Play App Signing en die van de upload-sleutel in Firebase.
  - Zet de SHA-256 in `web/.well-known/assetlinks.json`. Daar staan nu nog twee oude.

## Stap 3 — Backend live (jij zet de secrets, daarna kan Claude deployen)

1. Zet de secrets. Elk commando vraagt om de waarde:
   ```bash
   firebase functions:secrets:set SENDGRID_API_KEY --project sleeptales-4bac2
   ```
   ```bash
   firebase functions:secrets:set STRIPE_SECRET_KEY --project sleeptales-4bac2
   ```
   ```bash
   firebase functions:secrets:set STRIPE_WEBHOOK_SECRET --project sleeptales-4bac2
   ```
   ```bash
   firebase functions:secrets:set APPLE_IAP_KEY --project sleeptales-4bac2
   ```
   ```bash
   firebase functions:secrets:set APPLE_SIGNIN_KEY --project sleeptales-4bac2
   ```
   Voor `STRIPE_WEBHOOK_SECRET` vul je eerst een placeholder in. De echte waarde bestaat pas als de webhook er is (stap 5).
2. Kopieer `functions/.env.example` naar `functions/.env.sleeptales-4bac2` en vul de id's in die je in stap 2 hebt genoteerd.
3. **Claude** deployt de rules, de indexes, Storage en de functions:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes,storage,functions --project sleeptales-4bac2
   ```
4. **Jij** maakt de eerste admin aan, met een service-account-sleutel:
   ```bash
   GOOGLE_APPLICATION_CREDENTIALS=key.json npm --prefix functions run set-admin -- jij@voorbeeld.nl
   ```

## Stap 4 — Webapp en admin live (Claude)

- Twee Vercel-projecten:

  | Project | Root directory | Opmerking |
  |---|---|---|
  | Webapp | repo-root | Bouwt met `scripts/vercel-build-web.sh` |
  | Admin | `apps/admin` | Geen env-variabelen nodig |

- Daarna zet **jij** beide `*.vercel.app`-adressen bij Firebase Auth → Authorized domains.
- Zodra de webapp-URL vaststaat: `APP_URL` in `functions/.env.sleeptales-4bac2` en in `website/build.py`.

## Stap 5 — Koppelingen naar de backend (jij)

- [ ] **Stripe-webhook:**
  - URL: `https://us-central1-sleeptales-4bac2.cloudfunctions.net/stripeWebhook`.
  - Events: `customer.subscription.created`, `customer.subscription.updated` en `customer.subscription.deleted`.
  - Zet het signing secret in `STRIPE_WEBHOOK_SECRET`. Daarna deployt Claude de functions opnieuw.
- [ ] **Apple Server Notifications v2:** zet `https://us-central1-sleeptales-4bac2.cloudfunctions.net/appleNotifications` voor zowel productie als sandbox.
- [ ] **Universal links:** maak `web/.well-known/apple-app-site-association` met `<TEAMID>.<bundle id>`. Geef Claude het team id, dan maakt Claude het bestand.

## Stap 6 — Content (jij, in de admin)

- [ ] Zet tracks, playlists en pagina's klaar, met Nederlandse titels waar je die wilt.
- [ ] Zet de premium-tracks op premium.
- [ ] Maak een codebatch voor Artazest en geef een testcode aan jezelf.
- [ ] Maak een demo-account voor de App Review en geef het handmatig premium (Onbeperkt).

## Stap 7 — Testen op echte toestellen (jij, Claude helpt)

- [ ] Inloggen met Google en Apple, op iOS en op Android.
- [ ] Een sandbox-aankoop doen, herstellen, wisselen tussen maand en jaar, en opzeggen. Check dat premium meebeweegt.
- [ ] Stripe Checkout en de Customer Portal in testmodus.
- [ ] Een code inwisselen.
- [ ] Een push sturen naar alle, premium en gratis gebruikers, in het Nederlands en het Engels.
- [ ] De audio-bediening op het vergrendelscherm, en offline afspelen.
- [ ] Een account verwijderen, ook met een Apple-relayadres.
- [ ] Een telefoon in het Nederlands: de app moet in het Nederlands starten.
- [ ] Android: draai één keer `flutter build appbundle` op een machine met de Android SDK. Hier is Android nooit gebouwd.

## Stap 8 — Stores indienen (jij)

- [ ] Teksten, screenshots (EN en NL), privacylabels en review notes. Zie [store-listing.md](store-listing.md).
- [ ] **Google Play:** Data safety, de verklaring voor de foreground service (media afspelen) en de content rating.
- [ ] Upload de builds:
  - iOS via Xcode of Transporter. Op deze Mac eerst `sudo xcodebuild -license accept`.
  - Android als appbundle.

## Stap 9 — Lanceerdag

- [ ] **Website:** dit loopt via de andere sessie, zie `website/README.md`.
  - Echt domein en supportadres in `build.py`.
  - Echte prijzen.
  - De `noindex`-header weg.
  - Store-knoppen erop.
  - Juridische teksten nagekeken.
- [ ] **Eigen domein:** koppel het aan de website, de webapp (`app.`) en de admin (`admin.`). Zet het daarna in Firebase Auth, `APP_URL`, `appLinkHost` en `Runner.entitlements`.
- [ ] **Oude webapp `gentle-mu.vercel.app`:** offline halen.

## Later

- **Firebase App Check.** Hiervoor zijn reCAPTCHA Enterprise, App Attest en Play Integrity in de console nodig.
- **Webpush in de webapp.** Hiervoor is een VAPID-sleutel nodig. Push gaat nu alleen naar iOS en Android.
- **FlutterFire-plugins upgraden.** Daarna kan Swift Package Manager weer aan. Nu staat het uit in `pubspec.yaml`, omdat de huidige versies alleen CocoaPods hebben.
- **In de admin:**
  - Volgorde aanpassen door te slepen in plaats van met pijltjes.
  - Een voorbeeld van een pagina.
