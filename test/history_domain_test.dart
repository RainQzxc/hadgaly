import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/transactions/domain/entry_rules.dart';
import 'package:hadgaly/features/transactions/domain/history.dart';

void main() {
  const items = [
    HistoryItem(
      id: 1,
      accountId: 1,
      kind: EventKind.income,
      amount: 200,
      day: '2026-11-03',
      effectiveAt: 10,
      note: 'ӨДРИЙН цалин',
    ),
    HistoryItem(
      id: 3,
      accountId: 2,
      kind: EventKind.expense,
      amount: 50,
      day: '2026-11-03',
      effectiveAt: 10,
      note: 'Өдрийн хоол',
    ),
    HistoryItem(
      id: 2,
      accountId: 1,
      kind: EventKind.adjustment,
      amount: -500,
      day: '2026-11-03',
      effectiveAt: 10,
    ),
    HistoryItem(
      id: 4,
      accountId: 1,
      kind: EventKind.expense,
      amount: 20,
      day: '2026-10-31',
      effectiveAt: 9,
      note: 'Өдрийн хоол',
    ),
    HistoryItem(
      id: 5,
      accountId: 1,
      kind: EventKind.income,
      amount: 10,
      day: '2026-10-27',
      effectiveAt: 8,
      note: 'Цалин',
    ),
  ];
  final now = DateTime(2026, 11, 3, 12);
  test('Date/time/stable ordering independent of input order', () {
    expect(filterHistory(items.reversed, now: now).map((e) => e.id), [
      3,
      2,
      1,
      4,
      5,
    ]);
  });
  test(
    'Account/period/type/note predicates combine, Unicode case and trim',
    () {
      expect(
        filterHistory(
          items,
          accountId: 1,
          kind: EventKind.expense,
          query: ' ӨДРИЙН ',
          period: HistoryPeriod.previousMonth,
          now: now,
        ).map((e) => e.id),
        [4],
      );
      expect(
        filterHistory(items, accountId: 2, query: 'цалин', now: now),
        isEmpty,
      );
      expect(filterHistory(items, query: ' ', now: now), hasLength(5));
      expect(filterHistory(items, query: 'Өдрийн', now: now).map((e) => e.id), [
        3,
        1,
        4,
      ]);
    },
  );
  test('Month bounds and last seven days include calendar boundary', () {
    expect(
      filterHistory(
        items,
        period: HistoryPeriod.month,
        now: now,
      ).map((e) => e.id),
      [3, 2, 1],
    );
    expect(
      filterHistory(
        items,
        period: HistoryPeriod.week,
        now: now,
      ).map((e) => e.id),
      [3, 2, 1, 4],
    );
    expect(
      filterHistory(items, kind: EventKind.income, now: now).map((e) => e.id),
      [1, 5],
    );
  });
  test('Metadata/account edit preserves original effective position', () {
    expect(
      editedEntryEffectiveAt(
        previousDate: '2026-10-31',
        previousTime: 123,
        date: DateTime(2026, 10, 31),
        now: now,
        sequence: 1,
        latestOtherTime: 999,
        latestOtherSequence: 4,
      ),
      123,
    );
  });
  test(
    'Changed date to today follows later same-time anchor with older sequence',
    () {
      final time = now.toUtc().microsecondsSinceEpoch;
      expect(
        editedEntryEffectiveAt(
          previousDate: '2026-10-31',
          previousTime: 123,
          date: now,
          now: now,
          sequence: 1,
          latestOtherTime: time,
          latestOtherSequence: 4,
        ),
        time + 1,
      );
      expect(
        editedEntryEffectiveAt(
          previousDate: '2026-10-31',
          previousTime: 123,
          date: now,
          now: now.subtract(const Duration(seconds: 1)),
          sequence: 5,
          latestOtherTime: time,
          latestOtherSequence: 4,
        ),
        time,
      );
    },
  );
  test('Changed historical date uses local day end, future rejected', () {
    expect(
      editedEntryEffectiveAt(
        previousDate: '2026-10-31',
        previousTime: 123,
        date: DateTime(2026, 11, 1),
        now: now,
        sequence: 1,
        latestOtherTime: 9999999999999999,
        latestOtherSequence: 5,
      ),
      DateTime(2026, 11, 2).toUtc().microsecondsSinceEpoch - 1,
    );
    expect(
      () => editedEntryEffectiveAt(
        previousDate: '2026-10-31',
        previousTime: 123,
        date: DateTime(2026, 11, 4),
        now: now,
        sequence: 1,
        latestOtherTime: 0,
        latestOtherSequence: 0,
      ),
      throwsFormatException,
    );
  });
}
