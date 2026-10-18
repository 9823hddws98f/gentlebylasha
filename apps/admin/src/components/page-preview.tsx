"use client";

import {
  BatteryFull,
  CircleUserRound,
  House,
  ImageOff,
  ListMusic,
  Lock,
  Play,
  Search,
  Signal,
  TriangleAlert,
  Unlink,
  Wifi,
  X,
} from "lucide-react";
import { type ReactNode, useEffect, useMemo, useRef } from "react";
import { type Block, type Page, type Playlist, toPlaylist, toTrack, type Track, useCollection } from "@/lib/content";
import type { TxImage } from "@/lib/media";
import { Button } from "./ui";

// A phone-sized mock of one page as the Flutter app draws it in its dark theme:
// lib/screens/home (first page) and lib/screens/explore (the others), with rows
// from lib/widgets/blocks. Sizes are the app's own, in logical pixels.

export type PreviewLanguage = "en" | "nl";

/** The app's own strings on these screens (lib/l10n/app_*.arb). */
const APP_TEXT = {
  en: {
    home: "Home",
    explore: "Explore",
    more: "More",
    search: "Search",
    seeAll: "See all",
    sessions: (n: number) => (n === 1 ? "1 Session" : `${n} Sessions`),
  },
  nl: {
    home: "Thuis",
    explore: "Ontdekken",
    more: "Meer",
    search: "Zoeken",
    seeAll: "Alles bekijken",
    sessions: (n: number) => (n === 1 ? "1 sessie" : `${n} sessies`),
  },
};

/** localizedContent in lib/utils/localized_content.dart: Dutch when filled in, else the default text. */
const localized = (value: string, nl: string, lang: PreviewLanguage) => (lang === "nl" && nl.trim() ? nl : value);

/** AudioTrack.durationString: whole minutes and seconds, rounded down. */
function appDuration(ms: number) {
  const s = Math.floor(ms / 1000);
  return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;
}

const hex = (argb: number) => `#${(argb & 0xffffff).toString(16).padStart(6, "0")}`;

/** ItemTag: the dominant colour mixed 30% toward the surface, or the theme's green without one. */
const tagColor = (argb: number | null | undefined) =>
  argb == null ? "var(--app-leaf)" : `color-mix(in srgb, ${hex(argb)} 70%, var(--app-surface))`;

/** The admin's Track plus the top-level `dominantColor` the app tints the duration tag with. */
type PreviewTrack = Track & { dominantColor: number | null };
const toPreviewTrack = (id: string, v: Record<string, unknown>): PreviewTrack => ({
  ...toTrack(id, v),
  dominantColor: typeof v.dominantColor === "number" ? v.dominantColor : null,
});

type Item =
  | { kind: "track"; id: string; track: PreviewTrack }
  | { kind: "playlist"; id: string; playlist: Playlist }
  | { kind: "missing"; id: string; of: "track" | "playlist" }
  | { kind: "loading"; id: string };

/** The row's items in the app's order. The app fetches them with `whereIn`, so repeats show once. */
function itemsOf(block: Block, tracks: Map<string, PreviewTrack> | null, playlists: Map<string, Playlist> | null): Item[] {
  if (block.type === "Series") {
    return [...new Set(block.playlistIds ?? [])].map((id): Item => {
      if (!playlists) return { kind: "loading", id };
      const playlist = playlists.get(id);
      return playlist ? { kind: "playlist", id, playlist } : { kind: "missing", id, of: "playlist" };
    });
  }
  const ids = block.type === "Hero" ? (block.trackId ? [block.trackId] : []) : (block.trackIds ?? []);
  return [...new Set(ids)].map((id): Item => {
    if (!tracks) return { kind: "loading", id };
    const track = tracks.get(id);
    return track ? { kind: "track", id, track } : { kind: "missing", id, of: "track" };
  });
}

