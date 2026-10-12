import { randomUUID } from "node:crypto";
import { getStorage } from "firebase-admin/storage";

/** Bucket and object path from a Firebase Storage download URL. */
export function parseDownloadUrl(url: string): { bucket: string; path: string } | null {
  const m = url.match(/^https:\/\/firebasestorage\.googleapis\.com\/v0\/b\/([^/]+)\/o\/([^?]+)/);
  return m ? { bucket: m[1], path: decodeURIComponent(m[2]) } : null;
}

export function downloadUrl(bucket: string, path: string, token: string): string {
  return `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
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
