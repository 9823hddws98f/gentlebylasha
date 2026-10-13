import { getFirestore, Timestamp } from "firebase-admin/firestore";

const DAY = 86_400_000;

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

  const [usersTotal, recentUsers, activeSubs, codeCounts, topStats] = await Promise.all([
    db.collection("users").count().get(),
    // users.createdAt is stored as milliseconds by the app
    db.collection("users").where("createdAt", ">=", since).select("createdAt").get(),
    db.collection("subscriptions").where("active", "==", true).select("expiresAt", "source").get(),
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
    generatedAt: now.toISOString(),
    users: usersTotal.data().count,
    signupsPerWeek: weeklyBuckets(
      recentUsers.docs.map((d) => Number(d.get("createdAt"))).filter(Number.isFinite),
      now,
      weeks,
    ),
    premium: Object.values(premiumBySource).reduce((a, b) => a + b, 0),
    premiumBySource,
    codes: Object.fromEntries(codeCounts),
    topTracks: topStats.docs.map((d) => ({
      id: d.id,
      title: titles.get(d.id) ?? "(verwijderd)",
      plays: Number(d.get("plays") ?? 0),
    })),
  };
}
