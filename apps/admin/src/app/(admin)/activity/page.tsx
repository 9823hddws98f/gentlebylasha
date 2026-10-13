"use client";

import {
  collection,
  getDocs,
  limit,
  orderBy,
  query,
  type QueryConstraint,
  type QueryDocumentSnapshot,
  startAfter,
  Timestamp,
  where,
} from "firebase/firestore";
import { useEffect, useRef, useState } from "react";
import { Button, Select } from "@/components/ui";
import { call, db } from "@/lib/firebase";

const PAGE_SIZE = 50;

/** The actions the functions write to admin_log (logAdminAction in functions/src/index.ts). */
const ACTIONS = {
  generateCodes: "Codes aangemaakt",
  assignCode: "Code uitgegeven",
  disableCode: "Code uitgeschakeld",
  setTrackPremium: "Track premium of gratis",
  deleteTrack: "Track verwijderd",
  setManualPremium: "Handmatige premium",
  sendPush: "Pushbericht verstuurd",
  cancelPush: "Pushbericht geannuleerd",
  setAdmin: "Admin-rechten",
  deleteUser: "Account verwijderd",
} as const;
type Action = keyof typeof ACTIONS;

interface Entry {
  id: string;
  adminUid: string;
  action: string;
  payload: Record<string, unknown>;
  at?: Date;
}

const userEmails = call<{ uids: string[] }, Record<string, string>>("adminUserEmails");

const AUDIENCE: Record<string, string> = { all: "iedereen", premium: "premiumgebruikers", free: "gratis gebruikers" };
const LANGUAGE: Record<string, string> = { en: "Engels", nl: "Nederlands" };

const dateFmt = new Intl.DateTimeFormat("nl-NL", { day: "numeric", month: "short", year: "numeric" });
const dateTimeFmt = new Intl.DateTimeFormat("nl-NL", {
  day: "numeric",
  month: "short",
  year: "numeric",
  hour: "2-digit",
  minute: "2-digit",
});

const text = (v: unknown) => (typeof v === "string" ? v : "");

function toEntry(d: QueryDocumentSnapshot): Entry {
  const v = d.data();
  return {
    id: d.id,
    adminUid: text(v.adminUid),
    action: text(v.action),
    payload: v.payload && typeof v.payload === "object" ? v.payload : {},
    at: v.at instanceof Timestamp ? v.at.toDate() : undefined,
  };
}

/** Uids worth showing as an email: the admin, and the user an action was about. */
const uidsOf = (e: Entry) => [e.adminUid, e.action === "setManualPremium" ? text(e.payload.uid) : ""].filter(Boolean);

/** One page of log entries, newest first, after `after` when given. */
async function fetchLog(action: string, after: QueryDocumentSnapshot | null) {
  const constraints: QueryConstraint[] = [];
  if (action) constraints.push(where("action", "==", action));
  constraints.push(orderBy("at", "desc"));
  if (after) constraints.push(startAfter(after));
  constraints.push(limit(PAGE_SIZE));
  const snap = await getDocs(query(collection(db, "admin_log"), ...constraints));
  return {
    entries: snap.docs.map(toEntry),
    cursor: snap.docs.at(-1) ?? after,
    hasMore: snap.docs.length === PAGE_SIZE,
  };
}

/** A readable Dutch sentence for one log entry. */
function describe(e: Entry, who: (uid: string) => string): string {
  const p = e.payload;
  switch (e.action as Action) {
    case "generateCodes": {
      const n = Number(p.count ?? 0);
      return `${n} ${n === 1 ? "code" : "codes"} aangemaakt`;
    }
    case "assignCode":
      return `Code ${text(p.code)} uitgegeven aan ${text(p.email)}${p.emailed ? " en gemaild" : ""}`;
    case "disableCode":
      return `Code ${text(p.code)} uitgeschakeld`;
    case "setTrackPremium":
      return p.premium ? "Track premium gemaakt" : "Track gratis gemaakt";
    case "deleteTrack":
      return "Track verwijderd";
    case "setManualPremium": {
      const user = who(text(p.uid));
      if (!p.active) return `Handmatige premium afgenomen van ${user}`;
      const until = typeof p.expiresAt === "string" ? new Date(p.expiresAt) : null;
      return until && !Number.isNaN(until.getTime())
        ? `Premium gegeven aan ${user} tot ${dateFmt.format(until)}`
        : `Premium zonder einddatum gegeven aan ${user}`;
    }
    case "sendPush": {
      const audience = AUDIENCE[text(p.audience)] ?? text(p.audience);
      if (p.scheduled) return `Pushbericht ingepland voor ${audience}`;
      const failed = Array.isArray(p.failed) ? p.failed.map((l) => LANGUAGE[l] ?? String(l)) : [];
      if (failed.length >= 2) return `Pushbericht naar ${audience} mislukt`;
      if (failed.length) return `Pushbericht verstuurd naar ${audience}, behalve in het ${failed.join(", ")}`;
      return `Pushbericht verstuurd naar ${audience}`;
    }
    case "cancelPush":
      return "Ingepland pushbericht geannuleerd";
    case "setAdmin": {
      const user = text(p.email) || who(text(p.uid));
      return p.admin ? `${user} admin gemaakt` : `Admin-rechten afgenomen van ${user}`;
    }
    case "deleteUser":
      return `Account ${text(p.email) || text(p.uid)} verwijderd`;
    default:
      return e.action || "Onbekende actie";
  }
}

/** The raw payload on one line, for ids that aren't in the sentence. */
function detail(payload: Record<string, unknown>): string {
  const value = (v: unknown) =>
    v === null || v === undefined ? "–" : typeof v === "object" ? JSON.stringify(v) : String(v);
  return Object.entries(payload)
    .map(([k, v]) => `${k} ${value(v)}`)
    .join(" · ");
}

