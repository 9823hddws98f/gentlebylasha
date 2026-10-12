import { androidpublisher, auth } from "@googleapis/androidpublisher";
import { defineString } from "firebase-functions/params";
import type { SourceGrant } from "../entitlement.js";
import { googleGrant } from "./grants.js";

const ANDROID_PACKAGE = defineString("ANDROID_PACKAGE", { default: "com.mezz.gentle" });

// Uses the functions' service account; invite it in Play Console
// (Users and permissions) with "View financial data" and "Manage orders".
const api = () =>
  androidpublisher({
    version: "v3",
    auth: new auth.GoogleAuth({ scopes: ["https://www.googleapis.com/auth/androidpublisher"] }),
  });

export interface GoogleResult {
  grant: SourceGrant;
  productId?: string;
}

/** Current state of a Play subscription; acknowledges it if needed (else Google refunds after 3 days). */
export async function googleSubscription(purchaseToken: string): Promise<GoogleResult> {
  const packageName = ANDROID_PACKAGE.value();
  const { data } = await api().purchases.subscriptionsv2.get({ packageName, token: purchaseToken });
  const item = data.lineItems?.[0];
  const grant = googleGrant(data.subscriptionState, item?.expiryTime);

  if (grant.active && data.acknowledgementState === "ACKNOWLEDGEMENT_STATE_PENDING" && item?.productId) {
    await api().purchases.subscriptions.acknowledge({
      packageName,
      subscriptionId: item.productId,
      token: purchaseToken,
      requestBody: {},
    });
  }
  return { grant, productId: item?.productId ?? undefined };
}
