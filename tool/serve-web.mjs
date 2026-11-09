import { createServer as createHttpServer } from 'node:http';
import { createServer as createHttpsServer } from 'node:https';
import { createReadStream, readFileSync, statSync } from 'node:fs';
import { extname, resolve, sep } from 'node:path';

const root = resolve(process.argv[2] ?? 'build/web');
const port = Number(process.env.HADGALY_WEB_PORT ?? 4173);
const certPath = process.env.HADGALY_TEST_TLS_CERT;
const keyPath = process.env.HADGALY_TEST_TLS_KEY;
if (Boolean(certPath) !== Boolean(keyPath)) throw new Error('Supply both TLS paths.');
const config = JSON.parse(readFileSync('vercel.json', 'utf8'));
const mime = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8',
  '.wasm': 'application/wasm', '.json': 'application/json; charset=utf-8',
  '.css': 'text/css; charset=utf-8', '.png': 'image/png', '.svg': 'image/svg+xml',
  '.ttf': 'font/ttf', '.otf': 'font/otf', '.woff2': 'font/woff2',
};
const handle = (request, response) => {
  try {
    const url = new URL(request.url, 'http://localhost');
    const path = decodeURIComponent(url.pathname);
    let file = resolve(root, '.' + path);
    if (file !== root && !file.startsWith(root + sep)) {
      response.writeHead(403).end();
      return;
    }
    let info = statSync(file, { throwIfNoEntry: false });
    if ((!info || !info.isFile()) && !extname(path)) {
      file = resolve(root, 'index.html');
      info = statSync(file, { throwIfNoEntry: false });
    }
    if (!info?.isFile()) {
      response.writeHead(404).end();
      return;
    }
    for (const rule of config.headers) {
      if (!new RegExp('^' + rule.source + '$').test(path)) continue;
      for (const header of rule.headers) response.setHeader(header.key, header.value);
    }
    response.setHeader('Content-Type', mime[extname(file)] ?? 'application/octet-stream');
    response.setHeader('Content-Length', info.size);
    if (request.method === 'HEAD') response.end();
    else createReadStream(file).pipe(response);
  } catch {
    response.writeHead(400).end();
  }
};
const server = certPath
  ? createHttpsServer({ cert: readFileSync(certPath), key: readFileSync(keyPath) }, handle)
  : createHttpServer(handle);
const scheme = certPath ? 'https' : 'http';
server.listen(port, '127.0.0.1', () => console.log(`Hadgaly web test origin ${scheme}://127.0.0.1:${server.address().port}`));
