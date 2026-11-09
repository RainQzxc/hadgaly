import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/backup/data/backup_service.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/transactions/data/transactions_repository.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import '../test/support/stage5_data.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const importBrowserFixture = bool.fromEnvironment('HADGALY_TEST_WEB_BACKUP');
  testWidgets('Android and browser backup exchange preserves the rich ledger', (
    _,
  ) async {
    final dir = await (await getTemporaryDirectory()).createTemp(
      'hadgaly-web-exchange-',
    );
    File file(String name) => File.fromUri(dir.uri.resolve(name));
    final service = BackupService(dir);
    final live = file('hadgaly.sqlite');
    final transfer = file('transfer.hadgaly');
    final candidate = file('candidate.sqlite');
    final clock = DateTime(2026, 11, 6, 12);
    try {
      final db = AppDatabase(NativeDatabase(live));
      try {
        final seeded = await seedStage5(db, clock);
        final transactions = TransactionsRepository(db, clock: () => clock);
        await transactions.delete(
          id: seeded.expense,
          expectedRevision: 0,
          requestKey: 'pwa-delete',
        );
        final accounts = AccountsRepository(db);
        final anchor = (await accounts.snapshot())
            .byId(1)
            .adjustments
            .single
            .record;
        await accounts.editAdjustment(
          anchor.id,
          '950',
          anchor.revision,
          'pwa-audit',
        );
        await service.export(db, file('export.sqlite'), transfer);
        binding.reportData = {
          'nativeBackup': base64Encode(await transfer.readAsBytes()),
        };
        if (importBrowserFixture) {
          final incoming = File.fromUri(
            (await getApplicationSupportDirectory()).uri.resolve(
              'synthetic-web-bridge.hadgaly',
            ),
          );
          await transfer.writeAsBytes(await incoming.readAsBytes());
          await incoming.delete();
          final preview = await service.inspect(transfer, candidate);
          expect(
            (
              preview.accounts,
              preview.entries,
              preview.revisions,
              preview.adjustments,
              preview.audits,
              preview.balance,
            ),
            (2, 4, 1, 1, 1, BigInt.from(425)),
          );
          await accounts.renameAccount(1, 'Сэргээхийн өмнө');
          await service.stage(candidate);
        }
      } finally {
        await db.close();
      }
      if (importBrowserFixture) {
        expect(await service.applyPending(), RestoreOutcome.restored);
        final restored = AppDatabase(NativeDatabase(live));
        final rollback = AppDatabase(
          NativeDatabase(file('restore-rollback.sqlite')),
        );
        try {
          final snapshot = await AccountsRepository(restored).snapshot();
          expect(snapshot.defaultId, 2);
          expect(snapshot.byId(1).balance, 950);
          expect(snapshot.byId(2).balance, -525);
          expect(
            snapshot.byId(1).adjustments.single.edits.single.newTarget,
            950,
          );
          expect(
            snapshot.categories.any((category) => category.archived),
            isTrue,
          );
          final revision =
              (await restored.select(restored.entryRevisions).get()).single;
          expect(
            (revision.revision, revision.deleted, revision.amount),
            (1, true, 50),
          );
          final previous = await AccountsRepository(rollback).snapshot();
          expect(previous.byId(1).account.name, 'Сэргээхийн өмнө');
          binding.reportData!['restoredBrowserLedger'] = true;
        } finally {
          await restored.close();
          await rollback.close();
        }
      }
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