export function PagePreview({
  page,
  pages,
  blocks,
  lang,
  onLangChange,
  onClose,
}: {
  page: Page;
  /** All pages in app order: the first is the home screen, the rest are the tabs under Explore. */
  pages: Page[];
  /** This page's rows in order, as the editor shows them (a drag shows here at once). */
  blocks: Block[];
  lang: PreviewLanguage;
  onLangChange: (lang: PreviewLanguage) => void;
  onClose: () => void;
}) {
  // Same queries as the Pages screen, so the SDK shares one listener; this mapper also keeps dominantColor.
  const { items: trackList } = useCollection("tracks", "title", toPreviewTrack);
  const { items: playlistList } = useCollection("playlists", "title", toPlaylist);
  const tracks = useMemo(() => trackList && new Map(trackList.map((t) => [t.id, t])), [trackList]);
  const playlists = useMemo(() => playlistList && new Map(playlistList.map((p) => [p.id, p])), [playlistList]);

  const isHome = pages[0]?.id === page.id;
  const tabs = useMemo(() => pages.slice(1), [pages]);
  const rows = useMemo(() => blocks.map((block) => ({ block, items: itemsOf(block, tracks, playlists) })), [blocks, tracks, playlists]);

  const { missingTracks, missingPlaylists, untranslated } = useMemo(() => {
    let missingTracks = 0;
    let missingPlaylists = 0;
    const untranslated = new Set<string>();
    const check = (key: string, value: string, nl: string) => {
      if (value.trim() && !nl.trim()) untranslated.add(key);
    };
    if (!isHome) tabs.forEach((p) => check(`page:${p.id}`, p.name, p.nameNl));
    for (const { block, items } of rows) {
      // A Hero row shows no title in the app.
      if (block.type !== "Hero") check(`block:${block.id}`, block.title, block.titleNl);
      for (const item of items) {
        if (item.kind === "missing" && item.of === "track") missingTracks++;
        if (item.kind === "missing" && item.of === "playlist") missingPlaylists++;
        if (item.kind === "track") check(`track:${item.id}`, item.track.title, item.track.titleNl);
        if (item.kind === "playlist") check(`playlist:${item.id}`, item.playlist.title, item.playlist.titleNl);
      }
    }
    return { missingTracks, missingPlaylists, untranslated: untranslated.size };
  }, [rows, tabs, isHome]);

  const closeButton = useRef<HTMLButtonElement>(null);
  // Opening moves focus into the panel; Escape or the close button hands it back.
  useEffect(() => {
    closeButton.current?.focus({ preventScroll: true });
  }, []);

  const pageName = localized(page.name, page.nameNl, lang) || "Zonder naam";
  const missingCount = missingTracks + missingPlaylists;
  const missingLabel = [
    missingTracks && `${missingTracks} ${missingTracks === 1 ? "track" : "tracks"}`,
    missingPlaylists && `${missingPlaylists} ${missingPlaylists === 1 ? "playlist" : "playlists"}`,
  ]
    .filter(Boolean)
    .join(" en ");

  return (
    <section
      id="page-preview"
      aria-label={`Voorbeeld van ${page.name || "de pagina"} in de app`}
      onKeyDown={(e) => {
        if (e.key === "Escape") {
          e.stopPropagation();
          onClose();
        }
      }}
      className="fixed inset-y-0 right-0 z-30 flex w-[450px] max-w-full flex-col border-l border-line bg-paper shadow-[-24px_0_60px_-24px_rgb(16_22_42/0.3)] animate-[sheet_380ms_var(--ease-out-expo)] xl:shadow-none"
    >
      <header className="px-5 pt-5 pb-4">
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0">
            <h2 className="font-display text-xl font-medium text-ink">Voorbeeld</h2>
            <p className="mt-0.5 truncate text-sm text-ink-soft">
              {pageName} · {isHome ? "startscherm" : `tabblad onder ${APP_TEXT[lang].explore}`}
            </p>
          </div>
          <div className="flex shrink-0 items-center gap-1">
            <LanguageToggle value={lang} onChange={onLangChange} />
            <Button
              ref={closeButton}
              type="button"
              variant="ghost"
              aria-label="Voorbeeld sluiten"
              className="-mr-2 px-2"
              onClick={onClose}
              icon={<X className="size-4" aria-hidden />}
            />
          </div>
        </div>
        <div aria-live="polite" className="mt-3 space-y-1.5 text-[13px] leading-snug empty:mt-0">
          {missingCount > 0 && (
            <p className="flex gap-2 text-ember">
              <TriangleAlert className="mt-px size-3.5 shrink-0" aria-hidden />
              <span>
                {missingLabel} {missingCount === 1 ? "ontbreekt" : "ontbreken"}.{" "}
                {missingCount === 1 ? "De app laat hem weg; hier staat hij gemarkeerd." : "De app laat ze weg; hier staan ze gemarkeerd."}
              </span>
            </p>
          )}
          {lang === "nl" && untranslated > 0 && (
            <p className="text-ink-soft">
              {untranslated === 1
                ? "1 tekst heeft geen Nederlandse versie en staat in het Engels."
                : `${untranslated} teksten hebben geen Nederlandse versie en staan in het Engels.`}
            </p>
          )}
        </div>
      </header>

      <div className="flex min-h-0 flex-1 justify-center px-5 pb-5">
        <div className="flex h-full max-h-[864px] w-full max-w-[410px] rounded-[50px] bg-[#05080f] p-2.5 shadow-[0_24px_48px_-16px_rgb(16_22_42/0.45),inset_0_0_0_1px_rgb(255_255_255/0.08)]">
          <div className="app-screen flex min-w-0 flex-1 flex-col overflow-hidden rounded-[40px] bg-app-bg text-app-ink">
            <StatusBar />
            <div
              key={page.id}
              role="group"
              tabIndex={0}
              aria-label="Scherm van de app"
              className="min-h-0 flex-1 overflow-y-auto overscroll-contain"
            >
              <div lang={lang}>
              <p className="flex h-[68px] items-center px-4 text-2xl font-medium">{isHome ? APP_TEXT[lang].home : APP_TEXT[lang].explore}</p>
              {!isHome && <ExploreHeader tabs={tabs} current={page.id} lang={lang} />}
              {rows.length === 0 ? (
                <p lang="nl" className="px-4 py-16 text-center text-sm text-app-ink-soft">
                  Deze pagina heeft nog geen rijen.
                </p>
              ) : (
                rows.map(({ block, items }, i) => (
                  <div key={block.id}>
                    {i > 0 && (
                      <div className="px-4 pt-4 pb-2">
                        <hr className="border-app-line" />
                      </div>
                    )}
                    <Row block={block} items={items} lang={lang} showDurations={page.config.showItemDurations} />
                  </div>
                ))
              )}
              </div>
              <div className="h-4" />
            </div>
            <BottomBar home={isHome} lang={lang} />
          </div>
        </div>
      </div>
    </section>
  );
}

