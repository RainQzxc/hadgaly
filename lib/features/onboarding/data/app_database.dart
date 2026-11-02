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

@DriftDatabase(tables: [Accounts, Profiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'hadgaly'));

  @override
  int get schemaVersion => 1;

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
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

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
