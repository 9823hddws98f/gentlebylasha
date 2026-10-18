import { createHash } from "node:crypto";
import { VerificationException, VerificationStatus } from "@apple/app-store-server-library";
import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { defineBoolean } from "firebase-functions/params";
import { CallableRequest, HttpsError, onCall, onRequest } from "firebase-functions/v2/https";
import { onMessagePublished } from "firebase-functions/v2/pubsub";
import { z } from "zod";

import {
  accountToken,
  bestGrant,
  computeEntitlement,
  readSources,
  setSourceGrant,
  type Source,
  type SourceGrant,
} from "./entitlement.js";
import { APPLE_IAP_KEY, appleSubscription, InvalidNotification, verifyAppleNotification } from "./stores/apple.js";
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
// Enable once Stripe Tax has an origin address (Stripe dashboard → Tax).
const STRIPE_AUTOMATIC_TAX = defineBoolean("STRIPE_AUTOMATIC_TAX", { default: false });
const MAX_VERIFY_PER_HOUR = 20;

function requireAuth(req: CallableRequest): string {
  if (!req.auth) throw new HttpsError("unauthenticated", "Sign in first.");
  return req.auth.uid;
}

const userExists = (uid: string) =>
  getAuth()
    .getUser(uid)
    .then(() => true)
    .catch(() => false);

// ---------------------------------------------------------------------------
// Store purchases: one store_links doc per purchase, holding its owner and grant
// ---------------------------------------------------------------------------

const linkRef = (source: Source, id: string) =>
  db().collection("store_links").doc(`${source}_${createHash("sha256").update(id).digest("hex").slice(0, 40)}`);

async function linkedUid(source: Source, id: string): Promise<string | undefined> {
  return (await linkRef(source, id).get()).data()?.uid;
}

/** Premium from a store = the best grant over all of the user's purchases there. */
async function recomputeSource(uid: string, source: Source) {
  const links = await db().collection("store_links").where("uid", "==", uid).where("source", "==", source).get();
  const grants = links.docs.map((doc): SourceGrant => {
    const g = doc.data().grant;
    return { active: g?.active === true, expiresAt: g?.expiresAt instanceof Timestamp ? g.expiresAt.toDate() : null };
  });
  await setSourceGrant(uid, source, bestGrant(grants, new Date()));
}

/**
 * Stores a purchase's grant for `uid`. A purchase belongs to one account; it can
 * only move when the previous owner's account no longer exists.
 */
