import { chromium, expect, test } from '@playwright/test';
import { spawn } from 'node:child_process';
import { createHash } from 'node:crypto';
import { cp, readFile, writeFile } from 'node:fs/promises';
import { DatabaseSync } from 'node:sqlite';

const button = (page, name) => page.getByRole('button', { name, exact: true });
const balance = (page, text) => page.getByText('Бүх дансны одоогийн нийт үлдэгдэл: ' + text + ' ₮', { exact: true });
const text = (page, value) => page.locator('flt-semantics').getByText(value, { exact: true });

async function open(page, route = '/') {
  await page.goto(route);
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
}

async function fill(page, label, value) {
  const field = page.getByRole('textbox', { name: new RegExp('^' + label) });
  await field.click();
  // The browser focuses the semantics input before Flutter binds its editor.
  const frames = () => page.evaluate(() => new Promise((resolve) =>
    requestAnimationFrame(() => requestAnimationFrame(resolve))));
  await frames();
  await field.fill(value);
  await frames();
  await expect(field).toHaveValue(value);
}

async function onboard(page, { keyboard = false } = {}) {
  await expect(button(page, 'Болсон')).toBeVisible({ timeout: 30_000 });
  await fill(page, 'Дуудах нэр', 'Туршилт');
  await button(page, 'Болсон').click();
  await button(page, 'Эхэлцгээе').click();
  await fill(page, 'Дансны нэр', 'Бэлэн');
  await fill(page, 'Эхний үлдэгдэл', '1000');
  if (keyboard) {
    await page.getByRole('textbox', { name: /^Эхний үлдэгдэл/ }).press('Enter');
  } else {
    await button(page, 'Дансаа үүсгэх').click();
  }
  await button(page, 'Нүүр рүү орох').click();
  await expect(balance(page, '1,000')).toBeVisible();
}

async function post(page, kind, amount, category) {
  await button(page, kind + ' нэмэх').click();
  await fill(page, 'Мөнгөн дүн', amount);
  await button(page, category).click();
  await button(page, 'Хадгалах').click();
}

async function settings(page) {
  await button(page, 'Цэс нээх').click();
  await button(page, 'Тохиргоо').click();
}

async function upload(page, bytes) {
  const chosen = page.waitForEvent('filechooser');
  await button(page, 'Нөөцөөс сэргээх').click();
  await (await chosen).setFiles({
    name: 'Synthetic.hadgaly',
    mimeType: 'application/octet-stream',
    buffer: bytes,
  });
}

async function exportFile(page, previous = false) {
  const downloading = page.waitForEvent('download');
  await button(page, previous ? 'Өмнөх өгөгдлийн нөөцийг татах' : 'Өгөгдөл нөөцлөх').click();
  const download = await downloading;
  expect(download.suggestedFilename()).toBe(previous ? 'Hadgaly-previous.hadgaly' : 'Hadgaly.hadgaly');
  const bytes = await readFile(await download.path());
  expect(bytes.subarray(0, 8).toString('ascii')).toBe('HADGALY1');
  expect(bytes.subarray(8, 40)).toEqual(createHash('sha256').update(bytes.subarray(40)).digest());
  return bytes;
}

