import { defineConfig } from "vitest/config";

// Run through `npm run test:rules`, which starts the Firestore and Storage emulators.
export default defineConfig({
  test: { include: ["test-rules/**/*.test.ts"], fileParallelism: false, testTimeout: 20_000, hookTimeout: 60_000 },
});
