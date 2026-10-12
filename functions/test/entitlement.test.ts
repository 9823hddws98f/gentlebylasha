import { describe, expect, it } from "vitest";
import { computeEntitlement, type SourceGrant } from "../src/entitlement.js";

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
