import { getFirestore, Timestamp } from "firebase-admin/firestore";

export type Source = "apple" | "google" | "stripe" | "code" | "manual";

/** What one source grants. `expiresAt: null` = never expires. */
export interface SourceGrant {
  active: boolean;
  expiresAt: Date | null;
}

export interface Entitlement {
  active: boolean;
  expiresAt: Date | null;
  source: string | null;
}

/** Premium is the longest-lasting grant that is still valid. */
export function computeEntitlement(sources: Record<string, SourceGrant>, now: Date): Entitlement {
  let best: Entitlement = { active: false, expiresAt: null, source: null };
  for (const [source, grant] of Object.entries(sources)) {
    if (!grant.active) continue;
    if (grant.expiresAt !== null && grant.expiresAt <= now) continue;
    const better =
      !best.active ||
      (best.expiresAt !== null && (grant.expiresAt === null || grant.expiresAt > best.expiresAt));
    if (better) best = { active: true, expiresAt: grant.expiresAt, source };
  }
  return best;
}

const toDate = (v: unknown) => (v instanceof Timestamp ? v.toDate() : null);

export function readSources(data: FirebaseFirestore.DocumentData | undefined): Record<string, SourceGrant> {
  const raw = (data?.sources ?? {}) as Record<string, { active?: boolean; expiresAt?: unknown }>;
  return Object.fromEntries(
    Object.entries(raw).map(([k, v]) => [k, { active: v.active === true, expiresAt: toDate(v.expiresAt) }]),
  );
}

/** Firestore fields for subscriptions/{uid} after `sources` changed. */
export function entitlementFields(sources: Record<string, SourceGrant>, now: Date, extra: Record<string, unknown> = {}) {
  const e = computeEntitlement(sources, now);
  return {
    sources: Object.fromEntries(
      Object.entries(sources).map(([k, v]) => [
        k,
        { active: v.active, expiresAt: v.expiresAt ? Timestamp.fromDate(v.expiresAt) : null },
      ]),
    ),
    active: e.active,
    expiresAt: e.expiresAt ? Timestamp.fromDate(e.expiresAt) : null,
    source: e.source,
    updatedAt: Timestamp.fromDate(now),
    ...extra,
  };
}

/** Sets one source's grant for a user and recomputes their premium status. */
export async function setSourceGrant(uid: string, source: Source, grant: SourceGrant, extra: Record<string, unknown> = {}) {
  const db = getFirestore();
  const ref = db.collection("subscriptions").doc(uid);
  await db.runTransaction(async (tx) => {
    const sources = readSources((await tx.get(ref)).data());
    sources[source] = grant;
    tx.set(ref, entitlementFields(sources, new Date(), extra), { merge: true });
  });
}
