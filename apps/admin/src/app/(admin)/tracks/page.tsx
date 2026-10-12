"use client";

import { collection, doc, onSnapshot, orderBy, query, updateDoc } from "firebase/firestore";
import { Lock, Search } from "lucide-react";
import { useDeferredValue, useEffect, useMemo, useState } from "react";
import { Input } from "@/components/ui";
import { db } from "@/lib/firebase";

interface Track {
  id: string;
  title: string;
  speaker: string;
  durationMs: number;
  thumbnail?: string;
  premium: boolean;
}

function formatDuration(ms: number) {
  const s = Math.round(ms / 1000);
  return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;
}

export default function TracksPage() {
  const [tracks, setTracks] = useState<Track[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const q = useDeferredValue(search.trim().toLowerCase());
  const [saving, setSaving] = useState<string | null>(null);

  useEffect(
    () =>
      onSnapshot(
        query(collection(db, "tracks"), orderBy("title")),
        (snap) =>
          setTracks(
            snap.docs.map((d) => {
              const v = d.data();
              return {
                id: d.id,
                title: v.title ?? "",
                speaker: v.speaker ?? "",
                durationMs: v.duration ?? 0,
                thumbnail: v.thumbnail?.url,
                premium: v.premium === true,
              };
            }),
          ),
        () => {
          setError("Tracks konden niet worden geladen.");
          setTracks([]);
        },
      ),
    [],
  );

  const visible = useMemo(
    () =>
      tracks?.filter((t) => !q || t.title.toLowerCase().includes(q) || t.speaker.toLowerCase().includes(q)) ?? null,
    [tracks, q],
  );
  const premiumCount = tracks?.filter((t) => t.premium).length ?? 0;

  async function toggle(t: Track) {
    setSaving(t.id);
    setError(null);
    try {
      await updateDoc(doc(db, "tracks", t.id), { premium: !t.premium });
    } catch {
      setError(`Opslaan van “${t.title}” mislukt.`);
    } finally {
      setSaving(null);
    }
  }

  return (
    <div className="mx-auto max-w-4xl">
      <header className="mb-8">
        <h1 className="font-display text-[2rem] leading-tight font-medium tracking-[-0.02em] text-ink">Tracks</h1>
        <p className="mt-1.5 max-w-prose text-[15px] text-ink-soft">
          Premium-tracks kunnen alleen worden afgespeeld met een abonnement of ingewisselde code.
          {tracks && (
            <span className="tabular">
              {" "}
              {premiumCount} van {tracks.length} zijn premium.
            </span>
          )}
        </p>
      </header>

      <div className="relative mb-4 max-w-sm">
        <Search className="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-ink-faint" aria-hidden />
        <Input
          type="search"
          aria-label="Zoek op titel of spreker"
          placeholder="Zoek op titel of spreker"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="pl-9"
        />
      </div>

      <div aria-live="polite">{error && <p className="mb-3 text-sm text-ember">{error}</p>}</div>

      {visible === null ? (
        <div className="h-64 animate-pulse rounded-2xl border border-line bg-surface" aria-busy="true" />
      ) : visible.length === 0 ? (
        <div className="rounded-2xl border border-dashed border-line-strong px-6 py-14 text-center">
          <p className="font-medium text-ink">{q ? "Niets gevonden" : "Nog geen tracks"}</p>
        </div>
      ) : (
        <ul className="divide-y divide-line overflow-hidden rounded-2xl border border-line bg-surface">
          {visible.map((t) => (
            <li key={t.id} className="flex items-center gap-4 px-4 py-3">
              {t.thumbnail ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={t.thumbnail} alt="" className="size-11 shrink-0 rounded-lg object-cover" />
              ) : (
                <div className="size-11 shrink-0 rounded-lg bg-paper" />
              )}
              <div className="min-w-0 flex-1">
                <p className="truncate font-medium text-ink">{t.title}</p>
                <p className="truncate text-sm text-ink-faint">
                  {t.speaker} · <span className="tabular">{formatDuration(t.durationMs)}</span>
                </p>
              </div>
              <label className="flex shrink-0 cursor-pointer items-center gap-2.5 text-sm text-ink-soft">
                <Lock className={`size-4 transition-colors ${t.premium ? "text-dusk" : "text-line-strong"}`} aria-hidden />
                <span className="hidden sm:inline">Premium</span>
                <button
                  role="switch"
                  aria-checked={t.premium}
                  aria-label={`Premium voor ${t.title}`}
                  disabled={saving === t.id}
                  onClick={() => toggle(t)}
                  className={`relative h-6 w-10 rounded-full transition-colors duration-200 disabled:opacity-60 ${
                    t.premium ? "bg-dusk" : "bg-line-strong"
                  }`}
                >
                  <span
                    className={`absolute top-0.5 left-0.5 size-5 rounded-full bg-white shadow-[0_1px_2px_rgb(0_0_0/0.2)] transition-transform duration-200 ease-out-expo ${
                      t.premium ? "translate-x-4" : ""
                    }`}
                  />
                </button>
              </label>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
