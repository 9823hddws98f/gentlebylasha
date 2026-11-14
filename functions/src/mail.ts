import sgMail from "@sendgrid/mail";
import { logger } from "firebase-functions";
import { defineSecret, defineString } from "firebase-functions/params";

export const SENDGRID_API_KEY = defineSecret("SENDGRID_API_KEY");
// Empty by default: a forgotten value must not send mail from another domain.
const MAIL_FROM = defineString("MAIL_FROM", { default: "" });

export async function sendMail(to: string, mail: { subject: string; html: string; text: string }) {
  // Local runs have no SendGrid key; log the mail so codes in it can still be used.
  if (process.env.FUNCTIONS_EMULATOR === "true") {
    logger.info("Mail not sent on the emulator", { to, subject: mail.subject, text: mail.text });
    return;
  }
  const from = MAIL_FROM.value();
  if (!from) throw new Error("MAIL_FROM is not set (functions/.env.<project>)");
  sgMail.setApiKey(SENDGRID_API_KEY.value());
  await sgMail.send({ to, from: { email: from, name: "Gentle" }, ...mail });
}

export function escapeHtml(value: string): string {
  return value.replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);
}
