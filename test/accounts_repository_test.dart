import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';

void main() {
  late AppDatabase db;
  late AccountsRepository repo;
  var clock = 100;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = 100;
    repo = AccountsRepository(db, clock: () => clock);
    await db.loadProfile();
    await db.createFirstAccount('Өнөр', 'Хэтэвч', '1000');
    await db.completeOnboarding();
  });
  tearDown(() => db.close());

  test('Multiple account zero/negative/opening and default; rename preserves balance', () async {
    final a = await repo.createAccount('Карт', '0', 'zero');
    final b = await repo.createAccount('Зээл', '-500', 'negative');
    expect((await repo.snapshot()).accounts.map((a) => a.balance), [
      1000,
      0,
      -500,
    ]);
    await repo.selectDefault(b);
    await repo.renameAccount(b, 'Өртэй карт');
    final s = await repo.snapshot();
    expect(s.defaultAccount.account.id, b);
    expect(s.defaultAccount.balance, -500);
    expect(s.defaultAccount.account.name, 'Өртэй карт');
    expect(s.byId(a).balance, 0);
    await expectLater(repo.selectDefault(999), throwsFormatException);
    await expectLater(repo.renameAccount(a, ' '), throwsFormatException);
  });
  test(
    'Create requests and adjustments are durable idempotent operations',
    () async {
      await Future.wait([
        repo.createAccount('Карт', '0', 'c1'),
        repo.createAccount('Карт', '0', 'c1'),
      ]);
      await Future.wait([
        repo.adjustBalance(1, '900', 'a1'),
        repo.adjustBalance(1, '900', 'a1'),
      ]);
      final s = await repo.snapshot();
      expect(s.accounts, hasLength(2));
      expect(s.byId(1).adjustments, hasLength(1));
      await expectLater(repo.adjustBalance(1, '901', 'a1'), throwsStateError);
      await expectLater(
        repo.createAccount('Карт', '1', 'c1'),
        throwsStateError,
      );
    },
  );
  test('Same instant anchors preserve sequence; edit keeps later target and original evidence', () async {
    final a = await repo.adjustBalance(1, '900', 'a');
    final b = await repo.adjustBalance(1, '800', 'b');
    await repo.editAdjustment(a, '950', 0, 'edit-a');
    final s = (await repo.snapshot()).byId(1);
    expect(s.balance, 800);
    expect(s.ledger.points.map((p) => p.event.sequence), [a, b]);
    final av = s.adjustments.singleWhere((r) => r.record.id == a);
    final bv = s.adjustments.singleWhere((r) => r.record.id == b);
    expect(av.record.effectiveAt, 100);
    expect(av.record.revision, 1);
    expect(av.originalDifference, -100);
    expect(av.point.difference, -50);
    expect(bv.record.target, 800);
    expect(bv.point.difference, -150);
    expect(bv.originalDifference, -100);
    expect(av.edits.single.oldTarget, 900);
    expect(av.edits.single.newTarget, 950);
    expect(av.edits.single.editedAt, 100);
  });
  test('Clock rollback uses stable current anchor ordering and stores observation time', () async {
    await repo.adjustBalance(1, '900', 'first');
    clock = 50;
    await repo.adjustBalance(1, '700', 'second');
    final s = (await repo.snapshot()).byId(1);
    expect(s.balance, 700);
    expect(s.adjustments.first.record.effectiveAt, 100);
    expect(s.adjustments.first.record.createdAt, 50);
  });
  test(
    'Multiple edits audit history, stale rejection, retry and unchanged no-op',
    () async {
      final a = await repo.adjustBalance(1, '900', 'a');
      clock = 200;
      await Future.wait([
        repo.editAdjustment(a, '800', 0, 'edit1'),
        repo.editAdjustment(a, '800', 0, 'edit1'),
      ]);
      await expectLater(
        repo.editAdjustment(a, '700', 0, 'stale'),
        throwsFormatException,
      );
      await repo.editAdjustment(a, '800', 1, 'same');
      clock = 300;
      await repo.editAdjustment(a, '750', 1, 'edit2');
      final v = (await repo.snapshot()).byId(1).adjustments.single;
      expect(v.record.target, 750);
      expect(v.record.effectiveAt, 100);
      expect(v.edits.map((e) => e.oldTarget), [900, 800]);
      expect(v.edits.map((e) => e.newTarget), [800, 750]);
      expect(v.edits.map((e) => e.editedAt), [200, 300]);
      await repo.editAdjustment(a, '800', 0, 'edit1');
      expect((await repo.snapshot()).byId(1).balance, 750);
    },
  );
  for (final failure in ['audit', 'target']) {
    test('Atomic edit rollback when $failure write fails', () async {
      final a = await repo.adjustBalance(1, '900', 'a');
      await db.customStatement(
        failure == 'audit'
            ? "CREATE TRIGGER fail_edit BEFORE INSERT ON adjustment_edits BEGIN SELECT RAISE(ABORT,'injected'); END"
            : "CREATE TRIGGER fail_target BEFORE UPDATE ON balance_adjustments BEGIN SELECT RAISE(ABORT,'injected'); END",
      );
      await expectLater(
        repo.editAdjustment(a, '800', 0, 'edit'),
        throwsA(anything),
      );
      final v = (await repo.snapshot()).byId(1).adjustments.single;
      expect(v.record.target, 900);
      expect(v.record.revision, 0);
      expect(v.edits, isEmpty);
    });
  }
  test(
    'Atomic creation failure and SQL audit/observation/deletion guards',
    () async {
      await db.customStatement(
        "CREATE TRIGGER fail_add BEFORE INSERT ON balance_adjustments BEGIN SELECT RAISE(ABORT,'injected'); END",
      );
      await expectLater(repo.adjustBalance(1, '800', 'a'), throwsA(anything));
      expect((await repo.snapshot()).byId(1).balance, 1000);
      await db.customStatement('DROP TRIGGER fail_add');
      final a = await repo.adjustBalance(1, '900', 'a');
      await expectLater(
        db.customStatement('UPDATE balance_adjustments SET effective_at=10'),
        throwsA(anything),
      );
      await expectLater(
        db.customStatement('UPDATE balance_adjustments SET target=800'),
        throwsA(anything),
      );
      await expectLater(
        db.customStatement('DELETE FROM balance_adjustments'),
        throwsA(anything),
      );
      await repo.editAdjustment(a, '800', 0, 'edit');
      await expectLater(
        db.customStatement('UPDATE adjustment_edits SET old_target=0'),
        throwsA(anything),
      );
      await expectLater(
        db.customStatement('DELETE FROM adjustment_edits'),
        throwsA(anything),
      );
    },
  );
  test('Adjustment has zero income/expense/net totals', () async {
    await repo.adjustBalance(1, '-500', 'a');
    final l = (await repo.snapshot()).byId(1).ledger;
    expect(l.income, BigInt.zero);
    expect(l.expense, BigInt.zero);
    expect(l.netCashFlow, BigInt.zero);
  });
  test('Stream refreshes after default, rename, adjustment and edit', () async {
    final first = await repo.watch().first;
    expect(first.defaultAccount.balance, 1000);
    final second = await repo.createAccount('Карт', '0', 'card');
    final changed = repo.watch().firstWhere((s) => s.defaultId == second);
    await repo.selectDefault(second);
    expect((await changed).defaultAccount.balance, 0);
    final adjusted = repo.watch().firstWhere(
      (s) => s.defaultAccount.balance == 450,
    );
    await repo.adjustBalance(second, '450', 'adjust');
    expect((await adjusted).defaultAccount.balance, 450);
  });
  test(
    'File reopen retains accounts, default, adjustments and audit',
    () async {
      await db.close();
      final dir = await Directory.systemTemp.createTemp('hadgaly-stage2-');
      final file = File('${dir.path}/test.sqlite');
      db = AppDatabase(NativeDatabase(file));
      repo = AccountsRepository(db, clock: () => 100);
      try {
        await db.loadProfile();
        await db.createFirstAccount('Болд', 'Бэлэн', '0');
        await db.completeOnboarding();
        final id = await repo.createAccount('Карт', '-100', 'c');
        await repo.selectDefault(id);
        final a = await repo.adjustBalance(id, '200', 'a');
        await repo.editAdjustment(a, '250', 0, 'e');
        await db.close();
        db = AppDatabase(NativeDatabase(file));
        repo = AccountsRepository(db);
        final s = await repo.snapshot();
        expect(s.defaultId, id);
        expect(s.defaultAccount.balance, 250);
        expect(s.defaultAccount.adjustments.single.originalDifference, 300);
        expect(s.defaultAccount.adjustments.single.edits.single.oldTarget, 200);
      } finally {
        await db.close();
        await dir.delete(recursive: true);
      }
    },
  );
  for (final completed in [false, true]) {
    test(
      'v1 migration preserves ${completed ? 'completed' : 'partial'} Stage 1 data',
      () async {
        await db.close();
        final schema = File('test/fixtures/stage1_v1.sql').readAsStringSync();
        db = AppDatabase(
          NativeDatabase.memory(
            setup: (raw) {
              raw.execute(schema);
              if (completed) {
                raw.execute(
                  "INSERT INTO accounts(id,name,opening_balance) VALUES(7,'Хуучин данс',-123)",
                );
                raw.execute(
                  "INSERT INTO profiles(id,nickname,step,completed,default_account_id) VALUES(1,'Өнөр',4,1,7)",
                );
              } else {
                raw.execute(
                  "INSERT INTO profiles(id,nickname,account_draft,balance_draft,step) VALUES(1,'Өнөр','Карт','-',2)",
                );
              }
            },
          ),
        );
        repo = AccountsRepository(db, clock: () => 100);
        final p = await db.loadProfile();
        expect(p.nickname, 'Өнөр');
        expect(p.completed, completed);
        if (completed) {
          expect(p.defaultAccountId, 7);
          expect((await repo.snapshot()).defaultAccount.balance, -123);
          await repo.adjustBalance(7, '0', 'new');
          expect((await repo.snapshot()).defaultAccount.balance, 0);
        } else {
          expect(p.step, 2);
          expect(p.accountDraft, 'Карт');
          expect(p.balanceDraft, '-');
          expect(await db.select(db.accounts).get(), isEmpty);
        }
        expect(
          await db.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
        expect(
          (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
            'user_version',
          ),
          2,
        );
      },
    );
  }
}
