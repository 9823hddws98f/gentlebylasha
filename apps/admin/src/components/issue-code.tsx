"use client";

import { Check, Copy, Send } from "lucide-react";
import { useState } from "react";
import { assignCode, type Batch, errorMessage } from "@/lib/codes";
import { Button, Input, Label, Select } from "./ui";

/** The everyday task: give the next free code to an Artazest customer. */
export function IssueCode({ batches, onIssued }: { batches: Batch[]; onIssued: () => void }) {
  const [email, setEmail] = useState("");
  const [note, setNote] = useState("");
  const [batchId, setBatchId] = useState("");
  const [sendEmail, setSendEmail] = useState(true);
  const [language, setLanguage] = useState<"nl" | "en">("nl");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [issued, setIssued] = useState<{ code: string; email: string; emailed: boolean; mailFailed: boolean } | null>(null);
  const [copied, setCopied] = useState<"idle" | "copied" | "failed">("idle");

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const { code, emailed } = await assignCode({
        email,
        note: note || undefined,
        batchId: batchId || undefined,
        sendEmail,
        language,
      });
      setIssued({ code, email, emailed, mailFailed: sendEmail && !emailed });
      setCopied("idle");
      setEmail("");
      setNote("");
      onIssued();
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  }

  async function copy() {
    if (!issued) return;
    try {
      await navigator.clipboard.writeText(issued.code);
      setCopied("copied");
    } catch {
      setCopied("failed"); // no clipboard permission; the code can still be selected by hand
    }
  }

  return (
    <section aria-labelledby="issue-heading" className="rounded-2xl border border-line bg-surface p-5 sm:p-6">
      <h2 id="issue-heading" className="text-[15px] font-semibold text-ink">
        Code uitgeven aan klant
      </h2>
      <p className="mt-1 text-sm text-ink-soft">Neemt de eerstvolgende vrije code en koppelt die aan het e-mailadres.</p>

      <form onSubmit={submit} className="mt-5 grid gap-4 lg:grid-cols-[minmax(0,1.4fr)_minmax(0,1fr)_minmax(0,0.9fr)_auto] lg:items-end">
        <div>
          <Label htmlFor="issue-email">E-mail klant</Label>
          <Input
            id="issue-email"
            type="email"
            required
            placeholder="naam@voorbeeld.nl"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>
        <div>
          <Label htmlFor="issue-note">Notitie (bijv. ordernummer)</Label>
          <Input id="issue-note" value={note} maxLength={500} onChange={(e) => setNote(e.target.value)} />
        </div>
        <div>
          <Label htmlFor="issue-batch">Uit batch</Label>
          <Select id="issue-batch" value={batchId} onChange={(e) => setBatchId(e.target.value)}>
            <option value="">Willekeurige batch</option>
            {batches.map((b) => (
              <option key={b.id} value={b.id}>
                {b.name}
              </option>
            ))}
          </Select>
        </div>
        <Button type="submit" variant="primary" busy={busy} icon={<Send className="size-4" aria-hidden />}>
          Uitgeven
        </Button>

        <div className="flex flex-wrap items-center gap-x-5 gap-y-2 text-sm text-ink-soft lg:col-span-4">
          <label className="inline-flex cursor-pointer items-center gap-2">
            <input
              type="checkbox"
              checked={sendEmail}
              onChange={(e) => setSendEmail(e.target.checked)}
              className="size-4 accent-[var(--dusk)]"
            />
            Code mailen naar klant
          </label>
          {sendEmail && (
            <label className="inline-flex items-center gap-2 whitespace-nowrap">
              Taal van de mail
              <Select
                value={language}
                onChange={(e) => setLanguage(e.target.value as "nl" | "en")}
                className="h-8 w-auto"
                aria-label="Taal van de mail"
              >
                <option value="nl">Nederlands</option>
                <option value="en">Engels</option>
              </Select>
            </label>
          )}
        </div>
      </form>

      <div aria-live="polite">
        {error && <p className="mt-4 text-sm text-ember">{error}</p>}
        {issued && (
          <div className="mt-5 flex flex-wrap items-center gap-x-4 gap-y-3 rounded-xl bg-leaf-wash px-4 py-3 animate-[issued_420ms_var(--ease-out-expo)]">
            <span className="font-mono text-lg font-medium tracking-wider text-ink select-all">{issued.code}</span>
            <span className="text-sm text-leaf-ink">
              {issued.emailed ? "Gemaild naar" : "Gekoppeld aan"} {issued.email}
            </span>
            {issued.mailFailed && (
              <span className="basis-full text-sm text-ember order-last">
                De mail kon niet worden verstuurd. Kopieer de code en stuur hem zelf.
              </span>
            )}
            <Button
              variant="ghost"
              onClick={copy}
              className="ml-auto"
              icon={copied === "copied" ? <Check className="size-4" aria-hidden /> : <Copy className="size-4" aria-hidden />}
            >
              {copied === "copied" ? "Gekopieerd" : "Kopiëren"}
            </Button>
            {copied === "failed" && (
              <span className="basis-full text-sm text-ember order-last">
                Kopiëren mislukt. Selecteer de code en kopieer hem zelf.
              </span>
            )}
          </div>
        )}
      </div>
    </section>
  );
}
