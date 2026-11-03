"""Real Android IME smoke test, synthetic data only, on the disposable AVD.

Build a NORMAL sandbox APK first (no integration target), then pass its path.
Refuses the production package, wrong AVD, or existing sandbox installation.
--resume-empty only permits the identical installed APK with an empty profile;
it never clears existing data to make the test pass.
No data clearing, uninstall, database seeding, or founder-device commands.
"""
from pathlib import Path
import hashlib
import os
import re
import sqlite3
import subprocess
import sys
import time
import xml.etree.ElementTree as ET

sdk = Path(os.environ['LOCALAPPDATA']) / 'Android/Sdk'
adb = str(sdk / 'platform-tools/adb.exe')
package = 'mn.hadgaly.hadgaly.sandbox'
device = 'emulator-5556'
apk = Path(sys.argv[1]).resolve()
output = Path('build/stage3/real-ime')
output.mkdir(parents=True, exist_ok=True)

def command(*args):
    return subprocess.run([adb, '-s', device, *args], capture_output=True, check=True).stdout

if command('emu', 'avd', 'name').decode().splitlines()[0] != 'Hadgaly_Stage2_Disposable':
    raise SystemExit('Wrong AVD; refusing')
packages = command('shell', 'pm', 'list', 'packages').decode().splitlines()
if 'package:mn.hadgaly.hadgaly' in packages:
    raise SystemExit('Main package present; refusing')
installed = f'package:{package}' in packages
resume = '--resume-empty' in sys.argv[2:]
if installed and not resume:
    raise SystemExit('Sandbox already installed; no automatic uninstall')
badging = subprocess.run([str(sdk / 'build-tools/37.0.0/aapt.exe'), 'dump', 'badging', str(apk)],
    capture_output=True, check=True).stdout.decode()
actual = re.search(r"^package: name='([^']+)'", badging).group(1)
if actual != package:
    raise SystemExit('Unsafe APK package ID; refusing installation')
digest = hashlib.sha256(apk.read_bytes()).hexdigest()
frozen = output / 'verified-sandbox.apk'
frozen.write_bytes(apk.read_bytes())
assert hashlib.sha256(frozen.read_bytes()).hexdigest() == digest
print(f'VERIFIED BEFORE INSTALL: {actual}; {device}; SHA256={digest}', flush=True)
if installed:
    # A failed smoke-test setup may resume only the exact APK and EMPTY profile.
    # Never clear/recreate existing records to obtain a passing test.
    installed_path = command('shell', 'pm', 'path', package).decode().strip().removeprefix('package:')
    assert hashlib.sha256(command('exec-out', 'cat', installed_path)).hexdigest() == digest
    command('shell', 'am', 'force-stop', package)
    preserved = output / f'empty-check-{time.time_ns()}'
    preserved.mkdir()
    for name in command('shell', 'run-as', package, 'ls', 'app_flutter').decode().splitlines():
        if re.fullmatch(r'hadgaly\.sqlite(?:-wal|-shm|-journal)?', name):
            (preserved / name).write_bytes(command('exec-out', 'run-as', package, 'cat', f'app_flutter/{name}'))
    check = sqlite3.connect(str(preserved / 'hadgaly.sqlite'))
    assert check.execute('SELECT step,completed,nickname FROM profiles').fetchall() == [(0, 0, '')]
    for table in ['accounts', 'cash_entries', 'balance_adjustments']:
        assert check.execute(f'SELECT count(*) FROM {table}').fetchone()[0] == 0
    check.close()
    print('VERIFIED existing same sandbox APK and empty synthetic onboarding; no reinstall/reset', flush=True)
else:
    command('install', str(frozen.resolve()))
command('shell', 'am', 'start', '-W', '-n', f'{package}/mn.hadgaly.hadgaly.MainActivity')

def snapshot():
    command('shell', 'uiautomator', 'dump', '/sdcard/hadgaly-keyboard-test.xml')
    data = command('exec-out', 'cat', '/sdcard/hadgaly-keyboard-test.xml')
    (output / 'last-ui.xml').write_bytes(data)
    return ET.fromstring(data)

def bounds(node):
    return list(map(int, re.findall(r'\d+', node.attrib['bounds'])))

