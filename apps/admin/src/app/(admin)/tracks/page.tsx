"use client";

import { Lock, Plus, Search } from "lucide-react";
import { useDeferredValue, useMemo, useState } from "react";
import { AudioField, Field, ImageField, Switch, Textarea } from "@/components/form";
import { Sheet } from "@/components/sheet";
import { Button, Input } from "@/components/ui";
import { errorMessage } from "@/lib/codes";
import { deleteTrack, formatDuration, newId, saveTrack, toTrack, type Track, useCollection } from "@/lib/content";
import { call } from "@/lib/firebase";

// Moves the audio URL out of reach of free users and rotates its token.
const setTrackPremium = call<{ trackId: string; premium: boolean }, { success: boolean }>("adminSetTrackPremium");

const emptyTrack = (): Track => ({
  id: newId("tracks"),
  title: "",
  titleNl: "",
  writer: "",
  speaker: "",
  description: "",
  descriptionNl: "",
  trackUrl: "",
  duration: 0,
  hasTimer: false,
  premium: false,
  thumbnail: null,
  imageBackground: null,
});

export default function TracksPage() {
  const { items: tracks, error: loadError } = useCollection("tracks", "title", toTrack);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const q = useDeferredValue(search.trim().toLowerCase());
  const [saving, setSaving] = useState<string | null>(null);
  const [editing, setEditing] = useState<{ track: Track; isNew: boolean } | null>(null);

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
      await setTrackPremium({ trackId: t.id, premium: !t.premium });
    } catch (e) {
      setError(`Opslaan van “${t.title}” mislukt: ${errorMessage(e)}`);
    } finally {
      setSaving(null);
    }
  }

  return (
    <div className="mx-auto max-w-4xl">
      <header className="mb-8 flex flex-wrap items-end justify-between gap-4">
        <div>
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
        </div>
        <Button onClick={() => setEditing({ track: emptyTrack(), isNew: true })} icon={<Plus className="size-4" aria-hidden />}>
          Nieuwe track
        </Button>
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

      <div aria-live="polite">{(error || loadError) && <p className="mb-3 text-sm text-ember">{error || loadError}</p>}</div>

      {visible === null ? (
        <div className="h-64 animate-pulse rounded-2xl border border-line bg-surface" aria-busy="true" />
      ) : visible.length === 0 ? (
        <div className="rounded-2xl border border-dashed border-line-strong px-6 py-14 text-center">
          <p className="font-medium text-ink">{q ? "Niets gevonden" : "Nog geen tracks"}</p>
          {!q && <p className="mt-1 text-sm text-ink-soft">Voeg je eerste track toe met de knop rechtsboven.</p>}
        </div>
      ) : (
        <ul className="divide-y divide-line overflow-hidden rounded-2xl border border-line bg-surface">
          {visible.map((t) => (
            <li key={t.id} className="flex items-center gap-4 px-4 py-3">
              <button
                onClick={() => setEditing({ track: t, isNew: false })}
                className="flex min-w-0 flex-1 items-center gap-4 rounded-lg text-left"
                aria-label={`${t.title} bewerken`}
              >
                {t.thumbnail ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={t.thumbnail.url} alt="" className="size-11 shrink-0 rounded-lg object-cover" />
                ) : (
                  <div className="size-11 shrink-0 rounded-lg bg-paper" />
                )}
                <div className="min-w-0 flex-1">
                  <p className="truncate font-medium text-ink">{t.title || "Zonder titel"}</p>
                  <p className="truncate text-sm text-ink-faint">
                    {t.speaker && `${t.speaker} · `}
                    <span className="tabular">{formatDuration(t.duration)}</span>
                  </p>
                </div>
              </button>
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

      {editing && (
        <TrackEditor key={editing.track.id} initial={editing.track} isNew={editing.isNew} onClose={() => setEditing(null)} />
      )}
    </div>
  );
}

function TrackEditor({ initial, isNew, onClose }: { initial: Track; isNew: boolean; onClose: () => void }) {
  const [t, setT] = useState(initial);
  const [audioChanged, setAudioChanged] = useState(false);
  const [uploads, setUploads] = useState(0);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const set = (patch: Partial<Track>) => setT((prev) => ({ ...prev, ...patch }));
  const onBusy = (b: boolean) => setUploads((n) => n + (b ? 1 : -1));

  const hasAudio = !!t.trackUrl || (t.premium && !audioChanged && t.duration > 0);
  const missing = [
    !t.title.trim() && "titel",
    !t.speaker.trim() && "spreker",
    !hasAudio && "audio",
    !t.thumbnail && "thumbnail",
    !t.imageBackground && "achtergrond",
  ].filter(Boolean);

  async function save(e: React.FormEvent) {
    e.preventDefault();
    if (missing.length) return setError(`Nog nodig: ${missing.join(", ")}.`);
    setBusy(true);
    setError(null);
    try {
      await saveTrack({ ...t, title: t.title.trim(), speaker: t.speaker.trim() }, audioChanged);
      onClose();
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  }

  async function remove() {
    if (!confirm(`“${t.title}” verwijderen? Audio en afbeeldingen worden ook gewist.`)) return;
    setBusy(true);
    try {
      await deleteTrack(initial);
      onClose();
    } catch (err) {
      setError(errorMessage(err));
      setBusy(false);
    }
  }

  return (
    <Sheet
      open
      error={error}
      busy={busy || uploads > 0}
      wide
      title={isNew ? "Nieuwe track" : "Track bewerken"}
      onClose={onClose}
      footer={
        <>
          {!isNew && (
            <Button type="button" variant="danger" onClick={remove} disabled={busy} className="mr-auto">
              Verwijderen
            </Button>
          )}
          <Button type="button" variant="ghost" onClick={onClose} disabled={busy || uploads > 0}>
            Annuleren
          </Button>
          <Button type="submit" form="track-form" variant="primary" busy={busy} disabled={uploads > 0}>
            {uploads > 0 ? "Uploaden…" : "Opslaan"}
          </Button>
        </>
      }
    >
      <form id="track-form" onSubmit={save} className="space-y-5">
        <div className="grid gap-5 sm:grid-cols-2">
          <Field label="Titel (EN)">{(id) => <Input id={id} value={t.title} onChange={(e) => set({ title: e.target.value })} />}</Field>
          <Field label="Titel (NL)" hint="Leeg = Engelse tekst wordt getoond">
            {(id) => <Input id={id} value={t.titleNl} onChange={(e) => set({ titleNl: e.target.value })} />}
          </Field>
        </div>
        <div className="grid gap-5 sm:grid-cols-2">
          <Field label="Spreker">{(id) => <Input id={id} value={t.speaker} onChange={(e) => set({ speaker: e.target.value })} />}</Field>
          <Field label="Schrijver">{(id) => <Input id={id} value={t.writer} onChange={(e) => set({ writer: e.target.value })} />}</Field>
        </div>
        <div className="grid gap-5 sm:grid-cols-2">
          <Field label="Beschrijving (EN)">
            {(id) => <Textarea id={id} value={t.description} onChange={(e) => set({ description: e.target.value })} />}
          </Field>
          <Field label="Beschrijving (NL)" hint="Leeg = Engelse tekst wordt getoond">
            {(id) => <Textarea id={id} value={t.descriptionNl} onChange={(e) => set({ descriptionNl: e.target.value })} />}
          </Field>
        </div>
        <AudioField
          value={t.trackUrl}
          durationMs={t.duration}
          folder="track/audio"
          onBusy={onBusy}
          onChange={(url, duration) => {
            set({ trackUrl: url, duration });
            setAudioChanged(true);
          }}
        />
        <div className="grid gap-5 sm:grid-cols-2">
          <ImageField label="Thumbnail (vierkant)" value={t.thumbnail} folder="track/thumbnails" onBusy={onBusy} onChange={(thumbnail) => set({ thumbnail })} />
          <ImageField label="Achtergrond (speler)" value={t.imageBackground} folder="track/backgrounds" onBusy={onBusy} onChange={(imageBackground) => set({ imageBackground })} />
        </div>
        <Switch label="Slaaptimer tonen in de speler" checked={t.hasTimer} onChange={(hasTimer) => set({ hasTimer })} />
        {t.premium && <p className="text-sm text-ink-faint">Deze track is premium. Premium aan/uit zet je in de lijst.</p>}
      </form>
    </Sheet>
  );
}
