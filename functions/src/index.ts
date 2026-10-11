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
  type Entitlement,
  generateCode,
  mergeEntitlement,
  normalizeCode,
  planRedemption,
} from "./codes.js";
import { escapeHtml, sendMail, SENDGRID_API_KEY } from "./mail.js";

initializeApp();
setGlobalOptions({ region: "europe-west1", maxInstances: 10 });

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

/** Deletes the caller's own account. Ignores any uid sent by the client. */
export const deleteUser = onCall(async (req) => {
  const uid = requireAuth(req);
  const batch = db.batch();
  batch.delete(db.collection("users").doc(uid));
  batch.delete(db.collection("favorites").doc(uid));
  batch.delete(db.collection("favorites_playlists").doc(uid));
  await batch.commit();
  await getAuth().deleteUser(uid);
  logger.info("User deleted", { uid });
  return { success: true };
});

/**
 * Kept for the app's account-deletion mail. Only sends to the caller's own
 * verified address, so it can no longer be used as an open relay.
 */
export const sendEmail = onCall({ secrets: [SENDGRID_API_KEY] }, async (req) => {
  requireAuth(req);
  const { to, subject, htmlContent } = parse(
    z.object({ to: z.string().email(), subject: z.string().max(200), htmlContent: z.string().max(5000) }),
    req.data,
  );
  const ownEmail = req.auth?.token.email;
  if (!ownEmail || ownEmail.toLowerCase() !== to.toLowerCase()) {
    throw new HttpsError("permission-denied", "You can only email yourself.");
  }
  await sendMail(to, subject, htmlContent);
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

const MAX_FAILED_ATTEMPTS_PER_HOUR = 10;

/** A signed-in user redeems a code and gets premium access. */
export const redeemCode = onCall(async (req) => {
  const uid = requireAuth(req);
  const { code: input } = parse(z.object({ code: z.string().max(40) }), req.data);
  const now = new Date();

  const attemptsRef = db.collection("code_attempts").doc(uid);
  const attempts = (await attemptsRef.get()).data();
  const windowStart = toDate(attempts?.windowStart);
  const inWindow = windowStart && now.getTime() - windowStart.getTime() < 3_600_000;
  if (inWindow && (attempts?.count ?? 0) >= MAX_FAILED_ATTEMPTS_PER_HOUR) {
    throw new HttpsError("resource-exhausted", "too-many-attempts");
  }

  const recordFailure = async (reason: string) => {
    await attemptsRef.set(
      inWindow
        ? { count: FieldValue.increment(1) }
        : { count: 1, windowStart: Timestamp.fromDate(now) },
      { merge: true },
    );
    throw new HttpsError("failed-precondition", reason);
  };

  const normalized = normalizeCode(input);
  if (!normalized) return recordFailure("not-found");

  const codeRef = db.collection("access_codes").doc(normalized);
  const subRef = db.collection("subscriptions").doc(uid);

  const result = await db.runTransaction(async (tx) => {
    const [codeSnap, subSnap] = await Promise.all([tx.get(codeRef), tx.get(subRef)]);
    const raw = codeSnap.data();
    const code: AccessCode | undefined = raw && {
      ...(raw as AccessCode),
      createdAt: toDate(raw.createdAt) ?? now,
    };
    const plan = planRedemption(code, uid, now);
    if (!plan.ok || plan.alreadyRedeemed) return plan;

    const sub = subSnap.data();
    const current: Entitlement | undefined = sub && {
      active: sub.active === true,
      expiresAt: sub.expiresAt === null ? null : (toDate(sub.expiresAt) ?? new Date(0)),
    };
    const expiresAt = mergeEntitlement(current, plan.expiresAt, now);

    tx.update(codeRef, {
      status: "redeemed",
      redeemedBy: uid,
      redeemedAt: Timestamp.fromDate(now),
    });
    tx.set(
      subRef,
      {
        active: true,
        source: "code",
        code: normalized,
        expiresAt: expiresAt ? Timestamp.fromDate(expiresAt) : null,
        updatedAt: Timestamp.fromDate(now),
      },
      { merge: true },
    );
    return { ...plan, expiresAt };
  });

  if (!result.ok) return recordFailure(result.reason);
  logger.info("Code redeemed", { uid, code: normalized });
  return { success: true, expiresAt: result.expiresAt?.toISOString() ?? null };
});

/** Admin: create a batch of unique codes. */
export const adminGenerateCodes = onCall(async (req) => {
  const adminUid = requireAdmin(req);
  const { count, durationDays, batchName } = parse(
    z.object({
      count: z.number().int().min(1).max(1000),
      durationDays: z.number().int().min(1).max(3650).nullable(),
      batchName: z.string().trim().min(1).max(100),
    }),
    req.data,
  );

  const batchRef = db.collection("code_batches").doc();
  const createdAt = FieldValue.serverTimestamp();
  const codes = new Set<string>();
  while (codes.size < count) codes.add(generateCode());

  // `create` fails if a code already exists, so a collision can never overwrite a code.
  const writer = db.bulkWriter();
  const failed: string[] = [];
  writer.onWriteError((err) => {
    failed.push(err.documentRef.id);
    return false;
  });
  for (const code of codes) {
    writer.create(db.collection("access_codes").doc(code), {
      code,
      batchId: batchRef.id,
      batchName,
      durationDays,
      status: "available",
      createdAt,
    });
  }
  await writer.close();

  const created = count - failed.length;
  await batchRef.set({ name: batchName, count: created, durationDays, createdAt, createdBy: adminUid });
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

  let codeRef;
  if (input.code) {
    const normalized = normalizeCode(input.code);
    if (!normalized) throw new HttpsError("invalid-argument", "Invalid code.");
    codeRef = db.collection("access_codes").doc(normalized);
  } else {
    let q = db.collection("access_codes").where("status", "==", "available");
    if (input.batchId) q = q.where("batchId", "==", input.batchId);
    const snap = await q.limit(1).get();
    if (snap.empty) throw new HttpsError("not-found", "No available codes left. Generate a new batch.");
    codeRef = snap.docs[0].ref;
  }

  const code = await db.runTransaction(async (tx) => {
    const snap = await tx.get(codeRef);
    const data = snap.data();
    if (!data) throw new HttpsError("not-found", "Code not found.");
    if (data.status !== "available") throw new HttpsError("failed-precondition", `Code is ${data.status}.`);
    tx.update(codeRef, {
      status: "assigned",
      assignedEmail: input.email,
      assignedNote: input.note ?? null,
      assignedAt: FieldValue.serverTimestamp(),
      assignedBy: adminUid,
    });
    return data as AccessCode;
  });

  if (input.sendEmail) {
    const nl = input.language === "nl";
    const access = code.durationDays === null
      ? (nl ? "onbeperkt" : "unlimited")
      : nl ? `${code.durationDays} dagen` : `${code.durationDays} days`;
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
  }

  await logAdminAction(adminUid, "assignCode", { code: code.code, email: input.email, emailed: input.sendEmail });
  return { code: code.code };
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
