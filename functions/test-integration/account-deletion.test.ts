import { Timestamp } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { hashCode } from "../src/deletion.js";
import {
  adminAuth,
  adminLog,
  bucket,
  clearFirestore,
  createAuthUser,
  createClient,
  data,
  db,
  expectError,
} from "./helpers.js";

beforeEach(() => clearFirestore());

/** Everything an account owns, plus one activity entry of someone else. */
async function seedAccount(uid: string, email: string) {
  await Promise.all([
    db.doc(`users/${uid}`).set({ id: uid, name: "Doomed", email, language: "en", role: "client", createdAt: 1 }),
    db.doc(`favorites/${uid}`).set({ trackIds: ["t1"] }),
    db.doc(`favorites_playlists/${uid}`).set({ playlistIds: ["p1"] }),
    db.doc(`subscriptions/${uid}`).set({ active: true, source: "manual", expiresAt: null, sources: {} }),
    db.doc(`code_attempts/${uid}`).set({ count: 1, windowStart: Timestamp.now() }),
    db.collection("activity_log").add({ userId: uid, name: "Doomed", email, action: "play" }),
    db.collection("activity_log").add({ userId: uid, name: "Doomed", email, action: "favorite" }),
    db.collection("activity_log").add({ userId: "someone-else", action: "play" }),
    bucket.file(`users/${uid}/photo.jpg`).save(Buffer.from("photo"), { contentType: "image/jpeg" }),
  ]);
}

async function expectAccountGone(uid: string) {
  for (const collection of ["users", "favorites", "favorites_playlists", "subscriptions", "code_attempts", "deletion_codes"]) {
    expect(await data(`${collection}/${uid}`), collection).toBeUndefined();
  }
  const activity = await db.collection("activity_log").get();
  expect(activity.docs.map((d) => d.data().userId)).toEqual(["someone-else"]);
  expect((await bucket.file(`users/${uid}/photo.jpg`).exists())[0]).toBe(false);
  await expect(adminAuth.getUser(uid)).rejects.toMatchObject({ code: "auth/user-not-found" });
}

describe("adminDeleteUser", () => {
  it("removes the account with everything that belongs to it", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    const { uid, email } = await createAuthUser({ name: "doomed" });
    await seedAccount(uid, email);

    await admin.call("adminDeleteUser", { uid });
    await expectAccountGone(uid);
    expect(await adminLog("deleteUser")).toMatchObject([{ adminUid: admin.uid, payload: { uid, email } }]);
  });

  it("refuses the admin's own account and other admins", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    const other = await createAuthUser({ admin: true, name: "other-admin" });

    await expectError(admin.call("adminDeleteUser", { uid: admin.uid }), "failed-precondition");
    await expectError(admin.call("adminDeleteUser", { uid: other.uid }), "failed-precondition", /admin/);
    await expectError(admin.call("adminDeleteUser", { uid: "nobody" }), "not-found");
    await adminAuth.getUser(admin.uid);
    await adminAuth.getUser(other.uid);
  });
});

describe("deleteUser (own account)", () => {
  // requestAccountDeletion emails the code, which the dummy SendGrid key can't
  // do; the stored code is seeded the way it writes it.
  async function seedCode(uid: string, code: string, opts: { expiresInMs?: number; attempts?: number } = {}) {
    await db.doc(`deletion_codes/${uid}`).set({
      codeHash: hashCode(uid, code),
      expiresAt: Timestamp.fromMillis(Date.now() + (opts.expiresInMs ?? 15 * 60_000)),
      sentAt: Timestamp.now(),
      dayStart: Timestamp.now(),
      sends: 1,
      attempts: opts.attempts ?? 0,
    });
  }

  it("deletes the account after the right code, counting wrong guesses", async () => {
    const user = await createClient({ name: "leaving" });
    await seedAccount(user.uid, user.email);
    await seedCode(user.uid, "123456");

    await expectError(user.call("deleteUser", { code: "654321" }), "failed-precondition", "wrong-code");
    expect(await data(`deletion_codes/${user.uid}`)).toMatchObject({ attempts: 1 });
    await adminAuth.getUser(user.uid);

    await user.call("deleteUser", { code: " 123456 " });
    await expectAccountGone(user.uid);
  });

  it("refuses without a code, with an expired one, or after too many guesses", async () => {
    const user = await createClient({ name: "leaving" });
    await expectError(user.call("deleteUser", { code: "123456" }), "failed-precondition", "no-code");

    await seedCode(user.uid, "123456", { expiresInMs: -1000 });
    await expectError(user.call("deleteUser", { code: "123456" }), "failed-precondition", "expired");

    await seedCode(user.uid, "123456", { attempts: 5 });
    await expectError(user.call("deleteUser", { code: "123456" }), "failed-precondition", "too-many-attempts");

    await adminAuth.getUser(user.uid);
  });
});
