import type { SourceGrant } from "../entitlement.js";

const none: SourceGrant = { active: false, expiresAt: null };

/**
 * Apple subscription status: 1 active, 2 expired, 3 billing retry,
 * 4 billing grace period, 5 revoked.
 */
export function appleGrant(status: number | undefined, expiresDateMs: number | undefined): SourceGrant {
  if ((status === 1 || status === 4) && expiresDateMs) return { active: true, expiresAt: new Date(expiresDateMs) };
  return none;
}

/** Google Play subscriptionsv2 state. A canceled subscription runs until expiry. */
export function googleGrant(state: string | null | undefined, expiryTime: string | null | undefined): SourceGrant {
  const granting = [
    "SUBSCRIPTION_STATE_ACTIVE",
    "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
    "SUBSCRIPTION_STATE_CANCELED",
  ];
  if (state && granting.includes(state) && expiryTime) return { active: true, expiresAt: new Date(expiryTime) };
  return none;
}

/** Stripe subscription status; past_due keeps access while Stripe retries the payment. */
export function stripeGrant(status: string, periodEndSeconds: number | undefined): SourceGrant {
  if (["active", "trialing", "past_due"].includes(status) && periodEndSeconds) {
    return { active: true, expiresAt: new Date(periodEndSeconds * 1000) };
  }
  return none;
}

/** Reads a JWS payload without verifying it. Only for data fetched from Apple over TLS. */
export function decodeJwsPayload<T = Record<string, unknown>>(jws: string): T {
  const part = jws.split(".")[1];
  if (!part) throw new Error("Not a JWS");
  return JSON.parse(Buffer.from(part, "base64url").toString("utf8")) as T;
}