test('offline shell, exact ledger, second-tab guard, export and confirmed restore', async ({ page, context }, info) => {
  const unexpected = [];
  page.on('pageerror', (error) => unexpected.push(error.message));
  page.on('request', (request) => {
    if (!request.url().startsWith(info.project.use.baseURL) &&
        !request.url().startsWith('blob:')) unexpected.push('External request: ' + request.url());
  });
  await open(page);
  await onboard(page);
  await post(page, 'Орлого', '230', 'Цалин');
  await expect(balance(page, '1,230')).toBeVisible();
  await post(page, 'Зарлага', '55', 'Хоол');
  await expect(balance(page, '1,175')).toBeVisible();
  await expect(page.getByRole('img', {
    name: /зарлагын ангиллын хуваарилалт.*−55 ₮/,
  })).toBeVisible();

  if (info.project.name === 'android-emulated') await page.screenshot({ path: info.outputPath('home.png') });
  await button(page, 'Цэс нээх').click();
  await expect(button(page, 'Санхүү')).toBeVisible();
  if (info.project.name === 'android-emulated') await page.screenshot({ path: info.outputPath('drawer.png') });
  await button(page, 'Цэс хаах').click();
  await button(page, 'Санхүүгийн тайлан').click();
  await expect(page.getByRole('heading', { name: 'Санхүүгийн тайлан' })).toBeVisible();
  await expect(text(page, 'Цэвэр: +175 ₮')).toBeVisible();
  await expect(text(page, 'Хоол')).toBeVisible();
  await expect(text(page, '55 ₮ · 100.0%')).toBeVisible();
  if (info.project.name === 'android-emulated') await page.screenshot({ path: info.outputPath('report.png') });
  await button(page, 'Буцах').click();

  await page.waitForFunction(() => navigator.serviceWorker.controller !== null);
  const manifest = await page.evaluate(async () => (await fetch('/manifest.json')).json());
  expect(manifest.display).toBe('standalone');
  expect(manifest.icons.map((icon) => icon.sizes)).toEqual(['192x192', '512x512']);
  const cached = await page.evaluate(async () => {
    const keys = await caches.keys();
    const shell = await caches.open(keys.find((key) => key.startsWith('hadgaly-shell-')));
    return (await shell.keys()).map((key) => new URL(key.url).pathname);
  });
  expect(cached).toEqual(expect.arrayContaining(['/index.html', '/main.dart.js', '/sqlite3.wasm', '/drift_worker.js']));

  const second = await context.newPage();
  await open(second);
  await expect(text(second, 'Хадгалъя өөр таб эсвэл цонхонд нээлттэй байна. Түүнийг хаагаад энэ хуудсыг дахин ачаална уу.')).toBeVisible();
  await second.close();

  await context.setOffline(true);
  await open(page, '/offline-reopen');
  await expect(balance(page, '1,175')).toBeVisible({ timeout: 30_000 });
  await post(page, 'Орлого', '25', 'Цалин');
  await expect(balance(page, '1,200')).toBeVisible();
  await context.setOffline(false);
  await open(page);
  await expect(balance(page, '1,200')).toBeVisible();

  await settings(page);
  if (info.project.name === 'android-emulated') await page.screenshot({ path: info.outputPath('settings.png') });
  const backup = await exportFile(page);
  const sqlitePath = info.outputPath('synthetic.sqlite');
  await writeFile(sqlitePath, backup.subarray(40));
  const db = new DatabaseSync(sqlitePath, { readOnly: true });
  expect(db.prepare('PRAGMA user_version').get().user_version).toBe(4);
  expect(db.prepare('PRAGMA integrity_check').get().integrity_check).toBe('ok');
  expect(db.prepare('SELECT opening_balance FROM accounts').get().opening_balance).toBe(1000);
  expect(db.prepare('SELECT amount FROM cash_entries ORDER BY id').all().map((row) => row.amount))
    .toEqual([230, 55, 25]);
  db.close();
  await writeFile(info.outputPath('web-export.hadgaly'), backup);
  await button(page, 'Буцах').click();
  await post(page, 'Зарлага', '80', 'Хоол');
  await expect(balance(page, '1,120')).toBeVisible();
  await settings(page);

  const corrupted = Buffer.from(backup);
  corrupted[50] ^= 1;
  await upload(page, corrupted);
  await expect(text(page, 'Нөөц файлыг шалгах эсвэл бэлтгэх боломжгүй байна. Одоогийн өгөгдөл хэвээр байна.')).toBeVisible();
  await upload(page, backup);
  await expect(button(page, 'Сэргээх')).toBeVisible();
  if (info.project.name === 'android-emulated') await page.screenshot({ path: info.outputPath('restore.png') });
  await button(page, 'Болих').click();
  await upload(page, backup);
  // Abort publication only, after the worker has persisted and verified its candidate.
  await page.evaluate(() => {
    const put = IDBObjectStore.prototype.put;
    IDBObjectStore.prototype.put = function (...args) {
      if (this.name === 'state' && String(args[0]).includes('"restored":true')) {
        IDBObjectStore.prototype.put = put;
        this.transaction.abort();
        return;
      }
      return put.apply(this, args);
    };
  });
  await button(page, 'Сэргээх').click();
  await expect(text(page, 'Нөөц файлыг шалгах эсвэл бэлтгэх боломжгүй байна. Одоогийн өгөгдөл хэвээр байна.')).toBeVisible();
  await open(page);
  await expect(balance(page, '1,120')).toBeVisible();
  await settings(page);
  await upload(page, backup);
  await button(page, 'Сэргээх').click();
  await expect(button(page, 'Дахин нээх')).toBeVisible();
  await expect(button(page, 'Цэс нээх')).toHaveCount(0);
  // Simulate closing/reloading without using the explicit restart button.
  await open(page);
  await button(page, 'Ойлголоо').click();
  await expect(balance(page, '1,200')).toBeVisible();
  await settings(page);
  const previous = await exportFile(page, true);
  await upload(page, previous);
  await button(page, 'Сэргээх').click();
  await button(page, 'Дахин нээх').click();
  await button(page, 'Ойлголоо').click();
  await expect(balance(page, '1,120')).toBeVisible();
  expect(unexpected).toEqual([]);
});

