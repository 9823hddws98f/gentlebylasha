import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { setGlobalOptions } from "firebase-functions/v2";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { CallableRequest, HttpsError, onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";
import { z } from "zod";

import {
  type AccessCode,
  generateCode,
  mergeEntitlement,
  normalizeCode,
  planRedemption,
} from "./codes.js";
import {
  checkDeletionCode,
  DELETION_CODE_TTL_MS,
  hashCode,
  newDeletionCode,
  type StoredDeletionCode,
} from "./deletion.js";
import { computeEntitlement, entitlementFields, readSources, setSourceGrant } from "./entitlement.js";
import { escapeHtml, sendMail, SENDGRID_API_KEY } from "./mail.js";
import { releaseBilling } from "./purchases.js";
import { sendPush } from "./push.js";
import { computeStats } from "./stats.js";
import { rotateDownloadUrl } from "./track-audio.js";
import { STRIPE_SECRET_KEY } from "./stores/stripe.js";

initializeApp();
setGlobalOptions({ region: "us-central1", maxInstances: 10 });

const db = getFirestore();

function requireAuth(req: CallableRequest): string {
  if (!req.auth) throw new HttpsError("unauthenticated", "Sign in first.");
  return req.auth.uid;
}

function requireAdmin(req: CallableRequest): string {
  const uid = requireAuth(req);
  if (req.auth?.token.admin !== true) throw new HttpsError("permission-denied", "Admins only.");
  return uid;
}

function parse<T>(schema: z.ZodType<T>, data: unknown): T {
  const result = schema.safeParse(data);
  if (!result.success) throw new HttpsError("invalid-argument", result.error.issues[0].message);
  return result.data;
}

async function logAdminAction(adminUid: string, action: string, payload: Record<string, unknown>) {
  await db.collection("admin_log").add({ adminUid, action, payload, at: FieldValue.serverTimestamp() });
}

function toDate(value: unknown): Date | undefined {
  return value instanceof Timestamp ? value.toDate() : undefined;
}

// ---------------------------------------------------------------------------
// Account
// ---------------------------------------------------------------------------

/** Emails a one-time code that the user must enter to delete their account. */
export const requestAccountDeletion = onCall({ secrets: [SENDGRID_API_KEY] }, async (req) => {
  const uid = requireAuth(req);
  const email = req.auth?.token.email;
  if (!email) throw new HttpsError("failed-precondition", "no-email");

  const ref = db.collection("deletion_codes").doc(uid);
  const code = newDeletionCode();
  const now = new Date();
  await db.runTransaction(async (tx) => {
    const previous = (await tx.get(ref)).data();
    const sentAt = toDate(previous?.sentAt);
    if (sentAt && now.getTime() - sentAt.getTime() < 60_000) {
      throw new HttpsError("resource-exhausted", "wait-before-resend");
    }
    // Failed attempts and resends count per day, so resending can't reset the guess limit.
    const dayStart = toDate(previous?.dayStart);
    const sameDay = dayStart && now.getTime() - dayStart.getTime() < 86_400_000;
    const sends = sameDay ? (previous?.sends ?? 0) : 0;
    if (sends >= 5) throw new HttpsError("resource-exhausted", "wait-before-resend");
    tx.set(ref, {
      codeHash: hashCode(uid, code),
      expiresAt: Timestamp.fromMillis(now.getTime() + DELETION_CODE_TTL_MS),
      sentAt: Timestamp.fromDate(now),
      dayStart: sameDay ? previous!.dayStart : Timestamp.fromDate(now),
      sends: sends + 1,
      attempts: sameDay ? (previous?.attempts ?? 0) : 0,
    });
  });
  await sendMail(
    email,
    "Delete your Gentle account",
    `<p>You asked to delete your Gentle account. Enter this code in the app to confirm:</p>
     <p style="font-size:24px;font-weight:bold;letter-spacing:4px">${code}</p>
     <p>The code is valid for 15 minutes. Didn't ask for this? Ignore this email.</p>`,
  );
  return { success: true };
});

/** Deletes the caller's own account after checking the emailed code. */
export const deleteUser = onCall({ secrets: [STRIPE_SECRET_KEY] }, async (req) => {
  const uid = requireAuth(req);
  const { code } = parse(z.object({ code: z.string().max(20) }), req.data);
  const ref = db.collection("deletion_codes").doc(uid);
  // Check and count in one transaction so parallel guesses can't skip the limit.
  const check = await db.runTransaction(async (tx) => {
    const data = (await tx.get(ref)).data();
    const stored: StoredDeletionCode | undefined = data && {
      codeHash: data.codeHash,
      expiresAt: toDate(data.expiresAt) ?? new Date(0),
      attempts: data.attempts ?? 0,
    };
    const result = checkDeletionCode(stored, uid, code, new Date());
    if (result === "wrong-code") tx.update(ref, { attempts: FieldValue.increment(1) });
    return result;
  });
  if (check !== "ok") throw new HttpsError("failed-precondition", check);

  await releaseBilling(uid);
  const batch = db.batch();
  for (const collection of [
    "users",
    "favorites",
    "favorites_playlists",
    "subscriptions",
    "deletion_codes",
    "code_attempts",
    "purchase_attempts",
  ]) {
    batch.delete(db.collection(collection).doc(uid));
  }
  await batch.commit();
  await getAuth().deleteUser(uid);
  logger.info("User deleted", { uid });
  return { success: true };
});

export const onUserCreated = onDocumentCreated(
  { document: "users/{userId}", secrets: [SENDGRID_API_KEY] },
  async (event) => {
    const user = event.data?.data();
    if (!user?.email) return;
    const name = escapeHtml(String(user.name ?? "").trim()) || "there";
    try {
      await sendMail(
        user.email,
        "Welcome to Gentle",
        `<h1>Welcome, ${name}!</h1><p>Thank you for joining Gentle. Sleep well.</p>`,
      );
    } catch (e) {
      logger.error("Welcome mail failed", e);
    }
  },
);

// ---------------------------------------------------------------------------
// Access codes (Artazest customers)
// ---------------------------------------------------------------------------

const MAX_ATTEMPTS_PER_HOUR = 10;

/** Counts an attempt atomically; throws once the hourly limit is reached. */
async function takeAttempt(uid: string, now: Date) {
  const ref = db.collection("code_attempts").doc(uid);
  await db.runTransaction(async (tx) => {
    const data = (await tx.get(ref)).data();
    const windowStart = toDate(data?.windowStart);
    const inWindow = windowStart && now.getTime() - windowStart.getTime() < 3_600_000;
    if (!inWindow) {
      tx.set(ref, { count: 1, windowStart: Timestamp.fromDate(now) });
      return;
    }
    if ((data?.count ?? 0) >= MAX_ATTEMPTS_PER_HOUR) {
      throw new HttpsError("resource-exhausted", "too-many-attempts");
    }
    tx.update(ref, { count: FieldValue.increment(1) });
  });
}

/** A signed-in user redeems a code and gets premium access. */
export const redeemCode = onCall(async (req) => {
  const uid = requireAuth(req);
  const { code: input } = parse(z.object({ code: z.string().max(40) }), req.data);
  const now = new Date();

  await takeAttempt(uid, now);

  const normalized = normalizeCode(input);
  if (!normalized) throw new HttpsError("failed-precondition", "not-found");

  const codeRef = db.collection("access_codes").doc(normalized);
  const subRef = db.collection("subscriptions").doc(uid);

  const result = await db.runTransaction(async (tx) => {
    const [codeSnap, subSnap] = await Promise.all([tx.get(codeRef), tx.get(subRef)]);
    const raw = codeSnap.data();
    const code: AccessCode | undefined = raw && {
      ...(raw as AccessCode),
      createdAt: toDate(raw.createdAt) ?? now,
    };
    const sources = readSources(subSnap.data());

    const plan = planRedemption(code, uid, now);
    if (!plan.ok) return plan;
    // Redeeming the same code twice changes nothing; report the access the user has.
    if (plan.alreadyRedeemed) return { ...plan, expiresAt: computeEntitlement(sources, now).expiresAt };

    // A second code extends the code grant; other sources are kept as they are.
    sources.code = { active: true, expiresAt: mergeEntitlement(sources.code, plan.expiresAt, now) };

    tx.update(codeRef, {
      status: "redeemed",
      redeemedBy: uid,
      redeemedAt: Timestamp.fromDate(now),
    });
    tx.set(subRef, entitlementFields(sources, now, { code: normalized }), { merge: true });
    return { ...plan, expiresAt: computeEntitlement(sources, now).expiresAt };
  });

  if (!result.ok) throw new HttpsError("failed-precondition", result.reason);
  logger.info("Code redeemed", { uid, code: normalized });
  return { success: true, expiresAt: result.expiresAt?.toISOString() ?? null };
});

/** Admin: create a batch of unique codes. */
export const adminGenerateCodes = onCall({ timeoutSeconds: 300 }, async (req) => {
  const adminUid = requireAdmin(req);
  const { count, durationDays, batchName } = parse(
    z.object({
      count: z.number().int().min(1).max(1000),
      durationDays: z.number().int().min(1).max(3650).nullable(),
      batchName: z.string().trim().min(1).max(100),
    }),
    req.data,
  );

  // Batch doc first, so codes never point at a batch that doesn't exist.
  const batchRef = db.collection("code_batches").doc();
  const createdAt = FieldValue.serverTimestamp();
  await batchRef.set({ name: batchName, count: 0, durationDays, createdAt, createdBy: adminUid });

  const codes = new Set<string>();
  while (codes.size < count) codes.add(generateCode());

  // `create` fails if a code already exists, so a collision can never overwrite a code.
  const writer = db.bulkWriter();
  writer.onWriteError(() => false);
  const writes = [...codes].map((code) =>
    writer.create(db.collection("access_codes").doc(code), {
      code,
      batchId: batchRef.id,
      batchName,
      durationDays,
      status: "available",
      createdAt,
    }),
  );
  await writer.close();
  const created = (await Promise.allSettled(writes)).filter((r) => r.status === "fulfilled").length;

  await batchRef.update({ count: created });
  await logAdminAction(adminUid, "generateCodes", { batchId: batchRef.id, count: created });
  return { batchId: batchRef.id, created };
});

/**
 * Admin: assign a code to a customer email. Uses the given code, or picks the
 * next available one from the batch (or any batch). Optionally emails it.
 */
export const adminAssignCode = onCall({ secrets: [SENDGRID_API_KEY] }, async (req) => {
  const adminUid = requireAdmin(req);
  const input = parse(
    z.object({
      email: z.string().trim().toLowerCase().email(),
      code: z.string().optional(),
      batchId: z.string().optional(),
      note: z.string().max(500).optional(),
      sendEmail: z.boolean().default(false),
      language: z.enum(["en", "nl"]).default("nl"),
    }),
    req.data,
  );

  let fixedRef: FirebaseFirestore.DocumentReference | undefined;
  if (input.code) {
    const normalized = normalizeCode(input.code);
    if (!normalized) throw new HttpsError("invalid-argument", "Invalid code.");
    fixedRef = db.collection("access_codes").doc(normalized);
  }
  let available: FirebaseFirestore.Query = db.collection("access_codes").where("status", "==", "available");
  if (input.batchId) available = available.where("batchId", "==", input.batchId);

  const code = await db.runTransaction(async (tx) => {
    // Picking inside the transaction means two admins can't grab the same code.
    let ref = fixedRef;
    if (!ref) {
      const snap = await tx.get(available.limit(1));
      if (snap.empty) throw new HttpsError("not-found", "Geen vrije codes meer. Maak een nieuwe batch aan.");
      ref = snap.docs[0].ref;
    }
    const data = (await tx.get(ref)).data();
    if (!data) throw new HttpsError("not-found", "Code niet gevonden.");
    if (data.status !== "available") throw new HttpsError("failed-precondition", "Deze code is al gebruikt of uitgegeven.");
    tx.update(ref, {
      status: "assigned",
      assignedEmail: input.email,
      assignedNote: input.note ?? null,
      assignedAt: FieldValue.serverTimestamp(),
      assignedBy: adminUid,
    });
    return data as AccessCode;
  });

  let emailed = false;
  if (input.sendEmail) {
    const nl = input.language === "nl";
    const access = code.durationDays === null
      ? (nl ? "onbeperkt" : "unlimited")
      : nl ? `${code.durationDays} dagen` : `${code.durationDays} days`;
    try {
      await sendMail(
        input.email,
        nl ? "Je Gentle-code" : "Your Gentle code",
        nl
          ? `<p>Bedankt voor je bestelling bij Artazest. Hiermee krijg je ${access} toegang tot Gentle:</p>
             <p style="font-size:22px;font-weight:bold;letter-spacing:2px">${code.code}</p>
             <p>Download de Gentle-app, maak een account en vul de code in onder Profiel &rarr; Code invoeren.</p>`
          : `<p>Thank you for your Artazest order. This gives you ${access} access to Gentle:</p>
             <p style="font-size:22px;font-weight:bold;letter-spacing:2px">${code.code}</p>
             <p>Download the Gentle app, create an account and enter the code under Profile &rarr; Redeem code.</p>`,
      );
      emailed = true;
    } catch (e) {
      // The code stays assigned; the admin can copy it and send it by hand.
      logger.error("Code mail failed", { code: code.code, error: String(e) });
    }
  }

  await logAdminAction(adminUid, "assignCode", { code: code.code, email: input.email, emailed });
  return { code: code.code, emailed };
});

/** Admin: disable a code that has not been redeemed yet. */
export const adminDisableCode = onCall(async (req) => {
  const adminUid = requireAdmin(req);
  const { code: input } = parse(z.object({ code: z.string() }), req.data);
  const normalized = normalizeCode(input);
  if (!normalized) throw new HttpsError("invalid-argument", "Invalid code.");
  const ref = db.collection("access_codes").doc(normalized);
  await db.runTransaction(async (tx) => {
    const data = (await tx.get(ref)).data();
    if (!data) throw new HttpsError("not-found", "Code not found.");
    if (data.status === "redeemed") throw new HttpsError("failed-precondition", "Code is already redeemed.");
    tx.update(ref, { status: "disabled" });
  });
  await logAdminAction(adminUid, "disableCode", { code: normalized });
  return { success: true };
});

/**
 * Admin: make a track premium or free. A premium track's audio URL moves to
 * track_audio/{id} (premium users only) and gets a new token, so the URL that
 * was readable in tracks/{id} stops working.
 */
export const adminSetTrackPremium = onCall(async (req) => {
  const adminUid = requireAdmin(req);
  const { trackId, premium } = parse(z.object({ trackId: z.string().min(1), premium: z.boolean() }), req.data);
  const trackRef = db.collection("tracks").doc(trackId);
  const audioRef = db.collection("track_audio").doc(trackId);
  const [track, audio] = await Promise.all([trackRef.get(), audioRef.get()]);
  if (!track.exists) throw new HttpsError("not-found", "Track niet gevonden.");

  if (premium) {
    const url: string = track.data()?.trackUrl || audio.data()?.url;
    if (!url) throw new HttpsError("failed-precondition", "Track heeft geen audio.");
    const newUrl = await rotateDownloadUrl(url);
    await audioRef.set({ url: newUrl });
    await trackRef.update({ premium: true, trackUrl: "" });
  } else {
    const url: string | undefined = audio.data()?.url;
    if (url) await trackRef.update({ premium: false, trackUrl: url });
    else await trackRef.update({ premium: false });
    await audioRef.delete();
  }
  await logAdminAction(adminUid, "setTrackPremium", { trackId, premium });
  return { success: true };
});

/** Admin: give or take away premium by hand (gifts, support cases). */
export const adminSetManualPremium = onCall(async (req) => {
  const adminUid = requireAdmin(req);
  const { uid, active, expiresAt } = parse(
    z.object({ uid: z.string().min(1), active: z.boolean(), expiresAt: z.string().datetime().nullable() }),
    req.data,
  );
  await getAuth().getUser(uid).catch(() => {
    throw new HttpsError("not-found", "Gebruiker niet gevonden.");
  });
  await setSourceGrant(uid, "manual", { active, expiresAt: expiresAt ? new Date(expiresAt) : null });
  await logAdminAction(adminUid, "setManualPremium", { uid, active, expiresAt });
  return { success: true };
});

/** Admin: send a push now, or schedule it (sendScheduledPushes sends it later). */
export const adminSendPush = onCall(async (req) => {
  const adminUid = requireAdmin(req);
  const text = z.string().trim().min(1).max(200);
  const job = parse(
    z.object({
      title: z.object({ en: text, nl: text }),
      body: z.object({ en: z.string().trim().min(1).max(500), nl: z.string().trim().min(1).max(500) }),
      audience: z.enum(["all", "premium", "free"]),
      sendAt: z.string().datetime().nullable(),
    }),
    req.data,
  );
  const sendAt = job.sendAt ? new Date(job.sendAt) : null;
  const scheduled = sendAt !== null && sendAt.getTime() > Date.now() + 60_000;
  const ref = db.collection("push_jobs").doc();
  await ref.set({
    title: job.title,
    body: job.body,
    audience: job.audience,
    sendAt: Timestamp.fromDate(sendAt ?? new Date()),
    status: scheduled ? "scheduled" : "sending",
    createdBy: adminUid,
    createdAt: FieldValue.serverTimestamp(),
  });
  if (!scheduled) {
    try {
      await sendPush(job);
      await ref.update({ status: "sent", sentAt: FieldValue.serverTimestamp() });
    } catch (e) {
      await ref.update({ status: "failed", error: String(e).slice(0, 500) });
      throw new HttpsError("internal", "Versturen mislukt.");
    }
  }
  await logAdminAction(adminUid, "sendPush", { job: ref.id, audience: job.audience, scheduled });
  return { id: ref.id, scheduled };
});

/** Admin: cancel a scheduled push that hasn't gone out yet. */
export const adminCancelPush = onCall(async (req) => {
  const adminUid = requireAdmin(req);
  const { id } = parse(z.object({ id: z.string().min(1) }), req.data);
  const ref = db.collection("push_jobs").doc(id);
  await db.runTransaction(async (tx) => {
    if ((await tx.get(ref)).data()?.status !== "scheduled") {
      throw new HttpsError("failed-precondition", "Dit bericht is al verstuurd.");
    }
    tx.update(ref, { status: "cancelled" });
  });
  await logAdminAction(adminUid, "cancelPush", { job: id });
  return { success: true };
});

/** Admin: dashboard numbers, cached for 15 minutes unless a refresh is asked for. */
export const adminStats = onCall({ timeoutSeconds: 120 }, async (req) => {
  requireAdmin(req);
  const { refresh } = parse(z.object({ refresh: z.boolean().default(false) }), req.data ?? {});
  const ref = db.collection("admin_cache").doc("stats");
  const cached = (await ref.get()).data();
  if (!refresh && cached && Date.now() - Date.parse(cached.generatedAt) < 15 * 60_000) return cached;
  const stats = await computeStats();
  await ref.set(stats);
  return stats;
});

/** Admin: grant or revoke admin rights by email. */
export const adminSetAdmin = onCall(async (req) => {
  const adminUid = requireAdmin(req);
  const { email, admin } = parse(z.object({ email: z.string().email(), admin: z.boolean() }), req.data);
  const user = await getAuth().getUserByEmail(email).catch(() => {
    throw new HttpsError("not-found", "No account with that email.");
  });
  if (user.uid === adminUid && !admin) throw new HttpsError("failed-precondition", "You can't remove yourself.");
  await getAuth().setCustomUserClaims(user.uid, { ...user.customClaims, admin });
  await logAdminAction(adminUid, "setAdmin", { email, admin });
  return { success: true };
});

export {
  appleNotifications,
  createCheckoutSession,
  createPortalSession,
  googleRtdn,
  stripeWebhook,
  verifyPurchase,
} from "./purchases.js";

export { sendScheduledPushes } from "./push.js";
