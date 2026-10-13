import { defineConfig } from "vitest/config";

// Unit tests only; the security rules tests need the emulators (npm run test:rules).
export default defineConfig({ test: { include: ["test/**/*.test.ts"] } });
