import { defineConfig, devices } from '@playwright/test';

/**
 * E2E tests for the Chain 138 Snap companion site.
 * Does not drive MetaMask Flask; for full install/connect flow use the manual checklist in TESTING_INSTRUCTIONS.md.
 * Run: pnpm run test:e2e
 */
export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: 1,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:8000',
    trace: 'on-first-retry',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
  webServer: {
    command: 'pnpm run start',
    url: 'http://localhost:8000',
    reuseExistingServer: !process.env.CI,
    timeout: 240_000,
  },
  timeout: 60_000,
});
