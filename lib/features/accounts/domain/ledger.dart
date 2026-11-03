import '../../../core/domain/money.dart';

enum EventKind { income, expense, adjustment }

/// Persistence-free input. Transaction kinds are fixtures only in Stage 2.
class LedgerEvent {
  const LedgerEvent({
    required this.sequence,
    required this.effectiveAt,
    required this.kind,
    required this.amount,
    this.originalDifference,
  });
  final int sequence, effectiveAt, amount;
  final EventKind kind;
  final int? originalDifference;
}

class LedgerPoint {
  const LedgerPoint(this.event, this.before, this.after, this.difference);
  final LedgerEvent event;
  final int before, after;
  final int? difference;
}

class LedgerResult {
  const LedgerResult(this.balance, this.points, this.income, this.expense);
  final int balance;
  final List<LedgerPoint> points;
  final BigInt income, expense;
  BigInt get netCashFlow => income - expense;
}

int checkedBalance(BigInt value) {
  if (value.abs() > BigInt.from(maxMnt)) {
    throw const FormatException('Үлдэгдэл зөвшөөрөгдөх хязгаараас давлаа.');
  }
  return value.toInt();
}

LedgerResult replayLedger(int openingBalance, Iterable<LedgerEvent> events) {
  var balance = checkedBalance(BigInt.from(openingBalance));
  var income = BigInt.zero, expense = BigInt.zero;
  final ordered = events.toList()
    ..sort((a, b) {
      final time = a.effectiveAt.compareTo(b.effectiveAt);
      return time == 0 ? a.sequence.compareTo(b.sequence) : time;
    });
  final sequences = <int>{};
  final points = <LedgerPoint>[];
  for (final event in ordered) {
    if (event.sequence <= 0 ||
        event.effectiveAt < 0 ||
        !sequences.add(event.sequence)) {
      throw const FormatException('Invalid or duplicate event ordering');
    }
    checkedBalance(BigInt.from(event.amount));
    final before = balance;
    int? difference;
    if (event.kind == EventKind.adjustment) {
      difference = (BigInt.from(event.amount) - BigInt.from(before)).toInt();
      balance = event.amount;
    } else {
      if (event.amount <= 0) {
        throw const FormatException('Amount must be positive');
      }
      final amount = BigInt.from(event.amount);
      if (event.kind == EventKind.income) {
        income += amount;
        balance = checkedBalance(BigInt.from(balance) + amount);
      } else {
        expense += amount;
        balance = checkedBalance(BigInt.from(balance) - amount);
      }
    }
    points.add(LedgerPoint(event, before, balance, difference));
  }
  return LedgerResult(balance, List.unmodifiable(points), income, expense);
}
