"use client";

import { ArrowDown, ArrowUp, Plus } from "lucide-react";
import { useMemo, useState } from "react";
import { Field, OrderedPicker, Switch } from "@/components/form";
import { Sheet } from "@/components/sheet";
import { Button, Input, Select } from "@/components/ui";
import { errorMessage } from "@/lib/codes";
import {
  type Block,
  type BlockType,
  deleteBlock,
  deletePage,
  newId,
  type Page,
  reorder,
  saveBlock,
  savePage,
  toBlock,
  toPage,
  toPlaylist,
  toTrack,
  useCollection,
} from "@/lib/content";

const TYPE_INFO: Record<BlockType, string> = {
  Hero: "Grote uitgelichte track bovenaan",
  Featured: "Rij met brede tegels",
  Normal: "Rij met tracks",
  Series: "Rij met playlists",
};

function MoveButtons({ index, count, onMove }: { index: number; count: number; onMove: (d: -1 | 1) => void }) {
  return (
    <span className="flex shrink-0">
      <button type="button" disabled={index === 0} onClick={() => onMove(-1)} aria-label="Omhoog" className="rounded p-1.5 text-ink-soft hover:bg-paper disabled:opacity-30">
        <ArrowUp className="size-4" />
      </button>
      <button type="button" disabled={index === count - 1} onClick={() => onMove(1)} aria-label="Omlaag" className="rounded p-1.5 text-ink-soft hover:bg-paper disabled:opacity-30">
        <ArrowDown className="size-4" />
      </button>
    </span>
  );
}

const moved = <T,>(list: T[], i: number, d: -1 | 1) => {
  const next = [...list];
  [next[i], next[i + d]] = [next[i + d], next[i]];
  return next;
};