export default function ActivityPage() {
  const [action, setAction] = useState("");
  const [entries, setEntries] = useState<Entry[] | null>(null);
  const [cursor, setCursor] = useState<QueryDocumentSnapshot | null>(null);
  const [hasMore, setHasMore] = useState(false);
  const [loadingMore, setLoadingMore] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [emails, setEmails] = useState<Record<string, string>>({});
  const requested = useRef(new Set<string>());

  useEffect(() => {
    let cancelled = false;
    fetchLog(action, null)
      .then((page) => {
        if (cancelled) return;
        setEntries(page.entries);
        setCursor(page.cursor);
        setHasMore(page.hasMore);
      })
      .catch(() => {
        if (cancelled) return;
        setError("Activiteit kon niet worden geladen.");
        setEntries([]);
      });
    return () => {
      cancelled = true;
    };
  }, [action]);

  // The log stores uids; look up their email addresses, 100 at a time.
  useEffect(() => {
    if (!entries) return;
    const missing = [...new Set(entries.flatMap(uidsOf))].filter((uid) => !requested.current.has(uid));
    for (let i = 0; i < missing.length; i += 100) {
      const uids = missing.slice(i, i + 100);
      uids.forEach((uid) => requested.current.add(uid));
      userEmails({ uids })
        .then((found) => setEmails((prev) => ({ ...prev, ...found })))
        // The uid is shown instead; try again with the next page.
        .catch(() => uids.forEach((uid) => requested.current.delete(uid)));
    }
  }, [entries]);

  function filter(next: string) {
    setAction(next);
    setEntries(null);
    setCursor(null);
    setHasMore(false);
    setError(null);
  }

  async function loadMore() {
    setLoadingMore(true);
    setError(null);
    try {
      const page = await fetchLog(action, cursor);
      setEntries((prev) => {
        const seen = new Set(prev?.map((e) => e.id));
        return [...(prev ?? []), ...page.entries.filter((e) => !seen.has(e.id))];
      });
      setCursor(page.cursor);
      setHasMore(page.hasMore);
    } catch {
      setError("Meer activiteit laden mislukt.");
    } finally {
      setLoadingMore(false);
    }
  }

  const who = (uid: string) => emails[uid] || uid;

  return (
    <div className="mx-auto max-w-5xl">
      <header className="mb-8">
        <h1 className="font-display text-[2rem] leading-tight font-medium tracking-[-0.02em] text-ink">Activiteit</h1>
        <p className="mt-1.5 max-w-prose text-[15px] text-ink-soft">
          Wat admins hier hebben gedaan, nieuwste eerst: codes, premium, tracks, push en accounts.
        </p>
      </header>

      <div className="mb-4 flex flex-wrap items-center gap-3">
        <Select
          aria-label="Filter op actie"
          value={action}
          onChange={(e) => filter(e.target.value)}
          className="w-auto min-w-56"
        >
          <option value="">Alle acties</option>
          {(Object.keys(ACTIONS) as Action[]).map((a) => (
            <option key={a} value={a}>
              {ACTIONS[a]}
            </option>
          ))}
        </Select>
      </div>

      <div aria-live="polite">{error && <p className="mb-3 text-sm text-ember">{error}</p>}</div>

      {entries === null ? (
        <div className="h-64 animate-pulse rounded-2xl border border-line bg-surface" aria-busy="true" />
      ) : entries.length === 0 ? (
        error ? null : (
          <div className="rounded-2xl border border-dashed border-line-strong px-6 py-14 text-center">
            <p className="font-medium text-ink">{action ? "Niets gevonden" : "Nog geen activiteit"}</p>
            <p className="mt-1 text-sm text-ink-soft">
              {action ? "Er is nog niets van deze soort gedaan. Kies een andere actie." : "Acties van admins verschijnen hier."}
            </p>
          </div>
        )
      ) : (
        <>
          <div className="overflow-x-auto rounded-2xl border border-line bg-surface">
            <table className="w-full min-w-[720px] text-left text-sm">
              <thead>
                <tr className="border-b border-line text-[13px] text-ink-faint">
                  <th scope="col" className="w-44 py-3 pr-4 pl-5 font-medium">Wanneer</th>
                  <th scope="col" className="px-4 py-3 font-medium">Wat</th>
                  <th scope="col" className="w-56 py-3 pr-5 pl-4 font-medium">Door</th>
                </tr>
              </thead>
              <tbody>
                {entries.map((e) => {
                  const raw = detail(e.payload);
                  const admin = emails[e.adminUid];
                  return (
                    <tr key={e.id} className="border-b border-line align-top last:border-0 hover:bg-paper/60">
                      <td className="tabular py-2.5 pr-4 pl-5 whitespace-nowrap text-ink-soft">
                        {e.at ? dateTimeFmt.format(e.at) : "–"}
                      </td>
                      <td className="max-w-0 px-4 py-2.5">
                        <p className="text-ink">{describe(e, who)}</p>
                        {raw && (
                          <p className="mt-0.5 truncate font-mono text-xs text-ink-faint" title={raw}>
                            {raw}
                          </p>
                        )}
                      </td>
                      <td className="max-w-56 py-2.5 pr-5 pl-4">
                        {admin ? (
                          <span className="block truncate text-ink-soft" title={admin}>
                            {admin}
                          </span>
                        ) : (
                          <span className="block truncate font-mono text-xs leading-5 text-ink-faint" title={e.adminUid}>
                            {e.adminUid || "–"}
                          </span>
                        )}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
          {hasMore && (
            <Button className="mt-3 w-full" busy={loadingMore} onClick={loadMore}>
              Meer laden
            </Button>
          )}
        </>
      )}
    </div>
  );
}
