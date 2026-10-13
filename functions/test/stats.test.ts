import { describe, expect, it } from "vitest";
import { weeklyBuckets } from "../src/stats.js";

describe("weeklyBuckets", () => {
  // Monday 12 Oct 2026
  const now = new Date("2026-10-14T10:00:00Z");

  it("returns the last N weeks starting on Monday, oldest first", () => {
    const b = weeklyBuckets([], now, 3);
    expect(b.map((x) => x.weekStart)).toEqual(["2026-09-28", "2026-10-05", "2026-10-12"]);
    expect(b.every((x) => x.count === 0)).toBe(true);
  });

  it("counts sign-ups into their week and ignores older ones", () => {
    const b = weeklyBuckets(
      [
        new Date("2026-10-12T00:30:00Z").getTime(),
        new Date("2026-10-13T09:00:00Z").getTime(),
        new Date("2026-10-06T09:00:00Z").getTime(),
        new Date("2026-01-01T00:00:00Z").getTime(),
      ],
      now,
      2,
    );
    expect(b).toEqual([
      { weekStart: "2026-10-05", count: 1 },
      { weekStart: "2026-10-12", count: 2 },
    ]);
  });
});
