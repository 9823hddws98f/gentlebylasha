/**
 * Bootstraps the first admin. Run locally with credentials for the project:
 *   GOOGLE_APPLICATION_CREDENTIALS=key.json npm run set-admin -- you@example.com
 * After that, admins can add other admins from the admin webapp.
 */
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

const email = process.argv[2];
if (!email) {
  console.error("Usage: npm run set-admin -- <email>");
  process.exit(1);
}

initializeApp({ projectId: "sleeptales-4bac2" });
const user = await getAuth().getUserByEmail(email);
await getAuth().setCustomUserClaims(user.uid, { ...user.customClaims, admin: true });
console.log(`${email} is now an admin. They must sign out and in again.`);
