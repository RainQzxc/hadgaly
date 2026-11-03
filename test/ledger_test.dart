import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/core/domain/money.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';

LedgerEvent event(
  int seq,
  int time,
  EventKind kind,
  int amount, [
  int? observed,
]) => LedgerEvent(
  sequence: seq,
  effectiveAt: time,
  kind: kind,
  amount: amount,
  originalDifference: observed,
);
LedgerEvent income(int seq, int t, int n) => event(seq, t, EventKind.income, n);
LedgerEvent expense(int seq, int t, int n) =>
    event(seq, t, EventKind.expense, n);
LedgerEvent anchor(int seq, int t, int n, [int? observed]) =>
    event(seq, t, EventKind.adjustment, n, observed);

void main() {
  for (final opening in [0, 1000, -500]) {
    test('Opening baseline $opening', () {
      final r = replayLedger(opening, []);
      expect(r.balance, opening);
      expect(r.income, BigInt.zero);
      expect(r.expense, BigInt.zero);
      expect(r.netCashFlow, BigInt.zero);
    });
  }
  test('Single anchor overrides previous balance and excludes differences from totals', () {
    final r = replayLedger(1000, [
      income(1, 10, 200),
      anchor(2, 20, 900, -300),
    ]);
    expect(r.balance, 900);
    expect(r.points.last.difference, -300);
    expect(r.income, BigInt.from(200));
    expect(r.expense, BigInt.zero);
    expect(r.netCashFlow, BigInt.from(200));
  });
  for (final extra in [100, 50, 0]) {
    test(
      'Backdated income add/edit/delete $extra preserves anchor and observation',
      () {
        final r = replayLedger(1000, [
          income(1, 10, 200),
          if (extra > 0) income(3, 15, extra),
          anchor(2, 20, 900, -300),
        ]);
        expect(r.balance, 900);
        expect(r.points.last.difference, -300 - extra);
        expect(r.points.last.event.originalDifference, -300);
      },
    );
  }
  for (final extra in [100, 50, 0]) {
    test('Backdated expense add/edit/delete $extra before anchor', () {
      final r = replayLedger(1000, [
        if (extra > 0) expense(1, 10, extra),
        anchor(2, 20, 900, -100),
      ]);
      expect(r.balance, 900);
      expect(r.points.last.difference, -100 + extra);
      expect(r.points.last.event.originalDifference, -100);
    });
  }
  for (final amount in [50, 70, 0]) {
    test('Post-anchor expense add/edit/delete $amount', () {
      final r = replayLedger(1000, [
        anchor(1, 20, 900),
        if (amount > 0) expense(2, 30, amount),
      ]);
      expect(r.balance, 900 - amount);
      expect(r.points.first.after, 900);
    });
    test('Post-anchor income add/edit/delete $amount', () {
      final r = replayLedger(1000, [
        anchor(1, 20, 900),
        if (amount > 0) income(2, 30, amount),
      ]);
      expect(r.balance, 900 + amount);
    });
  }
  test(
    'Later authoritative anchor survives earlier correction and movements',
    () {
      List<LedgerEvent> chain(int a, int b) => [
        anchor(1, 20, a, -100),
        expense(2, 30, 50),
        anchor(3, 40, b, -50),
        income(4, 50, 70),
      ];
      final before = replayLedger(1000, chain(900, 800));
      final edited = replayLedger(1000, chain(950, 800));
      expect(before.balance, 870);
      expect(edited.balance, 870);
      expect(edited.points[2].after, 800);
      expect(edited.points[2].difference, -100);
      expect(edited.points[2].event.originalDifference, -50);
      expect(replayLedger(1000, chain(950, 750)).balance, 820);
      expect(edited.income, BigInt.from(70));
      expect(edited.expense, BigInt.from(50));
      expect(edited.netCashFlow, BigInt.from(20));
    },
  );
  test('Same timestamp uses sequence regardless input order', () {
    final fixtures = [
      income(1, 20, 200),
      anchor(2, 20, 900),
      expense(3, 20, 50),
      anchor(4, 20, 800),
    ];
    for (final list in [
      fixtures,
      fixtures.reversed.toList(),
      [fixtures[2], fixtures[0], fixtures[3], fixtures[1]],
    ]) {
      final r = replayLedger(1000, list);
      expect(r.points.map((p) => p.after), [1200, 900, 850, 800]);
      expect(r.income, BigInt.from(200));
      expect(r.expense, BigInt.from(50));
      expect(r.netCashFlow, BigInt.from(150));
    }
  });
  test('Moving a fixture across anchors recalculates correct segment', () {
    final original = [
      income(1, 10, 200),
      anchor(2, 20, 900),
      anchor(3, 40, 800),
    ];
    final moved = [income(1, 30, 200), anchor(2, 20, 900), anchor(3, 40, 800)];
    expect(replayLedger(1000, original).balance, 800);
    final r = replayLedger(1000, moved);
    expect(r.balance, 800);
    expect(r.points[2].difference, -300);
  });
  test('Full-range difference is exact, intermediate overflow is rejected', () {
    final r = replayLedger(maxMnt, [anchor(1, 1, -maxMnt)]);
    expect(r.points.single.difference, -1999999999998);
    expect(
      () => replayLedger(maxMnt, [income(1, 1, 1)]),
      throwsFormatException,
    );
    expect(
      () => replayLedger(-maxMnt, [expense(1, 1, 1)]),
      throwsFormatException,
    );
    expect(() => replayLedger(0, [income(1, 1, 0)]), throwsFormatException);
    expect(() => replayLedger(0, [expense(1, 1, -1)]), throwsFormatException);
  });
  test('Invalid duplicate ordering fails explicitly', () {
    expect(
      () => replayLedger(0, [anchor(1, 1, 0), anchor(1, 2, 0)]),
      throwsFormatException,
    );
    expect(() => replayLedger(0, [anchor(0, 1, 0)]), throwsFormatException);
  });
}
