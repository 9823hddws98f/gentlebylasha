# Gentle — lanceer-checklist

Stand: 13 oktober 2026. Alles hieronder kan alleen de eigenaar doen: accounts, sleutels, consoles en tests op echte toestellen. De code is klaar voor zover hij zonder die accounts te bouwen en te testen is.

## 0. Eerst, vandaag

1. **Oude functions controleren.** De oude v1-functions uit 2024 (`deleteUser`, `sendEmail`, `onUserCreateOrUpdate`) hadden geen inlogcontrole: iedereen kon elk account verwijderen en mail versturen via jullie SendGrid. Als ze nog draaien, zijn dat open gaten. Ze blokkeren ook de eerste deploy, omdat een v2-functie met dezelfde naam een v1-functie niet kan vervangen.
   ```bash
   firebase login
   firebase functions:list --project sleeptales-4bac2
   firebase functions:delete deleteUser sendEmail onUserCreateOrUpdate --region us-central1 --project sleeptales-4bac2
   ```
2. **SendGrid-sleutel vervangen.** De oude sleutel staat in git-commit `da308ba`. Maak in SendGrid een nieuwe aan en trek de oude in.
3. **Firebase op Blaze** met een budgetalarm van €10 per maand (Google Cloud Console → Billing → Budgets).

## 1. Beslissingen

- **iOS bundle id.** Nu `io.sleeptales.sleeptales`. Bestaat daar al een App Store-record onder jullie account, houd hem dan. Anders kan het een nieuwe id worden; dan ook `APPLE_BUNDLE_ID` en `APPLE_SIGNIN_CLIENT_ID` aanpassen. Android is `com.mezz.gentle`.
- **Code inwisselen op iOS** (App Store-richtlijn 3.1.1). De knop "Heb je een code?" staat in de paywall. Kies:
  - houden, en in de review notes uitleggen dat codes bij een fysieke Artazest-aankoop horen; of
  - op iOS verbergen en klanten laten inwisselen in de webapp.
- **Welke content gratis is en welke premium.** Per track in de admin in te stellen.
- **Domein, supportmailadres en prijzen.** Tot die er zijn draaien de webapp en de website op `*.vercel.app`.
- **Buildnummer.** `pubspec.yaml` staat op `1.1.10+1`. Hebben de bestaande store-records hogere builds, zet het nummer daarboven.

## 2. Firebase

1. **Secrets** (Secret Manager):
   ```bash
   firebase functions:secrets:set SENDGRID_API_KEY
   firebase functions:secrets:set STRIPE_SECRET_KEY
   firebase functions:secrets:set STRIPE_WEBHOOK_SECRET   # eerst een placeholder, zie Stripe
   firebase functions:secrets:set APPLE_IAP_KEY           # inhoud van het .p8-bestand
   firebase functions:secrets:set APPLE_SIGNIN_KEY        # inhoud van het .p8-bestand
   ```
2. **Parameters.** Kopieer `functions/.env.example` naar `functions/.env.sleeptales-4bac2` en vul hem in.
3. **Deployen:**
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes,storage,functions --project sleeptales-4bac2
   ```
4. **Authentication:**
   - Zet de providers E-mail/wachtwoord, Google en Apple aan.
   - Voeg bij Authorized domains toe: de admin, de webapp en later het eigen domein.
   - Zet de openbare projectnaam en het OAuth-toestemmingsscherm op "Gentle". Nu ziet de Google-login op het web `sleeptales-4bac2.firebaseapp.com`.
5. **Eerste admin aanmaken.** Daarna kunnen admins elkaar via de admin-webapp aanmaken.
   ```bash
   GOOGLE_APPLICATION_CREDENTIALS=key.json npm --prefix functions run set-admin -- jij@voorbeeld.nl
   ```
6. **Cloud Messaging.** Upload de APNs-sleutel van Apple, anders komen pushberichten niet aan op iOS.
7. **Rules-tests** draaien lokaal met `npm --prefix functions run test:rules`. Daarvoor is Java nodig (`brew install openjdk@21`).

## 3. Stripe (web)

1. Maak het product "Gentle Premium" met een maandprijs en een jaarprijs. Zet de price-id's in `.env`.
2. **Webhook:**
   - URL: `https://us-central1-sleeptales-4bac2.cloudfunctions.net/stripeWebhook`.
   - Events: `customer.subscription.created`, `customer.subscription.updated` en `customer.subscription.deleted`.
   - Zet het signing secret in `STRIPE_WEBHOOK_SECRET` en deploy de functions opnieuw.