function LanguageToggle({ value, onChange }: { value: PreviewLanguage; onChange: (v: PreviewLanguage) => void }) {
  return (
    <div role="group" aria-label="Taal van de app" className="relative grid h-8 grid-cols-2 rounded-lg border border-line-strong bg-surface p-0.5">
      <span
        aria-hidden
        className={`absolute inset-y-0.5 left-0.5 w-[calc(50%-2px)] rounded-md bg-ink transition-transform duration-200 ease-out-expo ${value === "nl" ? "translate-x-full" : ""}`}
      />
      {(["en", "nl"] as const).map((l) => (
        <button
          key={l}
          type="button"
          aria-pressed={value === l}
          lang={l}
          aria-label={l === "en" ? "Engels" : "Nederlands"}
          onClick={() => onChange(l)}
          className={`relative w-9 rounded-md text-xs font-semibold tracking-wide uppercase transition-colors duration-150 ${value === l ? "text-white" : "text-ink-soft hover:text-ink"}`}
        >
          {l}
        </button>
      ))}
    </div>
  );
}

function StatusBar() {
  return (
    <div aria-hidden className="flex h-11 shrink-0 items-center justify-between pr-6 pl-8 text-[15px] font-semibold">
      <span className="tabular">22:30</span>
      <span className="flex items-center gap-1.5">
        <Signal className="size-4" strokeWidth={2.5} />
        <Wifi className="size-4" strokeWidth={2.5} />
        <BatteryFull className="size-5" strokeWidth={2} />
      </span>
    </div>
  );
}

/** ExploreScreen: search field, then the other pages as tabs with this one selected. */
function ExploreHeader({ tabs, current, lang }: { tabs: Page[]; current: string; lang: PreviewLanguage }) {
  const list = useRef<HTMLUListElement>(null);
  useEffect(() => {
    const el = list.current;
    const tab = el?.querySelector<HTMLElement>("[aria-current]");
    if (el && tab) el.scrollLeft = tab.offsetLeft - (el.clientWidth - tab.offsetWidth) / 2;
  }, [current]);

  return (
    <>
      <div aria-hidden className="px-4 py-1">
        <div className="flex h-12 items-center justify-between rounded-xl border border-app-line bg-app-ink-soft/10 pr-3 pl-4 text-app-ink-soft">
          {APP_TEXT[lang].search}
          <Search className="size-5 text-app-ink" />
        </div>
      </div>
      <ul ref={list} aria-label={`Tabbladen onder ${APP_TEXT[lang].explore}`} className="relative mt-3 mb-2 flex gap-2 overflow-x-auto px-4 pb-2">
        {tabs.map((p) => (
          <li
            key={p.id}
            aria-current={p.id === current ? "true" : undefined}
            className={`flex h-[47px] shrink-0 items-center rounded-[10px] border border-app-line px-[18px] text-sm font-medium whitespace-nowrap ${
              p.id === current ? "bg-app-leaf text-white" : "bg-app-surface text-app-ink"
            }`}
          >
            {localized(p.name, p.nameNl, lang)}
          </li>
        ))}
      </ul>
    </>
  );
}