def label(node):
    return node.attrib.get('content-desc', '') or node.attrib.get('text', '') or node.attrib.get('hint', '')

def find_node(predicate, scroll=False):
    for attempt in range(10):
        nodes = [n for n in snapshot().iter('node') if predicate(n)]
        for node in nodes:
            x1, y1, x2, y2 = bounds(node)
            if x2 > x1 and y2 > y1:
                return node
        if scroll and attempt > 0:
            command('shell', 'input', 'swipe', '540', '1800', '540', '650', '250')
        time.sleep(0.3)
    raise AssertionError('Expected synthetic UI control missing; see last-ui.xml')

def tap(text, scroll=False):
    node = find_node(lambda n: label(n) == text and n.attrib.get('clickable') == 'true', scroll)
    x1, y1, x2, y2 = bounds(node)
    command('shell', 'input', 'tap', str((x1+x2)//2), str((y1+y2)//2))
    time.sleep(0.5)

def enter(text, value):
    node = find_node(lambda n: text in label(n) and n.attrib.get('class') == 'android.widget.EditText')
    x1, y1, x2, y2 = bounds(node)
    command('shell', 'input', 'tap', str((x1+x2)//2), str((y1+y2)//2))
    time.sleep(0.6)
    command('shell', 'input', 'text', value)
    # Verify the actual Android input connection value, not a programmatic Flutter controller.
    find_node(lambda n: n.attrib.get('class') == 'android.widget.EditText' and n.attrib.get('text') == value)
    command('shell', 'input', 'keyevent', '4')
    time.sleep(0.4)

def screenshot(name):
    (output / f'{name}.png').write_bytes(command('exec-out', 'screencap', '-p'))

enter('Дуудах нэр', 'KeyboardTest')
tap('Болсон', True)
tap('Эхэлцгээе', True)
enter('Дансны нэр', 'Wallet')
enter('Эхний үлдэгдэл', '0')
tap('Дансаа үүсгэх', True)
tap('Нүүр рүү орох', True)
for action, amount, category in [('Орлого нэмэх', '123', 'Цалин'), ('Зарлага нэмэх', '125', 'Хоол')]:
    tap(action, True)
    enter('Мөнгөн дүн', amount)
    tap(category)
    screenshot('income-entry' if amount == '123' else 'expense-entry')
    tap('Хадгалах', True)
    find_node(lambda n: 'Бүх дансны одоогийн нийт үлдэгдэл' in label(n))
screenshot('home-real-ime')
# Force-stop/reopen persistence, then inspect a COPY of the synthetic SQLite file.
command('shell', 'am', 'force-stop', package)
files = command('shell', 'run-as', package, 'ls', 'app_flutter').decode().splitlines()
for name in files:
    if re.fullmatch(r'hadgaly\.sqlite(?:-wal|-shm|-journal)?', name):
        (output / name).write_bytes(command('exec-out', 'run-as', package, 'cat', f'app_flutter/{name}'))
db = sqlite3.connect(str(output / 'hadgaly.sqlite'))
assert db.execute('PRAGMA user_version').fetchone()[0] == 3
assert db.execute('SELECT kind,amount FROM cash_entries ORDER BY id').fetchall() == [('income', 123), ('expense', 125)]
assert db.execute('SELECT opening_balance FROM accounts').fetchone()[0] == 0
assert db.execute('SELECT completed,default_account_id FROM profiles').fetchone() == (1, 1)
assert db.execute('SELECT count(*) FROM balance_adjustments').fetchone()[0] == 0
assert not db.execute('PRAGMA foreign_key_check').fetchall()
db.close()
command('shell', 'am', 'start', '-W', '-n', f'{package}/mn.hadgaly.hadgaly.MainActivity')
find_node(lambda n: 'Бүх дансны одоогийн нийт үлдэгдэл: −2 ₮' == label(n))
screenshot('home-after-restart')
(output / 'result.txt').write_text(f'PASS real Android IME; synthetic income=123 expense=125 balance=-2; 2 entries; restart persisted. APK SHA256={digest}\n')
print('PASS real Android keyboard / synthetic entry / SQLite / cold restart; production untouched', flush=True)
