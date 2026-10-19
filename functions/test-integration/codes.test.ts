import { beforeEach, describe, expect, it } from "vitest";
import { adminLog, anonymous, clearFirestore, createClient, DAY, data, db, expectError, millis } from "./helpers.js";

beforeEach(() => clearFirestore());

const CODE_PATTERN = /^GENTLE-[A-HJ-NP-Z2-9]{4}-[A-HJ-NP-Z2-9]{4}$/;

/** An admin makes a batch and returns its codes. */
async function generate(admin: Awaited<ReturnType<typeof createClient>>, count: number, durationDays: number | null) {
  const { batchId, created } = await admin.call<{ batchId: string; created: number }>("adminGenerateCodes", {
    count,
    durationDays,
    batchName: "Integration",
  });
  expect(created).toBe(count);
  const snap = await db.collection("access_codes").where("batchId", "==", batchId).get();
  return { batchId, codes: snap.docs.map((d) => d.id) };
}

describe("access codes", () => {
  it("an admin generates a batch of unique, available codes", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    const { batchId, codes } = await generate(admin, 5, 30);

    expect(new Set(codes).size).toBe(5);
    for (const code of codes) {
      expect(code).toMatch(CODE_PATTERN);
      expect(await data(`access_codes/${code}`)).toMatchObject({
        code,
        batchId,
        batchName: "Integration",
        durationDays: 30,
        status: "available",
      });
    }
    expect(await data(`code_batches/${batchId}`)).toMatchObject({
      name: "Integration",
      count: 5,
      durationDays: 30,
      createdBy: admin.uid,
    });
    expect(await adminLog("generateCodes")).toMatchObject([{ adminUid: admin.uid, payload: { batchId, count: 5 } }]);
  });

  it("assigns a code to an email without note or batch, then the customer redeems it", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    const [code] = (await generate(admin, 1, 30)).codes;

    // The callable SDK sends empty optional fields as null.
    const assigned = await admin.call("adminAssignCode", {
      email: "  Customer@Example.COM ",
      code: null,
      batchId: null,
      note: null,
      sendEmail: false,
      language: "nl",
    });
    expect(assigned).toEqual({ code, emailed: false });
    expect(await data(`access_codes/${code}`)).toMatchObject({
      status: "assigned",
      assignedEmail: "customer@example.com",
      assignedNote: null,
      assignedBy: admin.uid,
    });

    // Lowercase, as people type it.
    const user = await createClient();
    const before = Date.now();
    const result = await user.call<{ success: boolean; expiresAt: string }>("redeemCode", { code: code.toLowerCase() });
    const after = Date.now();
    expect(result.success).toBe(true);
    const expiresAt = Date.parse(result.expiresAt);
    expect(expiresAt).toBeGreaterThanOrEqual(before + 30 * DAY - 1000);
    expect(expiresAt).toBeLessThanOrEqual(after + 30 * DAY + 1000);

    const sub = await data(`subscriptions/${user.uid}`);
    expect(sub).toMatchObject({ active: true, source: "code", code, sources: { code: { active: true } } });
    expect(millis(sub?.expiresAt)).toBe(expiresAt);
    expect(millis(sub?.sources.code.expiresAt)).toBe(expiresAt);
    expect(await data(`access_codes/${code}`)).toMatchObject({ status: "redeemed", redeemedBy: user.uid });

    // Redeeming the same code again changes nothing.
    const again = await user.call<{ expiresAt: string }>("redeemCode", { code });
    expect(again.expiresAt).toBe(result.expiresAt);
    const subAfter = await data(`subscriptions/${user.uid}`);
    expect(millis(subAfter?.expiresAt)).toBe(expiresAt);
    expect(millis(subAfter?.updatedAt)).toBe(millis(sub?.updatedAt));

    // Nobody else can use it.
    const other = await createClient();
    await expectError(other.call("redeemCode", { code }), "failed-precondition", "already-redeemed");
    expect(await data(`subscriptions/${other.uid}`)).toBeUndefined();
  });

  it("a code without a duration gives lifetime access", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    const [code] = (await generate(admin, 1, null)).codes;
    const user = await createClient();
    // Without dashes and the GENTLE prefix also works.
    const result = await user.call("redeemCode", { code: code.slice("GENTLE-".length).replace("-", "") });
    expect(result).toEqual({ success: true, expiresAt: null });
    expect(await data(`subscriptions/${user.uid}`)).toMatchObject({ active: true, source: "code", expiresAt: null });
  });

  it("a disabled code can't be redeemed", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    const [code] = (await generate(admin, 1, 30)).codes;
    await admin.call("adminDisableCode", { code: code.toLowerCase() });
    expect(await data(`access_codes/${code}`)).toMatchObject({ status: "disabled" });

    const user = await createClient();
    await expectError(user.call("redeemCode", { code }), "failed-precondition", "disabled");
    expect(await data(`subscriptions/${user.uid}`)).toBeUndefined();
  });

  it("a redeemed code can't be disabled or assigned", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    const [code] = (await generate(admin, 1, 30)).codes;
    const user = await createClient();
    await user.call("redeemCode", { code });

    await expectError(admin.call("adminDisableCode", { code }), "failed-precondition");
    await expectError(admin.call("adminAssignCode", { email: "a@example.com", code }), "failed-precondition");
    // No codes left to pick from.
    await expectError(admin.call("adminAssignCode", { email: "a@example.com" }), "not-found");
    expect(await data(`access_codes/${code}`)).toMatchObject({ status: "redeemed", redeemedBy: user.uid });
  });

  it("unknown and malformed codes are not found", async () => {
    const user = await createClient();
    await expectError(user.call("redeemCode", { code: "GENTLE-ZZZZ-ZZZZ" }), "failed-precondition", "not-found");
    await expectError(user.call("redeemCode", { code: "nonsense" }), "failed-precondition", "not-found");
  });

  it("stops after 10 attempts an hour, even for a valid code", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    const [code] = (await generate(admin, 1, 30)).codes;
    const user = await createClient();
    for (let i = 0; i < 10; i++) {
      await expectError(user.call("redeemCode", { code: "GENTLE-ZZZZ-ZZZZ" }), "failed-precondition", "not-found");
    }
    await expectError(user.call("redeemCode", { code }), "resource-exhausted", "too-many-attempts");
    expect(await data(`code_attempts/${user.uid}`)).toMatchObject({ count: 10 });
    expect(await data(`access_codes/${code}`)).toMatchObject({ status: "available" });

    // The limit is per account.
    const other = await createClient();
    await other.call("redeemCode", { code });
  });

  it("redeeming needs a signed-in user", async () => {
    await expectError(anonymous()("redeemCode", { code: "GENTLE-ABCD-EFGH" }), "unauthenticated");
  });
});

describe("admin callables", () => {
  const callables = [
    "adminGenerateCodes",
    "adminAssignCode",
    "adminDisableCode",
    "adminSetManualPremium",
    "adminSetAdmin",
    "adminDeleteUser",
    "adminFindUser",
    "adminUserEmails",
    "adminSendPush",
    "adminCancelPush",
    "adminStats",
    "adminDeleteTrack",
    "adminSetTrackPremium",
  ];

  it.each(callables)("%s refuses users who aren't admin", async (name) => {
    const user = await createClient();
    await expectError(user.call(name, {}), "permission-denied");
  });

  it.each(callables)("%s refuses anonymous callers", async (name) => {
    await expectError(anonymous()(name, {}), "unauthenticated");
  });

  it("a non-admin can't generate codes or give themselves premium", async () => {
    const user = await createClient();
    await expectError(user.call("adminGenerateCodes", { count: 1, durationDays: null, batchName: "x" }), "permission-denied");
    await expectError(
      user.call("adminSetManualPremium", { uid: user.uid, active: true, expiresAt: null }),
      "permission-denied",
    );
    expect((await db.collection("access_codes").get()).empty).toBe(true);
    expect(await data(`subscriptions/${user.uid}`)).toBeUndefined();
  });
});
