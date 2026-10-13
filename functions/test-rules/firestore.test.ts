import { readFileSync } from "node:fs";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { addDoc, collection, deleteDoc, doc, getDoc, getDocs, setDoc, Timestamp, updateDoc } from "firebase/firestore";
import { afterAll, beforeAll, beforeEach, describe, it } from "vitest";

let env: RulesTestEnvironment;

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-gentle-rules",
    firestore: { rules: readFileSync("../firestore.rules", "utf8") },
  });
});
afterAll(() => env.cleanup());
beforeEach(() => env.clearFirestore());

const alice = () => env.authenticatedContext("alice", { email: "alice@example.com" }).firestore();
const bob = () => env.authenticatedContext("bob").firestore();
const admin = () => env.authenticatedContext("admin", { admin: true }).firestore();
const anon = () => env.unauthenticatedContext().firestore();

/** Writes test data with rules switched off. */
const seed = (path: string, data: Record<string, unknown>) =>
  env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));

const profile = (extra: Record<string, unknown> = {}) => ({
  id: "alice",
  name: "Alice",
  email: "alice@example.com",
  createdAt: 1,
  language: "en",
  photoURL: "",
  role: "client",
  ...extra,
});

describe("users", () => {
  it("owner creates their profile as a client", async () => {
    await assertSucceeds(setDoc(doc(alice(), "users/alice"), profile()));
  });
  it("nobody makes themselves admin or writes unknown fields", async () => {
    await assertFails(setDoc(doc(alice(), "users/alice"), profile({ role: "admin" })));
    await assertFails(setDoc(doc(alice(), "users/alice"), profile({ premium: true })));
    await assertFails(setDoc(doc(alice(), "users/alice"), profile({ name: "x".repeat(101) })));
  });
  it("owner can't change their role later", async () => {
    await seed("users/alice", profile());
    await assertSucceeds(updateDoc(doc(alice(), "users/alice"), { name: "Alice B" }));
    await assertFails(updateDoc(doc(alice(), "users/alice"), { role: "admin" }));
  });
  it("only the owner and admins read a profile; only admins delete", async () => {
    await seed("users/alice", profile());
    await assertSucceeds(getDoc(doc(alice(), "users/alice")));
    await assertSucceeds(getDoc(doc(admin(), "users/alice")));
    await assertFails(getDoc(doc(bob(), "users/alice")));
    await assertFails(deleteDoc(doc(alice(), "users/alice")));
    await assertSucceeds(deleteDoc(doc(admin(), "users/alice")));
  });
  it("can't create someone else's profile", async () => {
    await assertFails(setDoc(doc(bob(), "users/alice"), profile()));
  });
});

describe("favorites", () => {
  it("are private to the owner", async () => {
    await assertSucceeds(setDoc(doc(alice(), "favorites/alice"), { ids: ["t1"] }));
    await assertSucceeds(setDoc(doc(alice(), "favorites_playlists/alice"), { ids: ["p1"] }));
    await assertFails(getDoc(doc(bob(), "favorites/alice")));
    await assertFails(setDoc(doc(bob(), "favorites_playlists/alice"), { ids: [] }));
  });
});

describe("content", () => {
  for (const name of ["tracks", "playlists", "pages", "blocks"]) {
    it(`${name}: signed-in users read, only admins write`, async () => {
      await seed(`${name}/x`, { title: "x" });
      await assertSucceeds(getDoc(doc(alice(), `${name}/x`)));
      await assertFails(getDoc(doc(anon(), `${name}/x`)));
      await assertFails(setDoc(doc(alice(), `${name}/y`), { title: "y" }));
      await assertSucceeds(setDoc(doc(admin(), `${name}/y`), { title: "y" }));
    });
  }
});

describe("track_audio", () => {
  beforeEach(() => seed("track_audio/t1", { url: "https://example.com/a.mp3" }));

  it("is readable with active premium", async () => {
    await seed("subscriptions/alice", { active: true, expiresAt: null });
    await assertSucceeds(getDoc(doc(alice(), "track_audio/t1")));
  });
  it("is readable until premium expires", async () => {
    await seed("subscriptions/alice", { active: true, expiresAt: Timestamp.fromMillis(Date.now() + 3_600_000) });
    await assertSucceeds(getDoc(doc(alice(), "track_audio/t1")));
  });
  it("is not readable after premium expired or without premium", async () => {
    await seed("subscriptions/alice", { active: true, expiresAt: Timestamp.fromMillis(Date.now() - 1000) });
    await assertFails(getDoc(doc(alice(), "track_audio/t1")));
    await assertFails(getDoc(doc(bob(), "track_audio/t1")));
  });
  it("admins read but nobody writes from a client", async () => {
    await assertSucceeds(getDoc(doc(admin(), "track_audio/t1")));
    await assertFails(setDoc(doc(admin(), "track_audio/t2"), { url: "x" }));
  });
});

