import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';
import 'package:web/web.dart' as web;

import '../../accounts/data/accounts_repository.dart';
import '../../onboarding/data/app_database.dart';
import 'backup_schema.dart';
import 'backup_types.dart';
import 'browser_state.dart';
import 'platform_types.dart';

const _imageLimit = 64 * 1024 * 1024;
const _headerSize = 40;
final _magic = ascii.encode('HADGALY1');
final _wasmUri = Uri.base.resolve('/sqlite3.wasm');
const _storage = WasmStorageImplementation.unsafeIndexedDb;
late WasmProbeResult _probe;
late BrowserStateStore _store;
late BrowserState _state;
bool _initialized = false;
bool _persistent = false;
Future<WasmSqlite3>? _validator;
const restartInstructions =
    'Сэргээж дуусгахын тулд энэ хуудсыг дахин нээнэ үү.';
const restartLabel = 'Дахин нээх';

String? get storageGuidance => [
  if (!web.window.navigator.onLine) 'Офлайн горим.',
  'Санхүүгийн мэдээлэл энэ төхөөрөмжийн энэ браузерт хадгалагдана. Сайтын өгөгдөл цэвэрлэх, браузерын профайл солих эсвэл браузер хадгалалтыг чөлөөлөхөд мэдээлэл алдагдаж болно.',
  if (!_persistent) 'Браузер хадгалалтыг хамгаалах зөвшөөрөл өгөөгүй байна.',
  'Апп суулгасан ч төхөөрөмж хооронд мэдээлэл хуваалцахгүй. Нөөцөө тогтмол файл болгон хадгалаарай.',
].join(' ');

bool get hasRollback => _initialized && _state.rollback != null;

Future<PlatformStartup> initializePlatform() async {
  AppDatabase? db;
  try {
    await holdFinanceLock();
    _store = await BrowserStateStore.open();
    final saved = await _store.read();
    if (saved == null) {
      final databases = await web.window.indexedDB.databases().toDart;
      if (databases.toDart.any((db) => db.name.startsWith('$firstDatabase-'))) {
        throw StateError('Browser restore metadata is missing');
      }
    }
    _state = saved ?? (active: firstDatabase, rollback: null, restored: false);
    _probe = await WasmDatabase.probe(
      sqlite3Uri: _wasmUri,
      driftWorkerUri: Uri.base.resolve('/drift_worker.js'),
      databaseName: _state.active,
    ).timeout(const Duration(seconds: 20));
    if (!_probe.availableStorages.contains(_storage)) {
      throw StateError('Dedicated IndexedDB storage unavailable');
    }
    if (saved != null) {
      final existing = await IndexedDbFileSystem.open(
        dbName: saved.active,
        writeAutomatically: false,
      );
      try {
        if (existing.xAccess('/database', 0) == 0) {
          throw StateError('Expected browser database is missing');
        }
      } finally {
        existing.close();
      }
    }
    db = await _open(_state.active);
    final journal = await db
        .customSelect('PRAGMA journal_mode=DELETE')
        .getSingle();
    if (journal.read<String>('journal_mode') != 'delete') {
      throw StateError('Unsupported browser journal mode');
    }
    await db.loadProfile();
    // Record the initial pointer only after the database has been persisted.
    if (saved == null || saved.restored) {
      await _store.write((
        active: _state.active,
        rollback: _state.rollback,
        restored: false,
      ));
    }
    _initialized = true;
    unawaited(_requestPersistence());
    return (
      db: db,
      outcome: saved?.restored == true
          ? RestoreOutcome.restored
          : RestoreOutcome.none,
    );
  } on AnotherHadgalyTab {
    throw const StorageStartupError(
      'Хадгалъя өөр таб эсвэл цонхонд нээлттэй байна. Түүнийг хаагаад энэ хуудсыг дахин ачаална уу.',
    );
  } catch (_) {
    await db?.close();
    throw const StorageStartupError(
      'Браузерын өгөгдлийг нээж чадсангүй. Хувийн горимоос гарч, хадгалах зай болон сайтын зөвшөөрлийг шалгаад дахин ачаална уу. Өгөгдлөө бүү цэвэрлээрэй.',
    );
  }
}

