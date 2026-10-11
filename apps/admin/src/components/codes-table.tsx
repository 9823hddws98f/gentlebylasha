"use client";

import { Ban, Check, Copy } from "lucide-react";
import { useState } from "react";
import { type AccessCode, type CodeStatus, disableCode, durationLabel, errorMessage, STATUS_LABEL } from "@/lib/codes";

const statusStyle: Record<CodeStatus, string> = {
  available: "bg-paper text-ink-soft ring-line-strong",
  assigned: "bg-dusk-wash text-dusk-ink ring-dusk/25",
  redeemed: "bg-leaf-wash text-leaf-ink ring-leaf/30",
  disabled: "bg-ember-wash text-ember ring-ember/20",
};

const dateFmt = new Intl.DateTimeFormat("nl-NL", { day: "numeric", month: "short", year: "numeric" });

function StatusPill({ status }: { status: CodeStatus }) {
  return (
    <span className={`inline-flex rounded-full px-2 py-0.5 text-xs font-medium ring-1 ring-inset ${statusStyle[status]}`}>
      {STATUS_LABEL[status]}
    </span>
  );
}

export function CodesTable({ codes, onChanged }: { codes: AccessCode[]; onChanged: () => void }) {
  const [copied, setCopied] = useState<string | null>(null);
  const [busy, setBusy] = useState<string | null>(null);

  async function copy(code: string) {
    await navigator.clipboard.writeText(code);
    setCopied(code);
    setTimeout(() => setCopied((c) => (c === code ? null : c)), 1500);
  }

  async function disable(code: string) {
    if (!confirm(`Code ${code} uitschakelen? Hij kan daarna niet meer worden ingewisseld.`)) return;
    setBusy(code);
    try {
      await disableCode({ code });
      onChanged();
    } catch (e) {
      alert(errorMessage(e));
    } finally {
      setBusy(null);
    }
  }

  return (
    <div className="overflow-x-auto rounded-2xl border border-line bg-surface">
      <table className="w-full min-w-[760px] text-left text-sm">
        <thead>
          <tr className="border-b border-line text-[13px] text-ink-faint">
            <th scope="col" className="py-3 pr-4 pl-5 font-medium">Code</th>
            <th scope="col" className="px-4 py-3 font-medium">Status</th>
            <th scope="col" className="px-4 py-3 font-medium">Klant</th>
            <th scope="col" className="px-4 py-3 font-medium">Batch</th>
            <th scope="col" className="px-4 py-3 font-medium">Datum</th>
            <th scope="col" className="py-3 pr-5 pl-4"><span className="sr-only">Acties</span></th>
          </tr>
        </thead>
        <tbody>
          {codes.map((c) => {
            const when = c.redeemedAt ?? c.assignedAt ?? c.createdAt;
            const whenLabel = c.redeemedAt ? "ingewisseld" : c.assignedAt ? "uitgegeven" : "aangemaakt";
            const canDisable = c.status === "available" || c.status === "assigned";
            return (
              <tr key={c.code} className="group border-b border-line last:border-0 hover:bg-paper/60">
                <td className="py-2.5 pr-4 pl-5 font-mono text-[13px] tracking-wide whitespace-nowrap text-ink">
                  {c.code}
                </td>
                <td className="px-4 py-2.5">
                  <StatusPill status={c.status} />
                </td>
                <td className="max-w-[260px] px-4 py-2.5">
                  {c.assignedEmail ? (
                    <>
                      <div className="truncate text-ink" title={c.assignedEmail}>{c.assignedEmail}</div>
                      {c.assignedNote && <div className="truncate text-xs text-ink-faint" title={c.assignedNote}>{c.assignedNote}</div>}
                    </>
                  ) : (
                    <span className="text-ink-faint">—</span>
                  )}
                </td>
                <td className="px-4 py-2.5 whitespace-nowrap">
                  <div className="text-ink-soft">{c.batchName ?? c.batchId}</div>
                  <div className="text-xs text-ink-faint">{durationLabel(c.durationDays)}</div>
                </td>
                <td className="tabular px-4 py-2.5 whitespace-nowrap text-ink-soft">
                  {when ? (
                    <>
                      {dateFmt.format(when)}
                      <div className="text-xs text-ink-faint">{whenLabel}</div>
                    </>
                  ) : (
                    "—"
                  )}
                </td>
                <td className="py-2.5 pr-5 pl-4">
                  <div className="flex justify-end gap-1 opacity-70 transition-opacity group-hover:opacity-100 focus-within:opacity-100">
                    <button
                      onClick={() => copy(c.code)}
                      className="rounded-md p-1.5 text-ink-soft hover:bg-paper hover:text-ink"
                      aria-label={`Kopieer ${c.code}`}
                      title="Kopiëren"
                    >
                      {copied === c.code ? <Check className="size-4 text-leaf-ink" /> : <Copy className="size-4" />}
                    </button>
                    {canDisable && (
                      <button
                        onClick={() => disable(c.code)}
                        disabled={busy === c.code}
                        className="rounded-md p-1.5 text-ink-soft hover:bg-ember-wash hover:text-ember disabled:opacity-40"
                        aria-label={`Schakel ${c.code} uit`}
                        title="Uitschakelen"
                      >
                        <Ban className="size-4" />
                      </button>
                    )}
                  </div>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
