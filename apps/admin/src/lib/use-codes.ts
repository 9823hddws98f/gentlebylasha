"use client";

import {
  collection,
  getCountFromServer,
  limit,
  onSnapshot,
  orderBy,
  query,
  type QueryConstraint,
  Timestamp,
  where,
} from "firebase/firestore";
import { useCallback, useEffect, useState } from "react";
import type { AccessCode, Batch, CodeStatus } from "./codes";
import { db } from "./firebase";

const PAGE_SIZE = 500;

const date = (v: unknown) => (v instanceof Timestamp ? v.toDate() : undefined);

export function useBatches() {
  const [batches, setBatches] = useState<Batch[]>([]);
  const [error, setError] = useState<string | null>(null);
  useEffect(
    () =>
      onSnapshot(
        query(collection(db, "code_batches"), orderBy("createdAt", "desc")),
        (snap) => {
          setError(null);
          setBatches(
            snap.docs.map((d) => ({
              id: d.id,
              name: d.data().name,
              count: d.data().count,
              durationDays: d.data().durationDays ?? null,
              createdAt: date(d.data().createdAt),
            })),
          );
        },
        () => setError("Batches konden niet worden geladen."),
      ),
    [],
  );
  return { batches, error };
}

export function useCodes(status: CodeStatus | "all", batchId: string) {
  const key = `${status}|${batchId}`;
  // Results are tagged with their query so a filter change shows loading, not stale rows.
  const [result, setResult] = useState<{ key: string; codes: AccessCode[]; error: string | null } | null>(null);

  useEffect(() => {
    const constraints: QueryConstraint[] = [];
    if (status !== "all") constraints.push(where("status", "==", status));
    if (batchId) constraints.push(where("batchId", "==", batchId));
    constraints.push(orderBy("createdAt", "desc"), limit(PAGE_SIZE));

    return onSnapshot(
      query(collection(db, "access_codes"), ...constraints),
      (snap) => {
        setResult({
          key,
          error: null,
          codes: snap.docs.map((d) => {
            const v = d.data();
            return {
              code: d.id,
              batchId: v.batchId,
              batchName: v.batchName,
              durationDays: v.durationDays ?? null,
              status: v.status,
              createdAt: date(v.createdAt),
              assignedEmail: v.assignedEmail,
              assignedNote: v.assignedNote,
              assignedAt: date(v.assignedAt),
              redeemedBy: v.redeemedBy,
              redeemedAt: date(v.redeemedAt),
            };
          }),
        });
      },
      () => setResult({ key, codes: [], error: "Codes konden niet worden geladen." }),
    );
  }, [key, status, batchId]);

  const current = result?.key === key ? result : null;
  return {
    codes: current?.codes ?? null,
    error: current?.error ?? null,
    truncated: (current?.codes.length ?? 0) >= PAGE_SIZE,
  };
}

const STATUSES: CodeStatus[] = ["available", "assigned", "redeemed", "disabled"];

export function useCounts(batchId: string) {
  const [counts, setCounts] = useState<Record<CodeStatus, number> | null>(null);
  const [version, setVersion] = useState(0);

  useEffect(() => {
    let cancelled = false;
    Promise.all(
      STATUSES.map((s) => {
        const c = [where("status", "==", s)];
        if (batchId) c.push(where("batchId", "==", batchId));
        return getCountFromServer(query(collection(db, "access_codes"), ...c)).then((r) => r.data().count);
      }),
    )
      .then((results) => Object.fromEntries(STATUSES.map((s, i) => [s, results[i]])) as Record<CodeStatus, number>)
      .catch(() => null)
      .then((next) => !cancelled && setCounts(next));
    return () => {
      cancelled = true;
    };
  }, [batchId, version]);

  const refresh = useCallback(() => setVersion((v) => v + 1), []);
  return { counts, refresh };
}
