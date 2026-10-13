"use client";

import {
  collection,
  doc,
  getDocs,
  limit,
  onSnapshot,
  orderBy,
  query,
  type QueryConstraint,
  type QueryDocumentSnapshot,
  startAfter,
  Timestamp,
} from "firebase/firestore";
import { Search } from "lucide-react";
import { useEffect, useState } from "react";
import { Button, Input, Label } from "@/components/ui";
import { useAuth } from "@/lib/auth";
import { errorMessage } from "@/lib/codes";
import { call, db } from "@/lib/firebase";

const PAGE_SIZE = 25;

interface UserRow {
  id: string;
  name: string;
  email: string;
  createdAt?: Date;
}

/** Firebase Auth account, as returned by adminFindUser. */
interface Account {
  uid: string;
  email: string;
  name: string;
  createdAt: string;
  lastSignInAt: string | null;
  providers: string[];
  admin: boolean;
  disabled: boolean;
}

interface Premium {
  active: boolean;
  expiresAt: Date | null;
  source: string | null;
  /** `current`: active and not yet expired. */
  manual?: { active: boolean; expiresAt: Date | null; current: boolean };
}

const SOURCE_LABEL: Record<string, string> = {
  apple: "App Store",
  google: "Google Play",
  stripe: "Stripe (web)",
  code: "Toegangscode",
  manual: "Handmatig",
};

const PROVIDER_LABEL: Record<string, string> = {
  password: "E-mail en wachtwoord",
  "google.com": "Google",
  "apple.com": "Apple",
  phone: "Telefoonnummer",
};

const PRESETS = [
  { months: 1, label: "1 maand" },
  { months: 3, label: "3 maanden" },
  { months: 6, label: "6 maanden" },
  { months: 12, label: "1 jaar" },
];

const dateFmt = new Intl.DateTimeFormat("nl-NL", { day: "numeric", month: "short", year: "numeric" });
const dateTimeFmt = new Intl.DateTimeFormat("nl-NL", {
  day: "numeric",
  month: "short",
  year: "numeric",
  hour: "2-digit",
  minute: "2-digit",
});
const ts = (v: unknown) => (v instanceof Timestamp ? v.toDate() : null);

const findUser = call<{ query: string }, { user: Account | null }>("adminFindUser");
const setAdmin = call<{ uid: string; admin: boolean }, { success: boolean }>("adminSetAdmin");
const deleteUser = call<{ uid: string }, { success: boolean }>("adminDeleteUser");
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

/** Local calendar date as a date-input value (YYYY-MM-DD). */
const toDateValue = (d: Date) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;

/** Adds months, clamping to the month's last day: 31 Jan + 1 month = 28/29 Feb, not 3 Mar. */
function addMonths(from: Date, months: number) {
  const target = new Date(from.getFullYear(), from.getMonth() + months, 1);
  const lastDay = new Date(target.getFullYear(), target.getMonth() + 1, 0).getDate();
  target.setDate(Math.min(from.getDate(), lastDay));
  return target;
}

/** "Tot en met" a date: access runs to the end of that day, local time. */
function endOfDay(value: string) {
  const [y, m, d] = value.split("-").map(Number);
  return new Date(y, m - 1, d, 23, 59, 59, 999);
}

/** One page of newest sign-ups, after `after` when given. */
async function fetchUsers(after: QueryDocumentSnapshot | null) {
  const constraints: QueryConstraint[] = [orderBy("createdAt", "desc")];
  if (after) constraints.push(startAfter(after));
  constraints.push(limit(PAGE_SIZE));
  const snap = await getDocs(query(collection(db, "users"), ...constraints));
  return {
    rows: snap.docs.map((d) => toRow(d.id, d.data())),
    cursor: snap.docs.at(-1) ?? after,
    hasMore: snap.docs.length === PAGE_SIZE,
  };
}