Future<void> _requestPersistence() async {
  try {
    final storage = web.window.navigator.storage;
    _persistent =
        (await storage.persisted().toDart).toDart ||
        (await storage.persist().toDart).toDart;
  } catch (_) {
    // Settings displays the conservative warning when the API is unavailable.
  }
}

Future<AppDatabase> _open(String name, {Uint8List? initial}) async =>
    AppDatabase(
      await _probe
          .open(
            _storage,
            name,
            initializeDatabase: initial == null
                ? null
                : () => Uint8List.fromList(initial),
          )
          .timeout(const Duration(seconds: 20)),
    );

Future<Uint8List> _readImage(String name) async {
  final vfs = await IndexedDbFileSystem.open(
    dbName: name,
    writeAutomatically: false,
  );
  try {
    if (vfs.xAccess('/database', 0) == 0 ||
        vfs.xAccess('/database-journal', 0) != 0 ||
        vfs.xAccess('/database-wal', 0) != 0) {
      throw StateError('Expected a standalone committed browser database');
    }
    final file = vfs.xOpen(Sqlite3Filename('/database'), 0).file;
    try {
      final size = file.xFileSize();
      if (size == 0 || size > _imageLimit) {
        throw const FormatException('Browser backup size outside limits');
      }
      final bytes = Uint8List(size);
      file.xRead(bytes, 0);
      return bytes;
    } finally {
      file.xClose();
    }
  } finally {
    vfs.close();
  }
}

Future<bool> exportBackup(AppDatabase db) async {
  // Drift waits for the IndexedDB flush at commit. No other tab can write and
  // exclusively prevents local transactions while reading the DELETE-mode image.
  final image = await db.exclusively(() async {
    final mode = await db.customSelect('PRAGMA journal_mode').getSingle();
    if (mode.read<String>('journal_mode') != 'delete') {
      throw StateError('Expected DELETE journal mode');
    }
    return _readImage(_state.active);
  });
  await _verify(image);
  _download(image, 'Hadgaly.hadgaly');
  return true;
}

Future<void> exportRollback() async {
  final image = await _readImage(_state.rollback!);
  await _verify(image);
  _download(image, 'Hadgaly-previous.hadgaly');
}

Future<bool> importBackup(AppDatabase db, ConfirmBackup confirm) async {
  final backup = await _pick();
  if (backup == null) return false;
  final image = _decode(backup);
  if (!await confirm(await _verify(image))) return false;

  final random = Random.secure();
  final suffix = List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  final name = '$firstDatabase-$suffix';
  final staged = await _open(name, initial: image);
  try {
    await staged.customSelect('SELECT 1').get();
  } finally {
    await staged.close();
  }
  final persisted = await _readImage(name);
  await _verify(persisted);
  if (!_equal(sha256.convert(image).bytes, sha256.convert(persisted).bytes)) {
    throw StateError('Persisted candidate differs from the verified backup');
  }

  // This single IndexedDB commit is the only publication step. The active
  // database has never been modified. The previous generation remains readable.
  await _store.write((active: name, rollback: _state.active, restored: true));
  return true;
}

Future<void> restartForRestore() async => web.window.location.reload();

