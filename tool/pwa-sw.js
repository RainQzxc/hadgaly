'use strict';

const namespace = 'hadgaly-shell-';
const version = namespace + '__RELEASE__';
const assets = __ASSETS__;

async function cacheAsset(cache, path) {
  const bytes = Uint8Array.from(assets[path].match(/../g), (hex) => parseInt(hex, 16));
  const integrity = 'sha256-' + btoa(String.fromCharCode(...bytes));
  const response = await fetch(path, { cache: 'reload', integrity });
  if (!response.ok || response.redirected) throw new Error('Asset unavailable');
  await cache.put(path, response.clone());
  return response;
}

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(version);
    try {
      const paths = Object.keys(assets);
      for (let i = 0; i < paths.length; i += 6) {
        const results = await Promise.allSettled(
          paths.slice(i, i + 6).map((path) => cacheAsset(cache, path)),
        );
        if (results.some((result) => result.status === 'rejected')) {
          throw new Error('Incomplete offline release');
        }
      }
    } catch (error) {
      await caches.delete(version);
      throw error;
    }
    // Let old tabs finish with the old release. No forced activation.
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    await Promise.all((await caches.keys())
      .filter((name) => name.startsWith(namespace) && name !== version)
      .map((name) => caches.delete(name)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== 'GET' || url.origin !== self.location.origin) return;
  const key = request.mode === 'navigate' ? '/index.html' : url.pathname;
  if (!Object.hasOwn(assets, key)) return;
  event.respondWith((async () => {
    const cache = await caches.open(version);
    const cached = await cache.match(key);
    if (cached) return cached;
    try {
      // Recover an evicted asset only when its release hash still matches.
      return await cacheAsset(cache, key);
    } catch (_) {
      return new Response(
        'Хадгалъя ачаалахад шаардлагатай файл алга. Интернэтэд холбогдож, Хадгалъя нээлттэй бүх цонхыг хаагаад дахин нээнэ үү.',
        { status: 503, headers: { 'Content-Type': 'text/plain; charset=utf-8' } },
      );
    }
  })());
});
