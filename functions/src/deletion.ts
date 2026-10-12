import { createHash, randomInt, timingSafeEqual } from "node:crypto";

export const DELETION_CODE_TTL_MS = 15 * 60_000;
export const MAX_DELETION_ATTEMPTS = 5;

export interface StoredDeletionCode {
  codeHash: string;
  expiresAt: Date;
  attempts: number;
}

export function newDeletionCode(): string {
  return String(randomInt(0, 1_000_000)).padStart(6, "0");
}

/** Salted with the uid so the stored value is useless for any other account. */
export function hashCode(uid: string, code: string): string {
  return createHash("sha256").update(`${uid}:${code}`).digest("hex");
}

export type DeletionCheck = "ok" | "no-code" | "expired" | "too-many-attempts" | "wrong-code";

export function checkDeletionCode(
  stored: StoredDeletionCode | undefined,
  uid: string,
  input: string,
  now: Date,
): DeletionCheck {
  if (!stored) return "no-code";
  if (stored.expiresAt <= now) return "expired";
  if (stored.attempts >= MAX_DELETION_ATTEMPTS) return "too-many-attempts";
  const given = Buffer.from(hashCode(uid, input.trim()), "hex");
  const expected = Buffer.from(stored.codeHash, "hex");
  return given.length === expected.length && timingSafeEqual(given, expected) ? "ok" : "wrong-code";
}
