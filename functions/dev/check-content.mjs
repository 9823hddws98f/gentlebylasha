// Read-only check of the app content in Firestore (tracks, playlists, pages,
// rows) against what the app parses. Run it before launch, after importing
// old content, or whenever the app shows empty screens:
//
//   GOOGLE_APPLICATION_CREDENTIALS=key.json npm --prefix functions run check-content
//
// Against the local emulators: FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 and
// PROJECT=demo-gentle. It never writes anything.
//
// "fout" means the app can't read the document: for a page or row that empties
// the whole app, for a track or playlist that row stays empty. "waarschuwing"
// means it works but something is off.

const { initializeApp } = await import("firebase-admin/app");
const { getFirestore } = await import("firebase-admin/firestore");

const projectId = process.env.PROJECT ?? "sleeptales-4bac2";
initializeApp({ projectId });
const db = getFirestore();

const errors = [];
const warnings = [];
const fail = (where, msg) => errors.push(`${where}: ${msg}`);
const warn = (where, msg) => warnings.push(`${where}: ${msg}`);

const isString = (v) => typeof v === "string";
const isInt = (v) => typeof v === "number" && Number.isInteger(v);
const optional = (v, check) => v === undefined || v === null || check(v);
const storageUrl = (v) => isString(v) && /^https:\/\/firebasestorage\.googleapis\.com\/v0\/b\/[^/]+\/o\//.test(v);

function requireFields(where, data, fields) {
  for (const [name, check, label] of fields) {
    if (!check(data[name])) fail(where, `veld "${name}" moet ${label} zijn (is ${JSON.stringify(data[name])?.slice(0, 60) ?? "leeg"})`);
  }
}

function checkImage(where, name, image) {
  if (!image || typeof image !== "object") return fail(where, `afbeelding "${name}" ontbreekt`);
  requireFields(`${where} → ${name}`, image, [
    ["url", isString, "tekst"],
    ["blurhash", isString, "tekst"],
    ["width", isInt, "een geheel getal"],
    ["height", isInt, "een geheel getal"],
    ["dominantColor", (v) => optional(v, isInt), "leeg of een geheel getal"],
  ]);
}

const [tracks, audio, playlists, pages, blocks] = await Promise.all(
  ["tracks", "track_audio", "playlists", "pages", "blocks"].map((c) => db.collection(c).get()),
);
const trackIds = new Set(tracks.docs.map((d) => d.id));
const playlistIds = new Set(playlists.docs.map((d) => d.id));
const pageIds = new Set(pages.docs.map((d) => d.id));
const audioById = new Map(audio.docs.map((d) => [d.id, d.data()]));

// The app looks tracks and playlists up by their `id` field, not the document id.
const idMatches = (where, doc) => {
  if (doc.get("id") !== doc.id) fail(where, `veld "id" (${JSON.stringify(doc.get("id"))}) moet gelijk zijn aan het document-id`);
};

let premium = 0;
for (const doc of tracks.docs) {
  const t = doc.data();
  const where = `track ${doc.id} "${t.title ?? ""}"`;
  idMatches(where, doc);
  requireFields(where, t, [
    ["title", isString, "tekst"],
    ["writer", isString, "tekst"],
    ["speaker", isString, "tekst"],
    ["description", isString, "tekst"],
    ["trackUrl", isString, "tekst"],
    ["duration", (v) => isInt(v) && v > 0, "een positief geheel getal (ms)"],
    ["hasTimer", (v) => optional(v, (x) => typeof x === "boolean"), "leeg of waar/onwaar"],
    ["premium", (v) => optional(v, (x) => typeof x === "boolean"), "leeg of waar/onwaar"],
    ["titleNl", (v) => optional(v, isString), "leeg of tekst"],
    ["descriptionNl", (v) => optional(v, isString), "leeg of tekst"],
  ]);
  checkImage(where, "thumbnail", t.thumbnail);
  checkImage(where, "imageBackground", t.imageBackground);
  if (t.premium === true) {
    premium++;
    const url = audioById.get(doc.id)?.url;
    if (!url) fail(where, "premium, maar track_audio heeft geen audio: niemand kan hem afspelen");
    if (t.trackUrl) warn(where, "premium, maar de audio-URL staat ook in het openbare document");
  } else {
    if (!t.trackUrl) fail(where, "gratis, maar zonder audio-URL");
    else if (!storageUrl(t.trackUrl)) warn(where, "audio staat niet in Firebase Storage; premium maken lukt dan niet");
  }
}