test('320px with browser text enlarged to 180 percent', async ({ page }, info) => {
  await page.setViewportSize({ width: 320, height: 760 });
  await page.emulateMedia({ reducedMotion: 'reduce' });
  await page.addInitScript(() => {
    const apply = () => { document.documentElement.style.fontSize = '180%'; };
    if (document.documentElement) apply();
    else addEventListener('DOMContentLoaded', apply, { once: true });
  });
  await open(page);
  await onboard(page, { keyboard: true });
  await expect(balance(page, '1,000')).toBeVisible();
  await settings(page);
  await expect(button(page, 'Өгөгдөл нөөцлөх')).toBeVisible();
  await expect(button(page, 'Нөөцөөс сэргээх')).toBeVisible();
  expect(await page.evaluate(() => document.documentElement.scrollWidth)).toBe(320);
  await page.screenshot({ path: info.outputPath('settings-320-180.png') });
});

test('web edits, deletions and anchors persist with a switched default', async ({ page }, info) => {
  test.skip(info.project.name !== 'chrome', 'Ledger UI mutations exercised once on Chromium');
  await open(page);
  await onboard(page);
  await button(page, 'Миний данс').click();
  await button(page, 'Данс нэмэх').click();
  await fill(page, 'Дансны нэр', 'Карт');
  await fill(page, 'Эхний үлдэгдэл', '0');
  await button(page, 'Хадгалах').click();
  await button(page, 'Үндсэн данс солих').click();
  await button(page, 'Карт').click();
  await page.getByRole('button', { name: /^Карт.*₮/s }).click();
  await button(page, 'Үлдэгдэл тохируулах').click();
  await fill(page, 'Бодит үлдэгдэл', '500');
  await button(page, 'Хадгалах').click();
  await button(page, 'Тохируулгын дүн засах').click();
  await fill(page, 'Бодит үлдэгдэл', '450');
  await button(page, 'Хадгалах').click();
  await expect(text(page, 'Засварын түүх')).toBeVisible();
  await button(page, 'Буцах').click();
  await button(page, 'Буцах').click();
  await expect(balance(page, '1,450')).toBeVisible();
  await post(page, 'Зарлага', '55', 'Хоол');
  await expect(balance(page, '1,395')).toBeVisible();
  await button(page, 'Гүйлгээний түүх').click();
  const entry = page.getByRole('button', { name: /^Хоол.*Карт/s });
  await entry.click();
  await fill(page, 'Мөнгөн дүн', '60');
  await button(page, 'Хадгалах').click();
  await expect(entry).toContainText('60');
  await entry.click();
  await button(page, 'Гүйлгээ устгах').click();
  await button(page, 'Устгах').click();
  await expect(page.getByRole('heading', { name: 'Гүйлгээний түүх' })).toBeVisible();
  await expect(entry).toHaveCount(0);
  await open(page);
  await expect(balance(page, '1,450')).toBeVisible();
  await settings(page);
  const backup = await exportFile(page);
  const path = info.outputPath('ledger.sqlite');
  await writeFile(path, backup.subarray(40));
  const db = new DatabaseSync(path, { readOnly: true });
  try {
    expect(db.prepare('SELECT default_account_id FROM profiles').get().default_account_id).toBe(2);
    expect(db.prepare('SELECT target FROM balance_adjustments').get().target).toBe(450);
    expect(db.prepare('SELECT old_target, new_target FROM adjustment_edits').get())
      .toMatchObject({ old_target: 500, new_target: 450 });
    expect(db.prepare('SELECT account_id, amount, deleted FROM entry_revisions ORDER BY revision').all())
      .toEqual([{ account_id: 2, amount: 60, deleted: 0 }, { account_id: 2, amount: 60, deleted: 1 }]);
  } finally {
    db.close();
  }
});

