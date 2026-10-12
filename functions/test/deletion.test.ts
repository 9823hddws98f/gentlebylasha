import { describe, expect, it } from "vitest";
import { checkDeletionCode, hashCode, newDeletionCode, type StoredDeletionCode } from "../src/deletion.js";

const now = new Date("2026-10-12T10:00:00Z");

function stored(overrides: Partial<StoredDeletionCode> = {}): StoredDeletionCode {
  return {
    codeHash: hashCode("u1", "123456"),
    expiresAt: new Date("2026-10-12T10:10:00Z"),
    attempts: 0,
    ...overrides,
  };
}

describe("newDeletionCode", () => {
  it("is six digits", () => {
    for (let i = 0; i < 200; i++) expect(newDeletionCode()).toMatch(/^\d{6}$/);
  });
});

describe("hashCode", () => {
  it("depends on the user, so a hash can't be reused across accounts", () => {
    expect(hashCode("u1", "123456")).not.toBe(hashCode("u2", "123456"));
  });
});

describe("checkDeletionCode", () => {
  it("accepts the right code", () => {
    expect(checkDeletionCode(stored(), "u1", "123456", now)).toBe("ok");
  });

  it("ignores surrounding whitespace", () => {
    expect(checkDeletionCode(stored(), "u1", " 123456 ", now)).toBe("ok");
  });

  it("rejects when no code was requested", () => {
    expect(checkDeletionCode(undefined, "u1", "123456", now)).toBe("no-code");
  });

  it("rejects an expired code", () => {
    expect(checkDeletionCode(stored({ expiresAt: new Date("2026-10-12T09:59:59Z") }), "u1", "123456", now)).toBe(
      "expired",
    );
  });

  it("rejects after too many attempts, even with the right code", () => {
    expect(checkDeletionCode(stored({ attempts: 5 }), "u1", "123456", now)).toBe("too-many-attempts");
  });

  it("rejects a wrong code", () => {
    expect(checkDeletionCode(stored(), "u1", "654321", now)).toBe("wrong-code");
  });
});