for (const doc of playlists.docs) {
  const p = doc.data();
  const where = `playlist ${doc.id} "${p.title ?? ""}"`;
  idMatches(where, doc);
  requireFields(where, p, [
    ["title", isString, "tekst"],
    ["author", isString, "tekst"],
    ["profession", isString, "tekst"],
    ["description", isString, "tekst"],
    ["showAudioThumbnails", (v) => typeof v === "boolean", "waar/onwaar"],
    ["trackIds", (v) => optional(v, (x) => Array.isArray(x) && x.every(isString)), "een lijst met ids"],
  ]);
  checkImage(where, "thumbnail", p.thumbnail);
  checkImage(where, "authorImage", p.authorImage);
  for (const id of p.trackIds ?? []) if (!trackIds.has(id)) warn(where, `track ${id} bestaat niet meer`);
}

const orders = new Map();
for (const doc of pages.docs) {
  const p = doc.data();
  const where = `pagina ${doc.id} "${p.name ?? ""}"`;
  requireFields(where, p, [
    ["id", isString, "tekst"],
    ["name", isString, "tekst"],
    ["order", isInt, "een geheel getal"],
    ["nameNl", (v) => optional(v, isString), "leeg of tekst"],
  ]);
  if (typeof p.config?.showItemDurations !== "boolean") fail(where, 'veld "config.showItemDurations" moet waar/onwaar zijn');
  if (orders.has(p.order)) warn(where, `zelfde volgorde (${p.order}) als pagina ${orders.get(p.order)}`);
  orders.set(p.order, doc.id);
}

const TYPES = ["Normal", "Featured", "Series", "Hero"];
const rowsPerPage = new Map();
for (const doc of blocks.docs) {
  const b = doc.data();
  const where = `rij ${doc.id} "${b.title ?? ""}"`;
  requireFields(where, b, [
    ["id", isString, "tekst"],
    ["pageId", isString, "tekst"],
    ["title", isString, "tekst"],
    ["sequence", isInt, "een geheel getal"],
    ["type", (v) => TYPES.includes(v), TYPES.join("/")],
    ["titleNl", (v) => optional(v, isString), "leeg of tekst"],
  ]);
  if (isString(b.pageId)) {
    if (!pageIds.has(b.pageId)) warn(where, `pagina ${b.pageId} bestaat niet; de rij wordt nergens getoond`);
    rowsPerPage.set(b.pageId, (rowsPerPage.get(b.pageId) ?? 0) + 1);
  }
  if (b.type === "Hero") {
    if (!isString(b.trackId)) fail(where, 'een Hero-rij heeft een "trackId" nodig');
    else if (!trackIds.has(b.trackId)) warn(where, `track ${b.trackId} bestaat niet meer`);
  } else if (b.type === "Series") {
    for (const id of b.playlistIds ?? []) if (!playlistIds.has(id)) warn(where, `playlist ${id} bestaat niet meer`);
    if (!(b.playlistIds ?? []).length) warn(where, "lege rij");
  } else if (TYPES.includes(b.type)) {
    for (const id of b.trackIds ?? []) if (!trackIds.has(id)) warn(where, `track ${id} bestaat niet meer`);
    if (!(b.trackIds ?? []).length) warn(where, "lege rij");
  }
}
for (const doc of pages.docs) {
  if (!rowsPerPage.get(doc.id)) warn(`pagina ${doc.id} "${doc.get("name") ?? ""}"`, "heeft geen rijen");
}

console.log(`Project ${projectId}`);
console.log(
  `${tracks.size} tracks (${premium} premium, ${tracks.size - premium} gratis), ${playlists.size} playlists, ` +
    `${pages.size} pagina's, ${blocks.size} rijen`,
);
console.log(`\n${errors.length} fouten`);
for (const e of errors) console.log(`  ✗ ${e}`);
console.log(`\n${warnings.length} waarschuwingen`);
for (const w of warnings) console.log(`  ! ${w}`);
process.exitCode = errors.length ? 1 : 0;
