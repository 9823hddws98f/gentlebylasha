# Gentle — teksten voor de stores

Dit zijn concepten om in App Store Connect en Play Console te plakken. Lees ze na voordat je ze gebruikt. Er staan bewust geen cijfers, reviews of claims in die we niet kunnen onderbouwen (zie PRODUCT.md).

Prijzen staan nergens in de tekst: die tonen de stores zelf.

## App Store

### Engels (primaire taal)

- **Name** (30): `Gentle: Sleep & Relax`
- **Subtitle** (30): `Sleep stories and calm sounds`
- **Keywords** (100): `sleep,sleep stories,meditation,relax,calm,bedtime,insomnia,mindfulness,rain sounds,white noise`
- **Promotional text** (170): `Close your eyes and listen. Sleep stories, guided meditations and calming sounds to help you unwind at the end of the day.`
- **Support URL:** `https://gentle-website.vercel.app/en/help` (later: eigen domein)
- **Privacy Policy URL:** `https://gentle-website.vercel.app/en/privacy`
- **Terms of Use (EULA):** `https://gentle-website.vercel.app/en/terms`

**Description**

```
Gentle helps you slow down and fall asleep. Put your phone away, close your eyes and listen.

WHAT YOU'LL FIND
• Sleep stories, read slowly and softly
• Guided meditations to let the day go
• Calming sounds for sleep, rest and focus
• Playlists that run from one track to the next

MADE FOR THE NIGHT
• Sleep timer, so the audio fades out on its own
• Download tracks and listen offline
• Keep your favourites close
• Bedtime reminders, if you want them
• Available in English and Dutch

GENTLE PREMIUM
Some tracks are free. Premium unlocks everything, with new stories and meditations added regularly. Choose a monthly or yearly subscription. Bought an Artazest artwork? Enter the code that came with it to unlock Gentle.

Payment is charged to your Apple ID at confirmation of purchase. The subscription renews automatically unless you turn it off at least 24 hours before the end of the current period. You can manage or cancel it in your App Store account settings.

Terms of Use: https://gentle-website.vercel.app/en/terms
Privacy Policy: https://gentle-website.vercel.app/en/privacy
```

### Nederlands

- **Naam** (30): `Gentle: Slapen & Ontspannen`
- **Subtitel** (30): `Slaapverhalen en rustgeluiden`
- **Trefwoorden** (100): `slapen,slaapverhalen,meditatie,ontspannen,rust,inslapen,slapeloosheid,mindfulness,regen,geluiden`
- **Promotietekst** (170): `Doe je ogen dicht en luister. Slaapverhalen, begeleide meditaties en rustgevende geluiden om aan het eind van de dag tot rust te komen.`
- **Support-URL:** `https://gentle-website.vercel.app/help`
- **Privacybeleid:** `https://gentle-website.vercel.app/privacy`
- **Gebruiksvoorwaarden:** `https://gentle-website.vercel.app/voorwaarden`

**Beschrijving**

```
Gentle helpt je om rustig te worden en in slaap te vallen. Leg je telefoon weg, doe je ogen dicht en luister.

WAT JE VINDT
• Slaapverhalen, langzaam en zacht voorgelezen
• Begeleide meditaties om de dag los te laten
• Rustgevende geluiden voor slaap, rust en focus
• Playlists die vanzelf doorspelen

GEMAAKT VOOR DE NACHT
• Slaaptimer: het geluid stopt vanzelf
• Download tracks en luister offline
• Bewaar je favorieten
• Herinneringen voor het slapengaan, als je dat wilt
• In het Nederlands en Engels

GENTLE PREMIUM
Een deel van de tracks is gratis. Met Premium luister je alles, en er komen regelmatig nieuwe verhalen en meditaties bij. Kies een maand- of jaarabonnement. Een kunstwerk van Artazest gekocht? Vul de code in die je erbij kreeg en Gentle gaat voor je open.

De betaling wordt bij bevestiging van de aankoop afgeschreven via je Apple ID. Het abonnement wordt automatisch verlengd, tenzij je het minstens 24 uur voor het einde van de periode uitzet. Je beheert of stopt het in de instellingen van je App Store-account.

Gebruiksvoorwaarden: https://gentle-website.vercel.app/voorwaarden
Privacybeleid: https://gentle-website.vercel.app/privacy
```

