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
          ..write('servingLabel: $servingLabel, ')
          ..write('isPreset: $isPreset, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSubstancesTable extends UserSubstances
    with TableInfo<$UserSubstancesTable, UserSubstance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSubstancesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('negative'),
  );
  static const VerificationMeta _defaultImpactMeta = const VerificationMeta(
    'defaultImpact',
  );
  @override
  late final GeneratedColumn<double> defaultImpact = GeneratedColumn<double>(
    'default_impact',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(5.0),
  );
  static const VerificationMeta _learnedImpactMeta = const VerificationMeta(
    'learnedImpact',
  );
  @override
  late final GeneratedColumn<double> learnedImpact = GeneratedColumn<double>(
    'learned_impact',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurrenceCountMeta = const VerificationMeta(
    'occurrenceCount',
  );
  @override
  late final GeneratedColumn<int> occurrenceCount = GeneratedColumn<int>(
    'occurrence_count',
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
    direction,
    defaultImpact,
    learnedImpact,
    occurrenceCount,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_substances';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSubstance> instance, {
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
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    }
    if (data.containsKey('default_impact')) {
      context.handle(
        _defaultImpactMeta,
        defaultImpact.isAcceptableOrUnknown(
          data['default_impact']!,
          _defaultImpactMeta,
        ),
      );
    }
    if (data.containsKey('learned_impact')) {
      context.handle(
        _learnedImpactMeta,
        learnedImpact.isAcceptableOrUnknown(
          data['learned_impact']!,
          _learnedImpactMeta,
        ),
      );
    }
    if (data.containsKey('occurrence_count')) {
      context.handle(
        _occurrenceCountMeta,
        occurrenceCount.isAcceptableOrUnknown(
          data['occurrence_count']!,
          _occurrenceCountMeta,
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
  UserSubstance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSubstance(
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
      direction:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}direction'],
          )!,
      defaultImpact:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}default_impact'],
          )!,
      learnedImpact: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}learned_impact'],
      ),
      occurrenceCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}occurrence_count'],
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
  $UserSubstancesTable createAlias(String alias) {
    return $UserSubstancesTable(attachedDatabase, alias);
  }
}

