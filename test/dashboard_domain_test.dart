import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/home/domain/dashboard.dart';

void main() {
  DashboardReport report(
    List<ReportEntry> entries, {
    List<int> balances = const [],
    DateTime? month,
  }) => aggregateDashboard(
    entries: entries,
    balances: balances,
    month: month ?? DateTime(2027, 1),
  );
  const income = EventKind.income, expense = EventKind.expense;
  test(
    'Empty database and negative aggregate balance are independent from flow',
    () {
      final empty = report([]);
      expect(empty.balance, BigInt.zero);
      expect(empty.current.income, BigInt.zero);
      expect(empty.previous.expense, BigInt.zero);
      expect(empty.categories, isEmpty);
      expect(empty.income.percentTenths, isNull);
      final negative = report([], balances: [1000, -2000]);
      expect(negative.balance, BigInt.from(-1000));
      expect(negative.net, BigInt.zero);
    },
  );
  test(
    'Stored month keys handle cross-year boundaries and exclude anchors',
    () {
      final r = report(
        [
          const ReportEntry(income, 200, '2027-01-01', 1),
          const ReportEntry(expense, 50, '2027-01-31', 2),
          const ReportEntry(income, 100, '2026-12-31', 1),
          const ReportEntry(expense, 100, '2026-12-01', 2),
          const ReportEntry(expense, 999, '2027-02-01', 2),
          const ReportEntry(expense, 999, '2026-11-30', 2),
          const ReportEntry(EventKind.adjustment, -999, '2027-01-01', 0),
        ],
        balances: [850, -500],
      );
      expect(r.balance, BigInt.from(350));
      expect(r.current.income, BigInt.from(200));
      expect(r.current.expense, BigInt.from(50));
      expect(r.net, BigInt.from(150));
      expect(r.previous.income, BigInt.from(100));
      expect(r.previous.expense, BigInt.from(100));
      expect(r.income.difference, BigInt.from(100));
      expect(r.income.percentTenths, BigInt.from(1000));
      expect(r.expense.difference, BigInt.from(-50));
      expect(r.expense.percentTenths, BigInt.from(500));
    },
  );
  test('Category shares reconcile with deterministic largest remainders', () {
    final r = report([
      for (final id in [3, 2, 1]) ReportEntry(expense, 1, '2027-01-01', id),
    ]);
    expect(r.categories.map((s) => s.id), [1, 2, 3]);
    expect(r.categories.map((s) => s.tenths), [334, 333, 333]);
    expect(
      r.categories.fold(BigInt.zero, (v, s) => v + s.amount),
      r.current.expense,
    );
    expect(r.categories.fold(0, (v, s) => v + s.tenths), 1000);
    expect(percentLabel(BigInt.from(334)), '33.4%');
  });
  test(
    'Zero baselines omit percentage; half-up rounding is exact and unsigned',
    () {
      expect(MonthComparison(BigInt.one, BigInt.zero).percentTenths, isNull);
      expect(
        MonthComparison(BigInt.zero, BigInt.one).percentTenths,
        BigInt.from(1000),
      );
      expect(
        MonthComparison(BigInt.from(2001), BigInt.from(2000)).percentTenths,
        BigInt.one,
      );
      expect(
        MonthComparison(BigInt.from(1999), BigInt.from(2000)).percentTenths,
        BigInt.one,
      );
      expect(
        MonthComparison(BigInt.from(2000), BigInt.from(2000)).percentTenths,
        BigInt.zero,
      );
    },
  );
  test(
    'Totals beyond double precision remain exact; tiny shares stay listed',
    () {
      final r = report(
        [
          for (var i = 0; i < 10000; i++)
            const ReportEntry(income, 999999999999, '2027-01-02', 1),
          const ReportEntry(expense, 999999999999, '2027-01-02', 2),
          const ReportEntry(expense, 1, '2027-01-02', 3),
        ],
        balances: [999999999999, 999999999999],
      );
      expect(r.current.income, BigInt.parse('9999999999990000'));
      expect(r.balance, BigInt.parse('1999999999998'));
      expect(r.categories.map((s) => s.tenths), [1000, 0]);
      final huge = MonthComparison(
        BigInt.parse('999999999999999999999999'),
        BigInt.one,
      );
      expect(huge.percentTenths, BigInt.parse('999999999999999999999998000'));
    },
  );
  test('Invalid entry magnitudes fail explicitly, never truncate', () {
    for (final value in [0, -1, 1000000000000]) {
      expect(
        () => report([ReportEntry(expense, value, '2027-01-01', 1)]),
        throwsFormatException,
      );
    }
  });
  test(
    'Many category amounts reconcile exactly without list-order dependence',
    () {
      final entries = [
        for (var id = 1; id <= 1234; id++)
          ReportEntry(expense, id, '2027-01-15', id),
      ];
      final a = report(entries), b = report(entries.reversed.toList());
      expect(
        a.categories.map((s) => (s.id, s.amount, s.tenths)),
        b.categories.map((s) => (s.id, s.amount, s.tenths)),
      );
      expect(a.categories.fold(0, (v, s) => v + s.tenths), 1000);
      expect(
        a.categories.fold(BigInt.zero, (v, s) => v + s.amount),
        a.current.expense,
      );
    },
  );
}
