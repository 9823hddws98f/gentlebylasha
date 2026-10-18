import { escapeHtml } from "./mail.js";

export type Language = "en" | "nl";

/** The user's app language as stored in users/{uid}; English when unknown. */
export const languageOf = (value: unknown): Language => (value === "nl" ? "nl" : "en");

export interface Email {
  subject: string;
  html: string;
  text: string;
}

const COLORS = { page: "#f4f2ee", card: "#ffffff", ink: "#1a2034", soft: "#5b6275", brand: "#342d6b", accent: "#52b788" };

/** One calm, plain layout for every mail: wordmark, text, optional big code or button. */
function layout(lang: Language, parts: { paragraphs: string[]; code?: string; button?: { label: string; url: string }; footer: string }) {
  const p = (t: string) => `<p style="margin:0 0 16px;font-size:16px;line-height:1.55;color:${COLORS.ink}">${t}</p>`;
  const code = parts.code
    ? `<p style="margin:8px 0 24px;font-size:26px;font-weight:600;letter-spacing:3px;color:${COLORS.brand};font-family:Menlo,Consolas,monospace">${escapeHtml(parts.code)}</p>`
    : "";
  const button = parts.button
    ? `<p style="margin:8px 0 24px"><a href="${escapeHtml(parts.button.url)}" style="display:inline-block;padding:12px 22px;border-radius:999px;background:${COLORS.accent};color:#0e1529;font-weight:600;text-decoration:none">${escapeHtml(parts.button.label)}</a></p>`
    : "";
  const html = `<!doctype html><html lang="${lang}"><body style="margin:0;padding:24px 12px;background:${COLORS.page};font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif">
<div style="max-width:480px;margin:0 auto;background:${COLORS.card};border-radius:18px;padding:32px 28px">
<p style="margin:0 0 24px;font-family:Georgia,'Times New Roman',serif;font-style:italic;font-size:28px;color:${COLORS.brand}">Gentle</p>
${parts.paragraphs.map(p).join("\n")}${code}${button}
<p style="margin:24px 0 0;font-size:13px;line-height:1.5;color:${COLORS.soft}">${parts.footer}</p>
</div></body></html>`;
  const text = [
    ...parts.paragraphs.map(stripTags),
    parts.code ?? "",
    parts.button ? `${parts.button.label}: ${parts.button.url}` : "",
    stripTags(parts.footer),
  ]
    .filter(Boolean)
    .join("\n\n");
  return { html, text };
}

const stripTags = (s: string) =>
  s
    .replace(/<[^>]+>/g, "")
    .replace(/&rarr;/g, "→")
    .replace(/&#(\d+);/g, (_, n) => String.fromCharCode(Number(n)));

export function welcomeEmail(lang: Language, rawName: string, appUrl: string): Email {
  const name = escapeHtml(rawName.trim().slice(0, 40));
  const nl = lang === "nl";
  return {
    subject: nl ? "Welkom bij Gentle" : "Welcome to Gentle",
    ...layout(lang, {
      paragraphs: nl
        ? [
            name ? `Hoi ${name},` : "Hoi,",
            "Fijn dat je er bent. Gentle is er voor het eind van de dag: leg je telefoon weg, doe je ogen dicht en luister.",
            "Begin met een slaapverhaal of een korte meditatie. Met de slaaptimer stopt het geluid vanzelf.",
          ]
        : [
            name ? `Hi ${name},` : "Hi,",
            "We're glad you're here. Gentle is made for the end of the day: put your phone away, close your eyes and listen.",
            "Start with a sleep story or a short meditation. The sleep timer stops the audio for you.",
          ],
      button: { label: nl ? "Open Gentle" : "Open Gentle", url: appUrl },
      footer: nl ? "Slaap lekker." : "Sleep well.",
    }),
  };
}

export function deletionCodeEmail(lang: Language, code: string): Email {
  const nl = lang === "nl";
  return {
    subject: nl ? "Je code om je Gentle-account te verwijderen" : "Your code to delete your Gentle account",
    ...layout(lang, {
      paragraphs: nl
        ? ["Je hebt gevraagd om je Gentle-account te verwijderen. Vul deze code in de app in om dat te bevestigen:"]
        : ["You asked to delete your Gentle account. Enter this code in the app to confirm:"],
      code,
      footer: nl
        ? "De code is 15 minuten geldig. Heb je dit niet gevraagd? Dan kun je deze mail negeren; er gebeurt niets."
        : "The code is valid for 15 minutes. Didn't ask for this? You can ignore this email; nothing will change.",
    }),
  };
}

/** "1 jaar", "3 months", "unlimited" … for an access code's duration. */
export function accessDuration(lang: Language, days: number | null): string {
  const nl = lang === "nl";
  if (days === null) return nl ? "onbeperkt" : "unlimited";
  if (days % 365 === 0) {
    const n = days / 365;
    return nl ? `${n} jaar` : `${n} year${n === 1 ? "" : "s"}`;
  }
  if (days % 30 === 0) {
    const n = days / 30;
    return nl ? `${n} ${n === 1 ? "maand" : "maanden"}` : `${n} month${n === 1 ? "" : "s"}`;
  }
  return nl ? `${days} dagen` : `${days} days`;
}

export function accessCodeEmail(lang: Language, code: string, durationDays: number | null, appUrl: string): Email {
  const nl = lang === "nl";
  const access = accessDuration(lang, durationDays);
  return {
    subject: nl ? "Je Gentle-code" : "Your Gentle code",
    ...layout(lang, {
      paragraphs: nl
        ? [
            "Bedankt voor je bestelling bij Artazest.",
            durationDays === null
              ? "Met deze code krijg je onbeperkt toegang tot alles in Gentle:"
              : `Met deze code krijg je ${access} toegang tot alles in Gentle:`,
          ]
        : [
            "Thank you for your Artazest order.",
            durationDays === null
              ? "This code gives you unlimited access to everything in Gentle:"
              : `This code gives you ${access} of access to everything in Gentle:`,
          ],
      code,
      button: { label: nl ? "Open Gentle" : "Open Gentle", url: appUrl },
      footer: nl
        ? "Download de Gentle-app of open Gentle in je browser, maak een account en vul de code in onder Profiel &rarr; Code invoeren."
        : "Download the Gentle app or open Gentle in your browser, create an account and enter the code under Profile &rarr; Redeem code.",
    }),
  };
}