Future<BackupPreview> _verify(Uint8List image) async {
  if (image.length < 100 ||
      image.length > _imageLimit ||
      !_equal(
        Uint8List.sublistView(image, 0, 16),
        ascii.encode('SQLite format 3\x00'),
      ) ||
      image[18] != 1 ||
      image[19] != 1) {
    throw const FormatException('Expected standalone SQLite image');
  }

  final sqlite = await (_validator ??= WasmSqlite3.loadFromUrl(_wasmUri));
  final vfs = InMemoryFileSystem();
  sqlite.registerVirtualFileSystem(vfs, makeDefault: true);
  try {
    final file = vfs
        .xOpen(Sqlite3Filename('/inspect'), SqlFlag.SQLITE_OPEN_CREATE)
        .file;
    try {
      file.xWrite(image, 0);
    } finally {
      file.xClose();
    }
    final candidate = sqlite.open('/inspect', mode: OpenMode.readOnly);
    try {
      candidate.execute('PRAGMA trusted_schema=OFF');
      candidate.execute('PRAGMA query_only=ON');
      final trusted = sqlite.openInMemory();
      final schema = AppDatabase(WasmDatabase.opened(trusted));
      try {
        if (candidate.userVersion != schema.schemaVersion) {
          throw const FormatException('Unsupported database version');
        }
        await schema.customSelect('SELECT 1').get();
        validateBackupSchema(candidate, trusted);
        _validateExactIntegers(candidate);
      } finally {
        await schema.close();
      }
      final view = AppDatabase(
        WasmDatabase.opened(candidate, closeUnderlyingOnClose: false),
      );
      try {
        final snapshot = await AccountsRepository(view).readSnapshot();
        return (
          accounts: snapshot.accounts.length,
          entries: snapshot.entries.length,
          revisions:
              candidate
                      .select('SELECT count(*) FROM entry_revisions')
                      .single
                      .values
                      .single
                  as int,
          adjustments: snapshot.accounts.fold(
            0,
            (count, row) => count + row.adjustments.length,
          ),
          audits:
              candidate
                      .select('SELECT count(*) FROM adjustment_edits')
                      .single
                      .values
                      .single
                  as int,
          balance: snapshot.accounts.fold(
            BigInt.zero,
            (total, row) => total + BigInt.from(row.balance),
          ),
        );
      } finally {
        await view.close();
      }
    } finally {
      candidate.close();
    }
  } finally {
    sqlite.unregisterVirtualFileSystem(vfs);
  }
}

void _validateExactIntegers(CommonDatabase database) {
  // Schema verification has already restricted table/column names to v4.
  for (final row in database.select(
    "SELECT name FROM sqlite_schema WHERE type='table'",
  )) {
    final table = row['name'] as String;
    final columns = table == 'sqlite_sequence'
        ? ['seq']
        : [
            for (final column in database.select('PRAGMA table_info("$table")'))
              if (column['type'] == 'INTEGER') column['name'] as String,
          ];
    for (final column in columns) {
      if (database
          .select(
            'SELECT 1 FROM "$table" WHERE "$column" IS NOT NULL AND '
            '(typeof("$column") != \'integer\' OR "$column" NOT BETWEEN '
            '-9007199254740991 AND 9007199254740991) LIMIT 1',
          )
          .isNotEmpty) {
        throw const FormatException(
          'An integer is outside the exact browser range',
        );
      }
    }
  }
}

Uint8List _decode(Uint8List backup) {
  if (backup.length <= _headerSize ||
      backup.length > _imageLimit + _headerSize ||
      !_equal(Uint8List.sublistView(backup, 0, 8), _magic)) {
    throw const FormatException('Unsupported Hadgaly backup');
  }
  final payload = Uint8List.sublistView(backup, _headerSize);
  if (!_equal(
    Uint8List.sublistView(backup, 8, _headerSize),
    sha256.convert(payload).bytes,
  )) {
    throw const FormatException('Backup checksum mismatch');
  }
  return payload;
}

bool _equal(List<int> first, List<int> second) {
  if (first.length != second.length) return false;
  for (var i = 0; i < first.length; i++) {
    if (first[i] != second[i]) return false;
  }
  return true;
}

Future<Uint8List?> _pick() async {
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = '.hadgaly,application/octet-stream'
    ..style.display = 'none';
  final selected = Completer<web.File?>();
  input.onchange = ((web.Event _) => selected.complete(
    input.files?.item(0),
  )).toJS;
  input.oncancel = ((web.Event _) => selected.complete(null)).toJS;
  web.document.body!.append(input);
  try {
    input.click();
    final file = await selected.future;
    if (file == null) return null;
    if (file.size > _imageLimit + _headerSize) {
      throw const FormatException('Backup exceeds the file size limit');
    }
    return (await file.arrayBuffer().toDart).toDart.asUint8List();
  } finally {
    input.remove();
  }
}

void _download(Uint8List image, String name) {
  final blob = web.Blob(
    [
      Uint8List.fromList(_magic).toJS,
      Uint8List.fromList(sha256.convert(image).bytes).toJS,
      image.toJS,
    ].toJS,
    web.BlobPropertyBag(type: 'application/octet-stream'),
  );
  final url = web.URL.createObjectURL(blob);
  final link = web.HTMLAnchorElement()
    ..href = url
    ..download = name;
  web.document.body!.append(link);
  link.click();
  link.remove();
  Timer(const Duration(minutes: 1), () => web.URL.revokeObjectURL(url));
}
