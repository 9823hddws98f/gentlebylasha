import { readFileSync } from "node:fs";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { deleteObject, getBytes, ref, uploadBytes } from "firebase/storage";
import { afterAll, beforeAll, beforeEach, describe, it } from "vitest";

let env: RulesTestEnvironment;

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-gentle-rules",
    storage: { rules: readFileSync("../storage.rules", "utf8") },
  });
});
afterAll(() => env.cleanup());
beforeEach(() => env.clearStorage());

const alice = () => env.authenticatedContext("alice").storage();
const bob = () => env.authenticatedContext("bob").storage();
const admin = () => env.authenticatedContext("admin", { admin: true }).storage();
const image = { contentType: "image/jpeg" };
const bytes = new Uint8Array([1, 2, 3]);

const seed = (path: string) =>
  env.withSecurityRulesDisabled((ctx) => uploadBytes(ref(ctx.storage(), path), bytes, image));

describe("profile photos", () => {
  it("owner uploads, reads and deletes an image", async () => {
    await assertSucceeds(uploadBytes(ref(alice(), "users/alice/images/a.jpg"), bytes, image));
    await assertSucceeds(getBytes(ref(alice(), "users/alice/images/a.jpg")));
    await assertSucceeds(deleteObject(ref(alice(), "users/alice/images/a.jpg")));
  });
  it("refuses non-images, big files and other people's folders", async () => {
    await assertFails(uploadBytes(ref(alice(), "users/alice/images/a.txt"), bytes, { contentType: "text/plain" }));
    await assertFails(uploadBytes(ref(alice(), "users/alice/images/big.jpg"), new Uint8Array(5 * 1024 * 1024), image));
    await assertFails(uploadBytes(ref(bob(), "users/alice/images/b.jpg"), bytes, image));
  });
  it("others can't read or delete them; admins can read", async () => {
    await seed("users/alice/images/a.jpg");
    await assertFails(getBytes(ref(bob(), "users/alice/images/a.jpg")));
    await assertFails(deleteObject(ref(bob(), "users/alice/images/a.jpg")));
    await assertSucceeds(getBytes(ref(admin(), "users/alice/images/a.jpg")));
  });
});

describe("content files", () => {
  it("only admins upload and read through the SDK (the app uses download URLs)", async () => {
    await assertSucceeds(uploadBytes(ref(admin(), "track/a.mp3"), bytes, { contentType: "audio/mpeg" }));
    await assertFails(uploadBytes(ref(alice(), "track/b.mp3"), bytes, { contentType: "audio/mpeg" }));
    await seed("playlist/c.jpg");
    await assertFails(getBytes(ref(alice(), "playlist/c.jpg")));
    await assertSucceeds(getBytes(ref(admin(), "playlist/c.jpg")));
  });
});
