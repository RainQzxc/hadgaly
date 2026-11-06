import '../../accounts/domain/ledger.dart';
import 'entry_rules.dart';

enum HistoryPeriod { all, month, previousMonth, week }

class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.accountId,
    required this.kind,
    required this.amount,
    required this.day,
    required this.effectiveAt,
    this.note = '',
    this.categoryId,
  });
  final int id, accountId, amount, effectiveAt;
  final EventKind kind;
  final String day, note;
  final int? categoryId;
}

List<HistoryItem> filterHistory(
  Iterable<HistoryItem> items, {
  int? accountId,
  EventKind? kind,
  HistoryPeriod period = HistoryPeriod.all,
  String query = '',
  required DateTime now,
}) {
  final today = calendarDay(now);
  final (start, end) = switch (period) {
    HistoryPeriod.all => ('', '9999-99-99'),
    HistoryPeriod.month => (
      dateKey(DateTime(now.year, now.month)),
      dateKey(DateTime(now.year, now.month + 1)),
    ),
    HistoryPeriod.previousMonth => (
      dateKey(DateTime(now.year, now.month - 1)),
      dateKey(DateTime(now.year, now.month)),
    ),
    HistoryPeriod.week => (
      dateKey(DateTime(today.year, today.month, today.day - 6)),
      dateKey(DateTime(today.year, today.month, today.day + 1)),
    ),
  };
  final needle = query.trim().toLowerCase();
  return items
      .where(
        (e) =>
            (accountId == null || e.accountId == accountId) &&
            (kind == null || e.kind == kind) &&
            e.day.compareTo(start) >= 0 &&
            e.day.compareTo(end) < 0 &&
            (needle.isEmpty ||
                (e.kind != EventKind.adjustment &&
                    e.note.toLowerCase().contains(needle))),
      )
      .toList()
    ..sort((a, b) {
      final day = b.day.compareTo(a.day);
      if (day != 0) return day;
      final time = b.effectiveAt.compareTo(a.effectiveAt);
      return time == 0 ? b.id.compareTo(a.id) : time;
    });
}
