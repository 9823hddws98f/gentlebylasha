import { sign } from "node:crypto";
import { getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { defineSecret, defineString } from "firebase-functions/params";

// Apple Developer → Certificates, Identifiers & Profiles → Keys: a key with
// "Sign in with Apple" enabled.
export const APPLE_SIGNIN_KEY = defineSecret("APPLE_SIGNIN_KEY");
const APPLE_SIGNIN_KEY_ID = defineString("APPLE_SIGNIN_KEY_ID", { default: "" });
const APPLE_TEAM_ID = defineString("APPLE_TEAM_ID", { default: "" });
const APPLE_SIGNIN_CLIENT_ID = defineString("APPLE_SIGNIN_CLIENT_ID", { default: "io.sleeptales.sleeptales" });

interface SecretParams {
  teamId: string;
  keyId: string;
  clientId: string;
  privateKey: string;
}

/** Short-lived client secret (ES256 JWT) for Apple's token endpoints. */
export function appleClientSecret(p: SecretParams, now = new Date()): string {
  const iat = Math.floor(now.getTime() / 1000);
  const b64 = (o: object) => Buffer.from(JSON.stringify(o)).toString("base64url");
  const unsigned = `${b64({ alg: "ES256", kid: p.keyId })}.${b64({
    iss: p.teamId,
    iat,
    exp: iat + 300,
    aud: "https://appleid.apple.com",
    sub: p.clientId,
  })}`;
  const signature = sign("sha256", Buffer.from(unsigned), { key: p.privateKey, dsaEncoding: "ieee-p1363" });
  return `${unsigned}.${signature.toString("base64url")}`;
}

function params(): SecretParams | null {
  const p = {
    teamId: APPLE_TEAM_ID.value(),
    keyId: APPLE_SIGNIN_KEY_ID.value(),
    clientId: APPLE_SIGNIN_CLIENT_ID.value(),
    privateKey: APPLE_SIGNIN_KEY.value(),
  };
  return p.teamId && p.keyId && p.privateKey ? p : null;
}

const tokenRef = (uid: string) => getFirestore().collection("apple_tokens").doc(uid);

/** Exchanges the authorization code from sign-in for a refresh token we can revoke later. */
export async function storeAppleRefreshToken(uid: string, authorizationCode: string) {
  const p = params();
  if (!p) return;
  const res = await fetch("https://appleid.apple.com/auth/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: p.clientId,
      client_secret: appleClientSecret(p),
      code: authorizationCode,
      grant_type: "authorization_code",
    }),
  });
  if (!res.ok) throw new Error(`Apple token exchange failed: ${res.status}`);
  const { refresh_token } = (await res.json()) as { refresh_token?: string };
  if (refresh_token) await tokenRef(uid).set({ refreshToken: refresh_token });
}

/** Required by Apple when an account that used Sign in with Apple is deleted. */
export async function revokeAppleToken(uid: string) {
  const ref = tokenRef(uid);
  const token = (await ref.get()).data()?.refreshToken as string | undefined;
  const p = params();
  if (token && p) {
    const res = await fetch("https://appleid.apple.com/auth/revoke", {
      method: "POST",
      headers: { "content-type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        client_id: p.clientId,
        client_secret: appleClientSecret(p),
        token,
        token_type_hint: "refresh_token",
      }),
    });
    if (!res.ok) logger.error("Apple token revoke failed", { uid, status: res.status });
  }
  await ref.delete();
}
