"use client";

import { collection, deleteDoc, doc, onSnapshot, orderBy, query, setDoc, writeBatch } from "firebase/firestore";
import { useEffect, useState } from "react";
import { call, db } from "./firebase";
import type { TxImage } from "./media";

// Shapes mirror the Flutter models in lib/domain/models.

export interface Track {
  id: string;
  title: string;
  writer: string;
  speaker: string;
  description: string;
  trackUrl: string;
  duration: number;
  hasTimer: boolean;
  premium: boolean;
  thumbnail: TxImage | null;
  imageBackground: TxImage | null;
}

export interface Playlist {
  id: string;
  title: string;
  author: string;
  profession: string;
  description: string;
  thumbnail: TxImage | null;
  authorImage: TxImage | null;
  showAudioThumbnails: boolean;
  trackIds: string[];
}

export interface Page {
  id: string;
  name: string;
  order: number;
  config: { showItemDurations: boolean };
}

/** Stored as the Flutter BlockType display names. */
export type BlockType = "Normal" | "Featured" | "Series" | "Hero";

export interface Block {
  id: string;
  pageId: string;
  title: string;
  type: BlockType;
  sequence: number;
  trackIds?: string[];
  playlistIds?: string[];
  trackId?: string;
}

export function useCollection<T>(name: string, order: string, map: (id: string, data: Record<string, unknown>) => T) {
  const [items, setItems] = useState<T[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  useEffect(
    () =>
      onSnapshot(
        query(collection(db, name), orderBy(order)),
        (snap) => setItems(snap.docs.map((d) => map(d.id, d.data()))),
        () => {
          setError("Laden mislukt.");
          setItems([]);
        },
      ),
    // map is a module-level function; name/order identify the query
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [name, order],
  );
  return { items, error };
}

const str = (v: unknown) => (typeof v === "string" ? v : "");
const img = (v: unknown) => (v && typeof v === "object" && "url" in v ? (v as TxImage) : null);
const ids = (v: unknown) => (Array.isArray(v) ? (v as string[]) : []);

export const toTrack = (id: string, v: Record<string, unknown>): Track => ({
  id,
  title: str(v.title),
  writer: str(v.writer),
  speaker: str(v.speaker),
  description: str(v.description),
  trackUrl: str(v.trackUrl),
  duration: typeof v.duration === "number" ? v.duration : 0,
  hasTimer: v.hasTimer === true,
  premium: v.premium === true,
  thumbnail: img(v.thumbnail),
  imageBackground: img(v.imageBackground),
});

export const toPlaylist = (id: string, v: Record<string, unknown>): Playlist => ({
  id,
  title: str(v.title),
  author: str(v.author),
  profession: str(v.profession),
  description: str(v.description),
  thumbnail: img(v.thumbnail),
  authorImage: img(v.authorImage),
  showAudioThumbnails: v.showAudioThumbnails === true,
  trackIds: ids(v.trackIds),
});

export const toPage = (id: string, v: Record<string, unknown>): Page => ({
  id,
  name: str(v.name),
  order: typeof v.order === "number" ? v.order : 0,
  config: { showItemDurations: (v.config as { showItemDurations?: boolean })?.showItemDurations === true },
});

export const toBlock = (id: string, v: Record<string, unknown>): Block => ({
  id,
  pageId: str(v.pageId),
  title: str(v.title),
  type: (["Normal", "Featured", "Series", "Hero"].includes(str(v.type)) ? v.type : "Normal") as BlockType,
  sequence: typeof v.sequence === "number" ? v.sequence : 0,
  trackIds: ids(v.trackIds),
  playlistIds: ids(v.playlistIds),
  trackId: str(v.trackId) || undefined,
});

export const newId = (name: string) => doc(collection(db, name)).id;

const setTrackPremium = call<{ trackId: string; premium: boolean }, { success: boolean }>("adminSetTrackPremium");

/** Saves a track. Premium tracks keep their audio out of tracks/{id} (see adminSetTrackPremium). */
export async function saveTrack(t: Track, audioChanged: boolean) {
  const { premium, ...rest } = t;
  const data: Record<string, unknown> = { ...rest };
  // A premium track's trackUrl is empty on purpose; only write it when new audio was uploaded.
  if (premium && !audioChanged) delete data.trackUrl;
  await setDoc(doc(db, "tracks", t.id), data, { merge: true });
  if (premium && audioChanged) await setTrackPremium({ trackId: t.id, premium: true });
}

export async function deleteTrack(t: Track) {
  if (t.premium) await setTrackPremium({ trackId: t.id, premium: false });
  await deleteDoc(doc(db, "tracks", t.id));
}

export const savePlaylist = (p: Playlist) => setDoc(doc(db, "playlists", p.id), { ...p });
export const deletePlaylist = (id: string) => deleteDoc(doc(db, "playlists", id));

export const savePage = (p: Page) => setDoc(doc(db, "pages", p.id), { ...p });

export async function deletePage(page: Page, blocks: Block[]) {
  const batch = writeBatch(db);
  blocks.filter((b) => b.pageId === page.id).forEach((b) => batch.delete(doc(db, "blocks", b.id)));
  batch.delete(doc(db, "pages", page.id));
  await batch.commit();
}

/** Writes only the fields the Flutter block type reads. */
export function saveBlock(b: Block) {
  const base = { id: b.id, pageId: b.pageId, title: b.title, type: b.type, sequence: b.sequence };
  const data =
    b.type === "Series"
      ? { ...base, playlistIds: b.playlistIds ?? [] }
      : b.type === "Hero"
        ? { ...base, trackId: b.trackId ?? "" }
        : { ...base, trackIds: b.trackIds ?? [] };
  return setDoc(doc(db, "blocks", b.id), data);
}

export const deleteBlock = (id: string) => deleteDoc(doc(db, "blocks", id));

/** Rewrites `order`/`sequence` as 0..n-1 in the given order. */
export async function reorder(name: "pages" | "blocks", idsInOrder: string[]) {
  const field = name === "pages" ? "order" : "sequence";
  const batch = writeBatch(db);
  idsInOrder.forEach((id, i) => batch.update(doc(db, name, id), { [field]: i }));
  await batch.commit();
}

export function formatDuration(ms: number) {
  const s = Math.round(ms / 1000);
  return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;
}
