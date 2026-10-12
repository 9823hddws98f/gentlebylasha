import { createHash } from "node:crypto";
import { getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { CallableRequest, HttpsError, onCall, onRequest } from "firebase-functions/v2/https";
import { onMessagePublished } from "firebase-functions/v2/pubsub";
import { z } from "zod";

import { computeEntitlement, readSources, setSourceGrant, type Source } from "./entitlement.js";
import { APPLE_IAP_KEY, appleNotificationTransactionId, appleSubscription } from "./stores/apple.js";
import { googleSubscription } from "./stores/google.js";
import {
  APP_URL,
  stripe,
  STRIPE_PRICE_MONTHLY,
  STRIPE_PRICE_YEARLY,
  STRIPE_SECRET_KEY,
  STRIPE_WEBHOOK_SECRET,
  subscriptionGrant,
} from "./stores/stripe.js";

const db = () => getFirestore();
// Pub/Sub topic that Play Console publishes real-time developer notifications to.
const PLAY_RTDN_TOPIC = "play-rtdn";

function requireAuth(req: CallableRequest): string {
  if (!req.auth) throw new HttpsError("unauthenticated", "Sign in first.");
  return req.auth.uid;
}

/** One store purchase belongs to one account; remembered so renewals find the user. */
const linkRef = (source: Source, id: string) =>
  db().collection("store_links").doc(`${source}_${createHash("sha256").update(id).digest("hex").slice(0, 40)}`);

async function claimLink(source: Source, id: string, uid: string) {
  const ref = linkRef(source, id);
  await db().runTransaction(async (tx) => {
    const owner = (await tx.get(ref)).data()?.uid;
    if (owner && owner !== uid) throw new HttpsError("already-exists", "linked-to-other-account");
    if (!owner) tx.set(ref, { uid, source, purchaseId: id });
  });
}

async function linkedUid(source: Source, id: string): Promise<string | undefined> {
  return (await linkRef(source, id).get()).data()?.uid;
}

// ---------------------------------------------------------------------------
// App Store / Google Play
// ---------------------------------------------------------------------------

/** Called by the app after a purchase or restore. The server asks the store; the app is not trusted. */
export const verifyPurchase = onCall({ secrets: [APPLE_IAP_KEY] }, async (req) => {
  const uid = requireAuth(req);
  const input = z
    .object({ platform: z.enum(["ios", "android"]), purchaseId: z.string().min(1).max(4096) })
    .safeParse(req.data);
  if (!input.success) throw new HttpsError("invalid-argument", "Invalid purchase.");
  const { platform, purchaseId } = input.data;

  try {
    if (platform === "ios") {
      const { originalTransactionId, grant } = await appleSubscription(purchaseId);
      await claimLink("apple", originalTransactionId, uid);
      await setSourceGrant(uid, "apple", grant);
    } else {
      const { grant } = await googleSubscription(purchaseId);
      await claimLink("google", purchaseId, uid);
      await setSourceGrant(uid, "google", grant);
    }
  } catch (e) {
    if (e instanceof HttpsError) throw e;
    logger.error("verifyPurchase failed", { uid, platform, error: String(e) });
    throw new HttpsError("unavailable", "verification-failed");
  }

  const e = computeEntitlement(readSources((await db().collection("subscriptions").doc(uid).get()).data()), new Date());
  return { active: e.active, expiresAt: e.expiresAt?.toISOString() ?? null };
});

/** App Store Server Notifications v2: renewals, expiries, refunds. */
export const appleNotifications = onRequest({ secrets: [APPLE_IAP_KEY] }, async (req, res) => {
  try {
    // The payload is only used to find the subscription; its status comes from Apple's API.
    const originalTransactionId = appleNotificationTransactionId(String(req.body?.signedPayload ?? ""));
    const uid = originalTransactionId && (await linkedUid("apple", originalTransactionId));
    if (originalTransactionId && uid) {
      const { grant } = await appleSubscription(originalTransactionId);
      await setSourceGrant(uid, "apple", grant);
    }
    res.sendStatus(200);
  } catch (e) {
    logger.error("appleNotifications failed", String(e));
    res.sendStatus(500); // Apple retries
  }
});

/** Google Play real-time developer notifications (Pub/Sub). */
export const googleRtdn = onMessagePublished(PLAY_RTDN_TOPIC, async (event) => {
  const token = (event.data.message.json as { subscriptionNotification?: { purchaseToken?: string } })
    ?.subscriptionNotification?.purchaseToken;
  if (!token) return;
  const uid = await linkedUid("google", token);
  if (!uid) return;
  const { grant } = await googleSubscription(token);
  await setSourceGrant(uid, "google", grant);
});

// ---------------------------------------------------------------------------
// Stripe (web)
// ---------------------------------------------------------------------------

async function stripeCustomerId(uid: string, email: string | undefined): Promise<string> {
  const ref = db().collection("subscriptions").doc(uid);
  const existing = (await ref.get()).data()?.stripeCustomerId;
  if (existing) return existing;
  const customer = await stripe().customers.create({ email, metadata: { uid } });
  await ref.set({ stripeCustomerId: customer.id }, { merge: true });
  return customer.id;
}

export const createCheckoutSession = onCall({ secrets: [STRIPE_SECRET_KEY] }, async (req) => {
  const uid = requireAuth(req);
  const plan = z.object({ plan: z.enum(["monthly", "yearly"]) }).safeParse(req.data);
  if (!plan.success) throw new HttpsError("invalid-argument", "Unknown plan.");
  const price = plan.data.plan === "monthly" ? STRIPE_PRICE_MONTHLY.value() : STRIPE_PRICE_YEARLY.value();
  if (!price) throw new HttpsError("failed-precondition", "Stripe prices are not configured.");

  const session = await stripe().checkout.sessions.create({
    mode: "subscription",
    customer: await stripeCustomerId(uid, req.auth?.token.email),
    line_items: [{ price, quantity: 1 }],
    client_reference_id: uid,
    subscription_data: { metadata: { uid } },
    allow_promotion_codes: true,
    automatic_tax: { enabled: true },
    customer_update: { address: "auto" },
    success_url: `${APP_URL.value()}/?checkout=success`,
    cancel_url: `${APP_URL.value()}/?checkout=cancelled`,
  });
  return { url: session.url };
});

/** Stripe's customer portal: change plan, update card, cancel. */
export const createPortalSession = onCall({ secrets: [STRIPE_SECRET_KEY] }, async (req) => {
  const uid = requireAuth(req);
  const customer = (await db().collection("subscriptions").doc(uid).get()).data()?.stripeCustomerId;
  if (!customer) throw new HttpsError("failed-precondition", "no-stripe-customer");
  const session = await stripe().billingPortal.sessions.create({ customer, return_url: APP_URL.value() });
  return { url: session.url };
});

export const stripeWebhook = onRequest({ secrets: [STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET] }, async (req, res) => {
  let event;
  try {
    event = stripe().webhooks.constructEvent(
      req.rawBody,
      String(req.headers["stripe-signature"] ?? ""),
      STRIPE_WEBHOOK_SECRET.value(),
    );
  } catch {
    res.sendStatus(400);
    return;
  }

  if (event.type.startsWith("customer.subscription.")) {
    const sent = event.data.object as { id: string };
    try {
      // Events can arrive out of order; always use the subscription's current state.
      const sub = await stripe().subscriptions.retrieve(sent.id);
      const uid = sub.metadata.uid;
      if (uid) await setSourceGrant(uid, "stripe", subscriptionGrant(sub));
    } catch (e) {
      logger.error("stripeWebhook failed", { event: event.id, error: String(e) });
      res.sendStatus(500); // Stripe retries
      return;
    }
  }
  res.sendStatus(200);
});
