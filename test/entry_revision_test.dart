import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/transactions/data/transactions_repository.dart';

void main() {
  late AppDatabase db;
  late AccountsRepository accounts;
  late TransactionsRepository repo;
  late DateTime clock;
  late int income, expense;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 11, 3, 12);
    accounts = AccountsRepository(
      db,
      clock: () => clock.toUtc().microsecondsSinceEpoch,
    );
    repo = TransactionsRepository(db, clock: () => clock);
    await db.loadProfile();
    await db.createFirstAccount('Тест', 'Хэтэвч', '1000');
    await db.completeOnboarding();
    final cats = await db.select(db.categories).get();
    income = cats.firstWhere((c) => c.kind == 'income').id;
    expense = cats.firstWhere((c) => c.kind == 'expense').id;
  });
  tearDown(() => db.close());
  Future<int> post(
    String key, {
    String amount = '200',
    EventKind kind = EventKind.income,
    DateTime? date,
    int account = 1,
  }) => repo.post(
    kind: kind,
    amount: amount,
    accountId: account,
    categoryId: kind == EventKind.income ? income : expense,
    date: date ?? clock,
    requestKey: key,
    note: 'Тэмдэглэл',
  );
  Future<void> edit(
    int id,
    String key, {
    String amount = '300',
    EventKind kind = EventKind.income,
    int account = 1,
    DateTime? date,
    int revision = 0,
    int? category,
  }) => repo.edit(
    id: id,
    expectedRevision: revision,
    kind: kind,
    amount: amount,
    accountId: account,
    categoryId: category ?? (kind == EventKind.income ? income : expense),
    date: date ?? clock,
    note: 'Шинэ тэмдэглэл',
    requestKey: key,
  );

  test('Concurrent different saves reject the stale revision and retain one winner', () async {
    final id = await post('race');
    final outcomes = await Future.wait([
      edit(
        id,
        'race-a',
        amount: '300',
      ).then((_) => true, onError: (_) => false),
      edit(
        id,
        'race-b',
        amount: '400',
      ).then((_) => true, onError: (_) => false),
    ]);
    expect(outcomes.where((ok) => ok), hasLength(1));
    expect(await db.select(db.entryRevisions).get(), hasLength(1));
    expect((await repo.load(id)).revision, 1);
    expect((await accounts.snapshot()).byId(1).balance, anyOf(1300, 1400));
  });
  test('Create/edit/delete changes current balance exactly once, originals immutable', () async {
    final id = await post('p');
    final original = (await db.select(db.cashEntries).get()).single.toJson();
    await Future.wait([edit(id, 'e'), edit(id, 'e')]);
    expect((await accounts.snapshot()).byId(1).balance, 1300);
    expect((await accounts.snapshot()).entries.single.amount, 300);
    expect((await repo.load(id)).revision, 1);
    await expectLater(edit(id, 'e', amount: '301'), throwsStateError);
    await Future.wait([
      repo.delete(id: id, expectedRevision: 1, requestKey: 'd'),
      repo.delete(id: id, expectedRevision: 1, requestKey: 'd'),
    ]);
    final s = await accounts.snapshot();
    expect(s.byId(1).balance, 1000);
    expect(s.entries, isEmpty);
    expect(s.byId(1).ledger.income, BigInt.zero);
    expect(await db.select(db.entryRevisions).get(), hasLength(2));
    expect((await db.select(db.cashEntries).get()).single.toJson(), original);
    await edit(id, 'e'); // committed retry never restores a deleted entry
    expect((await repo.load(id)).deleted, isTrue);
    expect(await post('p'), id);
    expect((await accounts.snapshot()).entries, isEmpty);
    await expectLater(edit(id, 'new', revision: 2), throwsFormatException);
  });
  test('Moving account/type/category/date updates both accounts and keeps global identity', () async {
    final card = await accounts.createAccount('Карт', '-500', 'card');
    await accounts.selectDefault(card);
    final id = await post('p');
    final old = (await repo.load(id)).entry;
    await edit(
      id,
      'move',
      account: card,
      amount: '200',
      kind: EventKind.expense,
    );
    var s = await accounts.snapshot();
    expect(s.byId(1).balance, 1000);
    expect(s.byId(card).balance, -700);
    expect(s.defaultId, card);
    expect(s.entries.single.id, id);
    expect(s.entries.single.effectiveAt, old.effectiveAt);
    expect(s.byId(card).ledger.expense, BigInt.from(200));
    expect(s.byId(1).ledger.income, BigInt.zero);
    await edit(
      id,
      'date',
      account: card,
      amount: '50',
      kind: EventKind.income,
      revision: 1,
      date: DateTime(2026, 11, 1),
    );
    s = await accounts.snapshot();
    expect(s.byId(card).balance, -450);
    expect(s.entries.single.entryDate, '2026-11-01');
    expect((await db.select(db.ledgerSequences).get()).single.kind, 'income');
    expect(await db.select(db.ledgerSequences).get(), hasLength(1));
  });
  test('Backdated edits/deletion change anchor difference, not target or observation', () async {
    final id = await post('earlier', date: DateTime(2026, 11, 1));
    final a = await accounts.adjustBalance(1, '900', 'a');
    final after = await post('after', kind: EventKind.expense, amount: '50');
    final auditBefore = (await db.select(db.balanceAdjustments).get()).single
        .toJson();
    await edit(id, 'e', amount: '100', date: DateTime(2026, 11, 1));
    var s = (await accounts.snapshot()).byId(1);
    expect(s.balance, 850);
    expect(s.adjustments.single.originalDifference, -300);
    expect(s.adjustments.single.point.difference, -200);
    await repo.delete(id: id, expectedRevision: 1, requestKey: 'd');
    s = (await accounts.snapshot()).byId(1);
    expect(s.balance, 850);
    expect(s.adjustments.single.point.difference, -100);
    await edit(
      after,
      'back',
      kind: EventKind.expense,
      amount: '50',
      date: DateTime(2026, 11, 2),
    );
    s = (await accounts.snapshot()).byId(1);
    expect(s.balance, 900);
    expect(s.adjustments.single.point.difference, -50);
    expect(
      (await db.select(db.balanceAdjustments).get()).single.toJson(),
      auditBefore,
    );
    await accounts.editAdjustment(a, '950', 0, 'edit-anchor');
    expect((await accounts.snapshot()).byId(1).balance, 950);
    expect((await db.select(db.adjustmentEdits).get()).single.oldTarget, 900);
  });
  test('Later anchor stays authoritative through type/date/account edits and deletion', () async {
    final id = await post('p', date: DateTime(2026, 11, 1));
    final a = await accounts.adjustBalance(1, '900', 'a');
    final b = await accounts.adjustBalance(1, '800', 'b');
    await edit(
      id,
      'type',
      amount: '200',
      kind: EventKind.expense,
      date: DateTime(2026, 11, 1),
    );
    await accounts.editAdjustment(a, '950', 0, 'ae');
    var s = (await accounts.snapshot()).byId(1);
    expect(s.balance, 800);
    expect(s.adjustments.first.record.id, b);
    expect(s.ledger.expense, BigInt.from(200));
    expect(s.ledger.income, BigInt.zero);
    await repo.delete(id: id, expectedRevision: 1, requestKey: 'd');
    expect((await accounts.snapshot()).byId(1).balance, 800);
  });
  test(
    'Editing date to today puts older entry AFTER same-time newer anchor',
    () async {
      final id = await post('p', date: DateTime(2026, 11, 1));
      final a = await accounts.adjustBalance(1, '900', 'a');
      await edit(id, 'to-today', amount: '200');
      final s = (await accounts.snapshot()).byId(1);
      expect(s.balance, 1100);
      expect(s.ledger.points.map((p) => p.event.sequence), [a, id]);
      expect(
        s.ledger.points.last.event.effectiveAt,
        s.ledger.points.first.event.effectiveAt + 1,
      );
    },
  );
  test('Archived original category retained, references survive type change and tombstone', () async {
    final id = await post('p');
    await repo.archiveCategory(income);
    await edit(id, 'retain');
    final another = await repo.saveCategory(
      kind: EventKind.income,
      name: 'Нэмэлт',
      icon: 'gift',
      requestKey: 'cat',
    );
    await repo.archiveCategory(another);
    await expectLater(
      edit(id, 'bad', revision: 1, category: another),
      throwsFormatException,
    );
    await edit(id, 'type', revision: 1, kind: EventKind.expense);
    await repo.delete(id: id, expectedRevision: 2, requestKey: 'd');
    expect((await db.select(db.cashEntries).get()).single.categoryId, income);
    expect(
      (await db.select(db.entryRevisions).get()).map((r) => r.categoryId),
      [income, expense, expense],
    );
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });
  test(
    'Invalid/stale/missing account edits and injected writes roll back fully',
    () async {
      final id = await post('p');
      for (final value in [
        '0',
        '-1',
        '1.2',
        '1000000000000',
        '9999999999999999999999999',
      ]) {
        await expectLater(
          edit(id, 'bad$value', amount: value),
          throwsFormatException,
        );
      }
      await expectLater(
        edit(id, 'missing', account: 999),
        throwsFormatException,
      );
      await expectLater(
        edit(id, 'future', date: clock.add(const Duration(days: 1))),
        throwsFormatException,
      );
      await expectLater(edit(id, 'stale', revision: 1), throwsFormatException);
      await db.customStatement(
        "CREATE TRIGGER fail_revision BEFORE INSERT ON entry_revisions BEGIN SELECT RAISE(ABORT,'test'); END",
      );
      await expectLater(edit(id, 'fail'), throwsA(anything));
      expect(await db.select(db.entryRevisions).get(), isEmpty);
      expect((await accounts.snapshot()).byId(1).balance, 1200);
    },
  );
  test('Cross-account overflow rejects BOTH changes including source hidden overflow', () async {
    final full = await accounts.createAccount('Дүүрэн', '999999999999', 'full');
    final id = await post('p');
    await expectLater(edit(id, 'bad', account: full), throwsFormatException);
    expect((await accounts.snapshot()).byId(1).balance, 1200);
    expect((await accounts.snapshot()).byId(full).balance, 999999999999);
    expect(await db.select(db.entryRevisions).get(), isEmpty);
    final zero = await accounts.createAccount('Тэг', '0', 'zero');
    final offset = await post(
      'offset',
      account: zero,
      kind: EventKind.expense,
      amount: '1',
    );
    await post('max', account: zero, amount: '999999999999');
    await post('plus', account: zero, amount: '1');
    await accounts.adjustBalance(zero, '0', 'anchor');
    await expectLater(
      repo.delete(
        id: offset,
        expectedRevision: 0,
        requestKey: 'delete-overflow',
      ),
      throwsFormatException,
    );
    await expectLater(
      edit(
        offset,
        'move-offset',
        kind: EventKind.expense,
        amount: '1',
        account: 1,
      ),
      throwsFormatException,
    );
    expect((await repo.load(offset)).deleted, isFalse);
    expect((await repo.load(offset)).revision, 0);
    expect((await accounts.snapshot()).byId(zero).balance, 0);
  });
  test('Revision snapshots are immutable; sequential/deleted guards reject invalid SQL', () async {
    final id = await post('p');
    await edit(id, 'e');
    for (final sql in [
      'UPDATE entry_revisions SET amount=1',
      'DELETE FROM entry_revisions',
      'UPDATE cash_entries SET amount=1',
      'DELETE FROM cash_entries',
      'DELETE FROM categories',
    ]) {
      await expectLater(db.customStatement(sql), throwsA(anything));
    }
    await expectLater(
      db.customStatement(
        "INSERT INTO entry_revisions(entry_id,revision,account_id,category_id,kind,amount,effective_at,entry_date,note,changed_at,request_key) VALUES($id,3,1,$income,'income',1,1,'2026-11-03','',1,'skip')",
      ),
      throwsA(anything),
    );
    await repo.delete(id: id, expectedRevision: 1, requestKey: 'd');
    await expectLater(
      repo.delete(id: id, expectedRevision: 0, requestKey: 'stale-delete'),
      throwsFormatException,
    );
    expect(await db.select(db.entryRevisions).get(), hasLength(2));
  });
  test('Database reopen preserves resolved edit/delete history and default account', () async {
    final dir = await Directory.systemTemp.createTemp('hadgaly-v4-');
    final file = File('${dir.path}/test.sqlite');
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    repo = TransactionsRepository(db, clock: () => clock);
    accounts = AccountsRepository(db);
    await db.loadProfile();
    await db.createFirstAccount('Тест', 'Хэтэвч', '1000');
    await db.completeOnboarding();
    final id = await post('p');
    await edit(id, 'e', amount: '500');
    final gone = await post('gone', kind: EventKind.expense);
    await repo.delete(id: gone, expectedRevision: 0, requestKey: 'd');
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    repo = TransactionsRepository(db);
    final s = await AccountsRepository(db).snapshot();
    expect(s.entries, hasLength(1));
    expect(s.entries.single.amount, 500);
    expect(s.defaultAccount.balance, 1500);
    expect((await db.loadProfile()).completed, isTrue);
    expect((await repo.load(gone)).deleted, isTrue);
    expect((await repo.load(id)).revision, 1);
    await db.close();
    await dir.delete(recursive: true);
    db = AppDatabase(NativeDatabase.memory());
  });
}
