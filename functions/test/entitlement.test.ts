import { describe, expect, it } from "vitest";
import { bestGrant, computeEntitlement, type SourceGrant } from "../src/entitlement.js";

const now = new Date("2026-10-12T12:00:00Z");
const d = (s: string) => new Date(s);

describe("computeEntitlement", () => {
  it("is inactive without sources", () => {
    expect(computeEntitlement({}, now)).toEqual({ active: false, expiresAt: null, source: null });
  });

  it("uses a single active source", () => {
    const sources: Record<string, SourceGrant> = { apple: { active: true, expiresAt: d("2026-11-12T12:00:00Z") } };
    expect(computeEntitlement(sources, now)).toEqual({
      active: true,
      expiresAt: d("2026-11-12T12:00:00Z"),
      source: "apple",
    });
  });

  it("ignores expired and inactive sources", () => {
    const sources: Record<string, SourceGrant> = {
      apple: { active: true, expiresAt: d("2026-10-01T00:00:00Z") },
      stripe: { active: false, expiresAt: d("2027-01-01T00:00:00Z") },
    };
    expect(computeEntitlement(sources, now)).toEqual({ active: false, expiresAt: null, source: null });
  });

  it("picks the source that lasts longest", () => {
    const sources: Record<string, SourceGrant> = {
      code: { active: true, expiresAt: d("2026-12-01T00:00:00Z") },
      google: { active: true, expiresAt: d("2027-01-01T00:00:00Z") },
    };
    expect(computeEntitlement(sources, now)).toMatchObject({ expiresAt: d("2027-01-01T00:00:00Z"), source: "google" });
  });

  it("lifetime beats any expiry", () => {
    const sources: Record<string, SourceGrant> = {
      stripe: { active: true, expiresAt: d("2027-01-01T00:00:00Z") },
      code: { active: true, expiresAt: null },
    };
    expect(computeEntitlement(sources, now)).toEqual({ active: true, expiresAt: null, source: "code" });
  });

  it("keeps a cancelled subscription until it runs out", () => {
    const sources: Record<string, SourceGrant> = { stripe: { active: true, expiresAt: d("2026-10-20T00:00:00Z") } };
    expect(computeEntitlement(sources, now).active).toBe(true);
  });
});

describe("readSources (legacy documents)", () => {
  it("treats an old top-level code grant as the code source", async () => {
    const { readSources } = await import("../src/entitlement.js");
    const { Timestamp } = await import("firebase-admin/firestore");
    const exp = new Date("2027-01-01T00:00:00Z");
    expect(readSources({ active: true, source: "code", expiresAt: Timestamp.fromDate(exp) })).toEqual({
      code: { active: true, expiresAt: exp },
    });
    expect(readSources({ active: true, source: "code", expiresAt: null })).toEqual({
      code: { active: true, expiresAt: null },
    });
  });

  it("prefers the sources map when present", async () => {
    const { readSources } = await import("../src/entitlement.js");
    expect(readSources({ active: true, expiresAt: null, sources: { apple: { active: false, expiresAt: null } } })).toEqual({
      apple: { active: false, expiresAt: null },
    });
  });
});

describe("accountToken", () => {
  it("is a stable UUID-shaped string per uid", async () => {
    const { accountToken } = await import("../src/entitlement.js");
    expect(accountToken("u1")).toMatch(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/);
    expect(accountToken("u1")).toBe(accountToken("u1"));
    expect(accountToken("u1")).not.toBe(accountToken("u2"));
  });

  it("matches the value the app computes for a known uid", async () => {
    const { accountToken } = await import("../src/entitlement.js");
    // sha256("abc") = ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
    expect(accountToken("abc")).toBe("ba7816bf-8f01-cfea-4141-40de5dae2223");
  });
});

describe("bestGrant", () => {
  const now = new Date("2026-10-13T12:00:00Z");
  const later = new Date("2026-12-01T00:00:00Z");
  const soon = new Date("2026-10-20T00:00:00Z");

  it("picks the longest valid grant", () => {
    expect(bestGrant([{ active: true, expiresAt: soon }, { active: true, expiresAt: later }], now)).toEqual({
      active: true,
      expiresAt: later,
    });
  });
  it("an old cancelled grant doesn't hide an active one", () => {
    expect(bestGrant([{ active: true, expiresAt: later }, { active: false, expiresAt: null }], now).active).toBe(true);
  });
  it("nothing valid means no access", () => {
    expect(bestGrant([], now)).toEqual({ active: false, expiresAt: null });
    expect(bestGrant([{ active: true, expiresAt: new Date("2026-01-01") }], now).active).toBe(false);
  });
});
