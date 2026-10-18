"use client";

import { Plus, Smartphone } from "lucide-react";
import { useMemo, useState } from "react";
import { Field, OrderedPicker, Switch } from "@/components/form";
import { PagePreview, type PreviewLanguage } from "@/components/page-preview";
import { Sheet } from "@/components/sheet";
import { SortableItem, SortableList, useOptimisticOrder } from "@/components/sortable";
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

export default function PagesPage() {
  const { items: storedPages, error } = useCollection("pages", "order", toPage);
  const { items: blocks } = useCollection("blocks", "sequence", toBlock);
  const { items: tracks } = useCollection("tracks", "title", toTrack);
  const { items: playlists } = useCollection("playlists", "title", toPlaylist);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [editingPage, setEditingPage] = useState<{ page: Page; isNew: boolean } | null>(null);
  const [editingBlock, setEditingBlock] = useState<{ block: Block; isNew: boolean } | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);
  const [previewOpen, setPreviewOpen] = useState(false);
  const [previewLang, setPreviewLang] = useState<PreviewLanguage>("en");
  const orderFailed = (e: unknown) => setActionError(`De nieuwe volgorde is niet opgeslagen. ${errorMessage(e)}`);

  // A dragged order shows at once and rolls back if the write fails.
  const [pages, reorderPages] = useOptimisticOrder(storedPages, (ids) => reorder("pages", ids), orderFailed);
  const selected = pages?.find((p) => p.id === selectedId) ?? pages?.[0] ?? null;
  const pageIds = useMemo(() => (pages ?? []).map((p) => p.id), [pages]);
  const selectedBlocks = useMemo(() => (blocks ?? []).filter((b) => b.pageId === selected?.id), [blocks, selected]);
  const [pageBlocks, reorderBlocks] = useOptimisticOrder(selectedBlocks, (ids) => reorder("blocks", ids), orderFailed);
  const trackOptions = useMemo(() => (tracks ?? []).map((t) => ({ id: t.id, label: t.title, sub: t.speaker })), [tracks]);
  const playlistOptions = useMemo(
    () => (playlists ?? []).map((p) => ({ id: p.id, label: p.title, sub: `${p.trackIds.length} tracks` })),
    [playlists],
  );

  function closePreview() {
    setPreviewOpen(false);
    document.getElementById("page-preview-toggle")?.focus();
  }

  // With the preview open, wide screens keep the rows clear of it, so both stay usable side by side.
  const roomForPreview = previewOpen && selected ? "xl:box-content xl:pr-[426px]" : "";

  return (
    <div className={`mx-auto max-w-5xl ${roomForPreview}`}>
      <header className="mb-8">
        <h1 className="font-display text-[2rem] leading-tight font-medium tracking-[-0.02em] text-ink">Pagina&apos;s</h1>
        <p className="mt-1.5 max-w-prose text-[15px] text-ink-soft">
          De tabbladen in de app en de rijen erop. De eerste pagina is het startscherm.
        </p>
      </header>

      {(error || actionError) && (
        <p role="alert" className="mb-3 text-sm text-ember">
          {error || actionError}
        </p>
      )}

      <div className="grid gap-6 md:grid-cols-[240px_minmax(0,1fr)]">
        <section aria-label="Pagina's">
          <SortableList
            as="ul"
            ids={pageIds}
            label={(id) => pages?.find((p) => p.id === id)?.name || "Zonder naam"}
            onReorder={(ids) => {
              setActionError(null);
              reorderPages(ids);
            }}
            className="divide-y divide-line overflow-hidden rounded-2xl border border-line bg-surface"
          >
            {(pages ?? []).map((p) => (
              <SortableItem
                key={p.id}
                id={p.id}
                handleClassName="p-1.5"
                className={`flex items-center pl-1.5 data-dragging:rounded-lg data-dragging:border-transparent ${selected?.id === p.id ? "bg-dusk-wash" : "data-dragging:bg-surface"}`}
              >
                <button onClick={() => setSelectedId(p.id)} aria-current={selected?.id === p.id} className="min-w-0 flex-1 truncate py-3 pr-4 pl-1.5 text-left text-sm font-medium text-ink">
                  {p.name || "Zonder naam"}
                </button>
              </SortableItem>
            ))}
          </SortableList>
          <Button
            className="mt-3 w-full"
            icon={<Plus className="size-4" aria-hidden />}
            onClick={() =>
              setEditingPage({
                page: { id: newId("pages"), name: "", nameNl: "", order: pages?.length ?? 0, config: { showItemDurations: true } },
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
                    id="page-preview-toggle"
                    variant="ghost"
                    aria-expanded={previewOpen}
                    aria-controls="page-preview"
                    icon={<Smartphone className="size-4" aria-hidden />}
                    onClick={() => (previewOpen ? closePreview() : setPreviewOpen(true))}
                  >
                    Voorbeeld
                  </Button>
                  <Button
                    icon={<Plus className="size-4" aria-hidden />}
                    onClick={() =>
                      setEditingBlock({
                        block: {
                          id: newId("blocks"),
                          pageId: selected.id,
                          title: "",
                          titleNl: "",
                          type: "Normal",
                          sequence: pageBlocks.length,
                          trackIds: [],
                        },
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
                <SortableList
                  ids={pageBlocks.map((b) => b.id)}
                  label={(id) => pageBlocks.find((b) => b.id === id)?.title || "Zonder titel"}
                  onReorder={(ids) => {
                    setActionError(null);
                    reorderBlocks(ids);
                  }}
                  className="space-y-2"
                >
                  {pageBlocks.map((b) => {
                    const count = b.type === "Series" ? b.playlistIds?.length : b.type === "Hero" ? (b.trackId ? 1 : 0) : b.trackIds?.length;
                    return (
                      <SortableItem
                        key={b.id}
                        id={b.id}
                        handleClassName="p-1.5"
                        className="flex items-center gap-2 rounded-2xl border border-line bg-surface py-3 pr-4 pl-2"
                      >
                        <button onClick={() => setEditingBlock({ block: b, isNew: false })} className="min-w-0 flex-1 text-left">
                          <span className="block truncate font-medium text-ink">{b.title || "Zonder titel"}</span>
                          <span className="block text-sm text-ink-faint">
                            {TYPE_INFO[b.type]} · <span className="tabular">{count ?? 0}</span> {b.type === "Series" ? "playlists" : "tracks"}
                          </span>
                        </button>
                      </SortableItem>
                    );
                  })}
                </SortableList>
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
      {previewOpen && selected && (
        <PagePreview
          page={selected}
          pages={pages ?? []}
          blocks={pageBlocks}
          lang={previewLang}
          onLangChange={setPreviewLang}
          onClose={closePreview}
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
      error={error}
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
          <Button type="button" variant="ghost" onClick={onClose} disabled={busy}>
            Annuleren
          </Button>
          <Button type="submit" form="page-form" variant="primary" busy={busy}>
            Opslaan
          </Button>
        </>
      }
    >
      <form id="page-form" onSubmit={save} className="space-y-5">
        <Field label="Naam tabblad (EN)">
          {(id) => <Input id={id} value={p.name} onChange={(e) => setP({ ...p, name: e.target.value })} />}
        </Field>
        <Field label="Naam tabblad (NL)" hint="Leeg = Engelse tekst wordt getoond">
          {(id) => <Input id={id} value={p.nameNl} onChange={(e) => setP({ ...p, nameNl: e.target.value })} />}
        </Field>
        <Switch
          label="Duur tonen bij tracks"
          checked={p.config.showItemDurations}
          onChange={(showItemDurations) => setP({ ...p, config: { showItemDurations } })}
        />
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
      error={error}
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
          <Button type="button" variant="ghost" onClick={onClose} disabled={busy}>
            Annuleren
          </Button>
          <Button type="submit" form="block-form" variant="primary" busy={busy}>
            Opslaan
          </Button>
        </>
      }
    >
      <form id="block-form" onSubmit={save} className="space-y-5">
        <div className="grid gap-5 sm:grid-cols-2">
          <Field label="Titel (EN)">{(id) => <Input id={id} value={b.title} onChange={(e) => set({ title: e.target.value })} />}</Field>
          <Field label="Titel (NL)" hint="Leeg = Engelse tekst wordt getoond">
            {(id) => <Input id={id} value={b.titleNl} onChange={(e) => set({ titleNl: e.target.value })} />}
          </Field>
        </div>
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
      </form>
    </Sheet>
  );
}
