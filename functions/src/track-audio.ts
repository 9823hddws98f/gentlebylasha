import { randomUUID } from "node:crypto";
import { getStorage } from "firebase-admin/storage";

/** Where download URLs point: production, or the local Storage emulator. */
const storageOrigin = () => {
  const emulator = process.env.FIREBASE_STORAGE_EMULATOR_HOST;
  return emulator ? `http://${emulator}` : "https://firebasestorage.googleapis.com";
};

/** Bucket and object path from a Firebase Storage download URL. */
export function parseDownloadUrl(url: string): { bucket: string; path: string } | null {
  const prefix = `${storageOrigin()}/v0/b/`;
  if (!url.startsWith(prefix)) return null;
  const m = url.slice(prefix.length).match(/^([^/]+)\/o\/([^?]+)/);
  return m ? { bucket: m[1], path: decodeURIComponent(m[2]) } : null;
}

export function downloadUrl(bucket: string, path: string, token: string): string {
  return `${storageOrigin()}/v0/b/${bucket}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
}

/** Gives the file a new download token, so every earlier URL stops working. */
export async function rotateDownloadUrl(url: string): Promise<string> {
  const parsed = parseDownloadUrl(url);
  if (!parsed) throw new Error("Not a Firebase Storage download URL");
  const token = randomUUID();
  await getStorage()
    .bucket(parsed.bucket)
    .file(parsed.path)
    .setMetadata({ metadata: { firebaseStorageDownloadTokens: token } });
  return downloadUrl(parsed.bucket, parsed.path, token);
}
