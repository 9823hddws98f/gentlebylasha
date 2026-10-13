"use client";

import { encode } from "blurhash";
import { getDownloadURL, getStorage, ref, uploadBytesResumable } from "firebase/storage";
import { app } from "./firebase";

const storage = getStorage(app);

/** Same shape as TxImage in the Flutter app (lib/utils/tx_image.dart). */
export interface TxImage {
  url: string;
  blurhash: string;
  dominantColor: number | null;
  width: number;
  height: number;
}

export function uploadFile(folder: string, file: File, onProgress?: (fraction: number) => void): Promise<string> {
  const ext = file.name.split(".").pop()?.toLowerCase() || "bin";
  const fileRef = ref(storage, `${folder}/${crypto.randomUUID()}.${ext}`);
  const task = uploadBytesResumable(fileRef, file, { contentType: file.type || undefined });
  return new Promise((resolve, reject) => {
    task.on(
      "state_changed",
      (s) => onProgress?.(s.totalBytes ? s.bytesTransferred / s.totalBytes : 0),
      reject,
      () => getDownloadURL(fileRef).then(resolve, reject),
    );
  });
}

function loadImage(file: File): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => resolve(img);
    img.onerror = () => reject(new Error("Afbeelding kon niet worden gelezen."));
    img.src = URL.createObjectURL(file);
  });
}

/** Size, blurhash placeholder and average colour (as ARGB int, like Flutter's Color.value). */
async function describeImage(file: File) {
  const img = await loadImage(file);
  const w = 32;
  const h = Math.max(1, Math.round((img.naturalHeight / img.naturalWidth) * w));
  const canvas = document.createElement("canvas");
  canvas.width = w;
  canvas.height = h;
  const ctx = canvas.getContext("2d")!;
  ctx.drawImage(img, 0, 0, w, h);
  const { data } = ctx.getImageData(0, 0, w, h);
  let r = 0, g = 0, b = 0;
  for (let i = 0; i < data.length; i += 4) {
    r += data[i];
    g += data[i + 1];
    b += data[i + 2];
  }
  const n = data.length / 4;
  const argb = ((0xff << 24) | (Math.round(r / n) << 16) | (Math.round(g / n) << 8) | Math.round(b / n)) >>> 0;
  URL.revokeObjectURL(img.src);
  return {
    width: img.naturalWidth,
    height: img.naturalHeight,
    blurhash: encode(data, w, h, 4, 3),
    dominantColor: argb,
  };
}

export async function uploadImage(folder: string, file: File, onProgress?: (f: number) => void): Promise<TxImage> {
  if (!file.type.startsWith("image/")) throw new Error("Kies een afbeelding.");
  const [meta, url] = await Promise.all([describeImage(file), uploadFile(folder, file, onProgress)]);
  return { url, ...meta };
}

/** Duration in milliseconds, read by the browser. */
export function audioDuration(file: File): Promise<number> {
  return new Promise((resolve, reject) => {
    const audio = new Audio();
    audio.preload = "metadata";
    audio.onloadedmetadata = () => {
      URL.revokeObjectURL(audio.src);
      resolve(Math.round(audio.duration * 1000));
    };
    audio.onerror = () => reject(new Error("Audio kon niet worden gelezen."));
    audio.src = URL.createObjectURL(file);
  });
}