3. Sla de instellingen van de Customer Portal één keer op, anders werkt "Abonnement beheren" niet.
4. Optioneel: geef Stripe Tax een vestigingsadres en zet daarna `STRIPE_AUTOMATIC_TAX=true`.

## 4. Apple

1. **App ID:** zet de capabilities Sign in with Apple, Push Notifications en Associated Domains aan.
2. **App Store Connect:**
   - Een abonnementsgroep met `gentle_premium_monthly` en `gentle_premium_yearly`.
   - De Paid Apps-overeenkomst.
   - Privacy-, support- en EULA-URL's. De pagina's staan al op de website.
   - App Privacy-labels.
   - Review notes over de toegangscodes, plus een demo-account.
3. **In-App Purchase-sleutel** (Users and Access → Integrations): noteer de key id en de issuer id.
4. **Server Notifications v2**, voor productie en sandbox: `https://us-central1-sleeptales-4bac2.cloudfunctions.net/appleNotifications`.
5. **Sign in with Apple-sleutel:** noteer de key id en het team id.
6. **Mail aan "Verberg mijn e-mail"-gebruikers.** Registreer het afzenderdomein van `MAIL_FROM` bij "Sign in with Apple for Email Communication". Anders komt de verwijdercode niet aan bij gebruikers die hun e-mail verbergen, en dat is een afwijzingsreden.
7. **Universal links:**
   - Zet `apple-app-site-association` in `web/.well-known/` met het team id.
   - Pas de host in `ios/Runner/Runner.entitlements` aan als het domein verandert.
8. Voor iOS-builds op deze Mac: `sudo xcodebuild -license accept`.

## 5. Google Play

1. Maak een upload-keystore en `android/key.properties`. Release-builds stoppen nu met een foutmelding als die ontbreekt.
2. **SHA-fingerprints:**
   - Zet de SHA-1 van Play App Signing en die van de upload-sleutel in Firebase (nodig voor Google-login).
   - Controleer de SHA-256 in `web/.well-known/assetlinks.json`. Daar staan nu twee fingerprints van de oude sleutels.
3. Maak de abonnementen `gentle_premium_monthly` en `gentle_premium_yearly` met hun basisabonnementen.
4. **Real-time developer notifications:**
   - Maak in Pub/Sub het topic `projects/sleeptales-4bac2/topics/play-rtdn`.
   - Geef `google-play-developer-notifications@system.gserviceaccount.com` daarop de rol Pub/Sub Publisher.
5. **Toegang voor de functions:**
   - Nodig het service-account van de functions uit in Play Console, met "Financiële gegevens bekijken" en "Bestellingen beheren".
   - Zet de Android Publisher API aan.
6. Vul in: het Data safety-formulier, de verklaring voor de foreground service (media afspelen) en de content rating.

## 6. Vercel

| Project | Root | Opmerking |
|---|---|---|
| Webapp (Flutter web) | repo-root | `vercel.json` bouwt met `scripts/vercel-build-web.sh` (Flutter 3.47.7) |
| Admin | `apps/admin` | geen env-variabelen nodig |
| Website | `website/public` | zie `website/README.md` |

Voeg elk domein ook toe aan Firebase Auth → Authorized domains.

## 7. Testen op echte toestellen

- Inloggen met Google en Apple, op iOS en op Android.
- Een sandbox-aankoop doen, herstellen en opzeggen. Check daarna dat premium aan en weer uit gaat.
- Stripe Checkout en de Customer Portal in testmodus.
- Een code inwisselen: `GENTLE-XXXX-XXXX` uit de admin.
- Een push sturen naar alle, premium en gratis gebruikers, in NL en EN.
- De audio-bediening op het vergrendelscherm.
- Een account verwijderen, ook met een Apple-relayadres ("Verberg mijn e-mail").
- Een telefoon in het Nederlands: de app moet dan in het Nederlands starten.

## 8. Bewust nog niet gebouwd

Kleiner of afhankelijk van keuzes hierboven:

- Handtekeningcontrole (JWS) op Apple Server Notifications. De status wordt altijd opnieuw bij Apple opgevraagd, dus premium valt er niet mee te vervalsen.
- Firebase App Check.
- Downloads per gebruiker scheiden en wissen bij uitloggen.
- In de admin:
  - Slepen in plaats van pijltjes voor de volgorde.
  - Een voorbeeld van een pagina.
  - Opzeggingen in de statistieken.
