import { describe, expect, it } from "vitest";
import { accessCodeEmail, accessDuration, deletionCodeEmail, languageOf, welcomeEmail } from "../src/emails.js";

describe("languageOf", () => {
  it("is Dutch only for nl, English otherwise", () => {
    expect(languageOf("nl")).toBe("nl");
    expect(languageOf("en")).toBe("en");
    expect(languageOf(undefined)).toBe("en");
    expect(languageOf("de")).toBe("en");
  });
});

describe("welcomeEmail", () => {
  it("greets in the user's language and escapes the name", () => {
    const nl = welcomeEmail("nl", "<b>Eva</b>", "https://app.example");
    expect(nl.subject).toBe("Welkom bij Gentle");
    expect(nl.html).toContain("Hoi &#60;b&#62;Eva&#60;/b&#62;,");
    expect(nl.html).not.toContain("<b>Eva");
    expect(nl.text).toContain("Hoi <b>Eva</b>,");
    expect(nl.html).toContain('href="https://app.example"');
    expect(welcomeEmail("en", "", "https://app.example").text).toMatch(/^Hi,/);
  });
  it("caps very long names", () => {
    expect(welcomeEmail("en", "x".repeat(500), "https://a").text).not.toContain("x".repeat(41));
  });
});

describe("deletionCodeEmail", () => {
  it("shows the code and the 15 minute limit in both languages", () => {
    const en = deletionCodeEmail("en", "123456");
    expect(en.html).toContain("123456");
    expect(en.text).toContain("15 minutes");
    expect(deletionCodeEmail("nl", "123456").text).toContain("15 minuten");
  });
});

describe("accessCodeEmail", () => {
  it("names the duration naturally", () => {
    expect(accessDuration("nl", 365)).toBe("1 jaar");
    expect(accessDuration("en", 730)).toBe("2 years");
    expect(accessDuration("nl", 90)).toBe("3 maanden");
    expect(accessDuration("en", 30)).toBe("1 month");
    expect(accessDuration("en", 10)).toBe("10 days");
    expect(accessDuration("nl", null)).toBe("onbeperkt");
  });
  it("contains the code, the duration and where to enter it", () => {
    const nl = accessCodeEmail("nl", "GENTLE-ABCD-EFGH", 365, "https://app.example");
    expect(nl.html).toContain("GENTLE-ABCD-EFGH");
    expect(nl.text).toContain("1 jaar toegang");
    expect(nl.text).toContain("Profiel → Code invoeren");
    expect(accessCodeEmail("en", "GENTLE-ABCD-EFGH", null, "https://a").text).toContain("unlimited access");
  });
});
