// Shared setup for the integration tests. They run against the emulators of the
// demo project (never a real one): the callables through the client SDK as real
// signed-in users, seeding and checking through firebase-admin.
import { randomUUID } from "node:crypto";
import { deleteApp, type FirebaseApp, initializeApp as initializeClientApp } from "firebase/app";
import { connectAuthEmulator, getAuth as getClientAuth, signInWithEmailAndPassword, type User } from "firebase/auth";
import { connectFunctionsEmulator, getFunctions, httpsCallable } from "firebase/functions";
import { getApps, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { afterAll, expect } from "vitest";

export const PROJECT_ID = "demo-gentle";
export const BUCKET = `${PROJECT_ID}.appspot.com`;

// emulators:exec sets these; the defaults match firebase.json.
process.env.FIRESTORE_EMULATOR_HOST ??= "127.0.0.1:8080";
process.env.FIREBASE_AUTH_EMULATOR_HOST ??= "127.0.0.1:9099";
process.env.FIREBASE_STORAGE_EMULATOR_HOST ??= "127.0.0.1:9199";
const FUNCTIONS_HOST = process.env.FUNCTIONS_EMULATOR_HOST ?? "127.0.0.1:5001";

if (!getApps().length) initializeApp({ projectId: PROJECT_ID, storageBucket: BUCKET });
export const db = getFirestore();
export const adminAuth = getAuth();
export const bucket = getStorage().bucket();

export const DAY = 86_400_000;
export const PASSWORD = "test-password";

/** Empties the Firestore emulator. Auth users stay; every test makes its own. */
export async function clearFirestore() {
  const res = await fetch(
    `http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/${PROJECT_ID}/databases/(default)/documents`,
    { method: "DELETE" },
  );
  if (!res.ok) throw new Error(`Clearing Firestore failed: ${res.status}`);
}

/** An Auth user made with the Admin SDK, optionally with the admin claim. */
export async function createAuthUser(opts: { admin?: boolean; name?: string } = {}) {
  const email = `${opts.name ?? "user"}-${randomUUID().slice(0, 8)}@gentle.test`;
  const user = await adminAuth.createUser({ email, password: PASSWORD, displayName: opts.name ?? "Test" });
  if (opts.admin) await adminAuth.setCustomUserClaims(user.uid, { admin: true });
  return { uid: user.uid, email };
}

export interface Client {
  uid: string;
  email: string;
  user: User;
  /** Calls a callable as this user and returns its data. */
  call: <T = any>(name: string, data?: unknown) => Promise<T>;
}

const clientApps: FirebaseApp[] = [];
afterAll(async () => {
  await Promise.all(clientApps.splice(0).map((app) => deleteApp(app)));
});

function clientApp() {
  const app = initializeClientApp(
    { apiKey: "demo-key", projectId: PROJECT_ID, appId: "1:1:web:1", authDomain: `${PROJECT_ID}.firebaseapp.com` },
    `client-${randomUUID()}`,
  );
  clientApps.push(app);
  const auth = getClientAuth(app);
  connectAuthEmulator(auth, `http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}`, { disableWarnings: true });
  const functions = getFunctions(app, "us-central1");
  const [host, port] = FUNCTIONS_HOST.split(":");
  connectFunctionsEmulator(functions, host, Number(port));
  const call = <T>(name: string, data?: unknown) =>
    httpsCallable<unknown, T>(functions, name)(data ?? null).then((r) => r.data);
  return { auth, call };
}

/** Signs in with the client SDK, as the app does. */
export async function signIn(email: string): Promise<Client> {
  const { auth, call } = clientApp();
  const { user } = await signInWithEmailAndPassword(auth, email, PASSWORD);
  return { uid: user.uid, email, user, call };
}

/** A new account, signed in. */
export async function createClient(opts: { admin?: boolean; name?: string } = {}): Promise<Client> {
  const { email } = await createAuthUser(opts);
  return signIn(email);
}

/** Calls without signing in. */
export function anonymous() {
  return clientApp().call;
}

/** Expects a callable to fail with this HttpsError code (and message, if given). */
export async function expectError(promise: Promise<unknown>, code: string, message?: string | RegExp) {
  const error = await promise.then(
    () => {
      throw new Error(`Expected functions/${code}, but the call succeeded`);
    },
    (e: { code?: string; message?: string }) => e,
  );
  expect(error.code).toBe(`functions/${code}`);
  if (message !== undefined) expect(error.message).toMatch(message);
}

export async function data(path: string) {
  return (await db.doc(path).get()).data();
}

export const millis = (value: unknown): number | null => (value instanceof Timestamp ? value.toMillis() : null);

/** admin_log entries of one action, oldest first. */
export async function adminLog(action: string) {
  const snap = await db.collection("admin_log").where("action", "==", action).get();
  return snap.docs.map((d) => d.data()).sort((a, b) => (millis(a.at) ?? 0) - (millis(b.at) ?? 0));
}
