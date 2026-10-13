import { createPublicKey, generateKeyPairSync, verify } from "node:crypto";
import { describe, expect, it } from "vitest";
import { appleClientSecret } from "../src/apple-signin.js";

describe("appleClientSecret", () => {
  const { privateKey } = generateKeyPairSync("ec", { namedCurve: "P-256" });
  const pem = privateKey.export({ type: "pkcs8", format: "pem" }).toString();
  const now = new Date("2026-10-13T12:00:00Z");
  const jwt = appleClientSecret({ teamId: "TEAM123", keyId: "KEY123", clientId: "io.example.app", privateKey: pem }, now);
  const [h, p, s] = jwt.split(".");
  const decode = (x: string) => JSON.parse(Buffer.from(x, "base64url").toString());

  it("has Apple's required header and claims", () => {
    expect(decode(h)).toEqual({ alg: "ES256", kid: "KEY123" });
    expect(decode(p)).toEqual({
      iss: "TEAM123",
      iat: now.getTime() / 1000,
      exp: now.getTime() / 1000 + 300,
      aud: "https://appleid.apple.com",
      sub: "io.example.app",
    });
  });

  it("is signed with the key (ES256, raw r||s signature)", () => {
    const ok = verify(
      "sha256",
      Buffer.from(`${h}.${p}`),
      { key: createPublicKey(privateKey), dsaEncoding: "ieee-p1363" },
      Buffer.from(s, "base64url"),
    );
    expect(ok).toBe(true);
  });
});
