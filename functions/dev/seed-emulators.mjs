// Fills the local emulators (project demo-gentle) with test data shaped the way
// the admin writes it: two tracks (one premium), a home page with one row, an
// unused access code and an admin account. Run while `npm run emulators` runs:
//   npm run seed
// Never point this at a real project: it refuses anything but demo-gentle.
import { randomUUID } from "node:crypto";
import { fileURLToPath } from "node:url";

process.env.FIREBASE_AUTH_EMULATOR_HOST ??= "127.0.0.1:9099";
process.env.FIRESTORE_EMULATOR_HOST ??= "127.0.0.1:8080";
process.env.FIREBASE_STORAGE_EMULATOR_HOST ??= "127.0.0.1:9199";

const { initializeApp } = await import("firebase-admin/app");
const { getAuth } = await import("firebase-admin/auth");
const { FieldValue, getFirestore } = await import("firebase-admin/firestore");
const { getStorage } = await import("firebase-admin/storage");

const projectId = "demo-gentle";
const bucketName = `${projectId}.appspot.com`;
initializeApp({ projectId, storageBucket: bucketName });
const db = getFirestore();
const bucket = getStorage().bucket();
const fixture = (name) => fileURLToPath(new URL(`./fixtures/${name}`, import.meta.url));

async function upload(file, path, contentType) {
  const token = randomUUID();
  await bucket.upload(fixture(file), {
    destination: path,
    metadata: { contentType, metadata: { firebaseStorageDownloadTokens: token } },
  });
  const host = process.env.FIREBASE_STORAGE_EMULATOR_HOST;
  return `http://${host}/v0/b/${bucketName}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
}

const image = async (file) => ({
  url: await upload(file, `track/images/${randomUUID()}.jpg`, "image/jpeg"),
  blurhash: "LEHV6nWB2yk8pyo0adR*.7kCMdnj",
  dominantColor: 0xff342d6b,
  width: 600,
  height: 600,
});

const audio = await upload("tone.mp3", "track/audio/tone.mp3", "audio/mpeg");
const track = { writer: "Gentle", speaker: "Gentle", hasTimer: true, duration: 8000 };

await db.doc("tracks/t-free").set({
  ...track,
  id: "t-free",
  title: "Evening breeze",
  titleNl: "Avondbries",
  description: "A free track",
  descriptionNl: "Een gratis track",
  trackUrl: audio,
  premium: false,
  thumbnail: await image("thumbnail.jpg"),
  imageBackground: await image("background.jpg"),
});
await db.doc("tracks/t-premium").set({
  ...track,
  id: "t-premium",
  title: "Deep sleep story",
  titleNl: "Diep slaapverhaal",
  description: "A premium track",
  trackUrl: "",
  premium: true,
  thumbnail: await image("thumbnail.jpg"),
  imageBackground: await image("background.jpg"),
});
await db.doc("track_audio/t-premium").set({ url: audio });
await db.doc("pages/home").set({ id: "home", name: "Home", nameNl: "Thuis", order: 0, config: { showItemDurations: true } });
await db.doc("blocks/tonight").set({
  id: "tonight",
  pageId: "home",
  title: "Tonight",
  titleNl: "Vanavond",
  type: "Normal",
  sequence: 0,
  trackIds: ["t-free", "t-premium"],
});

await db.doc("code_batches/dev").set({ name: "Dev", count: 1, durationDays: 365, createdAt: FieldValue.serverTimestamp() });
await db.doc("access_codes/GENTLE-ABCD-EFGH").set({
  code: "GENTLE-ABCD-EFGH",
  batchId: "dev",
  batchName: "Dev",
  durationDays: 365,
  status: "available",
  createdAt: FieldValue.serverTimestamp(),
});

const email = "admin@gentle.test";
const admin = await getAuth()
  .getUserByEmail(email)
  .catch(() => getAuth().createUser({ email, password: "admin-password", displayName: "Admin" }));
await getAuth().setCustomUserClaims(admin.uid, { admin: true });

console.log(`Seeded ${projectId}: admin ${email} / admin-password, code GENTLE-ABCD-EFGH.`);
