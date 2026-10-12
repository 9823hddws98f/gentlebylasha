import { describe, expect, it } from "vitest";
import { appleGrant, decodeJwsPayload, googleGrant, stripeGrant } from "../src/stores/grants.js";

const exp = new Date("2026-11-12T12:00:00Z");

describe("appleGrant", () => {
  it("active (1) and grace period (4) grant access until expiry", () => {
    expect(appleGrant(1, exp.getTime())).toEqual({ active: true, expiresAt: exp });
    expect(appleGrant(4, exp.getTime())).toEqual({ active: true, expiresAt: exp });
  });
  it("expired (2), billing retry (3) and revoked (5) grant nothing", () => {
    for (const s of [2, 3, 5]) expect(appleGrant(s, exp.getTime()).active).toBe(false);
  });
  it("needs an expiry date", () => {
    expect(appleGrant(1, undefined).active).toBe(false);
  });
});

describe("googleGrant", () => {
  it("active, in grace period and canceled-but-not-expired grant access", () => {
    for (const s of ["SUBSCRIPTION_STATE_ACTIVE", "SUBSCRIPTION_STATE_IN_GRACE_PERIOD", "SUBSCRIPTION_STATE_CANCELED"]) {
      expect(googleGrant(s, exp.toISOString())).toEqual({ active: true, expiresAt: exp });
    }
  });
  it("on hold, paused, expired and pending grant nothing", () => {
    for (const s of [
      "SUBSCRIPTION_STATE_ON_HOLD",
      "SUBSCRIPTION_STATE_PAUSED",
      "SUBSCRIPTION_STATE_EXPIRED",
      "SUBSCRIPTION_STATE_PENDING",
    ]) {
      expect(googleGrant(s, exp.toISOString()).active).toBe(false);
    }
  });
});

describe("stripeGrant", () => {
  it("active, trialing and past_due keep access until the period ends", () => {
    for (const s of ["active", "trialing", "past_due"]) {
      expect(stripeGrant(s, exp.getTime() / 1000)).toEqual({ active: true, expiresAt: exp });
    }
  });
  it("canceled, unpaid and incomplete grant nothing", () => {
    for (const s of ["canceled", "unpaid", "incomplete", "incomplete_expired", "paused"]) {
      expect(stripeGrant(s, exp.getTime() / 1000).active).toBe(false);
    }
  });
});

describe("decodeJwsPayload", () => {
  it("reads the middle part of a JWS", () => {
    const payload = Buffer.from(JSON.stringify({ originalTransactionId: "42" })).toString("base64url");
    expect(decodeJwsPayload(`header.${payload}.sig`)).toEqual({ originalTransactionId: "42" });
  });
  it("throws on garbage", () => {
    expect(() => decodeJwsPayload("nope")).toThrow();
  });
});

describe("appleGrant grace period", () => {
  it("uses the grace period end while Apple retries billing", () => {
    const expired = new Date("2026-10-01T00:00:00Z").getTime();
    const grace = new Date("2026-10-20T00:00:00Z");
    expect(appleGrant(4, expired, grace.getTime())).toEqual({ active: true, expiresAt: grace });
  });
  it("keeps the later date when both exist", () => {
    expect(appleGrant(1, exp.getTime(), new Date("2026-10-01T00:00:00Z").getTime())).toEqual({
      active: true,
      expiresAt: exp,
    });
  });
});
