import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { readSources, type SourceGrant } from "./entitlement.js";

const DAY = 86_400_000;
/** Bump when the shape changes, so adminStats doesn't serve an older cached version. */
export const STATS_VERSION = 2;
const CANCELLATION_DAYS = 30;

/** Sources that are paid subscriptions in a store. */
export const PAID_SOURCES = ["apple", "google", "stripe"] as const;
export type PaidSource = (typeof PAID_SOURCES)[number];

const isCurrent = (g: SourceGrant, now: Date) => g.active && (g.expiresAt === null || g.expiresAt > now);
const zero = () => Object.fromEntries(PAID_SOURCES.map((s) => [s, 0])) as Record<PaidSource, number>;

/** Users with a running paid subscription, per store (someone paying in two stores counts in both). */
export function payingBySource(users: Record<string, SourceGrant>[], now: Date): Record<PaidSource, number> {
  const counts = zero();
  for (const sources of users) {
    for (const s of PAID_SOURCES) if (sources[s] && isCurrent(sources[s], now)) counts[s]++;
  }
  return counts;
}

/**
 * Users who paid in a store but no longer pay anywhere, per store whose
 * subscription ended. Someone who moved to another store has not cancelled.
 * The caller passes only recently updated users.
 */
export function cancellations(users: Record<string, SourceGrant>[], now: Date) {
  const bySource = zero();
  let total = 0;
  for (const sources of users) {
    const paid = PAID_SOURCES.filter((s) => sources[s]);
    if (!paid.length || paid.some((s) => isCurrent(sources[s], now))) continue;
    total++;
    for (const s of paid) bySource[s]++;
  }
  return { total, bySource };
}

/** Sign-ups per week (UTC, weeks start on Monday) for the last `weeks` weeks, oldest first. */
export function weeklyBuckets(createdAtMs: number[], now: Date, weeks: number) {
  const today = Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate());
  const mondayOffset = (new Date(today).getUTCDay() + 6) % 7;
  const thisWeek = today - mondayOffset * DAY;
  const starts = Array.from({ length: weeks }, (_, i) => thisWeek - (weeks - 1 - i) * 7 * DAY);
  const counts = new Array(weeks).fill(0);
  for (const t of createdAtMs) {
    const i = Math.floor((t - starts[0]) / (7 * DAY));
    if (i >= 0 && i < weeks) counts[i]++;
  }
  return starts.map((s, i) => ({ weekStart: new Date(s).toISOString().slice(0, 10), count: counts[i] }));
}

export async function computeStats(now = new Date()) {
  const db = getFirestore();
  const weeks = 12;
  const since = now.getTime() - (weeks + 1) * 7 * DAY;

  const [usersTotal, recentUsers, activeSubs, recentSubs, codeCounts, topStats] = await Promise.all([
    db.collection("users").count().get(),
    // users.createdAt is stored as milliseconds by the app
    db.collection("users").where("createdAt", ">=", since).select("createdAt").get(),
    db.collection("subscriptions").where("active", "==", true).select("active", "expiresAt", "source", "sources").get(),
    db
      .collection("subscriptions")
      .where("updatedAt", ">=", Timestamp.fromMillis(now.getTime() - CANCELLATION_DAYS * DAY))
      .select("active", "expiresAt", "sources")
      .get(),
    Promise.all(
      (["available", "assigned", "redeemed", "disabled"] as const).map(async (s) => [
        s,
        (await db.collection("access_codes").where("status", "==", s).count().get()).data().count,
      ]),
    ),
    db.collection("track_stats").orderBy("plays", "desc").limit(10).get(),
  ]);

  const premiumBySource: Record<string, number> = {};
  for (const doc of activeSubs.docs) {
    const exp = doc.get("expiresAt");
    if (exp instanceof Timestamp && exp.toMillis() <= now.getTime()) continue;
    const source = doc.get("source") ?? "code";
    premiumBySource[source] = (premiumBySource[source] ?? 0) + 1;
  }

  const trackDocs = topStats.empty
    ? []
    : await db.getAll(...topStats.docs.map((d) => db.collection("tracks").doc(d.id)));
  const titles = new Map(trackDocs.map((d) => [d.id, d.get("title") as string | undefined]));

  return {
    version: STATS_VERSION,
    generatedAt: now.toISOString(),
    users: usersTotal.data().count,
    signupsPerWeek: weeklyBuckets(
      recentUsers.docs.map((d) => Number(d.get("createdAt"))).filter(Number.isFinite),
      now,
      weeks,
    ),
    premium: Object.values(premiumBySource).reduce((a, b) => a + b, 0),
    premiumBySource,
    // Paying users always have an active subscriptions doc.
    paying: payingBySource(activeSubs.docs.map((d) => readSources(d.data())), now),
    cancellations: { days: CANCELLATION_DAYS, ...cancellations(recentSubs.docs.map((d) => readSources(d.data())), now) },
    codes: Object.fromEntries(codeCounts),
    topTracks: topStats.docs.map((d) => ({
      id: d.id,
      title: titles.get(d.id) ?? "(verwijderd)",
      plays: Number(d.get("plays") ?? 0),
    })),
  };
}
