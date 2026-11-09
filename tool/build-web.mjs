import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { existsSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';

const version = readFileSync('.flutter-version', 'utf8').trim();
const revision = 'c197ca5199e9ee5661e865596c9c07294dfab51c';
const install = process.argv.includes('--install-flutter');
const clerkKey = process.env.HADGALY_CLERK_PUBLISHABLE_KEY?.trim() ?? '';
let clerkOrigin = '';
if (clerkKey) {
  const match = /^pk_test_([A-Za-z0-9+/_=-]+)$/.exec(clerkKey);
  const decoded = match && Buffer.from(match[1], 'base64').toString('utf8');
  const hostname = decoded && /^([a-z0-9-]+\.clerk\.accounts\.dev)\$$/.exec(decoded);
  if (!hostname) throw new Error('Use the Clerk Development publishable key (pk_test_).');
  clerkOrigin = 'https://' + hostname[1];
}
const windows = process.platform === 'win32';
const sdk = process.env.FLUTTER_ROOT || (install ? resolve('.flutter-sdk') : null);
const flutter = sdk ? join(sdk, 'bin', windows ? 'flutter.bat' : 'flutter') : 'flutter';
function run(file, args, capture = false) {
  const result = spawnSync(file, args, {
    shell: windows && (file.endsWith('.bat') || file === 'flutter'),
    stdio: capture ? ['ignore', 'pipe', 'inherit'] : 'inherit',
    encoding: 'utf8',
  });
  if (result.status !== 0) throw result.error ?? new Error(file + ' failed');
  return result.stdout;
}
if (install && !existsSync(flutter)) {
  run('git', ['clone', '--depth', '1', '--branch', version,
    'https://github.com/flutter/flutter.git', sdk]);
}
const sdkVersion = JSON.parse(run(flutter, ['--version', '--machine'], true));
if (sdkVersion.frameworkVersion !== version || sdkVersion.frameworkRevision !== revision) {
  throw new Error('Use pinned Flutter ' + version + ' (' + revision + ')');
}

const sha = (bytes) => createHash('sha256').update(bytes).digest('hex');
const vendors = {
  'sqlite3.wasm': '13d3f11d05b39ba0618a7115fb41640a5d48b6300f5d3f325f554b42bd6688a4',
  'drift_worker.js': 'a54b81412d4c4ab56653bb9e4c02912b0820bb37e2bba00722ddef4d78083d4a',
};
for (const [file, hash] of Object.entries(vendors)) {
  if (sha(readFileSync(join('web', file))) !== hash) {
    throw new Error('Unexpected vendored artifact ' + file);
  }
}

run(flutter, ['pub', 'get', '--enforce-lockfile']);
run(flutter, ['build', 'web', '--release', '--no-pub', '--pwa-strategy=none',
  '--no-web-resources-cdn', '--base-href=/',
  `--dart-define=HADGALY_CLERK_ENABLED=${Boolean(clerkOrigin)}`]);

const output = 'build/web';
const authPage = join(output, 'auth/index.html');
writeFileSync(authPage, readFileSync(authPage, 'utf8')
  .replaceAll('__CLERK_ORIGIN__', clerkOrigin));
writeFileSync(join(output, 'auth/config.js'),
  'window.hadgalyClerk = ' + JSON.stringify({ key: clerkKey, origin: clerkOrigin }) + ';\n');
const template = readFileSync('tool/pwa-sw.js', 'utf8');
const entries = readdirSync(output, { recursive: true, withFileTypes: true })
  .filter((entry) => entry.isFile())
  .map((entry) => join(entry.parentPath, entry.name).slice(output.length + 1)
    .replaceAll('\\', '/'))
  .filter((file) => !['sw.js', '.last_build_id'].includes(file))
  // The pinned JS build uses full or Chromium CanvasKit. Skip debug symbols
  // and renderers the current bootstrap never requests.
  .filter((file) => !file.endsWith('.symbols') &&
    !/^canvaskit\/(skwasm|wimp|webparagraph\/)/.test(file))
  .sort();
const files = Object.fromEntries(entries.map((file) => [
  '/' + file, sha(readFileSync(join(output, file))),
]));
const release = sha(JSON.stringify(files) + template).slice(0, 24);
writeFileSync(join(output, 'sw.js'), template
  .replace('__RELEASE__', release)
  .replace('__ASSETS__', JSON.stringify(files)));
console.log('Hadgaly web release ' + release + ': ' + entries.length + ' offline assets');
