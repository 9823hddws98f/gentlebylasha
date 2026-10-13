"use client";

import { collection, limit, onSnapshot, orderBy, query, Timestamp } from "firebase/firestore";
import { Send } from "lucide-react";
import { useEffect, useState } from "react";
import { Field, Textarea } from "@/components/form";
import { Button, Input, Select } from "@/components/ui";
import { errorMessage } from "@/lib/codes";
import { call, db } from "@/lib/firebase";

type Audience = "all" | "premium" | "free";
type Lang = "en" | "nl";

interface Job {
  id: string;
  title: Record<Lang, string>;
  audience: Audience;
  status: "scheduled" | "sending" | "sent" | "partial" | "failed" | "cancelled";
  sendAt?: Date;
}

const sendPush = call<
  { title: Record<Lang, string>; body: Record<Lang, string>; audience: Audience; sendAt: string | null },
  { id: string; scheduled: boolean }
>("adminSendPush");
const cancelPush = call<{ id: string }, { success: boolean }>("adminCancelPush");

const AUDIENCE: Record<Audience, string> = { all: "Iedereen", premium: "Premium", free: "Gratis gebruikers" };
const STATUS: Record<Job["status"], string> = {
  scheduled: "Gepland",
  sending: "Bezig",
  sent: "Verstuurd",
  partial: "Deels verstuurd",
  failed: "Mislukt",
  cancelled: "Geannuleerd",
};
const dateFmt = new Intl.DateTimeFormat("nl-NL", { day: "numeric", month: "short", hour: "2-digit", minute: "2-digit" });

export default function PushPage() {
  const [jobs, setJobs] = useState<Job[] | null>(null);
  const [title, setTitle] = useState<Record<Lang, string>>({ nl: "", en: "" });
  const [body, setBody] = useState<Record<Lang, string>>({ nl: "", en: "" });
  const [audience, setAudience] = useState<Audience>("all");
  const [when, setWhen] = useState("");
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<{ ok: boolean; text: string } | null>(null);

  useEffect(
    () =>
      onSnapshot(
        query(collection(db, "push_jobs"), orderBy("createdAt", "desc"), limit(30)),
        (snap) =>
          setJobs(
            snap.docs.map((d) => {
              const v = d.data();
              return {
                id: d.id,
                title: v.title,
                audience: v.audience,
                status: v.status,
                sendAt: v.sendAt instanceof Timestamp ? v.sendAt.toDate() : undefined,
              };
            }),
          ),
        () => setJobs([]),
      ),
    [],
  );

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    if (when && !confirm("Bericht inplannen?")) return;
    if (!when && !confirm(`Nu versturen naar ${AUDIENCE[audience].toLowerCase()}?`)) return;
    setBusy(true);
    setMessage(null);
    try {
      const res = await sendPush({ title, body, audience, sendAt: when ? new Date(when).toISOString() : null });
      setMessage({ ok: true, text: res.scheduled ? "Ingepland." : "Verstuurd." });
      setTitle({ nl: "", en: "" });
      setBody({ nl: "", en: "" });
      setWhen("");
    } catch (err) {
      setMessage({ ok: false, text: errorMessage(err) });
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="mx-auto max-w-4xl">
      <header className="mb-8">
        <h1 className="font-display text-[2rem] leading-tight font-medium tracking-[-0.02em] text-ink">Pushberichten</h1>
        <p className="mt-1.5 max-w-prose text-[15px] text-ink-soft">
          Gebruikers krijgen het bericht in de taal van hun app. Alleen voor de iOS- en Android-app.
        </p>
      </header>

      <form onSubmit={submit} className="space-y-5 rounded-2xl border border-line bg-surface p-5 sm:p-6">
        <div className="grid gap-5 md:grid-cols-2">
          {(["nl", "en"] as const).map((lang) => (
            <fieldset key={lang} className="space-y-4">
              <legend className="mb-1 text-sm font-semibold text-ink">{lang === "nl" ? "Nederlands" : "Engels"}</legend>
              <Field label="Titel">
                {(id) => (
                  <Input id={id} required maxLength={200} value={title[lang]} onChange={(e) => setTitle({ ...title, [lang]: e.target.value })} />
                )}
              </Field>
              <Field label="Tekst">
                {(id) => (
                  <Textarea id={id} required maxLength={500} value={body[lang]} onChange={(e) => setBody({ ...body, [lang]: e.target.value })} />
                )}
              </Field>
            </fieldset>
          ))}
        </div>
        <div className="flex flex-wrap items-end gap-4">
          <Field label="Naar">
            {(id) => (
              <Select id={id} value={audience} onChange={(e) => setAudience(e.target.value as Audience)} className="w-48">
                {(Object.keys(AUDIENCE) as Audience[]).map((a) => (
                  <option key={a} value={a}>
                    {AUDIENCE[a]}
                  </option>
                ))}
              </Select>
            )}
          </Field>
          <Field label="Wanneer (leeg = nu)">
            {(id) => <Input id={id} type="datetime-local" value={when} onChange={(e) => setWhen(e.target.value)} className="w-56" />}
          </Field>
          <Button type="submit" variant="primary" busy={busy} icon={<Send className="size-4" aria-hidden />} className="ml-auto">
            {when ? "Inplannen" : "Nu versturen"}
          </Button>
        </div>
        <div aria-live="polite">
          {message && <p className={`text-sm ${message.ok ? "text-leaf-ink" : "text-ember"}`}>{message.text}</p>}
        </div>
      </form>

      <h2 className="mt-10 mb-3 text-[15px] font-semibold text-ink">Eerder</h2>
      {jobs === null ? (
        <div className="h-32 animate-pulse rounded-2xl border border-line bg-surface" aria-busy="true" />
      ) : jobs.length === 0 ? (
        <p className="text-sm text-ink-faint">Nog geen berichten verstuurd.</p>
      ) : (
        <ul className="divide-y divide-line overflow-hidden rounded-2xl border border-line bg-surface">
          {jobs.map((j) => (
            <li key={j.id} className="flex flex-wrap items-center gap-x-4 gap-y-1 px-4 py-3 text-sm">
              <span className="min-w-0 flex-1 truncate font-medium text-ink">{j.title?.nl}</span>
              <span className="text-ink-faint">{AUDIENCE[j.audience]}</span>
              <span className="tabular text-ink-faint">{j.sendAt ? dateFmt.format(j.sendAt) : ""}</span>
              <span className={j.status === "failed" || j.status === "partial" ? "text-ember" : j.status === "sent" ? "text-leaf-ink" : "text-ink-soft"}>
                {STATUS[j.status]}
              </span>
              {j.status === "scheduled" && (
                <Button variant="danger" className="h-8" onClick={() => cancelPush({ id: j.id }).catch((e) => alert(errorMessage(e)))}>
                  Annuleren
                </Button>
              )}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