export default function UsersPage() {
  const [recent, setRecent] = useState<UserRow[] | null>(null);
  const [cursor, setCursor] = useState<QueryDocumentSnapshot | null>(null);
  const [hasMore, setHasMore] = useState(false);
  const [loadingMore, setLoadingMore] = useState(false);
  const [search, setSearch] = useState("");
  const [searching, setSearching] = useState(false);
  // `account: null` = searched, nothing found.
  const [result, setResult] = useState<{ account: Account | null } | null>(null);
  const [selected, setSelected] = useState<{ row: UserRow; account?: Account } | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchUsers(null)
      .then((page) => {
        setRecent(page.rows);
        setCursor(page.cursor);
        setHasMore(page.hasMore);
      })
      .catch(() => {
        setError("Gebruikers konden niet worden geladen.");
        setRecent([]);
      });
  }, []);

  async function loadMore() {
    setLoadingMore(true);
    setError(null);
    try {
      const page = await fetchUsers(cursor);
      // A user deleted or re-sorted in between could show up twice; keep the first.
      setRecent((prev) => {
        const seen = new Set(prev?.map((u) => u.id));
        return [...(prev ?? []), ...page.rows.filter((u) => !seen.has(u.id))];
      });
      setCursor(page.cursor);
      setHasMore(page.hasMore);
    } catch {
      setError("Meer gebruikers laden mislukt.");
    } finally {
      setLoadingMore(false);
    }
  }

  async function find(e: React.FormEvent) {
    e.preventDefault();
    const q = search.trim();
    if (!q) return setResult(null);
    setSearching(true);
    setError(null);
    try {
      const { user } = await findUser({ query: q.includes("@") ? q.toLowerCase() : q });
      setResult({ account: user });
      setSelected(user ? { row: accountRow(user), account: user } : null);
    } catch (err) {
      setError(`Zoeken mislukt: ${errorMessage(err)}`);
    } finally {
      setSearching(false);
    }
  }

  function removed(uid: string) {
    setSelected(null);
    setRecent((prev) => prev?.filter((u) => u.id !== uid) ?? prev);
    setResult((prev) => (prev?.account?.uid === uid ? { account: null } : prev));
  }

  const list = result ? (result.account ? [accountRow(result.account)] : []) : recent;

  return (
    <div className="mx-auto max-w-5xl">
      <header className="mb-8">
        <h1 className="font-display text-[2rem] leading-tight font-medium tracking-[-0.02em] text-ink">Gebruikers</h1>
        <p className="mt-1.5 max-w-prose text-[15px] text-ink-soft">
          Zoek een account op e-mail of uid om het te bekijken, premium te geven of rechten te wijzigen.
        </p>
      </header>

      <form onSubmit={find} className="mb-5 flex max-w-lg gap-2">
        <div className="relative flex-1">
          <Search className="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-ink-faint" aria-hidden />
          <Input
            type="search"
            aria-label="E-mailadres of uid"
            placeholder="Exact e-mailadres of uid"
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              if (!e.target.value) setResult(null);
            }}
            className="pl-9"
          />
        </div>
        <Button type="submit" busy={searching}>
          Zoeken
        </Button>
      </form>

      <div aria-live="polite">{error && <p className="mb-3 text-sm text-ember">{error}</p>}</div>

      <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_340px]">
        <div>
          <p className="mb-2 text-[13px] text-ink-faint">{result ? "Zoekresultaat" : "Nieuwste aanmeldingen"}</p>
          {list === null ? (
            <div className="h-64 animate-pulse rounded-2xl border border-line bg-surface" aria-busy="true" />
          ) : list.length === 0 ? (
            <div className="rounded-2xl border border-dashed border-line-strong px-6 py-12 text-center text-sm text-ink-soft">
              {result ? "Geen account gevonden." : "Nog geen gebruikers."}
            </div>
          ) : (
            <>
              <ul className="divide-y divide-line overflow-hidden rounded-2xl border border-line bg-surface">
                {list.map((u) => (
                  <li key={u.id}>
                    <button
                      onClick={() => selected?.row.id !== u.id && setSelected({ row: u })}
                      aria-current={selected?.row.id === u.id}
                      className={`flex w-full items-center justify-between gap-4 px-4 py-3 text-left transition-colors hover:bg-paper ${
                        selected?.row.id === u.id ? "bg-dusk-wash" : ""
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
              {!result && hasMore && (
                <Button className="mt-3 w-full" busy={loadingMore} onClick={loadMore}>
                  Meer laden
                </Button>
              )}
            </>
          )}
        </div>

        {selected ? (
          <UserPanel key={selected.row.id} row={selected.row} initial={selected.account} onDeleted={removed} />
        ) : (
          <div className="hidden rounded-2xl border border-dashed border-line-strong p-6 text-sm text-ink-soft lg:block">
            Kies een gebruiker om account en premium te zien.
          </div>
        )}
      </div>
    </div>
  );
}

function accountRow(a: Account): UserRow {
  return { id: a.uid, email: a.email, name: a.name, createdAt: new Date(a.createdAt) };
}

function UserPanel({
  row,
  initial,
  onDeleted,
}: {
  row: UserRow;
  initial?: Account;
  onDeleted: (uid: string) => void;
}) {
  const { user: me } = useAuth();
  // undefined = loading, null = no Auth account for this uid.
  const [account, setAccount] = useState<Account | null | undefined>(initial);
  const [accountError, setAccountError] = useState<string | null>(null);
  const [premium, setPremium] = useState<Premium | null>(null);
  const [premiumError, setPremiumError] = useState<string | null>(null);

  useEffect(() => {
    if (initial) return;
    let cancelled = false;
    findUser({ query: row.id })
      .then(({ user }) => !cancelled && setAccount(user))
      .catch((e) => !cancelled && setAccountError(`Account laden mislukt: ${errorMessage(e)}`));
    return () => {
      cancelled = true;
    };
  }, [row.id, initial]);

  useEffect(
    () =>
      onSnapshot(
        doc(db, "subscriptions", row.id),
        (snap) => {
          const v = snap.data();
          const manual = v?.sources?.manual;
          const now = new Date();
          const manualExpires = ts(manual?.expiresAt);
          setPremiumError(null);
          setPremium({
            active: v?.active === true && (ts(v?.expiresAt) === null || ts(v?.expiresAt)! > now),
            expiresAt: ts(v?.expiresAt),
            source: v?.source ?? null,
            manual: manual
              ? {
                  active: manual.active === true,
                  expiresAt: manualExpires,
                  current: manual.active === true && (manualExpires === null || manualExpires > now),
                }
              : undefined,
          });
        },
        () => setPremiumError("Premium kon niet worden geladen."),
      ),
    [row.id],
  );

  const email = account?.email || row.email;
  const isMe = me?.uid === row.id;

  return (
    <section aria-label={`Gebruiker ${email || row.id}`} className="h-fit rounded-2xl border border-line bg-surface p-5">
      <h2 className="truncate font-semibold text-ink" title={email}>
        {email || "Geen e-mailadres"}
      </h2>
      <p className="truncate text-sm text-ink-soft">{account?.name || row.name || "Geen naam"}</p>
      <p className="mt-0.5 font-mono text-xs break-all text-ink-faint select-all">{row.id}</p>

      {account && (account.admin || account.disabled || isMe) && (
        <div className="mt-3 flex flex-wrap gap-1.5">
          {account.admin && (
            <span className="inline-flex rounded-full bg-dusk-wash px-2 py-0.5 text-xs font-medium text-dusk-ink ring-1 ring-dusk/25 ring-inset">
              Admin
            </span>
          )}
          {account.disabled && (
            <span className="inline-flex rounded-full bg-ember-wash px-2 py-0.5 text-xs font-medium text-ember ring-1 ring-ember/20 ring-inset">
              Uitgeschakeld
            </span>
          )}
          {isMe && (
            <span className="inline-flex rounded-full bg-paper px-2 py-0.5 text-xs font-medium text-ink-soft ring-1 ring-line-strong ring-inset">
              Jij
            </span>
          )}
        </div>
      )}

      <div className="mt-4 text-sm">
        {account === undefined ? (
          accountError ? (
            <p className="text-ember">{accountError}</p>
          ) : (
            <p className="text-ink-faint">Account laden…</p>
          )
        ) : account === null ? (
          <p className="text-ink-soft">Geen account in Firebase Auth gevonden; alleen het profiel bestaat nog.</p>
        ) : (
          <dl className="grid grid-cols-[auto_minmax(0,1fr)] gap-x-4 gap-y-1.5">
            <dt className="text-ink-faint">Inloggen met</dt>
            <dd className="text-ink">
              {account.providers.length
                ? account.providers.map((p) => PROVIDER_LABEL[p] ?? p).join(", ")
                : "Onbekend"}
            </dd>
            <dt className="text-ink-faint">Aangemaakt</dt>
            <dd className="tabular text-ink">{dateFmt.format(new Date(account.createdAt))}</dd>
            <dt className="text-ink-faint">Laatst ingelogd</dt>
            <dd className="tabular text-ink">
              {account.lastSignInAt ? dateTimeFmt.format(new Date(account.lastSignInAt)) : "Nooit"}
            </dd>
          </dl>
        )}
      </div>

      <div className="mt-5 rounded-xl bg-paper px-4 py-3 text-sm">
        {premiumError ? (
          <p className="text-ember">{premiumError}</p>
        ) : premium === null ? (
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
        {premium?.manual?.current && premium.source !== "manual" && (
          <p className="text-ink-faint">
            Handmatig: {premium.manual.expiresAt ? `tot en met ${dateFmt.format(premium.manual.expiresAt)}` : "onbeperkt"}
          </p>
        )}
      </div>

      {account !== null && <ManualPremium uid={row.id} manual={premium?.manual} />}

      {account && (
        <AccountActions account={account} isMe={isMe} onChanged={setAccount} onDeleted={() => onDeleted(account.uid)} />
      )}
    </section>
  );
}

function ManualPremium({ uid, manual }: { uid: string; manual?: Premium["manual"] }) {
  // The panel only mounts after a click, so reading the clock here is safe.
  const [today] = useState(() => toDateValue(new Date()));
  const [until, setUntil] = useState(() => toDateValue(addMonths(new Date(), 12)));
  const [unlimited, setUnlimited] = useState(false);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<{ ok: boolean; text: string } | null>(null);

  const presetValue = (months: number) => toDateValue(addMonths(endOfDay(today), months));

  async function grant(active: boolean) {
    setMessage(null);
    let expiresAt: Date | null = null;
    if (active && !unlimited) {
      if (!until) return setMessage({ ok: false, text: "Kies een datum of Onbeperkt." });
      if (until < today) return setMessage({ ok: false, text: "Kies een datum vanaf vandaag." });
      expiresAt = endOfDay(until);
      // Giving premium overwrites the manual grant; don't cut a longer one short by accident.
      const current = manual?.current ? manual.expiresAt : undefined;
      if (current !== undefined && (current === null || current > expiresAt)) {
        const now = current === null ? "onbeperkt" : `tot en met ${dateFmt.format(current)}`;
        if (!confirm(`Deze gebruiker heeft al handmatig premium (${now}). Inkorten tot en met ${dateFmt.format(expiresAt)}?`)) {
          return;
        }
      }
    }
    if (!active && !confirm("Handmatige premium intrekken?")) return;
    setBusy(true);
    try {
      await setManualPremium({ uid, active, expiresAt: expiresAt?.toISOString() ?? null });
      setMessage({ ok: true, text: active ? "Premium gegeven." : "Handmatige premium ingetrokken." });
    } catch (e) {
      setMessage({ ok: false, text: errorMessage(e) });
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="mt-5">
      <p className="mb-2 text-[13px] font-medium text-ink-soft">Handmatig premium geven</p>
      <div className="mb-3 flex flex-wrap gap-1.5" role="group" aria-label="Snelkeuze looptijd">
        {PRESETS.map(({ months, label }) => {
          const active = !unlimited && until === presetValue(months);
          return (
            <PresetChip
              key={months}
              active={active}
              onClick={() => {
                setUnlimited(false);
                setUntil(presetValue(months));
              }}
            >
              {label}
            </PresetChip>
          );
        })}
        <PresetChip active={unlimited} onClick={() => setUnlimited(true)}>
          Onbeperkt
        </PresetChip>
      </div>
      <Label htmlFor="manual-until">Tot en met</Label>
      <div className="flex gap-2">
        <Input
          id="manual-until"
          type="date"
          min={today}
          value={unlimited ? "" : until}
          disabled={unlimited}
          onChange={(e) => {
            setUnlimited(false);
            setUntil(e.target.value);
          }}
          className="tabular flex-1"
        />
        <Button variant="primary" busy={busy} onClick={() => grant(true)}>
          Geven
        </Button>
      </div>
      {manual?.active && (
        <Button variant="danger" disabled={busy} onClick={() => grant(false)} className="mt-2 -ml-3">
          Handmatige premium intrekken
        </Button>
      )}
      <p className="mt-2 text-xs text-ink-faint">Werkt naast abonnementen en codes; de langste geldige toegang telt.</p>
      <div aria-live="polite">
        {message && <p className={`mt-3 text-sm ${message.ok ? "text-leaf-ink" : "text-ember"}`}>{message.text}</p>}
      </div>
    </div>
  );
}

function PresetChip({ active, onClick, children }: { active: boolean; onClick: () => void; children: React.ReactNode }) {
  return (
    <button
      type="button"
      aria-pressed={active}
      onClick={onClick}
      className={`rounded-lg px-2.5 py-1 text-xs ring-1 transition-[background-color,color,box-shadow] duration-150 ring-inset active:scale-[0.97] ${
        active ? "bg-dusk-wash text-dusk-ink ring-dusk/25" : "text-ink-soft ring-line-strong hover:bg-paper hover:text-ink"
      }`}
    >
      {children}
    </button>
  );
}

function AccountActions({
  account,
  isMe,
  onChanged,
  onDeleted,
}: {
  account: Account;
  isMe: boolean;
  onChanged: (a: Account) => void;
  onDeleted: () => void;
}) {
  const [busy, setBusy] = useState<"admin" | "delete" | null>(null);
  const [message, setMessage] = useState<{ ok: boolean; text: string } | null>(null);
  const [confirming, setConfirming] = useState(false);
  const [typed, setTyped] = useState("");

  // Accounts without an email (rare) confirm with their uid instead.
  const confirmWord = account.email || account.uid;
  const who = account.email || "deze gebruiker";

  async function toggleAdmin() {
    const admin = !account.admin;
    const question = admin
      ? `${who} admin maken? Diegene kan dan alles in deze beheeromgeving.`
      : `Admin-rechten van ${who} afnemen?`;
    if (!confirm(question)) return;
    setBusy("admin");
    setMessage(null);
    try {
      await setAdmin({ uid: account.uid, admin });
      onChanged({ ...account, admin });
      setMessage({
        ok: true,
        text: admin
          ? `${who} is nu admin. Diegene moet uit- en weer inloggen om toegang te krijgen.`
          : "Admin-rechten afgenomen.",
      });
    } catch (e) {
      setMessage({ ok: false, text: errorMessage(e) });
    } finally {
      setBusy(null);
    }
  }

  async function remove(e: React.FormEvent) {
    e.preventDefault();
    if (typed.trim().toLowerCase() !== confirmWord.toLowerCase()) return;
    setBusy("delete");
    setMessage(null);
    try {
      await deleteUser({ uid: account.uid });
      onDeleted();
    } catch (err) {
      setMessage({ ok: false, text: errorMessage(err) });
      setBusy(null);
    }
  }

  return (
    <div className="mt-6 space-y-5 border-t border-line pt-5">
      <div>
        <div className="flex items-center justify-between gap-3">
          <p className="text-sm text-ink">{account.admin ? "Heeft admin-rechten" : "Geen admin"}</p>
          {!(isMe && account.admin) && (
            <Button className="h-8" busy={busy === "admin"} disabled={busy !== null} onClick={toggleAdmin}>
              {account.admin ? "Admin-rechten afnemen" : "Admin maken"}
            </Button>
          )}
        </div>
        <p className="mt-1.5 text-xs text-ink-faint">
          {isMe && account.admin
            ? "Je kunt je eigen admin-rechten niet afnemen."
            : "Na een wijziging moet de persoon uit- en weer inloggen."}
        </p>
      </div>

      <div>
        {isMe ? (
          <p className="text-xs text-ink-faint">Je eigen account kun je hier niet verwijderen.</p>
        ) : account.admin ? (
          <p className="text-xs text-ink-faint">Om dit account te verwijderen, neem je eerst de admin-rechten af.</p>
        ) : !confirming ? (
          <Button variant="danger" className="-ml-3" disabled={busy !== null} onClick={() => setConfirming(true)}>
            Account verwijderen
          </Button>
        ) : (
          <form onSubmit={remove} className="rounded-xl bg-ember-wash/60 p-3.5">
            <p className="text-sm text-ink">
              Verwijdert het account met profiel, favorieten en premium-gegevens, net als wanneer de gebruiker het zelf
              doet. Dit kan niet ongedaan worden gemaakt.
            </p>
            <div className="mt-3">
              <Label htmlFor="delete-confirm">
                Typ <span className="font-mono break-all text-ink">{confirmWord}</span> om te bevestigen
              </Label>
            </div>
            <Input
              id="delete-confirm"
              autoComplete="off"
              spellCheck={false}
              autoFocus
              value={typed}
              onChange={(e) => setTyped(e.target.value)}
            />
            <div className="mt-3 flex justify-end gap-2">
              <Button
                type="button"
                variant="ghost"
                disabled={busy === "delete"}
                onClick={() => {
                  setConfirming(false);
                  setTyped("");
                }}
              >
                Annuleren
              </Button>
              <Button
                type="submit"
                variant="danger"
                className="bg-surface"
                busy={busy === "delete"}
                disabled={typed.trim().toLowerCase() !== confirmWord.toLowerCase()}
              >
                Definitief verwijderen
              </Button>
            </div>
          </form>
        )}
      </div>

      <div aria-live="polite">
        {message && <p className={`text-sm ${message.ok ? "text-leaf-ink" : "text-ember"}`}>{message.text}</p>}
      </div>
    </div>
  );
}
