"use client";

import { collection, doc, getDocs, limit, onSnapshot, orderBy, query, Timestamp, where } from "firebase/firestore";
import { Search } from "lucide-react";
import { useEffect, useState } from "react";
import { Button, Input, Label, Select } from "@/components/ui";
import { errorMessage } from "@/lib/codes";
import { call, db } from "@/lib/firebase";

interface UserRow {
  id: string;
  name: string;
  email: string;
  createdAt?: Date;
}

interface Premium {
  active: boolean;
  expiresAt: Date | null;
  source: string | null;
  manual?: { active: boolean; expiresAt: Date | null };
}

const SOURCE_LABEL: Record<string, string> = {
  apple: "App Store",
  google: "Google Play",
  stripe: "Stripe (web)",
  code: "Toegangscode",
  manual: "Handmatig",
};

const dateFmt = new Intl.DateTimeFormat("nl-NL", { day: "numeric", month: "short", year: "numeric" });
const ts = (v: unknown) => (v instanceof Timestamp ? v.toDate() : null);

const setManualPremium = call<{ uid: string; active: boolean; expiresAt: string | null }, { success: boolean }>(
  "adminSetManualPremium",
);

function toRow(id: string, v: Record<string, unknown>): UserRow {
  return {
    id,
    name: String(v.name ?? ""),
    email: String(v.email ?? ""),
    createdAt: typeof v.createdAt === "number" ? new Date(v.createdAt) : undefined,
  };
}

