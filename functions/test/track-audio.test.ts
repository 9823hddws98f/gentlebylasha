import { describe, expect, it } from "vitest";
import { downloadUrl, parseDownloadUrl } from "../src/track-audio.js";

describe("download URLs", () => {
  const url =
    "https://firebasestorage.googleapis.com/v0/b/sleeptales-4bac2.appspot.com/o/track%2Faudio%2Fslaap%20zacht.mp3?alt=media&token=abc";

  it("parses bucket and decoded path", () => {
    expect(parseDownloadUrl(url)).toEqual({ bucket: "sleeptales-4bac2.appspot.com", path: "track/audio/slaap zacht.mp3" });
  });

  it("round-trips with a new token", () => {
    const { bucket, path } = parseDownloadUrl(url)!;
    expect(downloadUrl(bucket, path, "abc")).toBe(url);
  });

  it("rejects other URLs", () => {
    expect(parseDownloadUrl("https://example.com/a.mp3")).toBeNull();
  });
});
