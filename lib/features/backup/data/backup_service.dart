import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../accounts/data/accounts_repository.dart';
import '../../onboarding/data/app_database.dart';
import 'backup_validation.dart';
import 'backup_types.dart';

export 'backup_types.dart';

const _maxImage = 64 * 1024 * 1024;
const _headerSize = 40;
final _magic = ascii.encode('HADGALY1');
const _pendingPrefix = 'restore-ready-';

class BackupService {
  BackupService(this.directory);
  final Directory directory;

  File _file(String name) => File.fromUri(directory.uri.resolve(name));

  Future<void> export(AppDatabase db, File image, File destination) async {
    await db.customStatement('VACUUM INTO ?', [image.path]);
    await Isolate.run(() async {
      final bytes = await _readBounded(image, _maxImage);
      final hash = sha256.convert(bytes);
      final output = await destination.open(mode: FileMode.write);
      try {
        await output.writeFrom(_magic);
        await output.writeFrom(hash.bytes);
        await output.writeFrom(bytes);
        await output.flush();
      } finally {
        await output.close();
      }
    });
  }

  Future<BackupPreview> inspect(File backup, File candidate) =>
      Isolate.run(() async {
        final bytes = await _readBounded(backup, _maxImage + _headerSize);
        if (bytes.length <= _headerSize ||
            !_equal(Uint8List.sublistView(bytes, 0, 8), _magic)) {
          throw const FormatException('Unsupported Hadgaly backup');
        }
        final payload = Uint8List.sublistView(bytes, _headerSize);
        if (!_equal(
          Uint8List.sublistView(bytes, 8, _headerSize),
          sha256.convert(payload).bytes,
        )) {
          throw const FormatException('Backup checksum mismatch');
        }
        await candidate.writeAsBytes(payload, flush: true);
        return _validate(candidate);
      });

  Future<void> stage(File candidate) async {
    await directory.create(recursive: true);
    final folder = directory;
    await Isolate.run(() async {
      final service = BackupService(folder);
      if ((await service._pending()).isNotEmpty) {
        throw StateError('A restore is already queued');
      }
      final bytes = await _readBounded(candidate, _maxImage);
      final digest = sha256.convert(bytes);
      final temp = service._file('restore-writing.tmp');
      await temp.writeAsBytes(bytes, flush: true);
      await temp.rename(service._file('$_pendingPrefix$digest.sqlite').path);
    });
  }

  Future<List<File>> _pending() async {
    if (!await directory.exists()) return [];
    final pattern = RegExp(r'^restore-ready-[a-f0-9]{64}\.sqlite$');
    return [
      await for (final entity in directory.list(followLinks: false))
        if (entity is File && pattern.hasMatch(entity.uri.pathSegments.last))
          entity,
    ];
  }

  // Called before the first Drift connection on a fresh app engine.
  Future<RestoreOutcome> applyPending() {
    final folder = directory;
    return Isolate.run(() => BackupService(folder)._applyPending());
  }

  Future<RestoreOutcome> _applyPending() async {
    final writing = _file('restore-writing.tmp');
    if (await writing.exists()) await writing.delete();
    final pending = await _pending();
    if (pending.isEmpty) return RestoreOutcome.none;
    final rollback = _file('restore-rollback.sqlite');
    final temp = _file('restore-rollback.tmp');
    try {
      final candidate = pending.single;
      final name = candidate.uri.pathSegments.last;
      final hash = sha256.convert(await _readBounded(candidate, _maxImage));
      if (name != '$_pendingPrefix$hash.sqlite') {
        throw const FormatException('Staged checksum mismatch');
      }
      await _validate(candidate);
      final live = _file('hadgaly.sqlite');
      if (await temp.exists()) await temp.delete();
      final old = sqlite3.open(live.path, mode: OpenMode.readWrite);
      try {
        old.execute('PRAGMA busy_timeout=2000');
        old.execute('VACUUM INTO ?', [temp.path]);
        final checkpoint = old.select('PRAGMA wal_checkpoint(TRUNCATE)').single;
        if (checkpoint['busy'] != 0 ||
            old.select('PRAGMA journal_mode=DELETE').single.values.single !=
                'delete') {
          throw StateError('Database is busy');
        }
      } finally {
        old.close();
      }
      // Validate and sync the rollback before replacing the live database.
      await _validate(temp);
      final handle = await temp.open(mode: FileMode.append);
      try {
        await handle.flush();
      } finally {
        await handle.close();
      }
      await temp.rename(rollback.path);
      for (final suffix in ['-wal', '-shm', '-journal']) {
        if (await File(live.path + suffix).exists()) {
          throw StateError('Unexpected SQLite sidecar');
        }
      }
      await candidate.rename(live.path);
      return RestoreOutcome.restored;
    } catch (_) {
      // This happens before the atomic replacement. Never discard the live file.
      for (final file in pending) {
        await file.delete();
      }
      if (await temp.exists()) await temp.delete();
      return RestoreOutcome.rejected;
    }
  }

  Future<BackupPreview> _validate(File image) async {
    final handle = await image.open();
    try {
      final header = await handle.read(20);
      if (header.length < 20 ||
          !_equal(
            header.sublist(0, 16),
            ascii.encode('SQLite format 3\u0000'),
          ) ||
          header[18] != 1 ||
          header[19] != 1) {
        throw const FormatException('Expected standalone SQLite image');
      }
    } finally {
      await handle.close();
    }
    final native = sqlite3.open(image.path, mode: OpenMode.readOnly);
    AppDatabase? db;
    try {
      native.execute('PRAGMA trusted_schema=OFF');
      native.execute('PRAGMA query_only=ON');
      await validateBackupDatabase(native);
      db = AppDatabase(
        NativeDatabase.opened(native, closeUnderlyingOnClose: false),
      );
      if (native.userVersion != db.schemaVersion) {
        throw const FormatException('Unsupported schema version');
      }
      final snapshot = await AccountsRepository(db).readSnapshot();
      return (
        accounts: snapshot.accounts.length,
        entries: snapshot.entries.length,
        revisions:
            native
                    .select('SELECT count(*) FROM entry_revisions')
                    .single
                    .values
                    .single
                as int,
        adjustments: snapshot.accounts.fold(
          0,
          (n, a) => n + a.adjustments.length,
        ),
        audits:
            native
                    .select('SELECT count(*) FROM adjustment_edits')
                    .single
                    .values
                    .single
                as int,
        balance: snapshot.accounts.fold(
          BigInt.zero,
          (sum, a) => sum + BigInt.from(a.balance),
        ),
      );
    } finally {
      // A rejected image may fail before Drift opens the provided handle.
      await db?.close();
      // NativeDatabase.opened does not transfer ownership unless requested.
      native.close();
    }
  }
}

bool _equal(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

Future<Uint8List> _readBounded(File file, int max) async {
  final handle = await file.open();
  try {
    final length = await handle.length();
    if (length > max || length == 0) {
      throw const FormatException('Backup size outside limits');
    }
    final bytes = await handle.read(length);
    if (bytes.length != length || (await handle.read(1)).isNotEmpty) {
      throw const FormatException('Backup size changed during read');
    }
    return bytes;
  } finally {
    await handle.close();
  }
}
