"use client";

import {
  GoogleAuthProvider,
  onIdTokenChanged,
  signInWithEmailAndPassword,
  signInWithPopup,
  signOut as fbSignOut,
  type User,
} from "firebase/auth";
import { createContext, useContext, useEffect, useState } from "react";
import { auth } from "./firebase";

interface AuthState {
  user: User | null;
  isAdmin: boolean;
  loading: boolean;
  /** Set when the signed-in user's rights could not be checked (e.g. offline). */
  error: string | null;
}

const AuthContext = createContext<AuthState>({ user: null, isAdmin: false, loading: true, error: null });

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<AuthState>({ user: null, isAdmin: false, loading: true, error: null });

  useEffect(
    () =>
      onIdTokenChanged(auth, async (user) => {
        if (!user) return setState({ user: null, isAdmin: false, loading: false, error: null });
        try {
          const token = await user.getIdTokenResult();
          setState({ user, isAdmin: token.claims.admin === true, loading: false, error: null });
        } catch {
          // Without this the app would wait forever on a blank screen.
          setState({
            user,
            isAdmin: false,
            loading: false,
            error: "Je rechten konden niet worden gecontroleerd. Controleer je verbinding en log opnieuw in.",
          });
        }
      }),
    [],
  );

  return <AuthContext value={state}>{children}</AuthContext>;
}

export const useAuth = () => useContext(AuthContext);

export const signInWithEmail = (email: string, password: string) =>
  signInWithEmailAndPassword(auth, email, password);

export const signInWithGoogle = () => signInWithPopup(auth, new GoogleAuthProvider());

export const signOut = () => fbSignOut(auth);
