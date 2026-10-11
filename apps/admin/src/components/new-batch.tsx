"use client";

import { Plus, X } from "lucide-react";
import { useRef, useState } from "react";
import { durationLabel, errorMessage, generateCodes } from "@/lib/codes";
import { Button, Input, Label, Select } from "./ui";

const DURATIONS: (number | null)[] = [30, 90, 180, 365, 730, null];

/** Side sheet for creating a batch of codes. */
export function NewBatch({ onCreated }: { onCreated: (batchId: string, created: number) => void }) {
  const dialog = useRef<HTMLDialogElement>(null);
  const [name, setName] = useState("");
  const [count, setCount] = useState(100);
  const [duration, setDuration] = useState("365");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function open() {
    setError(null);
    dialog.current?.showModal();
  }

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const res = await generateCodes({
        batchName: name.trim(),
        count,
        durationDays: duration === "unlimited" ? null : Number(duration),
      });
      dialog.current?.close();
      setName("");
      onCreated(res.batchId, res.created);
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  }

  return (
    <>
      <Button variant="secondary" onClick={open} icon={<Plus className="size-4" aria-hidden />}>
        Nieuwe batch
      </Button>

      <dialog
        ref={dialog}
        aria-labelledby="batch-heading"
        className="m-0 ml-auto h-dvh max-h-none w-full max-w-md bg-surface p-0 text-ink shadow-[-24px_0_60px_-24px_rgb(16_22_42/0.35)] backdrop:bg-night/40 open:animate-[sheet_380ms_var(--ease-out-expo)]"
        onClick={(e) => e.target === dialog.current && dialog.current.close()}
      >
        <form onSubmit={submit} className="flex h-full flex-col">
          <header className="flex items-start justify-between border-b border-line px-6 py-5">
            <div>
              <h2 id="batch-heading" className="font-display text-xl font-medium">
                Nieuwe batch codes
              </h2>
              <p className="mt-1 text-sm text-ink-soft">Elke code is uniek en werkt één keer.</p>
            </div>
            <Button
              type="button"
              variant="ghost"
              aria-label="Sluiten"
              className="-mr-2 px-2"
              onClick={() => dialog.current?.close()}
              icon={<X className="size-4" aria-hidden />}
            />
          </header>

          <div className="flex-1 space-y-5 overflow-y-auto px-6 py-6">
            <div>
              <Label htmlFor="batch-name">Naam</Label>
              <Input
                id="batch-name"
                required
                maxLength={100}
                placeholder="Artazest najaar 2026"
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
            </div>
            <div>
              <Label htmlFor="batch-count">Aantal codes</Label>
              <Input
                id="batch-count"
                type="number"
                className="tabular"
                min={1}
                max={1000}
                required
                value={count}
                onChange={(e) => setCount(Number(e.target.value))}
              />
              <p className="mt-1.5 text-xs text-ink-faint">Maximaal 1000 per keer.</p>
            </div>
            <div>
              <Label htmlFor="batch-duration">Toegang na inwisselen</Label>
              <Select id="batch-duration" value={duration} onChange={(e) => setDuration(e.target.value)}>
                {DURATIONS.map((d) => (
                  <option key={d ?? "unlimited"} value={d ?? "unlimited"}>
                    {durationLabel(d)}
                  </option>
                ))}
              </Select>
            </div>
            {error && <p className="text-sm text-ember">{error}</p>}
          </div>

          <footer className="flex justify-end gap-2 border-t border-line px-6 py-4">
            <Button type="button" variant="ghost" onClick={() => dialog.current?.close()}>
              Annuleren
            </Button>
            <Button type="submit" variant="primary" busy={busy}>
              {count} codes aanmaken
            </Button>
          </footer>
        </form>
      </dialog>
    </>
  );
}
