import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
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
import { accessCodeEmail, deletionCodeEmail, languageOf, welcomeEmail } from "./emails.js";
import { sendMail, SENDGRID_API_KEY } from "./mail.js";
import { APPLE_SIGNIN_KEY, revokeAppleToken, storeAppleRefreshToken } from "./apple-signin.js";
import { releaseBilling } from "./purchases.js";
import { pushResult, sendPush } from "./push.js";
import { computeStats, STATS_VERSION } from "./stats.js";
import { parseDownloadUrl, rotateDownloadUrl } from "./track-audio.js";
import { APP_URL, STRIPE_SECRET_KEY } from "./stores/stripe.js";

initializeApp();
setGlobalOptions({ region: "us-central1", maxInstances: 10 });

const db = getFirestore();

function requireAuth(req: CallableRequest): string {
  if (!req.auth) throw new HttpsError("unauthenticated", "Sign in first.");
  return req.auth.uid;
}

/**
 * Checks the claim on the account itself, not only in the ID token, so an
 * admin whose rights were taken away can't keep using an older token. (The
 * security rules only see the token; that window closes when it expires.)
 */
async function requireAdmin(req: CallableRequest): Promise<string> {
  const uid = requireAuth(req);
  if (req.auth?.token.admin !== true) throw new HttpsError("permission-denied", "Admins only.");
  const user = await getAuth().getUser(uid);
  if (user.customClaims?.admin !== true) throw new HttpsError("permission-denied", "Admins only.");
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
  const language = languageOf((await db.collection("users").doc(uid).get()).get("language"));
  await sendMail(email, deletionCodeEmail(language, code));
  return { success: true };
});

/** Deletes the caller's own account after checking the emailed code. */
export const deleteUser = onCall({ secrets: [STRIPE_SECRET_KEY, APPLE_SIGNIN_KEY] }, async (req) => {
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

  await deleteAccount(uid);
  logger.info("User deleted", { uid });
  return { success: true };
});

/** Removes an account with everything that belongs to it. */
async function deleteAccount(uid: string) {
  await releaseBilling(uid);
  await revokeAppleToken(uid).catch((e) => logger.error("revokeAppleToken failed", { uid, error: String(e) }));
  const batch = db.batch();
  for (const collection of [
    "users",
    "favorites",
    "favorites_playlists",
    "subscriptions",
    "deletion_codes",
    "code_attempts",
    "purchase_attempts",
    "apple_tokens",
  ]) {
    batch.delete(db.collection(collection).doc(uid));
  }
  await batch.commit();
  // activity_log entries carry the user's name and email.
  const activity = await db.collection("activity_log").where("userId", "==", uid).get();
  const writer = db.bulkWriter();
  const deletes = activity.docs.map((d) => writer.delete(d.ref));
  await writer.close();
  await Promise.all(deletes);
  await getStorage()
    .bucket()
    .deleteFiles({ prefix: `users/${uid}/` })
    .catch((e) => logger.error("Deleting profile files failed", { uid, error: String(e) }));
  await getAuth().deleteUser(uid);
  // Cancelling Stripe above fires a webhook that may have rewritten the
  // subscription before the Auth user was gone; the webhook cleans up after
  // itself when it finishes later.
  await db.collection("subscriptions").doc(uid).delete();
}

/** After Sign in with Apple: keep a revocable token (Apple requires revoking it on account deletion). */
export const linkAppleSignIn = onCall({ secrets: [APPLE_SIGNIN_KEY] }, async (req) => {
  const uid = requireAuth(req);
  const { authorizationCode } = parse(z.object({ authorizationCode: z.string().min(1).max(2000) }), req.data);
  const user = await getAuth().getUser(uid);
  if (!user.providerData.some((p) => p.providerId === "apple.com")) {
    throw new HttpsError("failed-precondition", "Not an Apple account.");
  }
  try {
    await storeAppleRefreshToken(uid, authorizationCode);
  } catch (e) {
    logger.error("linkAppleSignIn failed", { uid, error: String(e) });
    throw new HttpsError("unavailable", "apple-token-failed");
  }
  return { success: true };
});

