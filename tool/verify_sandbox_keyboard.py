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

if not __debug__:
    raise SystemExit('Safety assertions must remain enabled; do not use optimized Python')

sdk = Path(os.environ['LOCALAPPDATA']) / 'Android/Sdk'
adb = str(sdk / 'platform-tools/adb.exe')
package = 'mn.hadgaly.hadgaly.sandbox'
device = 'emulator-5556'
apk = Path(sys.argv[1]).resolve()
drawer_check = '--drawer-screenshots' in sys.argv[2:]
output = Path('build/stage5', 'drawer-ime' if drawer_check else 'report-ime') / time.strftime('%Y%m%d-%H%M%S')
output.mkdir(parents=True, exist_ok=False)

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
print(f'VERIFIED BEFORE INSTALL: {actual}; {device}; SHA256={digest}; evidence={output}', flush=True)
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
            sizes = re.findall(r'(\d+)x(\d+)', command('shell', 'wm', 'size').decode())
            width, height = map(int, sizes[-1])
            command('shell', 'input', 'swipe', str(width//2), str(height*3//4), str(width//2), str(height//3), '250')
        time.sleep(0.3)
    raise AssertionError('Expected synthetic UI control missing; see last-ui.xml')

def tap(text, scroll=False):
    node = find_node(lambda n: label(n) == text and n.attrib.get('clickable') == 'true', scroll)
    x1, y1, x2, y2 = bounds(node)
    command('shell', 'input', 'tap', str((x1+x2)//2), str((y1+y2)//2))
    time.sleep(0.5)

def enter(text, value, replace=False):
    node = find_node(lambda n: (text in label(n) or text in n.attrib.get('hint','')) and n.attrib.get('class') == 'android.widget.EditText')
    x1, y1, x2, y2 = bounds(node)
    command('shell', 'input', 'tap', str((x1+x2)//2), str((y1+y2)//2))
    time.sleep(0.6)
    if replace:
        command('shell', 'input', 'keyevent', '123', *(['67'] * len(node.attrib.get('text',''))))
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

# Real OS screenshots of the same synthetic records on both screen sizes.
# No Flutter surface conversion, database seeding or financial mutation for images.
def restart_home():
    command('shell', 'am', 'force-stop', package)
    command('shell', 'am', 'start', '-W', '-n', f'{package}/mn.hadgaly.hadgaly.MainActivity')
    find_node(lambda n: label(n).startswith('Энэ сарын зарлагын ангиллын хуваарилалт.'))

def capture_report(suffix):
    restart_home()
    screenshot(f'report-home{suffix}')
    tap('Санхүүгийн тайлан', True)
    find_node(lambda n: label(n) == 'Цэвэр: −2 ₮', True)
    screenshot(f'report-screen{suffix}')
    find_node(lambda n: label(n) == '125 ₮ · 100.0%', True)
    screenshot(f'report-breakdown{suffix}')
    find_node(lambda n: label(n) == 'Үндсэн данс', True)
    screenshot(f'report-accounts{suffix}')
    command('shell', 'input', 'keyevent', '4')
    find_node(lambda n: label(n) == 'Санхүүгийн тайлан' and n.attrib.get('clickable') == 'true', True)

def capture_drawer(suffix):
    def menu_closed():
        # The modal excludes the underlying toolbar from Android's UI tree.
        find_node(lambda n: label(n) == 'Цэс нээх' and n.attrib.get('clickable') == 'true')

    restart_home()
    menu_closed()
    screenshot(f'drawer-closed{suffix}')
    tap('Цэс нээх')
    modules = ('Хийх зүйл', 'Авах зүйл', 'Санаа', 'Санхүү')
    finance = find_node(lambda n: label(n) == 'Санхүү' and n.attrib.get('selected') == 'true')
    visible_labels = {label(n) for n in snapshot().iter('node')}
    assert set(modules) | {'Цэс', 'Цэс хаах'} <= visible_labels
    assert 'Тохиргоо' not in visible_labels
    screenshot(f'drawer-open{suffix}')

    sizes = re.findall(r'(\d+)x(\d+)', command('shell', 'wm', 'size').decode())
    width, height = map(int, sizes[-1])
    x1, _, x2, _ = bounds(finance)
    # The scrim must consume this tap and leave Finance selected.
    command('shell', 'input', 'tap', str(x1//3), str(height//2))
    menu_closed()
    tap('Цэс нээх')
    close = find_node(lambda n: label(n) == 'Цэс хаах'
                      and bounds(n)[0] >= x1)
    a, b, c, d = bounds(close)
    command('shell', 'input', 'tap', str((a+c)//2), str((b+d)//2))
    menu_closed()
    tap('Цэс нээх')
    command('shell', 'input', 'swipe', str((x1+x2)//2), str(height*2//3),
            str(width-32), str(height*2//3), '250')
    menu_closed()

    tap('Санхүүгийн тайлан', True)
    find_node(lambda n: label(n) == 'Цэвэр: −2 ₮', True)
    tap('Цэс нээх')
    command('shell', 'input', 'keyevent', '4')
    menu_closed()
    find_node(lambda n: label(n) == 'Цэвэр: −2 ₮', True)
    for name in modules[:3]:
        tap('Цэс нээх')
        tap(name)
        find_node(lambda n: label(n) == 'Тун удахгүй')
    tap('Цэс нээх')
    tap('Санхүү')
    find_node(lambda n: label(n) == 'Цэвэр: −2 ₮', True)
    command('shell', 'input', 'keyevent', '4')
    menu_closed()
    # The underlying Home intentionally retains its scroll position at the report
    # row, so the donut may be above the viewport on a small display.
    balance = 'Бүх дансны одоогийн нийт үлдэгдэл: −2 ₮'
    find_node(lambda n: label(n) == balance)

    # Open the drawer while a real keyboard and unsaved transaction form are active.
    tap('Орлого нэмэх', True)
    field = find_node(lambda n: 'Мөнгөн дүн' in label(n)
                      and n.attrib.get('class') == 'android.widget.EditText')
    a, b, c, d = bounds(field)
    command('shell', 'input', 'tap', str((a+c)//2), str((b+d)//2))
    time.sleep(0.5)
    command('shell', 'input', 'text', '42')
    tap('Цэс нээх')
    tap('Санаа')
    tap('Цэс нээх')
    tap('Санхүү')
    find_node(lambda n: n.attrib.get('class') == 'android.widget.EditText'
              and n.attrib.get('text') == '42')
    tap('Буцах')
    find_node(lambda n: label(n) == balance)
    print(f'PASS: Android drawer{suffix}: four modules, outside/close/swipe/Back, report and IME draft retained', flush=True)


capture = capture_drawer if drawer_check else capture_report
capture('')
if drawer_check or '--report-screenshots' in sys.argv[2:]:
    # Only run on the already verified disposable AVD with standard metrics.
    assert 'Override' not in command('shell', 'wm', 'size').decode()
    assert 'Override' not in command('shell', 'wm', 'density').decode()
    original_scale = command('shell', 'settings', 'get', 'system', 'font_scale').decode().strip()
    try:
        command('shell', 'wm', 'size', '640x1136')
        command('shell', 'wm', 'density', '320')
        command('shell', 'settings', 'put', 'system', 'font_scale', '1.8')
        capture('-large-text')
    finally:
        command('shell', 'settings', 'put', 'system', 'font_scale', original_scale)
        command('shell', 'wm', 'size', 'reset')
        command('shell', 'wm', 'density', 'reset')
restart_home()

def tap_row(amount):
    node=find_node(lambda n: amount in label(n) and n.attrib.get('clickable')=='true',True)
    x1,y1,x2,y2=bounds(node)
    command('shell','input','tap',str((x1+x2)//2),str((y1+y2)//2))
    time.sleep(0.5)
tap('Гүйлгээний түүх',True)
tap_row('+123 ₮')
enter('Мөнгөн дүн','200',replace=True)
screenshot('edited-entry-real-ime')
tap('Хадгалах',True)
tap_row('−125 ₮')
ime = command('shell','dumpsys','input_method').decode(errors='replace')
if 'mInputShown=true' in ime or 'mIsInputViewShown=true' in ime:
    command('shell','input','keyevent','4')
    time.sleep(0.4)
tap('Гүйлгээ устгах',True)
screenshot('delete-confirmation')
tap('Устгах')
find_node(lambda n: '+200 ₮' in label(n))
screenshot('history-after-edit-delete')
command('shell','input','keyevent','4')
find_node(lambda n: 'Бүх дансны одоогийн нийт үлдэгдэл: 200 ₮' == label(n))

# Force-stop/reopen persistence, then inspect a COPY of the synthetic SQLite file.
command('shell', 'am', 'force-stop', package)
files = command('shell', 'run-as', package, 'ls', 'app_flutter').decode().splitlines()
for name in files:
    if re.fullmatch(r'hadgaly\.sqlite(?:-wal|-shm|-journal)?', name):
        (output / name).write_bytes(command('exec-out', 'run-as', package, 'cat', f'app_flutter/{name}'))
db = sqlite3.connect(str(output / 'hadgaly.sqlite'))
assert db.execute('PRAGMA user_version').fetchone()[0] == 4
assert db.execute('SELECT kind,amount FROM cash_entries ORDER BY id').fetchall() == [('income', 123), ('expense', 125)]
assert db.execute('SELECT opening_balance FROM accounts').fetchone()[0] == 0
assert db.execute('SELECT completed,default_account_id FROM profiles').fetchone() == (1, 1)
assert db.execute('SELECT count(*) FROM balance_adjustments').fetchone()[0] == 0
assert db.execute('SELECT entry_id,revision,amount,deleted FROM entry_revisions ORDER BY id').fetchall()==[(1,1,200,0),(2,1,125,1)]
assert db.execute('SELECT count(*) FROM ledger_sequences').fetchone()[0]==2
assert not db.execute('PRAGMA foreign_key_check').fetchall()
db.close()
command('shell', 'am', 'start', '-W', '-n', f'{package}/mn.hadgaly.hadgaly.MainActivity')
find_node(lambda n: 'Бүх дансны одоогийн нийт үлдэгдэл: 200 ₮' == label(n))
screenshot('home-after-restart')
(output / 'result.txt').write_text(f'PASS real Android IME; synthetic originals income=123 expense=125 preserved; revised income=200, expense deleted; balance=200; 2 revisions; restart persisted. APK SHA256={digest}\n')
print('PASS real Android IME / create-edit-delete / immutable originals / revisions / SQLite / restart; production untouched', flush=True)
