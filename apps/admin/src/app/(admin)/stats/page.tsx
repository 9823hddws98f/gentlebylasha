"use client";

import { RefreshCw } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { SignupChart } from "@/components/signup-chart";
import { Button } from "@/components/ui";
import { errorMessage } from "@/lib/codes";
import { call } from "@/lib/firebase";

interface Stats {
  generatedAt: string;
  users: number;
  signupsPerWeek: { weekStart: string; count: number }[];
  premium: number;
  premiumBySource: Record<string, number>;
  /** Running paid subscriptions per store. Missing from functions older than this page. */
  paying?: Record<PaidSource, number>;
  /** Users who stopped paying in the last `days` days, per store that ended. */
  cancellations?: { days: number; total: number; bySource: Record<PaidSource, number> };
  codes: Record<string, number>;
  topTracks: { id: string; title: string; plays: number }[];
}

type PaidSource = "apple" | "google" | "stripe";
const PAID_SOURCES: PaidSource[] = ["apple", "google", "stripe"];

const getStats = call<{ refresh: boolean }, Stats>("adminStats");

const SOURCE: Record<string, string> = {
  apple: "App Store",
  google: "Google Play",
  stripe: "Stripe (web)",
  code: "Toegangscode",
  manual: "Handmatig",
};
const num = new Intl.NumberFormat("nl-NL");
const timeFmt = new Intl.DateTimeFormat("nl-NL", { hour: "2-digit", minute: "2-digit" });

export default function StatsPage() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback((refresh: boolean) => {
    setBusy(true);
    setError(null);
    getStats({ refresh })
      .then(setStats)
      .catch((e) => setError(errorMessage(e)))
      .finally(() => setBusy(false));
  }, []);

  useEffect(() => {
    getStats({ refresh: false })
      .then(setStats)
      .catch((e) => setError(errorMessage(e)));
  }, []);

  const signupsTotal = stats?.signupsPerWeek.reduce((a, w) => a + w.count, 0) ?? 0;

  return (
    <div className="mx-auto max-w-5xl">
      <header className="mb-8 flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="font-display text-[2rem] leading-tight font-medium tracking-[-0.02em] text-ink">Statistieken</h1>
          {stats && (
            <p className="mt-1.5 text-[15px] text-ink-soft">Bijgewerkt om {timeFmt.format(new Date(stats.generatedAt))}.</p>
          )}
        </div>
        <Button onClick={() => load(true)} busy={busy} icon={<RefreshCw className="size-4" aria-hidden />}>
          Vernieuwen
        </Button>
      </header>

      {error && <p className="mb-4 text-sm text-ember">{error}</p>}

      {!stats ? (
        <div className="h-80 animate-pulse rounded-2xl border border-line bg-surface" aria-busy="true" />
      ) : (
        <div className="space-y-6">
          <dl className="flex flex-wrap gap-x-10 gap-y-4 rounded-2xl border border-line bg-surface px-6 py-5">
            {[
              ["Gebruikers", stats.users],
              ["Premium nu", stats.premium],
              ...(stats.cancellations
                ? [[`Opzeggingen (${stats.cancellations.days} dagen)`, stats.cancellations.total] as const]
                : []),
              ["Codes ingewisseld", stats.codes.redeemed ?? 0],
              ["Codes nog vrij", stats.codes.available ?? 0],
            ].map(([label, value]) => (
              <div key={label}>
                <dt className="text-[13px] text-ink-faint">{label}</dt>
                <dd className="tabular text-2xl font-semibold text-ink">{num.format(Number(value))}</dd>
              </div>
            ))}
          </dl>

          <section className="rounded-2xl border border-line bg-surface p-5 sm:p-6">
            <h2 className="text-[15px] font-semibold text-ink">Nieuwe gebruikers per week</h2>
            <p className="mb-4 text-sm text-ink-faint">
              <span className="tabular">{num.format(signupsTotal)}</span> in de laatste {stats.signupsPerWeek.length} weken
            </p>
            <SignupChart weeks={stats.signupsPerWeek} />
          </section>

          <div className="grid gap-6 md:grid-cols-2">
            <div className="space-y-6">
              <section className="rounded-2xl border border-line bg-surface p-5 sm:p-6">
                <h2 className="mb-3 text-[15px] font-semibold text-ink">Premium via</h2>
                {stats.premium === 0 ? (
                  <p className="text-sm text-ink-faint">Nog niemand heeft premium.</p>
                ) : (
                  <table className="w-full text-sm">
                    <tbody>
                      {Object.entries(stats.premiumBySource)
                        .sort((a, b) => b[1] - a[1])
                        .map(([source, n]) => (
                          <tr key={source} className="border-b border-line last:border-0">
                            <td className="py-2 text-ink">{SOURCE[source] ?? source}</td>
                            <td className="tabular py-2 text-right text-ink">{num.format(n)}</td>
                          </tr>
                        ))}
                    </tbody>
                  </table>
                )}
              </section>

              {stats.paying && stats.cancellations && (
                <section className="rounded-2xl border border-line bg-surface p-5 sm:p-6">
                  <h2 className="text-[15px] font-semibold text-ink">Betaalde abonnementen</h2>
                  <p className="mb-3 text-sm text-ink-faint">
                    Opgezegd: gestopt in de laatste {stats.cancellations.days} dagen, zonder ander betaald abonnement.
                  </p>
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="border-b border-line text-[13px] text-ink-faint">
                        <th scope="col" className="py-2 text-left font-medium">Via</th>
                        <th scope="col" className="py-2 text-right font-medium">Betalend</th>
                        <th scope="col" className="py-2 pl-4 text-right font-medium">Opgezegd</th>
                      </tr>
                    </thead>
                    <tbody>
                      {PAID_SOURCES.map((source) => {
                        const paying = stats.paying?.[source] ?? 0;
                        const cancelled = stats.cancellations?.bySource[source] ?? 0;
                        return (
                          <tr key={source} className="border-b border-line last:border-0">
                            <td className="py-2 text-ink">{SOURCE[source]}</td>
                            <td className={`tabular py-2 text-right ${paying ? "text-ink" : "text-ink-faint"}`}>
                              {num.format(paying)}
                            </td>
                            <td className={`tabular py-2 pl-4 text-right ${cancelled ? "text-ink" : "text-ink-faint"}`}>
                              {num.format(cancelled)}
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </section>
              )}
            </div>

            <section className="rounded-2xl border border-line bg-surface p-5 sm:p-6">
              <h2 className="mb-3 text-[15px] font-semibold text-ink">Meest beluisterd</h2>
              {stats.topTracks.length === 0 ? (
                <p className="text-sm text-ink-faint">Nog geen afspeelgegevens.</p>
              ) : (
                <table className="w-full text-sm">
                  <thead className="sr-only">
                    <tr>
                      <th>Track</th>
                      <th>Keer afgespeeld</th>
                    </tr>
                  </thead>
                  <tbody>
                    {stats.topTracks.map((t, i) => (
                      <tr key={t.id} className="border-b border-line last:border-0">
                        <td className="tabular w-6 py-2 pr-3 text-ink-faint">{i + 1}</td>
                        <td className="w-full max-w-0 truncate py-2 text-ink">{t.title}</td>
                        <td className="tabular py-2 pl-3 text-right text-ink">{num.format(t.plays)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </section>
          </div>
        </div>
      )}
    </div>
  );
}
