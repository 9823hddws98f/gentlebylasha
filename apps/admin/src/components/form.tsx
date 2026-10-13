"use client";

import { ArrowDown, ArrowUp, ImagePlus, Music, Plus, X } from "lucide-react";
import { useId, useMemo, useState } from "react";
import { audioDuration, type TxImage, uploadFile, uploadImage } from "@/lib/media";
import { Input, Label } from "./ui";

export function Field({ label, children, hint }: { label: string; children: (id: string) => React.ReactNode; hint?: string }) {
  const id = useId();
  return (
    <div>
      <Label htmlFor={id}>{label}</Label>
      {children(id)}
      {hint && <p className="mt-1.5 text-xs text-ink-faint">{hint}</p>}
    </div>
  );
}

export function Textarea(props: React.TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return (
    <textarea
      {...props}
      className="min-h-24 w-full rounded-lg border border-line-strong bg-surface px-3 py-2 text-sm text-ink placeholder:text-ink-faint transition-[border-color,box-shadow] hover:border-ink-faint focus:border-dusk focus:shadow-[0_0_0_3px_rgb(54_93_203/0.15)] focus:outline-none"
    />
  );
}

export function Switch({ checked, onChange, label }: { checked: boolean; onChange: (v: boolean) => void; label: string }) {
  return (
    <label className="flex cursor-pointer items-center justify-between gap-4 text-sm text-ink">
      {label}
      <button
        type="button"
        role="switch"
        aria-checked={checked}
        onClick={() => onChange(!checked)}
        className={`relative h-6 w-10 shrink-0 rounded-full transition-colors duration-200 ${checked ? "bg-dusk" : "bg-line-strong"}`}
      >
        <span
          className={`absolute top-0.5 left-0.5 size-5 rounded-full bg-white shadow-[0_1px_2px_rgb(0_0_0/0.2)] transition-transform duration-200 ease-out-expo ${checked ? "translate-x-4" : ""}`}
        />
      </button>
    </label>
  );
}

function Progress({ value }: { value: number }) {
  return (
    <div className="mt-2 h-1 overflow-hidden rounded-full bg-line" role="progressbar" aria-valuenow={Math.round(value * 100)}>
      <div className="h-full bg-dusk transition-[width]" style={{ width: `${value * 100}%` }} />
    </div>
  );
}

/** Pick an image; uploads it and returns a TxImage. */
export function ImageField({
  label,
  value,
  folder,
  onChange,
  onBusy,
}: {
  label: string;
  value: TxImage | null;
  folder: string;
  onChange: (v: TxImage) => void;
  onBusy?: (busy: boolean) => void;
}) {
  const id = useId();
  const [progress, setProgress] = useState<number | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function pick(file: File | undefined) {
    if (!file) return;
    setError(null);
    setProgress(0);
    onBusy?.(true);
    try {
      onChange(await uploadImage(folder, file, setProgress));
    } catch (e) {
      setError(e instanceof Error ? e.message : "Upload mislukt.");
    } finally {
      setProgress(null);
      onBusy?.(false);
    }
  }

  return (
    <div>
      <Label htmlFor={id}>{label}</Label>
      <label
        htmlFor={id}
        className="flex cursor-pointer items-center gap-4 rounded-xl border border-dashed border-line-strong p-3 transition-colors hover:border-ink-faint hover:bg-paper"
      >
        {value ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={value.url} alt="" className="size-16 rounded-lg object-cover" />
        ) : (
          <span className="grid size-16 place-items-center rounded-lg bg-paper text-ink-faint">
            <ImagePlus className="size-5" aria-hidden />
          </span>
        )}
        <span className="text-sm text-ink-soft">{value ? "Andere afbeelding kiezen" : "Afbeelding kiezen"}</span>
      </label>
      <input id={id} type="file" accept="image/*" className="sr-only" onChange={(e) => {
          pick(e.target.files?.[0]);
          e.target.value = ""; // allow picking the same file again
        }} />
      {progress !== null && <Progress value={progress} />}
      {error && <p className="mt-1.5 text-sm text-ember">{error}</p>}
    </div>
  );
}