test('native Android backup restores and re-exports all ledger rows', async ({ page }, info) => {
  test.skip(!process.env.HADGALY_ANDROID_FIXTURE, 'Run the guarded Android bridge first');
  const android = await readFile(process.env.HADGALY_ANDROID_FIXTURE);
  await open(page);
  await onboard(page);
  await settings(page);
  await upload(page, android);
  await expect(button(page, 'Сэргээх')).toBeVisible();
  await button(page, 'Сэргээх').click();
  await button(page, 'Дахин нээх').click();
  await button(page, 'Ойлголоо').click();
  await expect(balance(page, '425')).toBeVisible();
  await settings(page);
  const exported = await exportFile(page);
  await writeFile(info.outputPath('browser-rich.hadgaly'), exported);
  for (const [key, envelope] of [['android', android], ['web', exported]]) {
    await writeFile(info.outputPath(key + '.sqlite'), envelope.subarray(40));
  }
  const source = new DatabaseSync(info.outputPath('android.sqlite'), { readOnly: true });
  const restored = new DatabaseSync(info.outputPath('web.sqlite'), { readOnly: true });
  try {
    const names = ['profiles', 'accounts', 'categories', 'ledger_sequences', 'cash_entries',
      'entry_revisions', 'balance_adjustments', 'adjustment_edits', 'sqlite_sequence'];
    for (const table of names) {
      const query = 'SELECT * FROM ' + table + ' ORDER BY rowid';
      expect(restored.prepare(query).all()).toEqual(source.prepare(query).all());
    }
    expect(restored.prepare('PRAGMA foreign_key_check').all()).toEqual([]);
    expect(restored.prepare('SELECT revision, deleted, amount FROM entry_revisions').get())
      .toMatchObject({ revision: 1, deleted: 1, amount: 50 });
  } finally {
    source.close();
    restored.close();
  }
});

