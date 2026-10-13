import { describe, expect, it } from "vitest";
import type { SourceGrant } from "../src/entitlement.js";
import { cancellations, payingBySource, weeklyBuckets } from "../src/stats.js";

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

describe("subscriptions", () => {
  const now = new Date("2026-10-14T10:00:00Z");
  const running: SourceGrant = { active: true, expiresAt: new Date("2026-11-14T10:00:00Z") };
  const ended: SourceGrant = { active: false, expiresAt: null };
  // Still marked active, but the expiry has passed (no notification came in).
  const lapsed: SourceGrant = { active: true, expiresAt: new Date("2026-10-01T00:00:00Z") };
  const forever: SourceGrant = { active: true, expiresAt: null };

  it("counts running paid subscriptions per store, ignoring codes and manual premium", () => {
    expect(
      payingBySource(
        [
          { apple: running },
          { apple: running, stripe: running },
          { google: lapsed },
          { stripe: ended, code: forever },
          { manual: forever },
        ],
        now,
      ),
    ).toEqual({ apple: 2, google: 0, stripe: 1 });
  });

  it("counts users who stopped paying, per store that ended", () => {
    expect(
      cancellations(
        [
          { apple: ended },
          { google: lapsed },
          { stripe: ended, apple: ended },
          // still has premium from a code, but stopped paying
          { stripe: ended, code: forever },
        ],
        now,
      ),
    ).toEqual({ total: 4, bySource: { apple: 2, google: 1, stripe: 2 } });
  });

  it("does not count someone who still pays, or never paid", () => {
    expect(
      cancellations(
        [
          // moved from the App Store to the web
          { apple: ended, stripe: running },
          { apple: running },
          { code: ended },
          {},
        ],
        now,
      ),
    ).toEqual({ total: 0, bySource: { apple: 0, google: 0, stripe: 0 } });
  });
});
