import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/backup/data/backup_service.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/transactions/data/transactions_repository.dart';
import 'package:sqlite3/sqlite3.dart';

import 'support/stage5_data.dart';

void main() {
  late Directory work;
  late File live, image, backup, candidate;
  late BackupService service;
  File file(String name) => File.fromUri(work.uri.resolve(name));

  setUp(() async {
    work = await Directory.systemTemp.createTemp('hadgaly-safety-');
    live = file('hadgaly.sqlite');
    image = file('export.sqlite');
    backup = file('transfer.hadgaly');
    candidate = file('candidate.sqlite');
    service = BackupService(work);
  });
  tearDown(() => work.delete(recursive: true));

  test('WAL export, confirmation queue, cold restore and rollback preserve both versions', () async {
    final db = AppDatabase(NativeDatabase(live));
    await db.customStatement('PRAGMA journal_mode=WAL');
    final clock = DateTime(2026, 11, 6, 12);
    final seeded = await seedStage5(db, clock);
    await TransactionsRepository(
      db,
      clock: () => clock,
    ).delete(id: seeded.expense, expectedRevision: 0, requestKey: 's6-delete');
    final repo = AccountsRepository(db);
    final before = await repo.snapshot();
    final anchor = before.byId(1).adjustments.single.record;
    await repo.editAdjustment(anchor.id, '950', anchor.revision, 's6-edit');
    expect(await File('${live.path}-wal').length(), greaterThan(32));
    await service.export(db, image, backup);
    final preview = await service.inspect(backup, candidate);
    expect(preview.accounts, 2);
    expect(preview.entries, 4);
    expect(preview.revisions, 1);
    expect(preview.adjustments, 1);
    expect(preview.audits, 1);
    expect(preview.balance, BigInt.from(425));
    await repo.renameAccount(1, 'Дараагийн нэр');
    await repo.selectDefault(1);
    await service.stage(candidate);
    expect((await repo.snapshot()).defaultId, 1);
    await db.close();

    expect(await service.applyPending(), RestoreOutcome.restored);
    expect(await service.applyPending(), RestoreOutcome.none);
    final restored = AppDatabase(NativeDatabase(live));
    final rollback = AppDatabase(
      NativeDatabase(file('restore-rollback.sqlite')),
    );
    try {
      final snapshot = await AccountsRepository(restored).snapshot();
      expect(snapshot.defaultId, 2);
      expect(snapshot.byId(1).balance, 950);
      expect(snapshot.byId(2).balance, -525);
      expect(snapshot.byId(1).adjustments.single.edits.single.newTarget, 950);
      expect(snapshot.categories.any((c) => c.archived), isTrue);
      final version = await TransactionsRepository(restored)
          .load(seeded.expense);
      expect(version.deleted, isTrue);
      expect(version.revision, 1);
      expect(version.entry.amount, 50);
      final previous = await AccountsRepository(rollback).snapshot();
      expect(previous.defaultId, 1);
      expect(previous.byId(1).account.name, 'Дараагийн нэр');
    } finally {
      await restored.close();
      await rollback.close();
    }
  });

  test(
    'Checksum mismatch and unknown schema cannot affect live data',
    () async {
      final db = AppDatabase(NativeDatabase(live));
      await db.loadProfile();
      await service.export(db, image, backup);
      await db.close();
      final pristine = await live.readAsBytes();

      final corrupted = await backup.readAsBytes();
      corrupted[41] ^= 1;
      await backup.writeAsBytes(corrupted);
      await expectLater(
        service.inspect(backup, candidate),
        throwsFormatException,
      );

      final native = sqlite3.open(image.path);
      native.userVersion = 5;
      native.close();
      final payload = await image.readAsBytes();
      await backup.writeAsBytes([
        ...ascii.encode('HADGALY1'),
        ...sha256.convert(payload).bytes,
        ...payload,
      ]);
      await expectLater(
        service.inspect(backup, candidate),
        throwsFormatException,
      );
      expect(await live.readAsBytes(), pristine);
    },
  );

  test(
    'Corrupted pending image is rejected on startup, with live bytes untouched',
    () async {
      final db = AppDatabase(NativeDatabase(live));
      await db.loadProfile();
      await db.close();
      final original = await live.readAsBytes();
      await candidate.writeAsString('bad image');
      await service.stage(candidate);
      expect(await service.applyPending(), RestoreOutcome.rejected);
      expect(await service.applyPending(), RestoreOutcome.none);
      expect(await live.readAsBytes(), original);
      expect(await file('restore-rollback.sqlite').exists(), isFalse);
    },
  );

  test('Failure to publish rollback prevents replacement', () async {
    final db = AppDatabase(NativeDatabase(live));
    try {
      await db.loadProfile();
      await db.createFirstAccount('Нөөц', 'Данс', '120');
      await service.export(db, image, backup);
      await service.inspect(backup, candidate);
      await AccountsRepository(db).renameAccount(1, 'Одоогийн данс');
      await service.stage(candidate);
    } finally {
      await db.close();
    }
    await Directory(file('restore-rollback.sqlite').path).create();
    expect(await service.applyPending(), RestoreOutcome.rejected);
    expect(await service.applyPending(), RestoreOutcome.none);
    final current = AppDatabase(NativeDatabase(live));
    try {
      expect(
        (await AccountsRepository(current).snapshot()).byId(1).account.name,
        'Одоогийн данс',
      );
    } finally {
      await current.close();
    }
  });

  for (final fixture in [
    'stage1_completed_v1',
    'stage1_partial_v1',
    'stage2_v2',
    'stage3_v3',
  ]) {
    test('Migrated fixture can be exported and verified: $fixture', () async {
      await File('test/fixtures/$fixture.fixture').copy(live.path);
      final db = AppDatabase(NativeDatabase(live));
      try {
        await db.loadProfile();
        await service.export(db, image, backup);
        final preview = await service.inspect(backup, candidate);
        expect(
          preview.accounts,
          (await AccountsRepository(db).snapshot()).accounts.length,
        );
      } finally {
        await db.close();
      }
    });
  }
}
