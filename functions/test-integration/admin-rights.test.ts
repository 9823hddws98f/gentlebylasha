import { getIdToken, getIdTokenResult } from "firebase/auth";
import { beforeEach, describe, expect, it } from "vitest";
import { adminAuth, adminLog, clearFirestore, createClient, expectError, signIn } from "./helpers.js";

beforeEach(() => clearFirestore());

describe("admin rights", () => {
  it("grants and revokes; a demoted admin's older token no longer works", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    const other = await createClient({ name: "other" });
    await expectError(other.call("adminFindUser", { query: admin.uid }), "permission-denied");

    await admin.call("adminSetAdmin", { uid: other.uid, admin: true });
    expect((await adminAuth.getUser(other.uid)).customClaims).toEqual({ admin: true });

    // The claim reaches the user with their next token.
    await getIdToken(other.user, true);
    const found = await other.call<{ user: { uid: string; admin: boolean } }>("adminFindUser", { query: admin.email });
    expect(found.user).toMatchObject({ uid: admin.uid, admin: true });

    await admin.call("adminSetAdmin", { uid: other.uid, admin: false });
    expect((await adminAuth.getUser(other.uid)).customClaims).toEqual({ admin: false });

    // Their cached token still says admin, but the server checks the account.
    expect((await getIdTokenResult(other.user)).claims.admin).toBe(true);
    await expectError(other.call("adminFindUser", { query: admin.email }), "permission-denied");
    await expectError(other.call("adminSetAdmin", { uid: other.uid, admin: true }), "permission-denied");
    expect((await adminAuth.getUser(other.uid)).customClaims).toEqual({ admin: false });

    // (adminSetAdmin also revokes their refresh tokens, but the Auth emulator
    // doesn't enforce that, so it isn't checked here.)

    // Signing in again gives a token without the claim.
    const again = await signIn(other.email);
    expect((await getIdTokenResult(again.user)).claims.admin).toBe(false);
    await expectError(again.call("adminFindUser", { query: admin.email }), "permission-denied");

    expect(await adminLog("setAdmin")).toMatchObject([
      { adminUid: admin.uid, payload: { uid: other.uid, email: other.email, admin: true } },
      { adminUid: admin.uid, payload: { uid: other.uid, email: other.email, admin: false } },
    ]);
  });

  it("an admin can't take their own rights away", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    await expectError(admin.call("adminSetAdmin", { uid: admin.uid, admin: false }), "failed-precondition");
    expect((await adminAuth.getUser(admin.uid)).customClaims).toEqual({ admin: true });
  });

  it("keeps other claims and refuses unknown users", async () => {
    const admin = await createClient({ admin: true, name: "admin" });
    const other = await createClient();
    await adminAuth.setCustomUserClaims(other.uid, { beta: true });
    await admin.call("adminSetAdmin", { uid: other.uid, admin: true });
    expect((await adminAuth.getUser(other.uid)).customClaims).toEqual({ beta: true, admin: true });
    await expectError(admin.call("adminSetAdmin", { uid: "nobody", admin: true }), "not-found");
  });
});
