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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    profiles,
    balanceAdjustments,
    adjustmentEdits,
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
              ({profilesRefs = false, balanceAdjustmentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (profilesRefs) db.profiles,
                    if (balanceAdjustmentsRefs) db.balanceAdjustments,
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
      PrefetchHooks Function({bool profilesRefs, bool balanceAdjustmentsRefs})
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
}
