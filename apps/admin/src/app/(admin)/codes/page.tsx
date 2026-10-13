"use client";

import { Download, Search } from "lucide-react";
import { useDeferredValue, useMemo, useState } from "react";
import { CodesTable } from "@/components/codes-table";
import { IssueCode } from "@/components/issue-code";
import { NewBatch } from "@/components/new-batch";
import { Input, Select } from "@/components/ui";
import { type CodeStatus, STATUS_LABEL, toCsv } from "@/lib/codes";
import { useBatches, useCodes, useCounts } from "@/lib/use-codes";

const FILTERS: (CodeStatus | "all")[] = ["all", "available", "assigned", "redeemed", "disabled"];

export default function CodesPage() {
  const [status, setStatus] = useState<CodeStatus | "all">("all");
  const [batchId, setBatchId] = useState("");
  const [search, setSearch] = useState("");
  const deferredSearch = useDeferredValue(search.trim().toLowerCase());
  const [notice, setNotice] = useState<string | null>(null);

  const { batches, error: batchesError } = useBatches();
  const { codes, error, truncated } = useCodes(status, batchId);
  const { counts, refresh } = useCounts(batchId);

  const visible = useMemo(() => {
    if (!codes) return null;
    if (!deferredSearch) return codes;
    const compact = deferredSearch.replace(/[^a-z0-9]/g, "");
    return codes.filter(
      (c) =>
        c.assignedEmail?.includes(deferredSearch) ||
        c.assignedNote?.toLowerCase().includes(deferredSearch) ||
        (compact && c.code.toLowerCase().replace(/-/g, "").includes(compact)),
    );
  }, [codes, deferredSearch]);

  const total = counts ? Object.values(counts).reduce((a, b) => a + b, 0) : null;

  function exportCsv() {
    if (!visible) return;
    const blob = new Blob(["﻿" + toCsv(visible)], { type: "text/csv;charset=utf-8" });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    const batch = batches.find((b) => b.id === batchId)?.name ?? "alle";
    a.download = `gentle-codes-${batch.replace(/\W+/g, "-").toLowerCase()}-${status}.csv`;
    a.click();
    URL.revokeObjectURL(a.href);
  }

  return (
    <div className="mx-auto max-w-6xl">
      <header className="mb-8 flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="font-display text-[2rem] leading-tight font-medium tracking-[-0.02em] text-ink">
            Toegangscodes
          </h1>
          <p className="mt-1.5 max-w-prose text-[15px] text-ink-soft">
            Artazest-klanten wisselen deze codes in de app in voor premium toegang.
          </p>
        </div>
        <NewBatch
          onCreated={(id, created) => {
            setBatchId(id);
            setStatus("all");
            setNotice(`${created} codes aangemaakt.`);
            refresh();
          }}
        />
      </header>

      <IssueCode batches={batches} onIssued={refresh} />

      <section aria-label="Alle codes" className="mt-10">
        <div className="mb-4 flex flex-wrap items-center gap-3">
          <div role="tablist" aria-label="Filter op status" className="flex flex-wrap gap-1 rounded-xl bg-line/50 p-1">
            {FILTERS.map((f) => {
              const n = f === "all" ? total : counts?.[f];
              const active = status === f;
              return (
                <button
                  key={f}
                  role="tab"
                  aria-selected={active}
                  onClick={() => setStatus(f)}
                  className={`flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-sm transition-[background-color,color,box-shadow] duration-150 ${
                    active ? "bg-surface text-ink shadow-[0_1px_2px_rgb(20_26_46/0.12)]" : "text-ink-soft hover:text-ink"
                  }`}
                >
                  {f === "all" ? "Alle" : STATUS_LABEL[f]}
                  <span className="tabular text-xs text-ink-faint">{n ?? "·"}</span>
                </button>
              );
            })}
          </div>

          <Select
            aria-label="Filter op batch"
            value={batchId}
            onChange={(e) => setBatchId(e.target.value)}
            className="w-auto min-w-44"
          >
            <option value="">Alle batches</option>
            {batches.map((b) => (
              <option key={b.id} value={b.id}>
                {b.name} ({b.count})
              </option>
            ))}
          </Select>

          <div className="relative min-w-56 flex-1">
            <Search className="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-ink-faint" aria-hidden />
            <Input
              type="search"
              aria-label="Zoek op code, e-mail of notitie"
              placeholder="Zoek op code, e-mail of notitie"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-9"
            />
          </div>

          <span className="inline-flex items-center gap-1">
            <button
              onClick={exportCsv}
              disabled={!visible?.length}
              aria-describedby={truncated ? "csv-scope" : undefined}
              className="inline-flex h-9 items-center gap-2 rounded-lg px-3 text-sm text-ink-soft hover:bg-surface hover:text-ink disabled:opacity-40"
            >
              <Download className="size-4" aria-hidden /> CSV
            </button>
            {truncated && visible && (
              <span id="csv-scope" className="tabular text-xs text-ink-faint">
                exporteert de {visible.length} geladen codes
              </span>
            )}
          </span>
        </div>

        <div aria-live="polite" className="text-sm">
          {notice && <p className="mb-3 text-leaf-ink">{notice}</p>}
          {error && <p className="mb-3 text-ember">{error}</p>}
          {batchesError && <p className="mb-3 text-ember">{batchesError}</p>}
        </div>

        {visible === null ? (
          <div className="h-64 animate-pulse rounded-2xl border border-line bg-surface" aria-busy="true" />
        ) : visible.length === 0 ? (
          <div className="rounded-2xl border border-dashed border-line-strong px-6 py-14 text-center">
            <p className="font-medium text-ink">
              {deferredSearch ? "Niets gevonden" : batches.length ? "Geen codes met deze filter" : "Nog geen codes"}
            </p>
            <p className="mt-1 text-sm text-ink-soft">
              {deferredSearch
                ? "Probeer een ander deel van de code of het e-mailadres."
                : batches.length
                  ? "Kies een andere status of batch."
                  : "Maak eerst een batch aan met de knop rechtsboven."}
            </p>
          </div>
        ) : (
          <>
            <CodesTable codes={visible} onChanged={refresh} />
            {truncated && (
              <p className="mt-3 text-xs text-ink-faint">
                De nieuwste 500 codes worden getoond. Filter op batch of status om verder te zoeken.
              </p>
            )}
          </>
        )}
      </section>
    </div>
  );
}
