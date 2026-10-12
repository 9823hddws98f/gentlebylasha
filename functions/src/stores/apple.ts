import { APIException, AppStoreServerAPIClient, Environment } from "@apple/app-store-server-library";
import { defineSecret, defineString } from "firebase-functions/params";
import type { SourceGrant } from "../entitlement.js";
import { appleGrant, decodeJwsPayload } from "./grants.js";

// App Store Connect → Users and Access → Integrations → In-App Purchase key.
export const APPLE_IAP_KEY = defineSecret("APPLE_IAP_KEY");
const APPLE_IAP_KEY_ID = defineString("APPLE_IAP_KEY_ID", { default: "" });
const APPLE_IAP_ISSUER_ID = defineString("APPLE_IAP_ISSUER_ID", { default: "" });
const APPLE_BUNDLE_ID = defineString("APPLE_BUNDLE_ID", { default: "io.sleeptales.sleeptales" });

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

/** originalTransactionId from an App Store Server Notification (v2). */
export function appleNotificationTransactionId(signedPayload: string): string | undefined {
  const payload = decodeJwsPayload<{ data?: { signedTransactionInfo?: string } }>(signedPayload);
  const info = payload.data?.signedTransactionInfo;
  return info ? decodeJwsPayload<TransactionPayload>(info).originalTransactionId : undefined;
}