export default function PagesPage() {
  const { items: pages, error } = useCollection("pages", "order", toPage);
  const { items: blocks } = useCollection("blocks", "sequence", toBlock);
  const { items: tracks } = useCollection("tracks", "title", toTrack);
  const { items: playlists } = useCollection("playlists", "title", toPlaylist);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [editingPage, setEditingPage] = useState<{ page: Page; isNew: boolean } | null>(null);
  const [editingBlock, setEditingBlock] = useState<{ block: Block; isNew: boolean } | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);

  const selected = pages?.find((p) => p.id === selectedId) ?? pages?.[0] ?? null;
  const pageBlocks = useMemo(() => (blocks ?? []).filter((b) => b.pageId === selected?.id), [blocks, selected]);
  const trackOptions = useMemo(() => (tracks ?? []).map((t) => ({ id: t.id, label: t.title, sub: t.speaker })), [tracks]);
  const playlistOptions = useMemo(
    () => (playlists ?? []).map((p) => ({ id: p.id, label: p.title, sub: `${p.trackIds.length} tracks` })),
    [playlists],
  );

  const run = (action: Promise<unknown>) => action.catch((e) => setActionError(errorMessage(e)));

  return (
    <div className="mx-auto max-w-5xl">
      <header className="mb-8">
        <h1 className="font-display text-[2rem] leading-tight font-medium tracking-[-0.02em] text-ink">Pagina&apos;s</h1>
        <p className="mt-1.5 max-w-prose text-[15px] text-ink-soft">
          De tabbladen in de app en de rijen erop. De eerste pagina is het startscherm.
        </p>
      </header>

      {(error || actionError) && <p className="mb-3 text-sm text-ember">{error || actionError}</p>}

      <div className="grid gap-6 md:grid-cols-[240px_minmax(0,1fr)]">
        <section aria-label="Pagina's">
          <ul className="divide-y divide-line overflow-hidden rounded-2xl border border-line bg-surface">
            {(pages ?? []).map((p, i) => (
              <li key={p.id} className={`flex items-center gap-1 pr-1 ${selected?.id === p.id ? "bg-dusk-wash" : ""}`}>
                <button onClick={() => setSelectedId(p.id)} aria-current={selected?.id === p.id} className="min-w-0 flex-1 truncate px-4 py-3 text-left text-sm font-medium text-ink">
                  {p.name || "Zonder naam"}
                </button>
                <MoveButtons index={i} count={pages!.length} onMove={(d) => run(reorder("pages", moved(pages!, i, d).map((x) => x.id)))} />
              </li>
            ))}
          </ul>
          <Button
            className="mt-3 w-full"
            icon={<Plus className="size-4" aria-hidden />}
            onClick={() =>
              setEditingPage({
                page: { id: newId("pages"), name: "", order: pages?.length ?? 0, config: { showItemDurations: true } },
                isNew: true,
              })
            }
          >
            Nieuwe pagina
          </Button>
        </section>

        <section aria-label="Rijen op de pagina">
          {!selected ? (
            <div className="rounded-2xl border border-dashed border-line-strong px-6 py-14 text-center text-sm text-ink-soft">
              {pages === null ? "Laden…" : "Maak eerst een pagina aan."}
            </div>
          ) : (
            <>
              <div className="mb-3 flex flex-wrap items-center justify-between gap-3">
                <h2 className="text-lg font-semibold text-ink">{selected.name}</h2>
                <div className="flex gap-2">
                  <Button variant="ghost" onClick={() => setEditingPage({ page: selected, isNew: false })}>
                    Pagina-instellingen
                  </Button>
                  <Button
                    icon={<Plus className="size-4" aria-hidden />}
                    onClick={() =>
                      setEditingBlock({
                        block: { id: newId("blocks"), pageId: selected.id, title: "", type: "Normal", sequence: pageBlocks.length, trackIds: [] },
                        isNew: true,
                      })
                    }
                  >
                    Nieuwe rij
                  </Button>
                </div>
              </div>
              {pageBlocks.length === 0 ? (
                <div className="rounded-2xl border border-dashed border-line-strong px-6 py-12 text-center text-sm text-ink-soft">
                  Deze pagina is nog leeg.
                </div>
              ) : (
                <ol className="space-y-2">
                  {pageBlocks.map((b, i) => {
                    const count = b.type === "Series" ? b.playlistIds?.length : b.type === "Hero" ? (b.trackId ? 1 : 0) : b.trackIds?.length;
                    return (
                      <li key={b.id} className="flex items-center gap-3 rounded-2xl border border-line bg-surface px-4 py-3">
                        <button onClick={() => setEditingBlock({ block: b, isNew: false })} className="min-w-0 flex-1 text-left">
                          <span className="block truncate font-medium text-ink">{b.title || "Zonder titel"}</span>
                          <span className="block text-sm text-ink-faint">
                            {TYPE_INFO[b.type]} · <span className="tabular">{count ?? 0}</span> {b.type === "Series" ? "playlists" : "tracks"}
                          </span>
                        </button>
                        <MoveButtons index={i} count={pageBlocks.length} onMove={(d) => run(reorder("blocks", moved(pageBlocks, i, d).map((x) => x.id)))} />
                      </li>
                    );
                  })}
                </ol>
              )}
            </>
          )}
        </section>
      </div>

      {editingPage && (
        <PageEditor
          key={editingPage.page.id}
          initial={editingPage.page}
          isNew={editingPage.isNew}
          onDelete={() => deletePage(editingPage.page, blocks ?? [])}
          onSaved={(id) => setSelectedId(id)}
          onClose={() => setEditingPage(null)}
        />
      )}
      {editingBlock && (
        <BlockEditor
          key={editingBlock.block.id}
          initial={editingBlock.block}
          isNew={editingBlock.isNew}
          trackOptions={trackOptions}
          playlistOptions={playlistOptions}
          onClose={() => setEditingBlock(null)}
        />
      )}
    </div>
  );
}

