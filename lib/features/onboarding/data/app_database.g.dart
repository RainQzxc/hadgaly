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
  static const VerificationMeta _creationKeyMeta = const VerificationMeta(
    'creationKey',
  );
  @override
  late final GeneratedColumn<String> creationKey = GeneratedColumn<String>(
    'creation_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, openingBalance, creationKey];
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
    if (data.containsKey('creation_key')) {
      context.handle(
        _creationKeyMeta,
        creationKey.isAcceptableOrUnknown(
          data['creation_key']!,
          _creationKeyMeta,
        ),
      );
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
      creationKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creation_key'],
      ),
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
  final String? creationKey;
  const Account({
    required this.id,
    required this.name,
    required this.openingBalance,
    this.creationKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['opening_balance'] = Variable<int>(openingBalance);
    if (!nullToAbsent || creationKey != null) {
      map['creation_key'] = Variable<String>(creationKey);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      openingBalance: Value(openingBalance),
      creationKey: creationKey == null && nullToAbsent
          ? const Value.absent()
          : Value(creationKey),
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
      creationKey: serializer.fromJson<String?>(json['creationKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'openingBalance': serializer.toJson<int>(openingBalance),
      'creationKey': serializer.toJson<String?>(creationKey),
    };
  }

  Account copyWith({
    int? id,
    String? name,
    int? openingBalance,
    Value<String?> creationKey = const Value.absent(),
  }) => Account(
    id: id ?? this.id,
    name: name ?? this.name,
    openingBalance: openingBalance ?? this.openingBalance,
    creationKey: creationKey.present ? creationKey.value : this.creationKey,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      creationKey: data.creationKey.present
          ? data.creationKey.value
          : this.creationKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('creationKey: $creationKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, openingBalance, creationKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.openingBalance == this.openingBalance &&
          other.creationKey == this.creationKey);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> openingBalance;
  final Value<String?> creationKey;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.creationKey = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int openingBalance,
    this.creationKey = const Value.absent(),
  }) : name = Value(name),
       openingBalance = Value(openingBalance);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? openingBalance,
    Expression<String>? creationKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (creationKey != null) 'creation_key': creationKey,
    });
  }

  AccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? openingBalance,
    Value<String?>? creationKey,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      openingBalance: openingBalance ?? this.openingBalance,
      creationKey: creationKey ?? this.creationKey,
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
    if (creationKey.present) {
      map['creation_key'] = Variable<String>(creationKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('creationKey: $creationKey')
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

class $BalanceAdjustmentsTable extends BalanceAdjustments
    with TableInfo<$BalanceAdjustmentsTable, BalanceAdjustment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BalanceAdjustmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    false,
    check: () => ComparableExpr(target).isBetweenValues(-maxMnt, maxMnt),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveAtMeta = const VerificationMeta(
    'effectiveAt',
  );
  @override
  late final GeneratedColumn<int> effectiveAt = GeneratedColumn<int>(
    'effective_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalTargetMeta = const VerificationMeta(
    'originalTarget',
  );
  @override
  late final GeneratedColumn<int> originalTarget = GeneratedColumn<int>(
    'original_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observedBalanceBeforeMeta =
      const VerificationMeta('observedBalanceBefore');
  @override
  late final GeneratedColumn<int> observedBalanceBefore = GeneratedColumn<int>(
    'observed_balance_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _requestKeyMeta = const VerificationMeta(
    'requestKey',
  );
  @override
  late final GeneratedColumn<String> requestKey = GeneratedColumn<String>(
    'request_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    target,
    effectiveAt,
    createdAt,
    originalTarget,
    observedBalanceBefore,
    revision,
    requestKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'balance_adjustments';
  @override
  VerificationContext validateIntegrity(
    Insertable<BalanceAdjustment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('effective_at')) {
      context.handle(
        _effectiveAtMeta,
        effectiveAt.isAcceptableOrUnknown(
          data['effective_at']!,
          _effectiveAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('original_target')) {
      context.handle(
        _originalTargetMeta,
        originalTarget.isAcceptableOrUnknown(
          data['original_target']!,
          _originalTargetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalTargetMeta);
    }
    if (data.containsKey('observed_balance_before')) {
      context.handle(
        _observedBalanceBeforeMeta,
        observedBalanceBefore.isAcceptableOrUnknown(
          data['observed_balance_before']!,
          _observedBalanceBeforeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observedBalanceBeforeMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('request_key')) {
      context.handle(
        _requestKeyMeta,
        requestKey.isAcceptableOrUnknown(data['request_key']!, _requestKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_requestKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BalanceAdjustment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BalanceAdjustment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      )!,
      effectiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effective_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      originalTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_target'],
      )!,
      observedBalanceBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}observed_balance_before'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      requestKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_key'],
      )!,
    );
  }

  @override
  $BalanceAdjustmentsTable createAlias(String alias) {
    return $BalanceAdjustmentsTable(attachedDatabase, alias);
  }
}

class BalanceAdjustment extends DataClass
    implements Insertable<BalanceAdjustment> {
  final int id;
  final int accountId;
  final int target;
  final int effectiveAt;
  final int createdAt;
  final int originalTarget;
  final int observedBalanceBefore;
  final int revision;
  final String requestKey;
  const BalanceAdjustment({
    required this.id,
    required this.accountId,
    required this.target,
    required this.effectiveAt,
    required this.createdAt,
    required this.originalTarget,
    required this.observedBalanceBefore,
    required this.revision,
    required this.requestKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    map['target'] = Variable<int>(target);
    map['effective_at'] = Variable<int>(effectiveAt);
    map['created_at'] = Variable<int>(createdAt);
    map['original_target'] = Variable<int>(originalTarget);
    map['observed_balance_before'] = Variable<int>(observedBalanceBefore);
    map['revision'] = Variable<int>(revision);
    map['request_key'] = Variable<String>(requestKey);
    return map;
  }

  BalanceAdjustmentsCompanion toCompanion(bool nullToAbsent) {
    return BalanceAdjustmentsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      target: Value(target),
      effectiveAt: Value(effectiveAt),
      createdAt: Value(createdAt),
      originalTarget: Value(originalTarget),
      observedBalanceBefore: Value(observedBalanceBefore),
      revision: Value(revision),
      requestKey: Value(requestKey),
    );
  }

  factory BalanceAdjustment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BalanceAdjustment(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      target: serializer.fromJson<int>(json['target']),
      effectiveAt: serializer.fromJson<int>(json['effectiveAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      originalTarget: serializer.fromJson<int>(json['originalTarget']),
      observedBalanceBefore: serializer.fromJson<int>(
        json['observedBalanceBefore'],
      ),
      revision: serializer.fromJson<int>(json['revision']),
      requestKey: serializer.fromJson<String>(json['requestKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'target': serializer.toJson<int>(target),
      'effectiveAt': serializer.toJson<int>(effectiveAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'originalTarget': serializer.toJson<int>(originalTarget),
      'observedBalanceBefore': serializer.toJson<int>(observedBalanceBefore),
      'revision': serializer.toJson<int>(revision),
      'requestKey': serializer.toJson<String>(requestKey),
    };
  }

  BalanceAdjustment copyWith({
    int? id,
    int? accountId,
    int? target,
    int? effectiveAt,
    int? createdAt,
    int? originalTarget,
    int? observedBalanceBefore,
    int? revision,
    String? requestKey,
  }) => BalanceAdjustment(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    target: target ?? this.target,
    effectiveAt: effectiveAt ?? this.effectiveAt,
    createdAt: createdAt ?? this.createdAt,
    originalTarget: originalTarget ?? this.originalTarget,
    observedBalanceBefore: observedBalanceBefore ?? this.observedBalanceBefore,
    revision: revision ?? this.revision,
    requestKey: requestKey ?? this.requestKey,
  );
  BalanceAdjustment copyWithCompanion(BalanceAdjustmentsCompanion data) {
    return BalanceAdjustment(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      target: data.target.present ? data.target.value : this.target,
      effectiveAt: data.effectiveAt.present
          ? data.effectiveAt.value
          : this.effectiveAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      originalTarget: data.originalTarget.present
          ? data.originalTarget.value
          : this.originalTarget,
      observedBalanceBefore: data.observedBalanceBefore.present
          ? data.observedBalanceBefore.value
          : this.observedBalanceBefore,
      revision: data.revision.present ? data.revision.value : this.revision,
      requestKey: data.requestKey.present
          ? data.requestKey.value
          : this.requestKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BalanceAdjustment(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('target: $target, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('originalTarget: $originalTarget, ')
          ..write('observedBalanceBefore: $observedBalanceBefore, ')
          ..write('revision: $revision, ')
          ..write('requestKey: $requestKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    target,
    effectiveAt,
    createdAt,
    originalTarget,
    observedBalanceBefore,
    revision,
    requestKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BalanceAdjustment &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.target == this.target &&
          other.effectiveAt == this.effectiveAt &&
          other.createdAt == this.createdAt &&
          other.originalTarget == this.originalTarget &&
          other.observedBalanceBefore == this.observedBalanceBefore &&
          other.revision == this.revision &&
          other.requestKey == this.requestKey);
}

class BalanceAdjustmentsCompanion extends UpdateCompanion<BalanceAdjustment> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<int> target;
  final Value<int> effectiveAt;
  final Value<int> createdAt;
  final Value<int> originalTarget;
  final Value<int> observedBalanceBefore;
  final Value<int> revision;
  final Value<String> requestKey;
  const BalanceAdjustmentsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.target = const Value.absent(),
    this.effectiveAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.originalTarget = const Value.absent(),
    this.observedBalanceBefore = const Value.absent(),
    this.revision = const Value.absent(),
    this.requestKey = const Value.absent(),
  });
  BalanceAdjustmentsCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    required int target,
    required int effectiveAt,
    required int createdAt,
    required int originalTarget,
    required int observedBalanceBefore,
    this.revision = const Value.absent(),
    required String requestKey,
  }) : accountId = Value(accountId),
       target = Value(target),
       effectiveAt = Value(effectiveAt),
       createdAt = Value(createdAt),
       originalTarget = Value(originalTarget),
       observedBalanceBefore = Value(observedBalanceBefore),
       requestKey = Value(requestKey);
  static Insertable<BalanceAdjustment> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<int>? target,
    Expression<int>? effectiveAt,
    Expression<int>? createdAt,
    Expression<int>? originalTarget,
    Expression<int>? observedBalanceBefore,
    Expression<int>? revision,
    Expression<String>? requestKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (target != null) 'target': target,
      if (effectiveAt != null) 'effective_at': effectiveAt,
      if (createdAt != null) 'created_at': createdAt,
      if (originalTarget != null) 'original_target': originalTarget,
      if (observedBalanceBefore != null)
        'observed_balance_before': observedBalanceBefore,
      if (revision != null) 'revision': revision,
      if (requestKey != null) 'request_key': requestKey,
    });
  }

  BalanceAdjustmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? accountId,
    Value<int>? target,
    Value<int>? effectiveAt,
    Value<int>? createdAt,
    Value<int>? originalTarget,
    Value<int>? observedBalanceBefore,
    Value<int>? revision,
    Value<String>? requestKey,
  }) {
    return BalanceAdjustmentsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      target: target ?? this.target,
      effectiveAt: effectiveAt ?? this.effectiveAt,
      createdAt: createdAt ?? this.createdAt,
      originalTarget: originalTarget ?? this.originalTarget,
      observedBalanceBefore:
          observedBalanceBefore ?? this.observedBalanceBefore,
      revision: revision ?? this.revision,
      requestKey: requestKey ?? this.requestKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (effectiveAt.present) {
      map['effective_at'] = Variable<int>(effectiveAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (originalTarget.present) {
      map['original_target'] = Variable<int>(originalTarget.value);
    }
    if (observedBalanceBefore.present) {
      map['observed_balance_before'] = Variable<int>(
        observedBalanceBefore.value,
      );
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (requestKey.present) {
      map['request_key'] = Variable<String>(requestKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BalanceAdjustmentsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('target: $target, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('originalTarget: $originalTarget, ')
          ..write('observedBalanceBefore: $observedBalanceBefore, ')
          ..write('revision: $revision, ')
          ..write('requestKey: $requestKey')
          ..write(')'))
        .toString();
  }
}

class $AdjustmentEditsTable extends AdjustmentEdits
    with TableInfo<$AdjustmentEditsTable, AdjustmentEdit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdjustmentEditsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _adjustmentIdMeta = const VerificationMeta(
    'adjustmentId',
  );
  @override
  late final GeneratedColumn<int> adjustmentId = GeneratedColumn<int>(
    'adjustment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES balance_adjustments (id)',
    ),
  );
  static const VerificationMeta _oldTargetMeta = const VerificationMeta(
    'oldTarget',
  );
  @override
  late final GeneratedColumn<int> oldTarget = GeneratedColumn<int>(
    'old_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newTargetMeta = const VerificationMeta(
    'newTarget',
  );
  @override
  late final GeneratedColumn<int> newTarget = GeneratedColumn<int>(
    'new_target',
    aliasedName,
    false,
    check: () => ComparableExpr(newTarget).isBetweenValues(-maxMnt, maxMnt),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editedAtMeta = const VerificationMeta(
    'editedAt',
  );
  @override
  late final GeneratedColumn<int> editedAt = GeneratedColumn<int>(
    'edited_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousRevisionMeta = const VerificationMeta(
    'previousRevision',
  );
  @override
  late final GeneratedColumn<int> previousRevision = GeneratedColumn<int>(
    'previous_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestKeyMeta = const VerificationMeta(
    'requestKey',
  );
  @override
  late final GeneratedColumn<String> requestKey = GeneratedColumn<String>(
    'request_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    adjustmentId,
    oldTarget,
    newTarget,
    editedAt,
    previousRevision,
    requestKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adjustment_edits';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdjustmentEdit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('adjustment_id')) {
      context.handle(
        _adjustmentIdMeta,
        adjustmentId.isAcceptableOrUnknown(
          data['adjustment_id']!,
          _adjustmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_adjustmentIdMeta);
    }
    if (data.containsKey('old_target')) {
      context.handle(
        _oldTargetMeta,
        oldTarget.isAcceptableOrUnknown(data['old_target']!, _oldTargetMeta),
      );
    } else if (isInserting) {
      context.missing(_oldTargetMeta);
    }
    if (data.containsKey('new_target')) {
      context.handle(
        _newTargetMeta,
        newTarget.isAcceptableOrUnknown(data['new_target']!, _newTargetMeta),
      );
    } else if (isInserting) {
      context.missing(_newTargetMeta);
    }
    if (data.containsKey('edited_at')) {
      context.handle(
        _editedAtMeta,
        editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_editedAtMeta);
    }
    if (data.containsKey('previous_revision')) {
      context.handle(
        _previousRevisionMeta,
        previousRevision.isAcceptableOrUnknown(
          data['previous_revision']!,
          _previousRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousRevisionMeta);
    }
    if (data.containsKey('request_key')) {
      context.handle(
        _requestKeyMeta,
        requestKey.isAcceptableOrUnknown(data['request_key']!, _requestKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_requestKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdjustmentEdit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdjustmentEdit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      adjustmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}adjustment_id'],
      )!,
      oldTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}old_target'],
      )!,
      newTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_target'],
      )!,
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edited_at'],
      )!,
      previousRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}previous_revision'],
      )!,
      requestKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_key'],
      )!,
    );
  }

  @override
  $AdjustmentEditsTable createAlias(String alias) {
    return $AdjustmentEditsTable(attachedDatabase, alias);
  }
}