/** Pick an audio file; uploads it and reports the URL and duration. */
export function AudioField({
  value,
  durationMs,
  folder,
  onChange,
  onBusy,
}: {
  value: string;
  durationMs: number;
  folder: string;
  onChange: (url: string, durationMs: number) => void;
  onBusy?: (busy: boolean) => void;
}) {
  const id = useId();
  const [progress, setProgress] = useState<number | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function pick(file: File | undefined) {
    if (!file) return;
    if (!file.type.startsWith("audio/")) return setError("Kies een audiobestand (mp3, m4a).");
    setError(null);
    setProgress(0);
    onBusy?.(true);
    try {
      const [duration, url] = await Promise.all([audioDuration(file), uploadFile(folder, file, setProgress)]);
      onChange(url, duration);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Upload mislukt.");
    } finally {
      setProgress(null);
      onBusy?.(false);
    }
  }

  const minutes = Math.round(durationMs / 1000);
  return (
    <div>
      <Label htmlFor={id}>Audio</Label>
      <label
        htmlFor={id}
        className="flex cursor-pointer items-center gap-4 rounded-xl border border-dashed border-line-strong p-3 transition-colors hover:border-ink-faint hover:bg-paper"
      >
        <span className="grid size-12 place-items-center rounded-lg bg-paper text-ink-faint">
          <Music className="size-5" aria-hidden />
        </span>
        <span className="text-sm text-ink-soft">
          {value || durationMs ? (
            <>
              Audio staat klaar ·{" "}
              <span className="tabular">
                {Math.floor(minutes / 60)}:{String(minutes % 60).padStart(2, "0")}
              </span>{" "}
              · vervangen
            </>
          ) : (
            "Audiobestand kiezen"
          )}
        </span>
      </label>
      <input id={id} type="file" accept="audio/*" className="sr-only" onChange={(e) => {
          pick(e.target.files?.[0]);
          e.target.value = ""; // allow picking the same file again
        }} />
      {progress !== null && <Progress value={progress} />}
      {error && <p className="mt-1.5 text-sm text-ember">{error}</p>}
    </div>
  );
}

export interface PickItem {
  id: string;
  label: string;
  sub?: string;
}

/** Most options the picker lists at once; searching narrows the rest. */
const PICKER_LIMIT = 50;

/** Ordered selection from a list: add, remove, move up/down. */
export function OrderedPicker({
  label,
  options,
  value,
  onChange,
  max,
}: {
  label: string;
  options: PickItem[];
  value: string[];
  onChange: (ids: string[]) => void;
  max?: number;
}) {
  const [q, setQ] = useState("");
  const byId = useMemo(() => new Map(options.map((o) => [o.id, o])), [options]);
  const available = options.filter(
    (o) => !value.includes(o.id) && (!q || o.label.toLowerCase().includes(q.toLowerCase())),
  );
  const full = max !== undefined && value.length >= max;

  const move = (i: number, d: -1 | 1) => {
    const next = [...value];
    [next[i], next[i + d]] = [next[i + d], next[i]];
    onChange(next);
  };

  return (
    <div>
      <p className="mb-1.5 text-[13px] font-medium text-ink-soft">{label}</p>
      {value.length > 0 ? (
        <ol className="mb-3 divide-y divide-line rounded-xl border border-line">
          {value.map((id, i) => (
            <li key={id} className="flex items-center gap-2 px-3 py-2 text-sm">
              <span className="tabular w-5 text-ink-faint">{i + 1}</span>
              <span className="min-w-0 flex-1 truncate">{byId.get(id)?.label ?? <em className="text-ember">Verwijderd</em>}</span>
              <button type="button" disabled={i === 0} onClick={() => move(i, -1)} aria-label="Omhoog" className="rounded p-1 text-ink-soft hover:bg-paper disabled:opacity-30">
                <ArrowUp className="size-4" />
              </button>
              <button type="button" disabled={i === value.length - 1} onClick={() => move(i, 1)} aria-label="Omlaag" className="rounded p-1 text-ink-soft hover:bg-paper disabled:opacity-30">
                <ArrowDown className="size-4" />
              </button>
              <button type="button" onClick={() => onChange(value.filter((v) => v !== id))} aria-label="Verwijderen" className="rounded p-1 text-ink-soft hover:bg-ember-wash hover:text-ember">
                <X className="size-4" />
              </button>
            </li>
          ))}
        </ol>
      ) : (
        <p className="mb-3 text-sm text-ink-faint">Nog niets gekozen.</p>
      )}
      {!full && (
        <>
          <Input type="search" placeholder="Zoeken om toe te voegen" value={q} onChange={(e) => setQ(e.target.value)} aria-label={`${label} zoeken`} />
          <ul className="mt-2 max-h-48 overflow-y-auto rounded-xl border border-line">
            {available.slice(0, PICKER_LIMIT).map((o) => (
              <li key={o.id}>
                <button
                  type="button"
                  onClick={() => onChange([...value, o.id])}
                  className="flex w-full items-center gap-2 px-3 py-2 text-left text-sm hover:bg-paper"
                >
                  <Plus className="size-4 text-ink-faint" aria-hidden />
                  <span className="min-w-0 flex-1 truncate">{o.label}</span>
                  {o.sub && <span className="shrink-0 text-xs text-ink-faint">{o.sub}</span>}
                </button>
              </li>
            ))}
            {available.length === 0 && <li className="px-3 py-2 text-sm text-ink-faint">Niets gevonden.</li>}
            {available.length > PICKER_LIMIT && (
              <li className="tabular border-t border-line px-3 py-2 text-xs text-ink-faint">
                Nog {available.length - PICKER_LIMIT} meer — verfijn je zoekopdracht
              </li>
            )}
          </ul>
        </>
      )}
    </div>
  );
}
