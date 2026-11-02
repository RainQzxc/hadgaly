// Drift evaluates column check expressions during code generation.
// ignore_for_file: recursive_getters
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../../core/domain/money.dart';

part 'app_database.g.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name =>
      text().check(name.trim().length.isBetweenValues(1, 60))();
  IntColumn get openingBalance =>
      integer().check(openingBalance.isBetweenValues(-maxMnt, maxMnt))();
  TextColumn get creationKey => text().nullable()();
}

class BalanceAdjustments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get target =>
      integer().check(target.isBetweenValues(-maxMnt, maxMnt))();
  IntColumn get effectiveAt => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get originalTarget => integer()();
  IntColumn get observedBalanceBefore => integer()();
  IntColumn get revision => integer().withDefault(const Constant(0))();
  TextColumn get requestKey => text().unique()();
}

class AdjustmentEdits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get adjustmentId => integer().references(BalanceAdjustments, #id)();
  IntColumn get oldTarget => integer()();
  IntColumn get newTarget =>
      integer().check(newTarget.isBetweenValues(-maxMnt, maxMnt))();
  IntColumn get editedAt => integer()();
  IntColumn get previousRevision => integer()();
  TextColumn get requestKey => text().unique()();
}

class Profiles extends Table {
  IntColumn get id => integer().check(id.equals(1))();
  TextColumn get nickname => text().withDefault(const Constant(''))();
  TextColumn get accountDraft => text().withDefault(const Constant(''))();
  TextColumn get balanceDraft => text().withDefault(const Constant(''))();
  IntColumn get step => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  IntColumn get defaultAccountId =>
      integer().nullable().references(Accounts, #id)();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [Accounts, Profiles, BalanceAdjustments, AdjustmentEdits],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'hadgaly'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Protect onboarding invariants even from an invalid direct SQL write.
      await customStatement(
        '''CREATE TRIGGER valid_completed_profile
        BEFORE UPDATE ON profiles
        WHEN (NEW.completed = 1 OR NEW.step >= 3) AND
          (length(trim(NEW.nickname)) = 0 OR NEW.default_account_id IS NULL OR
           NOT EXISTS (SELECT 1 FROM accounts WHERE id = NEW.default_account_id))
        BEGIN SELECT RAISE(ABORT, 'Onboarding requires a valid account'); END''',
      );
      await _financialGuards();
    },
    onUpgrade: (m, from, to) async {
      if (from == 1) {
        await transaction(() async {
          await m.addColumn(accounts, accounts.creationKey);
          await m.createTable(balanceAdjustments);
          await m.createTable(adjustmentEdits);
          await _financialGuards();
        });
      } else {
        throw StateError('Unsupported database migration: $from to $to');
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _financialGuards() async {
    await customStatement(
      'CREATE UNIQUE INDEX adjustment_edit_revision ON adjustment_edits(adjustment_id, previous_revision)',
    );
    await customStatement(
      '''CREATE TRIGGER valid_adjustment_edit BEFORE INSERT ON adjustment_edits
      WHEN NOT EXISTS (SELECT 1 FROM balance_adjustments WHERE id = NEW.adjustment_id
        AND target = NEW.old_target AND revision = NEW.previous_revision)
      BEGIN SELECT RAISE(ABORT, 'Audit does not match current adjustment'); END''',
    );
    await customStatement(
      '''CREATE TRIGGER audited_adjustment_change BEFORE UPDATE ON balance_adjustments
      WHEN (NEW.target != OLD.target OR NEW.revision != OLD.revision) AND
        (NEW.revision != OLD.revision + 1 OR NOT EXISTS
          (SELECT 1 FROM adjustment_edits WHERE adjustment_id = OLD.id
            AND old_target = OLD.target AND new_target = NEW.target AND previous_revision = OLD.revision))
      BEGIN SELECT RAISE(ABORT, 'Adjustment edit requires matching audit'); END''',
    );
    await customStatement(
      'CREATE UNIQUE INDEX account_creation_key ON accounts(creation_key)',
    );
    await customStatement(
      'CREATE INDEX adjustment_chronology ON balance_adjustments(account_id, effective_at, id)',
    );
    await customStatement('''CREATE TRIGGER immutable_adjustment_observation
      BEFORE UPDATE ON balance_adjustments
      WHEN NEW.id != OLD.id OR NEW.account_id != OLD.account_id OR
        NEW.effective_at != OLD.effective_at OR NEW.created_at != OLD.created_at OR
        NEW.original_target != OLD.original_target OR
        NEW.observed_balance_before != OLD.observed_balance_before OR NEW.request_key != OLD.request_key
      BEGIN SELECT RAISE(ABORT, 'Immutable adjustment observation'); END''');
    await customStatement(
      '''CREATE TRIGGER no_adjustment_delete BEFORE DELETE ON balance_adjustments
      BEGIN SELECT RAISE(ABORT, 'Adjustment deletion is not supported'); END''',
    );
    for (final action in ['UPDATE', 'DELETE']) {
      await customStatement(
        '''CREATE TRIGGER immutable_audit_${action.toLowerCase()} BEFORE $action ON adjustment_edits
        BEGIN SELECT RAISE(ABORT, 'Immutable adjustment audit'); END''',
      );
    }
  }

  Future<Profile> loadProfile() async {
    await into(profiles).insert(
      const ProfilesCompanion(id: Value(1)),
      mode: InsertMode.insertOrIgnore,
    );
    return select(profiles).getSingle();
  }

  Future<Account?> defaultAccount(Profile profile) async =>
      profile.defaultAccountId == null
      ? null
      : (select(accounts)..where((a) => a.id.equals(profile.defaultAccountId!)))
            .getSingleOrNull();

  Future<void> saveDraft(
    String nickname,
    String account,
    String balance,
    int step,
  ) async {
    await (update(
      profiles,
    )..where((p) => p.id.equals(1) & p.completed.equals(false))).write(
      ProfilesCompanion(
        nickname: Value(nickname),
        accountDraft: Value(account),
        balanceDraft: Value(balance),
        step: Value(step),
      ),
    );
  }

  Future<void> createFirstAccount(
    String nickname,
    String name,
    String balance,
  ) async {
    final validNickname = validateName(nickname);
    final validAccount = validateName(name, label: 'Дансны нэр');
    final amount = parseMnt(balance);
    await transaction(() async {
      final profile = await loadProfile();
      // Stable singleton profile makes retries idempotent.
      if (profile.defaultAccountId != null) return;
      final id = await into(accounts).insert(
        AccountsCompanion.insert(name: validAccount, openingBalance: amount),
      );
      await (update(profiles)..where((p) => p.id.equals(1))).write(
        ProfilesCompanion(
          nickname: Value(validNickname),
          accountDraft: const Value(''),
          balanceDraft: const Value(''),
          defaultAccountId: Value(id),
          step: const Value(3),
        ),
      );
    });
  }

  Future<void> completeOnboarding() => transaction(() async {
    final profile = await loadProfile();
    if (await defaultAccount(profile) == null ||
        profile.nickname.trim().isEmpty) {
      throw StateError('Missing first account or nickname');
    }
    await (update(profiles)..where((p) => p.id.equals(1))).write(
      const ProfilesCompanion(completed: Value(true), step: Value(4)),
    );
  });
}
