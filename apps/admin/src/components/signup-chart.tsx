"use client";

import { useState } from "react";

const weekFmt = new Intl.DateTimeFormat("nl-NL", { day: "numeric", month: "short" });

/** Single-series bar chart: one hue, rounded data ends, hover tooltip, table for screen readers. */
export function SignupChart({ weeks }: { weeks: { weekStart: string; count: number }[] }) {
  const [hover, setHover] = useState<number | null>(null);
  const max = Math.max(4, ...weeks.map((w) => w.count));
  const step = Math.ceil(max / 4);
  const top = step * 4;
  const ticks = [0, step, step * 2, step * 3, top];
  const H = 180;

  return (
    <div className="relative">
      <div className="flex gap-3">
        <div className="tabular flex h-[180px] flex-col-reverse justify-between text-right text-xs text-ink-faint" aria-hidden>
          {ticks.map((t) => (
            <span key={t} className="-my-2 leading-4">
              {t}
            </span>
          ))}
        </div>
        <div className="relative flex-1">
          <div className="relative h-[180px]">
            <div className="pointer-events-none absolute inset-0 flex flex-col-reverse justify-between" aria-hidden>
              {ticks.map((t) => (
                <div key={t} className={t === 0 ? "border-t border-line-strong" : "border-t border-line"} />
              ))}
            </div>
            <div className="relative flex h-full items-end" onMouseLeave={() => setHover(null)}>
              {weeks.map((w, i) => (
                <div
                  key={w.weekStart}
                  className="flex h-full flex-1 items-end justify-center"
                  onMouseEnter={() => setHover(i)}
                  onFocus={() => setHover(i)}
                  tabIndex={0}
                  aria-label={`Week van ${weekFmt.format(new Date(w.weekStart))}: ${w.count} nieuwe gebruikers`}
                >
                  <div
                    className={`w-[62%] max-w-10 rounded-t-[4px] transition-colors ${hover === i ? "bg-dusk-ink" : "bg-dusk"}`}
                    style={{ height: `${(w.count / top) * H}px`, minHeight: w.count ? 2 : 0 }}
                  />
                </div>
              ))}
            </div>
          </div>
          {hover !== null && (
            <div
              className="pointer-events-none absolute -top-2 z-10 -translate-x-1/2 -translate-y-full rounded-lg bg-night px-2.5 py-1.5 text-xs whitespace-nowrap text-white shadow-[0_4px_12px_rgb(16_22_42/0.25)]"
              style={{ left: `${((hover + 0.5) / weeks.length) * 100}%` }}
            >
              <span className="text-night-ink">Week van {weekFmt.format(new Date(weeks[hover].weekStart))}</span>
              <span className="tabular ml-2 font-semibold">{weeks[hover].count}</span>
            </div>
          )}
          <div className="tabular mt-2 flex text-xs text-ink-faint" aria-hidden>
            {weeks.map((w, i) => (
              <span key={w.weekStart} className="flex-1 truncate text-center">
                {(weeks.length - 1 - i) % 2 === 0 ? weekFmt.format(new Date(w.weekStart)) : ""}
              </span>
            ))}
          </div>
        </div>
      </div>
      <table className="sr-only">
        <caption>Nieuwe gebruikers per week</caption>
        <tbody>
          {weeks.map((w) => (
            <tr key={w.weekStart}>
              <th>{w.weekStart}</th>
              <td>{w.count}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
