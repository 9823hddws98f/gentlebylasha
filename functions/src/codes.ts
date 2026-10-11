import { randomInt } from "node:crypto";

/** No 0/O/1/I so codes are easy to read off a card and type in. */
export const CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
const PREFIX = "GENTLE";
const BODY_LENGTH = 8;

export type CodeStatus = "available" | "assigned" | "redeemed" | "disabled";

export interface AccessCode {
  code: string;
  batchId: string;
  /** null = lifetime access */
  durationDays: number | null;
  status: CodeStatus;
  createdAt: Date;
  assignedEmail?: string;
  assignedNote?: string;
  assignedAt?: Date;
  redeemedBy?: string;
  redeemedAt?: Date;
}

export interface Entitlement {
  active: boolean;
  /** null = never expires */
  expiresAt: Date | null;
}

export function formatCode(body: string): string {
  return `${PREFIX}-${body.slice(0, 4)}-${body.slice(4, 8)}`;
}

export function generateCode(): string {
  let body = "";
  for (let i = 0; i < BODY_LENGTH; i++) {
    body += CODE_ALPHABET[randomInt(CODE_ALPHABET.length)];
  }
  return formatCode(body);
}

/** Turns whatever the user typed into the canonical code, or null if it can't be one. */
export function normalizeCode(input: string): string | null {
  let body = input.toUpperCase().replace(/[^A-Z0-9]/g, "");
  if (body.startsWith(PREFIX) && body.length === PREFIX.length + BODY_LENGTH) {
    body = body.slice(PREFIX.length);
  }
  if (body.length !== BODY_LENGTH) return null;
  return formatCode(body);
}

export type RedemptionPlan =
  | { ok: true; alreadyRedeemed: boolean; expiresAt: Date | null }
  | { ok: false; reason: "not-found" | "disabled" | "already-redeemed" };

export function planRedemption(
  code: AccessCode | undefined,
  uid: string,
  now: Date,
): RedemptionPlan {
  if (!code) return { ok: false, reason: "not-found" };
  if (code.status === "disabled") return { ok: false, reason: "disabled" };
  if (code.status === "redeemed") {
    return code.redeemedBy === uid
      ? { ok: true, alreadyRedeemed: true, expiresAt: null }
      : { ok: false, reason: "already-redeemed" };
  }
  const expiresAt =
    code.durationDays === null ? null : new Date(now.getTime() + code.durationDays * 86_400_000);
  return { ok: true, alreadyRedeemed: false, expiresAt };
}

/** Combines an existing entitlement with a newly granted one; the longest access wins. */
export function mergeEntitlement(
  current: Entitlement | undefined,
  granted: Date | null,
  now: Date,
): Date | null {
  const currentValid =
    current?.active && (current.expiresAt === null || current.expiresAt > now);
  if (!currentValid) return granted;
  if (current.expiresAt === null || granted === null) return null;
  return current.expiresAt > granted ? current.expiresAt : granted;
}