function BottomBar({ home, lang }: { home: boolean; lang: PreviewLanguage }) {
  const t = APP_TEXT[lang];
  const items = [
    { label: t.home, icon: House, active: home },
    { label: t.explore, icon: Search, active: !home },
    { label: t.more, icon: CircleUserRound, active: false },
  ];
  return (
    <div aria-hidden className="shrink-0 border-t border-app-line">
      <div className="flex h-[53px]">
        {items.map(({ label, icon: Icon, active }) => (
          <span key={label} className={`flex flex-1 flex-col items-center justify-center gap-0.5 text-xs ${active ? "text-app-ink" : "text-app-ink-soft"}`}>
            <Icon className="size-6" strokeWidth={1.75} />
            {label}
          </span>
        ))}
      </div>
      <div className="flex h-[21px] justify-center">
        <span className="mt-2 h-[5px] w-[134px] rounded-full bg-app-ink/85" />
      </div>
    </div>
  );
}

function Row({ block, items, lang, showDurations }: { block: Block; items: Item[]; lang: PreviewLanguage; showDurations: boolean }) {
  // HeroBlockItem: one large, centred track and no row header.
  if (block.type === "Hero") {
    const item = items[0];
    return (
      <div className="mx-auto flex h-[370px] w-[255px] flex-col items-center">
        {!item ? (
          <Placeholder className="size-[255px]">Geen track gekozen</Placeholder>
        ) : item.kind === "missing" ? (
          <MissingCard item={item} className="size-[255px]" />
        ) : item.kind === "track" ? (
          <>
            <Artwork image={item.track.thumbnail} alt={localized(item.track.title, item.track.titleNl, lang)} className="size-[255px] shrink-0">
              <Tag icon={<Play />} text={`${appDuration(item.track.duration)} min`} color={tagColor(item.track.dominantColor)} />
            </Artwork>
            <p className="mt-4 line-clamp-2 text-center text-2xl leading-tight font-medium">
              {localized(item.track.title, item.track.titleNl, lang)}
            </p>
            <p className="mt-2 max-w-full truncate text-base text-app-ink-soft">{item.track.speaker}</p>
          </>
        ) : (
          <Skeleton className="size-[255px]" />
        )}
      </div>
    );
  }

  const title = localized(block.title, block.titleNl, lang);
  const wide = block.type === "Featured";
  return (
    <div>
      <div className="flex items-center gap-3 px-4 pt-2 pb-4">
        <h3 className="min-w-0 flex-1 text-xl leading-tight font-medium">{title}</h3>
        <span className="shrink-0 text-base">{APP_TEXT[lang].seeAll}</span>
      </div>
      <ul tabIndex={0} aria-label={title} className="flex gap-4 overflow-x-auto overflow-y-hidden px-4">
        {items.length === 0 && (
          <li className="w-full">
            <Placeholder className="h-[219px]">Deze rij is leeg</Placeholder>
          </li>
        )}
        {items.map((item) => (
          <li key={item.id} className={`flex h-[219px] shrink-0 flex-col ${wide ? "w-[242px]" : "w-[164px]"}`}>
            {item.kind === "track" ? (
              <TrackCard track={item.track} lang={lang} showDuration={showDurations} />
            ) : item.kind === "playlist" ? (
              <PlaylistCard playlist={item.playlist} lang={lang} showCount={showDurations} />
            ) : item.kind === "missing" ? (
              <MissingCard item={item} className="min-h-0 flex-1" withCaption />
            ) : (
              <Skeleton className="min-h-0 flex-1" withCaption />
            )}
          </li>
        ))}
      </ul>
    </div>
  );
}

/** AudioBlockItem (Normal and Featured rows). */
function TrackCard({ track, lang, showDuration }: { track: PreviewTrack; lang: PreviewLanguage; showDuration: boolean }) {
  const title = localized(track.title, track.titleNl, lang);
  return (
    <>
      <Artwork image={track.thumbnail} alt={title} className="min-h-0 flex-1">
        <Tag icon={<Play />} text={showDuration ? `${appDuration(track.duration)} min` : undefined} color={tagColor(track.dominantColor)} />
      </Artwork>
      <div className="mt-4 flex h-[18px] items-center gap-1">
        <p className="truncate text-sm leading-[18px] font-medium">{title}</p>
        {track.premium && (
          <>
            <Lock className="size-3.5 shrink-0" strokeWidth={2.5} aria-hidden />
            <span className="sr-only">Premium</span>
          </>
        )}
      </div>
      <p className="mt-0.5 h-[15px] truncate text-xs leading-[15px] text-app-ink-soft">{track.speaker}</p>
    </>
  );
}