### App Review — notes (Engels)

```
Gentle is a sleep and relaxation audio app. Some tracks are free; premium tracks
need a subscription (monthly or yearly, auto-renewing, in-app purchase).

Demo account (has premium through a manual grant):
  email: <demo-account e-mail>
  password: <wachtwoord>

Access codes: Gentle is a sister brand of Artazest, which sells physical acoustic
art panels. Buyers receive a printed/emailed code with their physical purchase
that unlocks Gentle premium (Profile → Redeem code). Codes are not sold in or
outside the app as a digital good; they come with a physical product.

Account deletion: Profile → Delete account (a confirmation code is emailed first).
Sign in with Apple: tokens are revoked when the account is deleted.
```

Maak het demo-account in de app aan en geef het in de admin handmatig premium (Gebruikers → Handmatig premium geven → Onbeperkt).

### App Privacy (privacylabels)

Alles is **gekoppeld aan de gebruiker** en **niet voor tracking**:

| Gegevenstype | Waarvoor |
|---|---|
| Contactgegevens → E-mailadres, Naam | App-functionaliteit (account) |
| Gebruikersinhoud → Foto's | App-functionaliteit (profielfoto, optioneel) |
| Identificatoren → Gebruikers-ID | App-functionaliteit |
| Identificatoren → Apparaat-ID | Analyse (Firebase Analytics), App-functionaliteit (pushberichten) |
| Aankopen → Aankoopgeschiedenis | App-functionaliteit (premium) |
| Gebruiksgegevens → Productinteractie | Analyse, App-functionaliteit (afspeeltellingen, favorieten) |

Controleer de Firebase-onderdelen met de uitleg van Google: firebase.google.com/docs/ios/app-store-data-collection.

## Google Play

### Engels

- **App name** (30): `Gentle: Sleep & Relax`
- **Short description** (80): `Sleep stories, guided meditations and calming sounds to help you fall asleep.`
- **Full description:** dezelfde tekst als de App Store-beschrijving. Vervang daarin de alinea over Apple ID door:

```
Subscriptions renew automatically until you cancel them in Google Play (Payments & subscriptions → Subscriptions).
```

### Nederlands

- **App-naam** (30): `Gentle: Slapen & Ontspannen`
- **Korte beschrijving** (80): `Slaapverhalen, meditaties en rustgevende geluiden om makkelijker in te slapen.`
- **Volledige beschrijving:** dezelfde tekst als bij de App Store. Vervang de alinea over Apple ID door:

```
Abonnementen worden automatisch verlengd tot je ze stopt in Google Play (Betalingen en abonnementen → Abonnementen).
```

### Data safety

- **Verzameld:** e-mailadres, naam, gebruikers-ID, foto's (optioneel), aankoopgeschiedenis, app-interacties, apparaat-ID.
- **Gedeeld met derden:** nee. Firebase, Stripe en Google Play zijn verwerkers, geen ontvangers.
- **Versleuteld onderweg:** ja.
- **Gebruiker kan verwijdering vragen:** ja, in de app (Profiel → Account verwijderen).
- **URL voor accountverwijdering:** een pagina die uitlegt hoe dat in de app gaat. Bijvoorbeeld `https://gentle-website.vercel.app/help`. Zorg dat daar een kopje "Account verwijderen" staat.

### Overige formulieren

- **Foreground service:** type media playback. Doel: het geluid speelt verder met het scherm uit, met bediening in de melding.
- **Content rating:** geen geweld, geen gebruikerscontact, geen aankopen buiten de store.
- **Doelgroep:** 18+ (geen kinderapp).
