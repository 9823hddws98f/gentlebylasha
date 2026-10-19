import { beforeEach, describe, expect, it } from "vitest";
import { adminLog, clearFirestore, createClient, data, db, expectError } from "./helpers.js";

beforeEach(() => clearFirestore());

async function seedTrack(id: string) {
  await Promise.all([
    db.doc(`tracks/${id}`).set({ id, title: "Evening breeze", premium: true, trackUrl: "" }),
    db.doc(`track_audio/${id}`).set({ url: "https://example.com/audio.mp3" }),
    db.doc(`track_stats/${id}`).set({ plays: 3 }),
  ]);
}

describe("adminDeleteTrack", () => {
  it("refuses while a playlist or page row uses the track", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    await seedTrack("t1");
    await db.doc("playlists/p1").set({ title: "Calm nights", trackIds: ["t0", "t1"] });

    await expectError(admin.call("adminDeleteTrack", { trackId: "t1" }), "failed-precondition", /Calm nights/);
    expect(await data("tracks/t1")).toBeDefined();
    expect(await data("track_audio/t1")).toBeDefined();

    await db.doc("playlists/p1").delete();
    await db.doc("blocks/hero").set({ title: "Tonight", type: "Hero", trackId: "t1" });
    await expectError(admin.call("adminDeleteTrack", { trackId: "t1" }), "failed-precondition", /Tonight/);

    await db.doc("blocks/hero").delete();
    await db.doc("blocks/row").set({ title: "Popular", trackIds: ["t1"] });
    await expectError(admin.call("adminDeleteTrack", { trackId: "t1" }), "failed-precondition", /Popular/);

    expect(await data("tracks/t1")).toBeDefined();
    expect(await adminLog("deleteTrack")).toEqual([]);
  });

  it("deletes an unused track with its audio and play count", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    await seedTrack("t1");
    await seedTrack("t2");
    await db.doc("playlists/p1").set({ title: "Calm nights", trackIds: ["t2"] });

    await admin.call("adminDeleteTrack", { trackId: "t1" });
    expect(await data("tracks/t1")).toBeUndefined();
    expect(await data("track_audio/t1")).toBeUndefined();
    expect(await data("track_stats/t1")).toBeUndefined();
    expect(await data("tracks/t2")).toBeDefined();
    expect(await adminLog("deleteTrack")).toMatchObject([{ adminUid: admin.uid, payload: { trackId: "t1" } }]);
  });
});
