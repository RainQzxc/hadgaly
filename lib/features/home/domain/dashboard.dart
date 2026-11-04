import '../../accounts/domain/ledger.dart';
import '../../transactions/domain/entry_rules.dart';

class ReportEntry extends PeriodAmount {
  const ReportEntry(super.kind, super.amount, super.date, this.categoryId);
  final int categoryId;
}

class CategoryShare {
  const CategoryShare(this.id, this.amount, this.tenths);
  final int id;
  final BigInt amount;
  final int tenths;
}

class MonthComparison {
  const MonthComparison(this.current, this.previous);
  final BigInt current, previous;
  BigInt get difference => current - previous;
  // Integer half-up rounding to tenths of one percent; absent for zero baseline.
  BigInt? get percentTenths => previous == BigInt.zero
      ? null
      : (difference.abs() * BigInt.from(2000) + previous) ~/
            (previous * BigInt.two);
}

class DashboardReport {
  const DashboardReport(
    this.balance,
    this.current,
    this.previous,
    this.categories,
  );
  final BigInt balance;
  final FlowTotals current, previous;
  final List<CategoryShare> categories;
  BigInt get net => current.income - current.expense;
  MonthComparison get income =>
      MonthComparison(current.income, previous.income);
  MonthComparison get expense =>
      MonthComparison(current.expense, previous.expense);
}

DashboardReport aggregateDashboard({
  required Iterable<ReportEntry> entries,
  required Iterable<int> balances,
  required DateTime month,
}) {
  final records = entries.toList();
  final current = monthFlows(records, month);
  final previous = monthFlows(records, DateTime(month.year, month.month - 1));
  final start = dateKey(DateTime(month.year, month.month));
  final end = dateKey(DateTime(month.year, month.month + 1));
  final totals = <int, BigInt>{};
  for (final e in records) {
    if (e.kind == EventKind.expense &&
        e.date.compareTo(start) >= 0 &&
        e.date.compareTo(end) < 0) {
      totals.update(
        e.categoryId,
        (v) => v + BigInt.from(e.amount),
        ifAbsent: () => BigInt.from(e.amount),
      );
    }
  }
  final parts = <int, int>{};
  final residues = <int, BigInt>{};
  for (final item in totals.entries) {
    final scaled = item.value * BigInt.from(1000);
    parts[item.key] = (scaled ~/ current.expense).toInt();
    residues[item.key] = scaled % current.expense;
  }
  final remainderOrder = totals.keys.toList()
    ..sort((a, b) {
      final result = residues[b]!.compareTo(residues[a]!);
      return result != 0 ? result : a.compareTo(b);
    });
  final left = totals.isEmpty
      ? 0
      : 1000 - parts.values.fold(0, (a, b) => a + b);
  for (var i = 0; i < left; i++) {
    parts[remainderOrder[i]] = parts[remainderOrder[i]]! + 1;
  }
  final ordered = totals.keys.toList()
    ..sort((a, b) {
      final result = totals[b]!.compareTo(totals[a]!);
      return result != 0 ? result : a.compareTo(b);
    });
  return DashboardReport(
    balances.fold(BigInt.zero, (v, b) => v + BigInt.from(b)),
    current,
    previous,
    List.unmodifiable(
      ordered.map((id) => CategoryShare(id, totals[id]!, parts[id]!)),
    ),
  );
}

String percentLabel(BigInt tenths) =>
    '${tenths ~/ BigInt.from(10)}.${tenths % BigInt.from(10)}%';
String signedMoney(BigInt value) =>
    '${value.isNegative
        ? '−'
        : value > BigInt.zero
        ? '+'
        : ''}${formatFlow(value.abs())}';
