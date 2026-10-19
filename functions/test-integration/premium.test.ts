import { Timestamp } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { adminLog, clearFirestore, createAuthUser, createClient, DAY, data, db, expectError, millis } from "./helpers.js";

beforeEach(() => clearFirestore());

describe("manual premium", () => {
  it("grants premium until a date and revokes it", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    const { uid } = await createAuthUser();
    const until = new Date(Date.now() + 7 * DAY);
    until.setMilliseconds(0);

    await admin.call("adminSetManualPremium", { uid, active: true, expiresAt: until.toISOString() });
    const granted = await data(`subscriptions/${uid}`);
    expect(granted).toMatchObject({ active: true, source: "manual", sources: { manual: { active: true } } });
    expect(millis(granted?.expiresAt)).toBe(until.getTime());
    expect(millis(granted?.sources.manual.expiresAt)).toBe(until.getTime());
    expect(granted?.updatedAt).toBeInstanceOf(Timestamp);

    await admin.call("adminSetManualPremium", { uid, active: false, expiresAt: null });
    expect(await data(`subscriptions/${uid}`)).toMatchObject({
      active: false,
      source: null,
      expiresAt: null,
      sources: { manual: { active: false, expiresAt: null } },
    });

    expect(await adminLog("setManualPremium")).toMatchObject([
      { adminUid: admin.uid, payload: { uid, active: true, expiresAt: until.toISOString() } },
      { adminUid: admin.uid, payload: { uid, active: false, expiresAt: null } },
    ]);
  });

  it("keeps other sources: the longest grant wins and revoking falls back to it", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    const { uid } = await createAuthUser();
    const codeEnd = Timestamp.fromMillis(Date.now() + 30 * DAY);
    await db.doc(`subscriptions/${uid}`).set({
      active: true,
      source: "code",
      expiresAt: codeEnd,
      code: "GENTLE-ABCD-EFGH",
      sources: { code: { active: true, expiresAt: codeEnd } },
    });

    // A shorter manual grant doesn't take over.
    await admin.call("adminSetManualPremium", {
      uid,
      active: true,
      expiresAt: new Date(Date.now() + 7 * DAY).toISOString(),
    });
    let sub = await data(`subscriptions/${uid}`);
    expect(sub).toMatchObject({ active: true, source: "code", code: "GENTLE-ABCD-EFGH" });
    expect(millis(sub?.expiresAt)).toBe(codeEnd.toMillis());

    // Without an end date it does.
    await admin.call("adminSetManualPremium", { uid, active: true, expiresAt: null });
    expect(await data(`subscriptions/${uid}`)).toMatchObject({ active: true, source: "manual", expiresAt: null });

    await admin.call("adminSetManualPremium", { uid, active: false, expiresAt: null });
    sub = await data(`subscriptions/${uid}`);
    expect(sub).toMatchObject({ active: true, source: "code", sources: { code: { active: true } } });
    expect(millis(sub?.expiresAt)).toBe(codeEnd.toMillis());
  });

  it("refuses unknown users and bad dates", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    await expectError(
      admin.call("adminSetManualPremium", { uid: "nobody", active: true, expiresAt: null }),
      "not-found",
    );
    const { uid } = await createAuthUser();
    await expectError(
      admin.call("adminSetManualPremium", { uid, active: true, expiresAt: "next week" }),
      "invalid-argument",
    );
    expect(await data(`subscriptions/${uid}`)).toBeUndefined();
    expect(await data("subscriptions/nobody")).toBeUndefined();
  });
});
