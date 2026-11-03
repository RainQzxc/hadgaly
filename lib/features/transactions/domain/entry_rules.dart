import '../../../core/domain/money.dart';
import '../../accounts/domain/ledger.dart';

const categoryIcons = [
  'briefcase',
  'plus',
  'gift',
  'food',
  'cart',
  'car',
  'home',
  'heart',
  'book',
  'phone',
  'card',
  'other',
];
const initialCategories = [
  (kind: 'income', name: 'Цалин', icon: 'briefcase'),
  (kind: 'income', name: 'Нэмэлт орлого', icon: 'plus'),
  (kind: 'income', name: 'Бэлэг', icon: 'gift'),
  (kind: 'income', name: 'Бусад', icon: 'other'),
  (kind: 'expense', name: 'Хоол', icon: 'food'),
  (kind: 'expense', name: 'Хүнс', icon: 'cart'),
  (kind: 'expense', name: 'Унаа', icon: 'car'),
  (kind: 'expense', name: 'Гэр', icon: 'home'),
  (kind: 'expense', name: 'Эрүүл мэнд', icon: 'heart'),
  (kind: 'expense', name: 'Бусад', icon: 'other'),
];

int parseEntryAmount(String raw) {
  final amount = parseMnt(raw);
  if (amount <= 0) {
    throw const FormatException('0-ээс их бүхэл төгрөгөөр оруулаарай.');
  }
  return amount;
}

String entryKind(EventKind kind) {
  if (kind == EventKind.adjustment) throw ArgumentError('Not a cash entry');
  return kind.name;
}

DateTime calendarDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);
String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

DateTime validateEntryDate(DateTime selected, DateTime now) {
  final date = calendarDay(selected);
  if (date.isBefore(DateTime(1970)) || date.isAfter(calendarDay(now))) {
    throw const FormatException('Өнгөрсөн эсвэл өнөөдрийн огноог сонгоорой.');
  }
  return date;
}

int entryEffectiveAt(DateTime date, DateTime now, int latestEffectiveAt) {
  validateEntryDate(date, now);
  if (calendarDay(date) == calendarDay(now)) {
    final micros = now.toUtc().microsecondsSinceEpoch;
    return micros < latestEffectiveAt ? latestEffectiveAt : micros;
  }
  return DateTime(
        date.year,
        date.month,
        date.day + 1,
      ).toUtc().microsecondsSinceEpoch -
      1;
}

String validateNote(String raw) {
  final note = raw.trim();
  if (note.runes.length > 500 ||
      RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]').hasMatch(note)) {
    throw const FormatException('Тэмдэглэл 500 хүртэл тэмдэгттэй байна.');
  }
  return note;
}

class PeriodAmount {
  const PeriodAmount(this.kind, this.amount, this.date);
  final EventKind kind;
  final int amount;
  final String date;
}

class FlowTotals {
  const FlowTotals(this.income, this.expense);
  final BigInt income, expense;
}

FlowTotals monthFlows(Iterable<PeriodAmount> records, DateTime month) {
  final start = dateKey(DateTime(month.year, month.month));
  final end = dateKey(DateTime(month.year, month.month + 1));
  var income = BigInt.zero, expense = BigInt.zero;
  for (final record in records) {
    if (record.date.compareTo(start) < 0 ||
        record.date.compareTo(end) >= 0 ||
        record.kind == EventKind.adjustment) {
      continue;
    }
    if (record.amount <= 0 || record.amount > maxMnt) {
      throw const FormatException('Invalid entry amount');
    }
    if (record.kind == EventKind.income) {
      income += BigInt.from(record.amount);
    } else {
      expense += BigInt.from(record.amount);
    }
  }
  return FlowTotals(income, expense);
}

String formatFlow(BigInt value) =>
    '${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ₮';
