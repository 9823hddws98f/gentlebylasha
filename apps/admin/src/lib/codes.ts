import { call } from "./firebase";

export type CodeStatus = "available" | "assigned" | "redeemed" | "disabled";

export interface AccessCode {
  code: string;
  batchId: string;
  batchName?: string;
  durationDays: number | null;
  status: CodeStatus;
  createdAt?: Date;
  assignedEmail?: string;
  assignedNote?: string | null;
  assignedAt?: Date;
  redeemedBy?: string;
  redeemedAt?: Date;
}

export interface Batch {
  id: string;
  name: string;
  count: number;
  durationDays: number | null;
  createdAt?: Date;
}

export const generateCodes = call<
  { count: number; durationDays: number | null; batchName: string },
  { batchId: string; created: number }
>("adminGenerateCodes");

export const assignCode = call<
  { email: string; code?: string; batchId?: string; note?: string; sendEmail: boolean; language: "nl" | "en" },
  { code: string; emailed: boolean }
>("adminAssignCode");

export const disableCode = call<{ code: string }, { success: boolean }>("adminDisableCode");

export const STATUS_LABEL: Record<CodeStatus, string> = {
  available: "Beschikbaar",
  assigned: "Uitgegeven",
  redeemed: "Ingewisseld",
  disabled: "Uitgeschakeld",
};

export function durationLabel(days: number | null): string {
  if (days === null) return "Onbeperkt";
  if (days % 365 === 0) return days === 365 ? "1 jaar" : `${days / 365} jaar`;
  if (days % 30 === 0) return days === 30 ? "1 maand" : `${days / 30} maanden`;
  return `${days} dagen`;
}

export function toCsv(rows: AccessCode[]): string {
  const header = ["code", "status", "batch", "looptijd", "email", "notitie", "uitgegeven", "ingewisseld"];
  const fmt = (d?: Date) => (d ? d.toISOString().slice(0, 10) : "");
  const esc = (v: string) => (/[",\n;]/.test(v) ? `"${v.replace(/"/g, '""')}"` : v);
  const lines = rows.map((r) =>
    [
      r.code,
      STATUS_LABEL[r.status],
      r.batchName ?? r.batchId,
      durationLabel(r.durationDays),
      r.assignedEmail ?? "",
      r.assignedNote ?? "",
      fmt(r.assignedAt),
      fmt(r.redeemedAt),
    ]
      .map((v) => esc(String(v)))
      .join(","),
  );
  return [header.join(","), ...lines].join("\n");
}

/** Firebase callable errors carry a readable message; fall back for anything else. */
export function errorMessage(e: unknown): string {
  if (e && typeof e === "object" && "message" in e && typeof e.message === "string") {
    // The callable SDK appends the HTTP status ("… [400]"); admins don't need it.
    return e.message.replace(/\s*\[\d{3}\]$/, "") || "Er ging iets mis.";
  }
  return "Er ging iets mis.";
}
