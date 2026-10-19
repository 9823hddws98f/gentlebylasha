import { beforeEach, describe, expect, it } from "vitest";
import { adminLog, clearFirestore, createClient, DAY, data, expectError, millis } from "./helpers.js";

beforeEach(() => clearFirestore());

const message = (sendAt: string | null) => ({
  title: { en: "Hello", nl: "Hallo" },
  body: { en: "A new story", nl: "Een nieuw verhaal" },
  audience: "premium",
  sendAt,
});

describe("push messages", () => {
  it("refuses a time in the past", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    const past = new Date(Date.now() - 60 * 60_000).toISOString();
    await expectError(admin.call("adminSendPush", message(past)), "invalid-argument", /verleden/);
    expect(await adminLog("sendPush")).toEqual([]);
  });

  it("refuses empty or missing texts", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    await expectError(
      admin.call("adminSendPush", { ...message(null), title: { en: "Hello", nl: "  " } }),
      "invalid-argument",
    );
    await expectError(admin.call("adminSendPush", { ...message(null), audience: "everyone" }), "invalid-argument");
  });

  it("schedules a push for later and cancels it", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    const sendAt = new Date(Date.now() + DAY);
    const result = await admin.call<{ id: string; scheduled: boolean }>("adminSendPush", message(sendAt.toISOString()));
    expect(result.scheduled).toBe(true);

    const job = await data(`push_jobs/${result.id}`);
    expect(job).toMatchObject({
      status: "scheduled",
      audience: "premium",
      title: { en: "Hello", nl: "Hallo" },
      createdBy: admin.uid,
    });
    expect(millis(job?.sendAt)).toBe(sendAt.getTime());
    expect(job?.sentAt).toBeUndefined();
    expect(await adminLog("sendPush")).toMatchObject([
      { adminUid: admin.uid, payload: { job: result.id, scheduled: true, failed: [] } },
    ]);

    await admin.call("adminCancelPush", { id: result.id });
    expect(await data(`push_jobs/${result.id}`)).toMatchObject({ status: "cancelled" });
    expect(await adminLog("cancelPush")).toMatchObject([{ adminUid: admin.uid, payload: { job: result.id } }]);

    // Only a scheduled push can be cancelled.
    await expectError(admin.call("adminCancelPush", { id: result.id }), "failed-precondition");
    await expectError(admin.call("adminCancelPush", { id: "missing" }), "failed-precondition");
  });

  // There is no FCM emulator, so sending now fails in both languages; the job
  // and the admin log must say so instead of claiming it went out. (Without
  // credentials, as in CI, the Admin SDK first waits for the metadata server.)
  it("records a failed send", { timeout: 60_000 }, async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    await expectError(admin.call("adminSendPush", message(null)), "internal", "Versturen mislukt.");

    const [entry] = await adminLog("sendPush");
    expect(entry).toMatchObject({ adminUid: admin.uid, payload: { scheduled: false, failed: ["en", "nl"] } });
    expect(await data(`push_jobs/${entry.payload.job}`)).toMatchObject({ status: "failed" });
  });
});
