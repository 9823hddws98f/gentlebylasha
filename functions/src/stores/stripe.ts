import { defineSecret, defineString } from "firebase-functions/params";
import Stripe from "stripe";
import type { SourceGrant } from "../entitlement.js";
import { stripeGrant } from "./grants.js";

export const STRIPE_SECRET_KEY = defineSecret("STRIPE_SECRET_KEY");
export const STRIPE_WEBHOOK_SECRET = defineSecret("STRIPE_WEBHOOK_SECRET");
export const STRIPE_PRICE_MONTHLY = defineString("STRIPE_PRICE_MONTHLY", { default: "" });
export const STRIPE_PRICE_YEARLY = defineString("STRIPE_PRICE_YEARLY", { default: "" });
/** Where Stripe sends the customer back to: the customer webapp. */
export const APP_URL = defineString("APP_URL", { default: "https://gentle-mu.vercel.app" });

export const stripe = () => new Stripe(STRIPE_SECRET_KEY.value());

export function subscriptionGrant(sub: Stripe.Subscription): SourceGrant {
  // The period end lives on the subscription items in current API versions.
  const periodEnd = Math.max(0, ...sub.items.data.map((i) => i.current_period_end ?? 0));
  return stripeGrant(sub.status, periodEnd || undefined);
}
