// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () =>
        ComparableExpr(StringExpressionOperators(name).trim().length)
            .isBetweenValues(1, 60),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingBalanceMeta = const VerificationMeta(
    'openingBalance',
  );
  @override
  late final GeneratedColumn<int> openingBalance = GeneratedColumn<int>(
    'opening_balance',
    aliasedName,
    false,
    check: () =>
        ComparableExpr(openingBalance).isBetweenValues(-maxMnt, maxMnt),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, openingBalance];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
        _openingBalanceMeta,
        openingBalance.isAcceptableOrUnknown(
          data['opening_balance']!,
          _openingBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingBalanceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      openingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final String name;
  final int openingBalance;
  const Account({
    required this.id,
    required this.name,
    required this.openingBalance,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['opening_balance'] = Variable<int>(openingBalance);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      openingBalance: Value(openingBalance),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      openingBalance: serializer.fromJson<int>(json['openingBalance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'openingBalance': serializer.toJson<int>(openingBalance),
    };
  }

  Account copyWith({int? id, String? name, int? openingBalance}) => Account(
    id: id ?? this.id,
    name: name ?? this.name,
    openingBalance: openingBalance ?? this.openingBalance,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('openingBalance: $openingBalance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, openingBalance);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.openingBalance == this.openingBalance);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> openingBalance;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.openingBalance = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int openingBalance,
  }) : name = Value(name),
       openingBalance = Value(openingBalance);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? openingBalance,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (openingBalance != null) 'opening_balance': openingBalance,
    });
  }

  AccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? openingBalance,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      openingBalance: openingBalance ?? this.openingBalance,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<int>(openingBalance.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('openingBalance: $openingBalance')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _accountDraftMeta = const VerificationMeta(
    'accountDraft',
  );
  @override
  late final GeneratedColumn<String> accountDraft = GeneratedColumn<String>(
    'account_draft',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _balanceDraftMeta = const VerificationMeta(
    'balanceDraft',
  );
  @override
  late final GeneratedColumn<String> balanceDraft = GeneratedColumn<String>(
    'balance_draft',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _stepMeta = const VerificationMeta('step');
  @override
  late final GeneratedColumn<int> step = GeneratedColumn<int>(
    'step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _defaultAccountIdMeta = const VerificationMeta(
    'defaultAccountId',
  );
  @override
  late final GeneratedColumn<int> defaultAccountId = GeneratedColumn<int>(
    'default_account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nickname,
    accountDraft,
    balanceDraft,
    step,
    completed,
    defaultAccountId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('account_draft')) {
      context.handle(
        _accountDraftMeta,
        accountDraft.isAcceptableOrUnknown(
          data['account_draft']!,
          _accountDraftMeta,
        ),
      );
    }
    if (data.containsKey('balance_draft')) {
      context.handle(
        _balanceDraftMeta,
        balanceDraft.isAcceptableOrUnknown(
          data['balance_draft']!,
          _balanceDraftMeta,
        ),
      );
    }
    if (data.containsKey('step')) {
      context.handle(
        _stepMeta,
        step.isAcceptableOrUnknown(data['step']!, _stepMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('default_account_id')) {
      context.handle(
        _defaultAccountIdMeta,
        defaultAccountId.isAcceptableOrUnknown(
          data['default_account_id']!,
          _defaultAccountIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      accountDraft: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_draft'],
      )!,
      balanceDraft: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}balance_draft'],
      )!,
      step: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      defaultAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_account_id'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String nickname;
  final String accountDraft;
  final String balanceDraft;
  final int step;
  final bool completed;
  final int? defaultAccountId;
  const Profile({
    required this.id,
    required this.nickname,
    required this.accountDraft,
    required this.balanceDraft,
    required this.step,
    required this.completed,
    this.defaultAccountId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nickname'] = Variable<String>(nickname);
    map['account_draft'] = Variable<String>(accountDraft);
    map['balance_draft'] = Variable<String>(balanceDraft);
    map['step'] = Variable<int>(step);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || defaultAccountId != null) {
      map['default_account_id'] = Variable<int>(defaultAccountId);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      nickname: Value(nickname),
      accountDraft: Value(accountDraft),
      balanceDraft: Value(balanceDraft),
      step: Value(step),
      completed: Value(completed),
      defaultAccountId: defaultAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultAccountId),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      accountDraft: serializer.fromJson<String>(json['accountDraft']),
      balanceDraft: serializer.fromJson<String>(json['balanceDraft']),
      step: serializer.fromJson<int>(json['step']),
      completed: serializer.fromJson<bool>(json['completed']),
      defaultAccountId: serializer.fromJson<int?>(json['defaultAccountId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nickname': serializer.toJson<String>(nickname),
      'accountDraft': serializer.toJson<String>(accountDraft),
      'balanceDraft': serializer.toJson<String>(balanceDraft),
      'step': serializer.toJson<int>(step),
      'completed': serializer.toJson<bool>(completed),
      'defaultAccountId': serializer.toJson<int?>(defaultAccountId),
    };
  }

  Profile copyWith({
    int? id,
    String? nickname,
    String? accountDraft,
    String? balanceDraft,
    int? step,
    bool? completed,
    Value<int?> defaultAccountId = const Value.absent(),
  }) => Profile(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    accountDraft: accountDraft ?? this.accountDraft,
    balanceDraft: balanceDraft ?? this.balanceDraft,
    step: step ?? this.step,
    completed: completed ?? this.completed,
    defaultAccountId: defaultAccountId.present
        ? defaultAccountId.value
        : this.defaultAccountId,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      accountDraft: data.accountDraft.present
          ? data.accountDraft.value
          : this.accountDraft,
      balanceDraft: data.balanceDraft.present
          ? data.balanceDraft.value
          : this.balanceDraft,
      step: data.step.present ? data.step.value : this.step,
      completed: data.completed.present ? data.completed.value : this.completed,
      defaultAccountId: data.defaultAccountId.present
          ? data.defaultAccountId.value
          : this.defaultAccountId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('accountDraft: $accountDraft, ')
          ..write('balanceDraft: $balanceDraft, ')
          ..write('step: $step, ')
          ..write('completed: $completed, ')
          ..write('defaultAccountId: $defaultAccountId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nickname,
    accountDraft,
    balanceDraft,
    step,
    completed,
    defaultAccountId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.accountDraft == this.accountDraft &&
          other.balanceDraft == this.balanceDraft &&
          other.step == this.step &&
          other.completed == this.completed &&
          other.defaultAccountId == this.defaultAccountId);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> nickname;
  final Value<String> accountDraft;
  final Value<String> balanceDraft;
  final Value<int> step;
  final Value<bool> completed;
  final Value<int?> defaultAccountId;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.accountDraft = const Value.absent(),
    this.balanceDraft = const Value.absent(),
    this.step = const Value.absent(),
    this.completed = const Value.absent(),
    this.defaultAccountId = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.accountDraft = const Value.absent(),
    this.balanceDraft = const Value.absent(),
    this.step = const Value.absent(),
    this.completed = const Value.absent(),
    this.defaultAccountId = const Value.absent(),
  });
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? nickname,
    Expression<String>? accountDraft,
    Expression<String>? balanceDraft,
    Expression<int>? step,
    Expression<bool>? completed,
    Expression<int>? defaultAccountId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (accountDraft != null) 'account_draft': accountDraft,
      if (balanceDraft != null) 'balance_draft': balanceDraft,
      if (step != null) 'step': step,
      if (completed != null) 'completed': completed,
      if (defaultAccountId != null) 'default_account_id': defaultAccountId,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? nickname,
    Value<String>? accountDraft,
    Value<String>? balanceDraft,
    Value<int>? step,
    Value<bool>? completed,
    Value<int?>? defaultAccountId,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      accountDraft: accountDraft ?? this.accountDraft,
      balanceDraft: balanceDraft ?? this.balanceDraft,
      step: step ?? this.step,
      completed: completed ?? this.completed,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (accountDraft.present) {
      map['account_draft'] = Variable<String>(accountDraft.value);
    }
    if (balanceDraft.present) {
      map['balance_draft'] = Variable<String>(balanceDraft.value);
    }
    if (step.present) {
      map['step'] = Variable<int>(step.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (defaultAccountId.present) {
      map['default_account_id'] = Variable<int>(defaultAccountId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('accountDraft: $accountDraft, ')
          ..write('balanceDraft: $balanceDraft, ')
          ..write('step: $step, ')
          ..write('completed: $completed, ')
          ..write('defaultAccountId: $defaultAccountId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [accounts, profiles];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  required String name,
  required int openingBalance,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> openingBalance,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProfilesTable, List<Profile>> _profilesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.profiles,
    aliasName: 'accounts__id__profiles__default_account_id',
  );

  $$ProfilesTableProcessedTableManager get profilesRefs {
    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.defaultAccountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_profilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> profilesRefs(
    Expression<bool> Function($$ProfilesTableFilterComposer f) f,
  ) {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.defaultAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => column,
  );

  Expression<T> profilesRefs<T extends Object>(
    Expression<T> Function($$ProfilesTableAnnotationComposer a) f,
  ) {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.defaultAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, $$AccountsTableReferences),
          Account,
          PrefetchHooks Function({bool profilesRefs})
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> openingBalance = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                openingBalance: openingBalance,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int openingBalance,
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                openingBalance: openingBalance,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, Account>(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profilesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (profilesRefs) db.profiles],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (profilesRefs)
                    await $_getPrefetchedDataByColumns<
                      Account,
                      $AccountsTable,
                      Profile,
                      $ProfilesTable
                    >(
                      currentTable: table,
                      referencedTable: $$AccountsTableReferences
                          ._profilesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AccountsTableReferences(db, table, p0).profilesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'default_account_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, $$AccountsTableReferences),
      Account,
      PrefetchHooks Function({bool profilesRefs})
    >;
typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> nickname,
  Value<String> accountDraft,
  Value<String> balanceDraft,
  Value<int> step,
  Value<bool> completed,
  Value<int?> defaultAccountId,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> nickname,
  Value<String> accountDraft,
  Value<String> balanceDraft,
  Value<int> step,
  Value<bool> completed,
  Value<int?> defaultAccountId,
});

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _defaultAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('profiles__default_account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get defaultAccountId {
    final $_column = $_itemColumn<int>('default_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_defaultAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountDraft => $composableBuilder(
    column: $table.accountDraft,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get balanceDraft => $composableBuilder(
    column: $table.balanceDraft,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get defaultAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountDraft => $composableBuilder(
    column: $table.accountDraft,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get balanceDraft => $composableBuilder(
    column: $table.balanceDraft,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get defaultAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get accountDraft => $composableBuilder(
    column: $table.accountDraft,
    builder: (column) => column,
  );

  GeneratedColumn<String> get balanceDraft => $composableBuilder(
    column: $table.balanceDraft,
    builder: (column) => column,
  );

  GeneratedColumn<int> get step =>
      $composableBuilder(column: $table.step, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  $$AccountsTableAnnotationComposer get defaultAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, $$ProfilesTableReferences),
          Profile,
          PrefetchHooks Function({bool defaultAccountId})
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String> accountDraft = const Value.absent(),
                Value<String> balanceDraft = const Value.absent(),
                Value<int> step = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int?> defaultAccountId = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                nickname: nickname,
                accountDraft: accountDraft,
                balanceDraft: balanceDraft,
                step: step,
                completed: completed,
                defaultAccountId: defaultAccountId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String> accountDraft = const Value.absent(),
                Value<String> balanceDraft = const Value.absent(),
                Value<int> step = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int?> defaultAccountId = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                nickname: nickname,
                accountDraft: accountDraft,
                balanceDraft: balanceDraft,
                step: step,
                completed: completed,
                defaultAccountId: defaultAccountId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, Profile>(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({defaultAccountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (defaultAccountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.defaultAccountId,
                        referencedTable: $$ProfilesTableReferences
                            ._defaultAccountIdTable(db),
                        referencedColumn: $$ProfilesTableReferences
                            ._defaultAccountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, $$ProfilesTableReferences),
      Profile,
      PrefetchHooks Function({bool defaultAccountId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
}