async function recordPurchase(source: Source, purchaseId: string, uid: string, grant: SourceGrant) {
  const ref = linkRef(source, purchaseId);
  // In a transaction, so two accounts verifying the same purchase can't both claim it.
  await db().runTransaction(async (tx) => {
    const owner = (await tx.get(ref)).data()?.uid as string | undefined;
    if (owner && owner !== uid && (await userExists(owner))) {
      throw new HttpsError("already-exists", "linked-to-other-account");
    }
    tx.set(ref, {
      uid,
      source,
      purchaseId,
      grant: { active: grant.active, expiresAt: grant.expiresAt ? Timestamp.fromDate(grant.expiresAt) : null },
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
  await recomputeSource(uid, source);
}

async function takeVerifyAttempt(uid: string) {
  const ref = db().collection("purchase_attempts").doc(uid);
  const now = Date.now();
  await db().runTransaction(async (tx) => {
    const d = (await tx.get(ref)).data();
    const start = d?.windowStart instanceof Timestamp ? d.windowStart.toMillis() : 0;
    if (now - start > 3_600_000) return tx.set(ref, { count: 1, windowStart: Timestamp.fromMillis(now) });
    if ((d?.count ?? 0) >= MAX_VERIFY_PER_HOUR) throw new HttpsError("resource-exhausted", "too-many-attempts");
    tx.update(ref, { count: FieldValue.increment(1) });
  });
}

/** Called by the app after a purchase or restore. The server asks the store; the app is not trusted. */
export const verifyPurchase = onCall({ secrets: [APPLE_IAP_KEY] }, async (req) => {
  const uid = requireAuth(req);
  const input = z
    .object({ platform: z.enum(["ios", "android"]), purchaseId: z.string().min(1).max(4096) })
    .safeParse(req.data);
  if (!input.success) throw new HttpsError("invalid-argument", "Invalid purchase.");
  const { platform, purchaseId } = input.data;
  await takeVerifyAttempt(uid);

  try {
    if (platform === "ios") {
      const result = await appleSubscription(purchaseId);
      // Purchases made by this app carry the account's token; a different one belongs to someone else.
      if (result.appAccountToken && result.appAccountToken !== accountToken(uid)) {
        throw new HttpsError("already-exists", "linked-to-other-account");
      }
      await recordPurchase("apple", result.originalTransactionId, uid, result.grant);
    } else {
      const result = await googleSubscription(purchaseId);
      if (result.obfuscatedAccountId && result.obfuscatedAccountId !== accountToken(uid)) {
        throw new HttpsError("already-exists", "linked-to-other-account");
      }
      if (result.linkedPurchaseToken) await retireReplacedPurchase(uid, result.linkedPurchaseToken);
      await recordPurchase("google", purchaseId, uid, result.grant);
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
    const notification = await verifyAppleNotification(String(req.body?.signedPayload ?? ""));
    if (!notification.verified) {
      logger.warn("appleNotifications: production notification not verified; set APPLE_APP_ID");
    }
    // The payload is only used to find the subscription; its status comes from Apple's API.
    const { originalTransactionId } = notification;
    const uid = originalTransactionId && (await linkedUid("apple", originalTransactionId));
    if (originalTransactionId && uid) {
      const { grant } = await appleSubscription(originalTransactionId);
      await recordPurchase("apple", originalTransactionId, uid, grant);
    }
    res.sendStatus(200);
  } catch (e) {
    if (e instanceof InvalidNotification) {
      logger.warn("appleNotifications: rejected", { reason: e.message });
      res.sendStatus(400);
      return;
    }
    // VerificationException has no message of its own; its status and cause say what happened.
    const error = e instanceof VerificationException ? `${VerificationStatus[e.status]}: ${e.cause ?? ""}` : String(e);
    logger.error("appleNotifications failed", { error });
    res.sendStatus(500); // Apple retries
  }
});

/** Google Play real-time developer notifications (Pub/Sub). Retried on failure. */
export const googleRtdn = onMessagePublished({ topic: PLAY_RTDN_TOPIC, retry: true }, async (event) => {
  const token = (event.data.message.json as { subscriptionNotification?: { purchaseToken?: string } })
    ?.subscriptionNotification?.purchaseToken;
  if (!token) return;
  let result;
  try {
    result = await googleSubscription(token);
  } catch (e) {
    // A token Google doesn't know (anymore) won't get better by retrying for a week.
    const status = (e as { status?: number; code?: number }).status ?? (e as { code?: number }).code;
    if (status === 400 || status === 404 || status === 410) {
      logger.warn("googleRtdn: unknown purchase token", { status });
      return;
    }
    throw e;
  }
  // A plan change or resubscribe creates a new token that points at the old one.
  const uid =
    (await linkedUid("google", token)) ??
    (result.linkedPurchaseToken ? await linkedUid("google", result.linkedPurchaseToken) : undefined);
  if (!uid) return;
  if (result.linkedPurchaseToken) await retireReplacedPurchase(uid, result.linkedPurchaseToken);
  await recordPurchase("google", token, uid, result.grant);
});

/**
 * A plan change (monthly ↔ yearly) gives a new Play purchase that replaces the
 * old one. The old link would otherwise keep granting premium until its old
 * expiry date, even after the new subscription is cancelled.
 */
async function retireReplacedPurchase(uid: string, oldToken: string) {
  const ref = linkRef("google", oldToken);
  if ((await ref.get()).data()?.uid === uid) await ref.delete();
}

// ---------------------------------------------------------------------------
// Stripe (web)
// ---------------------------------------------------------------------------

async function stripeCustomerId(uid: string, email: string | undefined): Promise<string> {
  const ref = db().collection("subscriptions").doc(uid);
  const existing = (await ref.get()).data()?.stripeCustomerId;
  if (existing) return existing;
  // Idempotency key: parallel checkouts get the same customer back from Stripe.
  const customer = await stripe().customers.create({ email, metadata: { uid } }, { idempotencyKey: `customer-${uid}` });
  await ref.set({ stripeCustomerId: customer.id }, { merge: true });
  return customer.id;
}

export const createCheckoutSession = onCall({ secrets: [STRIPE_SECRET_KEY] }, async (req) => {
  const uid = requireAuth(req);
  const plan = z.object({ plan: z.enum(["monthly", "yearly"]) }).safeParse(req.data);
  if (!plan.success) throw new HttpsError("invalid-argument", "Unknown plan.");
  const price = plan.data.plan === "monthly" ? STRIPE_PRICE_MONTHLY.value() : STRIPE_PRICE_YEARLY.value();
  if (!price) throw new HttpsError("failed-precondition", "Stripe prices are not configured.");

  const sources = readSources((await db().collection("subscriptions").doc(uid).get()).data());
  const paying = (["stripe", "apple", "google"] as const).find(
    (s) => computeEntitlement({ [s]: sources[s] ?? { active: false, expiresAt: null } }, new Date()).active,
  );
  if (paying) throw new HttpsError("failed-precondition", `already-subscribed:${paying}`);

  const session = await stripe().checkout.sessions.create({
    mode: "subscription",
    customer: await stripeCustomerId(uid, req.auth?.token.email),
    line_items: [{ price, quantity: 1 }],
    client_reference_id: uid,
    subscription_data: { metadata: { uid } },
    allow_promotion_codes: true,
    ...(STRIPE_AUTOMATIC_TAX.value()
      ? { automatic_tax: { enabled: true }, customer_update: { address: "auto" as const } }
      : {}),
    success_url: `${APP_URL.value()}/?checkout=success`,
    cancel_url: `${APP_URL.value()}/?checkout=cancelled`,
  });
  return { url: session.url };
});

export interface WebPrice {
  /** In the currency's smallest unit (cents). */
  amount: number;
  currency: string;
}

let priceCache: { at: number; prices: Record<"monthly" | "yearly", WebPrice | null> } | undefined;

/** Prices of the web plans, so the paywall can show them before checkout. Cached for an hour. */
export const webPrices = onCall({ secrets: [STRIPE_SECRET_KEY] }, async (req) => {
  requireAuth(req);
  if (priceCache && Date.now() - priceCache.at < 3_600_000) return priceCache.prices;
  const load = async (id: string): Promise<WebPrice | null> => {
    if (!id) return null;
    const price = await stripe().prices.retrieve(id);
    return price.unit_amount === null ? null : { amount: price.unit_amount, currency: price.currency };
  };
  try {
    const [monthly, yearly] = await Promise.all([load(STRIPE_PRICE_MONTHLY.value()), load(STRIPE_PRICE_YEARLY.value())]);
    priceCache = { at: Date.now(), prices: { monthly, yearly } };
    return priceCache.prices;
  } catch (e) {
    // The paywall still works without prices; Stripe Checkout shows them too.
    logger.error("webPrices failed", { error: String(e) });
    return { monthly: null, yearly: null };
  }
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
      const sub = await stripe().subscriptions.retrieve(sent.id, { expand: ["customer"] });
      const customer = typeof sub.customer === "object" && !("deleted" in sub.customer) ? sub.customer : null;
      const uid = sub.metadata.uid || customer?.metadata.uid;
      if (!uid) logger.warn("Stripe subscription without uid", { subscription: sub.id });
      // Ignore accounts that were deleted meanwhile; don't recreate their data.
      else if (await userExists(uid)) {
        // The best of all the customer's subscriptions, so a late event about an
        // old cancelled one can't take away premium that a newer one gives.
        const all = customer
          ? (await stripe().subscriptions.list({ customer: customer.id, status: "all", limit: 100 })).data
          : [sub];
        await setSourceGrant(uid, "stripe", bestGrant(all.map(subscriptionGrant), new Date()));
        // The account may have been deleted while this ran (deleting cancels Stripe,
        // which triggers this webhook); don't leave its subscription doc behind.
        if (!(await userExists(uid))) await db().collection("subscriptions").doc(uid).delete();
      }
    } catch (e) {
      logger.error("stripeWebhook failed", { event: event.id, error: String(e) });
      res.sendStatus(500); // Stripe retries
      return;
    }
  }
  res.sendStatus(200);
});

/**
 * Called when an account is deleted: stops Stripe billing and frees the user's
 * store purchases so they can be restored on a new account. App Store and
 * Google Play subscriptions can only be cancelled by the user in the store.
 */
export async function releaseBilling(uid: string) {
  const customer = (await db().collection("subscriptions").doc(uid).get()).data()?.stripeCustomerId;
  if (customer && STRIPE_SECRET_KEY.value()) {
    const subs = await stripe().subscriptions.list({ customer, status: "all", limit: 20 });
    for (const sub of subs.data) {
      if (!["canceled", "incomplete_expired"].includes(sub.status)) await stripe().subscriptions.cancel(sub.id);
    }
  }
  const links = await db().collection("store_links").where("uid", "==", uid).get();
  const batch = db().batch();
  links.docs.forEach((d) => batch.delete(d.ref));
  await batch.commit();
}