class AdjustmentEdit extends DataClass implements Insertable<AdjustmentEdit> {
  final int id;
  final int adjustmentId;
  final int oldTarget;
  final int newTarget;
  final int editedAt;
  final int previousRevision;
  final String requestKey;
  const AdjustmentEdit({
    required this.id,
    required this.adjustmentId,
    required this.oldTarget,
    required this.newTarget,
    required this.editedAt,
    required this.previousRevision,
    required this.requestKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['adjustment_id'] = Variable<int>(adjustmentId);
    map['old_target'] = Variable<int>(oldTarget);
    map['new_target'] = Variable<int>(newTarget);
    map['edited_at'] = Variable<int>(editedAt);
    map['previous_revision'] = Variable<int>(previousRevision);
    map['request_key'] = Variable<String>(requestKey);
    return map;
  }

  AdjustmentEditsCompanion toCompanion(bool nullToAbsent) {
    return AdjustmentEditsCompanion(
      id: Value(id),
      adjustmentId: Value(adjustmentId),
      oldTarget: Value(oldTarget),
      newTarget: Value(newTarget),
      editedAt: Value(editedAt),
      previousRevision: Value(previousRevision),
      requestKey: Value(requestKey),
    );
  }

  factory AdjustmentEdit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdjustmentEdit(
      id: serializer.fromJson<int>(json['id']),
      adjustmentId: serializer.fromJson<int>(json['adjustmentId']),
      oldTarget: serializer.fromJson<int>(json['oldTarget']),
      newTarget: serializer.fromJson<int>(json['newTarget']),
      editedAt: serializer.fromJson<int>(json['editedAt']),
      previousRevision: serializer.fromJson<int>(json['previousRevision']),
      requestKey: serializer.fromJson<String>(json['requestKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'adjustmentId': serializer.toJson<int>(adjustmentId),
      'oldTarget': serializer.toJson<int>(oldTarget),
      'newTarget': serializer.toJson<int>(newTarget),
      'editedAt': serializer.toJson<int>(editedAt),
      'previousRevision': serializer.toJson<int>(previousRevision),
      'requestKey': serializer.toJson<String>(requestKey),
    };
  }

  AdjustmentEdit copyWith({
    int? id,
    int? adjustmentId,
    int? oldTarget,
    int? newTarget,
    int? editedAt,
    int? previousRevision,
    String? requestKey,
  }) => AdjustmentEdit(
    id: id ?? this.id,
    adjustmentId: adjustmentId ?? this.adjustmentId,
    oldTarget: oldTarget ?? this.oldTarget,
    newTarget: newTarget ?? this.newTarget,
    editedAt: editedAt ?? this.editedAt,
    previousRevision: previousRevision ?? this.previousRevision,
    requestKey: requestKey ?? this.requestKey,
  );
  AdjustmentEdit copyWithCompanion(AdjustmentEditsCompanion data) {
    return AdjustmentEdit(
      id: data.id.present ? data.id.value : this.id,
      adjustmentId: data.adjustmentId.present
          ? data.adjustmentId.value
          : this.adjustmentId,
      oldTarget: data.oldTarget.present ? data.oldTarget.value : this.oldTarget,
      newTarget: data.newTarget.present ? data.newTarget.value : this.newTarget,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      previousRevision: data.previousRevision.present
          ? data.previousRevision.value
          : this.previousRevision,
      requestKey: data.requestKey.present
          ? data.requestKey.value
          : this.requestKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdjustmentEdit(')
          ..write('id: $id, ')
          ..write('adjustmentId: $adjustmentId, ')
          ..write('oldTarget: $oldTarget, ')
          ..write('newTarget: $newTarget, ')
          ..write('editedAt: $editedAt, ')
          ..write('previousRevision: $previousRevision, ')
          ..write('requestKey: $requestKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    adjustmentId,
    oldTarget,
    newTarget,
    editedAt,
    previousRevision,
    requestKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdjustmentEdit &&
          other.id == this.id &&
          other.adjustmentId == this.adjustmentId &&
          other.oldTarget == this.oldTarget &&
          other.newTarget == this.newTarget &&
          other.editedAt == this.editedAt &&
          other.previousRevision == this.previousRevision &&
          other.requestKey == this.requestKey);
}

class AdjustmentEditsCompanion extends UpdateCompanion<AdjustmentEdit> {
  final Value<int> id;
  final Value<int> adjustmentId;
  final Value<int> oldTarget;
  final Value<int> newTarget;
  final Value<int> editedAt;
  final Value<int> previousRevision;
  final Value<String> requestKey;
  const AdjustmentEditsCompanion({
    this.id = const Value.absent(),
    this.adjustmentId = const Value.absent(),
    this.oldTarget = const Value.absent(),
    this.newTarget = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.previousRevision = const Value.absent(),
    this.requestKey = const Value.absent(),
  });
  AdjustmentEditsCompanion.insert({
    this.id = const Value.absent(),
    required int adjustmentId,
    required int oldTarget,
    required int newTarget,
    required int editedAt,
    required int previousRevision,
    required String requestKey,
  }) : adjustmentId = Value(adjustmentId),
       oldTarget = Value(oldTarget),
       newTarget = Value(newTarget),
       editedAt = Value(editedAt),
       previousRevision = Value(previousRevision),
       requestKey = Value(requestKey);
  static Insertable<AdjustmentEdit> custom({
    Expression<int>? id,
    Expression<int>? adjustmentId,
    Expression<int>? oldTarget,
    Expression<int>? newTarget,
    Expression<int>? editedAt,
    Expression<int>? previousRevision,
    Expression<String>? requestKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (adjustmentId != null) 'adjustment_id': adjustmentId,
      if (oldTarget != null) 'old_target': oldTarget,
      if (newTarget != null) 'new_target': newTarget,
      if (editedAt != null) 'edited_at': editedAt,
      if (previousRevision != null) 'previous_revision': previousRevision,
      if (requestKey != null) 'request_key': requestKey,
    });
  }

  AdjustmentEditsCompanion copyWith({
    Value<int>? id,
    Value<int>? adjustmentId,
    Value<int>? oldTarget,
    Value<int>? newTarget,
    Value<int>? editedAt,
    Value<int>? previousRevision,
    Value<String>? requestKey,
  }) {
    return AdjustmentEditsCompanion(
      id: id ?? this.id,
      adjustmentId: adjustmentId ?? this.adjustmentId,
      oldTarget: oldTarget ?? this.oldTarget,
      newTarget: newTarget ?? this.newTarget,
      editedAt: editedAt ?? this.editedAt,
      previousRevision: previousRevision ?? this.previousRevision,
      requestKey: requestKey ?? this.requestKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (adjustmentId.present) {
      map['adjustment_id'] = Variable<int>(adjustmentId.value);
    }
    if (oldTarget.present) {
      map['old_target'] = Variable<int>(oldTarget.value);
    }
    if (newTarget.present) {
      map['new_target'] = Variable<int>(newTarget.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<int>(editedAt.value);
    }
    if (previousRevision.present) {
      map['previous_revision'] = Variable<int>(previousRevision.value);
    }
    if (requestKey.present) {
      map['request_key'] = Variable<String>(requestKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdjustmentEditsCompanion(')
          ..write('id: $id, ')
          ..write('adjustmentId: $adjustmentId, ')
          ..write('oldTarget: $oldTarget, ')
          ..write('newTarget: $newTarget, ')
          ..write('editedAt: $editedAt, ')
          ..write('previousRevision: $previousRevision, ')
          ..write('requestKey: $requestKey')
          ..write(')'))
        .toString();
  }
}

class $LedgerSequencesTable extends LedgerSequences
    with TableInfo<$LedgerSequencesTable, LedgerSequence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerSequencesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    check: () => kind.isIn(['income', 'expense', 'adjustment']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, kind];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_sequences';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerSequence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerSequence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerSequence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
    );
  }

  @override
  $LedgerSequencesTable createAlias(String alias) {
    return $LedgerSequencesTable(attachedDatabase, alias);
  }
}

class LedgerSequence extends DataClass implements Insertable<LedgerSequence> {
  final int id;
  final String kind;
  const LedgerSequence({required this.id, required this.kind});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    return map;
  }

  LedgerSequencesCompanion toCompanion(bool nullToAbsent) {
    return LedgerSequencesCompanion(id: Value(id), kind: Value(kind));
  }

  factory LedgerSequence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerSequence(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
    };
  }

  LedgerSequence copyWith({int? id, String? kind}) =>
      LedgerSequence(id: id ?? this.id, kind: kind ?? this.kind);
  LedgerSequence copyWithCompanion(LedgerSequencesCompanion data) {
    return LedgerSequence(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerSequence(')
          ..write('id: $id, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerSequence &&
          other.id == this.id &&
          other.kind == this.kind);
}

class LedgerSequencesCompanion extends UpdateCompanion<LedgerSequence> {
  final Value<int> id;
  final Value<String> kind;
  const LedgerSequencesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
  });
  LedgerSequencesCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
  }) : kind = Value(kind);
  static Insertable<LedgerSequence> custom({
    Expression<int>? id,
    Expression<String>? kind,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
    });
  }

  LedgerSequencesCompanion copyWith({Value<int>? id, Value<String>? kind}) {
    return LedgerSequencesCompanion(id: id ?? this.id, kind: kind ?? this.kind);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerSequencesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    check: () => kind.isIn(['income', 'expense']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    check: () => icon.isIn(categoryIcons),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _creationKeyMeta = const VerificationMeta(
    'creationKey',
  );
  @override
  late final GeneratedColumn<String> creationKey = GeneratedColumn<String>(
    'creation_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    name,
    normalizedName,
    icon,
    archived,
    creationKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('creation_key')) {
      context.handle(
        _creationKeyMeta,
        creationKey.isAcceptableOrUnknown(
          data['creation_key']!,
          _creationKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creationKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      creationKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creation_key'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String kind;
  final String name;
  final String normalizedName;
  final String icon;
  final bool archived;
  final String creationKey;
  const Category({
    required this.id,
    required this.kind,
    required this.name,
    required this.normalizedName,
    required this.icon,
    required this.archived,
    required this.creationKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['icon'] = Variable<String>(icon);
    map['archived'] = Variable<bool>(archived);
    map['creation_key'] = Variable<String>(creationKey);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      kind: Value(kind),
      name: Value(name),
      normalizedName: Value(normalizedName),
      icon: Value(icon),
      archived: Value(archived),
      creationKey: Value(creationKey),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      icon: serializer.fromJson<String>(json['icon']),
      archived: serializer.fromJson<bool>(json['archived']),
      creationKey: serializer.fromJson<String>(json['creationKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'icon': serializer.toJson<String>(icon),
      'archived': serializer.toJson<bool>(archived),
      'creationKey': serializer.toJson<String>(creationKey),
    };
  }

  Category copyWith({
    int? id,
    String? kind,
    String? name,
    String? normalizedName,
    String? icon,
    bool? archived,
    String? creationKey,
  }) => Category(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    icon: icon ?? this.icon,
    archived: archived ?? this.archived,
    creationKey: creationKey ?? this.creationKey,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      icon: data.icon.present ? data.icon.value : this.icon,
      archived: data.archived.present ? data.archived.value : this.archived,
      creationKey: data.creationKey.present
          ? data.creationKey.value
          : this.creationKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('icon: $icon, ')
          ..write('archived: $archived, ')
          ..write('creationKey: $creationKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, name, normalizedName, icon, archived, creationKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.icon == this.icon &&
          other.archived == this.archived &&
          other.creationKey == this.creationKey);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String> icon;
  final Value<bool> archived;
  final Value<String> creationKey;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.icon = const Value.absent(),
    this.archived = const Value.absent(),
    this.creationKey = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String name,
    required String normalizedName,
    required String icon,
    this.archived = const Value.absent(),
    required String creationKey,
  }) : kind = Value(kind),
       name = Value(name),
       normalizedName = Value(normalizedName),
       icon = Value(icon),
       creationKey = Value(creationKey);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? icon,
    Expression<bool>? archived,
    Expression<String>? creationKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (icon != null) 'icon': icon,
      if (archived != null) 'archived': archived,
      if (creationKey != null) 'creation_key': creationKey,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String>? icon,
    Value<bool>? archived,
    Value<String>? creationKey,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      icon: icon ?? this.icon,
      archived: archived ?? this.archived,
      creationKey: creationKey ?? this.creationKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (creationKey.present) {
      map['creation_key'] = Variable<String>(creationKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('icon: $icon, ')
          ..write('archived: $archived, ')
          ..write('creationKey: $creationKey')
          ..write(')'))
        .toString();
  }
}

class $CashEntriesTable extends CashEntries
    with TableInfo<$CashEntriesTable, CashEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ledger_sequences (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    check: () => kind.isIn(['income', 'expense']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    check: () => ComparableExpr(amount).isBetweenValues(1, maxMnt),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveAtMeta = const VerificationMeta(
    'effectiveAt',
  );
  @override
  late final GeneratedColumn<int> effectiveAt = GeneratedColumn<int>(
    'effective_at',
    aliasedName,
    false,
    check: () => ComparableExpr(effectiveAt).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _requestKeyMeta = const VerificationMeta(
    'requestKey',
  );
  @override
  late final GeneratedColumn<String> requestKey = GeneratedColumn<String>(
    'request_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    categoryId,
    kind,
    amount,
    effectiveAt,
    createdAt,
    entryDate,
    note,
    requestKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('effective_at')) {
      context.handle(
        _effectiveAtMeta,
        effectiveAt.isAcceptableOrUnknown(
          data['effective_at']!,
          _effectiveAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('request_key')) {
      context.handle(
        _requestKeyMeta,
        requestKey.isAcceptableOrUnknown(data['request_key']!, _requestKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_requestKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      effectiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effective_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      requestKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_key'],
      )!,
    );
  }

  @override
  $CashEntriesTable createAlias(String alias) {
    return $CashEntriesTable(attachedDatabase, alias);
  }
}

class CashEntry extends DataClass implements Insertable<CashEntry> {
  final int id;
  final int accountId;
  final int categoryId;
  final String kind;
  final int amount;
  final int effectiveAt;
  final int createdAt;
  final String entryDate;
  final String note;
  final String requestKey;
  const CashEntry({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.kind,
    required this.amount,
    required this.effectiveAt,
    required this.createdAt,
    required this.entryDate,
    required this.note,
    required this.requestKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    map['category_id'] = Variable<int>(categoryId);
    map['kind'] = Variable<String>(kind);
    map['amount'] = Variable<int>(amount);
    map['effective_at'] = Variable<int>(effectiveAt);
    map['created_at'] = Variable<int>(createdAt);
    map['entry_date'] = Variable<String>(entryDate);
    map['note'] = Variable<String>(note);
    map['request_key'] = Variable<String>(requestKey);
    return map;
  }

  CashEntriesCompanion toCompanion(bool nullToAbsent) {
    return CashEntriesCompanion(
      id: Value(id),
      accountId: Value(accountId),
      categoryId: Value(categoryId),
      kind: Value(kind),
      amount: Value(amount),
      effectiveAt: Value(effectiveAt),
      createdAt: Value(createdAt),
      entryDate: Value(entryDate),
      note: Value(note),
      requestKey: Value(requestKey),
    );
  }

  factory CashEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashEntry(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      kind: serializer.fromJson<String>(json['kind']),
      amount: serializer.fromJson<int>(json['amount']),
      effectiveAt: serializer.fromJson<int>(json['effectiveAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      note: serializer.fromJson<String>(json['note']),
      requestKey: serializer.fromJson<String>(json['requestKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'categoryId': serializer.toJson<int>(categoryId),
      'kind': serializer.toJson<String>(kind),
      'amount': serializer.toJson<int>(amount),
      'effectiveAt': serializer.toJson<int>(effectiveAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'entryDate': serializer.toJson<String>(entryDate),
      'note': serializer.toJson<String>(note),
      'requestKey': serializer.toJson<String>(requestKey),
    };
  }

  CashEntry copyWith({
    int? id,
    int? accountId,
    int? categoryId,
    String? kind,
    int? amount,
    int? effectiveAt,
    int? createdAt,
    String? entryDate,
    String? note,
    String? requestKey,
  }) => CashEntry(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId ?? this.categoryId,
    kind: kind ?? this.kind,
    amount: amount ?? this.amount,
    effectiveAt: effectiveAt ?? this.effectiveAt,
    createdAt: createdAt ?? this.createdAt,
    entryDate: entryDate ?? this.entryDate,
    note: note ?? this.note,
    requestKey: requestKey ?? this.requestKey,
  );
  CashEntry copyWithCompanion(CashEntriesCompanion data) {
    return CashEntry(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      kind: data.kind.present ? data.kind.value : this.kind,
      amount: data.amount.present ? data.amount.value : this.amount,
      effectiveAt: data.effectiveAt.present
          ? data.effectiveAt.value
          : this.effectiveAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      note: data.note.present ? data.note.value : this.note,
      requestKey: data.requestKey.present
          ? data.requestKey.value
          : this.requestKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashEntry(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('kind: $kind, ')
          ..write('amount: $amount, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('entryDate: $entryDate, ')
          ..write('note: $note, ')
          ..write('requestKey: $requestKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    categoryId,
    kind,
    amount,
    effectiveAt,
    createdAt,
    entryDate,
    note,
    requestKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashEntry &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.kind == this.kind &&
          other.amount == this.amount &&
          other.effectiveAt == this.effectiveAt &&
          other.createdAt == this.createdAt &&
          other.entryDate == this.entryDate &&
          other.note == this.note &&
          other.requestKey == this.requestKey);
}

class CashEntriesCompanion extends UpdateCompanion<CashEntry> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<int> categoryId;
  final Value<String> kind;
  final Value<int> amount;
  final Value<int> effectiveAt;
  final Value<int> createdAt;
  final Value<String> entryDate;
  final Value<String> note;
  final Value<String> requestKey;
  const CashEntriesCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.kind = const Value.absent(),
    this.amount = const Value.absent(),
    this.effectiveAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.note = const Value.absent(),
    this.requestKey = const Value.absent(),
  });
  CashEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    required int categoryId,
    required String kind,
    required int amount,
    required int effectiveAt,
    required int createdAt,
    required String entryDate,
    this.note = const Value.absent(),
    required String requestKey,
  }) : accountId = Value(accountId),
       categoryId = Value(categoryId),
       kind = Value(kind),
       amount = Value(amount),
       effectiveAt = Value(effectiveAt),
       createdAt = Value(createdAt),
       entryDate = Value(entryDate),
       requestKey = Value(requestKey);
  static Insertable<CashEntry> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<int>? categoryId,
    Expression<String>? kind,
    Expression<int>? amount,
    Expression<int>? effectiveAt,
    Expression<int>? createdAt,
    Expression<String>? entryDate,
    Expression<String>? note,
    Expression<String>? requestKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (kind != null) 'kind': kind,
      if (amount != null) 'amount': amount,
      if (effectiveAt != null) 'effective_at': effectiveAt,
      if (createdAt != null) 'created_at': createdAt,
      if (entryDate != null) 'entry_date': entryDate,
      if (note != null) 'note': note,
      if (requestKey != null) 'request_key': requestKey,
    });
  }

  CashEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? accountId,
    Value<int>? categoryId,
    Value<String>? kind,
    Value<int>? amount,
    Value<int>? effectiveAt,
    Value<int>? createdAt,
    Value<String>? entryDate,
    Value<String>? note,
    Value<String>? requestKey,
  }) {
    return CashEntriesCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      kind: kind ?? this.kind,
      amount: amount ?? this.amount,
      effectiveAt: effectiveAt ?? this.effectiveAt,
      createdAt: createdAt ?? this.createdAt,
      entryDate: entryDate ?? this.entryDate,
      note: note ?? this.note,
      requestKey: requestKey ?? this.requestKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (effectiveAt.present) {
      map['effective_at'] = Variable<int>(effectiveAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (requestKey.present) {
      map['request_key'] = Variable<String>(requestKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashEntriesCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('kind: $kind, ')
          ..write('amount: $amount, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('entryDate: $entryDate, ')
          ..write('note: $note, ')
          ..write('requestKey: $requestKey')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $BalanceAdjustmentsTable balanceAdjustments =
      $BalanceAdjustmentsTable(this);
  late final $AdjustmentEditsTable adjustmentEdits = $AdjustmentEditsTable(
    this,
  );
  late final $LedgerSequencesTable ledgerSequences = $LedgerSequencesTable(
    this,
  );
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CashEntriesTable cashEntries = $CashEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    profiles,
    balanceAdjustments,
    adjustmentEdits,
    ledgerSequences,
    categories,
    cashEntries,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  required String name,
  required int openingBalance,
  Value<String?> creationKey,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> openingBalance,
  Value<String?> creationKey,
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

  static MultiTypedResultKey<$BalanceAdjustmentsTable, List<BalanceAdjustment>>
  _balanceAdjustmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.balanceAdjustments,
        aliasName: 'accounts__id__balance_adjustments__account_id',
      );

  $$BalanceAdjustmentsTableProcessedTableManager get balanceAdjustmentsRefs {
    final manager = $$BalanceAdjustmentsTableTableManager(
      $_db,
      $_db.balanceAdjustments,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _balanceAdjustmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CashEntriesTable, List<CashEntry>>
  _cashEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashEntries,
    aliasName: 'accounts__id__cash_entries__account_id',
  );

  $$CashEntriesTableProcessedTableManager get cashEntriesRefs {
    final manager = $$CashEntriesTableTableManager(
      $_db,
      $_db.cashEntries,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cashEntriesRefsTable($_db));
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

  ColumnFilters<String> get creationKey => $composableBuilder(
    column: $table.creationKey,
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

  Expression<bool> balanceAdjustmentsRefs(
    Expression<bool> Function($$BalanceAdjustmentsTableFilterComposer f) f,
  ) {
    final $$BalanceAdjustmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.balanceAdjustments,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalanceAdjustmentsTableFilterComposer(
            $db: $db,
            $table: $db.balanceAdjustments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cashEntriesRefs(
    Expression<bool> Function($$CashEntriesTableFilterComposer f) f,
  ) {
    final $$CashEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashEntries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cashEntries,
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

  ColumnOrderings<String> get creationKey => $composableBuilder(
    column: $table.creationKey,
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

  GeneratedColumn<String> get creationKey => $composableBuilder(
    column: $table.creationKey,
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

  Expression<T> balanceAdjustmentsRefs<T extends Object>(
    Expression<T> Function($$BalanceAdjustmentsTableAnnotationComposer a) f,
  ) {
    final $$BalanceAdjustmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.balanceAdjustments,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BalanceAdjustmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.balanceAdjustments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> cashEntriesRefs<T extends Object>(
    Expression<T> Function($$CashEntriesTableAnnotationComposer a) f,
  ) {
    final $$CashEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashEntries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cashEntries,
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
          PrefetchHooks Function({
            bool profilesRefs,
            bool balanceAdjustmentsRefs,
            bool cashEntriesRefs,
          })
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
                Value<String?> creationKey = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                openingBalance: openingBalance,
                creationKey: creationKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int openingBalance,
                Value<String?> creationKey = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                openingBalance: openingBalance,
                creationKey: creationKey,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, Account>(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profilesRefs = false,
                balanceAdjustmentsRefs = false,
                cashEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (profilesRefs) db.profiles,
                    if (balanceAdjustmentsRefs) db.balanceAdjustments,
                    if (cashEntriesRefs) db.cashEntries,
                  ],
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
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).profilesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'default_account_id',
                          typedResults: items,
                        ),
                      if (balanceAdjustmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Account,
                          $AccountsTable,
                          BalanceAdjustment,
                          $BalanceAdjustmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._balanceAdjustmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).balanceAdjustmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'account_id',
                          typedResults: items,
                        ),
                      if (cashEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          Account,
                          $AccountsTable,
                          CashEntry,
                          $CashEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._cashEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).cashEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'account_id',
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
      PrefetchHooks Function({
        bool profilesRefs,
        bool balanceAdjustmentsRefs,
        bool cashEntriesRefs,
      })
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
typedef $$BalanceAdjustmentsTableCreateCompanionBuilder =
    BalanceAdjustmentsCompanion Function({
      Value<int> id,
      required int accountId,
      required int target,
      required int effectiveAt,
      required int createdAt,
      required int originalTarget,
      required int observedBalanceBefore,
      Value<int> revision,
      required String requestKey,
    });
typedef $$BalanceAdjustmentsTableUpdateCompanionBuilder =
    BalanceAdjustmentsCompanion Function({
      Value<int> id,
      Value<int> accountId,
      Value<int> target,
      Value<int> effectiveAt,
      Value<int> createdAt,
      Value<int> originalTarget,
      Value<int> observedBalanceBefore,
      Value<int> revision,
      Value<String> requestKey,
    });

final class $$BalanceAdjustmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BalanceAdjustmentsTable,
          BalanceAdjustment
        > {
  $$BalanceAdjustmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('balance_adjustments__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AdjustmentEditsTable, List<AdjustmentEdit>>
  _adjustmentEditsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.adjustmentEdits,
    aliasName: 'balance_adjustments__id__adjustment_edits__adjustment_id',
  );

  $$AdjustmentEditsTableProcessedTableManager get adjustmentEditsRefs {
    final manager = $$AdjustmentEditsTableTableManager(
      $_db,
      $_db.adjustmentEdits,
    ).filter((f) => f.adjustmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _adjustmentEditsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BalanceAdjustmentsTableFilterComposer
    extends Composer<_$AppDatabase, $BalanceAdjustmentsTable> {
  $$BalanceAdjustmentsTableFilterComposer({
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

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalTarget => $composableBuilder(
    column: $table.originalTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get observedBalanceBefore => $composableBuilder(
    column: $table.observedBalanceBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
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

  Expression<bool> adjustmentEditsRefs(
    Expression<bool> Function($$AdjustmentEditsTableFilterComposer f) f,
  ) {
    final $$AdjustmentEditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adjustmentEdits,
      getReferencedColumn: (t) => t.adjustmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdjustmentEditsTableFilterComposer(
            $db: $db,
            $table: $db.adjustmentEdits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BalanceAdjustmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $BalanceAdjustmentsTable> {
  $$BalanceAdjustmentsTableOrderingComposer({
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

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalTarget => $composableBuilder(
    column: $table.originalTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get observedBalanceBefore => $composableBuilder(
    column: $table.observedBalanceBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
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

class $$BalanceAdjustmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BalanceAdjustmentsTable> {
  $$BalanceAdjustmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<int> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get originalTarget => $composableBuilder(
    column: $table.originalTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get observedBalanceBefore => $composableBuilder(
    column: $table.observedBalanceBefore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => column,
  );

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
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

  Expression<T> adjustmentEditsRefs<T extends Object>(
    Expression<T> Function($$AdjustmentEditsTableAnnotationComposer a) f,
  ) {
    final $$AdjustmentEditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adjustmentEdits,
      getReferencedColumn: (t) => t.adjustmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdjustmentEditsTableAnnotationComposer(
            $db: $db,
            $table: $db.adjustmentEdits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BalanceAdjustmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BalanceAdjustmentsTable,
          BalanceAdjustment,
          $$BalanceAdjustmentsTableFilterComposer,
          $$BalanceAdjustmentsTableOrderingComposer,
          $$BalanceAdjustmentsTableAnnotationComposer,
          $$BalanceAdjustmentsTableCreateCompanionBuilder,
          $$BalanceAdjustmentsTableUpdateCompanionBuilder,
          (BalanceAdjustment, $$BalanceAdjustmentsTableReferences),
          BalanceAdjustment,
          PrefetchHooks Function({bool accountId, bool adjustmentEditsRefs})
        > {
  $$BalanceAdjustmentsTableTableManager(
    _$AppDatabase db,
    $BalanceAdjustmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BalanceAdjustmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BalanceAdjustmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BalanceAdjustmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<int> target = const Value.absent(),
                Value<int> effectiveAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> originalTarget = const Value.absent(),
                Value<int> observedBalanceBefore = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> requestKey = const Value.absent(),
              }) => BalanceAdjustmentsCompanion(
                id: id,
                accountId: accountId,
                target: target,
                effectiveAt: effectiveAt,
                createdAt: createdAt,
                originalTarget: originalTarget,
                observedBalanceBefore: observedBalanceBefore,
                revision: revision,
                requestKey: requestKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int accountId,
                required int target,
                required int effectiveAt,
                required int createdAt,
                required int originalTarget,
                required int observedBalanceBefore,
                Value<int> revision = const Value.absent(),
                required String requestKey,
              }) => BalanceAdjustmentsCompanion.insert(
                id: id,
                accountId: accountId,
                target: target,
                effectiveAt: effectiveAt,
                createdAt: createdAt,
                originalTarget: originalTarget,
                observedBalanceBefore: observedBalanceBefore,
                revision: revision,
                requestKey: requestKey,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BalanceAdjustmentsTable, BalanceAdjustment>(
                    table,
                  ),
                  $$BalanceAdjustmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({accountId = false, adjustmentEditsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (adjustmentEditsRefs) db.adjustmentEdits,
                  ],
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
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$BalanceAdjustmentsTableReferences
                                ._accountIdTable(db),
                            referencedColumn:
                                $$BalanceAdjustmentsTableReferences
                                    ._accountIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (adjustmentEditsRefs)
                        await $_getPrefetchedDataByColumns<
                          BalanceAdjustment,
                          $BalanceAdjustmentsTable,
                          AdjustmentEdit,
                          $AdjustmentEditsTable
                        >(
                          currentTable: table,
                          referencedTable: $$BalanceAdjustmentsTableReferences
                              ._adjustmentEditsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BalanceAdjustmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).adjustmentEditsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'adjustment_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BalanceAdjustmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BalanceAdjustmentsTable,
      BalanceAdjustment,
      $$BalanceAdjustmentsTableFilterComposer,
      $$BalanceAdjustmentsTableOrderingComposer,
      $$BalanceAdjustmentsTableAnnotationComposer,
      $$BalanceAdjustmentsTableCreateCompanionBuilder,
      $$BalanceAdjustmentsTableUpdateCompanionBuilder,
      (BalanceAdjustment, $$BalanceAdjustmentsTableReferences),
      BalanceAdjustment,
      PrefetchHooks Function({bool accountId, bool adjustmentEditsRefs})
    >;
typedef $$AdjustmentEditsTableCreateCompanionBuilder =
    AdjustmentEditsCompanion Function({
      Value<int> id,
      required int adjustmentId,
      required int oldTarget,
      required int newTarget,
      required int editedAt,
      required int previousRevision,
      required String requestKey,
    });
typedef $$AdjustmentEditsTableUpdateCompanionBuilder =
    AdjustmentEditsCompanion Function({
      Value<int> id,
      Value<int> adjustmentId,
      Value<int> oldTarget,
      Value<int> newTarget,
      Value<int> editedAt,
      Value<int> previousRevision,
      Value<String> requestKey,
    });

final class $$AdjustmentEditsTableReferences
    extends
        BaseReferences<_$AppDatabase, $AdjustmentEditsTable, AdjustmentEdit> {
  $$AdjustmentEditsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BalanceAdjustmentsTable _adjustmentIdTable(_$AppDatabase db) => db
      .balanceAdjustments
      .createAlias('adjustment_edits__adjustment_id__balance_adjustments__id');

  $$BalanceAdjustmentsTableProcessedTableManager get adjustmentId {
    final $_column = $_itemColumn<int>('adjustment_id')!;

    final manager = $$BalanceAdjustmentsTableTableManager(
      $_db,
      $_db.balanceAdjustments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_adjustmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AdjustmentEditsTableFilterComposer
    extends Composer<_$AppDatabase, $AdjustmentEditsTable> {
  $$AdjustmentEditsTableFilterComposer({
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

  ColumnFilters<int> get oldTarget => $composableBuilder(
    column: $table.oldTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newTarget => $composableBuilder(
    column: $table.newTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previousRevision => $composableBuilder(
    column: $table.previousRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => ColumnFilters(column),
  );

  $$BalanceAdjustmentsTableFilterComposer get adjustmentId {
    final $$BalanceAdjustmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.adjustmentId,
      referencedTable: $db.balanceAdjustments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalanceAdjustmentsTableFilterComposer(
            $db: $db,
            $table: $db.balanceAdjustments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdjustmentEditsTableOrderingComposer
    extends Composer<_$AppDatabase, $AdjustmentEditsTable> {
  $$AdjustmentEditsTableOrderingComposer({
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

  ColumnOrderings<int> get oldTarget => $composableBuilder(
    column: $table.oldTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newTarget => $composableBuilder(
    column: $table.newTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previousRevision => $composableBuilder(
    column: $table.previousRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$BalanceAdjustmentsTableOrderingComposer get adjustmentId {
    final $$BalanceAdjustmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.adjustmentId,
      referencedTable: $db.balanceAdjustments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalanceAdjustmentsTableOrderingComposer(
            $db: $db,
            $table: $db.balanceAdjustments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdjustmentEditsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdjustmentEditsTable> {
  $$AdjustmentEditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get oldTarget =>
      $composableBuilder(column: $table.oldTarget, builder: (column) => column);

  GeneratedColumn<int> get newTarget =>
      $composableBuilder(column: $table.newTarget, builder: (column) => column);

  GeneratedColumn<int> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  GeneratedColumn<int> get previousRevision => $composableBuilder(
    column: $table.previousRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => column,
  );

  $$BalanceAdjustmentsTableAnnotationComposer get adjustmentId {
    final $$BalanceAdjustmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.adjustmentId,
          referencedTable: $db.balanceAdjustments,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BalanceAdjustmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.balanceAdjustments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AdjustmentEditsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdjustmentEditsTable,
          AdjustmentEdit,
          $$AdjustmentEditsTableFilterComposer,
          $$AdjustmentEditsTableOrderingComposer,
          $$AdjustmentEditsTableAnnotationComposer,
          $$AdjustmentEditsTableCreateCompanionBuilder,
          $$AdjustmentEditsTableUpdateCompanionBuilder,
          (AdjustmentEdit, $$AdjustmentEditsTableReferences),
          AdjustmentEdit,
          PrefetchHooks Function({bool adjustmentId})
        > {
  $$AdjustmentEditsTableTableManager(
    _$AppDatabase db,
    $AdjustmentEditsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdjustmentEditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdjustmentEditsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdjustmentEditsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> adjustmentId = const Value.absent(),
                Value<int> oldTarget = const Value.absent(),
                Value<int> newTarget = const Value.absent(),
                Value<int> editedAt = const Value.absent(),
                Value<int> previousRevision = const Value.absent(),
                Value<String> requestKey = const Value.absent(),
              }) => AdjustmentEditsCompanion(
                id: id,
                adjustmentId: adjustmentId,
                oldTarget: oldTarget,
                newTarget: newTarget,
                editedAt: editedAt,
                previousRevision: previousRevision,
                requestKey: requestKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int adjustmentId,
                required int oldTarget,
                required int newTarget,
                required int editedAt,
                required int previousRevision,
                required String requestKey,
              }) => AdjustmentEditsCompanion.insert(
                id: id,
                adjustmentId: adjustmentId,
                oldTarget: oldTarget,
                newTarget: newTarget,
                editedAt: editedAt,
                previousRevision: previousRevision,
                requestKey: requestKey,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AdjustmentEditsTable, AdjustmentEdit>(table),
                  $$AdjustmentEditsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({adjustmentId = false}) {
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
                    if (adjustmentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.adjustmentId,
                        referencedTable: $$AdjustmentEditsTableReferences
                            ._adjustmentIdTable(db),
                        referencedColumn: $$AdjustmentEditsTableReferences
                            ._adjustmentIdTable(db)
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

typedef $$AdjustmentEditsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdjustmentEditsTable,
      AdjustmentEdit,
      $$AdjustmentEditsTableFilterComposer,
      $$AdjustmentEditsTableOrderingComposer,
      $$AdjustmentEditsTableAnnotationComposer,
      $$AdjustmentEditsTableCreateCompanionBuilder,
      $$AdjustmentEditsTableUpdateCompanionBuilder,
      (AdjustmentEdit, $$AdjustmentEditsTableReferences),
      AdjustmentEdit,
      PrefetchHooks Function({bool adjustmentId})
    >;
typedef $$LedgerSequencesTableCreateCompanionBuilder =
    LedgerSequencesCompanion Function({Value<int> id, required String kind});
typedef $$LedgerSequencesTableUpdateCompanionBuilder =
    LedgerSequencesCompanion Function({Value<int> id, Value<String> kind});

final class $$LedgerSequencesTableReferences
    extends
        BaseReferences<_$AppDatabase, $LedgerSequencesTable, LedgerSequence> {
  $$LedgerSequencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CashEntriesTable, List<CashEntry>>
  _cashEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashEntries,
    aliasName: 'ledger_sequences__id__cash_entries__id',
  );

  $$CashEntriesTableProcessedTableManager get cashEntriesRefs {
    final manager = $$CashEntriesTableTableManager(
      $_db,
      $_db.cashEntries,
    ).filter((f) => f.id.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cashEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LedgerSequencesTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerSequencesTable> {
  $$LedgerSequencesTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cashEntriesRefs(
    Expression<bool> Function($$CashEntriesTableFilterComposer f) f,
  ) {
    final $$CashEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cashEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LedgerSequencesTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerSequencesTable> {
  $$LedgerSequencesTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LedgerSequencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerSequencesTable> {
  $$LedgerSequencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  Expression<T> cashEntriesRefs<T extends Object>(
    Expression<T> Function($$CashEntriesTableAnnotationComposer a) f,
  ) {
    final $$CashEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cashEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LedgerSequencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgerSequencesTable,
          LedgerSequence,
          $$LedgerSequencesTableFilterComposer,
          $$LedgerSequencesTableOrderingComposer,
          $$LedgerSequencesTableAnnotationComposer,
          $$LedgerSequencesTableCreateCompanionBuilder,
          $$LedgerSequencesTableUpdateCompanionBuilder,
          (LedgerSequence, $$LedgerSequencesTableReferences),
          LedgerSequence,
          PrefetchHooks Function({bool cashEntriesRefs})
        > {
  $$LedgerSequencesTableTableManager(
    _$AppDatabase db,
    $LedgerSequencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerSequencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerSequencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerSequencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> kind = const Value.absent(),
          }) => LedgerSequencesCompanion(id: id, kind: kind),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String kind,
          }) => LedgerSequencesCompanion.insert(id: id, kind: kind),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LedgerSequencesTable, LedgerSequence>(table),
                  $$LedgerSequencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cashEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cashEntriesRefs) db.cashEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cashEntriesRefs)
                    await $_getPrefetchedDataByColumns<
                      LedgerSequence,
                      $LedgerSequencesTable,
                      CashEntry,
                      $CashEntriesTable
                    >(
                      currentTable: table,
                      referencedTable: $$LedgerSequencesTableReferences
                          ._cashEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LedgerSequencesTableReferences(
                            db,
                            table,
                            p0,
                          ).cashEntriesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LedgerSequencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgerSequencesTable,
      LedgerSequence,
      $$LedgerSequencesTableFilterComposer,
      $$LedgerSequencesTableOrderingComposer,
      $$LedgerSequencesTableAnnotationComposer,
      $$LedgerSequencesTableCreateCompanionBuilder,
      $$LedgerSequencesTableUpdateCompanionBuilder,
      (LedgerSequence, $$LedgerSequencesTableReferences),
      LedgerSequence,
      PrefetchHooks Function({bool cashEntriesRefs})
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String kind,
  required String name,
  required String normalizedName,
  required String icon,
  Value<bool> archived,
  required String creationKey,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> kind,
  Value<String> name,
  Value<String> normalizedName,
  Value<String> icon,
  Value<bool> archived,
  Value<String> creationKey,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CashEntriesTable, List<CashEntry>>
  _cashEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashEntries,
    aliasName: 'categories__id__cash_entries__category_id',
  );

  $$CashEntriesTableProcessedTableManager get cashEntriesRefs {
    final manager = $$CashEntriesTableTableManager(
      $_db,
      $_db.cashEntries,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cashEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creationKey => $composableBuilder(
    column: $table.creationKey,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cashEntriesRefs(
    Expression<bool> Function($$CashEntriesTableFilterComposer f) f,
  ) {
    final $$CashEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashEntries,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cashEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creationKey => $composableBuilder(
    column: $table.creationKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get creationKey => $composableBuilder(
    column: $table.creationKey,
    builder: (column) => column,
  );

  Expression<T> cashEntriesRefs<T extends Object>(
    Expression<T> Function($$CashEntriesTableAnnotationComposer a) f,
  ) {
    final $$CashEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashEntries,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cashEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool cashEntriesRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String> creationKey = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                kind: kind,
                name: name,
                normalizedName: normalizedName,
                icon: icon,
                archived: archived,
                creationKey: creationKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required String name,
                required String normalizedName,
                required String icon,
                Value<bool> archived = const Value.absent(),
                required String creationKey,
              }) => CategoriesCompanion.insert(
                id: id,
                kind: kind,
                name: name,
                normalizedName: normalizedName,
                icon: icon,
                archived: archived,
                creationKey: creationKey,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, Category>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cashEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cashEntriesRefs) db.cashEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cashEntriesRefs)
                    await $_getPrefetchedDataByColumns<
                      Category,
                      $CategoriesTable,
                      CashEntry,
                      $CashEntriesTable
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._cashEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).cashEntriesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'category_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool cashEntriesRefs})
    >;
typedef $$CashEntriesTableCreateCompanionBuilder =
    CashEntriesCompanion Function({
      Value<int> id,
      required int accountId,
      required int categoryId,
      required String kind,
      required int amount,
      required int effectiveAt,
      required int createdAt,
      required String entryDate,
      Value<String> note,
      required String requestKey,
    });
typedef $$CashEntriesTableUpdateCompanionBuilder =
    CashEntriesCompanion Function({
      Value<int> id,
      Value<int> accountId,
      Value<int> categoryId,
      Value<String> kind,
      Value<int> amount,
      Value<int> effectiveAt,
      Value<int> createdAt,
      Value<String> entryDate,
      Value<String> note,
      Value<String> requestKey,
    });

final class $$CashEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $CashEntriesTable, CashEntry> {
  $$CashEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LedgerSequencesTable _idTable(_$AppDatabase db) =>
      db.ledgerSequences.createAlias('cash_entries__id__ledger_sequences__id');

  $$LedgerSequencesTableProcessedTableManager get id {
    final $_column = $_itemColumn<int>('id')!;

    final manager = $$LedgerSequencesTableTableManager(
      $_db,
      $_db.ledgerSequences,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_idTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('cash_entries__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('cash_entries__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CashEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CashEntriesTable> {
  $$CashEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => ColumnFilters(column),
  );

  $$LedgerSequencesTableFilterComposer get id {
    final $$LedgerSequencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerSequences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerSequencesTableFilterComposer(
            $db: $db,
            $table: $db.ledgerSequences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
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

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CashEntriesTable> {
  $$CashEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$LedgerSequencesTableOrderingComposer get id {
    final $$LedgerSequencesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerSequences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerSequencesTableOrderingComposer(
            $db: $db,
            $table: $db.ledgerSequences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
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

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashEntriesTable> {
  $$CashEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => column,
  );

  $$LedgerSequencesTableAnnotationComposer get id {
    final $$LedgerSequencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerSequences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerSequencesTableAnnotationComposer(
            $db: $db,
            $table: $db.ledgerSequences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
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

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashEntriesTable,
          CashEntry,
          $$CashEntriesTableFilterComposer,
          $$CashEntriesTableOrderingComposer,
          $$CashEntriesTableAnnotationComposer,
          $$CashEntriesTableCreateCompanionBuilder,
          $$CashEntriesTableUpdateCompanionBuilder,
          (CashEntry, $$CashEntriesTableReferences),
          CashEntry,
          PrefetchHooks Function({bool id, bool accountId, bool categoryId})
        > {
  $$CashEntriesTableTableManager(_$AppDatabase db, $CashEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> effectiveAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> entryDate = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> requestKey = const Value.absent(),
              }) => CashEntriesCompanion(
                id: id,
                accountId: accountId,
                categoryId: categoryId,
                kind: kind,
                amount: amount,
                effectiveAt: effectiveAt,
                createdAt: createdAt,
                entryDate: entryDate,
                note: note,
                requestKey: requestKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int accountId,
                required int categoryId,
                required String kind,
                required int amount,
                required int effectiveAt,
                required int createdAt,
                required String entryDate,
                Value<String> note = const Value.absent(),
                required String requestKey,
              }) => CashEntriesCompanion.insert(
                id: id,
                accountId: accountId,
                categoryId: categoryId,
                kind: kind,
                amount: amount,
                effectiveAt: effectiveAt,
                createdAt: createdAt,
                entryDate: entryDate,
                note: note,
                requestKey: requestKey,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CashEntriesTable, CashEntry>(table),
                  $$CashEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({id = false, accountId = false, categoryId = false}) {
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
                        if (id) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.id,
                            referencedTable: $$CashEntriesTableReferences
                                ._idTable(db),
                            referencedColumn: $$CashEntriesTableReferences
                                ._idTable(db)
                                .id,
                          ) as T;
                        }
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$CashEntriesTableReferences
                                ._accountIdTable(db),
                            referencedColumn: $$CashEntriesTableReferences
                                ._accountIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$CashEntriesTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$CashEntriesTableReferences
                                ._categoryIdTable(db)
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

typedef $$CashEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashEntriesTable,
      CashEntry,
      $$CashEntriesTableFilterComposer,
      $$CashEntriesTableOrderingComposer,
      $$CashEntriesTableAnnotationComposer,
      $$CashEntriesTableCreateCompanionBuilder,
      $$CashEntriesTableUpdateCompanionBuilder,
      (CashEntry, $$CashEntriesTableReferences),
      CashEntry,
      PrefetchHooks Function({bool id, bool accountId, bool categoryId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$BalanceAdjustmentsTableTableManager get balanceAdjustments =>
      $$BalanceAdjustmentsTableTableManager(_db, _db.balanceAdjustments);
  $$AdjustmentEditsTableTableManager get adjustmentEdits =>
      $$AdjustmentEditsTableTableManager(_db, _db.adjustmentEdits);
  $$LedgerSequencesTableTableManager get ledgerSequences =>
      $$LedgerSequencesTableTableManager(_db, _db.ledgerSequences);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CashEntriesTableTableManager get cashEntries =>
      $$CashEntriesTableTableManager(_db, _db.cashEntries);
}
