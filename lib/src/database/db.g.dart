// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyTypeMeta = const VerificationMeta(
    'frequencyType',
  );
  @override
  late final GeneratedColumn<String> frequencyType = GeneratedColumn<String>(
    'frequency_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('daily'),
  );
  static const VerificationMeta _targetDaysPerWeekMeta = const VerificationMeta(
    'targetDaysPerWeek',
  );
  @override
  late final GeneratedColumn<int> targetDaysPerWeek = GeneratedColumn<int>(
    'target_days_per_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _skipsAllowedPerWeekMeta =
      const VerificationMeta('skipsAllowedPerWeek');
  @override
  late final GeneratedColumn<int> skipsAllowedPerWeek = GeneratedColumn<int>(
    'skips_allowed_per_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    frequencyType,
    targetDaysPerWeek,
    skipsAllowedPerWeek,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('frequency_type')) {
      context.handle(
        _frequencyTypeMeta,
        frequencyType.isAcceptableOrUnknown(
          data['frequency_type']!,
          _frequencyTypeMeta,
        ),
      );
    }
    if (data.containsKey('target_days_per_week')) {
      context.handle(
        _targetDaysPerWeekMeta,
        targetDaysPerWeek.isAcceptableOrUnknown(
          data['target_days_per_week']!,
          _targetDaysPerWeekMeta,
        ),
      );
    }
    if (data.containsKey('skips_allowed_per_week')) {
      context.handle(
        _skipsAllowedPerWeekMeta,
        skipsAllowedPerWeek.isAcceptableOrUnknown(
          data['skips_allowed_per_week']!,
          _skipsAllowedPerWeekMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      frequencyType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}frequency_type'],
          )!,
      targetDaysPerWeek:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}target_days_per_week'],
          )!,
      skipsAllowedPerWeek:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}skips_allowed_per_week'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final String id;
  final String userId;
  final String name;
  final String frequencyType;
  final int targetDaysPerWeek;
  final int skipsAllowedPerWeek;
  final DateTime createdAt;
  final bool synced;
  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.frequencyType,
    required this.targetDaysPerWeek,
    required this.skipsAllowedPerWeek,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['frequency_type'] = Variable<String>(frequencyType);
    map['target_days_per_week'] = Variable<int>(targetDaysPerWeek);
    map['skips_allowed_per_week'] = Variable<int>(skipsAllowedPerWeek);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      frequencyType: Value(frequencyType),
      targetDaysPerWeek: Value(targetDaysPerWeek),
      skipsAllowedPerWeek: Value(skipsAllowedPerWeek),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      frequencyType: serializer.fromJson<String>(json['frequencyType']),
      targetDaysPerWeek: serializer.fromJson<int>(json['targetDaysPerWeek']),
      skipsAllowedPerWeek: serializer.fromJson<int>(
        json['skipsAllowedPerWeek'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'frequencyType': serializer.toJson<String>(frequencyType),
      'targetDaysPerWeek': serializer.toJson<int>(targetDaysPerWeek),
      'skipsAllowedPerWeek': serializer.toJson<int>(skipsAllowedPerWeek),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    String? frequencyType,
    int? targetDaysPerWeek,
    int? skipsAllowedPerWeek,
    DateTime? createdAt,
    bool? synced,
  }) => Habit(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    frequencyType: frequencyType ?? this.frequencyType,
    targetDaysPerWeek: targetDaysPerWeek ?? this.targetDaysPerWeek,
    skipsAllowedPerWeek: skipsAllowedPerWeek ?? this.skipsAllowedPerWeek,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      frequencyType:
          data.frequencyType.present
              ? data.frequencyType.value
              : this.frequencyType,
      targetDaysPerWeek:
          data.targetDaysPerWeek.present
              ? data.targetDaysPerWeek.value
              : this.targetDaysPerWeek,
      skipsAllowedPerWeek:
          data.skipsAllowedPerWeek.present
              ? data.skipsAllowedPerWeek.value
              : this.skipsAllowedPerWeek,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('targetDaysPerWeek: $targetDaysPerWeek, ')
          ..write('skipsAllowedPerWeek: $skipsAllowedPerWeek, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    frequencyType,
    targetDaysPerWeek,
    skipsAllowedPerWeek,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.frequencyType == this.frequencyType &&
          other.targetDaysPerWeek == this.targetDaysPerWeek &&
          other.skipsAllowedPerWeek == this.skipsAllowedPerWeek &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> frequencyType;
  final Value<int> targetDaysPerWeek;
  final Value<int> skipsAllowedPerWeek;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.frequencyType = const Value.absent(),
    this.targetDaysPerWeek = const Value.absent(),
    this.skipsAllowedPerWeek = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.frequencyType = const Value.absent(),
    this.targetDaysPerWeek = const Value.absent(),
    this.skipsAllowedPerWeek = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name);
  static Insertable<Habit> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? frequencyType,
    Expression<int>? targetDaysPerWeek,
    Expression<int>? skipsAllowedPerWeek,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (frequencyType != null) 'frequency_type': frequencyType,
      if (targetDaysPerWeek != null) 'target_days_per_week': targetDaysPerWeek,
      if (skipsAllowedPerWeek != null)
        'skips_allowed_per_week': skipsAllowedPerWeek,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? frequencyType,
    Value<int>? targetDaysPerWeek,
    Value<int>? skipsAllowedPerWeek,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      frequencyType: frequencyType ?? this.frequencyType,
      targetDaysPerWeek: targetDaysPerWeek ?? this.targetDaysPerWeek,
      skipsAllowedPerWeek: skipsAllowedPerWeek ?? this.skipsAllowedPerWeek,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (frequencyType.present) {
      map['frequency_type'] = Variable<String>(frequencyType.value);
    }
    if (targetDaysPerWeek.present) {
      map['target_days_per_week'] = Variable<int>(targetDaysPerWeek.value);
    }
    if (skipsAllowedPerWeek.present) {
      map['skips_allowed_per_week'] = Variable<int>(skipsAllowedPerWeek.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('targetDaysPerWeek: $targetDaysPerWeek, ')
          ..write('skipsAllowedPerWeek: $skipsAllowedPerWeek, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitCompletionsTable extends HabitCompletions
    with TableInfo<$HabitCompletionsTable, HabitCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedDateMeta = const VerificationMeta(
    'completedDate',
  );
  @override
  late final GeneratedColumn<DateTime> completedDate =
      GeneratedColumn<DateTime>(
        'completed_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    userId,
    completedDate,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('completed_date')) {
      context.handle(
        _completedDateMeta,
        completedDate.isAcceptableOrUnknown(
          data['completed_date']!,
          _completedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedDateMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitCompletion(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      habitId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}habit_id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      completedDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}completed_date'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $HabitCompletionsTable createAlias(String alias) {
    return $HabitCompletionsTable(attachedDatabase, alias);
  }
}

class HabitCompletion extends DataClass implements Insertable<HabitCompletion> {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completedDate;
  final bool synced;
  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedDate,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['user_id'] = Variable<String>(userId);
    map['completed_date'] = Variable<DateTime>(completedDate);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  HabitCompletionsCompanion toCompanion(bool nullToAbsent) {
    return HabitCompletionsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      userId: Value(userId),
      completedDate: Value(completedDate),
      synced: Value(synced),
    );
  }

  factory HabitCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitCompletion(
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      userId: serializer.fromJson<String>(json['userId']),
      completedDate: serializer.fromJson<DateTime>(json['completedDate']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'userId': serializer.toJson<String>(userId),
      'completedDate': serializer.toJson<DateTime>(completedDate),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  HabitCompletion copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? completedDate,
    bool? synced,
  }) => HabitCompletion(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    userId: userId ?? this.userId,
    completedDate: completedDate ?? this.completedDate,
    synced: synced ?? this.synced,
  );
  HabitCompletion copyWithCompanion(HabitCompletionsCompanion data) {
    return HabitCompletion(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      userId: data.userId.present ? data.userId.value : this.userId,
      completedDate:
          data.completedDate.present
              ? data.completedDate.value
              : this.completedDate,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompletion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('userId: $userId, ')
          ..write('completedDate: $completedDate, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, userId, completedDate, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitCompletion &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.userId == this.userId &&
          other.completedDate == this.completedDate &&
          other.synced == this.synced);
}

class HabitCompletionsCompanion extends UpdateCompanion<HabitCompletion> {
  final Value<String> id;
  final Value<String> habitId;
  final Value<String> userId;
  final Value<DateTime> completedDate;
  final Value<bool> synced;
  final Value<int> rowid;
  const HabitCompletionsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.userId = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitCompletionsCompanion.insert({
    required String id,
    required String habitId,
    required String userId,
    required DateTime completedDate,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitId = Value(habitId),
       userId = Value(userId),
       completedDate = Value(completedDate);
  static Insertable<HabitCompletion> custom({
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<String>? userId,
    Expression<DateTime>? completedDate,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (userId != null) 'user_id': userId,
      if (completedDate != null) 'completed_date': completedDate,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitCompletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? habitId,
    Value<String>? userId,
    Value<DateTime>? completedDate,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return HabitCompletionsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      completedDate: completedDate ?? this.completedDate,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (completedDate.present) {
      map['completed_date'] = Variable<DateTime>(completedDate.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('userId: $userId, ')
          ..write('completedDate: $completedDate, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitSkipsTable extends HabitSkips
    with TableInfo<$HabitSkipsTable, HabitSkip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitSkipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<DateTime> weekStart = GeneratedColumn<DateTime>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    userId,
    weekStart,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_skips';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitSkip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitSkip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitSkip(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      habitId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}habit_id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      weekStart:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}week_start'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $HabitSkipsTable createAlias(String alias) {
    return $HabitSkipsTable(attachedDatabase, alias);
  }
}

class HabitSkip extends DataClass implements Insertable<HabitSkip> {
  final String id;
  final String habitId;
  final String userId;
  final DateTime weekStart;
  final bool synced;
  const HabitSkip({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.weekStart,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['user_id'] = Variable<String>(userId);
    map['week_start'] = Variable<DateTime>(weekStart);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  HabitSkipsCompanion toCompanion(bool nullToAbsent) {
    return HabitSkipsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      userId: Value(userId),
      weekStart: Value(weekStart),
      synced: Value(synced),
    );
  }

  factory HabitSkip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitSkip(
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      userId: serializer.fromJson<String>(json['userId']),
      weekStart: serializer.fromJson<DateTime>(json['weekStart']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'userId': serializer.toJson<String>(userId),
      'weekStart': serializer.toJson<DateTime>(weekStart),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  HabitSkip copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? weekStart,
    bool? synced,
  }) => HabitSkip(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    userId: userId ?? this.userId,
    weekStart: weekStart ?? this.weekStart,
    synced: synced ?? this.synced,
  );
  HabitSkip copyWithCompanion(HabitSkipsCompanion data) {
    return HabitSkip(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      userId: data.userId.present ? data.userId.value : this.userId,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitSkip(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('userId: $userId, ')
          ..write('weekStart: $weekStart, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, userId, weekStart, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitSkip &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.userId == this.userId &&
          other.weekStart == this.weekStart &&
          other.synced == this.synced);
}

class HabitSkipsCompanion extends UpdateCompanion<HabitSkip> {
  final Value<String> id;
  final Value<String> habitId;
  final Value<String> userId;
  final Value<DateTime> weekStart;
  final Value<bool> synced;
  final Value<int> rowid;
  const HabitSkipsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.userId = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitSkipsCompanion.insert({
    required String id,
    required String habitId,
    required String userId,
    required DateTime weekStart,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitId = Value(habitId),
       userId = Value(userId),
       weekStart = Value(weekStart);
  static Insertable<HabitSkip> custom({
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<String>? userId,
    Expression<DateTime>? weekStart,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (userId != null) 'user_id': userId,
      if (weekStart != null) 'week_start': weekStart,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitSkipsCompanion copyWith({
    Value<String>? id,
    Value<String>? habitId,
    Value<String>? userId,
    Value<DateTime>? weekStart,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return HabitSkipsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      weekStart: weekStart ?? this.weekStart,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<DateTime>(weekStart.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitSkipsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('userId: $userId, ')
          ..write('weekStart: $weekStart, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealsTable extends Meals with TableInfo<$MealsTable, Meal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, name, loggedAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Meal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Meal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Meal(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      loggedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}logged_at'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $MealsTable createAlias(String alias) {
    return $MealsTable(attachedDatabase, alias);
  }
}

class Meal extends DataClass implements Insertable<Meal> {
  final String id;
  final String userId;
  final String name;
  final DateTime loggedAt;
  final bool synced;
  const Meal({
    required this.id,
    required this.userId,
    required this.name,
    required this.loggedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  MealsCompanion toCompanion(bool nullToAbsent) {
    return MealsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      loggedAt: Value(loggedAt),
      synced: Value(synced),
    );
  }

  factory Meal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Meal(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Meal copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? loggedAt,
    bool? synced,
  }) => Meal(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    loggedAt: loggedAt ?? this.loggedAt,
    synced: synced ?? this.synced,
  );
  Meal copyWithCompanion(MealsCompanion data) {
    return Meal(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Meal(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, name, loggedAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Meal &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.loggedAt == this.loggedAt &&
          other.synced == this.synced);
}

class MealsCompanion extends UpdateCompanion<Meal> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<DateTime> loggedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const MealsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.loggedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name);
  static Insertable<Meal> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<DateTime>? loggedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<DateTime>? loggedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return MealsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      loggedAt: loggedAt ?? this.loggedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodEntriesTable extends FoodEntries
    with TableInfo<$FoodEntriesTable, FoodEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<String> mealId = GeneratedColumn<String>(
    'meal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sugarMeta = const VerificationMeta('sugar');
  @override
  late final GeneratedColumn<double> sugar = GeneratedColumn<double>(
    'sugar',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
    'fiber',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sodiumMeta = const VerificationMeta('sodium');
  @override
  late final GeneratedColumn<double> sodium = GeneratedColumn<double>(
    'sodium',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cholesterolMeta = const VerificationMeta(
    'cholesterol',
  );
  @override
  late final GeneratedColumn<double> cholesterol = GeneratedColumn<double>(
    'cholesterol',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _potassiumMeta = const VerificationMeta(
    'potassium',
  );
  @override
  late final GeneratedColumn<double> potassium = GeneratedColumn<double>(
    'potassium',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _calciumMeta = const VerificationMeta(
    'calcium',
  );
  @override
  late final GeneratedColumn<double> calcium = GeneratedColumn<double>(
    'calcium',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _ironMeta = const VerificationMeta('iron');
  @override
  late final GeneratedColumn<double> iron = GeneratedColumn<double>(
    'iron',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _vitaminAMeta = const VerificationMeta(
    'vitaminA',
  );
  @override
  late final GeneratedColumn<double> vitaminA = GeneratedColumn<double>(
    'vitamin_a',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _vitaminCMeta = const VerificationMeta(
    'vitaminC',
  );
  @override
  late final GeneratedColumn<double> vitaminC = GeneratedColumn<double>(
    'vitamin_c',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _pantryFoodIdMeta = const VerificationMeta(
    'pantryFoodId',
  );
  @override
  late final GeneratedColumn<String> pantryFoodId = GeneratedColumn<String>(
    'pantry_food_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<double> servings = GeneratedColumn<double>(
    'servings',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mealId,
    userId,
    name,
    calories,
    protein,
    carbs,
    fat,
    sugar,
    fiber,
    sodium,
    cholesterol,
    potassium,
    calcium,
    iron,
    vitaminA,
    vitaminC,
    pantryFoodId,
    servings,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('meal_id')) {
      context.handle(
        _mealIdMeta,
        mealId.isAcceptableOrUnknown(data['meal_id']!, _mealIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    if (data.containsKey('sugar')) {
      context.handle(
        _sugarMeta,
        sugar.isAcceptableOrUnknown(data['sugar']!, _sugarMeta),
      );
    }
    if (data.containsKey('fiber')) {
      context.handle(
        _fiberMeta,
        fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta),
      );
    }
    if (data.containsKey('sodium')) {
      context.handle(
        _sodiumMeta,
        sodium.isAcceptableOrUnknown(data['sodium']!, _sodiumMeta),
      );
    }
    if (data.containsKey('cholesterol')) {
      context.handle(
        _cholesterolMeta,
        cholesterol.isAcceptableOrUnknown(
          data['cholesterol']!,
          _cholesterolMeta,
        ),
      );
    }
    if (data.containsKey('potassium')) {
      context.handle(
        _potassiumMeta,
        potassium.isAcceptableOrUnknown(data['potassium']!, _potassiumMeta),
      );
    }
    if (data.containsKey('calcium')) {
      context.handle(
        _calciumMeta,
        calcium.isAcceptableOrUnknown(data['calcium']!, _calciumMeta),
      );
    }
    if (data.containsKey('iron')) {
      context.handle(
        _ironMeta,
        iron.isAcceptableOrUnknown(data['iron']!, _ironMeta),
      );
    }
    if (data.containsKey('vitamin_a')) {
      context.handle(
        _vitaminAMeta,
        vitaminA.isAcceptableOrUnknown(data['vitamin_a']!, _vitaminAMeta),
      );
    }
    if (data.containsKey('vitamin_c')) {
      context.handle(
        _vitaminCMeta,
        vitaminC.isAcceptableOrUnknown(data['vitamin_c']!, _vitaminCMeta),
      );
    }
    if (data.containsKey('pantry_food_id')) {
      context.handle(
        _pantryFoodIdMeta,
        pantryFoodId.isAcceptableOrUnknown(
          data['pantry_food_id']!,
          _pantryFoodIdMeta,
        ),
      );
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodEntry(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      mealId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}meal_id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      calories:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}calories'],
          )!,
      protein:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}protein'],
          )!,
      carbs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}carbs'],
          )!,
      fat:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}fat'],
          )!,
      sugar:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}sugar'],
          )!,
      fiber:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}fiber'],
          )!,
      sodium:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}sodium'],
          )!,
      cholesterol:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}cholesterol'],
          )!,
      potassium:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}potassium'],
          )!,
      calcium:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}calcium'],
          )!,
      iron:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}iron'],
          )!,
      vitaminA:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}vitamin_a'],
          )!,
      vitaminC:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}vitamin_c'],
          )!,
      pantryFoodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pantry_food_id'],
      ),
      servings:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}servings'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $FoodEntriesTable createAlias(String alias) {
    return $FoodEntriesTable(attachedDatabase, alias);
  }
}

class FoodEntry extends DataClass implements Insertable<FoodEntry> {
  final String id;
  final String mealId;
  final String userId;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double sugar;

  /// Fiber (g)
  final double fiber;

  /// Sodium (mg)
  final double sodium;

  /// Cholesterol (mg)
  final double cholesterol;

  /// Potassium (mg)
  final double potassium;

  /// Calcium (mg)
  final double calcium;

  /// Iron (mg)
  final double iron;

  /// Vitamin A (mcg)
  final double vitaminA;

  /// Vitamin C (mg)
  final double vitaminC;

  /// Links back to the PantryFood this entry was logged from, if any.
  /// NULL for manually-entered foods. Powers Quick Add's usage ranking and
  /// lets a meal be saved as a template.
  final String? pantryFoodId;

  /// Number of servings logged (relative to the source PantryFood's
  /// per-serving macros). Defaults to 1.0 for rows predating this column.
  final double servings;
  final bool synced;
  const FoodEntry({
    required this.id,
    required this.mealId,
    required this.userId,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
    required this.fiber,
    required this.sodium,
    required this.cholesterol,
    required this.potassium,
    required this.calcium,
    required this.iron,
    required this.vitaminA,
    required this.vitaminC,
    this.pantryFoodId,
    required this.servings,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['meal_id'] = Variable<String>(mealId);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['calories'] = Variable<double>(calories);
    map['protein'] = Variable<double>(protein);
    map['carbs'] = Variable<double>(carbs);
    map['fat'] = Variable<double>(fat);
    map['sugar'] = Variable<double>(sugar);
    map['fiber'] = Variable<double>(fiber);
    map['sodium'] = Variable<double>(sodium);
    map['cholesterol'] = Variable<double>(cholesterol);
    map['potassium'] = Variable<double>(potassium);
    map['calcium'] = Variable<double>(calcium);
    map['iron'] = Variable<double>(iron);
    map['vitamin_a'] = Variable<double>(vitaminA);
    map['vitamin_c'] = Variable<double>(vitaminC);
    if (!nullToAbsent || pantryFoodId != null) {
      map['pantry_food_id'] = Variable<String>(pantryFoodId);
    }
    map['servings'] = Variable<double>(servings);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  FoodEntriesCompanion toCompanion(bool nullToAbsent) {
    return FoodEntriesCompanion(
      id: Value(id),
      mealId: Value(mealId),
      userId: Value(userId),
      name: Value(name),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      sugar: Value(sugar),
      fiber: Value(fiber),
      sodium: Value(sodium),
      cholesterol: Value(cholesterol),
      potassium: Value(potassium),
      calcium: Value(calcium),
      iron: Value(iron),
      vitaminA: Value(vitaminA),
      vitaminC: Value(vitaminC),
      pantryFoodId:
          pantryFoodId == null && nullToAbsent
              ? const Value.absent()
              : Value(pantryFoodId),
      servings: Value(servings),
      synced: Value(synced),
    );
  }

  factory FoodEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodEntry(
      id: serializer.fromJson<String>(json['id']),
      mealId: serializer.fromJson<String>(json['mealId']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      calories: serializer.fromJson<double>(json['calories']),
      protein: serializer.fromJson<double>(json['protein']),
      carbs: serializer.fromJson<double>(json['carbs']),
      fat: serializer.fromJson<double>(json['fat']),
      sugar: serializer.fromJson<double>(json['sugar']),
      fiber: serializer.fromJson<double>(json['fiber']),
      sodium: serializer.fromJson<double>(json['sodium']),
      cholesterol: serializer.fromJson<double>(json['cholesterol']),
      potassium: serializer.fromJson<double>(json['potassium']),
      calcium: serializer.fromJson<double>(json['calcium']),
      iron: serializer.fromJson<double>(json['iron']),
      vitaminA: serializer.fromJson<double>(json['vitaminA']),
      vitaminC: serializer.fromJson<double>(json['vitaminC']),
      pantryFoodId: serializer.fromJson<String?>(json['pantryFoodId']),
      servings: serializer.fromJson<double>(json['servings']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mealId': serializer.toJson<String>(mealId),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'calories': serializer.toJson<double>(calories),
      'protein': serializer.toJson<double>(protein),
      'carbs': serializer.toJson<double>(carbs),
      'fat': serializer.toJson<double>(fat),
      'sugar': serializer.toJson<double>(sugar),
      'fiber': serializer.toJson<double>(fiber),
      'sodium': serializer.toJson<double>(sodium),
      'cholesterol': serializer.toJson<double>(cholesterol),
      'potassium': serializer.toJson<double>(potassium),
      'calcium': serializer.toJson<double>(calcium),
      'iron': serializer.toJson<double>(iron),
      'vitaminA': serializer.toJson<double>(vitaminA),
      'vitaminC': serializer.toJson<double>(vitaminC),
      'pantryFoodId': serializer.toJson<String?>(pantryFoodId),
      'servings': serializer.toJson<double>(servings),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  FoodEntry copyWith({
    String? id,
    String? mealId,
    String? userId,
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? sugar,
    double? fiber,
    double? sodium,
    double? cholesterol,
    double? potassium,
    double? calcium,
    double? iron,
    double? vitaminA,
    double? vitaminC,
    Value<String?> pantryFoodId = const Value.absent(),
    double? servings,
    bool? synced,
  }) => FoodEntry(
    id: id ?? this.id,
    mealId: mealId ?? this.mealId,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
    sugar: sugar ?? this.sugar,
    fiber: fiber ?? this.fiber,
    sodium: sodium ?? this.sodium,
    cholesterol: cholesterol ?? this.cholesterol,
    potassium: potassium ?? this.potassium,
    calcium: calcium ?? this.calcium,
    iron: iron ?? this.iron,
    vitaminA: vitaminA ?? this.vitaminA,
    vitaminC: vitaminC ?? this.vitaminC,
    pantryFoodId: pantryFoodId.present ? pantryFoodId.value : this.pantryFoodId,
    servings: servings ?? this.servings,
    synced: synced ?? this.synced,
  );
  FoodEntry copyWithCompanion(FoodEntriesCompanion data) {
    return FoodEntry(
      id: data.id.present ? data.id.value : this.id,
      mealId: data.mealId.present ? data.mealId.value : this.mealId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      sugar: data.sugar.present ? data.sugar.value : this.sugar,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      sodium: data.sodium.present ? data.sodium.value : this.sodium,
      cholesterol:
          data.cholesterol.present ? data.cholesterol.value : this.cholesterol,
      potassium: data.potassium.present ? data.potassium.value : this.potassium,
      calcium: data.calcium.present ? data.calcium.value : this.calcium,
      iron: data.iron.present ? data.iron.value : this.iron,
      vitaminA: data.vitaminA.present ? data.vitaminA.value : this.vitaminA,
      vitaminC: data.vitaminC.present ? data.vitaminC.value : this.vitaminC,
      pantryFoodId:
          data.pantryFoodId.present
              ? data.pantryFoodId.value
              : this.pantryFoodId,
      servings: data.servings.present ? data.servings.value : this.servings,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodEntry(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('sugar: $sugar, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('cholesterol: $cholesterol, ')
          ..write('potassium: $potassium, ')
          ..write('calcium: $calcium, ')
          ..write('iron: $iron, ')
          ..write('vitaminA: $vitaminA, ')
          ..write('vitaminC: $vitaminC, ')
          ..write('pantryFoodId: $pantryFoodId, ')
          ..write('servings: $servings, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mealId,
    userId,
    name,
    calories,
    protein,
    carbs,
    fat,
    sugar,
    fiber,
    sodium,
    cholesterol,
    potassium,
    calcium,
    iron,
    vitaminA,
    vitaminC,
    pantryFoodId,
    servings,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodEntry &&
          other.id == this.id &&
          other.mealId == this.mealId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.sugar == this.sugar &&
          other.fiber == this.fiber &&
          other.sodium == this.sodium &&
          other.cholesterol == this.cholesterol &&
          other.potassium == this.potassium &&
          other.calcium == this.calcium &&
          other.iron == this.iron &&
          other.vitaminA == this.vitaminA &&
          other.vitaminC == this.vitaminC &&
          other.pantryFoodId == this.pantryFoodId &&
          other.servings == this.servings &&
          other.synced == this.synced);
}

class FoodEntriesCompanion extends UpdateCompanion<FoodEntry> {
  final Value<String> id;
  final Value<String> mealId;
  final Value<String> userId;
  final Value<String> name;
  final Value<double> calories;
  final Value<double> protein;
  final Value<double> carbs;
  final Value<double> fat;
  final Value<double> sugar;
  final Value<double> fiber;
  final Value<double> sodium;
  final Value<double> cholesterol;
  final Value<double> potassium;
  final Value<double> calcium;
  final Value<double> iron;
  final Value<double> vitaminA;
  final Value<double> vitaminC;
  final Value<String?> pantryFoodId;
  final Value<double> servings;
  final Value<bool> synced;
  final Value<int> rowid;
  const FoodEntriesCompanion({
    this.id = const Value.absent(),
    this.mealId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.sugar = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sodium = const Value.absent(),
    this.cholesterol = const Value.absent(),
    this.potassium = const Value.absent(),
    this.calcium = const Value.absent(),
    this.iron = const Value.absent(),
    this.vitaminA = const Value.absent(),
    this.vitaminC = const Value.absent(),
    this.pantryFoodId = const Value.absent(),
    this.servings = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodEntriesCompanion.insert({
    required String id,
    required String mealId,
    required String userId,
    required String name,
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.sugar = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sodium = const Value.absent(),
    this.cholesterol = const Value.absent(),
    this.potassium = const Value.absent(),
    this.calcium = const Value.absent(),
    this.iron = const Value.absent(),
    this.vitaminA = const Value.absent(),
    this.vitaminC = const Value.absent(),
    this.pantryFoodId = const Value.absent(),
    this.servings = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mealId = Value(mealId),
       userId = Value(userId),
       name = Value(name);
  static Insertable<FoodEntry> custom({
    Expression<String>? id,
    Expression<String>? mealId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<double>? calories,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? fat,
    Expression<double>? sugar,
    Expression<double>? fiber,
    Expression<double>? sodium,
    Expression<double>? cholesterol,
    Expression<double>? potassium,
    Expression<double>? calcium,
    Expression<double>? iron,
    Expression<double>? vitaminA,
    Expression<double>? vitaminC,
    Expression<String>? pantryFoodId,
    Expression<double>? servings,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealId != null) 'meal_id': mealId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (sugar != null) 'sugar': sugar,
      if (fiber != null) 'fiber': fiber,
      if (sodium != null) 'sodium': sodium,
      if (cholesterol != null) 'cholesterol': cholesterol,
      if (potassium != null) 'potassium': potassium,
      if (calcium != null) 'calcium': calcium,
      if (iron != null) 'iron': iron,
      if (vitaminA != null) 'vitamin_a': vitaminA,
      if (vitaminC != null) 'vitamin_c': vitaminC,
      if (pantryFoodId != null) 'pantry_food_id': pantryFoodId,
      if (servings != null) 'servings': servings,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? mealId,
    Value<String>? userId,
    Value<String>? name,
    Value<double>? calories,
    Value<double>? protein,
    Value<double>? carbs,
    Value<double>? fat,
    Value<double>? sugar,
    Value<double>? fiber,
    Value<double>? sodium,
    Value<double>? cholesterol,
    Value<double>? potassium,
    Value<double>? calcium,
    Value<double>? iron,
    Value<double>? vitaminA,
    Value<double>? vitaminC,
    Value<String?>? pantryFoodId,
    Value<double>? servings,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return FoodEntriesCompanion(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      sugar: sugar ?? this.sugar,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      cholesterol: cholesterol ?? this.cholesterol,
      potassium: potassium ?? this.potassium,
      calcium: calcium ?? this.calcium,
      iron: iron ?? this.iron,
      vitaminA: vitaminA ?? this.vitaminA,
      vitaminC: vitaminC ?? this.vitaminC,
      pantryFoodId: pantryFoodId ?? this.pantryFoodId,
      servings: servings ?? this.servings,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mealId.present) {
      map['meal_id'] = Variable<String>(mealId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (sugar.present) {
      map['sugar'] = Variable<double>(sugar.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    if (sodium.present) {
      map['sodium'] = Variable<double>(sodium.value);
    }
    if (cholesterol.present) {
      map['cholesterol'] = Variable<double>(cholesterol.value);
    }
    if (potassium.present) {
      map['potassium'] = Variable<double>(potassium.value);
    }
    if (calcium.present) {
      map['calcium'] = Variable<double>(calcium.value);
    }
    if (iron.present) {
      map['iron'] = Variable<double>(iron.value);
    }
    if (vitaminA.present) {
      map['vitamin_a'] = Variable<double>(vitaminA.value);
    }
    if (vitaminC.present) {
      map['vitamin_c'] = Variable<double>(vitaminC.value);
    }
    if (pantryFoodId.present) {
      map['pantry_food_id'] = Variable<String>(pantryFoodId.value);
    }
    if (servings.present) {
      map['servings'] = Variable<double>(servings.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodEntriesCompanion(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('sugar: $sugar, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('cholesterol: $cholesterol, ')
          ..write('potassium: $potassium, ')
          ..write('calcium: $calcium, ')
          ..write('iron: $iron, ')
          ..write('vitaminA: $vitaminA, ')
          ..write('vitaminC: $vitaminC, ')
          ..write('pantryFoodId: $pantryFoodId, ')
          ..write('servings: $servings, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WaterLogsTable extends WaterLogs
    with TableInfo<$WaterLogsTable, WaterLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMlMeta = const VerificationMeta(
    'amountMl',
  );
  @override
  late final GeneratedColumn<double> amountMl = GeneratedColumn<double>(
    'amount_ml',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    amountMl,
    loggedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaterLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('amount_ml')) {
      context.handle(
        _amountMlMeta,
        amountMl.isAcceptableOrUnknown(data['amount_ml']!, _amountMlMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMlMeta);
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WaterLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterLog(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      amountMl:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}amount_ml'],
          )!,
      loggedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}logged_at'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $WaterLogsTable createAlias(String alias) {
    return $WaterLogsTable(attachedDatabase, alias);
  }
}

class WaterLog extends DataClass implements Insertable<WaterLog> {
  final String id;
  final String userId;
  final double amountMl;
  final DateTime loggedAt;
  final bool synced;
  const WaterLog({
    required this.id,
    required this.userId,
    required this.amountMl,
    required this.loggedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['amount_ml'] = Variable<double>(amountMl);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  WaterLogsCompanion toCompanion(bool nullToAbsent) {
    return WaterLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      amountMl: Value(amountMl),
      loggedAt: Value(loggedAt),
      synced: Value(synced),
    );
  }

  factory WaterLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterLog(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      amountMl: serializer.fromJson<double>(json['amountMl']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'amountMl': serializer.toJson<double>(amountMl),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  WaterLog copyWith({
    String? id,
    String? userId,
    double? amountMl,
    DateTime? loggedAt,
    bool? synced,
  }) => WaterLog(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    amountMl: amountMl ?? this.amountMl,
    loggedAt: loggedAt ?? this.loggedAt,
    synced: synced ?? this.synced,
  );
  WaterLog copyWithCompanion(WaterLogsCompanion data) {
    return WaterLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      amountMl: data.amountMl.present ? data.amountMl.value : this.amountMl,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amountMl: $amountMl, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, amountMl, loggedAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.amountMl == this.amountMl &&
          other.loggedAt == this.loggedAt &&
          other.synced == this.synced);
}

class WaterLogsCompanion extends UpdateCompanion<WaterLog> {
  final Value<String> id;
  final Value<String> userId;
  final Value<double> amountMl;
  final Value<DateTime> loggedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const WaterLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.amountMl = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WaterLogsCompanion.insert({
    required String id,
    required String userId,
    required double amountMl,
    this.loggedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       amountMl = Value(amountMl);
  static Insertable<WaterLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<double>? amountMl,
    Expression<DateTime>? loggedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (amountMl != null) 'amount_ml': amountMl,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WaterLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<double>? amountMl,
    Value<DateTime>? loggedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return WaterLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amountMl: amountMl ?? this.amountMl,
      loggedAt: loggedAt ?? this.loggedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (amountMl.present) {
      map['amount_ml'] = Variable<double>(amountMl.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amountMl: $amountMl, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyNutritionGoalsTable extends DailyNutritionGoals
    with TableInfo<$DailyNutritionGoalsTable, DailyNutritionGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyNutritionGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2000.0),
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(150.0),
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(250.0),
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(65.0),
  );
  static const VerificationMeta _waterMlMeta = const VerificationMeta(
    'waterMl',
  );
  @override
  late final GeneratedColumn<double> waterMl = GeneratedColumn<double>(
    'water_ml',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2500.0),
  );
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
    'fiber',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(28.0),
  );
  static const VerificationMeta _sodiumMeta = const VerificationMeta('sodium');
  @override
  late final GeneratedColumn<double> sodium = GeneratedColumn<double>(
    'sodium',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2300.0),
  );
  static const VerificationMeta _cholesterolMeta = const VerificationMeta(
    'cholesterol',
  );
  @override
  late final GeneratedColumn<double> cholesterol = GeneratedColumn<double>(
    'cholesterol',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(300.0),
  );
  static const VerificationMeta _potassiumMeta = const VerificationMeta(
    'potassium',
  );
  @override
  late final GeneratedColumn<double> potassium = GeneratedColumn<double>(
    'potassium',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(4700.0),
  );
  static const VerificationMeta _calciumMeta = const VerificationMeta(
    'calcium',
  );
  @override
  late final GeneratedColumn<double> calcium = GeneratedColumn<double>(
    'calcium',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1300.0),
  );
  static const VerificationMeta _ironMeta = const VerificationMeta('iron');
  @override
  late final GeneratedColumn<double> iron = GeneratedColumn<double>(
    'iron',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(18.0),
  );
  static const VerificationMeta _vitaminAMeta = const VerificationMeta(
    'vitaminA',
  );
  @override
  late final GeneratedColumn<double> vitaminA = GeneratedColumn<double>(
    'vitamin_a',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(900.0),
  );
  static const VerificationMeta _vitaminCMeta = const VerificationMeta(
    'vitaminC',
  );
  @override
  late final GeneratedColumn<double> vitaminC = GeneratedColumn<double>(
    'vitamin_c',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(90.0),
  );
  static const VerificationMeta _currentWeightKgMeta = const VerificationMeta(
    'currentWeightKg',
  );
  @override
  late final GeneratedColumn<double> currentWeightKg = GeneratedColumn<double>(
    'current_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta(
    'targetWeightKg',
  );
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    calories,
    protein,
    carbs,
    fat,
    waterMl,
    fiber,
    sodium,
    cholesterol,
    potassium,
    calcium,
    iron,
    vitaminA,
    vitaminC,
    currentWeightKg,
    targetWeightKg,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_nutrition_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyNutritionGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    if (data.containsKey('water_ml')) {
      context.handle(
        _waterMlMeta,
        waterMl.isAcceptableOrUnknown(data['water_ml']!, _waterMlMeta),
      );
    }
    if (data.containsKey('fiber')) {
      context.handle(
        _fiberMeta,
        fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta),
      );
    }
    if (data.containsKey('sodium')) {
      context.handle(
        _sodiumMeta,
        sodium.isAcceptableOrUnknown(data['sodium']!, _sodiumMeta),
      );
    }
    if (data.containsKey('cholesterol')) {
      context.handle(
        _cholesterolMeta,
        cholesterol.isAcceptableOrUnknown(
          data['cholesterol']!,
          _cholesterolMeta,
        ),
      );
    }
    if (data.containsKey('potassium')) {
      context.handle(
        _potassiumMeta,
        potassium.isAcceptableOrUnknown(data['potassium']!, _potassiumMeta),
      );
    }
    if (data.containsKey('calcium')) {
      context.handle(
        _calciumMeta,
        calcium.isAcceptableOrUnknown(data['calcium']!, _calciumMeta),
      );
    }
    if (data.containsKey('iron')) {
      context.handle(
        _ironMeta,
        iron.isAcceptableOrUnknown(data['iron']!, _ironMeta),
      );
    }
    if (data.containsKey('vitamin_a')) {
      context.handle(
        _vitaminAMeta,
        vitaminA.isAcceptableOrUnknown(data['vitamin_a']!, _vitaminAMeta),
      );
    }
    if (data.containsKey('vitamin_c')) {
      context.handle(
        _vitaminCMeta,
        vitaminC.isAcceptableOrUnknown(data['vitamin_c']!, _vitaminCMeta),
      );
    }
    if (data.containsKey('current_weight_kg')) {
      context.handle(
        _currentWeightKgMeta,
        currentWeightKg.isAcceptableOrUnknown(
          data['current_weight_kg']!,
          _currentWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(
        _targetWeightKgMeta,
        targetWeightKg.isAcceptableOrUnknown(
          data['target_weight_kg']!,
          _targetWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  DailyNutritionGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyNutritionGoal(
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      calories:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}calories'],
          )!,
      protein:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}protein'],
          )!,
      carbs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}carbs'],
          )!,
      fat:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}fat'],
          )!,
      waterMl:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}water_ml'],
          )!,
      fiber:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}fiber'],
          )!,
      sodium:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}sodium'],
          )!,
      cholesterol:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}cholesterol'],
          )!,
      potassium:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}potassium'],
          )!,
      calcium:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}calcium'],
          )!,
      iron:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}iron'],
          )!,
      vitaminA:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}vitamin_a'],
          )!,
      vitaminC:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}vitamin_c'],
          )!,
      currentWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_weight_kg'],
      ),
      targetWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight_kg'],
      ),
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $DailyNutritionGoalsTable createAlias(String alias) {
    return $DailyNutritionGoalsTable(attachedDatabase, alias);
  }
}

class DailyNutritionGoal extends DataClass
    implements Insertable<DailyNutritionGoal> {
  final String userId;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double waterMl;

  /// Fiber (g)
  final double fiber;

  /// Sodium (mg)
  final double sodium;

  /// Cholesterol (mg)
  final double cholesterol;

  /// Potassium (mg)
  final double potassium;

  /// Calcium (mg)
  final double calcium;

  /// Iron (mg)
  final double iron;

  /// Vitamin A (mcg)
  final double vitaminA;

  /// Vitamin C (mg)
  final double vitaminC;
  final double? currentWeightKg;
  final double? targetWeightKg;
  final bool synced;
  const DailyNutritionGoal({
    required this.userId,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.waterMl,
    required this.fiber,
    required this.sodium,
    required this.cholesterol,
    required this.potassium,
    required this.calcium,
    required this.iron,
    required this.vitaminA,
    required this.vitaminC,
    this.currentWeightKg,
    this.targetWeightKg,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['calories'] = Variable<double>(calories);
    map['protein'] = Variable<double>(protein);
    map['carbs'] = Variable<double>(carbs);
    map['fat'] = Variable<double>(fat);
    map['water_ml'] = Variable<double>(waterMl);
    map['fiber'] = Variable<double>(fiber);
    map['sodium'] = Variable<double>(sodium);
    map['cholesterol'] = Variable<double>(cholesterol);
    map['potassium'] = Variable<double>(potassium);
    map['calcium'] = Variable<double>(calcium);
    map['iron'] = Variable<double>(iron);
    map['vitamin_a'] = Variable<double>(vitaminA);
    map['vitamin_c'] = Variable<double>(vitaminC);
    if (!nullToAbsent || currentWeightKg != null) {
      map['current_weight_kg'] = Variable<double>(currentWeightKg);
    }
    if (!nullToAbsent || targetWeightKg != null) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  DailyNutritionGoalsCompanion toCompanion(bool nullToAbsent) {
    return DailyNutritionGoalsCompanion(
      userId: Value(userId),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      waterMl: Value(waterMl),
      fiber: Value(fiber),
      sodium: Value(sodium),
      cholesterol: Value(cholesterol),
      potassium: Value(potassium),
      calcium: Value(calcium),
      iron: Value(iron),
      vitaminA: Value(vitaminA),
      vitaminC: Value(vitaminC),
      currentWeightKg:
          currentWeightKg == null && nullToAbsent
              ? const Value.absent()
              : Value(currentWeightKg),
      targetWeightKg:
          targetWeightKg == null && nullToAbsent
              ? const Value.absent()
              : Value(targetWeightKg),
      synced: Value(synced),
    );
  }

  factory DailyNutritionGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyNutritionGoal(
      userId: serializer.fromJson<String>(json['userId']),
      calories: serializer.fromJson<double>(json['calories']),
      protein: serializer.fromJson<double>(json['protein']),
      carbs: serializer.fromJson<double>(json['carbs']),
      fat: serializer.fromJson<double>(json['fat']),
      waterMl: serializer.fromJson<double>(json['waterMl']),
      fiber: serializer.fromJson<double>(json['fiber']),
      sodium: serializer.fromJson<double>(json['sodium']),
      cholesterol: serializer.fromJson<double>(json['cholesterol']),
      potassium: serializer.fromJson<double>(json['potassium']),
      calcium: serializer.fromJson<double>(json['calcium']),
      iron: serializer.fromJson<double>(json['iron']),
      vitaminA: serializer.fromJson<double>(json['vitaminA']),
      vitaminC: serializer.fromJson<double>(json['vitaminC']),
      currentWeightKg: serializer.fromJson<double?>(json['currentWeightKg']),
      targetWeightKg: serializer.fromJson<double?>(json['targetWeightKg']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'calories': serializer.toJson<double>(calories),
      'protein': serializer.toJson<double>(protein),
      'carbs': serializer.toJson<double>(carbs),
      'fat': serializer.toJson<double>(fat),
      'waterMl': serializer.toJson<double>(waterMl),
      'fiber': serializer.toJson<double>(fiber),
      'sodium': serializer.toJson<double>(sodium),
      'cholesterol': serializer.toJson<double>(cholesterol),
      'potassium': serializer.toJson<double>(potassium),
      'calcium': serializer.toJson<double>(calcium),
      'iron': serializer.toJson<double>(iron),
      'vitaminA': serializer.toJson<double>(vitaminA),
      'vitaminC': serializer.toJson<double>(vitaminC),
      'currentWeightKg': serializer.toJson<double?>(currentWeightKg),
      'targetWeightKg': serializer.toJson<double?>(targetWeightKg),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  DailyNutritionGoal copyWith({
    String? userId,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? waterMl,
    double? fiber,
    double? sodium,
    double? cholesterol,
    double? potassium,
    double? calcium,
    double? iron,
    double? vitaminA,
    double? vitaminC,
    Value<double?> currentWeightKg = const Value.absent(),
    Value<double?> targetWeightKg = const Value.absent(),
    bool? synced,
  }) => DailyNutritionGoal(
    userId: userId ?? this.userId,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
    waterMl: waterMl ?? this.waterMl,
    fiber: fiber ?? this.fiber,
    sodium: sodium ?? this.sodium,
    cholesterol: cholesterol ?? this.cholesterol,
    potassium: potassium ?? this.potassium,
    calcium: calcium ?? this.calcium,
    iron: iron ?? this.iron,
    vitaminA: vitaminA ?? this.vitaminA,
    vitaminC: vitaminC ?? this.vitaminC,
    currentWeightKg:
        currentWeightKg.present ? currentWeightKg.value : this.currentWeightKg,
    targetWeightKg:
        targetWeightKg.present ? targetWeightKg.value : this.targetWeightKg,
    synced: synced ?? this.synced,
  );
  DailyNutritionGoal copyWithCompanion(DailyNutritionGoalsCompanion data) {
    return DailyNutritionGoal(
      userId: data.userId.present ? data.userId.value : this.userId,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      waterMl: data.waterMl.present ? data.waterMl.value : this.waterMl,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      sodium: data.sodium.present ? data.sodium.value : this.sodium,
      cholesterol:
          data.cholesterol.present ? data.cholesterol.value : this.cholesterol,
      potassium: data.potassium.present ? data.potassium.value : this.potassium,
      calcium: data.calcium.present ? data.calcium.value : this.calcium,
      iron: data.iron.present ? data.iron.value : this.iron,
      vitaminA: data.vitaminA.present ? data.vitaminA.value : this.vitaminA,
      vitaminC: data.vitaminC.present ? data.vitaminC.value : this.vitaminC,
      currentWeightKg:
          data.currentWeightKg.present
              ? data.currentWeightKg.value
              : this.currentWeightKg,
      targetWeightKg:
          data.targetWeightKg.present
              ? data.targetWeightKg.value
              : this.targetWeightKg,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyNutritionGoal(')
          ..write('userId: $userId, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('waterMl: $waterMl, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('cholesterol: $cholesterol, ')
          ..write('potassium: $potassium, ')
          ..write('calcium: $calcium, ')
          ..write('iron: $iron, ')
          ..write('vitaminA: $vitaminA, ')
          ..write('vitaminC: $vitaminC, ')
          ..write('currentWeightKg: $currentWeightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    calories,
    protein,
    carbs,
    fat,
    waterMl,
    fiber,
    sodium,
    cholesterol,
    potassium,
    calcium,
    iron,
    vitaminA,
    vitaminC,
    currentWeightKg,
    targetWeightKg,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyNutritionGoal &&
          other.userId == this.userId &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.waterMl == this.waterMl &&
          other.fiber == this.fiber &&
          other.sodium == this.sodium &&
          other.cholesterol == this.cholesterol &&
          other.potassium == this.potassium &&
          other.calcium == this.calcium &&
          other.iron == this.iron &&
          other.vitaminA == this.vitaminA &&
          other.vitaminC == this.vitaminC &&
          other.currentWeightKg == this.currentWeightKg &&
          other.targetWeightKg == this.targetWeightKg &&
          other.synced == this.synced);
}

class DailyNutritionGoalsCompanion extends UpdateCompanion<DailyNutritionGoal> {
  final Value<String> userId;
  final Value<double> calories;
  final Value<double> protein;
  final Value<double> carbs;
  final Value<double> fat;
  final Value<double> waterMl;
  final Value<double> fiber;
  final Value<double> sodium;
  final Value<double> cholesterol;
  final Value<double> potassium;
  final Value<double> calcium;
  final Value<double> iron;
  final Value<double> vitaminA;
  final Value<double> vitaminC;
  final Value<double?> currentWeightKg;
  final Value<double?> targetWeightKg;
  final Value<bool> synced;
  final Value<int> rowid;
  const DailyNutritionGoalsCompanion({
    this.userId = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.waterMl = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sodium = const Value.absent(),
    this.cholesterol = const Value.absent(),
    this.potassium = const Value.absent(),
    this.calcium = const Value.absent(),
    this.iron = const Value.absent(),
    this.vitaminA = const Value.absent(),
    this.vitaminC = const Value.absent(),
    this.currentWeightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyNutritionGoalsCompanion.insert({
    required String userId,
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.waterMl = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sodium = const Value.absent(),
    this.cholesterol = const Value.absent(),
    this.potassium = const Value.absent(),
    this.calcium = const Value.absent(),
    this.iron = const Value.absent(),
    this.vitaminA = const Value.absent(),
    this.vitaminC = const Value.absent(),
    this.currentWeightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<DailyNutritionGoal> custom({
    Expression<String>? userId,
    Expression<double>? calories,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? fat,
    Expression<double>? waterMl,
    Expression<double>? fiber,
    Expression<double>? sodium,
    Expression<double>? cholesterol,
    Expression<double>? potassium,
    Expression<double>? calcium,
    Expression<double>? iron,
    Expression<double>? vitaminA,
    Expression<double>? vitaminC,
    Expression<double>? currentWeightKg,
    Expression<double>? targetWeightKg,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (waterMl != null) 'water_ml': waterMl,
      if (fiber != null) 'fiber': fiber,
      if (sodium != null) 'sodium': sodium,
      if (cholesterol != null) 'cholesterol': cholesterol,
      if (potassium != null) 'potassium': potassium,
      if (calcium != null) 'calcium': calcium,
      if (iron != null) 'iron': iron,
      if (vitaminA != null) 'vitamin_a': vitaminA,
      if (vitaminC != null) 'vitamin_c': vitaminC,
      if (currentWeightKg != null) 'current_weight_kg': currentWeightKg,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyNutritionGoalsCompanion copyWith({
    Value<String>? userId,
    Value<double>? calories,
    Value<double>? protein,
    Value<double>? carbs,
    Value<double>? fat,
    Value<double>? waterMl,
    Value<double>? fiber,
    Value<double>? sodium,
    Value<double>? cholesterol,
    Value<double>? potassium,
    Value<double>? calcium,
    Value<double>? iron,
    Value<double>? vitaminA,
    Value<double>? vitaminC,
    Value<double?>? currentWeightKg,
    Value<double?>? targetWeightKg,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return DailyNutritionGoalsCompanion(
      userId: userId ?? this.userId,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      waterMl: waterMl ?? this.waterMl,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      cholesterol: cholesterol ?? this.cholesterol,
      potassium: potassium ?? this.potassium,
      calcium: calcium ?? this.calcium,
      iron: iron ?? this.iron,
      vitaminA: vitaminA ?? this.vitaminA,
      vitaminC: vitaminC ?? this.vitaminC,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (waterMl.present) {
      map['water_ml'] = Variable<double>(waterMl.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    if (sodium.present) {
      map['sodium'] = Variable<double>(sodium.value);
    }
    if (cholesterol.present) {
      map['cholesterol'] = Variable<double>(cholesterol.value);
    }
    if (potassium.present) {
      map['potassium'] = Variable<double>(potassium.value);
    }
    if (calcium.present) {
      map['calcium'] = Variable<double>(calcium.value);
    }
    if (iron.present) {
      map['iron'] = Variable<double>(iron.value);
    }
    if (vitaminA.present) {
      map['vitamin_a'] = Variable<double>(vitaminA.value);
    }
    if (vitaminC.present) {
      map['vitamin_c'] = Variable<double>(vitaminC.value);
    }
    if (currentWeightKg.present) {
      map['current_weight_kg'] = Variable<double>(currentWeightKg.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyNutritionGoalsCompanion(')
          ..write('userId: $userId, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('waterMl: $waterMl, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('cholesterol: $cholesterol, ')
          ..write('potassium: $potassium, ')
          ..write('calcium: $calcium, ')
          ..write('iron: $iron, ')
          ..write('vitaminA: $vitaminA, ')
          ..write('vitaminC: $vitaminC, ')
          ..write('currentWeightKg: $currentWeightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PantryFoodsTable extends PantryFoods
    with TableInfo<$PantryFoodsTable, PantryFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PantryFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sugarMeta = const VerificationMeta('sugar');
  @override
  late final GeneratedColumn<double> sugar = GeneratedColumn<double>(
    'sugar',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
    'fiber',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sodiumMeta = const VerificationMeta('sodium');
  @override
  late final GeneratedColumn<double> sodium = GeneratedColumn<double>(
    'sodium',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cholesterolMeta = const VerificationMeta(
    'cholesterol',
  );
  @override
  late final GeneratedColumn<double> cholesterol = GeneratedColumn<double>(
    'cholesterol',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _potassiumMeta = const VerificationMeta(
    'potassium',
  );
  @override
  late final GeneratedColumn<double> potassium = GeneratedColumn<double>(
    'potassium',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _calciumMeta = const VerificationMeta(
    'calcium',
  );
  @override
  late final GeneratedColumn<double> calcium = GeneratedColumn<double>(
    'calcium',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _ironMeta = const VerificationMeta('iron');
  @override
  late final GeneratedColumn<double> iron = GeneratedColumn<double>(
    'iron',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _vitaminAMeta = const VerificationMeta(
    'vitaminA',
  );
  @override
  late final GeneratedColumn<double> vitaminA = GeneratedColumn<double>(
    'vitamin_a',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _vitaminCMeta = const VerificationMeta(
    'vitaminC',
  );
  @override
  late final GeneratedColumn<double> vitaminC = GeneratedColumn<double>(
    'vitamin_c',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _servingLabelMeta = const VerificationMeta(
    'servingLabel',
  );
  @override
  late final GeneratedColumn<String> servingLabel = GeneratedColumn<String>(
    'serving_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1 serving'),
  );
  static const VerificationMeta _isPresetMeta = const VerificationMeta(
    'isPreset',
  );
  @override
  late final GeneratedColumn<bool> isPreset = GeneratedColumn<bool>(
    'is_preset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_preset" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    calories,
    protein,
    carbs,
    fat,
    sugar,
    fiber,
    sodium,
    cholesterol,
    potassium,
    calcium,
    iron,
    vitaminA,
    vitaminC,
    servingLabel,
    isPreset,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pantry_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<PantryFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    if (data.containsKey('sugar')) {
      context.handle(
        _sugarMeta,
        sugar.isAcceptableOrUnknown(data['sugar']!, _sugarMeta),
      );
    }
    if (data.containsKey('fiber')) {
      context.handle(
        _fiberMeta,
        fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta),
      );
    }
    if (data.containsKey('sodium')) {
      context.handle(
        _sodiumMeta,
        sodium.isAcceptableOrUnknown(data['sodium']!, _sodiumMeta),
      );
    }
    if (data.containsKey('cholesterol')) {
      context.handle(
        _cholesterolMeta,
        cholesterol.isAcceptableOrUnknown(
          data['cholesterol']!,
          _cholesterolMeta,
        ),
      );
    }
    if (data.containsKey('potassium')) {
      context.handle(
        _potassiumMeta,
        potassium.isAcceptableOrUnknown(data['potassium']!, _potassiumMeta),
      );
    }
    if (data.containsKey('calcium')) {
      context.handle(
        _calciumMeta,
        calcium.isAcceptableOrUnknown(data['calcium']!, _calciumMeta),
      );
    }
    if (data.containsKey('iron')) {
      context.handle(
        _ironMeta,
        iron.isAcceptableOrUnknown(data['iron']!, _ironMeta),
      );
    }
    if (data.containsKey('vitamin_a')) {
      context.handle(
        _vitaminAMeta,
        vitaminA.isAcceptableOrUnknown(data['vitamin_a']!, _vitaminAMeta),
      );
    }
    if (data.containsKey('vitamin_c')) {
      context.handle(
        _vitaminCMeta,
        vitaminC.isAcceptableOrUnknown(data['vitamin_c']!, _vitaminCMeta),
      );
    }
    if (data.containsKey('serving_label')) {
      context.handle(
        _servingLabelMeta,
        servingLabel.isAcceptableOrUnknown(
          data['serving_label']!,
          _servingLabelMeta,
        ),
      );
    }
    if (data.containsKey('is_preset')) {
      context.handle(
        _isPresetMeta,
        isPreset.isAcceptableOrUnknown(data['is_preset']!, _isPresetMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PantryFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PantryFood(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      calories:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}calories'],
          )!,
      protein:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}protein'],
          )!,
      carbs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}carbs'],
          )!,
      fat:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}fat'],
          )!,
      sugar:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}sugar'],
          )!,
      fiber:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}fiber'],
          )!,
      sodium:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}sodium'],
          )!,
      cholesterol:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}cholesterol'],
          )!,
      potassium:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}potassium'],
          )!,
      calcium:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}calcium'],
          )!,
      iron:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}iron'],
          )!,
      vitaminA:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}vitamin_a'],
          )!,
      vitaminC:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}vitamin_c'],
          )!,
      servingLabel:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}serving_label'],
          )!,
      isPreset:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_preset'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $PantryFoodsTable createAlias(String alias) {
    return $PantryFoodsTable(attachedDatabase, alias);
  }
}

class PantryFood extends DataClass implements Insertable<PantryFood> {
  final String id;

  /// NULL = global preset (admin-managed, visible to all users).
  /// Non-null = personal food belonging to this user.
  final String? userId;
  final String name;

  /// Calories per serving
  final double calories;

  /// Protein per serving (g)
  final double protein;

  /// Carbs per serving (g)
  final double carbs;

  /// Fat per serving (g)
  final double fat;

  /// Sugar per serving (g)
  final double sugar;

  /// Fiber per serving (g)
  final double fiber;

  /// Sodium per serving (mg)
  final double sodium;

  /// Cholesterol per serving (mg)
  final double cholesterol;

  /// Potassium per serving (mg)
  final double potassium;

  /// Calcium per serving (mg)
  final double calcium;

  /// Iron per serving (mg)
  final double iron;

  /// Vitamin A per serving (mcg)
  final double vitaminA;

  /// Vitamin C per serving (mg)
  final double vitaminC;

  /// Human-readable serving description e.g. "1 slice (28g)", "1 egg (50g)"
  final String servingLabel;

  /// True for global preset foods managed in Supabase.
  final bool isPreset;
  final DateTime createdAt;
  final bool synced;
  const PantryFood({
    required this.id,
    this.userId,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
    required this.fiber,
    required this.sodium,
    required this.cholesterol,
    required this.potassium,
    required this.calcium,
    required this.iron,
    required this.vitaminA,
    required this.vitaminC,
    required this.servingLabel,
    required this.isPreset,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['name'] = Variable<String>(name);
    map['calories'] = Variable<double>(calories);
    map['protein'] = Variable<double>(protein);
    map['carbs'] = Variable<double>(carbs);
    map['fat'] = Variable<double>(fat);
    map['sugar'] = Variable<double>(sugar);
    map['fiber'] = Variable<double>(fiber);
    map['sodium'] = Variable<double>(sodium);
    map['cholesterol'] = Variable<double>(cholesterol);
    map['potassium'] = Variable<double>(potassium);
    map['calcium'] = Variable<double>(calcium);
    map['iron'] = Variable<double>(iron);
    map['vitamin_a'] = Variable<double>(vitaminA);
    map['vitamin_c'] = Variable<double>(vitaminC);
    map['serving_label'] = Variable<String>(servingLabel);
    map['is_preset'] = Variable<bool>(isPreset);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  PantryFoodsCompanion toCompanion(bool nullToAbsent) {
    return PantryFoodsCompanion(
      id: Value(id),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      name: Value(name),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      sugar: Value(sugar),
      fiber: Value(fiber),
      sodium: Value(sodium),
      cholesterol: Value(cholesterol),
      potassium: Value(potassium),
      calcium: Value(calcium),
      iron: Value(iron),
      vitaminA: Value(vitaminA),
      vitaminC: Value(vitaminC),
      servingLabel: Value(servingLabel),
      isPreset: Value(isPreset),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory PantryFood.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PantryFood(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      calories: serializer.fromJson<double>(json['calories']),
      protein: serializer.fromJson<double>(json['protein']),
      carbs: serializer.fromJson<double>(json['carbs']),
      fat: serializer.fromJson<double>(json['fat']),
      sugar: serializer.fromJson<double>(json['sugar']),
      fiber: serializer.fromJson<double>(json['fiber']),
      sodium: serializer.fromJson<double>(json['sodium']),
      cholesterol: serializer.fromJson<double>(json['cholesterol']),
      potassium: serializer.fromJson<double>(json['potassium']),
      calcium: serializer.fromJson<double>(json['calcium']),
      iron: serializer.fromJson<double>(json['iron']),
      vitaminA: serializer.fromJson<double>(json['vitaminA']),
      vitaminC: serializer.fromJson<double>(json['vitaminC']),
      servingLabel: serializer.fromJson<String>(json['servingLabel']),
      isPreset: serializer.fromJson<bool>(json['isPreset']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'name': serializer.toJson<String>(name),
      'calories': serializer.toJson<double>(calories),
      'protein': serializer.toJson<double>(protein),
      'carbs': serializer.toJson<double>(carbs),
      'fat': serializer.toJson<double>(fat),
      'sugar': serializer.toJson<double>(sugar),
      'fiber': serializer.toJson<double>(fiber),
      'sodium': serializer.toJson<double>(sodium),
      'cholesterol': serializer.toJson<double>(cholesterol),
      'potassium': serializer.toJson<double>(potassium),
      'calcium': serializer.toJson<double>(calcium),
      'iron': serializer.toJson<double>(iron),
      'vitaminA': serializer.toJson<double>(vitaminA),
      'vitaminC': serializer.toJson<double>(vitaminC),
      'servingLabel': serializer.toJson<String>(servingLabel),
      'isPreset': serializer.toJson<bool>(isPreset),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  PantryFood copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? sugar,
    double? fiber,
    double? sodium,
    double? cholesterol,
    double? potassium,
    double? calcium,
    double? iron,
    double? vitaminA,
    double? vitaminC,
    String? servingLabel,
    bool? isPreset,
    DateTime? createdAt,
    bool? synced,
  }) => PantryFood(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    name: name ?? this.name,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
    sugar: sugar ?? this.sugar,
    fiber: fiber ?? this.fiber,
    sodium: sodium ?? this.sodium,
    cholesterol: cholesterol ?? this.cholesterol,
    potassium: potassium ?? this.potassium,
    calcium: calcium ?? this.calcium,
    iron: iron ?? this.iron,
    vitaminA: vitaminA ?? this.vitaminA,
    vitaminC: vitaminC ?? this.vitaminC,
    servingLabel: servingLabel ?? this.servingLabel,
    isPreset: isPreset ?? this.isPreset,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  PantryFood copyWithCompanion(PantryFoodsCompanion data) {
    return PantryFood(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      sugar: data.sugar.present ? data.sugar.value : this.sugar,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      sodium: data.sodium.present ? data.sodium.value : this.sodium,
      cholesterol:
          data.cholesterol.present ? data.cholesterol.value : this.cholesterol,
      potassium: data.potassium.present ? data.potassium.value : this.potassium,
      calcium: data.calcium.present ? data.calcium.value : this.calcium,
      iron: data.iron.present ? data.iron.value : this.iron,
      vitaminA: data.vitaminA.present ? data.vitaminA.value : this.vitaminA,
      vitaminC: data.vitaminC.present ? data.vitaminC.value : this.vitaminC,
      servingLabel:
          data.servingLabel.present
              ? data.servingLabel.value
              : this.servingLabel,
      isPreset: data.isPreset.present ? data.isPreset.value : this.isPreset,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PantryFood(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('sugar: $sugar, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('cholesterol: $cholesterol, ')
          ..write('potassium: $potassium, ')
          ..write('calcium: $calcium, ')
          ..write('iron: $iron, ')
          ..write('vitaminA: $vitaminA, ')
          ..write('vitaminC: $vitaminC, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('isPreset: $isPreset, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    calories,
    protein,
    carbs,
    fat,
    sugar,
    fiber,
    sodium,
    cholesterol,
    potassium,
    calcium,
    iron,
    vitaminA,
    vitaminC,
    servingLabel,
    isPreset,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PantryFood &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.sugar == this.sugar &&
          other.fiber == this.fiber &&
          other.sodium == this.sodium &&
          other.cholesterol == this.cholesterol &&
          other.potassium == this.potassium &&
          other.calcium == this.calcium &&
          other.iron == this.iron &&
          other.vitaminA == this.vitaminA &&
          other.vitaminC == this.vitaminC &&
          other.servingLabel == this.servingLabel &&
          other.isPreset == this.isPreset &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class PantryFoodsCompanion extends UpdateCompanion<PantryFood> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> name;
  final Value<double> calories;
  final Value<double> protein;
  final Value<double> carbs;
  final Value<double> fat;
  final Value<double> sugar;
  final Value<double> fiber;
  final Value<double> sodium;
  final Value<double> cholesterol;
  final Value<double> potassium;
  final Value<double> calcium;
  final Value<double> iron;
  final Value<double> vitaminA;
  final Value<double> vitaminC;
  final Value<String> servingLabel;
  final Value<bool> isPreset;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const PantryFoodsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.sugar = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sodium = const Value.absent(),
    this.cholesterol = const Value.absent(),
    this.potassium = const Value.absent(),
    this.calcium = const Value.absent(),
    this.iron = const Value.absent(),
    this.vitaminA = const Value.absent(),
    this.vitaminC = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.isPreset = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PantryFoodsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String name,
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.sugar = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sodium = const Value.absent(),
    this.cholesterol = const Value.absent(),
    this.potassium = const Value.absent(),
    this.calcium = const Value.absent(),
    this.iron = const Value.absent(),
    this.vitaminA = const Value.absent(),
    this.vitaminC = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.isPreset = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<PantryFood> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<double>? calories,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? fat,
    Expression<double>? sugar,
    Expression<double>? fiber,
    Expression<double>? sodium,
    Expression<double>? cholesterol,
    Expression<double>? potassium,
    Expression<double>? calcium,
    Expression<double>? iron,
    Expression<double>? vitaminA,
    Expression<double>? vitaminC,
    Expression<String>? servingLabel,
    Expression<bool>? isPreset,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (sugar != null) 'sugar': sugar,
      if (fiber != null) 'fiber': fiber,
      if (sodium != null) 'sodium': sodium,
      if (cholesterol != null) 'cholesterol': cholesterol,
      if (potassium != null) 'potassium': potassium,
      if (calcium != null) 'calcium': calcium,
      if (iron != null) 'iron': iron,
      if (vitaminA != null) 'vitamin_a': vitaminA,
      if (vitaminC != null) 'vitamin_c': vitaminC,
      if (servingLabel != null) 'serving_label': servingLabel,
      if (isPreset != null) 'is_preset': isPreset,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PantryFoodsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String>? name,
    Value<double>? calories,
    Value<double>? protein,
    Value<double>? carbs,
    Value<double>? fat,
    Value<double>? sugar,
    Value<double>? fiber,
    Value<double>? sodium,
    Value<double>? cholesterol,
    Value<double>? potassium,
    Value<double>? calcium,
    Value<double>? iron,
    Value<double>? vitaminA,
    Value<double>? vitaminC,
    Value<String>? servingLabel,
    Value<bool>? isPreset,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return PantryFoodsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      sugar: sugar ?? this.sugar,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      cholesterol: cholesterol ?? this.cholesterol,
      potassium: potassium ?? this.potassium,
      calcium: calcium ?? this.calcium,
      iron: iron ?? this.iron,
      vitaminA: vitaminA ?? this.vitaminA,
      vitaminC: vitaminC ?? this.vitaminC,
      servingLabel: servingLabel ?? this.servingLabel,
      isPreset: isPreset ?? this.isPreset,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (sugar.present) {
      map['sugar'] = Variable<double>(sugar.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    if (sodium.present) {
      map['sodium'] = Variable<double>(sodium.value);
    }
    if (cholesterol.present) {
      map['cholesterol'] = Variable<double>(cholesterol.value);
    }
    if (potassium.present) {
      map['potassium'] = Variable<double>(potassium.value);
    }
    if (calcium.present) {
      map['calcium'] = Variable<double>(calcium.value);
    }
    if (iron.present) {
      map['iron'] = Variable<double>(iron.value);
    }
    if (vitaminA.present) {
      map['vitamin_a'] = Variable<double>(vitaminA.value);
    }
    if (vitaminC.present) {
      map['vitamin_c'] = Variable<double>(vitaminC.value);
    }
    if (servingLabel.present) {
      map['serving_label'] = Variable<String>(servingLabel.value);
    }
    if (isPreset.present) {
      map['is_preset'] = Variable<bool>(isPreset.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PantryFoodsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('sugar: $sugar, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('cholesterol: $cholesterol, ')
          ..write('potassium: $potassium, ')
          ..write('calcium: $calcium, ')
          ..write('iron: $iron, ')
          ..write('vitaminA: $vitaminA, ')
          ..write('vitaminC: $vitaminC, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('isPreset: $isPreset, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealTemplatesTable extends MealTemplates
    with TableInfo<$MealTemplatesTable, MealTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, name, createdAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealTemplate(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $MealTemplatesTable createAlias(String alias) {
    return $MealTemplatesTable(attachedDatabase, alias);
  }
}

class MealTemplate extends DataClass implements Insertable<MealTemplate> {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;
  final bool synced;
  const MealTemplate({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  MealTemplatesCompanion toCompanion(bool nullToAbsent) {
    return MealTemplatesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory MealTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealTemplate(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  MealTemplate copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? createdAt,
    bool? synced,
  }) => MealTemplate(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  MealTemplate copyWithCompanion(MealTemplatesCompanion data) {
    return MealTemplate(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealTemplate(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, name, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealTemplate &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class MealTemplatesCompanion extends UpdateCompanion<MealTemplate> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const MealTemplatesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealTemplatesCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name);
  static Insertable<MealTemplate> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return MealTemplatesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealTemplateItemsTable extends MealTemplateItems
    with TableInfo<$MealTemplateItemsTable, MealTemplateItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealTemplateItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pantryFoodIdMeta = const VerificationMeta(
    'pantryFoodId',
  );
  @override
  late final GeneratedColumn<String> pantryFoodId = GeneratedColumn<String>(
    'pantry_food_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<double> servings = GeneratedColumn<double>(
    'servings',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sugarMeta = const VerificationMeta('sugar');
  @override
  late final GeneratedColumn<double> sugar = GeneratedColumn<double>(
    'sugar',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
    'fiber',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sodiumMeta = const VerificationMeta('sodium');
  @override
  late final GeneratedColumn<double> sodium = GeneratedColumn<double>(
    'sodium',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cholesterolMeta = const VerificationMeta(
    'cholesterol',
  );
  @override
  late final GeneratedColumn<double> cholesterol = GeneratedColumn<double>(
    'cholesterol',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _potassiumMeta = const VerificationMeta(
    'potassium',
  );
  @override
  late final GeneratedColumn<double> potassium = GeneratedColumn<double>(
    'potassium',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calciumMeta = const VerificationMeta(
    'calcium',
  );
  @override
  late final GeneratedColumn<double> calcium = GeneratedColumn<double>(
    'calcium',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ironMeta = const VerificationMeta('iron');
  @override
  late final GeneratedColumn<double> iron = GeneratedColumn<double>(
    'iron',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vitaminAMeta = const VerificationMeta(
    'vitaminA',
  );
  @override
  late final GeneratedColumn<double> vitaminA = GeneratedColumn<double>(
    'vitamin_a',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vitaminCMeta = const VerificationMeta(
    'vitaminC',
  );
  @override
  late final GeneratedColumn<double> vitaminC = GeneratedColumn<double>(
    'vitamin_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    userId,
    pantryFoodId,
    servings,
    synced,
    name,
    calories,
    protein,
    carbs,
    fat,
    sugar,
    fiber,
    sodium,
    cholesterol,
    potassium,
    calcium,
    iron,
    vitaminA,
    vitaminC,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_template_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealTemplateItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('pantry_food_id')) {
      context.handle(
        _pantryFoodIdMeta,
        pantryFoodId.isAcceptableOrUnknown(
          data['pantry_food_id']!,
          _pantryFoodIdMeta,
        ),
      );
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    if (data.containsKey('sugar')) {
      context.handle(
        _sugarMeta,
        sugar.isAcceptableOrUnknown(data['sugar']!, _sugarMeta),
      );
    }
    if (data.containsKey('fiber')) {
      context.handle(
        _fiberMeta,
        fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta),
      );
    }
    if (data.containsKey('sodium')) {
      context.handle(
        _sodiumMeta,
        sodium.isAcceptableOrUnknown(data['sodium']!, _sodiumMeta),
      );
    }
    if (data.containsKey('cholesterol')) {
      context.handle(
        _cholesterolMeta,
        cholesterol.isAcceptableOrUnknown(
          data['cholesterol']!,
          _cholesterolMeta,
        ),
      );
    }
    if (data.containsKey('potassium')) {
      context.handle(
        _potassiumMeta,
        potassium.isAcceptableOrUnknown(data['potassium']!, _potassiumMeta),
      );
    }
    if (data.containsKey('calcium')) {
      context.handle(
        _calciumMeta,
        calcium.isAcceptableOrUnknown(data['calcium']!, _calciumMeta),
      );
    }
    if (data.containsKey('iron')) {
      context.handle(
        _ironMeta,
        iron.isAcceptableOrUnknown(data['iron']!, _ironMeta),
      );
    }
    if (data.containsKey('vitamin_a')) {
      context.handle(
        _vitaminAMeta,
        vitaminA.isAcceptableOrUnknown(data['vitamin_a']!, _vitaminAMeta),
      );
    }
    if (data.containsKey('vitamin_c')) {
      context.handle(
        _vitaminCMeta,
        vitaminC.isAcceptableOrUnknown(data['vitamin_c']!, _vitaminCMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealTemplateItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealTemplateItem(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      templateId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}template_id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      pantryFoodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pantry_food_id'],
      ),
      servings:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}servings'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      ),
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      ),
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      ),
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      ),
      sugar: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugar'],
      ),
      fiber: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber'],
      ),
      sodium: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium'],
      ),
      cholesterol: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cholesterol'],
      ),
      potassium: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}potassium'],
      ),
      calcium: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calcium'],
      ),
      iron: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}iron'],
      ),
      vitaminA: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vitamin_a'],
      ),
      vitaminC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vitamin_c'],
      ),
    );
  }

  @override
  $MealTemplateItemsTable createAlias(String alias) {
    return $MealTemplateItemsTable(attachedDatabase, alias);
  }
}

class MealTemplateItem extends DataClass
    implements Insertable<MealTemplateItem> {
  final String id;
  final String templateId;
  final String userId;

  /// Non-null for a pantry-linked item; null for a manually-entered one.
  final String? pantryFoodId;
  final double servings;
  final bool synced;
  final String? name;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? sugar;
  final double? fiber;
  final double? sodium;
  final double? cholesterol;
  final double? potassium;
  final double? calcium;
  final double? iron;
  final double? vitaminA;
  final double? vitaminC;
  const MealTemplateItem({
    required this.id,
    required this.templateId,
    required this.userId,
    this.pantryFoodId,
    required this.servings,
    required this.synced,
    this.name,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.sugar,
    this.fiber,
    this.sodium,
    this.cholesterol,
    this.potassium,
    this.calcium,
    this.iron,
    this.vitaminA,
    this.vitaminC,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || pantryFoodId != null) {
      map['pantry_food_id'] = Variable<String>(pantryFoodId);
    }
    map['servings'] = Variable<double>(servings);
    map['synced'] = Variable<bool>(synced);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || calories != null) {
      map['calories'] = Variable<double>(calories);
    }
    if (!nullToAbsent || protein != null) {
      map['protein'] = Variable<double>(protein);
    }
    if (!nullToAbsent || carbs != null) {
      map['carbs'] = Variable<double>(carbs);
    }
    if (!nullToAbsent || fat != null) {
      map['fat'] = Variable<double>(fat);
    }
    if (!nullToAbsent || sugar != null) {
      map['sugar'] = Variable<double>(sugar);
    }
    if (!nullToAbsent || fiber != null) {
      map['fiber'] = Variable<double>(fiber);
    }
    if (!nullToAbsent || sodium != null) {
      map['sodium'] = Variable<double>(sodium);
    }
    if (!nullToAbsent || cholesterol != null) {
      map['cholesterol'] = Variable<double>(cholesterol);
    }
    if (!nullToAbsent || potassium != null) {
      map['potassium'] = Variable<double>(potassium);
    }
    if (!nullToAbsent || calcium != null) {
      map['calcium'] = Variable<double>(calcium);
    }
    if (!nullToAbsent || iron != null) {
      map['iron'] = Variable<double>(iron);
    }
    if (!nullToAbsent || vitaminA != null) {
      map['vitamin_a'] = Variable<double>(vitaminA);
    }
    if (!nullToAbsent || vitaminC != null) {
      map['vitamin_c'] = Variable<double>(vitaminC);
    }
    return map;
  }

  MealTemplateItemsCompanion toCompanion(bool nullToAbsent) {
    return MealTemplateItemsCompanion(
      id: Value(id),
      templateId: Value(templateId),
      userId: Value(userId),
      pantryFoodId:
          pantryFoodId == null && nullToAbsent
              ? const Value.absent()
              : Value(pantryFoodId),
      servings: Value(servings),
      synced: Value(synced),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      calories:
          calories == null && nullToAbsent
              ? const Value.absent()
              : Value(calories),
      protein:
          protein == null && nullToAbsent
              ? const Value.absent()
              : Value(protein),
      carbs:
          carbs == null && nullToAbsent ? const Value.absent() : Value(carbs),
      fat: fat == null && nullToAbsent ? const Value.absent() : Value(fat),
      sugar:
          sugar == null && nullToAbsent ? const Value.absent() : Value(sugar),
      fiber:
          fiber == null && nullToAbsent ? const Value.absent() : Value(fiber),
      sodium:
          sodium == null && nullToAbsent ? const Value.absent() : Value(sodium),
      cholesterol:
          cholesterol == null && nullToAbsent
              ? const Value.absent()
              : Value(cholesterol),
      potassium:
          potassium == null && nullToAbsent
              ? const Value.absent()
              : Value(potassium),
      calcium:
          calcium == null && nullToAbsent
              ? const Value.absent()
              : Value(calcium),
      iron: iron == null && nullToAbsent ? const Value.absent() : Value(iron),
      vitaminA:
          vitaminA == null && nullToAbsent
              ? const Value.absent()
              : Value(vitaminA),
      vitaminC:
          vitaminC == null && nullToAbsent
              ? const Value.absent()
              : Value(vitaminC),
    );
  }

  factory MealTemplateItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealTemplateItem(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      userId: serializer.fromJson<String>(json['userId']),
      pantryFoodId: serializer.fromJson<String?>(json['pantryFoodId']),
      servings: serializer.fromJson<double>(json['servings']),
      synced: serializer.fromJson<bool>(json['synced']),
      name: serializer.fromJson<String?>(json['name']),
      calories: serializer.fromJson<double?>(json['calories']),
      protein: serializer.fromJson<double?>(json['protein']),
      carbs: serializer.fromJson<double?>(json['carbs']),
      fat: serializer.fromJson<double?>(json['fat']),
      sugar: serializer.fromJson<double?>(json['sugar']),
      fiber: serializer.fromJson<double?>(json['fiber']),
      sodium: serializer.fromJson<double?>(json['sodium']),
      cholesterol: serializer.fromJson<double?>(json['cholesterol']),
      potassium: serializer.fromJson<double?>(json['potassium']),
      calcium: serializer.fromJson<double?>(json['calcium']),
      iron: serializer.fromJson<double?>(json['iron']),
      vitaminA: serializer.fromJson<double?>(json['vitaminA']),
      vitaminC: serializer.fromJson<double?>(json['vitaminC']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'userId': serializer.toJson<String>(userId),
      'pantryFoodId': serializer.toJson<String?>(pantryFoodId),
      'servings': serializer.toJson<double>(servings),
      'synced': serializer.toJson<bool>(synced),
      'name': serializer.toJson<String?>(name),
      'calories': serializer.toJson<double?>(calories),
      'protein': serializer.toJson<double?>(protein),
      'carbs': serializer.toJson<double?>(carbs),
      'fat': serializer.toJson<double?>(fat),
      'sugar': serializer.toJson<double?>(sugar),
      'fiber': serializer.toJson<double?>(fiber),
      'sodium': serializer.toJson<double?>(sodium),
      'cholesterol': serializer.toJson<double?>(cholesterol),
      'potassium': serializer.toJson<double?>(potassium),
      'calcium': serializer.toJson<double?>(calcium),
      'iron': serializer.toJson<double?>(iron),
      'vitaminA': serializer.toJson<double?>(vitaminA),
      'vitaminC': serializer.toJson<double?>(vitaminC),
    };
  }

  MealTemplateItem copyWith({
    String? id,
    String? templateId,
    String? userId,
    Value<String?> pantryFoodId = const Value.absent(),
    double? servings,
    bool? synced,
    Value<String?> name = const Value.absent(),
    Value<double?> calories = const Value.absent(),
    Value<double?> protein = const Value.absent(),
    Value<double?> carbs = const Value.absent(),
    Value<double?> fat = const Value.absent(),
    Value<double?> sugar = const Value.absent(),
    Value<double?> fiber = const Value.absent(),
    Value<double?> sodium = const Value.absent(),
    Value<double?> cholesterol = const Value.absent(),
    Value<double?> potassium = const Value.absent(),
    Value<double?> calcium = const Value.absent(),
    Value<double?> iron = const Value.absent(),
    Value<double?> vitaminA = const Value.absent(),
    Value<double?> vitaminC = const Value.absent(),
  }) => MealTemplateItem(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    userId: userId ?? this.userId,
    pantryFoodId: pantryFoodId.present ? pantryFoodId.value : this.pantryFoodId,
    servings: servings ?? this.servings,
    synced: synced ?? this.synced,
    name: name.present ? name.value : this.name,
    calories: calories.present ? calories.value : this.calories,
    protein: protein.present ? protein.value : this.protein,
    carbs: carbs.present ? carbs.value : this.carbs,
    fat: fat.present ? fat.value : this.fat,
    sugar: sugar.present ? sugar.value : this.sugar,
    fiber: fiber.present ? fiber.value : this.fiber,
    sodium: sodium.present ? sodium.value : this.sodium,
    cholesterol: cholesterol.present ? cholesterol.value : this.cholesterol,
    potassium: potassium.present ? potassium.value : this.potassium,
    calcium: calcium.present ? calcium.value : this.calcium,
    iron: iron.present ? iron.value : this.iron,
    vitaminA: vitaminA.present ? vitaminA.value : this.vitaminA,
    vitaminC: vitaminC.present ? vitaminC.value : this.vitaminC,
  );
  MealTemplateItem copyWithCompanion(MealTemplateItemsCompanion data) {
    return MealTemplateItem(
      id: data.id.present ? data.id.value : this.id,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      userId: data.userId.present ? data.userId.value : this.userId,
      pantryFoodId:
          data.pantryFoodId.present
              ? data.pantryFoodId.value
              : this.pantryFoodId,
      servings: data.servings.present ? data.servings.value : this.servings,
      synced: data.synced.present ? data.synced.value : this.synced,
      name: data.name.present ? data.name.value : this.name,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      sugar: data.sugar.present ? data.sugar.value : this.sugar,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      sodium: data.sodium.present ? data.sodium.value : this.sodium,
      cholesterol:
          data.cholesterol.present ? data.cholesterol.value : this.cholesterol,
      potassium: data.potassium.present ? data.potassium.value : this.potassium,
      calcium: data.calcium.present ? data.calcium.value : this.calcium,
      iron: data.iron.present ? data.iron.value : this.iron,
      vitaminA: data.vitaminA.present ? data.vitaminA.value : this.vitaminA,
      vitaminC: data.vitaminC.present ? data.vitaminC.value : this.vitaminC,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealTemplateItem(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('userId: $userId, ')
          ..write('pantryFoodId: $pantryFoodId, ')
          ..write('servings: $servings, ')
          ..write('synced: $synced, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('sugar: $sugar, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('cholesterol: $cholesterol, ')
          ..write('potassium: $potassium, ')
          ..write('calcium: $calcium, ')
          ..write('iron: $iron, ')
          ..write('vitaminA: $vitaminA, ')
          ..write('vitaminC: $vitaminC')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    templateId,
    userId,
    pantryFoodId,
    servings,
    synced,
    name,
    calories,
    protein,
    carbs,
    fat,
    sugar,
    fiber,
    sodium,
    cholesterol,
    potassium,
    calcium,
    iron,
    vitaminA,
    vitaminC,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealTemplateItem &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.userId == this.userId &&
          other.pantryFoodId == this.pantryFoodId &&
          other.servings == this.servings &&
          other.synced == this.synced &&
          other.name == this.name &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.sugar == this.sugar &&
          other.fiber == this.fiber &&
          other.sodium == this.sodium &&
          other.cholesterol == this.cholesterol &&
          other.potassium == this.potassium &&
          other.calcium == this.calcium &&
          other.iron == this.iron &&
          other.vitaminA == this.vitaminA &&
          other.vitaminC == this.vitaminC);
}

class MealTemplateItemsCompanion extends UpdateCompanion<MealTemplateItem> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> userId;
  final Value<String?> pantryFoodId;
  final Value<double> servings;
  final Value<bool> synced;
  final Value<String?> name;
  final Value<double?> calories;
  final Value<double?> protein;
  final Value<double?> carbs;
  final Value<double?> fat;
  final Value<double?> sugar;
  final Value<double?> fiber;
  final Value<double?> sodium;
  final Value<double?> cholesterol;
  final Value<double?> potassium;
  final Value<double?> calcium;
  final Value<double?> iron;
  final Value<double?> vitaminA;
  final Value<double?> vitaminC;
  final Value<int> rowid;
  const MealTemplateItemsCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.userId = const Value.absent(),
    this.pantryFoodId = const Value.absent(),
    this.servings = const Value.absent(),
    this.synced = const Value.absent(),
    this.name = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.sugar = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sodium = const Value.absent(),
    this.cholesterol = const Value.absent(),
    this.potassium = const Value.absent(),
    this.calcium = const Value.absent(),
    this.iron = const Value.absent(),
    this.vitaminA = const Value.absent(),
    this.vitaminC = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealTemplateItemsCompanion.insert({
    required String id,
    required String templateId,
    required String userId,
    this.pantryFoodId = const Value.absent(),
    this.servings = const Value.absent(),
    this.synced = const Value.absent(),
    this.name = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.sugar = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sodium = const Value.absent(),
    this.cholesterol = const Value.absent(),
    this.potassium = const Value.absent(),
    this.calcium = const Value.absent(),
    this.iron = const Value.absent(),
    this.vitaminA = const Value.absent(),
    this.vitaminC = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       templateId = Value(templateId),
       userId = Value(userId);
  static Insertable<MealTemplateItem> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? userId,
    Expression<String>? pantryFoodId,
    Expression<double>? servings,
    Expression<bool>? synced,
    Expression<String>? name,
    Expression<double>? calories,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? fat,
    Expression<double>? sugar,
    Expression<double>? fiber,
    Expression<double>? sodium,
    Expression<double>? cholesterol,
    Expression<double>? potassium,
    Expression<double>? calcium,
    Expression<double>? iron,
    Expression<double>? vitaminA,
    Expression<double>? vitaminC,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (userId != null) 'user_id': userId,
      if (pantryFoodId != null) 'pantry_food_id': pantryFoodId,
      if (servings != null) 'servings': servings,
      if (synced != null) 'synced': synced,
      if (name != null) 'name': name,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (sugar != null) 'sugar': sugar,
      if (fiber != null) 'fiber': fiber,
      if (sodium != null) 'sodium': sodium,
      if (cholesterol != null) 'cholesterol': cholesterol,
      if (potassium != null) 'potassium': potassium,
      if (calcium != null) 'calcium': calcium,
      if (iron != null) 'iron': iron,
      if (vitaminA != null) 'vitamin_a': vitaminA,
      if (vitaminC != null) 'vitamin_c': vitaminC,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealTemplateItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? templateId,
    Value<String>? userId,
    Value<String?>? pantryFoodId,
    Value<double>? servings,
    Value<bool>? synced,
    Value<String?>? name,
    Value<double?>? calories,
    Value<double?>? protein,
    Value<double?>? carbs,
    Value<double?>? fat,
    Value<double?>? sugar,
    Value<double?>? fiber,
    Value<double?>? sodium,
    Value<double?>? cholesterol,
    Value<double?>? potassium,
    Value<double?>? calcium,
    Value<double?>? iron,
    Value<double?>? vitaminA,
    Value<double?>? vitaminC,
    Value<int>? rowid,
  }) {
    return MealTemplateItemsCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      userId: userId ?? this.userId,
      pantryFoodId: pantryFoodId ?? this.pantryFoodId,
      servings: servings ?? this.servings,
      synced: synced ?? this.synced,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      sugar: sugar ?? this.sugar,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      cholesterol: cholesterol ?? this.cholesterol,
      potassium: potassium ?? this.potassium,
      calcium: calcium ?? this.calcium,
      iron: iron ?? this.iron,
      vitaminA: vitaminA ?? this.vitaminA,
      vitaminC: vitaminC ?? this.vitaminC,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (pantryFoodId.present) {
      map['pantry_food_id'] = Variable<String>(pantryFoodId.value);
    }
    if (servings.present) {
      map['servings'] = Variable<double>(servings.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (sugar.present) {
      map['sugar'] = Variable<double>(sugar.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    if (sodium.present) {
      map['sodium'] = Variable<double>(sodium.value);
    }
    if (cholesterol.present) {
      map['cholesterol'] = Variable<double>(cholesterol.value);
    }
    if (potassium.present) {
      map['potassium'] = Variable<double>(potassium.value);
    }
    if (calcium.present) {
      map['calcium'] = Variable<double>(calcium.value);
    }
    if (iron.present) {
      map['iron'] = Variable<double>(iron.value);
    }
    if (vitaminA.present) {
      map['vitamin_a'] = Variable<double>(vitaminA.value);
    }
    if (vitaminC.present) {
      map['vitamin_c'] = Variable<double>(vitaminC.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealTemplateItemsCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('userId: $userId, ')
          ..write('pantryFoodId: $pantryFoodId, ')
          ..write('servings: $servings, ')
          ..write('synced: $synced, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('sugar: $sugar, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('cholesterol: $cholesterol, ')
          ..write('potassium: $potassium, ')
          ..write('calcium: $calcium, ')
          ..write('iron: $iron, ')
          ..write('vitaminA: $vitaminA, ')
          ..write('vitaminC: $vitaminC, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackedSubstancesTable extends TrackedSubstances
    with TableInfo<$TrackedSubstancesTable, TrackedSubstance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackedSubstancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitLabelMeta = const VerificationMeta(
    'unitLabel',
  );
  @override
  late final GeneratedColumn<String> unitLabel = GeneratedColumn<String>(
    'unit_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('drink'),
  );
  static const VerificationMeta _dailyLimitMeta = const VerificationMeta(
    'dailyLimit',
  );
  @override
  late final GeneratedColumn<double> dailyLimit = GeneratedColumn<double>(
    'daily_limit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weeklyLimitMeta = const VerificationMeta(
    'weeklyLimit',
  );
  @override
  late final GeneratedColumn<double> weeklyLimit = GeneratedColumn<double>(
    'weekly_limit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    unitLabel,
    dailyLimit,
    weeklyLimit,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracked_substances';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackedSubstance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit_label')) {
      context.handle(
        _unitLabelMeta,
        unitLabel.isAcceptableOrUnknown(data['unit_label']!, _unitLabelMeta),
      );
    }
    if (data.containsKey('daily_limit')) {
      context.handle(
        _dailyLimitMeta,
        dailyLimit.isAcceptableOrUnknown(data['daily_limit']!, _dailyLimitMeta),
      );
    }
    if (data.containsKey('weekly_limit')) {
      context.handle(
        _weeklyLimitMeta,
        weeklyLimit.isAcceptableOrUnknown(
          data['weekly_limit']!,
          _weeklyLimitMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackedSubstance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackedSubstance(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      unitLabel:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}unit_label'],
          )!,
      dailyLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}daily_limit'],
      ),
      weeklyLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weekly_limit'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $TrackedSubstancesTable createAlias(String alias) {
    return $TrackedSubstancesTable(attachedDatabase, alias);
  }
}

class TrackedSubstance extends DataClass
    implements Insertable<TrackedSubstance> {
  final String id;
  final String userId;
  final String name;

  /// Shown after counts, e.g. "3 drinks", "2 cigarettes".
  final String unitLabel;

  /// Optional limits — null means no target is set for that window.
  final double? dailyLimit;
  final double? weeklyLimit;
  final DateTime createdAt;
  final bool synced;
  const TrackedSubstance({
    required this.id,
    required this.userId,
    required this.name,
    required this.unitLabel,
    this.dailyLimit,
    this.weeklyLimit,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['unit_label'] = Variable<String>(unitLabel);
    if (!nullToAbsent || dailyLimit != null) {
      map['daily_limit'] = Variable<double>(dailyLimit);
    }
    if (!nullToAbsent || weeklyLimit != null) {
      map['weekly_limit'] = Variable<double>(weeklyLimit);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  TrackedSubstancesCompanion toCompanion(bool nullToAbsent) {
    return TrackedSubstancesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      unitLabel: Value(unitLabel),
      dailyLimit:
          dailyLimit == null && nullToAbsent
              ? const Value.absent()
              : Value(dailyLimit),
      weeklyLimit:
          weeklyLimit == null && nullToAbsent
              ? const Value.absent()
              : Value(weeklyLimit),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory TrackedSubstance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackedSubstance(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      unitLabel: serializer.fromJson<String>(json['unitLabel']),
      dailyLimit: serializer.fromJson<double?>(json['dailyLimit']),
      weeklyLimit: serializer.fromJson<double?>(json['weeklyLimit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'unitLabel': serializer.toJson<String>(unitLabel),
      'dailyLimit': serializer.toJson<double?>(dailyLimit),
      'weeklyLimit': serializer.toJson<double?>(weeklyLimit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  TrackedSubstance copyWith({
    String? id,
    String? userId,
    String? name,
    String? unitLabel,
    Value<double?> dailyLimit = const Value.absent(),
    Value<double?> weeklyLimit = const Value.absent(),
    DateTime? createdAt,
    bool? synced,
  }) => TrackedSubstance(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    unitLabel: unitLabel ?? this.unitLabel,
    dailyLimit: dailyLimit.present ? dailyLimit.value : this.dailyLimit,
    weeklyLimit: weeklyLimit.present ? weeklyLimit.value : this.weeklyLimit,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  TrackedSubstance copyWithCompanion(TrackedSubstancesCompanion data) {
    return TrackedSubstance(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      unitLabel: data.unitLabel.present ? data.unitLabel.value : this.unitLabel,
      dailyLimit:
          data.dailyLimit.present ? data.dailyLimit.value : this.dailyLimit,
      weeklyLimit:
          data.weeklyLimit.present ? data.weeklyLimit.value : this.weeklyLimit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackedSubstance(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('unitLabel: $unitLabel, ')
          ..write('dailyLimit: $dailyLimit, ')
          ..write('weeklyLimit: $weeklyLimit, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    unitLabel,
    dailyLimit,
    weeklyLimit,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackedSubstance &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.unitLabel == this.unitLabel &&
          other.dailyLimit == this.dailyLimit &&
          other.weeklyLimit == this.weeklyLimit &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class TrackedSubstancesCompanion extends UpdateCompanion<TrackedSubstance> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> unitLabel;
  final Value<double?> dailyLimit;
  final Value<double?> weeklyLimit;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const TrackedSubstancesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.unitLabel = const Value.absent(),
    this.dailyLimit = const Value.absent(),
    this.weeklyLimit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackedSubstancesCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.unitLabel = const Value.absent(),
    this.dailyLimit = const Value.absent(),
    this.weeklyLimit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name);
  static Insertable<TrackedSubstance> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? unitLabel,
    Expression<double>? dailyLimit,
    Expression<double>? weeklyLimit,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (unitLabel != null) 'unit_label': unitLabel,
      if (dailyLimit != null) 'daily_limit': dailyLimit,
      if (weeklyLimit != null) 'weekly_limit': weeklyLimit,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackedSubstancesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? unitLabel,
    Value<double?>? dailyLimit,
    Value<double?>? weeklyLimit,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return TrackedSubstancesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      unitLabel: unitLabel ?? this.unitLabel,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      weeklyLimit: weeklyLimit ?? this.weeklyLimit,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unitLabel.present) {
      map['unit_label'] = Variable<String>(unitLabel.value);
    }
    if (dailyLimit.present) {
      map['daily_limit'] = Variable<double>(dailyLimit.value);
    }
    if (weeklyLimit.present) {
      map['weekly_limit'] = Variable<double>(weeklyLimit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackedSubstancesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('unitLabel: $unitLabel, ')
          ..write('dailyLimit: $dailyLimit, ')
          ..write('weeklyLimit: $weeklyLimit, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubstanceLogsTable extends SubstanceLogs
    with TableInfo<$SubstanceLogsTable, SubstanceLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubstanceLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _substanceIdMeta = const VerificationMeta(
    'substanceId',
  );
  @override
  late final GeneratedColumn<String> substanceId = GeneratedColumn<String>(
    'substance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    substanceId,
    userId,
    amount,
    loggedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'substance_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubstanceLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('substance_id')) {
      context.handle(
        _substanceIdMeta,
        substanceId.isAcceptableOrUnknown(
          data['substance_id']!,
          _substanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_substanceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubstanceLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubstanceLog(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      substanceId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}substance_id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      amount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}amount'],
          )!,
      loggedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}logged_at'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $SubstanceLogsTable createAlias(String alias) {
    return $SubstanceLogsTable(attachedDatabase, alias);
  }
}

class SubstanceLog extends DataClass implements Insertable<SubstanceLog> {
  final String id;
  final String substanceId;
  final String userId;
  final double amount;
  final DateTime loggedAt;
  final bool synced;
  const SubstanceLog({
    required this.id,
    required this.substanceId,
    required this.userId,
    required this.amount,
    required this.loggedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['substance_id'] = Variable<String>(substanceId);
    map['user_id'] = Variable<String>(userId);
    map['amount'] = Variable<double>(amount);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  SubstanceLogsCompanion toCompanion(bool nullToAbsent) {
    return SubstanceLogsCompanion(
      id: Value(id),
      substanceId: Value(substanceId),
      userId: Value(userId),
      amount: Value(amount),
      loggedAt: Value(loggedAt),
      synced: Value(synced),
    );
  }

  factory SubstanceLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubstanceLog(
      id: serializer.fromJson<String>(json['id']),
      substanceId: serializer.fromJson<String>(json['substanceId']),
      userId: serializer.fromJson<String>(json['userId']),
      amount: serializer.fromJson<double>(json['amount']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'substanceId': serializer.toJson<String>(substanceId),
      'userId': serializer.toJson<String>(userId),
      'amount': serializer.toJson<double>(amount),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  SubstanceLog copyWith({
    String? id,
    String? substanceId,
    String? userId,
    double? amount,
    DateTime? loggedAt,
    bool? synced,
  }) => SubstanceLog(
    id: id ?? this.id,
    substanceId: substanceId ?? this.substanceId,
    userId: userId ?? this.userId,
    amount: amount ?? this.amount,
    loggedAt: loggedAt ?? this.loggedAt,
    synced: synced ?? this.synced,
  );
  SubstanceLog copyWithCompanion(SubstanceLogsCompanion data) {
    return SubstanceLog(
      id: data.id.present ? data.id.value : this.id,
      substanceId:
          data.substanceId.present ? data.substanceId.value : this.substanceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      amount: data.amount.present ? data.amount.value : this.amount,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubstanceLog(')
          ..write('id: $id, ')
          ..write('substanceId: $substanceId, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, substanceId, userId, amount, loggedAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubstanceLog &&
          other.id == this.id &&
          other.substanceId == this.substanceId &&
          other.userId == this.userId &&
          other.amount == this.amount &&
          other.loggedAt == this.loggedAt &&
          other.synced == this.synced);
}

class SubstanceLogsCompanion extends UpdateCompanion<SubstanceLog> {
  final Value<String> id;
  final Value<String> substanceId;
  final Value<String> userId;
  final Value<double> amount;
  final Value<DateTime> loggedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const SubstanceLogsCompanion({
    this.id = const Value.absent(),
    this.substanceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.amount = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubstanceLogsCompanion.insert({
    required String id,
    required String substanceId,
    required String userId,
    this.amount = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       substanceId = Value(substanceId),
       userId = Value(userId);
  static Insertable<SubstanceLog> custom({
    Expression<String>? id,
    Expression<String>? substanceId,
    Expression<String>? userId,
    Expression<double>? amount,
    Expression<DateTime>? loggedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (substanceId != null) 'substance_id': substanceId,
      if (userId != null) 'user_id': userId,
      if (amount != null) 'amount': amount,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubstanceLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? substanceId,
    Value<String>? userId,
    Value<double>? amount,
    Value<DateTime>? loggedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return SubstanceLogsCompanion(
      id: id ?? this.id,
      substanceId: substanceId ?? this.substanceId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      loggedAt: loggedAt ?? this.loggedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (substanceId.present) {
      map['substance_id'] = Variable<String>(substanceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubstanceLogsCompanion(')
          ..write('id: $id, ')
          ..write('substanceId: $substanceId, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitCompletionsTable habitCompletions = $HabitCompletionsTable(
    this,
  );
  late final $HabitSkipsTable habitSkips = $HabitSkipsTable(this);
  late final $MealsTable meals = $MealsTable(this);
  late final $FoodEntriesTable foodEntries = $FoodEntriesTable(this);
  late final $WaterLogsTable waterLogs = $WaterLogsTable(this);
  late final $DailyNutritionGoalsTable dailyNutritionGoals =
      $DailyNutritionGoalsTable(this);
  late final $PantryFoodsTable pantryFoods = $PantryFoodsTable(this);
  late final $MealTemplatesTable mealTemplates = $MealTemplatesTable(this);
  late final $MealTemplateItemsTable mealTemplateItems =
      $MealTemplateItemsTable(this);
  late final $TrackedSubstancesTable trackedSubstances =
      $TrackedSubstancesTable(this);
  late final $SubstanceLogsTable substanceLogs = $SubstanceLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    habits,
    habitCompletions,
    habitSkips,
    meals,
    foodEntries,
    waterLogs,
    dailyNutritionGoals,
    pantryFoods,
    mealTemplates,
    mealTemplateItems,
    trackedSubstances,
    substanceLogs,
  ];
}

typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<String> frequencyType,
      Value<int> targetDaysPerWeek,
      Value<int> skipsAllowedPerWeek,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String> frequencyType,
      Value<int> targetDaysPerWeek,
      Value<int> skipsAllowedPerWeek,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetDaysPerWeek => $composableBuilder(
    column: $table.targetDaysPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skipsAllowedPerWeek => $composableBuilder(
    column: $table.skipsAllowedPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetDaysPerWeek => $composableBuilder(
    column: $table.targetDaysPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skipsAllowedPerWeek => $composableBuilder(
    column: $table.skipsAllowedPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetDaysPerWeek => $composableBuilder(
    column: $table.targetDaysPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skipsAllowedPerWeek => $composableBuilder(
    column: $table.skipsAllowedPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
          Habit,
          PrefetchHooks Function()
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> frequencyType = const Value.absent(),
                Value<int> targetDaysPerWeek = const Value.absent(),
                Value<int> skipsAllowedPerWeek = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                userId: userId,
                name: name,
                frequencyType: frequencyType,
                targetDaysPerWeek: targetDaysPerWeek,
                skipsAllowedPerWeek: skipsAllowedPerWeek,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<String> frequencyType = const Value.absent(),
                Value<int> targetDaysPerWeek = const Value.absent(),
                Value<int> skipsAllowedPerWeek = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                frequencyType: frequencyType,
                targetDaysPerWeek: targetDaysPerWeek,
                skipsAllowedPerWeek: skipsAllowedPerWeek,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
      Habit,
      PrefetchHooks Function()
    >;
typedef $$HabitCompletionsTableCreateCompanionBuilder =
    HabitCompletionsCompanion Function({
      required String id,
      required String habitId,
      required String userId,
      required DateTime completedDate,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$HabitCompletionsTableUpdateCompanionBuilder =
    HabitCompletionsCompanion Function({
      Value<String> id,
      Value<String> habitId,
      Value<String> userId,
      Value<DateTime> completedDate,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$HabitCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$HabitCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitCompletionsTable,
          HabitCompletion,
          $$HabitCompletionsTableFilterComposer,
          $$HabitCompletionsTableOrderingComposer,
          $$HabitCompletionsTableAnnotationComposer,
          $$HabitCompletionsTableCreateCompanionBuilder,
          $$HabitCompletionsTableUpdateCompanionBuilder,
          (
            HabitCompletion,
            BaseReferences<
              _$AppDatabase,
              $HabitCompletionsTable,
              HabitCompletion
            >,
          ),
          HabitCompletion,
          PrefetchHooks Function()
        > {
  $$HabitCompletionsTableTableManager(
    _$AppDatabase db,
    $HabitCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$HabitCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$HabitCompletionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$HabitCompletionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> completedDate = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitCompletionsCompanion(
                id: id,
                habitId: habitId,
                userId: userId,
                completedDate: completedDate,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitId,
                required String userId,
                required DateTime completedDate,
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitCompletionsCompanion.insert(
                id: id,
                habitId: habitId,
                userId: userId,
                completedDate: completedDate,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitCompletionsTable,
      HabitCompletion,
      $$HabitCompletionsTableFilterComposer,
      $$HabitCompletionsTableOrderingComposer,
      $$HabitCompletionsTableAnnotationComposer,
      $$HabitCompletionsTableCreateCompanionBuilder,
      $$HabitCompletionsTableUpdateCompanionBuilder,
      (
        HabitCompletion,
        BaseReferences<_$AppDatabase, $HabitCompletionsTable, HabitCompletion>,
      ),
      HabitCompletion,
      PrefetchHooks Function()
    >;
typedef $$HabitSkipsTableCreateCompanionBuilder =
    HabitSkipsCompanion Function({
      required String id,
      required String habitId,
      required String userId,
      required DateTime weekStart,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$HabitSkipsTableUpdateCompanionBuilder =
    HabitSkipsCompanion Function({
      Value<String> id,
      Value<String> habitId,
      Value<String> userId,
      Value<DateTime> weekStart,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$HabitSkipsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitSkipsTable> {
  $$HabitSkipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitSkipsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitSkipsTable> {
  $$HabitSkipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitSkipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitSkipsTable> {
  $$HabitSkipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$HabitSkipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitSkipsTable,
          HabitSkip,
          $$HabitSkipsTableFilterComposer,
          $$HabitSkipsTableOrderingComposer,
          $$HabitSkipsTableAnnotationComposer,
          $$HabitSkipsTableCreateCompanionBuilder,
          $$HabitSkipsTableUpdateCompanionBuilder,
          (
            HabitSkip,
            BaseReferences<_$AppDatabase, $HabitSkipsTable, HabitSkip>,
          ),
          HabitSkip,
          PrefetchHooks Function()
        > {
  $$HabitSkipsTableTableManager(_$AppDatabase db, $HabitSkipsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$HabitSkipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$HabitSkipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$HabitSkipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> weekStart = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitSkipsCompanion(
                id: id,
                habitId: habitId,
                userId: userId,
                weekStart: weekStart,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitId,
                required String userId,
                required DateTime weekStart,
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitSkipsCompanion.insert(
                id: id,
                habitId: habitId,
                userId: userId,
                weekStart: weekStart,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitSkipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitSkipsTable,
      HabitSkip,
      $$HabitSkipsTableFilterComposer,
      $$HabitSkipsTableOrderingComposer,
      $$HabitSkipsTableAnnotationComposer,
      $$HabitSkipsTableCreateCompanionBuilder,
      $$HabitSkipsTableUpdateCompanionBuilder,
      (HabitSkip, BaseReferences<_$AppDatabase, $HabitSkipsTable, HabitSkip>),
      HabitSkip,
      PrefetchHooks Function()
    >;
typedef $$MealsTableCreateCompanionBuilder =
    MealsCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<DateTime> loggedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$MealsTableUpdateCompanionBuilder =
    MealsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<DateTime> loggedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$MealsTableFilterComposer extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MealsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$MealsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealsTable,
          Meal,
          $$MealsTableFilterComposer,
          $$MealsTableOrderingComposer,
          $$MealsTableAnnotationComposer,
          $$MealsTableCreateCompanionBuilder,
          $$MealsTableUpdateCompanionBuilder,
          (Meal, BaseReferences<_$AppDatabase, $MealsTable, Meal>),
          Meal,
          PrefetchHooks Function()
        > {
  $$MealsTableTableManager(_$AppDatabase db, $MealsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealsCompanion(
                id: id,
                userId: userId,
                name: name,
                loggedAt: loggedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<DateTime> loggedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                loggedAt: loggedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MealsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealsTable,
      Meal,
      $$MealsTableFilterComposer,
      $$MealsTableOrderingComposer,
      $$MealsTableAnnotationComposer,
      $$MealsTableCreateCompanionBuilder,
      $$MealsTableUpdateCompanionBuilder,
      (Meal, BaseReferences<_$AppDatabase, $MealsTable, Meal>),
      Meal,
      PrefetchHooks Function()
    >;
typedef $$FoodEntriesTableCreateCompanionBuilder =
    FoodEntriesCompanion Function({
      required String id,
      required String mealId,
      required String userId,
      required String name,
      Value<double> calories,
      Value<double> protein,
      Value<double> carbs,
      Value<double> fat,
      Value<double> sugar,
      Value<double> fiber,
      Value<double> sodium,
      Value<double> cholesterol,
      Value<double> potassium,
      Value<double> calcium,
      Value<double> iron,
      Value<double> vitaminA,
      Value<double> vitaminC,
      Value<String?> pantryFoodId,
      Value<double> servings,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$FoodEntriesTableUpdateCompanionBuilder =
    FoodEntriesCompanion Function({
      Value<String> id,
      Value<String> mealId,
      Value<String> userId,
      Value<String> name,
      Value<double> calories,
      Value<double> protein,
      Value<double> carbs,
      Value<double> fat,
      Value<double> sugar,
      Value<double> fiber,
      Value<double> sodium,
      Value<double> cholesterol,
      Value<double> potassium,
      Value<double> calcium,
      Value<double> iron,
      Value<double> vitaminA,
      Value<double> vitaminC,
      Value<String?> pantryFoodId,
      Value<double> servings,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$FoodEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealId => $composableBuilder(
    column: $table.mealId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cholesterol => $composableBuilder(
    column: $table.cholesterol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get potassium => $composableBuilder(
    column: $table.potassium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calcium => $composableBuilder(
    column: $table.calcium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get iron => $composableBuilder(
    column: $table.iron,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitaminA => $composableBuilder(
    column: $table.vitaminA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitaminC => $composableBuilder(
    column: $table.vitaminC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pantryFoodId => $composableBuilder(
    column: $table.pantryFoodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealId => $composableBuilder(
    column: $table.mealId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cholesterol => $composableBuilder(
    column: $table.cholesterol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get potassium => $composableBuilder(
    column: $table.potassium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calcium => $composableBuilder(
    column: $table.calcium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get iron => $composableBuilder(
    column: $table.iron,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitaminA => $composableBuilder(
    column: $table.vitaminA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitaminC => $composableBuilder(
    column: $table.vitaminC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pantryFoodId => $composableBuilder(
    column: $table.pantryFoodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mealId =>
      $composableBuilder(column: $table.mealId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get sugar =>
      $composableBuilder(column: $table.sugar, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<double> get sodium =>
      $composableBuilder(column: $table.sodium, builder: (column) => column);

  GeneratedColumn<double> get cholesterol => $composableBuilder(
    column: $table.cholesterol,
    builder: (column) => column,
  );

  GeneratedColumn<double> get potassium =>
      $composableBuilder(column: $table.potassium, builder: (column) => column);

  GeneratedColumn<double> get calcium =>
      $composableBuilder(column: $table.calcium, builder: (column) => column);

  GeneratedColumn<double> get iron =>
      $composableBuilder(column: $table.iron, builder: (column) => column);

  GeneratedColumn<double> get vitaminA =>
      $composableBuilder(column: $table.vitaminA, builder: (column) => column);

  GeneratedColumn<double> get vitaminC =>
      $composableBuilder(column: $table.vitaminC, builder: (column) => column);

  GeneratedColumn<String> get pantryFoodId => $composableBuilder(
    column: $table.pantryFoodId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$FoodEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodEntriesTable,
          FoodEntry,
          $$FoodEntriesTableFilterComposer,
          $$FoodEntriesTableOrderingComposer,
          $$FoodEntriesTableAnnotationComposer,
          $$FoodEntriesTableCreateCompanionBuilder,
          $$FoodEntriesTableUpdateCompanionBuilder,
          (
            FoodEntry,
            BaseReferences<_$AppDatabase, $FoodEntriesTable, FoodEntry>,
          ),
          FoodEntry,
          PrefetchHooks Function()
        > {
  $$FoodEntriesTableTableManager(_$AppDatabase db, $FoodEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$FoodEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$FoodEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$FoodEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mealId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<double> sugar = const Value.absent(),
                Value<double> fiber = const Value.absent(),
                Value<double> sodium = const Value.absent(),
                Value<double> cholesterol = const Value.absent(),
                Value<double> potassium = const Value.absent(),
                Value<double> calcium = const Value.absent(),
                Value<double> iron = const Value.absent(),
                Value<double> vitaminA = const Value.absent(),
                Value<double> vitaminC = const Value.absent(),
                Value<String?> pantryFoodId = const Value.absent(),
                Value<double> servings = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodEntriesCompanion(
                id: id,
                mealId: mealId,
                userId: userId,
                name: name,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                sugar: sugar,
                fiber: fiber,
                sodium: sodium,
                cholesterol: cholesterol,
                potassium: potassium,
                calcium: calcium,
                iron: iron,
                vitaminA: vitaminA,
                vitaminC: vitaminC,
                pantryFoodId: pantryFoodId,
                servings: servings,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mealId,
                required String userId,
                required String name,
                Value<double> calories = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<double> sugar = const Value.absent(),
                Value<double> fiber = const Value.absent(),
                Value<double> sodium = const Value.absent(),
                Value<double> cholesterol = const Value.absent(),
                Value<double> potassium = const Value.absent(),
                Value<double> calcium = const Value.absent(),
                Value<double> iron = const Value.absent(),
                Value<double> vitaminA = const Value.absent(),
                Value<double> vitaminC = const Value.absent(),
                Value<String?> pantryFoodId = const Value.absent(),
                Value<double> servings = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodEntriesCompanion.insert(
                id: id,
                mealId: mealId,
                userId: userId,
                name: name,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                sugar: sugar,
                fiber: fiber,
                sodium: sodium,
                cholesterol: cholesterol,
                potassium: potassium,
                calcium: calcium,
                iron: iron,
                vitaminA: vitaminA,
                vitaminC: vitaminC,
                pantryFoodId: pantryFoodId,
                servings: servings,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodEntriesTable,
      FoodEntry,
      $$FoodEntriesTableFilterComposer,
      $$FoodEntriesTableOrderingComposer,
      $$FoodEntriesTableAnnotationComposer,
      $$FoodEntriesTableCreateCompanionBuilder,
      $$FoodEntriesTableUpdateCompanionBuilder,
      (FoodEntry, BaseReferences<_$AppDatabase, $FoodEntriesTable, FoodEntry>),
      FoodEntry,
      PrefetchHooks Function()
    >;
typedef $$WaterLogsTableCreateCompanionBuilder =
    WaterLogsCompanion Function({
      required String id,
      required String userId,
      required double amountMl,
      Value<DateTime> loggedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$WaterLogsTableUpdateCompanionBuilder =
    WaterLogsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<double> amountMl,
      Value<DateTime> loggedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$WaterLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountMl => $composableBuilder(
    column: $table.amountMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WaterLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountMl => $composableBuilder(
    column: $table.amountMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WaterLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get amountMl =>
      $composableBuilder(column: $table.amountMl, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$WaterLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WaterLogsTable,
          WaterLog,
          $$WaterLogsTableFilterComposer,
          $$WaterLogsTableOrderingComposer,
          $$WaterLogsTableAnnotationComposer,
          $$WaterLogsTableCreateCompanionBuilder,
          $$WaterLogsTableUpdateCompanionBuilder,
          (WaterLog, BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLog>),
          WaterLog,
          PrefetchHooks Function()
        > {
  $$WaterLogsTableTableManager(_$AppDatabase db, $WaterLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$WaterLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$WaterLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$WaterLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<double> amountMl = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WaterLogsCompanion(
                id: id,
                userId: userId,
                amountMl: amountMl,
                loggedAt: loggedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required double amountMl,
                Value<DateTime> loggedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WaterLogsCompanion.insert(
                id: id,
                userId: userId,
                amountMl: amountMl,
                loggedAt: loggedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WaterLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WaterLogsTable,
      WaterLog,
      $$WaterLogsTableFilterComposer,
      $$WaterLogsTableOrderingComposer,
      $$WaterLogsTableAnnotationComposer,
      $$WaterLogsTableCreateCompanionBuilder,
      $$WaterLogsTableUpdateCompanionBuilder,
      (WaterLog, BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLog>),
      WaterLog,
      PrefetchHooks Function()
    >;
typedef $$DailyNutritionGoalsTableCreateCompanionBuilder =
    DailyNutritionGoalsCompanion Function({
      required String userId,
      Value<double> calories,
      Value<double> protein,
      Value<double> carbs,
      Value<double> fat,
      Value<double> waterMl,
      Value<double> fiber,
      Value<double> sodium,
      Value<double> cholesterol,
      Value<double> potassium,
      Value<double> calcium,
      Value<double> iron,
      Value<double> vitaminA,
      Value<double> vitaminC,
      Value<double?> currentWeightKg,
      Value<double?> targetWeightKg,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$DailyNutritionGoalsTableUpdateCompanionBuilder =
    DailyNutritionGoalsCompanion Function({
      Value<String> userId,
      Value<double> calories,
      Value<double> protein,
      Value<double> carbs,
      Value<double> fat,
      Value<double> waterMl,
      Value<double> fiber,
      Value<double> sodium,
      Value<double> cholesterol,
      Value<double> potassium,
      Value<double> calcium,
      Value<double> iron,
      Value<double> vitaminA,
      Value<double> vitaminC,
      Value<double?> currentWeightKg,
      Value<double?> targetWeightKg,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$DailyNutritionGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyNutritionGoalsTable> {
  $$DailyNutritionGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waterMl => $composableBuilder(
    column: $table.waterMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cholesterol => $composableBuilder(
    column: $table.cholesterol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get potassium => $composableBuilder(
    column: $table.potassium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calcium => $composableBuilder(
    column: $table.calcium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get iron => $composableBuilder(
    column: $table.iron,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitaminA => $composableBuilder(
    column: $table.vitaminA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitaminC => $composableBuilder(
    column: $table.vitaminC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentWeightKg => $composableBuilder(
    column: $table.currentWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyNutritionGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyNutritionGoalsTable> {
  $$DailyNutritionGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waterMl => $composableBuilder(
    column: $table.waterMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cholesterol => $composableBuilder(
    column: $table.cholesterol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get potassium => $composableBuilder(
    column: $table.potassium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calcium => $composableBuilder(
    column: $table.calcium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get iron => $composableBuilder(
    column: $table.iron,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitaminA => $composableBuilder(
    column: $table.vitaminA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitaminC => $composableBuilder(
    column: $table.vitaminC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentWeightKg => $composableBuilder(
    column: $table.currentWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyNutritionGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyNutritionGoalsTable> {
  $$DailyNutritionGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get waterMl =>
      $composableBuilder(column: $table.waterMl, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<double> get sodium =>
      $composableBuilder(column: $table.sodium, builder: (column) => column);

  GeneratedColumn<double> get cholesterol => $composableBuilder(
    column: $table.cholesterol,
    builder: (column) => column,
  );

  GeneratedColumn<double> get potassium =>
      $composableBuilder(column: $table.potassium, builder: (column) => column);

  GeneratedColumn<double> get calcium =>
      $composableBuilder(column: $table.calcium, builder: (column) => column);

  GeneratedColumn<double> get iron =>
      $composableBuilder(column: $table.iron, builder: (column) => column);

  GeneratedColumn<double> get vitaminA =>
      $composableBuilder(column: $table.vitaminA, builder: (column) => column);

  GeneratedColumn<double> get vitaminC =>
      $composableBuilder(column: $table.vitaminC, builder: (column) => column);

  GeneratedColumn<double> get currentWeightKg => $composableBuilder(
    column: $table.currentWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$DailyNutritionGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyNutritionGoalsTable,
          DailyNutritionGoal,
          $$DailyNutritionGoalsTableFilterComposer,
          $$DailyNutritionGoalsTableOrderingComposer,
          $$DailyNutritionGoalsTableAnnotationComposer,
          $$DailyNutritionGoalsTableCreateCompanionBuilder,
          $$DailyNutritionGoalsTableUpdateCompanionBuilder,
          (
            DailyNutritionGoal,
            BaseReferences<
              _$AppDatabase,
              $DailyNutritionGoalsTable,
              DailyNutritionGoal
            >,
          ),
          DailyNutritionGoal,
          PrefetchHooks Function()
        > {
  $$DailyNutritionGoalsTableTableManager(
    _$AppDatabase db,
    $DailyNutritionGoalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DailyNutritionGoalsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$DailyNutritionGoalsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$DailyNutritionGoalsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<double> waterMl = const Value.absent(),
                Value<double> fiber = const Value.absent(),
                Value<double> sodium = const Value.absent(),
                Value<double> cholesterol = const Value.absent(),
                Value<double> potassium = const Value.absent(),
                Value<double> calcium = const Value.absent(),
                Value<double> iron = const Value.absent(),
                Value<double> vitaminA = const Value.absent(),
                Value<double> vitaminC = const Value.absent(),
                Value<double?> currentWeightKg = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyNutritionGoalsCompanion(
                userId: userId,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                waterMl: waterMl,
                fiber: fiber,
                sodium: sodium,
                cholesterol: cholesterol,
                potassium: potassium,
                calcium: calcium,
                iron: iron,
                vitaminA: vitaminA,
                vitaminC: vitaminC,
                currentWeightKg: currentWeightKg,
                targetWeightKg: targetWeightKg,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<double> calories = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<double> waterMl = const Value.absent(),
                Value<double> fiber = const Value.absent(),
                Value<double> sodium = const Value.absent(),
                Value<double> cholesterol = const Value.absent(),
                Value<double> potassium = const Value.absent(),
                Value<double> calcium = const Value.absent(),
                Value<double> iron = const Value.absent(),
                Value<double> vitaminA = const Value.absent(),
                Value<double> vitaminC = const Value.absent(),
                Value<double?> currentWeightKg = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyNutritionGoalsCompanion.insert(
                userId: userId,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                waterMl: waterMl,
                fiber: fiber,
                sodium: sodium,
                cholesterol: cholesterol,
                potassium: potassium,
                calcium: calcium,
                iron: iron,
                vitaminA: vitaminA,
                vitaminC: vitaminC,
                currentWeightKg: currentWeightKg,
                targetWeightKg: targetWeightKg,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyNutritionGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyNutritionGoalsTable,
      DailyNutritionGoal,
      $$DailyNutritionGoalsTableFilterComposer,
      $$DailyNutritionGoalsTableOrderingComposer,
      $$DailyNutritionGoalsTableAnnotationComposer,
      $$DailyNutritionGoalsTableCreateCompanionBuilder,
      $$DailyNutritionGoalsTableUpdateCompanionBuilder,
      (
        DailyNutritionGoal,
        BaseReferences<
          _$AppDatabase,
          $DailyNutritionGoalsTable,
          DailyNutritionGoal
        >,
      ),
      DailyNutritionGoal,
      PrefetchHooks Function()
    >;
typedef $$PantryFoodsTableCreateCompanionBuilder =
    PantryFoodsCompanion Function({
      required String id,
      Value<String?> userId,
      required String name,
      Value<double> calories,
      Value<double> protein,
      Value<double> carbs,
      Value<double> fat,
      Value<double> sugar,
      Value<double> fiber,
      Value<double> sodium,
      Value<double> cholesterol,
      Value<double> potassium,
      Value<double> calcium,
      Value<double> iron,
      Value<double> vitaminA,
      Value<double> vitaminC,
      Value<String> servingLabel,
      Value<bool> isPreset,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$PantryFoodsTableUpdateCompanionBuilder =
    PantryFoodsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String> name,
      Value<double> calories,
      Value<double> protein,
      Value<double> carbs,
      Value<double> fat,
      Value<double> sugar,
      Value<double> fiber,
      Value<double> sodium,
      Value<double> cholesterol,
      Value<double> potassium,
      Value<double> calcium,
      Value<double> iron,
      Value<double> vitaminA,
      Value<double> vitaminC,
      Value<String> servingLabel,
      Value<bool> isPreset,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$PantryFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $PantryFoodsTable> {
  $$PantryFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cholesterol => $composableBuilder(
    column: $table.cholesterol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get potassium => $composableBuilder(
    column: $table.potassium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calcium => $composableBuilder(
    column: $table.calcium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get iron => $composableBuilder(
    column: $table.iron,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitaminA => $composableBuilder(
    column: $table.vitaminA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitaminC => $composableBuilder(
    column: $table.vitaminC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PantryFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $PantryFoodsTable> {
  $$PantryFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cholesterol => $composableBuilder(
    column: $table.cholesterol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get potassium => $composableBuilder(
    column: $table.potassium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calcium => $composableBuilder(
    column: $table.calcium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get iron => $composableBuilder(
    column: $table.iron,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitaminA => $composableBuilder(
    column: $table.vitaminA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitaminC => $composableBuilder(
    column: $table.vitaminC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PantryFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PantryFoodsTable> {
  $$PantryFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get sugar =>
      $composableBuilder(column: $table.sugar, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<double> get sodium =>
      $composableBuilder(column: $table.sodium, builder: (column) => column);

  GeneratedColumn<double> get cholesterol => $composableBuilder(
    column: $table.cholesterol,
    builder: (column) => column,
  );

  GeneratedColumn<double> get potassium =>
      $composableBuilder(column: $table.potassium, builder: (column) => column);

  GeneratedColumn<double> get calcium =>
      $composableBuilder(column: $table.calcium, builder: (column) => column);

  GeneratedColumn<double> get iron =>
      $composableBuilder(column: $table.iron, builder: (column) => column);

  GeneratedColumn<double> get vitaminA =>
      $composableBuilder(column: $table.vitaminA, builder: (column) => column);

  GeneratedColumn<double> get vitaminC =>
      $composableBuilder(column: $table.vitaminC, builder: (column) => column);

  GeneratedColumn<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPreset =>
      $composableBuilder(column: $table.isPreset, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$PantryFoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PantryFoodsTable,
          PantryFood,
          $$PantryFoodsTableFilterComposer,
          $$PantryFoodsTableOrderingComposer,
          $$PantryFoodsTableAnnotationComposer,
          $$PantryFoodsTableCreateCompanionBuilder,
          $$PantryFoodsTableUpdateCompanionBuilder,
          (
            PantryFood,
            BaseReferences<_$AppDatabase, $PantryFoodsTable, PantryFood>,
          ),
          PantryFood,
          PrefetchHooks Function()
        > {
  $$PantryFoodsTableTableManager(_$AppDatabase db, $PantryFoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PantryFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PantryFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$PantryFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<double> sugar = const Value.absent(),
                Value<double> fiber = const Value.absent(),
                Value<double> sodium = const Value.absent(),
                Value<double> cholesterol = const Value.absent(),
                Value<double> potassium = const Value.absent(),
                Value<double> calcium = const Value.absent(),
                Value<double> iron = const Value.absent(),
                Value<double> vitaminA = const Value.absent(),
                Value<double> vitaminC = const Value.absent(),
                Value<String> servingLabel = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PantryFoodsCompanion(
                id: id,
                userId: userId,
                name: name,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                sugar: sugar,
                fiber: fiber,
                sodium: sodium,
                cholesterol: cholesterol,
                potassium: potassium,
                calcium: calcium,
                iron: iron,
                vitaminA: vitaminA,
                vitaminC: vitaminC,
                servingLabel: servingLabel,
                isPreset: isPreset,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                required String name,
                Value<double> calories = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<double> sugar = const Value.absent(),
                Value<double> fiber = const Value.absent(),
                Value<double> sodium = const Value.absent(),
                Value<double> cholesterol = const Value.absent(),
                Value<double> potassium = const Value.absent(),
                Value<double> calcium = const Value.absent(),
                Value<double> iron = const Value.absent(),
                Value<double> vitaminA = const Value.absent(),
                Value<double> vitaminC = const Value.absent(),
                Value<String> servingLabel = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PantryFoodsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                sugar: sugar,
                fiber: fiber,
                sodium: sodium,
                cholesterol: cholesterol,
                potassium: potassium,
                calcium: calcium,
                iron: iron,
                vitaminA: vitaminA,
                vitaminC: vitaminC,
                servingLabel: servingLabel,
                isPreset: isPreset,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PantryFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PantryFoodsTable,
      PantryFood,
      $$PantryFoodsTableFilterComposer,
      $$PantryFoodsTableOrderingComposer,
      $$PantryFoodsTableAnnotationComposer,
      $$PantryFoodsTableCreateCompanionBuilder,
      $$PantryFoodsTableUpdateCompanionBuilder,
      (
        PantryFood,
        BaseReferences<_$AppDatabase, $PantryFoodsTable, PantryFood>,
      ),
      PantryFood,
      PrefetchHooks Function()
    >;
typedef $$MealTemplatesTableCreateCompanionBuilder =
    MealTemplatesCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$MealTemplatesTableUpdateCompanionBuilder =
    MealTemplatesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$MealTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $MealTemplatesTable> {
  $$MealTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MealTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $MealTemplatesTable> {
  $$MealTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealTemplatesTable> {
  $$MealTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$MealTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealTemplatesTable,
          MealTemplate,
          $$MealTemplatesTableFilterComposer,
          $$MealTemplatesTableOrderingComposer,
          $$MealTemplatesTableAnnotationComposer,
          $$MealTemplatesTableCreateCompanionBuilder,
          $$MealTemplatesTableUpdateCompanionBuilder,
          (
            MealTemplate,
            BaseReferences<_$AppDatabase, $MealTemplatesTable, MealTemplate>,
          ),
          MealTemplate,
          PrefetchHooks Function()
        > {
  $$MealTemplatesTableTableManager(_$AppDatabase db, $MealTemplatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MealTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$MealTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MealTemplatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealTemplatesCompanion(
                id: id,
                userId: userId,
                name: name,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealTemplatesCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MealTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealTemplatesTable,
      MealTemplate,
      $$MealTemplatesTableFilterComposer,
      $$MealTemplatesTableOrderingComposer,
      $$MealTemplatesTableAnnotationComposer,
      $$MealTemplatesTableCreateCompanionBuilder,
      $$MealTemplatesTableUpdateCompanionBuilder,
      (
        MealTemplate,
        BaseReferences<_$AppDatabase, $MealTemplatesTable, MealTemplate>,
      ),
      MealTemplate,
      PrefetchHooks Function()
    >;
typedef $$MealTemplateItemsTableCreateCompanionBuilder =
    MealTemplateItemsCompanion Function({
      required String id,
      required String templateId,
      required String userId,
      Value<String?> pantryFoodId,
      Value<double> servings,
      Value<bool> synced,
      Value<String?> name,
      Value<double?> calories,
      Value<double?> protein,
      Value<double?> carbs,
      Value<double?> fat,
      Value<double?> sugar,
      Value<double?> fiber,
      Value<double?> sodium,
      Value<double?> cholesterol,
      Value<double?> potassium,
      Value<double?> calcium,
      Value<double?> iron,
      Value<double?> vitaminA,
      Value<double?> vitaminC,
      Value<int> rowid,
    });
typedef $$MealTemplateItemsTableUpdateCompanionBuilder =
    MealTemplateItemsCompanion Function({
      Value<String> id,
      Value<String> templateId,
      Value<String> userId,
      Value<String?> pantryFoodId,
      Value<double> servings,
      Value<bool> synced,
      Value<String?> name,
      Value<double?> calories,
      Value<double?> protein,
      Value<double?> carbs,
      Value<double?> fat,
      Value<double?> sugar,
      Value<double?> fiber,
      Value<double?> sodium,
      Value<double?> cholesterol,
      Value<double?> potassium,
      Value<double?> calcium,
      Value<double?> iron,
      Value<double?> vitaminA,
      Value<double?> vitaminC,
      Value<int> rowid,
    });

class $$MealTemplateItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MealTemplateItemsTable> {
  $$MealTemplateItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pantryFoodId => $composableBuilder(
    column: $table.pantryFoodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cholesterol => $composableBuilder(
    column: $table.cholesterol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get potassium => $composableBuilder(
    column: $table.potassium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calcium => $composableBuilder(
    column: $table.calcium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get iron => $composableBuilder(
    column: $table.iron,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitaminA => $composableBuilder(
    column: $table.vitaminA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitaminC => $composableBuilder(
    column: $table.vitaminC,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MealTemplateItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealTemplateItemsTable> {
  $$MealTemplateItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pantryFoodId => $composableBuilder(
    column: $table.pantryFoodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cholesterol => $composableBuilder(
    column: $table.cholesterol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get potassium => $composableBuilder(
    column: $table.potassium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calcium => $composableBuilder(
    column: $table.calcium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get iron => $composableBuilder(
    column: $table.iron,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitaminA => $composableBuilder(
    column: $table.vitaminA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitaminC => $composableBuilder(
    column: $table.vitaminC,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealTemplateItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealTemplateItemsTable> {
  $$MealTemplateItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get pantryFoodId => $composableBuilder(
    column: $table.pantryFoodId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get sugar =>
      $composableBuilder(column: $table.sugar, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<double> get sodium =>
      $composableBuilder(column: $table.sodium, builder: (column) => column);

  GeneratedColumn<double> get cholesterol => $composableBuilder(
    column: $table.cholesterol,
    builder: (column) => column,
  );

  GeneratedColumn<double> get potassium =>
      $composableBuilder(column: $table.potassium, builder: (column) => column);

  GeneratedColumn<double> get calcium =>
      $composableBuilder(column: $table.calcium, builder: (column) => column);

  GeneratedColumn<double> get iron =>
      $composableBuilder(column: $table.iron, builder: (column) => column);

  GeneratedColumn<double> get vitaminA =>
      $composableBuilder(column: $table.vitaminA, builder: (column) => column);

  GeneratedColumn<double> get vitaminC =>
      $composableBuilder(column: $table.vitaminC, builder: (column) => column);
}

class $$MealTemplateItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealTemplateItemsTable,
          MealTemplateItem,
          $$MealTemplateItemsTableFilterComposer,
          $$MealTemplateItemsTableOrderingComposer,
          $$MealTemplateItemsTableAnnotationComposer,
          $$MealTemplateItemsTableCreateCompanionBuilder,
          $$MealTemplateItemsTableUpdateCompanionBuilder,
          (
            MealTemplateItem,
            BaseReferences<
              _$AppDatabase,
              $MealTemplateItemsTable,
              MealTemplateItem
            >,
          ),
          MealTemplateItem,
          PrefetchHooks Function()
        > {
  $$MealTemplateItemsTableTableManager(
    _$AppDatabase db,
    $MealTemplateItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MealTemplateItemsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$MealTemplateItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$MealTemplateItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> pantryFoodId = const Value.absent(),
                Value<double> servings = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<double?> calories = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> carbs = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> sugar = const Value.absent(),
                Value<double?> fiber = const Value.absent(),
                Value<double?> sodium = const Value.absent(),
                Value<double?> cholesterol = const Value.absent(),
                Value<double?> potassium = const Value.absent(),
                Value<double?> calcium = const Value.absent(),
                Value<double?> iron = const Value.absent(),
                Value<double?> vitaminA = const Value.absent(),
                Value<double?> vitaminC = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealTemplateItemsCompanion(
                id: id,
                templateId: templateId,
                userId: userId,
                pantryFoodId: pantryFoodId,
                servings: servings,
                synced: synced,
                name: name,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                sugar: sugar,
                fiber: fiber,
                sodium: sodium,
                cholesterol: cholesterol,
                potassium: potassium,
                calcium: calcium,
                iron: iron,
                vitaminA: vitaminA,
                vitaminC: vitaminC,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String templateId,
                required String userId,
                Value<String?> pantryFoodId = const Value.absent(),
                Value<double> servings = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<double?> calories = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> carbs = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> sugar = const Value.absent(),
                Value<double?> fiber = const Value.absent(),
                Value<double?> sodium = const Value.absent(),
                Value<double?> cholesterol = const Value.absent(),
                Value<double?> potassium = const Value.absent(),
                Value<double?> calcium = const Value.absent(),
                Value<double?> iron = const Value.absent(),
                Value<double?> vitaminA = const Value.absent(),
                Value<double?> vitaminC = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealTemplateItemsCompanion.insert(
                id: id,
                templateId: templateId,
                userId: userId,
                pantryFoodId: pantryFoodId,
                servings: servings,
                synced: synced,
                name: name,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                sugar: sugar,
                fiber: fiber,
                sodium: sodium,
                cholesterol: cholesterol,
                potassium: potassium,
                calcium: calcium,
                iron: iron,
                vitaminA: vitaminA,
                vitaminC: vitaminC,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MealTemplateItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealTemplateItemsTable,
      MealTemplateItem,
      $$MealTemplateItemsTableFilterComposer,
      $$MealTemplateItemsTableOrderingComposer,
      $$MealTemplateItemsTableAnnotationComposer,
      $$MealTemplateItemsTableCreateCompanionBuilder,
      $$MealTemplateItemsTableUpdateCompanionBuilder,
      (
        MealTemplateItem,
        BaseReferences<
          _$AppDatabase,
          $MealTemplateItemsTable,
          MealTemplateItem
        >,
      ),
      MealTemplateItem,
      PrefetchHooks Function()
    >;
typedef $$TrackedSubstancesTableCreateCompanionBuilder =
    TrackedSubstancesCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<String> unitLabel,
      Value<double?> dailyLimit,
      Value<double?> weeklyLimit,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$TrackedSubstancesTableUpdateCompanionBuilder =
    TrackedSubstancesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String> unitLabel,
      Value<double?> dailyLimit,
      Value<double?> weeklyLimit,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$TrackedSubstancesTableFilterComposer
    extends Composer<_$AppDatabase, $TrackedSubstancesTable> {
  $$TrackedSubstancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitLabel => $composableBuilder(
    column: $table.unitLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dailyLimit => $composableBuilder(
    column: $table.dailyLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weeklyLimit => $composableBuilder(
    column: $table.weeklyLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrackedSubstancesTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackedSubstancesTable> {
  $$TrackedSubstancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitLabel => $composableBuilder(
    column: $table.unitLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dailyLimit => $composableBuilder(
    column: $table.dailyLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weeklyLimit => $composableBuilder(
    column: $table.weeklyLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackedSubstancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackedSubstancesTable> {
  $$TrackedSubstancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unitLabel =>
      $composableBuilder(column: $table.unitLabel, builder: (column) => column);

  GeneratedColumn<double> get dailyLimit => $composableBuilder(
    column: $table.dailyLimit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weeklyLimit => $composableBuilder(
    column: $table.weeklyLimit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$TrackedSubstancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackedSubstancesTable,
          TrackedSubstance,
          $$TrackedSubstancesTableFilterComposer,
          $$TrackedSubstancesTableOrderingComposer,
          $$TrackedSubstancesTableAnnotationComposer,
          $$TrackedSubstancesTableCreateCompanionBuilder,
          $$TrackedSubstancesTableUpdateCompanionBuilder,
          (
            TrackedSubstance,
            BaseReferences<
              _$AppDatabase,
              $TrackedSubstancesTable,
              TrackedSubstance
            >,
          ),
          TrackedSubstance,
          PrefetchHooks Function()
        > {
  $$TrackedSubstancesTableTableManager(
    _$AppDatabase db,
    $TrackedSubstancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TrackedSubstancesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$TrackedSubstancesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$TrackedSubstancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> unitLabel = const Value.absent(),
                Value<double?> dailyLimit = const Value.absent(),
                Value<double?> weeklyLimit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackedSubstancesCompanion(
                id: id,
                userId: userId,
                name: name,
                unitLabel: unitLabel,
                dailyLimit: dailyLimit,
                weeklyLimit: weeklyLimit,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<String> unitLabel = const Value.absent(),
                Value<double?> dailyLimit = const Value.absent(),
                Value<double?> weeklyLimit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackedSubstancesCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                unitLabel: unitLabel,
                dailyLimit: dailyLimit,
                weeklyLimit: weeklyLimit,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrackedSubstancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackedSubstancesTable,
      TrackedSubstance,
      $$TrackedSubstancesTableFilterComposer,
      $$TrackedSubstancesTableOrderingComposer,
      $$TrackedSubstancesTableAnnotationComposer,
      $$TrackedSubstancesTableCreateCompanionBuilder,
      $$TrackedSubstancesTableUpdateCompanionBuilder,
      (
        TrackedSubstance,
        BaseReferences<
          _$AppDatabase,
          $TrackedSubstancesTable,
          TrackedSubstance
        >,
      ),
      TrackedSubstance,
      PrefetchHooks Function()
    >;
typedef $$SubstanceLogsTableCreateCompanionBuilder =
    SubstanceLogsCompanion Function({
      required String id,
      required String substanceId,
      required String userId,
      Value<double> amount,
      Value<DateTime> loggedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$SubstanceLogsTableUpdateCompanionBuilder =
    SubstanceLogsCompanion Function({
      Value<String> id,
      Value<String> substanceId,
      Value<String> userId,
      Value<double> amount,
      Value<DateTime> loggedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$SubstanceLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SubstanceLogsTable> {
  $$SubstanceLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get substanceId => $composableBuilder(
    column: $table.substanceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubstanceLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubstanceLogsTable> {
  $$SubstanceLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get substanceId => $composableBuilder(
    column: $table.substanceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubstanceLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubstanceLogsTable> {
  $$SubstanceLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get substanceId => $composableBuilder(
    column: $table.substanceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$SubstanceLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubstanceLogsTable,
          SubstanceLog,
          $$SubstanceLogsTableFilterComposer,
          $$SubstanceLogsTableOrderingComposer,
          $$SubstanceLogsTableAnnotationComposer,
          $$SubstanceLogsTableCreateCompanionBuilder,
          $$SubstanceLogsTableUpdateCompanionBuilder,
          (
            SubstanceLog,
            BaseReferences<_$AppDatabase, $SubstanceLogsTable, SubstanceLog>,
          ),
          SubstanceLog,
          PrefetchHooks Function()
        > {
  $$SubstanceLogsTableTableManager(_$AppDatabase db, $SubstanceLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SubstanceLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$SubstanceLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SubstanceLogsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> substanceId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubstanceLogsCompanion(
                id: id,
                substanceId: substanceId,
                userId: userId,
                amount: amount,
                loggedAt: loggedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String substanceId,
                required String userId,
                Value<double> amount = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubstanceLogsCompanion.insert(
                id: id,
                substanceId: substanceId,
                userId: userId,
                amount: amount,
                loggedAt: loggedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubstanceLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubstanceLogsTable,
      SubstanceLog,
      $$SubstanceLogsTableFilterComposer,
      $$SubstanceLogsTableOrderingComposer,
      $$SubstanceLogsTableAnnotationComposer,
      $$SubstanceLogsTableCreateCompanionBuilder,
      $$SubstanceLogsTableUpdateCompanionBuilder,
      (
        SubstanceLog,
        BaseReferences<_$AppDatabase, $SubstanceLogsTable, SubstanceLog>,
      ),
      SubstanceLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitCompletionsTableTableManager get habitCompletions =>
      $$HabitCompletionsTableTableManager(_db, _db.habitCompletions);
  $$HabitSkipsTableTableManager get habitSkips =>
      $$HabitSkipsTableTableManager(_db, _db.habitSkips);
  $$MealsTableTableManager get meals =>
      $$MealsTableTableManager(_db, _db.meals);
  $$FoodEntriesTableTableManager get foodEntries =>
      $$FoodEntriesTableTableManager(_db, _db.foodEntries);
  $$WaterLogsTableTableManager get waterLogs =>
      $$WaterLogsTableTableManager(_db, _db.waterLogs);
  $$DailyNutritionGoalsTableTableManager get dailyNutritionGoals =>
      $$DailyNutritionGoalsTableTableManager(_db, _db.dailyNutritionGoals);
  $$PantryFoodsTableTableManager get pantryFoods =>
      $$PantryFoodsTableTableManager(_db, _db.pantryFoods);
  $$MealTemplatesTableTableManager get mealTemplates =>
      $$MealTemplatesTableTableManager(_db, _db.mealTemplates);
  $$MealTemplateItemsTableTableManager get mealTemplateItems =>
      $$MealTemplateItemsTableTableManager(_db, _db.mealTemplateItems);
  $$TrackedSubstancesTableTableManager get trackedSubstances =>
      $$TrackedSubstancesTableTableManager(_db, _db.trackedSubstances);
  $$SubstanceLogsTableTableManager get substanceLogs =>
      $$SubstanceLogsTableTableManager(_db, _db.substanceLogs);
}