describe("track_stats", () => {
  it("adds exactly one play to an existing track", async () => {
    await seed("tracks/t1", { title: "t" });
    await assertSucceeds(setDoc(doc(alice(), "track_stats/t1"), { plays: 1 }));
    await assertSucceeds(updateDoc(doc(bob(), "track_stats/t1"), { plays: 2 }));
    await assertFails(updateDoc(doc(bob(), "track_stats/t1"), { plays: 10 }));
  });
  it("refuses unknown tracks, other numbers and other fields", async () => {
    await assertFails(setDoc(doc(alice(), "track_stats/nope"), { plays: 1 }));
    await seed("tracks/t1", { title: "t" });
    await assertFails(setDoc(doc(alice(), "track_stats/t1"), { plays: 5 }));
    await assertFails(setDoc(doc(alice(), "track_stats/t1"), { plays: 1, x: 1 }));
  });
  it("only admins read", async () => {
    await seed("track_stats/t1", { plays: 3 });
    await assertFails(getDoc(doc(alice(), "track_stats/t1")));
    await assertSucceeds(getDoc(doc(admin(), "track_stats/t1")));
  });
});

describe("activity_log", () => {
  const entry = (userId: string, extra: Record<string, unknown> = {}) => ({
    id: "1",
    title: "Favorite added",
    userId,
    subtitle: null,
    activityType: "favorite",
    timestamp: 1,
    extra: "t1",
    ...extra,
  });
  it("users append their own entries", async () => {
    await assertSucceeds(addDoc(collection(alice(), "activity_log"), entry("alice")));
  });
  it("refuses entries for others, unknown fields and huge text", async () => {
    await assertFails(addDoc(collection(alice(), "activity_log"), entry("bob")));
    await assertFails(addDoc(collection(alice(), "activity_log"), entry("alice", { role: "admin" })));
    await assertFails(addDoc(collection(alice(), "activity_log"), entry("alice", { extra: "x".repeat(501) })));
  });
  it("only admins read", async () => {
    await seed("activity_log/a", entry("alice"));
    await assertFails(getDocs(collection(alice(), "activity_log")));
    await assertSucceeds(getDocs(collection(admin(), "activity_log")));
  });
});

describe("subscriptions", () => {
  it("owner and admins read; nobody writes", async () => {
    await seed("subscriptions/alice", { active: true });
    await assertSucceeds(getDoc(doc(alice(), "subscriptions/alice")));
    await assertSucceeds(getDoc(doc(admin(), "subscriptions/alice")));
    await assertFails(getDoc(doc(bob(), "subscriptions/alice")));
    await assertFails(setDoc(doc(alice(), "subscriptions/alice"), { active: true, expiresAt: null }));
    await assertFails(setDoc(doc(admin(), "subscriptions/alice"), { active: true }));
  });
});

describe("admin-only collections", () => {
  for (const name of ["access_codes", "code_batches", "push_jobs", "admin_log"]) {
    it(`${name}: admins read, nobody writes`, async () => {
      await seed(`${name}/x`, { a: 1 });
      await assertSucceeds(getDoc(doc(admin(), `${name}/x`)));
      await assertFails(getDoc(doc(alice(), `${name}/x`)));
      await assertFails(setDoc(doc(admin(), `${name}/y`), { a: 1 }));
    });
  }
});

describe("server-only collections", () => {
  for (const name of ["code_attempts", "purchase_attempts", "store_links", "deletion_codes", "apple_tokens", "admin_cache"]) {
    it(`${name}: closed to every client`, async () => {
      await seed(`${name}/alice`, { a: 1 });
      await assertFails(getDoc(doc(alice(), `${name}/alice`)));
      await assertFails(getDoc(doc(admin(), `${name}/alice`)));
      await assertFails(setDoc(doc(alice(), `${name}/alice`), { a: 2 }));
    });
  }
});