class UserSubstance extends DataClass implements Insertable<UserSubstance> {
  final String id;
  final String userId;
  final String name;
  final String direction;
  final double defaultImpact;
  final double? learnedImpact;
  final int occurrenceCount;
  final DateTime createdAt;
  final bool synced;
  const UserSubstance({
    required this.id,
    required this.userId,
    required this.name,
    required this.direction,
    required this.defaultImpact,
    this.learnedImpact,
    required this.occurrenceCount,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['direction'] = Variable<String>(direction);
    map['default_impact'] = Variable<double>(defaultImpact);
    if (!nullToAbsent || learnedImpact != null) {
      map['learned_impact'] = Variable<double>(learnedImpact);
    }
    map['occurrence_count'] = Variable<int>(occurrenceCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  UserSubstancesCompanion toCompanion(bool nullToAbsent) {
    return UserSubstancesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      direction: Value(direction),
      defaultImpact: Value(defaultImpact),
      learnedImpact:
          learnedImpact == null && nullToAbsent
              ? const Value.absent()
              : Value(learnedImpact),
      occurrenceCount: Value(occurrenceCount),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory UserSubstance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSubstance(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      direction: serializer.fromJson<String>(json['direction']),
      defaultImpact: serializer.fromJson<double>(json['defaultImpact']),
      learnedImpact: serializer.fromJson<double?>(json['learnedImpact']),
      occurrenceCount: serializer.fromJson<int>(json['occurrenceCount']),
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
      'direction': serializer.toJson<String>(direction),
      'defaultImpact': serializer.toJson<double>(defaultImpact),
      'learnedImpact': serializer.toJson<double?>(learnedImpact),
      'occurrenceCount': serializer.toJson<int>(occurrenceCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  UserSubstance copyWith({
    String? id,
    String? userId,
    String? name,
    String? direction,
    double? defaultImpact,
    Value<double?> learnedImpact = const Value.absent(),
    int? occurrenceCount,
    DateTime? createdAt,
    bool? synced,
  }) => UserSubstance(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    direction: direction ?? this.direction,
    defaultImpact: defaultImpact ?? this.defaultImpact,
    learnedImpact:
        learnedImpact.present ? learnedImpact.value : this.learnedImpact,
    occurrenceCount: occurrenceCount ?? this.occurrenceCount,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  UserSubstance copyWithCompanion(UserSubstancesCompanion data) {
    return UserSubstance(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      direction: data.direction.present ? data.direction.value : this.direction,
      defaultImpact:
          data.defaultImpact.present
              ? data.defaultImpact.value
              : this.defaultImpact,
      learnedImpact:
          data.learnedImpact.present
              ? data.learnedImpact.value
              : this.learnedImpact,
      occurrenceCount:
          data.occurrenceCount.present
              ? data.occurrenceCount.value
              : this.occurrenceCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSubstance(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('direction: $direction, ')
          ..write('defaultImpact: $defaultImpact, ')
          ..write('learnedImpact: $learnedImpact, ')
          ..write('occurrenceCount: $occurrenceCount, ')
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
    direction,
    defaultImpact,
    learnedImpact,
    occurrenceCount,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSubstance &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.direction == this.direction &&
          other.defaultImpact == this.defaultImpact &&
          other.learnedImpact == this.learnedImpact &&
          other.occurrenceCount == this.occurrenceCount &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class UserSubstancesCompanion extends UpdateCompanion<UserSubstance> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> direction;
  final Value<double> defaultImpact;
  final Value<double?> learnedImpact;
  final Value<int> occurrenceCount;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const UserSubstancesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.direction = const Value.absent(),
    this.defaultImpact = const Value.absent(),
    this.learnedImpact = const Value.absent(),
    this.occurrenceCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSubstancesCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.direction = const Value.absent(),
    this.defaultImpact = const Value.absent(),
    this.learnedImpact = const Value.absent(),
    this.occurrenceCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name);
  static Insertable<UserSubstance> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? direction,
    Expression<double>? defaultImpact,
    Expression<double>? learnedImpact,
    Expression<int>? occurrenceCount,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (direction != null) 'direction': direction,
      if (defaultImpact != null) 'default_impact': defaultImpact,
      if (learnedImpact != null) 'learned_impact': learnedImpact,
      if (occurrenceCount != null) 'occurrence_count': occurrenceCount,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSubstancesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? direction,
    Value<double>? defaultImpact,
    Value<double?>? learnedImpact,
    Value<int>? occurrenceCount,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return UserSubstancesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      direction: direction ?? this.direction,
      defaultImpact: defaultImpact ?? this.defaultImpact,
      learnedImpact: learnedImpact ?? this.learnedImpact,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
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
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (defaultImpact.present) {
      map['default_impact'] = Variable<double>(defaultImpact.value);
    }
    if (learnedImpact.present) {
      map['learned_impact'] = Variable<double>(learnedImpact.value);
    }
    if (occurrenceCount.present) {
      map['occurrence_count'] = Variable<int>(occurrenceCount.value);
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
    return (StringBuffer('UserSubstancesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('direction: $direction, ')
          ..write('defaultImpact: $defaultImpact, ')
          ..write('learnedImpact: $learnedImpact, ')
          ..write('occurrenceCount: $occurrenceCount, ')
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _substanceNameMeta = const VerificationMeta(
    'substanceName',
  );
  @override
  late final GeneratedColumn<String> substanceName = GeneratedColumn<String>(
    'substance_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _impactSnapshotMeta = const VerificationMeta(
    'impactSnapshot',
  );
  @override
  late final GeneratedColumn<double> impactSnapshot = GeneratedColumn<double>(
    'impact_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    id,
    userId,
    date,
    substanceName,
    direction,
    impactSnapshot,
    quantity,
    notes,
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
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('substance_name')) {
      context.handle(
        _substanceNameMeta,
        substanceName.isAcceptableOrUnknown(
          data['substance_name']!,
          _substanceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_substanceNameMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('impact_snapshot')) {
      context.handle(
        _impactSnapshotMeta,
        impactSnapshot.isAcceptableOrUnknown(
          data['impact_snapshot']!,
          _impactSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_impactSnapshotMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      substanceName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}substance_name'],
          )!,
      direction:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}direction'],
          )!,
      impactSnapshot:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}impact_snapshot'],
          )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
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
  final String userId;
  final DateTime date;
  final String substanceName;
  final String direction;
  final double impactSnapshot;
  final String? quantity;
  final String? notes;
  final bool synced;
  const SubstanceLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.substanceName,
    required this.direction,
    required this.impactSnapshot,
    this.quantity,
    this.notes,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    map['substance_name'] = Variable<String>(substanceName);
    map['direction'] = Variable<String>(direction);
    map['impact_snapshot'] = Variable<double>(impactSnapshot);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<String>(quantity);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  SubstanceLogsCompanion toCompanion(bool nullToAbsent) {
    return SubstanceLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      substanceName: Value(substanceName),
      direction: Value(direction),
      impactSnapshot: Value(impactSnapshot),
      quantity:
          quantity == null && nullToAbsent
              ? const Value.absent()
              : Value(quantity),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
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
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      substanceName: serializer.fromJson<String>(json['substanceName']),
      direction: serializer.fromJson<String>(json['direction']),
      impactSnapshot: serializer.fromJson<double>(json['impactSnapshot']),
      quantity: serializer.fromJson<String?>(json['quantity']),
      notes: serializer.fromJson<String?>(json['notes']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'substanceName': serializer.toJson<String>(substanceName),
      'direction': serializer.toJson<String>(direction),
      'impactSnapshot': serializer.toJson<double>(impactSnapshot),
      'quantity': serializer.toJson<String?>(quantity),
      'notes': serializer.toJson<String?>(notes),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  SubstanceLog copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? substanceName,
    String? direction,
    double? impactSnapshot,
    Value<String?> quantity = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? synced,
  }) => SubstanceLog(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    substanceName: substanceName ?? this.substanceName,
    direction: direction ?? this.direction,
    impactSnapshot: impactSnapshot ?? this.impactSnapshot,
    quantity: quantity.present ? quantity.value : this.quantity,
    notes: notes.present ? notes.value : this.notes,
    synced: synced ?? this.synced,
  );
  SubstanceLog copyWithCompanion(SubstanceLogsCompanion data) {
    return SubstanceLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      substanceName:
          data.substanceName.present
              ? data.substanceName.value
              : this.substanceName,
      direction: data.direction.present ? data.direction.value : this.direction,
      impactSnapshot:
          data.impactSnapshot.present
              ? data.impactSnapshot.value
              : this.impactSnapshot,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      notes: data.notes.present ? data.notes.value : this.notes,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubstanceLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('substanceName: $substanceName, ')
          ..write('direction: $direction, ')
          ..write('impactSnapshot: $impactSnapshot, ')
          ..write('quantity: $quantity, ')
          ..write('notes: $notes, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    date,
    substanceName,
    direction,
    impactSnapshot,
    quantity,
    notes,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubstanceLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.substanceName == this.substanceName &&
          other.direction == this.direction &&
          other.impactSnapshot == this.impactSnapshot &&
          other.quantity == this.quantity &&
          other.notes == this.notes &&
          other.synced == this.synced);
}

class SubstanceLogsCompanion extends UpdateCompanion<SubstanceLog> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<String> substanceName;
  final Value<String> direction;
  final Value<double> impactSnapshot;
  final Value<String?> quantity;
  final Value<String?> notes;
  final Value<bool> synced;
  final Value<int> rowid;
  const SubstanceLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.substanceName = const Value.absent(),
    this.direction = const Value.absent(),
    this.impactSnapshot = const Value.absent(),
    this.quantity = const Value.absent(),
    this.notes = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubstanceLogsCompanion.insert({
    required String id,
    required String userId,
    required DateTime date,
    required String substanceName,
    required String direction,
    required double impactSnapshot,
    this.quantity = const Value.absent(),
    this.notes = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       date = Value(date),
       substanceName = Value(substanceName),
       direction = Value(direction),
       impactSnapshot = Value(impactSnapshot);
  static Insertable<SubstanceLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<String>? substanceName,
    Expression<String>? direction,
    Expression<double>? impactSnapshot,
    Expression<String>? quantity,
    Expression<String>? notes,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (substanceName != null) 'substance_name': substanceName,
      if (direction != null) 'direction': direction,
      if (impactSnapshot != null) 'impact_snapshot': impactSnapshot,
      if (quantity != null) 'quantity': quantity,
      if (notes != null) 'notes': notes,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubstanceLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? date,
    Value<String>? substanceName,
    Value<String>? direction,
    Value<double>? impactSnapshot,
    Value<String?>? quantity,
    Value<String?>? notes,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return SubstanceLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      substanceName: substanceName ?? this.substanceName,
      direction: direction ?? this.direction,
      impactSnapshot: impactSnapshot ?? this.impactSnapshot,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
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
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (substanceName.present) {
      map['substance_name'] = Variable<String>(substanceName.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (impactSnapshot.present) {
      map['impact_snapshot'] = Variable<double>(impactSnapshot.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('substanceName: $substanceName, ')
          ..write('direction: $direction, ')
          ..write('impactSnapshot: $impactSnapshot, ')
          ..write('quantity: $quantity, ')
          ..write('notes: $notes, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadinessCheckInsTable extends ReadinessCheckIns
    with TableInfo<$ReadinessCheckInsTable, ReadinessCheckIn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadinessCheckInsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkInWindowMeta = const VerificationMeta(
    'checkInWindow',
  );
  @override
  late final GeneratedColumn<String> checkInWindow = GeneratedColumn<String>(
    'check_in_window',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sleepHoursMeta = const VerificationMeta(
    'sleepHours',
  );
  @override
  late final GeneratedColumn<double> sleepHours = GeneratedColumn<double>(
    'sleep_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepQualityMeta = const VerificationMeta(
    'sleepQuality',
  );
  @override
  late final GeneratedColumn<int> sleepQuality = GeneratedColumn<int>(
    'sleep_quality',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stressLevelMeta = const VerificationMeta(
    'stressLevel',
  );
  @override
  late final GeneratedColumn<int> stressLevel = GeneratedColumn<int>(
    'stress_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energyLevelMeta = const VerificationMeta(
    'energyLevel',
  );
  @override
  late final GeneratedColumn<int> energyLevel = GeneratedColumn<int>(
    'energy_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caffeineCountMeta = const VerificationMeta(
    'caffeineCount',
  );
  @override
  late final GeneratedColumn<int> caffeineCount = GeneratedColumn<int>(
    'caffeine_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _focusLevelMeta = const VerificationMeta(
    'focusLevel',
  );
  @override
  late final GeneratedColumn<int> focusLevel = GeneratedColumn<int>(
    'focus_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    id,
    userId,
    date,
    checkInWindow,
    sleepHours,
    sleepQuality,
    stressLevel,
    energyLevel,
    mood,
    caffeineCount,
    focusLevel,
    notes,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'readiness_check_ins';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadinessCheckIn> instance, {
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
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('check_in_window')) {
      context.handle(
        _checkInWindowMeta,
        checkInWindow.isAcceptableOrUnknown(
          data['check_in_window']!,
          _checkInWindowMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkInWindowMeta);
    }
    if (data.containsKey('sleep_hours')) {
      context.handle(
        _sleepHoursMeta,
        sleepHours.isAcceptableOrUnknown(data['sleep_hours']!, _sleepHoursMeta),
      );
    }
    if (data.containsKey('sleep_quality')) {
      context.handle(
        _sleepQualityMeta,
        sleepQuality.isAcceptableOrUnknown(
          data['sleep_quality']!,
          _sleepQualityMeta,
        ),
      );
    }
    if (data.containsKey('stress_level')) {
      context.handle(
        _stressLevelMeta,
        stressLevel.isAcceptableOrUnknown(
          data['stress_level']!,
          _stressLevelMeta,
        ),
      );
    }
    if (data.containsKey('energy_level')) {
      context.handle(
        _energyLevelMeta,
        energyLevel.isAcceptableOrUnknown(
          data['energy_level']!,
          _energyLevelMeta,
        ),
      );
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('caffeine_count')) {
      context.handle(
        _caffeineCountMeta,
        caffeineCount.isAcceptableOrUnknown(
          data['caffeine_count']!,
          _caffeineCountMeta,
        ),
      );
    }
    if (data.containsKey('focus_level')) {
      context.handle(
        _focusLevelMeta,
        focusLevel.isAcceptableOrUnknown(data['focus_level']!, _focusLevelMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
  ReadinessCheckIn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadinessCheckIn(
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
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      checkInWindow:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}check_in_window'],
          )!,
      sleepHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sleep_hours'],
      ),
      sleepQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_quality'],
      ),
      stressLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stress_level'],
      ),
      energyLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy_level'],
      ),
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      ),
      caffeineCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}caffeine_count'],
      ),
      focusLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focus_level'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $ReadinessCheckInsTable createAlias(String alias) {
    return $ReadinessCheckInsTable(attachedDatabase, alias);
  }
}

class ReadinessCheckIn extends DataClass
    implements Insertable<ReadinessCheckIn> {
  final String id;
  final String userId;
  final DateTime date;
  final String checkInWindow;
  final double? sleepHours;
  final int? sleepQuality;
  final int? stressLevel;
  final int? energyLevel;
  final int? mood;
  final int? caffeineCount;
  final int? focusLevel;
  final String? notes;
  final bool synced;
  const ReadinessCheckIn({
    required this.id,
    required this.userId,
    required this.date,
    required this.checkInWindow,
    this.sleepHours,
    this.sleepQuality,
    this.stressLevel,
    this.energyLevel,
    this.mood,
    this.caffeineCount,
    this.focusLevel,
    this.notes,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    map['check_in_window'] = Variable<String>(checkInWindow);
    if (!nullToAbsent || sleepHours != null) {
      map['sleep_hours'] = Variable<double>(sleepHours);
    }
    if (!nullToAbsent || sleepQuality != null) {
      map['sleep_quality'] = Variable<int>(sleepQuality);
    }
    if (!nullToAbsent || stressLevel != null) {
      map['stress_level'] = Variable<int>(stressLevel);
    }
    if (!nullToAbsent || energyLevel != null) {
      map['energy_level'] = Variable<int>(energyLevel);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<int>(mood);
    }
    if (!nullToAbsent || caffeineCount != null) {
      map['caffeine_count'] = Variable<int>(caffeineCount);
    }
    if (!nullToAbsent || focusLevel != null) {
      map['focus_level'] = Variable<int>(focusLevel);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ReadinessCheckInsCompanion toCompanion(bool nullToAbsent) {
    return ReadinessCheckInsCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      checkInWindow: Value(checkInWindow),
      sleepHours:
          sleepHours == null && nullToAbsent
              ? const Value.absent()
              : Value(sleepHours),
      sleepQuality:
          sleepQuality == null && nullToAbsent
              ? const Value.absent()
              : Value(sleepQuality),
      stressLevel:
          stressLevel == null && nullToAbsent
              ? const Value.absent()
              : Value(stressLevel),
      energyLevel:
          energyLevel == null && nullToAbsent
              ? const Value.absent()
              : Value(energyLevel),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      caffeineCount:
          caffeineCount == null && nullToAbsent
              ? const Value.absent()
              : Value(caffeineCount),
      focusLevel:
          focusLevel == null && nullToAbsent
              ? const Value.absent()
              : Value(focusLevel),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      synced: Value(synced),
    );
  }

  factory ReadinessCheckIn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadinessCheckIn(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      checkInWindow: serializer.fromJson<String>(json['checkInWindow']),
      sleepHours: serializer.fromJson<double?>(json['sleepHours']),
      sleepQuality: serializer.fromJson<int?>(json['sleepQuality']),
      stressLevel: serializer.fromJson<int?>(json['stressLevel']),
      energyLevel: serializer.fromJson<int?>(json['energyLevel']),
      mood: serializer.fromJson<int?>(json['mood']),
      caffeineCount: serializer.fromJson<int?>(json['caffeineCount']),
      focusLevel: serializer.fromJson<int?>(json['focusLevel']),
      notes: serializer.fromJson<String?>(json['notes']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'checkInWindow': serializer.toJson<String>(checkInWindow),
      'sleepHours': serializer.toJson<double?>(sleepHours),
      'sleepQuality': serializer.toJson<int?>(sleepQuality),
      'stressLevel': serializer.toJson<int?>(stressLevel),
      'energyLevel': serializer.toJson<int?>(energyLevel),
      'mood': serializer.toJson<int?>(mood),
      'caffeineCount': serializer.toJson<int?>(caffeineCount),
      'focusLevel': serializer.toJson<int?>(focusLevel),
      'notes': serializer.toJson<String?>(notes),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  ReadinessCheckIn copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? checkInWindow,
    Value<double?> sleepHours = const Value.absent(),
    Value<int?> sleepQuality = const Value.absent(),
    Value<int?> stressLevel = const Value.absent(),
    Value<int?> energyLevel = const Value.absent(),
    Value<int?> mood = const Value.absent(),
    Value<int?> caffeineCount = const Value.absent(),
    Value<int?> focusLevel = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? synced,
  }) => ReadinessCheckIn(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    checkInWindow: checkInWindow ?? this.checkInWindow,
    sleepHours: sleepHours.present ? sleepHours.value : this.sleepHours,
    sleepQuality: sleepQuality.present ? sleepQuality.value : this.sleepQuality,
    stressLevel: stressLevel.present ? stressLevel.value : this.stressLevel,
    energyLevel: energyLevel.present ? energyLevel.value : this.energyLevel,
    mood: mood.present ? mood.value : this.mood,
    caffeineCount:
        caffeineCount.present ? caffeineCount.value : this.caffeineCount,
    focusLevel: focusLevel.present ? focusLevel.value : this.focusLevel,
    notes: notes.present ? notes.value : this.notes,
    synced: synced ?? this.synced,
  );
  ReadinessCheckIn copyWithCompanion(ReadinessCheckInsCompanion data) {
    return ReadinessCheckIn(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      checkInWindow:
          data.checkInWindow.present
              ? data.checkInWindow.value
              : this.checkInWindow,
      sleepHours:
          data.sleepHours.present ? data.sleepHours.value : this.sleepHours,
      sleepQuality:
          data.sleepQuality.present
              ? data.sleepQuality.value
              : this.sleepQuality,
      stressLevel:
          data.stressLevel.present ? data.stressLevel.value : this.stressLevel,
      energyLevel:
          data.energyLevel.present ? data.energyLevel.value : this.energyLevel,
      mood: data.mood.present ? data.mood.value : this.mood,
      caffeineCount:
          data.caffeineCount.present
              ? data.caffeineCount.value
              : this.caffeineCount,
      focusLevel:
          data.focusLevel.present ? data.focusLevel.value : this.focusLevel,
      notes: data.notes.present ? data.notes.value : this.notes,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadinessCheckIn(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('checkInWindow: $checkInWindow, ')
          ..write('sleepHours: $sleepHours, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('stressLevel: $stressLevel, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('mood: $mood, ')
          ..write('caffeineCount: $caffeineCount, ')
          ..write('focusLevel: $focusLevel, ')
          ..write('notes: $notes, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    date,
    checkInWindow,
    sleepHours,
    sleepQuality,
    stressLevel,
    energyLevel,
    mood,
    caffeineCount,
    focusLevel,
    notes,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadinessCheckIn &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.checkInWindow == this.checkInWindow &&
          other.sleepHours == this.sleepHours &&
          other.sleepQuality == this.sleepQuality &&
          other.stressLevel == this.stressLevel &&
          other.energyLevel == this.energyLevel &&
          other.mood == this.mood &&
          other.caffeineCount == this.caffeineCount &&
          other.focusLevel == this.focusLevel &&
          other.notes == this.notes &&
          other.synced == this.synced);
}

class ReadinessCheckInsCompanion extends UpdateCompanion<ReadinessCheckIn> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<String> checkInWindow;
  final Value<double?> sleepHours;
  final Value<int?> sleepQuality;
  final Value<int?> stressLevel;
  final Value<int?> energyLevel;
  final Value<int?> mood;
  final Value<int?> caffeineCount;
  final Value<int?> focusLevel;
  final Value<String?> notes;
  final Value<bool> synced;
  final Value<int> rowid;
  const ReadinessCheckInsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.checkInWindow = const Value.absent(),
    this.sleepHours = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.stressLevel = const Value.absent(),
    this.energyLevel = const Value.absent(),
    this.mood = const Value.absent(),
    this.caffeineCount = const Value.absent(),
    this.focusLevel = const Value.absent(),
    this.notes = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadinessCheckInsCompanion.insert({
    required String id,
    required String userId,
    required DateTime date,
    required String checkInWindow,
    this.sleepHours = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.stressLevel = const Value.absent(),
    this.energyLevel = const Value.absent(),
    this.mood = const Value.absent(),
    this.caffeineCount = const Value.absent(),
    this.focusLevel = const Value.absent(),
    this.notes = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       date = Value(date),
       checkInWindow = Value(checkInWindow);
  static Insertable<ReadinessCheckIn> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<String>? checkInWindow,
    Expression<double>? sleepHours,
    Expression<int>? sleepQuality,
    Expression<int>? stressLevel,
    Expression<int>? energyLevel,
    Expression<int>? mood,
    Expression<int>? caffeineCount,
    Expression<int>? focusLevel,
    Expression<String>? notes,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (checkInWindow != null) 'check_in_window': checkInWindow,
      if (sleepHours != null) 'sleep_hours': sleepHours,
      if (sleepQuality != null) 'sleep_quality': sleepQuality,
      if (stressLevel != null) 'stress_level': stressLevel,
      if (energyLevel != null) 'energy_level': energyLevel,
      if (mood != null) 'mood': mood,
      if (caffeineCount != null) 'caffeine_count': caffeineCount,
      if (focusLevel != null) 'focus_level': focusLevel,
      if (notes != null) 'notes': notes,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadinessCheckInsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? date,
    Value<String>? checkInWindow,
    Value<double?>? sleepHours,
    Value<int?>? sleepQuality,
    Value<int?>? stressLevel,
    Value<int?>? energyLevel,
    Value<int?>? mood,
    Value<int?>? caffeineCount,
    Value<int?>? focusLevel,
    Value<String?>? notes,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return ReadinessCheckInsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      checkInWindow: checkInWindow ?? this.checkInWindow,
      sleepHours: sleepHours ?? this.sleepHours,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      stressLevel: stressLevel ?? this.stressLevel,
      energyLevel: energyLevel ?? this.energyLevel,
      mood: mood ?? this.mood,
      caffeineCount: caffeineCount ?? this.caffeineCount,
      focusLevel: focusLevel ?? this.focusLevel,
      notes: notes ?? this.notes,
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
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (checkInWindow.present) {
      map['check_in_window'] = Variable<String>(checkInWindow.value);
    }
    if (sleepHours.present) {
      map['sleep_hours'] = Variable<double>(sleepHours.value);
    }
    if (sleepQuality.present) {
      map['sleep_quality'] = Variable<int>(sleepQuality.value);
    }
    if (stressLevel.present) {
      map['stress_level'] = Variable<int>(stressLevel.value);
    }
    if (energyLevel.present) {
      map['energy_level'] = Variable<int>(energyLevel.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (caffeineCount.present) {
      map['caffeine_count'] = Variable<int>(caffeineCount.value);
    }
    if (focusLevel.present) {
      map['focus_level'] = Variable<int>(focusLevel.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('ReadinessCheckInsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('checkInWindow: $checkInWindow, ')
          ..write('sleepHours: $sleepHours, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('stressLevel: $stressLevel, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('mood: $mood, ')
          ..write('caffeineCount: $caffeineCount, ')
          ..write('focusLevel: $focusLevel, ')
          ..write('notes: $notes, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyReadinessTable extends DailyReadiness
    with TableInfo<$DailyReadinessTable, DailyReadinessData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyReadinessTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _computedScoreMeta = const VerificationMeta(
    'computedScore',
  );
  @override
  late final GeneratedColumn<double> computedScore = GeneratedColumn<double>(
    'computed_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(70.0),
  );
  static const VerificationMeta _userRatedScoreMeta = const VerificationMeta(
    'userRatedScore',
  );
  @override
  late final GeneratedColumn<double> userRatedScore = GeneratedColumn<double>(
    'user_rated_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _previousDayInfluenceMeta =
      const VerificationMeta('previousDayInfluence');
  @override
  late final GeneratedColumn<double> previousDayInfluence =
      GeneratedColumn<double>(
        'previous_day_influence',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
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
    date,
    computedScore,
    userRatedScore,
    previousDayInfluence,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_readiness';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyReadinessData> instance, {
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
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('computed_score')) {
      context.handle(
        _computedScoreMeta,
        computedScore.isAcceptableOrUnknown(
          data['computed_score']!,
          _computedScoreMeta,
        ),
      );
    }
    if (data.containsKey('user_rated_score')) {
      context.handle(
        _userRatedScoreMeta,
        userRatedScore.isAcceptableOrUnknown(
          data['user_rated_score']!,
          _userRatedScoreMeta,
        ),
      );
    }
    if (data.containsKey('previous_day_influence')) {
      context.handle(
        _previousDayInfluenceMeta,
        previousDayInfluence.isAcceptableOrUnknown(
          data['previous_day_influence']!,
          _previousDayInfluenceMeta,
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyReadinessData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyReadinessData(
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
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      computedScore:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}computed_score'],
          )!,
      userRatedScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}user_rated_score'],
      ),
      previousDayInfluence:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}previous_day_influence'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $DailyReadinessTable createAlias(String alias) {
    return $DailyReadinessTable(attachedDatabase, alias);
  }
}

class DailyReadinessData extends DataClass
    implements Insertable<DailyReadinessData> {
  final String id;
  final String userId;
  final DateTime date;
  final double computedScore;
  final double? userRatedScore;
  final double previousDayInfluence;
  final bool synced;
  const DailyReadinessData({
    required this.id,
    required this.userId,
    required this.date,
    required this.computedScore,
    this.userRatedScore,
    required this.previousDayInfluence,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    map['computed_score'] = Variable<double>(computedScore);
    if (!nullToAbsent || userRatedScore != null) {
      map['user_rated_score'] = Variable<double>(userRatedScore);
    }
    map['previous_day_influence'] = Variable<double>(previousDayInfluence);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  DailyReadinessCompanion toCompanion(bool nullToAbsent) {
    return DailyReadinessCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      computedScore: Value(computedScore),
      userRatedScore:
          userRatedScore == null && nullToAbsent
              ? const Value.absent()
              : Value(userRatedScore),
      previousDayInfluence: Value(previousDayInfluence),
      synced: Value(synced),
    );
  }

  factory DailyReadinessData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyReadinessData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      computedScore: serializer.fromJson<double>(json['computedScore']),
      userRatedScore: serializer.fromJson<double?>(json['userRatedScore']),
      previousDayInfluence: serializer.fromJson<double>(
        json['previousDayInfluence'],
      ),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'computedScore': serializer.toJson<double>(computedScore),
      'userRatedScore': serializer.toJson<double?>(userRatedScore),
      'previousDayInfluence': serializer.toJson<double>(previousDayInfluence),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  DailyReadinessData copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? computedScore,
    Value<double?> userRatedScore = const Value.absent(),
    double? previousDayInfluence,
    bool? synced,
  }) => DailyReadinessData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    computedScore: computedScore ?? this.computedScore,
    userRatedScore:
        userRatedScore.present ? userRatedScore.value : this.userRatedScore,
    previousDayInfluence: previousDayInfluence ?? this.previousDayInfluence,
    synced: synced ?? this.synced,
  );
  DailyReadinessData copyWithCompanion(DailyReadinessCompanion data) {
    return DailyReadinessData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      computedScore:
          data.computedScore.present
              ? data.computedScore.value
              : this.computedScore,
      userRatedScore:
          data.userRatedScore.present
              ? data.userRatedScore.value
              : this.userRatedScore,
      previousDayInfluence:
          data.previousDayInfluence.present
              ? data.previousDayInfluence.value
              : this.previousDayInfluence,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyReadinessData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('computedScore: $computedScore, ')
          ..write('userRatedScore: $userRatedScore, ')
          ..write('previousDayInfluence: $previousDayInfluence, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    date,
    computedScore,
    userRatedScore,
    previousDayInfluence,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyReadinessData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.computedScore == this.computedScore &&
          other.userRatedScore == this.userRatedScore &&
          other.previousDayInfluence == this.previousDayInfluence &&
          other.synced == this.synced);
}

class DailyReadinessCompanion extends UpdateCompanion<DailyReadinessData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<double> computedScore;
  final Value<double?> userRatedScore;
  final Value<double> previousDayInfluence;
  final Value<bool> synced;
  final Value<int> rowid;
  const DailyReadinessCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.computedScore = const Value.absent(),
    this.userRatedScore = const Value.absent(),
    this.previousDayInfluence = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyReadinessCompanion.insert({
    required String id,
    required String userId,
    required DateTime date,
    this.computedScore = const Value.absent(),
    this.userRatedScore = const Value.absent(),
    this.previousDayInfluence = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       date = Value(date);
  static Insertable<DailyReadinessData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<double>? computedScore,
    Expression<double>? userRatedScore,
    Expression<double>? previousDayInfluence,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (computedScore != null) 'computed_score': computedScore,
      if (userRatedScore != null) 'user_rated_score': userRatedScore,
      if (previousDayInfluence != null)
        'previous_day_influence': previousDayInfluence,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyReadinessCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? date,
    Value<double>? computedScore,
    Value<double?>? userRatedScore,
    Value<double>? previousDayInfluence,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return DailyReadinessCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      computedScore: computedScore ?? this.computedScore,
      userRatedScore: userRatedScore ?? this.userRatedScore,
      previousDayInfluence: previousDayInfluence ?? this.previousDayInfluence,
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
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (computedScore.present) {
      map['computed_score'] = Variable<double>(computedScore.value);
    }
    if (userRatedScore.present) {
      map['user_rated_score'] = Variable<double>(userRatedScore.value);
    }
    if (previousDayInfluence.present) {
      map['previous_day_influence'] = Variable<double>(
        previousDayInfluence.value,
      );
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
    return (StringBuffer('DailyReadinessCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('computedScore: $computedScore, ')
          ..write('userRatedScore: $userRatedScore, ')
          ..write('previousDayInfluence: $previousDayInfluence, ')
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
  late final $UserSubstancesTable userSubstances = $UserSubstancesTable(this);
  late final $SubstanceLogsTable substanceLogs = $SubstanceLogsTable(this);
  late final $ReadinessCheckInsTable readinessCheckIns =
      $ReadinessCheckInsTable(this);
  late final $DailyReadinessTable dailyReadiness = $DailyReadinessTable(this);
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
    userSubstances,
    substanceLogs,
    readinessCheckIns,
    dailyReadiness,
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
typedef $$UserSubstancesTableCreateCompanionBuilder =
    UserSubstancesCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<String> direction,
      Value<double> defaultImpact,
      Value<double?> learnedImpact,
      Value<int> occurrenceCount,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$UserSubstancesTableUpdateCompanionBuilder =
    UserSubstancesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String> direction,
      Value<double> defaultImpact,
      Value<double?> learnedImpact,
      Value<int> occurrenceCount,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$UserSubstancesTableFilterComposer
    extends Composer<_$AppDatabase, $UserSubstancesTable> {
  $$UserSubstancesTableFilterComposer({
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

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultImpact => $composableBuilder(
    column: $table.defaultImpact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get learnedImpact => $composableBuilder(
    column: $table.learnedImpact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
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

class $$UserSubstancesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSubstancesTable> {
  $$UserSubstancesTableOrderingComposer({
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

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultImpact => $composableBuilder(
    column: $table.defaultImpact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get learnedImpact => $composableBuilder(
    column: $table.learnedImpact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
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

class $$UserSubstancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSubstancesTable> {
  $$UserSubstancesTableAnnotationComposer({
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

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<double> get defaultImpact => $composableBuilder(
    column: $table.defaultImpact,
    builder: (column) => column,
  );

  GeneratedColumn<double> get learnedImpact => $composableBuilder(
    column: $table.learnedImpact,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$UserSubstancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSubstancesTable,
          UserSubstance,
          $$UserSubstancesTableFilterComposer,
          $$UserSubstancesTableOrderingComposer,
          $$UserSubstancesTableAnnotationComposer,
          $$UserSubstancesTableCreateCompanionBuilder,
          $$UserSubstancesTableUpdateCompanionBuilder,
          (
            UserSubstance,
            BaseReferences<_$AppDatabase, $UserSubstancesTable, UserSubstance>,
          ),
          UserSubstance,
          PrefetchHooks Function()
        > {
  $$UserSubstancesTableTableManager(
    _$AppDatabase db,
    $UserSubstancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UserSubstancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$UserSubstancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$UserSubstancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<double> defaultImpact = const Value.absent(),
                Value<double?> learnedImpact = const Value.absent(),
                Value<int> occurrenceCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSubstancesCompanion(
                id: id,
                userId: userId,
                name: name,
                direction: direction,
                defaultImpact: defaultImpact,
                learnedImpact: learnedImpact,
                occurrenceCount: occurrenceCount,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<String> direction = const Value.absent(),
                Value<double> defaultImpact = const Value.absent(),
                Value<double?> learnedImpact = const Value.absent(),
                Value<int> occurrenceCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSubstancesCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                direction: direction,
                defaultImpact: defaultImpact,
                learnedImpact: learnedImpact,
                occurrenceCount: occurrenceCount,
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

typedef $$UserSubstancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSubstancesTable,
      UserSubstance,
      $$UserSubstancesTableFilterComposer,
      $$UserSubstancesTableOrderingComposer,
      $$UserSubstancesTableAnnotationComposer,
      $$UserSubstancesTableCreateCompanionBuilder,
      $$UserSubstancesTableUpdateCompanionBuilder,
      (
        UserSubstance,
        BaseReferences<_$AppDatabase, $UserSubstancesTable, UserSubstance>,
      ),
      UserSubstance,
      PrefetchHooks Function()
    >;
typedef $$SubstanceLogsTableCreateCompanionBuilder =
    SubstanceLogsCompanion Function({
      required String id,
      required String userId,
      required DateTime date,
      required String substanceName,
      required String direction,
      required double impactSnapshot,
      Value<String?> quantity,
      Value<String?> notes,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$SubstanceLogsTableUpdateCompanionBuilder =
    SubstanceLogsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> date,
      Value<String> substanceName,
      Value<String> direction,
      Value<double> impactSnapshot,
      Value<String?> quantity,
      Value<String?> notes,
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get substanceName => $composableBuilder(
    column: $table.substanceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get impactSnapshot => $composableBuilder(
    column: $table.impactSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get substanceName => $composableBuilder(
    column: $table.substanceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get impactSnapshot => $composableBuilder(
    column: $table.impactSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get substanceName => $composableBuilder(
    column: $table.substanceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<double> get impactSnapshot => $composableBuilder(
    column: $table.impactSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

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
                Value<String> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> substanceName = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<double> impactSnapshot = const Value.absent(),
                Value<String?> quantity = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubstanceLogsCompanion(
                id: id,
                userId: userId,
                date: date,
                substanceName: substanceName,
                direction: direction,
                impactSnapshot: impactSnapshot,
                quantity: quantity,
                notes: notes,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime date,
                required String substanceName,
                required String direction,
                required double impactSnapshot,
                Value<String?> quantity = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubstanceLogsCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                substanceName: substanceName,
                direction: direction,
                impactSnapshot: impactSnapshot,
                quantity: quantity,
                notes: notes,
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
typedef $$ReadinessCheckInsTableCreateCompanionBuilder =
    ReadinessCheckInsCompanion Function({
      required String id,
      required String userId,
      required DateTime date,
      required String checkInWindow,
      Value<double?> sleepHours,
      Value<int?> sleepQuality,
      Value<int?> stressLevel,
      Value<int?> energyLevel,
      Value<int?> mood,
      Value<int?> caffeineCount,
      Value<int?> focusLevel,
      Value<String?> notes,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$ReadinessCheckInsTableUpdateCompanionBuilder =
    ReadinessCheckInsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> date,
      Value<String> checkInWindow,
      Value<double?> sleepHours,
      Value<int?> sleepQuality,
      Value<int?> stressLevel,
      Value<int?> energyLevel,
      Value<int?> mood,
      Value<int?> caffeineCount,
      Value<int?> focusLevel,
      Value<String?> notes,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$ReadinessCheckInsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadinessCheckInsTable> {
  $$ReadinessCheckInsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkInWindow => $composableBuilder(
    column: $table.checkInWindow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stressLevel => $composableBuilder(
    column: $table.stressLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caffeineCount => $composableBuilder(
    column: $table.caffeineCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get focusLevel => $composableBuilder(
    column: $table.focusLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadinessCheckInsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadinessCheckInsTable> {
  $$ReadinessCheckInsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkInWindow => $composableBuilder(
    column: $table.checkInWindow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stressLevel => $composableBuilder(
    column: $table.stressLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caffeineCount => $composableBuilder(
    column: $table.caffeineCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get focusLevel => $composableBuilder(
    column: $table.focusLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadinessCheckInsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadinessCheckInsTable> {
  $$ReadinessCheckInsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get checkInWindow => $composableBuilder(
    column: $table.checkInWindow,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stressLevel => $composableBuilder(
    column: $table.stressLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<int> get caffeineCount => $composableBuilder(
    column: $table.caffeineCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get focusLevel => $composableBuilder(
    column: $table.focusLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ReadinessCheckInsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadinessCheckInsTable,
          ReadinessCheckIn,
          $$ReadinessCheckInsTableFilterComposer,
          $$ReadinessCheckInsTableOrderingComposer,
          $$ReadinessCheckInsTableAnnotationComposer,
          $$ReadinessCheckInsTableCreateCompanionBuilder,
          $$ReadinessCheckInsTableUpdateCompanionBuilder,
          (
            ReadinessCheckIn,
            BaseReferences<
              _$AppDatabase,
              $ReadinessCheckInsTable,
              ReadinessCheckIn
            >,
          ),
          ReadinessCheckIn,
          PrefetchHooks Function()
        > {
  $$ReadinessCheckInsTableTableManager(
    _$AppDatabase db,
    $ReadinessCheckInsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ReadinessCheckInsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$ReadinessCheckInsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$ReadinessCheckInsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> checkInWindow = const Value.absent(),
                Value<double?> sleepHours = const Value.absent(),
                Value<int?> sleepQuality = const Value.absent(),
                Value<int?> stressLevel = const Value.absent(),
                Value<int?> energyLevel = const Value.absent(),
                Value<int?> mood = const Value.absent(),
                Value<int?> caffeineCount = const Value.absent(),
                Value<int?> focusLevel = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadinessCheckInsCompanion(
                id: id,
                userId: userId,
                date: date,
                checkInWindow: checkInWindow,
                sleepHours: sleepHours,
                sleepQuality: sleepQuality,
                stressLevel: stressLevel,
                energyLevel: energyLevel,
                mood: mood,
                caffeineCount: caffeineCount,
                focusLevel: focusLevel,
                notes: notes,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime date,
                required String checkInWindow,
                Value<double?> sleepHours = const Value.absent(),
                Value<int?> sleepQuality = const Value.absent(),
                Value<int?> stressLevel = const Value.absent(),
                Value<int?> energyLevel = const Value.absent(),
                Value<int?> mood = const Value.absent(),
                Value<int?> caffeineCount = const Value.absent(),
                Value<int?> focusLevel = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadinessCheckInsCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                checkInWindow: checkInWindow,
                sleepHours: sleepHours,
                sleepQuality: sleepQuality,
                stressLevel: stressLevel,
                energyLevel: energyLevel,
                mood: mood,
                caffeineCount: caffeineCount,
                focusLevel: focusLevel,
                notes: notes,
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

typedef $$ReadinessCheckInsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadinessCheckInsTable,
      ReadinessCheckIn,
      $$ReadinessCheckInsTableFilterComposer,
      $$ReadinessCheckInsTableOrderingComposer,
      $$ReadinessCheckInsTableAnnotationComposer,
      $$ReadinessCheckInsTableCreateCompanionBuilder,
      $$ReadinessCheckInsTableUpdateCompanionBuilder,
      (
        ReadinessCheckIn,
        BaseReferences<
          _$AppDatabase,
          $ReadinessCheckInsTable,
          ReadinessCheckIn
        >,
      ),
      ReadinessCheckIn,
      PrefetchHooks Function()
    >;
typedef $$DailyReadinessTableCreateCompanionBuilder =
    DailyReadinessCompanion Function({
      required String id,
      required String userId,
      required DateTime date,
      Value<double> computedScore,
      Value<double?> userRatedScore,
      Value<double> previousDayInfluence,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$DailyReadinessTableUpdateCompanionBuilder =
    DailyReadinessCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> date,
      Value<double> computedScore,
      Value<double?> userRatedScore,
      Value<double> previousDayInfluence,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$DailyReadinessTableFilterComposer
    extends Composer<_$AppDatabase, $DailyReadinessTable> {
  $$DailyReadinessTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get computedScore => $composableBuilder(
    column: $table.computedScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get userRatedScore => $composableBuilder(
    column: $table.userRatedScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get previousDayInfluence => $composableBuilder(
    column: $table.previousDayInfluence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyReadinessTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyReadinessTable> {
  $$DailyReadinessTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get computedScore => $composableBuilder(
    column: $table.computedScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get userRatedScore => $composableBuilder(
    column: $table.userRatedScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get previousDayInfluence => $composableBuilder(
    column: $table.previousDayInfluence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyReadinessTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyReadinessTable> {
  $$DailyReadinessTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get computedScore => $composableBuilder(
    column: $table.computedScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get userRatedScore => $composableBuilder(
    column: $table.userRatedScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get previousDayInfluence => $composableBuilder(
    column: $table.previousDayInfluence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$DailyReadinessTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyReadinessTable,
          DailyReadinessData,
          $$DailyReadinessTableFilterComposer,
          $$DailyReadinessTableOrderingComposer,
          $$DailyReadinessTableAnnotationComposer,
          $$DailyReadinessTableCreateCompanionBuilder,
          $$DailyReadinessTableUpdateCompanionBuilder,
          (
            DailyReadinessData,
            BaseReferences<
              _$AppDatabase,
              $DailyReadinessTable,
              DailyReadinessData
            >,
          ),
          DailyReadinessData,
          PrefetchHooks Function()
        > {
  $$DailyReadinessTableTableManager(
    _$AppDatabase db,
    $DailyReadinessTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DailyReadinessTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$DailyReadinessTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$DailyReadinessTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> computedScore = const Value.absent(),
                Value<double?> userRatedScore = const Value.absent(),
                Value<double> previousDayInfluence = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyReadinessCompanion(
                id: id,
                userId: userId,
                date: date,
                computedScore: computedScore,
                userRatedScore: userRatedScore,
                previousDayInfluence: previousDayInfluence,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime date,
                Value<double> computedScore = const Value.absent(),
                Value<double?> userRatedScore = const Value.absent(),
                Value<double> previousDayInfluence = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyReadinessCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                computedScore: computedScore,
                userRatedScore: userRatedScore,
                previousDayInfluence: previousDayInfluence,
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

typedef $$DailyReadinessTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyReadinessTable,
      DailyReadinessData,
      $$DailyReadinessTableFilterComposer,
      $$DailyReadinessTableOrderingComposer,
      $$DailyReadinessTableAnnotationComposer,
      $$DailyReadinessTableCreateCompanionBuilder,
      $$DailyReadinessTableUpdateCompanionBuilder,
      (
        DailyReadinessData,
        BaseReferences<_$AppDatabase, $DailyReadinessTable, DailyReadinessData>,
      ),
      DailyReadinessData,
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
  $$UserSubstancesTableTableManager get userSubstances =>
      $$UserSubstancesTableTableManager(_db, _db.userSubstances);
  $$SubstanceLogsTableTableManager get substanceLogs =>
      $$SubstanceLogsTableTableManager(_db, _db.substanceLogs);
  $$ReadinessCheckInsTableTableManager get readinessCheckIns =>
      $$ReadinessCheckInsTableTableManager(_db, _db.readinessCheckIns);
  $$DailyReadinessTableTableManager get dailyReadiness =>
      $$DailyReadinessTableTableManager(_db, _db.dailyReadiness);
}
