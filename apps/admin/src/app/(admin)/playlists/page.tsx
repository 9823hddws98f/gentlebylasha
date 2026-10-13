"use client";

import { Plus } from "lucide-react";
import { useMemo, useState } from "react";
import { Field, ImageField, OrderedPicker, Switch, Textarea } from "@/components/form";
import { Sheet } from "@/components/sheet";
import { Button, Input } from "@/components/ui";
import { errorMessage } from "@/lib/codes";
import {
  deletePlaylist,
  formatDuration,
  newId,
  type Playlist,
  savePlaylist,
  toPlaylist,
  toTrack,
  useCollection,
} from "@/lib/content";

const emptyPlaylist = (): Playlist => ({
  id: newId("playlists"),
  title: "",
  author: "",
  profession: "",
  description: "",
  thumbnail: null,
  authorImage: null,
  showAudioThumbnails: true,
  trackIds: [],
});

export default function PlaylistsPage() {
  const { items: playlists, error } = useCollection("playlists", "title", toPlaylist);
  const { items: tracks } = useCollection("tracks", "title", toTrack);
  const [editing, setEditing] = useState<{ playlist: Playlist; isNew: boolean } | null>(null);

  const trackOptions = useMemo(
    () => (tracks ?? []).map((t) => ({ id: t.id, label: t.title, sub: `${t.speaker} · ${formatDuration(t.duration)}` })),
    [tracks],
  );

  return (
    <div className="mx-auto max-w-4xl">
      <header className="mb-8 flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="font-display text-[2rem] leading-tight font-medium tracking-[-0.02em] text-ink">Playlists</h1>
          <p className="mt-1.5 max-w-prose text-[15px] text-ink-soft">Series van tracks in een vaste volgorde.</p>
        </div>
        <Button onClick={() => setEditing({ playlist: emptyPlaylist(), isNew: true })} icon={<Plus className="size-4" aria-hidden />}>
          Nieuwe playlist
        </Button>
      </header>

      {error && <p className="mb-3 text-sm text-ember">{error}</p>}

      {playlists === null ? (
        <div className="h-64 animate-pulse rounded-2xl border border-line bg-surface" aria-busy="true" />
      ) : playlists.length === 0 ? (
        <div className="rounded-2xl border border-dashed border-line-strong px-6 py-14 text-center">
          <p className="font-medium text-ink">Nog geen playlists</p>
        </div>
      ) : (
        <ul className="grid gap-3 sm:grid-cols-2">
          {playlists.map((p) => (
            <li key={p.id}>
              <button
                onClick={() => setEditing({ playlist: p, isNew: false })}
                className="flex w-full items-center gap-4 rounded-2xl border border-line bg-surface p-3 text-left transition-colors hover:border-line-strong"
              >
                {p.thumbnail ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={p.thumbnail.url} alt="" className="size-16 shrink-0 rounded-xl object-cover" />
                ) : (
                  <div className="size-16 shrink-0 rounded-xl bg-paper" />
                )}
                <span className="min-w-0">
                  <span className="block truncate font-medium text-ink">{p.title || "Zonder titel"}</span>
                  <span className="block truncate text-sm text-ink-faint">
                    {p.author} · <span className="tabular">{p.trackIds.length}</span> tracks
                  </span>
                </span>
              </button>
            </li>
          ))}
        </ul>
      )}

      {editing && (
        <PlaylistEditor
          key={editing.playlist.id}
          initial={editing.playlist}
          isNew={editing.isNew}
          trackOptions={trackOptions}
          onClose={() => setEditing(null)}
        />
      )}
    </div>
  );
}

function PlaylistEditor({
  initial,
  isNew,
  trackOptions,
  onClose,
}: {
  initial: Playlist;
  isNew: boolean;
  trackOptions: { id: string; label: string; sub?: string }[];
  onClose: () => void;
}) {
  const [p, setP] = useState(initial);
  const [uploads, setUploads] = useState(0);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const set = (patch: Partial<Playlist>) => setP((prev) => ({ ...prev, ...patch }));
  const onBusy = (b: boolean) => setUploads((n) => n + (b ? 1 : -1));

  const missing = [
    !p.title.trim() && "titel",
    !p.author.trim() && "auteur",
    !p.thumbnail && "cover",
    !p.authorImage && "foto auteur",
    p.trackIds.length === 0 && "minstens één track",
  ].filter(Boolean);

  async function save(e: React.FormEvent) {
    e.preventDefault();
    if (missing.length) return setError(`Nog nodig: ${missing.join(", ")}.`);
    setBusy(true);
    setError(null);
    try {
      await savePlaylist({ ...p, title: p.title.trim(), author: p.author.trim() });
      onClose();
    } catch (err) {
      setError(errorMessage(err));
      setBusy(false);
    }
  }

  async function remove() {
    if (!confirm(`“${p.title}” verwijderen?`)) return;
    setBusy(true);
    try {
      await deletePlaylist(p.id);
      onClose();
    } catch (err) {
      setError(errorMessage(err));
      setBusy(false);
    }
  }

  return (
    <Sheet
      open
      wide
      title={isNew ? "Nieuwe playlist" : "Playlist bewerken"}
      onClose={onClose}
      footer={
        <>
          {!isNew && (
            <Button type="button" variant="danger" onClick={remove} disabled={busy} className="mr-auto">
              Verwijderen
            </Button>
          )}
          <Button type="button" variant="ghost" onClick={onClose}>
            Annuleren
          </Button>
          <Button type="submit" form="playlist-form" variant="primary" busy={busy} disabled={uploads > 0}>
            {uploads > 0 ? "Uploaden…" : "Opslaan"}
          </Button>
        </>
      }
    >
      <form id="playlist-form" onSubmit={save} className="space-y-5">
        <Field label="Titel">{(id) => <Input id={id} value={p.title} onChange={(e) => set({ title: e.target.value })} />}</Field>
        <div className="grid gap-5 sm:grid-cols-2">
          <Field label="Auteur">{(id) => <Input id={id} value={p.author} onChange={(e) => set({ author: e.target.value })} />}</Field>
          <Field label="Beroep auteur">
            {(id) => <Input id={id} value={p.profession} placeholder="Slaapcoach" onChange={(e) => set({ profession: e.target.value })} />}
          </Field>
        </div>
        <Field label="Beschrijving">
          {(id) => <Textarea id={id} value={p.description} onChange={(e) => set({ description: e.target.value })} />}
        </Field>
        <div className="grid gap-5 sm:grid-cols-2">
          <ImageField label="Cover" value={p.thumbnail} folder="playlist/covers" onBusy={onBusy} onChange={(thumbnail) => set({ thumbnail })} />
          <ImageField label="Foto auteur" value={p.authorImage} folder="playlist/authors" onBusy={onBusy} onChange={(authorImage) => set({ authorImage })} />
        </div>
        <Switch
          label="Thumbnails van tracks tonen in de lijst"
          checked={p.showAudioThumbnails}
          onChange={(showAudioThumbnails) => set({ showAudioThumbnails })}
        />
        <OrderedPicker label="Tracks" options={trackOptions} value={p.trackIds} onChange={(trackIds) => set({ trackIds })} />
        {error && <p className="text-sm text-ember">{error}</p>}
      </form>
    </Sheet>
  );
}