test('a persisted v3 fixture migrates through the live web executor', async ({ page }, info) => {
  test.skip(info.project.name !== 'chrome', 'Shared migration logic exercised once on Chromium');
  const image = await readFile('test/fixtures/stage3_v3.fixture');
  await page.route('**/migration-seed', (route) =>
    route.fulfill({ contentType: 'text/html', body: '<!doctype html><title>Test fixture setup</title>' }));
  await page.goto('/migration-seed');
  // Test-only seeding of the pinned sqlite3.dart 3.5.2 IndexedDB VFS format.
  await page.evaluate(async (bytes) => {
    const db = await new Promise((resolve, reject) => {
      const request = indexedDB.open('hadgaly-finance-v4', 1);
      request.onupgradeneeded = () => {
        request.result.createObjectStore('files', { autoIncrement: true })
          .createIndex('fileName', 'name', { unique: true });
        request.result.createObjectStore('blocks');
      };
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
    await new Promise((resolve, reject) => {
      const tx = db.transaction(['files', 'blocks'], 'readwrite');
      tx.oncomplete = resolve;
      tx.onabort = () => reject(tx.error);
      tx.objectStore('files').put({ name: '/database', length: bytes.length }, 1);
      for (let offset = 0; offset < bytes.length; offset += 4096) {
        const block = new Uint8Array(4096);
        block.set(bytes.slice(offset, offset + 4096));
        tx.objectStore('blocks').put(block.buffer, [1, offset]);
      }
    });
    db.close();
  }, [...image]);
  await open(page);
  await expect(page.getByText(/^Бүх дансны одоогийн нийт үлдэгдэл:/)).toBeVisible();
  await settings(page);
  const migrated = await exportFile(page);
  await writeFile(info.outputPath('migrated.sqlite'), migrated.subarray(40));
  await writeFile(info.outputPath('fixture.sqlite'), image);
  const fixture = new DatabaseSync(info.outputPath('fixture.sqlite'), { readOnly: true });
  const database = new DatabaseSync(info.outputPath('migrated.sqlite'), { readOnly: true });
  try {
    expect(database.prepare('PRAGMA user_version').get().user_version).toBe(4);
    expect(database.prepare('SELECT count(*) n FROM entry_revisions').get().n).toBe(0);
    for (const table of ['profiles', 'accounts', 'categories', 'cash_entries',
      'ledger_sequences', 'balance_adjustments', 'adjustment_edits']) {
      const query = 'SELECT * FROM ' + table + ' ORDER BY rowid';
      expect(database.prepare(query).all()).toEqual(fixture.prepare(query).all());
    }
  } finally {
    database.close();
    fixture.close();
  }
});

test('installed shell update and full browser restart retain records', async ({}, info) => {
  test.skip(info.project.name !== 'chrome' || !!process.env.HADGALY_TEST_ORIGIN, 'Isolated local update simulation');
  const root = info.outputPath('release');
  await cp('build/web', root, { recursive: true });
  const server = spawn(process.execPath, ['tool/serve-web.mjs', root], {
    env: { ...process.env, HADGALY_WEB_PORT: '0' }, stdio: ['ignore', 'pipe', 'inherit'],
  });
  let browser;
  try {
    const origin = await new Promise((resolve, reject) => {
      server.once('exit', () => reject(new Error('Update test server exited')));
      server.stdout.on('data', (chunk) => {
        const url = chunk.toString().match(/http:\/\/127\.0\.0\.1:\d+/)?.[0];
        if (url) resolve(url);
      });
    });
    const profile = info.outputPath('browser-profile');
    browser = await chromium.launchPersistentContext(profile, { channel: 'chrome', baseURL: origin });
    let page = browser.pages()[0];
    await open(page);
    await onboard(page);
    await post(page, 'Орлого', '7', 'Цалин');
    await expect(balance(page, '1,007')).toBeVisible();
    await page.waitForFunction(() => navigator.serviceWorker.controller !== null);
    const session = await browser.newCDPSession(page);
    const installability = await session.send('Page.getInstallabilityErrors');
    expect(installability.installabilityErrors).toEqual([]);

    const before = await readFile(root + '/sw.js', 'utf8');
    await writeFile(root + '/sw.js', before.replace(/namespace \+ '[a-f0-9]+'/, "namespace + 'update-test'"));
    await page.evaluate(async () => (await navigator.serviceWorker.getRegistration()).update());
    await page.waitForFunction(async () => (await navigator.serviceWorker.getRegistration())?.waiting);
    await browser.close();
    browser = await chromium.launchPersistentContext(profile, { channel: 'chrome', baseURL: origin });
    page = browser.pages()[0];
    await open(page);
    await expect(balance(page, '1,007')).toBeVisible();
    await page.waitForFunction(async () =>
      (await caches.keys()).filter((key) => key.startsWith('hadgaly-shell-')).join() === 'hadgaly-shell-update-test');
    await browser.setOffline(true);
    await open(page);
    await expect(balance(page, '1,007')).toBeVisible();
  } finally {
    await browser?.close();
    server.kill();
  }
});
