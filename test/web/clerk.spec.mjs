import { expect, test } from '@playwright/test';

async function readOrigin(request) {
  const response = await request.get('/auth/config.js');
  const script = await response.text();
  return JSON.parse(script.slice(script.indexOf('=') + 1).trim().slice(0, -1)).origin;
}

test('Clerk account page stays separate from the finance shell and works offline', async ({ page, context, request }) => {
  const origin = await readOrigin(request);
  const clerkRequests = [];
  page.on('request', (request) => {
    if (origin && request.url().startsWith(origin + '/')) clerkRequests.push(request.url());
  });
  await page.goto('/');
  await expect(page.getByRole('heading', { name: /Сайн уу/ })).toBeVisible();
  await page.waitForFunction(() => navigator.serviceWorker.controller !== null);
  expect(clerkRequests).toHaveLength(0);
  await page.getByRole('button', { name: 'Тохиргоо', exact: true }).click();

  const settingsLink = page.getByRole('button', { name: 'Clerk бүртгэл' });
  if (!origin) {
    await expect(settingsLink).toHaveCount(0);
    await page.goto('/auth/index.html');
    await expect(page.getByRole('status')).toHaveText(/тохируулаагүй/);
    return;
  }
  await context.setOffline(true);
  await settingsLink.click();
  await expect(page.getByRole('status')).toHaveText(/холбогдож чадсангүй/);
  expect(clerkRequests).toHaveLength(0);
  await page.getByRole('link', { name: 'Хадгалъя руу буцах' }).click();
  await expect(page.getByRole('heading', { name: /Сайн уу/ })).toBeVisible();
});

test.describe('mocked provider session', () => {
  test.use({ serviceWorkers: 'block' });
  test('sign-in and sign-out update the account status', async ({ page, context, request }) => {
    const origin = await readOrigin(request);
    test.skip(!origin, 'Build with the Clerk Development key to test the account controls');
    await context.route(origin + '/npm/**', async (route) => {
      const isSdk = route.request().url().includes('clerk.browser.js');
      await route.fulfill({
        headers: { 'access-control-allow-origin': '*' },
        contentType: 'text/javascript',
        body: isSdk ? `
          window.Clerk = {
            isSignedIn: false,
            async load(options) {
              if (options.signInForceRedirectUrl !== location.origin + '/auth/index.html') {
                throw new Error('Unexpected return URL');
              }
            },
            addListener(listener) { this.listener = listener; },
            async redirectToSignIn() {
              this.isSignedIn = true;
              this.listener();
            },
            async signOut() {
              this.isSignedIn = false;
            },
          };` : 'window.__internal_ClerkUICtor = function() {};',
      });
    });
    await page.goto('/auth/index.html');
    await expect(page.getByRole('status')).toHaveText('Нэвтрээгүй байна.');
    await expect(page.getByRole('button', { name: 'Бүртгүүлэх' })).toBeVisible();
    await page.getByRole('button', { name: 'Нэвтрэх' }).click();
    await expect(page.getByRole('status')).toHaveText('Нэвтэрсэн байна.');
    await page.getByRole('button', { name: 'Гарах' }).click();
    await expect(page.getByRole('status')).toHaveText('Нэвтрээгүй байна.');
  });
});

test('selected Clerk development portal opens for sign-in and sign-up', async ({ page, request }, info) => {
  test.skip(process.env.HADGALY_CLERK_LIVE_CHECK !== '1' || info.project.name !== 'chrome',
    'Opt-in check of the real portal without creating a user');
  const origin = await readOrigin(request);
  expect(origin).toMatch(/^https:\/\/[a-z0-9-]+\.clerk\.accounts\.dev$/);
  for (const [label, path] of [['Нэвтрэх', 'sign-in'], ['Бүртгүүлэх', 'sign-up']]) {
    await page.goto('/auth/index.html');
    await page.getByRole('button', { name: label, exact: true }).click({ timeout: 30_000 });
    await page.waitForURL((url) => url.hostname.endsWith('.accounts.dev') &&
      url.pathname.startsWith('/' + path), { timeout: 30_000 });
    await expect(page.getByRole('textbox').first()).toBeVisible({ timeout: 30_000 });
  }
});
