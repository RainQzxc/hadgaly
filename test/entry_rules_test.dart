import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/core/domain/money.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/transactions/domain/entry_rules.dart';

void main() {
  test('Positive whole MNT only, exact supported boundaries', () {
    expect(parseEntryAmount(' 1200 '), 1200);
    expect(parseEntryAmount('$maxMnt'), maxMnt);
    for (final input in [
      '',
      ' ',
      '0',
      '-1',
      '1.2',
      '1e3',
      'NaN',
      '1000000000000',
      '999999999999999999999999999999999999',
    ]) {
      expect(
        () => parseEntryAmount(input),
        throwsFormatException,
        reason: input,
      );
    }
    expect(() => entryKind(EventKind.adjustment), throwsArgumentError);
  });
  test('Date-only chronology, day-end backdating, clock rollback', () {
    final now = DateTime(2026, 11, 3, 12);
    final micros = now.toUtc().microsecondsSinceEpoch;
    expect(entryEffectiveAt(now, now, 0), micros);
    expect(entryEffectiveAt(now, now, micros + 10), micros + 10);
    expect(
      entryEffectiveAt(DateTime(2026, 11, 2), now, micros),
      DateTime(2026, 11, 3).toUtc().microsecondsSinceEpoch - 1,
    );
    expect(
      () => validateEntryDate(DateTime(2026, 11, 4), now),
      throwsFormatException,
    );
    expect(() => validateEntryDate(DateTime(1969), now), throwsFormatException);
    expect(dateKey(DateTime(2026, 1, 2)), '2026-01-02');
  });
  test('Optional notes validate Unicode length and unsafe control input', () {
    expect(validateNote('  Өдрийн хоол\nкафе '), 'Өдрийн хоол\nкафе');
    expect(validateNote(''), '');
    expect(validateNote('💚' * 500).runes.length, 500);
    expect(() => validateNote('💚' * 501), throwsFormatException);
    expect(() => validateNote('a\u0000b'), throwsFormatException);
  });
  test('Monthly totals exclude anchors and other months, exact beyond account limit', () {
    final result = monthFlows([
      const PeriodAmount(EventKind.income, maxMnt, '2026-11-01'),
      const PeriodAmount(EventKind.income, maxMnt, '2026-11-30'),
      const PeriodAmount(EventKind.expense, 300, '2026-11-03'),
      const PeriodAmount(EventKind.adjustment, 900, '2026-11-03'),
      const PeriodAmount(EventKind.income, 50, '2026-10-31'),
      const PeriodAmount(EventKind.expense, 60, '2026-12-01'),
    ], DateTime(2026, 11));
    expect(result.income, BigInt.from(maxMnt) * BigInt.two);
    expect(result.expense, BigInt.from(300));
    expect(formatFlow(result.income), '1,999,999,999,998 ₮');
  });
}
