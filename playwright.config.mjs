import { defineConfig, devices } from '@playwright/test';

const testOrigin = process.env.HADGALY_TEST_ORIGIN;
const loopbackTls = process.env.HADGALY_TEST_SELF_SIGNED === '1' &&
  new URL(testOrigin ?? 'http://127.0.0.1').origin.startsWith('https://127.0.0.1:');

export default defineConfig({
  testDir: 'test/web',
  timeout: 120_000,
  workers: 1,
  use: {
    actionTimeout: 12000,
    baseURL: testOrigin ?? 'http://127.0.0.1:4173',
    ignoreHTTPSErrors: loopbackTls,
  },
  projects: [
    { name: 'chrome', use: {
      browserName: 'chromium', channel: 'chrome', viewport: { width: 1280, height: 900 },
      launchOptions: loopbackTls ? { args: ['--ignore-certificate-errors'] } : undefined,
    } },
    { name: 'edge', use: { browserName: 'chromium', channel: 'msedge', viewport: { width: 1280, height: 900 } } },
    { name: 'android-emulated', use: { ...devices['Pixel 7'], channel: 'chrome' } },
    { name: 'iphone-emulated', use: { ...devices['iPhone 13'], browserName: 'webkit' } },
  ],
  webServer: process.env.HADGALY_TEST_ORIGIN ? undefined : {
    command: 'node tool/serve-web.mjs',
    url: 'http://127.0.0.1:4173',
    reuseExistingServer: true,
  },
});
