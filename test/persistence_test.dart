import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/onboarding/application/onboarding_controller.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('Fresh profile, no invented account', () async {
    final p = await db.loadProfile();
    expect(p.step, 0);
    expect(p.completed, false);
    expect(p.defaultAccountId, null);
    expect(await db.select(db.accounts).get(), isEmpty);
  });
  for (final balance in ['0', '120000', '-120000']) {
    test('Atomic first account $balance, default and completed', () async {
      await db.loadProfile();
      await db.createFirstAccount('Болд', 'Хэтэвч', balance);
      var p = await db.loadProfile();
      expect(p.step, 3);
      expect(p.completed, false);
      expect((await db.defaultAccount(p))!.openingBalance, int.parse(balance));
      await db.completeOnboarding();
      p = await db.loadProfile();
      expect(p.completed, true);
      expect(p.step, 4);
    });
  }
  test('Invalid input never creates account', () async {
    await db.loadProfile();
    await expectLater(
      db.createFirstAccount('Болд', ' ', '0'),
      throwsFormatException,
    );
    await expectLater(
      db.createFirstAccount(' ', 'Карт', '0'),
      throwsFormatException,
    );
    await expectLater(
      db.createFirstAccount('Болд', 'Карт', '1.1'),
      throwsFormatException,
    );
    expect(await db.select(db.accounts).get(), isEmpty);
    expect((await db.loadProfile()).completed, false);
  });
  test(
    'Write failure rolls back first account and default assignment',
    () async {
      await db.loadProfile();
      await db.customStatement(
        "CREATE TRIGGER fail_profile BEFORE UPDATE ON profiles BEGIN SELECT RAISE(ABORT, 'injected failure'); END",
      );
      await expectLater(
        db.createFirstAccount('Болд', 'Карт', '100'),
        throwsA(anything),
      );
      expect(await db.select(db.accounts).get(), isEmpty);
      expect((await db.loadProfile()).defaultAccountId, null);
      expect((await db.loadProfile()).completed, false);
    },
  );
  test('Cannot complete without account, including direct SQL', () async {
    await db.loadProfile();
    await expectLater(db.completeOnboarding(), throwsStateError);
    await expectLater(
      db.customStatement('UPDATE profiles SET completed = 1, step = 4'),
      throwsA(anything),
    );
    expect((await db.loadProfile()).completed, false);
  });
  test('Retries and double taps do not duplicate accounts', () async {
    await db.loadProfile();
    await Future.wait(
      List.generate(3, (_) => db.createFirstAccount('Болд', 'Карт', '0')),
    );
    expect(await db.select(db.accounts).get(), hasLength(1));
  });
  test('Foreign key prevents losing default account', () async {
    await db.loadProfile();
    await db.createFirstAccount('Болд', 'Карт', '0');
    await expectLater(db.delete(db.accounts).go(), throwsA(anything));
  });
  test(
    'Controller back navigation, interrupted drafts and double submission',
    () async {
      final c = OnboardingController(db);
      await c.ready;
      c.draft(name: 'Болд');
      await c.next();
      expect(c.step, 1);
      await c.next();
      expect(c.step, 2);
      c.draft(account: 'Карт', amount: '-');
      await c.back();
      expect(c.step, 1);
      await c.next();
      expect(c.balance, '-');
      c.draft(amount: '-50');
      await Future.wait([c.next(), c.next()]);
      expect(c.step, 3);
      expect(await db.select(db.accounts).get(), hasLength(1));
      c.dispose();
      final resumed = OnboardingController(db);
      await resumed.ready;
      expect(resumed.step, 3);
      expect(resumed.account!.openingBalance, -50);
      await resumed.next();
      expect(resumed.step, 4);
      resumed.dispose();
    },
  );
  test(
    'Real file close/reopen retains partial draft and completed state',
    () async {
      await db.close();
      final directory = await Directory.systemTemp.createTemp('hadgaly-test-');
      final file = File('${directory.path}/state.sqlite');
      var disk = AppDatabase(NativeDatabase(file));
      try {
        await disk.loadProfile();
        await disk.saveDraft('Болд', 'Кар', '-', 2);
        await disk.close();
        disk = AppDatabase(NativeDatabase(file));
        final p = await disk.loadProfile();
        expect(p.step, 2);
        expect(p.balanceDraft, '-');
        expect(p.accountDraft, 'Кар');
        await disk.createFirstAccount(p.nickname, 'Карт', '-250');
        await disk.completeOnboarding();
        await disk.close();
        disk = AppDatabase(NativeDatabase(file));
        final reopened = await disk.loadProfile();
        expect(reopened.completed, true);
        expect(reopened.step, 4);
        expect((await disk.defaultAccount(reopened))!.openingBalance, -250);
      } finally {
        await disk.close();
        await directory.delete(recursive: true);
      }
    },
  );
  test('Database rejects out-of-range integer directly', () async {
    await db.loadProfile();
    await expectLater(
      db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              name: 'Карт',
              openingBalance: 1000000000000,
            ),
          ),
      throwsA(anything),
    );
  });
}
