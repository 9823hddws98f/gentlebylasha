import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { z } from "zod";

import { computeEntitlement, readSources } from "./entitlement.js";
import { APP_URL } from "./stores/stripe.js";

export type Audience = "all" | "premium" | "free";
export type Language = "en" | "nl";
const LANGUAGES: Language[] = ["en", "nl"];

/**
 * FCM topic conditions per language. The app subscribes every device to
 * lang_en or lang_nl, and to premium or free (see lib/domain/services/push_service.dart).
 */
export function pushConditions(audience: Audience): { language: Language; condition: string }[] {
  return LANGUAGES.map((language) => ({
    language,
    condition: `'lang_${language}' in topics${audience === "all" ? "" : ` && '${audience}' in topics`}`,
  }));
}

/** Which topics a device should be in. Mirrors the app; kept here for tests and docs. */
export function topicsFor(language: Language, premium: boolean) {
  const other = language === "en" ? "nl" : "en";
  return {
    subscribe: [`lang_${language}`, premium ? "premium" : "free"],
    unsubscribe: [`lang_${other}`, premium ? "free" : "premium"],
  };
}

export interface PushJob {
  title: Record<Language, string>;
  body: Record<Language, string>;
  audience: Audience;
}

/** Sends one message per language; returns the languages that failed. */
export async function sendPush(job: PushJob): Promise<Language[]> {
  const failed: Language[] = [];
  for (const { language, condition } of pushConditions(job.audience)) {
    try {
      await getMessaging().send({
        condition,
        notification: { title: job.title[language], body: job.body[language] },
        android: { notification: { channelId: "gentle_news" } },
        // Web: clicking the notification opens the webapp.
        webpush: { fcmOptions: { link: APP_URL.value() } },
      });
    } catch (e) {
      logger.error("Push failed", { language, error: String(e) });
      failed.push(language);
    }
  }
  return failed;
}

/** Job status after sending; "partial" tells the admin not to resend to everyone. */
export function pushResult(failed: Language[]) {
  if (failed.length === 0) return { status: "sent" as const };
  if (failed.length === LANGUAGES.length) return { status: "failed" as const };
  return { status: "partial" as const, failedLanguages: failed };
}

/** Sends scheduled pushes that are due. */
export const sendScheduledPushes = onSchedule("every 5 minutes", async () => {
  const db = getFirestore();
  const due = await db
    .collection("push_jobs")
    .where("status", "==", "scheduled")
    .where("sendAt", "<=", Timestamp.now())
    .limit(20)
    .get();
  for (const doc of due.docs) {
    // Claim the job first so an overlapping run can't send it twice.
    const claimed = await db.runTransaction(async (tx) => {
      const fresh = await tx.get(doc.ref);
      if (fresh.data()?.status !== "scheduled") return false;
      tx.update(doc.ref, { status: "sending" });
      return true;
    });
    if (!claimed) continue;
    const failed = await sendPush(doc.data() as PushJob);
    await doc.ref.update({ ...pushResult(failed), sentAt: FieldValue.serverTimestamp() });
  }
});

/**
 * Web browsers can't join FCM topics themselves, so the webapp sends its token
 * here. Premium or free is decided from subscriptions/{uid}, not by the client.
 */
export const syncWebPushTopics = onCall(async (req) => {
  if (!req.auth) throw new HttpsError("unauthenticated", "Sign in first.");
  const input = z
    .object({ token: z.string().min(20).max(4096), language: z.enum(["en", "nl"]) })
    .safeParse(req.data);
  if (!input.success) throw new HttpsError("invalid-argument", "Invalid push token.");
  const { token, language } = input.data;
  const subscription = await getFirestore().collection("subscriptions").doc(req.auth.uid).get();
  const premium = computeEntitlement(readSources(subscription.data()), new Date()).active;
  const { subscribe, unsubscribe } = topicsFor(language, premium);
  const messaging = getMessaging();
  await Promise.all([
    ...subscribe.map((topic) => messaging.subscribeToTopic(token, topic)),
    ...unsubscribe.map((topic) => messaging.unsubscribeFromTopic(token, topic)),
  ]);
  return { premium, topics: subscribe };
});
