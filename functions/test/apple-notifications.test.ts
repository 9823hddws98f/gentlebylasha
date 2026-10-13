import { Environment, VerificationException, VerificationStatus } from "@apple/app-store-server-library";
import { describe, expect, it } from "vitest";
import { checkAppleNotification, InvalidNotification } from "../src/stores/apple.js";

const jws = (payload: object) => `header.${Buffer.from(JSON.stringify(payload)).toString("base64url")}.sig`;
const production = jws({ data: { environment: "Production" } });
const sandbox = jws({ data: { environment: "Sandbox" } });

type Answer = object | VerificationStatus;

/** A verifier that answers per environment: a payload, or a VerificationException with that status. */
function verifier(answers: Partial<Record<Environment, Answer>>) {
  const tried: Environment[] = [];
  const verify = async (env: Environment) => {
    tried.push(env);
    const answer = answers[env];
    if (answer === undefined) throw new Error(`unexpected ${env}`);
    if (typeof answer === "number") throw new VerificationException(answer);
    return answer;
  };
  return { verify, tried };
}

describe("checkAppleNotification", () => {
  it("accepts a production notification the production verifier accepts", async () => {
    const v = verifier({ [Environment.PRODUCTION]: { notificationType: "DID_RENEW" } });
    const result = await checkAppleNotification(production, v.verify, true);
    expect(result).toEqual({ payload: { notificationType: "DID_RENEW" }, verified: true });
    expect(v.tried).toEqual([Environment.PRODUCTION]);
  });

  it("falls through to the sandbox verifier for sandbox notifications", async () => {
    // Sandbox payloads carry no app id, so production rejects the app identifier.
    const v = verifier({
      [Environment.PRODUCTION]: VerificationStatus.INVALID_APP_IDENTIFIER,
      [Environment.SANDBOX]: { notificationType: "EXPIRED" },
    });
    const result = await checkAppleNotification(sandbox, v.verify, true);
    expect(result.verified).toBe(true);
    expect(v.tried).toEqual([Environment.PRODUCTION, Environment.SANDBOX]);
  });

  it("rejects a bad signature without trying further", async () => {
    const v = verifier({ [Environment.PRODUCTION]: VerificationStatus.VERIFICATION_FAILURE });
    await expect(checkAppleNotification(production, v.verify, true)).rejects.toBeInstanceOf(InvalidNotification);
    expect(v.tried).toEqual([Environment.PRODUCTION]);
  });

  it("rejects another app's notification", async () => {
    const v = verifier({
      [Environment.PRODUCTION]: VerificationStatus.INVALID_APP_IDENTIFIER,
      [Environment.SANDBOX]: VerificationStatus.INVALID_APP_IDENTIFIER,
    });
    await expect(checkAppleNotification(production, v.verify, true)).rejects.toBeInstanceOf(InvalidNotification);
  });

  it("rejects a payload that neither environment accepts", async () => {
    const v = verifier({
      [Environment.PRODUCTION]: VerificationStatus.INVALID_ENVIRONMENT,
      [Environment.SANDBOX]: VerificationStatus.INVALID_ENVIRONMENT,
    });
    await expect(checkAppleNotification(jws({ data: { environment: "Xcode" } }), v.verify, true)).rejects.toBeInstanceOf(
      InvalidNotification,
    );
  });

  it("passes temporary failures on, so Apple retries", async () => {
    const v = verifier({ [Environment.PRODUCTION]: VerificationStatus.RETRYABLE_VERIFICATION_FAILURE });
    const error = await checkAppleNotification(production, v.verify, true).catch((e) => e);
    expect(error).toBeInstanceOf(VerificationException);
    expect(error).not.toBeInstanceOf(InvalidNotification);
  });

  it("rejects an empty payload", async () => {
    const v = verifier({});
    await expect(checkAppleNotification("", v.verify, true)).rejects.toBeInstanceOf(InvalidNotification);
    expect(v.tried).toEqual([]);
  });

  describe("without the app's Apple ID", () => {
    it("never tries the production verifier and verifies sandbox notifications", async () => {
      const v = verifier({ [Environment.SANDBOX]: { notificationType: "TEST" } });
      const result = await checkAppleNotification(sandbox, v.verify, false);
      expect(result.verified).toBe(true);
      expect(v.tried).toEqual([Environment.SANDBOX]);
    });

    it("uses a correctly signed production notification unverified", async () => {
      const v = verifier({ [Environment.SANDBOX]: VerificationStatus.INVALID_ENVIRONMENT });
      const result = await checkAppleNotification(production, v.verify, false);
      expect(result).toEqual({ payload: { data: { environment: "Production" } }, verified: false });
    });

    it("still rejects a production notification with a bad signature", async () => {
      const v = verifier({ [Environment.SANDBOX]: VerificationStatus.VERIFICATION_FAILURE });
      await expect(checkAppleNotification(production, v.verify, false)).rejects.toBeInstanceOf(InvalidNotification);
    });
  });
});
