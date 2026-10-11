import { describe, expect, it } from "vitest";
import {
  CODE_ALPHABET,
  formatCode,
  generateCode,
  mergeEntitlement,
  normalizeCode,
  planRedemption,
  type AccessCode,
} from "../src/codes.js";

const now = new Date("2026-10-11T12:00:00Z");

function code(overrides: Partial<AccessCode> = {}): AccessCode {
  return {
    code: "GENTLE-ABCD-EFGH",
    batchId: "b1",
    durationDays: 365,
    status: "available",
    createdAt: now,
    ...overrides,
  };
}

describe("generateCode", () => {
  it("formats as GENTLE-XXXX-XXXX using only unambiguous characters", () => {
    const c = generateCode();
    expect(c).toMatch(/^GENTLE-[A-Z2-9]{4}-[A-Z2-9]{4}$/);
    for (const ch of c.slice(7).replace("-", "")) {
      expect(CODE_ALPHABET).toContain(ch);
    }
  });

  it("never uses 0, O, 1 or I", () => {
    expect(CODE_ALPHABET).not.toMatch(/[0O1I]/);
  });

  it("produces distinct codes", () => {
    const set = new Set(Array.from({ length: 5000 }, () => generateCode()));
    expect(set.size).toBe(5000);
  });
});

describe("normalizeCode", () => {
  it("accepts lowercase, spaces and missing dashes", () => {
    expect(normalizeCode(" gentle abcd efgh ")).toBe("GENTLE-ABCD-EFGH");
    expect(normalizeCode("abcdefgh")).toBe("GENTLE-ABCD-EFGH");
    expect(normalizeCode("GENTLE-ABCD-EFGH")).toBe("GENTLE-ABCD-EFGH");
  });

  it("returns null for input of the wrong length", () => {
    expect(normalizeCode("abc")).toBeNull();
    expect(normalizeCode("")).toBeNull();
    expect(normalizeCode("GENTLE-ABCD-EFGHX")).toBeNull();
  });

  it("formatCode inserts dashes", () => {
    expect(formatCode("ABCDEFGH")).toBe("GENTLE-ABCD-EFGH");
  });
});

describe("planRedemption", () => {
  it("rejects an unknown code", () => {
    expect(planRedemption(undefined, "u1", now)).toEqual({ ok: false, reason: "not-found" });
  });

  it("rejects a disabled code", () => {
    expect(planRedemption(code({ status: "disabled" }), "u1", now)).toEqual({
      ok: false,
      reason: "disabled",
    });
  });

  it("rejects a code redeemed by someone else", () => {
    const c = code({ status: "redeemed", redeemedBy: "other" });
    expect(planRedemption(c, "u1", now)).toEqual({ ok: false, reason: "already-redeemed" });
  });

  it("is idempotent for the same user", () => {
    const c = code({ status: "redeemed", redeemedBy: "u1" });
    expect(planRedemption(c, "u1", now)).toEqual({ ok: true, alreadyRedeemed: true, expiresAt: null });
  });

  it("redeems an available code with an expiry", () => {
    const r = planRedemption(code({ durationDays: 30 }), "u1", now);
    expect(r).toEqual({
      ok: true,
      alreadyRedeemed: false,
      expiresAt: new Date("2026-11-10T12:00:00Z"),
    });
  });

  it("redeems an assigned code too", () => {
    const r = planRedemption(code({ status: "assigned", assignedEmail: "a@b.nl" }), "u1", now);
    expect(r.ok).toBe(true);
  });

  it("lifetime code has no expiry", () => {
    const r = planRedemption(code({ durationDays: null }), "u1", now);
    expect(r).toEqual({ ok: true, alreadyRedeemed: false, expiresAt: null });
  });
});

describe("mergeEntitlement", () => {
  const later = new Date("2027-01-01T00:00:00Z");
  const sooner = new Date("2026-12-01T00:00:00Z");

  it("uses the new expiry when there is no current subscription", () => {
    expect(mergeEntitlement(undefined, sooner, now)).toEqual(sooner);
  });

  it("ignores an expired current subscription", () => {
    const expired = { active: true, expiresAt: new Date("2026-01-01T00:00:00Z") };
    expect(mergeEntitlement(expired, sooner, now)).toEqual(sooner);
  });

  it("keeps the later of two expiries", () => {
    expect(mergeEntitlement({ active: true, expiresAt: later }, sooner, now)).toEqual(later);
    expect(mergeEntitlement({ active: true, expiresAt: sooner }, later, now)).toEqual(later);
  });

  it("lifetime wins over any expiry", () => {
    expect(mergeEntitlement({ active: true, expiresAt: null }, later, now)).toBeNull();
    expect(mergeEntitlement({ active: true, expiresAt: later }, null, now)).toBeNull();
  });
});
