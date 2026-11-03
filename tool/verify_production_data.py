"""Private before/after evidence; never alters or restores the device database.

Caller must force-stop the production process before each capture. Copies all
SQLite sidecars before opening a PRIVATE COPY, then compares original records.
No names, notes, balances or raw financial data are printed / written into Git.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import sqlite3
import subprocess
import sys
import time
import xml.etree.ElementTree as ET

if not __debug__:
    raise SystemExit('Safety assertions must remain enabled; do not use optimized Python')

MODE, DIRECTORY = sys.argv[1:]
if MODE not in ('before', 'after', 'ready'):
    raise SystemExit('Expected before/after/ready and a private evidence directory')
root = Path(DIRECTORY).resolve()
private_root = (Path(os.environ['LOCALAPPDATA']) / 'HadgalyDev').resolve()
if private_root not in root.parents:
    raise SystemExit('Evidence must stay outside Git under LOCALAPPDATA/HadgalyDev')
adb = Path(os.environ['LOCALAPPDATA']) / 'Android/Sdk/platform-tools/adb.exe'
base = [str(adb), '-s', 'emulator-5554']
def run(*args):
    return subprocess.run(base + list(args), capture_output=True, check=True).stdout
assert run('emu', 'avd', 'name').decode().splitlines()[0] == 'Medium_Phone_API_37.0'
if MODE == 'ready':
    deadline = time.monotonic() + 60
    while time.monotonic() < deadline:
        try:
            subprocess.run(base + ['shell', 'uiautomator', 'dump', '/sdcard/hadgaly-demo-ready.xml'],
                capture_output=True, check=True, timeout=15)
            ui = ET.fromstring(run('exec-out', 'cat', '/sdcard/hadgaly-demo-ready.xml'))
            nodes = [n for n in ui.iter('node') if n.attrib.get('package') == 'mn.hadgaly.hadgaly']
            ready = any('Бүх дансны одоогийн нийт үлдэгдэл:' in n.attrib.get('content-desc', '')
                or 'Танилцах ' in n.attrib.get('content-desc', '') for n in nodes)
            if ready and any(n.attrib.get('clickable') == 'true' and n.attrib.get('enabled') == 'true' for n in nodes):
                print('PASS main Android UI ready: real app content and enabled controls accessible')
                raise SystemExit(0)
        except (subprocess.SubprocessError, ET.ParseError):
            pass
        time.sleep(0.3)
    raise SystemExit('Main UI readiness timeout; do not claim an interactive demo')
# pidof exits 1 when no process exists; inspect its status without check=True.
process = subprocess.run(base + ['shell', 'pidof', 'mn.hadgaly.hadgaly'], capture_output=True)
assert process.returncode == 1 and not process.stdout.strip(), 'Force-stop app before capture'
destination = root / MODE
destination.mkdir(parents=True, exist_ok=False)
files = run('shell', 'run-as', 'mn.hadgaly.hadgaly', 'ls', 'app_flutter').decode().splitlines()
names = [name for name in files if re.fullmatch(r'hadgaly\.sqlite(?:-wal|-shm|-journal)?', name)]
assert 'hadgaly.sqlite' in names, 'No production database; refusing fresh install assumption'
for name in names:
    data = run('exec-out', 'run-as', 'mn.hadgaly.hadgaly', 'cat', f'app_flutter/{name}')
    (destination / name).write_bytes(data)
source = sqlite3.connect(str(destination / 'hadgaly.sqlite'))
stable = sqlite3.connect(str(destination / 'stable.sqlite'))
source.backup(stable)
source.close()
assert stable.execute('PRAGMA integrity_check').fetchone()[0] == 'ok'
assert not stable.execute('PRAGMA foreign_key_check').fetchall()
tables = ['accounts', 'profiles', 'balance_adjustments', 'adjustment_edits']
records = {table: stable.execute(f'SELECT * FROM {table} ORDER BY id').fetchall() for table in tables}
fingerprint = hashlib.sha256(json.dumps(records, sort_keys=True).encode()).hexdigest()
version = stable.execute('PRAGMA user_version').fetchone()[0]
cash = stable.execute('SELECT * FROM cash_entries ORDER BY id').fetchall() if version >= 3 else []
cash_hash = hashlib.sha256(json.dumps(cash).encode()).hexdigest()
cash_events = {}
if version >= 3:
    cash_events = {row[0]: row[1:] for row in stable.execute('SELECT id,account_id,effective_at,kind,amount FROM cash_entries')}
if version >= 4:
    for entry, account, effective, kind, amount, deleted in stable.execute('SELECT entry_id,account_id,effective_at,kind,amount,deleted FROM entry_revisions ORDER BY revision'):
        if deleted: cash_events.pop(entry, None)
        else: cash_events[entry] = (account,effective,kind,amount)
revision_rows = stable.execute('SELECT * FROM entry_revisions ORDER BY id').fetchall() if version >= 4 else []
revisions_hash = hashlib.sha256(json.dumps(revision_rows).encode()).hexdigest()
metadata = {table: stable.execute(f'SELECT * FROM {table} ORDER BY id').fetchall() for table in ['categories','ledger_sequences']} if version >= 3 else None
metadata_hash = hashlib.sha256(json.dumps(metadata, sort_keys=True).encode()).hexdigest() if metadata is not None else None
balances = {}
for account, opening in stable.execute('SELECT id,opening_balance FROM accounts'):
    events = [(time, sequence, 'adjustment', target) for sequence, time, target in
        stable.execute('SELECT id,effective_at,target FROM balance_adjustments WHERE account_id=?', (account,))]
    events.extend((time,sequence,kind,amount) for sequence,(owner,time,kind,amount) in cash_events.items() if owner==account)
    balance = opening
    for _, _, kind, amount in sorted(events):
        balance = amount if kind == 'adjustment' else balance + (amount if kind == 'income' else -amount)
        assert abs(balance) <= 999999999999
    balances[account] = balance
evidence = {'schema': version, 'originalRecordsHash': fingerprint,
    'cashRecordsHash': cash_hash,
    'revisionRecordsHash': revisions_hash, 'categorySequenceHash': metadata_hash,
    'balancesHash': hashlib.sha256(json.dumps(balances, sort_keys=True).encode()).hexdigest(),
    'counts': {table: len(rows) for table, rows in records.items()}}
if MODE == 'before':
    assert version in (2, 3, 4)
else:
    previous = json.loads((root / 'before' / 'evidence.json').read_text())
    assert version == 4
    assert fingerprint == previous['originalRecordsHash'], 'Original records changed'
    assert evidence['balancesHash'] == previous['balancesHash'], 'Balances changed'
    assert evidence['counts'] == previous['counts']
    # Updates may preserve real Stage 3 entries, but never add synthetic ones.
    prior_cash_hash = previous.get('cashRecordsHash')
    if prior_cash_hash is None and previous['schema'] == 2:
        prior_cash_hash = hashlib.sha256(json.dumps([]).encode()).hexdigest()
    assert cash_hash == prior_cash_hash, 'Original cash entries changed during update'
    assert revisions_hash == previous['revisionRecordsHash'], 'Revision snapshots changed during update'
    if previous['categorySequenceHash'] is not None:
        assert metadata_hash == previous['categorySequenceHash'], 'Category/sequence data changed during update'
(destination / 'evidence.json').write_text(json.dumps(evidence, indent=2))
stable.close()
print(f'PASS production {MODE}: schema v{version}; original records protected; private evidence captured')