function PageEditor({
  initial,
  isNew,
  onDelete,
  onSaved,
  onClose,
}: {
  initial: Page;
  isNew: boolean;
  onDelete: () => Promise<void>;
  onSaved: (id: string) => void;
  onClose: () => void;
}) {
  const [p, setP] = useState(initial);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function save(e: React.FormEvent) {
    e.preventDefault();
    if (!p.name.trim()) return setError("Geef de pagina een naam.");
    setBusy(true);
    try {
      await savePage({ ...p, name: p.name.trim() });
      onSaved(p.id);
      onClose();
    } catch (err) {
      setError(errorMessage(err));
      setBusy(false);
    }
  }

  async function remove() {
    if (!confirm(`Pagina “${p.name}” en al haar rijen verwijderen?`)) return;
    setBusy(true);
    try {
      await onDelete();
      onClose();
    } catch (err) {
      setError(errorMessage(err));
      setBusy(false);
    }
  }

  return (
    <Sheet
      open
      busy={busy}
      title={isNew ? "Nieuwe pagina" : "Pagina-instellingen"}
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
          <Button type="submit" form="page-form" variant="primary" busy={busy}>
            Opslaan
          </Button>
        </>
      }
    >
      <form id="page-form" onSubmit={save} className="space-y-5">
        <Field label="Naam (tabblad in de app)">
          {(id) => <Input id={id} value={p.name} onChange={(e) => setP({ ...p, name: e.target.value })} />}
        </Field>
        <Switch
          label="Duur tonen bij tracks"
          checked={p.config.showItemDurations}
          onChange={(showItemDurations) => setP({ ...p, config: { showItemDurations } })}
        />
        {error && <p className="text-sm text-ember">{error}</p>}
      </form>
    </Sheet>
  );
}

function BlockEditor({
  initial,
  isNew,
  trackOptions,
  playlistOptions,
  onClose,
}: {
  initial: Block;
  isNew: boolean;
  trackOptions: { id: string; label: string; sub?: string }[];
  playlistOptions: { id: string; label: string; sub?: string }[];
  onClose: () => void;
}) {
  const [b, setB] = useState(initial);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const set = (patch: Partial<Block>) => setB((prev) => ({ ...prev, ...patch }));

  const empty =
    b.type === "Series" ? !b.playlistIds?.length : b.type === "Hero" ? !b.trackId : !b.trackIds?.length;

  async function save(e: React.FormEvent) {
    e.preventDefault();
    if (!b.title.trim()) return setError("Geef de rij een titel.");
    if (empty) return setError(b.type === "Series" ? "Kies minstens één playlist." : "Kies minstens één track.");
    setBusy(true);
    try {
      await saveBlock({ ...b, title: b.title.trim() });
      onClose();
    } catch (err) {
      setError(errorMessage(err));
      setBusy(false);
    }
  }

  async function remove() {
    if (!confirm(`Rij “${b.title}” verwijderen?`)) return;
    setBusy(true);
    try {
      await deleteBlock(b.id);
      onClose();
    } catch (err) {
      setError(errorMessage(err));
      setBusy(false);
    }
  }

  return (
    <Sheet
      open
      busy={busy}
      wide
      title={isNew ? "Nieuwe rij" : "Rij bewerken"}
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
          <Button type="submit" form="block-form" variant="primary" busy={busy}>
            Opslaan
          </Button>
        </>
      }
    >
      <form id="block-form" onSubmit={save} className="space-y-5">
        <Field label="Titel">{(id) => <Input id={id} value={b.title} onChange={(e) => set({ title: e.target.value })} />}</Field>
        <Field label="Soort rij" hint={TYPE_INFO[b.type]}>
          {(id) => (
            <Select id={id} value={b.type} onChange={(e) => set({ type: e.target.value as BlockType })}>
              <option value="Hero">Uitgelicht</option>
              <option value="Featured">Brede tegels</option>
              <option value="Normal">Tracks</option>
              <option value="Series">Playlists</option>
            </Select>
          )}
        </Field>
        {b.type === "Series" ? (
          <OrderedPicker label="Playlists" options={playlistOptions} value={b.playlistIds ?? []} onChange={(playlistIds) => set({ playlistIds })} />
        ) : b.type === "Hero" ? (
          <OrderedPicker label="Track" max={1} options={trackOptions} value={b.trackId ? [b.trackId] : []} onChange={(v) => set({ trackId: v[0] })} />
        ) : (
          <OrderedPicker label="Tracks" options={trackOptions} value={b.trackIds ?? []} onChange={(trackIds) => set({ trackIds })} />
        )}
        {error && <p className="text-sm text-ember">{error}</p>}
      </form>
    </Sheet>
  );
}
