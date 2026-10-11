import { getApp, getApps, initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getFunctions, httpsCallable } from "firebase/functions";

// Public web config (same as lib/firebase_options.dart in the app).
const config = {
  apiKey: "AIzaSyArdwqJWklzqJzHKNgcrIcRx9Herhs8Es8",
  appId: "1:65622286155:web:cf2c7cb81edc71f31e12ce",
  messagingSenderId: "65622286155",
  projectId: "sleeptales-4bac2",
  authDomain: "sleeptales-4bac2.firebaseapp.com",
  storageBucket: "sleeptales-4bac2.appspot.com",
};

export const app = getApps().length ? getApp() : initializeApp(config);
export const auth = getAuth(app);
export const db = getFirestore(app);
// Must match setGlobalOptions({ region }) in functions/src/index.ts.
const functions = getFunctions(app, "us-central1");

export const call = <Req, Res>(name: string) => {
  const fn = httpsCallable<Req, Res>(functions, name);
  return async (data: Req) => (await fn(data)).data;
};