export const onUserCreated = onDocumentCreated(
  { document: "users/{userId}", secrets: [SENDGRID_API_KEY] },
  async (event) => {
    const user = event.data?.data();
    // The address comes from Auth, not from the client-written profile, so the
    // profile can't be used to send mail to someone else.
    const email = await getAuth()
      .getUser(event.params.userId)
      .then((u) => u.email)
      .catch(() => undefined);
    if (!email) return;
    try {
      await sendMail(email, welcomeEmail(languageOf(user?.language), String(user?.name ?? ""), APP_URL.value()));
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
  const adminUid = await requireAdmin(req);
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
  const adminUid = await requireAdmin(req);
  const input = parse(
    z.object({
      email: z.string().trim().toLowerCase().email(),
      // The callable SDK sends empty optional fields as null.
      code: z.string().nullish(),
      batchId: z.string().nullish(),
      note: z.string().max(500).nullish(),
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
    try {
      await sendMail(input.email, accessCodeEmail(input.language, code.code, code.durationDays, APP_URL.value()));
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
  const adminUid = await requireAdmin(req);
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
  const adminUid = await requireAdmin(req);
  const { trackId, premium, url: newAudio } = parse(
    z.object({ trackId: z.string().min(1), premium: z.boolean(), url: z.string().url().optional() }),
    req.data,
  );
  const trackRef = db.collection("tracks").doc(trackId);
  const audioRef = db.collection("track_audio").doc(trackId);
  const [track, audio] = await Promise.all([trackRef.get(), audioRef.get()]);
  if (!track.exists) throw new HttpsError("not-found", "Track niet gevonden.");

  if (premium) {
    // New audio for a premium track comes straight here, never via the public doc.
    const url: string = newAudio || track.data()?.trackUrl || audio.data()?.url;
    if (!url) throw new HttpsError("failed-precondition", "Track heeft geen audio.");
    if (!parseDownloadUrl(url)) {
      throw new HttpsError(
        "failed-precondition",
        "Deze audio staat niet in Firebase Storage en kan niet beschermd worden. Upload de audio opnieuw.",
      );
    }
    const newUrl = await rotateDownloadUrl(url);
    await audioRef.set({ url: newUrl });
    await trackRef.update({ premium: true, trackUrl: "" });
  } else {
    const url: string | undefined = newAudio || audio.data()?.url;
    if (url) await trackRef.update({ premium: false, trackUrl: url });
    else await trackRef.update({ premium: false });
    await audioRef.delete();
  }
  await logAdminAction(adminUid, "setTrackPremium", { trackId, premium });
  return { success: true };
});

/**
 * Admin: delete a track with its protected audio, play count and uploaded
 * files. Refuses while a playlist or page row still uses it.
 */
export const adminDeleteTrack = onCall(async (req) => {
  const adminUid = await requireAdmin(req);
  const { trackId } = parse(z.object({ trackId: z.string().min(1) }), req.data);
  const [playlists, rows, heroes] = await Promise.all([
    db.collection("playlists").where("trackIds", "array-contains", trackId).get(),
    db.collection("blocks").where("trackIds", "array-contains", trackId).get(),
    db.collection("blocks").where("trackId", "==", trackId).get(),
  ]);
  const usedIn = [
    ...playlists.docs.map((d) => `playlist “${d.data().title ?? d.id}”`),
    ...[...rows.docs, ...heroes.docs].map((d) => `rij “${d.data().title || d.id}”`),
  ];
  if (usedIn.length) {
    throw new HttpsError("failed-precondition", `Track wordt nog gebruikt in ${usedIn.join(", ")}. Haal hem daar eerst weg.`);
  }

  const trackRef = db.collection("tracks").doc(trackId);
  const audioRef = db.collection("track_audio").doc(trackId);
  const [track, audio] = await Promise.all([trackRef.get(), audioRef.get()]);
  const t = track.data();
  const urls = [t?.trackUrl, t?.thumbnail?.url, t?.imageBackground?.url, audio.data()?.url];

  const batch = db.batch();
  batch.delete(trackRef);
  batch.delete(audioRef);
  batch.delete(db.collection("track_stats").doc(trackId));
  await batch.commit();
  await deleteStorageFiles(urls);
  await logAdminAction(adminUid, "deleteTrack", { trackId });
  return { success: true };
});

/** Deletes the Storage files behind download URLs; other URLs are left alone. */
async function deleteStorageFiles(urls: unknown[]) {
  for (const url of urls) {
    const parsed = typeof url === "string" ? parseDownloadUrl(url) : null;
    if (!parsed) continue;
    await getStorage()
      .bucket(parsed.bucket)
      .file(parsed.path)
      .delete({ ignoreNotFound: true })
      .catch((e) => logger.warn("Deleting file failed", { path: parsed.path, error: String(e) }));
  }
}

/** Admin: give or take away premium by hand (gifts, support cases). */
export const adminSetManualPremium = onCall(async (req) => {
  const adminUid = await requireAdmin(req);
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
  const adminUid = await requireAdmin(req);
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
  // A time in the past is a mistake, not a request to send to everyone right now.
  if (sendAt && sendAt.getTime() < Date.now() - 5 * 60_000) {
    throw new HttpsError("invalid-argument", "Het gekozen tijdstip ligt in het verleden.");
  }
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
  const failed = scheduled ? [] : await sendPush(job);
  if (!scheduled) await ref.update({ ...pushResult(failed), sentAt: FieldValue.serverTimestamp() });
  await logAdminAction(adminUid, "sendPush", { job: ref.id, audience: job.audience, scheduled, failed });
  if (failed.length === 2) throw new HttpsError("internal", "Versturen mislukt.");
  if (failed.length) throw new HttpsError("internal", `Niet verstuurd in: ${failed.join(", ")}. De rest is wel verstuurd.`);
  return { id: ref.id, scheduled };
});

/** Admin: cancel a scheduled push that hasn't gone out yet. */
export const adminCancelPush = onCall(async (req) => {
  const adminUid = await requireAdmin(req);
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

/** Admin: dashboard numbers, cached for an hour unless a refresh is asked for. */
export const adminStats = onCall({ timeoutSeconds: 120 }, async (req) => {
  await requireAdmin(req);
  const { refresh } = parse(z.object({ refresh: z.boolean().default(false) }), req.data ?? {});
  const ref = db.collection("admin_cache").doc("stats");
  const cached = (await ref.get()).data();
  const fresh = cached?.version === STATS_VERSION && Date.now() - Date.parse(cached.generatedAt) < 60 * 60_000;
  if (!refresh && fresh) return cached;
  const stats = await computeStats();
  await ref.set(stats);
  return stats;
});

async function getUserOrThrow(uid: string) {
  return getAuth()
    .getUser(uid)
    .catch(() => {
      throw new HttpsError("not-found", "Gebruiker niet gevonden.");
    });
}

/**
 * Admin: look up an account by email or uid in Firebase Auth, so accounts
 * without a profile document can be found too.
 */
export const adminFindUser = onCall(async (req) => {
  await requireAdmin(req);
  const { query } = parse(z.object({ query: z.string().trim().min(1).max(200) }), req.data);
  const user = await (query.includes("@") ? getAuth().getUserByEmail(query.toLowerCase()) : getAuth().getUser(query))
    .catch(() => null);
  if (!user) return { user: null };
  const profile = (await db.collection("users").doc(user.uid).get()).data();
  return {
    user: {
      uid: user.uid,
      email: user.email ?? "",
      name: user.displayName || String(profile?.name ?? ""),
      createdAt: new Date(user.metadata.creationTime).toISOString(),
      lastSignInAt: user.metadata.lastSignInTime ? new Date(user.metadata.lastSignInTime).toISOString() : null,
      providers: user.providerData.map((p) => p.providerId),
      admin: user.customClaims?.admin === true,
      disabled: user.disabled,
    },
  };
});

/** Admin: email addresses for uids (the activity log stores uids). Unknown uids are left out. */
export const adminUserEmails = onCall(async (req) => {
  await requireAdmin(req);
  const { uids } = parse(z.object({ uids: z.array(z.string().min(1).max(128)).max(100) }), req.data);
  if (!uids.length) return {};
  const { users } = await getAuth().getUsers([...new Set(uids)].map((uid) => ({ uid })));
  return Object.fromEntries(users.map((u) => [u.uid, u.email ?? ""]));
});

/** Admin: grant or revoke admin rights. */
export const adminSetAdmin = onCall(async (req) => {
  const adminUid = await requireAdmin(req);
  const { uid, admin } = parse(z.object({ uid: z.string().min(1), admin: z.boolean() }), req.data);
  const user = await getUserOrThrow(uid);
  if (user.uid === adminUid && !admin) throw new HttpsError("failed-precondition", "Je kunt jezelf geen admin-rechten afnemen.");
  await getAuth().setCustomUserClaims(user.uid, { ...user.customClaims, admin });
  // No new tokens with the old claim; requireAdmin already rejects the current one.
  if (!admin) await getAuth().revokeRefreshTokens(user.uid);
  await logAdminAction(adminUid, "setAdmin", { uid, email: user.email ?? null, admin });
  return { success: true };
});

/** Admin: delete someone's account, the same way users delete their own. */
export const adminDeleteUser = onCall({ secrets: [STRIPE_SECRET_KEY, APPLE_SIGNIN_KEY] }, async (req) => {
  const adminUid = await requireAdmin(req);
  const { uid } = parse(z.object({ uid: z.string().min(1) }), req.data);
  if (uid === adminUid) throw new HttpsError("failed-precondition", "Je kunt je eigen account hier niet verwijderen.");
  const user = await getUserOrThrow(uid);
  if (user.customClaims?.admin === true) {
    throw new HttpsError("failed-precondition", "Dit is een admin. Neem eerst de admin-rechten af.");
  }
  await deleteAccount(uid);
  await logAdminAction(adminUid, "deleteUser", { uid, email: user.email ?? null });
  return { success: true };
});

export {
  appleNotifications,
  createCheckoutSession,
  createPortalSession,
  googleRtdn,
  stripeWebhook,
  verifyPurchase,
  webPrices,
} from "./purchases.js";

export { sendScheduledPushes, syncWebPushTopics } from "./push.js";
