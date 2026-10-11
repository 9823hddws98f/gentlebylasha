import sgMail from "@sendgrid/mail";
import { defineSecret, defineString } from "firebase-functions/params";

export const SENDGRID_API_KEY = defineSecret("SENDGRID_API_KEY");
const MAIL_FROM = defineString("MAIL_FROM", { default: "noreply@headfolk.com" });

export async function sendMail(to: string, subject: string, html: string) {
  sgMail.setApiKey(SENDGRID_API_KEY.value());
  await sgMail.send({ to, from: MAIL_FROM.value(), subject, html });
}

export function escapeHtml(value: string): string {
  return value.replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);
}