/** PlaylistBlockItem (Series rows). */
function PlaylistCard({ playlist, lang, showCount }: { playlist: Playlist; lang: PreviewLanguage; showCount: boolean }) {
  const title = localized(playlist.title, playlist.titleNl, lang);
  return (
    <>
      <Artwork image={playlist.thumbnail} alt={title} className="min-h-0 flex-1">
        <Tag
          icon={<ListMusic />}
          text={showCount ? APP_TEXT[lang].sessions(playlist.trackIds.length) : undefined}
          color={tagColor(playlist.thumbnail?.dominantColor)}
        />
      </Artwork>
      <p className="mt-4 h-[18px] truncate text-sm leading-[18px] font-medium">{title}</p>
      <p className="mt-0.5 h-[15px] truncate text-xs leading-[15px] text-app-ink-soft">{playlist.author}</p>
    </>
  );
}

function Artwork({ image, alt, className, children }: { image: TxImage | null; alt: string; className: string; children: ReactNode }) {
  return (
    <div
      className={`relative overflow-hidden rounded-[10px] bg-app-surface ${className}`}
      style={image?.dominantColor != null ? { backgroundColor: hex(image.dominantColor) } : undefined}
    >
      {image ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img src={image.url} alt={alt} loading="lazy" decoding="async" className="size-full object-cover" />
      ) : (
        <span lang="nl" className="absolute inset-0 flex flex-col items-center justify-center gap-1.5 text-xs text-app-ink-soft">
          <ImageOff className="size-5" aria-hidden />
          Geen afbeelding
        </span>
      )}
      {children}
    </div>
  );
}

/** ItemTag: the small duration or session-count label on a cover. */
function Tag({ icon, text, color }: { icon: ReactNode; text?: string; color: string }) {
  return (
    <span
      className="absolute bottom-2 left-2 flex items-center gap-1 rounded-lg p-1.5 text-[10px] leading-2.5 font-medium text-white [text-shadow:0.2px_0.5px_4px_rgb(153_161_183/0.5)] [&_svg]:size-2.5 [&_svg]:fill-current"
      style={{ backgroundColor: color }}
    >
      <span aria-hidden className="contents">
        {icon}
      </span>
      {text && <span className="tabular">{text}</span>}
    </span>
  );
}

/** A reference to a track or playlist that no longer exists. The app silently skips it. */
function MissingCard({ item, className, withCaption = false }: { item: { id: string; of: "track" | "playlist" }; className: string; withCaption?: boolean }) {
  return (
    <div lang="nl" className={`flex flex-col ${withCaption ? "h-full" : ""}`}>
      <div
        className={`flex flex-col items-center justify-center gap-1.5 rounded-[10px] border border-dashed border-app-missing/50 bg-app-missing/[0.07] text-app-missing ${className}`}
      >
        <Unlink className="size-4" aria-hidden />
        <span className="text-xs font-medium">{item.of === "track" ? "Track" : "Playlist"} ontbreekt</span>
        {!withCaption && <span className="max-w-[80%] truncate font-mono text-[11px] text-app-ink-soft">{item.id}</span>}
      </div>
      {withCaption && (
        <>
          <p className="mt-4 h-[18px] truncate font-mono text-[11px] leading-[18px] text-app-ink-soft" title={item.id}>
            {item.id}
          </p>
          <p className="mt-0.5 h-[15px] text-xs leading-[15px] text-app-ink-soft">niet in de app</p>
        </>
      )}
    </div>
  );
}

function Placeholder({ className, children }: { className: string; children: ReactNode }) {
  return (
    <div lang="nl" className={`flex items-center justify-center rounded-[10px] border border-dashed border-app-line text-xs text-app-ink-soft ${className}`}>
      {children}
    </div>
  );
}

function Skeleton({ className, withCaption = false }: { className: string; withCaption?: boolean }) {
  return (
    <>
      <div aria-hidden className={`animate-pulse rounded-[10px] bg-app-surface ${className}`} />
      {withCaption && (
        <div aria-hidden className="animate-pulse">
          <div className="mt-4 h-4 w-[120px] max-w-full rounded-[10px] bg-app-surface" />
          <div className="mt-0.5 h-3 w-20 rounded-[10px] bg-app-surface" />
        </div>
      )}
    </>
  );
}
