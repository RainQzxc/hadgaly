import 'package:sqlite3/common.dart';

void validateBackupSchema(CommonDatabase db, CommonDatabase trusted) {
  final expected = _schema(trusted);
  final actual = _schema(db);
  const profile = 'table/profiles/profiles';
  // The preserved v1 schema omitted the explicit NULL on this nullable FK.
  final legacyProfile = expected[profile]!.replaceFirst(
    'default_account_id\u0000integer\u0000null\u0000references',
    'default_account_id\u0000integer\u0000references',
  );
  if (actual[profile] == legacyProfile) actual[profile] = expected[profile]!;
  if (actual.length != expected.length ||
      expected.entries.any((e) => actual[e.key] != e.value)) {
    throw const FormatException('Unrecognized database schema');
  }
  if (db.select('PRAGMA integrity_check(1)').single.values.single != 'ok' ||
      db.select('PRAGMA foreign_key_check').isNotEmpty) {
    throw const FormatException('SQLite integrity check failed');
  }
  for (final sql in _invariants) {
    if (db.select(sql).isNotEmpty) {
      throw const FormatException('Inconsistent Hadgaly data');
    }
  }
}

Map<String, String> _schema(CommonDatabase db) => {
  for (final row in db.select(
    'SELECT type,name,tbl_name,sql FROM sqlite_schema',
  ))
    [row['type'], row['name'], row['tbl_name']].join('/'): _canonicalSql(
      row['sql'] as String? ?? '',
    ),
};

final _sqlTokens = RegExp(
  r"""'(?:''|[^'])*'|"(?:""|[^"])*"|[A-Za-z_0-9]+|\S""",
);
final _quotedIdentifier = RegExp(r'^"[a-zA-Z_0-9]+"$');

// ALTER TABLE can rewrite identifier quoting and whitespace.
String _canonicalSql(String sql) => _sqlTokens
    .allMatches(sql)
    .map((m) {
      final token = m[0]!;
      if (_quotedIdentifier.hasMatch(token)) {
        return token.substring(1, token.length - 1).toLowerCase();
      }
      return token.startsWith("'") || token.startsWith('"')
          ? token
          : token.toLowerCase();
    })
    .join('\u0000');

const _invariants = [
  '''
  SELECT 1 WHERE (SELECT count(*) FROM profiles) != 1 OR EXISTS (
    SELECT 1 FROM profiles
    WHERE step NOT BETWEEN 0 AND 4 OR completed != (step = 4)
       OR (step >= 3 AND (default_account_id IS NULL OR trim(nickname) = ''))
       OR (step < 3 AND (default_account_id IS NOT NULL OR EXISTS (SELECT 1 FROM accounts)))
  )
  ''',
  '''
  SELECT 1 FROM ledger_sequences s
  LEFT JOIN cash_entries e ON e.id = s.id
  LEFT JOIN balance_adjustments a ON a.id = s.id
  WHERE (s.kind = 'adjustment' AND (a.id IS NULL OR e.id IS NOT NULL))
     OR (s.kind != 'adjustment' AND (a.id IS NOT NULL OR e.id IS NULL OR e.kind != s.kind))
  UNION ALL
  SELECT 1 FROM balance_adjustments a
  LEFT JOIN ledger_sequences s ON s.id = a.id WHERE s.id IS NULL
  LIMIT 1
  ''',
  '''
  SELECT 1 FROM cash_entries e JOIN categories c ON c.id = e.category_id
  WHERE c.kind != e.kind OR date(entry_date, '+0 days') IS NOT entry_date OR entry_date < '1970-01-01'
  UNION ALL
  SELECT 1 FROM entry_revisions e JOIN categories c ON c.id = e.category_id
  WHERE c.kind != e.kind OR date(entry_date, '+0 days') IS NOT entry_date OR entry_date < '1970-01-01'
  LIMIT 1
  ''',
  '''
  WITH chain AS (
    SELECT r.*, row_number() OVER w AS pos, lag(deleted, 1, 0) OVER w AS prior_deleted,
      lag(r.account_id, 1, e.account_id) OVER w AS prior_account,
      lag(r.category_id, 1, e.category_id) OVER w AS prior_category,
      lag(r.kind, 1, e.kind) OVER w AS prior_kind,
      lag(r.amount, 1, e.amount) OVER w AS prior_amount,
      lag(r.effective_at, 1, e.effective_at) OVER w AS prior_time,
      lag(r.entry_date, 1, e.entry_date) OVER w AS prior_date,
      lag(r.note, 1, e.note) OVER w AS prior_note
    FROM entry_revisions r JOIN cash_entries e ON e.id = r.entry_id
    WINDOW w AS (PARTITION BY entry_id ORDER BY revision)
  )
  SELECT 1 FROM chain
  WHERE revision != pos OR prior_deleted != 0 OR
    (deleted = 1 AND (account_id != prior_account OR category_id != prior_category
      OR kind != prior_kind OR amount != prior_amount OR effective_at != prior_time
      OR entry_date != prior_date OR note != prior_note))
  LIMIT 1
  ''',
  '''
  WITH chain AS (
    SELECT e.*, row_number() OVER w AS pos,
      lag(new_target, 1, original_target) OVER w AS prior_target
    FROM adjustment_edits e JOIN balance_adjustments a ON a.id = e.adjustment_id
    WINDOW w AS (PARTITION BY adjustment_id ORDER BY previous_revision)
  )
  SELECT 1 FROM chain WHERE previous_revision != pos - 1 OR old_target != prior_target
  UNION ALL
  SELECT 1 FROM balance_adjustments a
  WHERE a.original_target NOT BETWEEN -999999999999 AND 999999999999
     OR a.observed_balance_before NOT BETWEEN -999999999999 AND 999999999999
     OR a.revision != (SELECT count(*) FROM adjustment_edits e WHERE e.adjustment_id = a.id)
     OR a.target != coalesce((SELECT new_target FROM adjustment_edits e
          WHERE e.adjustment_id = a.id ORDER BY previous_revision DESC LIMIT 1), original_target)
  LIMIT 1
  ''',
];
