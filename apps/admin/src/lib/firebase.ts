import { getApp, getApps, initializeApp } from "firebase/app";
import { connectAuthEmulator, getAuth } from "firebase/auth";
import { connectFirestoreEmulator, getFirestore } from "firebase/firestore";
import { connectFunctionsEmulator, getFunctions, httpsCallable } from "firebase/functions";
import { connectStorageEmulator, getStorage } from "firebase/storage";

// Local development against the Firebase emulators (see README): a demo
// project, so nothing can reach production.
const emulators = process.env.NEXT_PUBLIC_FIREBASE_EMULATORS === "1";

// Public web config (same as lib/firebase_options.dart in the app).
const config = {
  apiKey: "AIzaSyArdwqJWklzqJzHKNgcrIcRx9Herhs8Es8",
  appId: "1:65622286155:web:cf2c7cb81edc71f31e12ce",
  messagingSenderId: "65622286155",
  projectId: emulators ? "demo-gentle" : "sleeptales-4bac2",
  authDomain: "sleeptales-4bac2.firebaseapp.com",
  storageBucket: emulators ? "demo-gentle.appspot.com" : "sleeptales-4bac2.appspot.com",
};

const fresh = getApps().length === 0;
export const app = fresh ? initializeApp(config) : getApp();
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
// Must match setGlobalOptions({ region }) in functions/src/index.ts.
const functions = getFunctions(app, "us-central1");

if (emulators && fresh) {
  connectAuthEmulator(auth, "http://127.0.0.1:9099", { disableWarnings: true });
  connectFirestoreEmulator(db, "127.0.0.1", 8080);
  connectStorageEmulator(storage, "127.0.0.1", 9199);
  connectFunctionsEmulator(functions, "127.0.0.1", 5001);
}

const isPlainObject = (v: unknown): v is Record<string, unknown> =>
  typeof v === "object" && v !== null && Object.getPrototypeOf(v) === Object.prototype;

/**
 * The callable SDK encodes `undefined` as `null`, which turns "not given" into
 * an explicit null. Dropping those keys keeps optional fields optional.
 */
const withoutUndefined = <T,>(data: T): T =>
  isPlainObject(data) ? (Object.fromEntries(Object.entries(data).filter(([, v]) => v !== undefined)) as T) : data;

export const call = <Req, Res>(name: string) => {
  const fn = httpsCallable<Req, Res>(functions, name);
  return async (data: Req) => (await fn(withoutUndefined(data))).data;
};
