import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  for (final completed in [true, false]) {
    testWidgets(
      'Preserved synthetic v1 ${completed ? 'completed' : 'partial'} fixture upgrades without data changes',
      (tester) async {
        final asset = completed
            ? 'test/fixtures/stage1_completed_v1.fixture'
            : 'test/fixtures/stage1_partial_v1.fixture';
        final bytes = await rootBundle.load(asset);
        final directory = await Directory.systemTemp.createTemp(
          'hadgaly-fixture-',
        );
        final file = File('${directory.path}/copy.sqlite');
        await file.writeAsBytes(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
          flush: true,
        );
        late List<Map<String, Object?>> originalAccounts, originalProfile;
        var db = AppDatabase(
          NativeDatabase(
            file,
            setup: (raw) {
              expect(
                raw.select('PRAGMA user_version').single['user_version'],
                1,
              );
              originalAccounts = raw
                  .select(
                    'SELECT id,name,opening_balance FROM accounts ORDER BY id',
                  )
                  .map((r) => Map<String, Object?>.from(r))
                  .toList();
              originalProfile = raw
                  .select('SELECT * FROM profiles ORDER BY id')
                  .map((r) => Map<String, Object?>.from(r))
                  .toList();
            },
          ),
        );
        try {
          final profile = await db.loadProfile();
          final accounts = await db
              .customSelect(
                'SELECT id,name,opening_balance FROM accounts ORDER BY id',
              )
              .get();
          final profiles = await db
              .customSelect('SELECT * FROM profiles ORDER BY id')
              .get();
          expect(accounts.map((r) => r.data).toList(), originalAccounts);
          expect(profiles.map((r) => r.data).toList(), originalProfile);
          expect(
            (await db.customSelect('PRAGMA user_version').getSingle())
                .read<int>('user_version'),
            2,
          );
          expect(
            await db.customSelect('PRAGMA foreign_key_check').get(),
            isEmpty,
          );
          expect(profile.completed, completed);
          expect(profile.step, completed ? 4 : 2);
          expect(profile.nickname, 'Туршилт');
          if (completed) {
            final s = await AccountsRepository(db).snapshot();
            expect(s.defaultId, 7);
            expect(s.accounts.map((a) => a.balance), [-123, 0]);
          } else {
            expect(profile.defaultAccountId, isNull);
            expect(profile.accountDraft, 'Тест: Дутуу');
            expect(profile.balanceDraft, '-');
          }
          await db.close();
          db = AppDatabase(NativeDatabase(file));
          expect((await db.loadProfile()).toJson(), profile.toJson());
          expect(
            (await db
                    .customSelect(
                      'SELECT id,name,opening_balance FROM accounts ORDER BY id',
                    )
                    .get())
                .map((r) => r.data)
                .toList(),
            originalAccounts,
          );
        } finally {
          await db.close();
        }
        // The preserved host fixture stays unchanged. The copied device file is
        // disposable and may be removed by sandbox package cleanup after assertions.
      },
    );
  }
}
