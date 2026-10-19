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
- [ ] **Cloud Messaging:**
  - Upload de APNs-sleutel van Apple.
  - Maak onder "Web configuration" een sleutelpaar aan. Die waarde gaat als `WEB_PUSH_VAPID_KEY` naar Vercel (stap 4), voor push in de webapp.

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
  | Webapp | repo-root | Bouwt met `scripts/vercel-build-web.sh`. Env: `WEB_PUSH_VAPID_KEY`, en later `SITE_URL`/`APP_URL` en App Check (stap 10) |
  | Admin | `apps/admin` | Geen env-variabelen nodig, tot App Check (stap 10) |

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
- [ ] **Controleer de content.** Doe dit eerst, en daarna nog eens na grote wijzigingen. Het script leest alleen en schrijft niets.
  ```bash
  GOOGLE_APPLICATION_CREDENTIALS=key.json npm --prefix functions run check-content
  ```
  Bij "fout" kan de app een document niet lezen. Eén fout pagina- of rij-document maakt de hele app leeg, één foute track maakt zijn rij leeg. Oude content uit 2024 is nog nooit zo gecontroleerd.

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

## Stap 10 — Firebase App Check (na de lancering)

Met App Check zien Firestore, Storage, Auth en de functions of een verzoek van een echte Gentle-build komt. De code staat klaar, maar staat uit. Zolang je de stappen hieronder niet doet, verandert er niets.

1. **Apps registreren (jij).** Firebase Console → App Check → Apps.
   - [ ] **Android** (`com.mezz.gentle`): kies Play Integrity.
     - Koppel in Play Console → App-integriteit de Play Integrity API aan het Cloud-project `sleeptales-4bac2`.
     - Zet de SHA-256 van het Play App Signing-certificaat in Firebase (Projectinstellingen → de Android-app). Test je met builds die met de upload-sleutel zijn getekend, zet dan ook die SHA-256 erbij.
   - [ ] **iOS** (`io.sleeptales.sleeptales`): registreer App Attest én DeviceCheck. Toestellen zonder App Attest vallen terug op DeviceCheck.
     - App Attest vraagt alleen het team id.
     - DeviceCheck vraagt een sleutel: Apple Developer → Keys → een nieuwe sleutel met DeviceCheck. Upload het `.p8`-bestand, met de key id en het team id.
     - Zet bij de App ID (Identifiers) de capability **App Attest** aan. Laat het Claude weten: Claude zet dan `com.apple.developer.devicecheck.appattest-environment` op `production` in `ios/Runner/Runner.entitlements`.
   - [ ] **Web**: kies reCAPTCHA Enterprise. De webapp en de admin zijn samen één Firebase-web-app, dus één sleutel.
     - Google Cloud Console → Security → reCAPTCHA: zet de API aan en maak een sleutel van het type Website, zonder vinkje-uitdaging (score-based).
     - Zet de domeinen van de webapp en de admin bij die sleutel: de twee `*.vercel.app`-adressen, en later `app.` en `admin.` van het eigen domein.
     - Plak de site key in App Check.
2. **Vercel (jij).** Zet de variabelen alleen voor de omgeving Production. Preview-adressen staan niet bij de reCAPTCHA-sleutel.
   - [ ] Webapp: `APP_CHECK=true` en `RECAPTCHA_SITE_KEY=<site key>`.
   - [ ] Admin: `NEXT_PUBLIC_RECAPTCHA_SITE_KEY=<dezelfde site key>`.
   - [ ] Deploy beide opnieuw.
3. **Store-builds met App Check (Claude).** Claude bouwt iOS en Android met `--dart-define=APP_CHECK=true`, bijvoorbeeld `flutter build appbundle --dart-define=APP_CHECK=true`. Jij dient die builds in.
   - **Eigen testtoestellen** gebruiken in debug een debug-token. De app zegt in de log waar dat token staat: Android-logcat `DebugAppCheckProvider`, de Xcode-console `Firebase App Check Debug Token`, de browserconsole `App Check debug token`. Voeg het één keer toe onder App Check → Apps → ⋮ → Debugtokens beheren.
   - Met `--dart-define=APP_CHECK_DEBUG_TOKEN=<token>` blijft hetzelfde token werken na een herinstallatie.
   - De admin onder `next dev` print zijn debug-token ook in de browserconsole.
   - De emulators gebruiken nooit App Check.
4. **Meekijken (jij).** App Check → APIs toont per product hoeveel verzoeken geverifieerd zijn.
   - Wacht tot bij Cloud Firestore, Cloud Storage en Authentication bijna alles "Verified" is.
   - Oude app-versies zonder App Check tellen als "Outdated client". Die werken niet meer zodra je afdwingt. Wacht dus tot de meeste gebruikers de nieuwe versie hebben.
5. **Afdwingen (jij).** App Check → APIs → per product **Enforce**: eerst Cloud Firestore, dan Cloud Storage, dan Authentication.
   - Het duurt tot 15 minuten voordat het werkt.
   - Gaat er iets mis, zet het dan op dezelfde plek weer uit.
6. **Callable functions (Claude).** Die dwing je af in de code, niet in de console: `enforceAppCheck: true` per callable in `functions/src`, daarna een deploy. `stripeWebhook` en `appleNotifications` blijven zonder App Check, want Stripe en Apple roepen die aan, niet de app.

reCAPTCHA Enterprise kost geld boven een gratis maandquotum. Het budgetalarm uit stap 2 waarschuwt je op tijd.

## Later

- **FlutterFire 5 (Firebase iOS SDK 13, Android BoM 35).** Dit vraagt Android `minSdk` 24 in plaats van 23, dus Android 6 valt dan af. De app zit nu op de 4.x-lijn.
- **audio_session via Swift Package Manager.** Blijft nu bewust onder 0.1.24 en dus op CocoaPods, zodat de Podfile de microfooncode eruit laat. Via SPM kan dat alleen met `AUDIO_SESSION_MICROPHONE=0` als omgevingsvariabele bij elke build. Dit moet opgelost zijn voordat Flutter CocoaPods laat vallen.
