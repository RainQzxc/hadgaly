import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/core/domain/money.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/transactions/data/transactions_repository.dart';

void main() {
  late AppDatabase db;
  late AccountsRepository accounts;
  late TransactionsRepository entries;
  late DateTime clock;
  late int income, expense;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 11, 3, 12);
    accounts = AccountsRepository(
      db,
      clock: () => clock.toUtc().microsecondsSinceEpoch,
    );
    entries = TransactionsRepository(db, clock: () => clock);
    await db.loadProfile();
    await db.createFirstAccount('Туршилт', 'Хэтэвч', '1000');
    await db.completeOnboarding();
    final categories = await db.select(db.categories).get();
    income = categories.firstWhere((c) => c.kind == 'income').id;
    expense = categories.firstWhere((c) => c.kind == 'expense').id;
  });
  tearDown(() => db.close());
  Future<int> post(
    String key, {
    EventKind kind = EventKind.income,
    String amount = '200',
    int account = 1,
    DateTime? date,
    int? category,
  }) => entries.post(
    kind: kind,
    amount: amount,
    accountId: account,
    categoryId: category ?? (kind == EventKind.income ? income : expense),
    date: date ?? clock,
    requestKey: key,
    note: ' Тэмдэглэл ',
  );

  test(
    'Posting across opening zero/negative accounts, default and flow totals',
    () async {
      final zero = await accounts.createAccount('Карт', '0', 'zero');
      final negative = await accounts.createAccount('Өр', '-500', 'negative');
      await accounts.selectDefault(negative);
      await post('income');
      await post('expense', kind: EventKind.expense, amount: '300');
      await post('zero', kind: EventKind.expense, amount: '50', account: zero);
      await post('negative', account: negative);
      final s = await accounts.snapshot();
      expect(s.byId(1).balance, 900);
      expect(s.byId(zero).balance, -50);
      expect(s.defaultId, negative);
      expect(s.defaultAccount.balance, -300);
      expect(s.byId(1).ledger.income, BigInt.from(200));
      expect(s.byId(1).ledger.expense, BigInt.from(300));
      expect(s.entries.first.note, 'Тэмдэглэл');
    },
  );
  test('Backdated entries recalculate differences; edits preserve anchors and audits', () async {
    final a = await accounts.adjustBalance(1, '900', 'a');
    await post('later', kind: EventKind.expense, amount: '50');
    await post('earlier', date: DateTime(2026, 11, 2));
    var view = (await accounts.snapshot()).byId(1);
    expect(view.balance, 850);
    expect(view.adjustments.single.originalDifference, -100);
    expect(view.adjustments.single.point.difference, -300);
    await accounts.editAdjustment(a, '950', 0, 'edit');
    view = (await accounts.snapshot()).byId(1);
    expect(view.balance, 900);
    expect(
      view.adjustments.single.record.effectiveAt,
      clock.toUtc().microsecondsSinceEpoch,
    );
    expect(view.adjustments.single.edits.single.oldTarget, 900);
    expect(view.adjustments.single.edits.single.newTarget, 950);
    final b = await accounts.adjustBalance(1, '800', 'b');
    await post(
      'earlier-expense',
      kind: EventKind.expense,
      amount: '40',
      date: DateTime(2026, 11, 1),
    );
    await accounts.editAdjustment(a, '975', 1, 'edit2');
    view = (await accounts.snapshot()).byId(1);
    expect(view.balance, 800);
    expect(view.adjustments.first.record.id, b);
    expect(view.adjustments.first.record.target, 800);
    expect(view.ledger.income, BigInt.from(200));
    expect(view.ledger.expense, BigInt.from(90));
    expect(view.ledger.netCashFlow, BigInt.from(110));
  });
  test('Same-time global order interleaves both kinds and anchors; rollback clock clamps', () async {
    final a = await accounts.adjustBalance(1, '900', 'a');
    final i = await post('i');
    final b = await accounts.adjustBalance(1, '800', 'b');
    clock = clock.subtract(const Duration(seconds: 1));
    final e = await post('e', kind: EventKind.expense, amount: '50');
    final ledger = (await accounts.snapshot()).byId(1).ledger;
    expect(ledger.points.map((p) => p.event.sequence), [a, i, b, e]);
    expect(ledger.points.map((p) => p.event.effectiveAt).toSet(), hasLength(1));
    expect(ledger.balance, 750);
    expect(
      (await db.select(db.cashEntries).get()).last.createdAt,
      lessThan(ledger.points.last.event.effectiveAt),
    );
  });
  test(
    'Concurrent duplicate retry is one posting, mismatched key rejected',
    () async {
      final ids = await Future.wait([post('same'), post('same')]);
      expect(ids[0], ids[1]);
      expect(await db.select(db.cashEntries).get(), hasLength(1));
      expect(await db.select(db.ledgerSequences).get(), hasLength(1));
      expect((await accounts.snapshot()).byId(1).balance, 1200);
      await expectLater(post('same', amount: '201'), throwsStateError);
    },
  );
  test(
    'Category edits/archive preserve posted history and idempotent retries',
    () async {
      final id = await entries.saveCategory(
        kind: EventKind.income,
        name: ' Хувийн ',
        icon: 'gift',
        requestKey: 'cat',
      );
      expect(
        await entries.saveCategory(
          kind: EventKind.income,
          name: 'Хувийн',
          icon: 'gift',
          requestKey: 'cat',
        ),
        id,
      );
      await post('custom', category: id);
      await entries.saveCategory(
        id: id,
        kind: EventKind.income,
        name: 'Шинэ нэр',
        icon: 'book',
        requestKey: 'edit-cat',
      );
      await entries.archiveCategory(id);
      await entries.archiveCategory(id);
      expect(await post('custom', category: id), isPositive);
      await expectLater(post('archived', category: id), throwsFormatException);
      await expectLater(
        post('wrong-kind', category: expense),
        throwsFormatException,
      );
      final row = (await db.select(db.categories).get()).singleWhere(
        (c) => c.id == id,
      );
      expect(row.archived, isTrue);
      expect(row.name, 'Шинэ нэр');
      expect(row.icon, 'book');
      expect((await db.select(db.cashEntries).get()).single.categoryId, id);
      await expectLater(
        db.customStatement('DELETE FROM categories WHERE id=$id'),
        throwsA(anything),
      );
      await expectLater(
        entries.saveCategory(
          kind: EventKind.income,
          name: ' цалин ',
          icon: 'gift',
          requestKey: 'duplicate',
        ),
        throwsFormatException,
      );
      await expectLater(
        entries.saveCategory(
          id: id,
          kind: EventKind.expense,
          name: 'Шинэ',
          icon: 'gift',
          requestKey: 'type',
        ),
        throwsFormatException,
      );
    },
  );
  test('Invalid amount/date/account/note never allocates a sequence', () async {
    for (final amount in [
      '0',
      '-1',
      '1.2',
      '1000000000000',
      '999999999999999999999999999',
    ]) {
      await expectLater(
        post('bad-$amount', amount: amount),
        throwsFormatException,
      );
    }
    await expectLater(
      post('future', date: clock.add(const Duration(days: 1))),
      throwsFormatException,
    );
    await expectLater(post('missing', account: 999), throwsFormatException);
    await expectLater(
      entries.post(
        kind: EventKind.income,
        amount: '1',
        accountId: 1,
        categoryId: income,
        date: clock,
        note: 'x' * 501,
        requestKey: 'note',
      ),
      throwsFormatException,
    );
    expect(await db.select(db.ledgerSequences).get(), isEmpty);
    expect(await db.select(db.cashEntries).get(), isEmpty);
  });
  test(
    'Overflow before a later anchor rolls back insert and allocated sequence',
    () async {
      final max = await accounts.createAccount('Хязгаар', '$maxMnt', 'max');
      await accounts.adjustBalance(max, '0', 'anchor');
      final count = (await db.select(db.ledgerSequences).get()).length;
      await expectLater(
        post(
          'overflow',
          account: max,
          amount: '1',
          date: DateTime(2026, 11, 2),
        ),
        throwsFormatException,
      );
      expect(await db.select(db.cashEntries).get(), isEmpty);
      expect(await db.select(db.ledgerSequences).get(), hasLength(count));
      expect((await accounts.snapshot()).byId(max).balance, 0);
      await post('valid', account: max, amount: '1');
      expect((await accounts.snapshot()).byId(max).balance, 1);
    },
  );
  test(
    'Injected database failure and anchor-edit overflow roll back atomically',
    () async {
      await db.customStatement(
        "CREATE TRIGGER fail_post BEFORE INSERT ON cash_entries BEGIN SELECT RAISE(ABORT,'test'); END",
      );
      await expectLater(post('failed'), throwsA(anything));
      expect(await db.select(db.ledgerSequences).get(), isEmpty);
      await db.customStatement('DROP TRIGGER fail_post');
      final anchor = await accounts.adjustBalance(1, '0', 'a');
      await post('large', amount: '$maxMnt');
      await expectLater(
        accounts.editAdjustment(anchor, '1', 0, 'bad-edit'),
        throwsFormatException,
      );
      expect(await db.select(db.adjustmentEdits).get(), isEmpty);
      expect(
        (await accounts.snapshot()).byId(1).adjustments.single.record.target,
        0,
      );
    },
  );
  test(
    'Database reopen retains entries, category archive, default and balances',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'hadgaly-stage3-',
      );
      final file = File('${directory.path}/test.sqlite');
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      await db.loadProfile();
      await db.createFirstAccount('Туршилт', 'Хэтэвч', '0');
      await db.completeOnboarding();
      accounts = AccountsRepository(db);
      entries = TransactionsRepository(db, clock: () => clock);
      await post('disk');
      await entries.archiveCategory(income);
      final second = await accounts.createAccount('Карт', '-100', 'card');
      await accounts.selectDefault(second);
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      final s = await AccountsRepository(db).snapshot();
      expect(s.byId(1).balance, 200);
      expect(s.defaultId, second);
      expect(s.defaultAccount.balance, -100);
      expect(s.entries.single.note, 'Тэмдэглэл');
      expect((await db.loadProfile()).completed, isTrue);
      expect(
        (await db.select(db.categories).get())
            .singleWhere((c) => c.id == income)
            .archived,
        isTrue,
      );
      await db.close();
      await directory.delete(recursive: true);
      db = AppDatabase(NativeDatabase.memory());
    },
  );
}
