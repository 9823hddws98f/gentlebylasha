import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { logger } from "firebase-functions";
import { onSchedule } from "firebase-functions/v2/scheduler";

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

export async function sendPush(job: PushJob) {
  for (const { language, condition } of pushConditions(job.audience)) {
    await getMessaging().send({
      condition,
      notification: { title: job.title[language], body: job.body[language] },
      android: { notification: { channelId: "gentle_news" } },
    });
  }
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
    try {
      await sendPush(doc.data() as PushJob);
      await doc.ref.update({ status: "sent", sentAt: FieldValue.serverTimestamp() });
    } catch (e) {
      logger.error("Scheduled push failed", { job: doc.id, error: String(e) });
      await doc.ref.update({ status: "failed", error: String(e).slice(0, 500) });
    }
  }
});
