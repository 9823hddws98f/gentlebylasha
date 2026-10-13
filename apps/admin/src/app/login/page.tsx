"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { Button, Input, Label } from "@/components/ui";
import { signInWithEmail, signInWithGoogle, signOut, useAuth } from "@/lib/auth";

/** Dutch message for a Firebase Auth error; null when there is nothing to say. */
function authErrorMessage(e: unknown): string | null {
  const code = e && typeof e === "object" && "code" in e && typeof e.code === "string" ? e.code : "";
  switch (code) {
    case "auth/popup-closed-by-user":
    case "auth/cancelled-popup-request":
    case "auth/user-cancelled":
      return null; // the user closed the Google window themselves
    case "auth/wrong-password":
    case "auth/invalid-credential":
    case "auth/invalid-login-credentials":
      return "E-mail of wachtwoord klopt niet.";
    case "auth/user-not-found":
      return "Er is geen account met dit e-mailadres.";
    case "auth/invalid-email":
      return "Dit is geen geldig e-mailadres.";
    case "auth/user-disabled":
      return "Dit account is uitgeschakeld.";
    case "auth/too-many-requests":
      return "Te veel pogingen. Wacht een paar minuten en probeer het opnieuw.";
    case "auth/network-request-failed":
      return "Geen verbinding met Firebase. Controleer je internet en probeer het opnieuw.";
    case "auth/popup-blocked":
      return "De browser blokkeerde het Google-venster. Sta pop-ups toe voor deze site.";
    case "auth/unauthorized-domain":
      return "Dit domein is nog niet toegestaan in Firebase Auth (Authorized domains).";
    case "auth/operation-not-allowed":
      return "Deze manier van inloggen staat niet aan in Firebase Auth (Sign-in method).";
    case "auth/account-exists-with-different-credential":
      return "Dit e-mailadres hoort bij een account met een andere inlogmethode.";
    default:
      return code ? `Inloggen mislukt (${code}).` : "Inloggen mislukt. Probeer het opnieuw.";
  }
}

export default function LoginPage() {
  const { user, isAdmin, loading, error: authError } = useAuth();
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!loading && isAdmin) router.replace("/stats");
  }, [loading, isAdmin, router]);

  async function run(action: () => Promise<unknown>) {
    setBusy(true);
    setError(null);
    try {
      await action();
    } catch (e) {
      setError(authErrorMessage(e));
    } finally {
      setBusy(false);
    }
  }

  const signedInWithoutRights = !loading && user && !isAdmin;

  return (
    <main className="grid min-h-screen place-items-center bg-night px-4 py-16">
      <div className="w-full max-w-sm">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src="/gentle_logo.svg" alt="Gentle" width={92} height={45} className="mx-auto mb-10 h-11 w-auto" />

        <div className="rounded-2xl bg-surface p-7 shadow-[0_24px_60px_-20px_rgb(0_0_0/0.6)]">
          <h1 className="font-display text-2xl font-medium tracking-[-0.01em] text-ink">Beheer</h1>

          {signedInWithoutRights ? (
            <div className="mt-4 space-y-4 text-sm text-ink-soft">
              {authError ? (
                <p role="alert" className="text-ember">
                  {authError}
                </p>
              ) : (
                <p>
                  <span className="font-medium text-ink">{user.email}</span> heeft geen beheerrechten. Vraag een
                  andere beheerder om je toe te voegen, en log daarna opnieuw in.
                </p>
              )}
              <Button onClick={() => signOut()} className="w-full">
                Uitloggen
              </Button>
            </div>
          ) : (
            <form
              className="mt-6 space-y-4"
              onSubmit={(e) => {
                e.preventDefault();
                run(() => signInWithEmail(email, password));
              }}
            >
              <div>
                <Label htmlFor="email">E-mail</Label>
                <Input
                  id="email"
                  type="email"
                  autoComplete="username"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                />
              </div>
              <div>
                <Label htmlFor="password">Wachtwoord</Label>
                <Input
                  id="password"
                  type="password"
                  autoComplete="current-password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                />
              </div>
              {error && (
                <p role="alert" className="text-sm text-ember">
                  {error}
                </p>
              )}
              <Button type="submit" variant="primary" busy={busy} className="w-full">
                Inloggen
              </Button>
              <div className="flex items-center gap-3 text-xs text-ink-faint">
                <span className="h-px flex-1 bg-line" /> of <span className="h-px flex-1 bg-line" />
              </div>
              <Button type="button" onClick={() => run(signInWithGoogle)} disabled={busy} className="w-full">
                Doorgaan met Google
              </Button>
            </form>
          )}
        </div>
      </div>
    </main>
  );
}
