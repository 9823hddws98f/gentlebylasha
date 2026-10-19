import { defineConfig } from "vitest/config";

// Run through `npm run test:integration`, which builds the functions and starts
// the Auth, Firestore, Storage and Functions emulators. Files share the
// emulators and clear Firestore between tests, so they run one at a time.
export default defineConfig({
  test: {
    include: ["test-integration/**/*.test.ts"],
    fileParallelism: false,
    testTimeout: 30_000,
    hookTimeout: 60_000,
  },
});