export default function UsersPage() {
  const [recent, setRecent] = useState<UserRow[] | null>(null);
  const [results, setResults] = useState<UserRow[] | null>(null);
  const [search, setSearch] = useState("");
  const [selected, setSelected] = useState<UserRow | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    getDocs(query(collection(db, "users"), orderBy("createdAt", "desc"), limit(25)))
      .then((snap) => setRecent(snap.docs.map((d) => toRow(d.id, d.data()))))
      .catch(() => {
        setError("Gebruikers konden niet worden geladen.");
        setRecent([]);
      });
  }, []);

  async function find(e: React.FormEvent) {
    e.preventDefault();
    const email = search.trim().toLowerCase();
    if (!email) return setResults(null);
    const snap = await getDocs(query(collection(db, "users"), where("email", "==", email), limit(10)));
    setResults(snap.docs.map((d) => toRow(d.id, d.data())));
  }

  const list = results ?? recent;

  return (
    <div className="mx-auto max-w-5xl">
      <header className="mb-8">
        <h1 className="font-display text-[2rem] leading-tight font-medium tracking-[-0.02em] text-ink">Gebruikers</h1>
        <p className="mt-1.5 max-w-prose text-[15px] text-ink-soft">
          Zoek een gebruiker op e-mail om premium te bekijken of handmatig te geven.
        </p>
      </header>

      <form onSubmit={find} className="mb-5 flex max-w-lg gap-2">
        <div className="relative flex-1">
          <Search className="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-ink-faint" aria-hidden />
          <Input
            type="search"
            aria-label="E-mailadres"
            placeholder="Exact e-mailadres"
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              if (!e.target.value) setResults(null);
            }}
            className="pl-9"
          />
        </div>
        <Button type="submit">Zoeken</Button>
      </form>

      {error && <p className="mb-3 text-sm text-ember">{error}</p>}

      <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_340px]">
        <div>
          <p className="mb-2 text-[13px] text-ink-faint">{results ? "Zoekresultaat" : "Nieuwste aanmeldingen"}</p>
          {list === null ? (
            <div className="h-64 animate-pulse rounded-2xl border border-line bg-surface" aria-busy="true" />
          ) : list.length === 0 ? (
            <div className="rounded-2xl border border-dashed border-line-strong px-6 py-12 text-center text-sm text-ink-soft">
              {results ? "Geen gebruiker met dit e-mailadres." : "Nog geen gebruikers."}
            </div>
          ) : (
            <ul className="divide-y divide-line overflow-hidden rounded-2xl border border-line bg-surface">
              {list.map((u) => (
                <li key={u.id}>
                  <button
                    onClick={() => setSelected(u)}
                    aria-current={selected?.id === u.id}
                    className={`flex w-full items-center justify-between gap-4 px-4 py-3 text-left transition-colors hover:bg-paper ${
                      selected?.id === u.id ? "bg-dusk-wash" : ""
                    }`}
                  >
                    <span className="min-w-0">
                      <span className="block truncate font-medium text-ink">{u.email || "—"}</span>
                      <span className="block truncate text-sm text-ink-faint">{u.name || "Geen naam"}</span>
                    </span>
                    {u.createdAt && (
                      <span className="tabular shrink-0 text-sm text-ink-faint">{dateFmt.format(u.createdAt)}</span>
                    )}
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>

        {selected ? (
          <UserPanel key={selected.id} user={selected} />
        ) : (
          <div className="hidden rounded-2xl border border-dashed border-line-strong p-6 text-sm text-ink-soft lg:block">
            Kies een gebruiker om premium te zien.
          </div>
        )}
      </div>
    </div>
  );
}

function UserPanel({ user }: { user: UserRow }) {
  const [premium, setPremium] = useState<Premium | null>(null);
  const [months, setMonths] = useState("12");
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  useEffect(
    () =>
      onSnapshot(doc(db, "subscriptions", user.id), (snap) => {
        const v = snap.data();
        const manual = v?.sources?.manual;
        setPremium({
          active: v?.active === true && (ts(v?.expiresAt) === null || ts(v?.expiresAt)! > new Date()),
          expiresAt: ts(v?.expiresAt),
          source: v?.source ?? null,
          manual: manual ? { active: manual.active === true, expiresAt: ts(manual.expiresAt) } : undefined,
        });
      }),
    [user.id],
  );

  async function grant(active: boolean) {
    setBusy(true);
    setMessage(null);
    try {
      let expiresAt: string | null = null;
      if (active && months !== "unlimited") {
        const d = new Date();
        d.setMonth(d.getMonth() + Number(months));
        expiresAt = d.toISOString();
      }
      await setManualPremium({ uid: user.id, active, expiresAt });
      setMessage(active ? "Premium gegeven." : "Handmatige premium ingetrokken.");
    } catch (e) {
      setMessage(errorMessage(e));
    } finally {
      setBusy(false);
    }
  }

  return (
    <section aria-label={`Premium voor ${user.email}`} className="h-fit rounded-2xl border border-line bg-surface p-5">
      <h2 className="truncate font-semibold text-ink">{user.email}</h2>
      <p className="mt-0.5 font-mono text-xs text-ink-faint">{user.id}</p>

      <div className="mt-5 rounded-xl bg-paper px-4 py-3 text-sm">
        {premium === null ? (
          <span className="text-ink-faint">Laden…</span>
        ) : premium.active ? (
          <>
            <p className="font-medium text-leaf-ink">Premium actief</p>
            <p className="text-ink-soft">
              {premium.expiresAt ? `Tot ${dateFmt.format(premium.expiresAt)}` : "Onbeperkt"} · via{" "}
              {SOURCE_LABEL[premium.source ?? ""] ?? premium.source}
            </p>
          </>
        ) : (
          <p className="text-ink-soft">Geen premium</p>
        )}
      </div>

      <div className="mt-5">
        <Label htmlFor="manual-months">Handmatig premium geven</Label>
        <div className="flex gap-2">
          <Select id="manual-months" value={months} onChange={(e) => setMonths(e.target.value)} className="flex-1">
            <option value="1">1 maand</option>
            <option value="3">3 maanden</option>
            <option value="6">6 maanden</option>
            <option value="12">1 jaar</option>
            <option value="unlimited">Onbeperkt</option>
          </Select>
          <Button variant="primary" busy={busy} onClick={() => grant(true)}>
            Geven
          </Button>
        </div>
        {premium?.manual?.active && (
          <Button variant="danger" disabled={busy} onClick={() => grant(false)} className="mt-2 -ml-3">
            Handmatige premium intrekken
          </Button>
        )}
        <p className="mt-2 text-xs text-ink-faint">
          Werkt naast abonnementen en codes; de langste geldige toegang telt.
        </p>
        <div aria-live="polite">{message && <p className="mt-3 text-sm text-ink-soft">{message}</p>}</div>
      </div>
    </section>
  );
}
