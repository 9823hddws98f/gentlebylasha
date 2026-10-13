import { readFileSync } from "node:fs";
import {
  APIException,
  AppStoreServerAPIClient,
  Environment,
  type ResponseBodyV2DecodedPayload,
  SignedDataVerifier,
  VerificationException,
  VerificationStatus,
} from "@apple/app-store-server-library";
import { defineSecret, defineString } from "firebase-functions/params";
import type { SourceGrant } from "../entitlement.js";
import { appleGrant, decodeJwsPayload } from "./grants.js";

// App Store Connect → Users and Access → Integrations → In-App Purchase key.
export const APPLE_IAP_KEY = defineSecret("APPLE_IAP_KEY");
const APPLE_IAP_KEY_ID = defineString("APPLE_IAP_KEY_ID", { default: "" });
const APPLE_IAP_ISSUER_ID = defineString("APPLE_IAP_ISSUER_ID", { default: "" });
const APPLE_BUNDLE_ID = defineString("APPLE_BUNDLE_ID", { default: "io.sleeptales.sleeptales" });
// App Store Connect → App Information → Apple ID (a number). Needed to verify production notifications.
const APPLE_APP_ID = defineString("APPLE_APP_ID", { default: "" });
// Apple Root CA - G3 and Apple Inc. Root, from apple.com/certificateauthority (DER).
const ROOT_CERTIFICATES = ["AppleRootCA-G3.cer", "AppleIncRootCertificate.cer"];

interface TransactionPayload {
  originalTransactionId?: string;
  productId?: string;
  expiresDate?: number;
  bundleId?: string;
  appAccountToken?: string;
}

interface RenewalPayload {
  gracePeriodExpiresDate?: number;
}

function client(env: Environment) {
  return new AppStoreServerAPIClient(
    APPLE_IAP_KEY.value(),
    APPLE_IAP_KEY_ID.value(),
    APPLE_IAP_ISSUER_ID.value(),
    APPLE_BUNDLE_ID.value(),
    env,
  );
}

export interface AppleResult {
  originalTransactionId: string;
  grant: SourceGrant;
  /** Set when the app passed it at purchase; ties the purchase to an account. */
  appAccountToken?: string;
}

/**
 * Asks Apple for the current status of the subscription that `transactionId`
 * belongs to. Tries production first, then the sandbox (TestFlight/review).
 */
export async function appleSubscription(transactionId: string): Promise<AppleResult> {
  for (const env of [Environment.PRODUCTION, Environment.SANDBOX]) {
    try {
      const res = await client(env).getAllSubscriptionStatuses(transactionId);
      let best: AppleResult | null = null;
      for (const group of res.data ?? []) {
        for (const item of group.lastTransactions ?? []) {
          if (!item.signedTransactionInfo) continue;
          const tx = decodeJwsPayload<TransactionPayload>(item.signedTransactionInfo);
          if (!tx.originalTransactionId) continue;
          const renewal = item.signedRenewalInfo
            ? decodeJwsPayload<RenewalPayload>(item.signedRenewalInfo)
            : {};
          const grant = appleGrant(Number(item.status), tx.expiresDate, renewal.gracePeriodExpiresDate);
          if (!best || (grant.active && (!best.grant.active || grant.expiresAt! > best.grant.expiresAt!))) {
            best = { originalTransactionId: tx.originalTransactionId, grant, appAccountToken: tx.appAccountToken };
          }
        }
      }
      if (best) return best;
      throw new Error("No subscription found for this transaction");
    } catch (e) {
      // Not found in production → it's a sandbox purchase; try there.
      if (env === Environment.PRODUCTION && e instanceof APIException && e.httpStatusCode === 404) continue;
      throw e;
    }
  }
  throw new Error("Transaction not found");
}

/** A notification that isn't signed by Apple for this app. Answer 400; Apple never sends these. */
export class InvalidNotification extends Error {}

/**
 * Checks a notification with the production verifier, then the sandbox one.
 * Without the app's Apple ID production can't be verified; then a production
 * notification is used unverified (after the sandbox verifier checked its
 * signature and bundle id and only rejected the environment). That is safe
 * enough: it only says which subscription to look up, and the status always
 * comes from Apple's API.
 *
 * Throws InvalidNotification for a bad payload; any other error is temporary.
 */
export async function checkAppleNotification(
  signedPayload: string,
  verify: (env: Environment) => Promise<ResponseBodyV2DecodedPayload>,
  canVerifyProduction: boolean,
): Promise<{ payload: ResponseBodyV2DecodedPayload; verified: boolean }> {
  if (!signedPayload) throw new InvalidNotification("No signedPayload");
  for (const env of [Environment.PRODUCTION, Environment.SANDBOX]) {
    if (env === Environment.PRODUCTION && !canVerifyProduction) continue;
    try {
      return { payload: await verify(env), verified: true };
    } catch (e) {
      if (!(e instanceof VerificationException) || e.status === VerificationStatus.RETRYABLE_VERIFICATION_FAILURE) throw e;
      // Signed by Apple but meant for the other environment (sandbox payloads carry no app id).
      const otherEnvironment =
        e.status === VerificationStatus.INVALID_ENVIRONMENT ||
        (env === Environment.PRODUCTION && e.status === VerificationStatus.INVALID_APP_IDENTIFIER);
      if (!otherEnvironment) throw new InvalidNotification(`${env}: ${VerificationStatus[e.status]}`);
    }
  }
  let payload: ResponseBodyV2DecodedPayload;
  try {
    payload = decodeJwsPayload<ResponseBodyV2DecodedPayload>(signedPayload);
  } catch {
    throw new InvalidNotification("Not a JWS");
  }
  const environment = payload.data?.environment ?? payload.summary?.environment;
  if (!canVerifyProduction && environment === Environment.PRODUCTION) return { payload, verified: false };
  throw new InvalidNotification(`Unexpected environment ${environment}`);
}

function appAppleId(): number | undefined {
  const id = Number(APPLE_APP_ID.value().trim());
  return Number.isSafeInteger(id) && id > 0 ? id : undefined;
}

// Kept per instance, so the verified certificate chain is cached between notifications.
const verifiers = new Map<Environment, SignedDataVerifier>();

function verifier(env: Environment): SignedDataVerifier {
  let v = verifiers.get(env);
  if (!v) {
    const roots = ROOT_CERTIFICATES.map((name) => readFileSync(new URL(`../../certs/${name}`, import.meta.url)));
    const appId = env === Environment.PRODUCTION ? appAppleId() : undefined;
    // Online checks: certificate revocation (OCSP) and expiry against today's date.
    v = new SignedDataVerifier(roots, true, env, APPLE_BUNDLE_ID.value(), appId);
    verifiers.set(env, v);
  }
  return v;
}

export interface AppleNotification {
  originalTransactionId?: string;
  /** False for a production notification while APPLE_APP_ID isn't set. */
  verified: boolean;
}

/** Verifies an App Store Server Notification (v2) and says which subscription it is about. */
export async function verifyAppleNotification(signedPayload: string): Promise<AppleNotification> {
  const { payload, verified } = await checkAppleNotification(
    signedPayload,
    (env) => verifier(env).verifyAndDecodeNotification(signedPayload),
    appAppleId() !== undefined,
  );
  // The transaction is inside the signed payload, so it needs no check of its own.
  const info = payload.data?.signedTransactionInfo;
  return {
    originalTransactionId: info ? decodeJwsPayload<TransactionPayload>(info).originalTransactionId : undefined,
    verified,
  };
}
