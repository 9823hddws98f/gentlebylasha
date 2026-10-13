import { describe, expect, it } from "vitest";
import { pushConditions, topicsFor } from "../src/push.js";

describe("pushConditions", () => {
  it("sends one message per language to everyone", () => {
    expect(pushConditions("all")).toEqual([
      { language: "en", condition: "'lang_en' in topics" },
      { language: "nl", condition: "'lang_nl' in topics" },
    ]);
  });

  it("narrows to premium or free users", () => {
    expect(pushConditions("premium")[1]).toEqual({
      language: "nl",
      condition: "'lang_nl' in topics && 'premium' in topics",
    });
    expect(pushConditions("free")[0].condition).toBe("'lang_en' in topics && 'free' in topics");
  });
});

describe("topicsFor", () => {
  it("subscribes to language and premium state", () => {
    expect(topicsFor("nl", true)).toEqual({ subscribe: ["lang_nl", "premium"], unsubscribe: ["lang_en", "free"] });
    expect(topicsFor("en", false)).toEqual({ subscribe: ["lang_en", "free"], unsubscribe: ["lang_nl", "premium"] });
  });
});
