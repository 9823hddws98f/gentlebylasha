import { setGlobalOptions } from "firebase-functions/v2";

// Imported first by index.ts: functions take these options when their module
// is evaluated, so this must run before purchases.ts and push.ts are loaded.
setGlobalOptions({ region: "us-central1", maxInstances: 10 });
