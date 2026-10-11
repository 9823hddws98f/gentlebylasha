# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

Flutter app for iOS and Android (also built for web as the customer webapp). The admin webapp and the marketing website are `web`.

## Stack

- App + customer webapp: Flutter (existing code).
- Backend: Firebase project `sleeptales-4bac2` (Auth, Firestore, Storage, Functions, FCM).
- Admin + website: Next.js (TypeScript), hosted on Vercel Hobby.

## Users

- **Listeners**: people who want to fall asleep or unwind. They use the app in bed, at night, often in the dark, with sound as the main medium.
- **Artazest customers**: people who bought an Artazest artwork (acoustic panel) and received a Gentle access code with it. They create an account and enter the code.
- **Admins**: the owner and a small team, all with the same rights. They manage content, users, codes and push messages from a laptop. *(Inferred: usage frequency and device not confirmed.)*

## Product Purpose

Gentle is a sleep and relaxation audio app: sleep stories, guided meditations and calming tracks, organised in playlists and pages. Success means people fall asleep with it and keep coming back; premium is the business model.

## Positioning

Gentle is the owner's own product and is connected to Artazest: Artazest customers get access to Gentle through a unique code. *(Inferred: the exact relationship between the brands is not confirmed.)*

## Operating Context

- Premium comes from a subscription (App Store, Play Store, Stripe on web) or a redeemed access code; all of these land in `subscriptions/{uid}`.
- Access codes are generated in batches in the admin, assigned to a customer email (optionally emailed), and redeemed in the app under Profile → Redeem code.
- Content lives in Firestore collections `tracks`, `playlists`, `pages`, `blocks`; audio and images in Firebase Storage.

## Capabilities and Constraints

- Languages: English (default) and Dutch.
- Code format `GENTLE-XXXX-XXXX`, no 0/O/1/I. Code duration is set per batch (days, or unlimited).
- Hosting cost must stay minimal (Firebase budget alert €10/month).
- Undecided: free trial, which content is free vs premium, prices, domain name.

## Brand Commitments

- Name: Gentle. Logo: `assets/gentle_logo.svg` (script wordmark). Splash tagline: “just close your eyes and listen”.
- Existing app colors in `lib/utils/app_theme.dart`: light primary `#365DCB`, secondary `#A483DB`, tertiary `#F6C000`; dark theme primary `#52B788` on deep navy. *(Not confirmed as the final brand.)*
- Old names “Sleeptales” / “Sleepytales” are retired and must not appear.

## Evidence on Hand

No testimonials, user numbers, reviews or press exist. Do not invent them.

## Product Principles

1. Calm over clever: nothing in the listener experience should be loud or urgent.
2. One premium status everywhere, decided server-side.
3. Admin work should take seconds: issuing a code to a customer is a one-step action.
4. Never trust the client for access or roles.
