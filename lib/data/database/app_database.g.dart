// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SemestersTable extends Semesters
    with TableInfo<$SemestersTable, Semester> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SemestersTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameManuallyEditedMeta =
      const VerificationMeta('nameManuallyEdited');
  @override
  late final GeneratedColumn<bool> nameManuallyEdited = GeneratedColumn<bool>(
    'name_manually_edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("name_manually_edited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _firstWeekMondayMeta = const VerificationMeta(
    'firstWeekMonday',
  );
  @override
  late final GeneratedColumn<DateTime> firstWeekMonday =
      GeneratedColumn<DateTime>(
        'first_week_monday',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionTemplateJsonMeta =
      const VerificationMeta('sessionTemplateJson');
  @override
  late final GeneratedColumn<String> sessionTemplateJson =
      GeneratedColumn<String>(
        'session_template_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nameManuallyEdited,
    firstWeekMonday,
    endDate,
    sessionTemplateJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'semesters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Semester> instance, {
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
    if (data.containsKey('name_manually_edited')) {
      context.handle(
        _nameManuallyEditedMeta,
        nameManuallyEdited.isAcceptableOrUnknown(
          data['name_manually_edited']!,
          _nameManuallyEditedMeta,
        ),
      );
    }
    if (data.containsKey('first_week_monday')) {
      context.handle(
        _firstWeekMondayMeta,
        firstWeekMonday.isAcceptableOrUnknown(
          data['first_week_monday']!,
          _firstWeekMondayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstWeekMondayMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('session_template_json')) {
      context.handle(
        _sessionTemplateJsonMeta,
        sessionTemplateJson.isAcceptableOrUnknown(
          data['session_template_json']!,
          _sessionTemplateJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Semester map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Semester(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameManuallyEdited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}name_manually_edited'],
      )!,
      firstWeekMonday: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_week_monday'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      sessionTemplateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_template_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SemestersTable createAlias(String alias) {
    return $SemestersTable(attachedDatabase, alias);
  }
}

class Semester extends DataClass implements Insertable<Semester> {
  final int id;
  final String name;
  final bool nameManuallyEdited;
  final DateTime firstWeekMonday;
  final DateTime? endDate;
  final String? sessionTemplateJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Semester({
    required this.id,
    required this.name,
    required this.nameManuallyEdited,
    required this.firstWeekMonday,
    this.endDate,
    this.sessionTemplateJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_manually_edited'] = Variable<bool>(nameManuallyEdited);
    map['first_week_monday'] = Variable<DateTime>(firstWeekMonday);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || sessionTemplateJson != null) {
      map['session_template_json'] = Variable<String>(sessionTemplateJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SemestersCompanion toCompanion(bool nullToAbsent) {
    return SemestersCompanion(
      id: Value(id),
      name: Value(name),
      nameManuallyEdited: Value(nameManuallyEdited),
      firstWeekMonday: Value(firstWeekMonday),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      sessionTemplateJson: sessionTemplateJson == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionTemplateJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Semester.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Semester(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameManuallyEdited: serializer.fromJson<bool>(json['nameManuallyEdited']),
      firstWeekMonday: serializer.fromJson<DateTime>(json['firstWeekMonday']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      sessionTemplateJson: serializer.fromJson<String?>(
        json['sessionTemplateJson'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameManuallyEdited': serializer.toJson<bool>(nameManuallyEdited),
      'firstWeekMonday': serializer.toJson<DateTime>(firstWeekMonday),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'sessionTemplateJson': serializer.toJson<String?>(sessionTemplateJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Semester copyWith({
    int? id,
    String? name,
    bool? nameManuallyEdited,
    DateTime? firstWeekMonday,
    Value<DateTime?> endDate = const Value.absent(),
    Value<String?> sessionTemplateJson = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Semester(
    id: id ?? this.id,
    name: name ?? this.name,
    nameManuallyEdited: nameManuallyEdited ?? this.nameManuallyEdited,
    firstWeekMonday: firstWeekMonday ?? this.firstWeekMonday,
    endDate: endDate.present ? endDate.value : this.endDate,
    sessionTemplateJson: sessionTemplateJson.present
        ? sessionTemplateJson.value
        : this.sessionTemplateJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Semester copyWithCompanion(SemestersCompanion data) {
    return Semester(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameManuallyEdited: data.nameManuallyEdited.present
          ? data.nameManuallyEdited.value
          : this.nameManuallyEdited,
      firstWeekMonday: data.firstWeekMonday.present
          ? data.firstWeekMonday.value
          : this.firstWeekMonday,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      sessionTemplateJson: data.sessionTemplateJson.present
          ? data.sessionTemplateJson.value
          : this.sessionTemplateJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Semester(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameManuallyEdited: $nameManuallyEdited, ')
          ..write('firstWeekMonday: $firstWeekMonday, ')
          ..write('endDate: $endDate, ')
          ..write('sessionTemplateJson: $sessionTemplateJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    nameManuallyEdited,
    firstWeekMonday,
    endDate,
    sessionTemplateJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Semester &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameManuallyEdited == this.nameManuallyEdited &&
          other.firstWeekMonday == this.firstWeekMonday &&
          other.endDate == this.endDate &&
          other.sessionTemplateJson == this.sessionTemplateJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SemestersCompanion extends UpdateCompanion<Semester> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> nameManuallyEdited;
  final Value<DateTime> firstWeekMonday;
  final Value<DateTime?> endDate;
  final Value<String?> sessionTemplateJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SemestersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameManuallyEdited = const Value.absent(),
    this.firstWeekMonday = const Value.absent(),
    this.endDate = const Value.absent(),
    this.sessionTemplateJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SemestersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.nameManuallyEdited = const Value.absent(),
    required DateTime firstWeekMonday,
    this.endDate = const Value.absent(),
    this.sessionTemplateJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       firstWeekMonday = Value(firstWeekMonday);
  static Insertable<Semester> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? nameManuallyEdited,
    Expression<DateTime>? firstWeekMonday,
    Expression<DateTime>? endDate,
    Expression<String>? sessionTemplateJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameManuallyEdited != null)
        'name_manually_edited': nameManuallyEdited,
      if (firstWeekMonday != null) 'first_week_monday': firstWeekMonday,
      if (endDate != null) 'end_date': endDate,
      if (sessionTemplateJson != null)
        'session_template_json': sessionTemplateJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SemestersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? nameManuallyEdited,
    Value<DateTime>? firstWeekMonday,
    Value<DateTime?>? endDate,
    Value<String?>? sessionTemplateJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SemestersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameManuallyEdited: nameManuallyEdited ?? this.nameManuallyEdited,
      firstWeekMonday: firstWeekMonday ?? this.firstWeekMonday,
      endDate: endDate ?? this.endDate,
      sessionTemplateJson: sessionTemplateJson ?? this.sessionTemplateJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (nameManuallyEdited.present) {
      map['name_manually_edited'] = Variable<bool>(nameManuallyEdited.value);
    }
    if (firstWeekMonday.present) {
      map['first_week_monday'] = Variable<DateTime>(firstWeekMonday.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (sessionTemplateJson.present) {
      map['session_template_json'] = Variable<String>(
        sessionTemplateJson.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SemestersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameManuallyEdited: $nameManuallyEdited, ')
          ..write('firstWeekMonday: $firstWeekMonday, ')
          ..write('endDate: $endDate, ')
          ..write('sessionTemplateJson: $sessionTemplateJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TimetablePlansTable extends TimetablePlans
    with TableInfo<$TimetablePlansTable, TimetablePlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimetablePlansTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _semesterIdMeta = const VerificationMeta(
    'semesterId',
  );
  @override
  late final GeneratedColumn<int> semesterId = GeneratedColumn<int>(
    'semester_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES semesters (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    semesterId,
    name,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timetable_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimetablePlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('semester_id')) {
      context.handle(
        _semesterIdMeta,
        semesterId.isAcceptableOrUnknown(data['semester_id']!, _semesterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_semesterIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimetablePlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimetablePlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      semesterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}semester_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TimetablePlansTable createAlias(String alias) {
    return $TimetablePlansTable(attachedDatabase, alias);
  }
}

class TimetablePlan extends DataClass implements Insertable<TimetablePlan> {
  final int id;
  final int semesterId;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TimetablePlan({
    required this.id,
    required this.semesterId,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['semester_id'] = Variable<int>(semesterId);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TimetablePlansCompanion toCompanion(bool nullToAbsent) {
    return TimetablePlansCompanion(
      id: Value(id),
      semesterId: Value(semesterId),
      name: Value(name),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TimetablePlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimetablePlan(
      id: serializer.fromJson<int>(json['id']),
      semesterId: serializer.fromJson<int>(json['semesterId']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'semesterId': serializer.toJson<int>(semesterId),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TimetablePlan copyWith({
    int? id,
    int? semesterId,
    String? name,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TimetablePlan(
    id: id ?? this.id,
    semesterId: semesterId ?? this.semesterId,
    name: name ?? this.name,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TimetablePlan copyWithCompanion(TimetablePlansCompanion data) {
    return TimetablePlan(
      id: data.id.present ? data.id.value : this.id,
      semesterId: data.semesterId.present
          ? data.semesterId.value
          : this.semesterId,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimetablePlan(')
          ..write('id: $id, ')
          ..write('semesterId: $semesterId, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, semesterId, name, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimetablePlan &&
          other.id == this.id &&
          other.semesterId == this.semesterId &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TimetablePlansCompanion extends UpdateCompanion<TimetablePlan> {
  final Value<int> id;
  final Value<int> semesterId;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TimetablePlansCompanion({
    this.id = const Value.absent(),
    this.semesterId = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TimetablePlansCompanion.insert({
    this.id = const Value.absent(),
    required int semesterId,
    required String name,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : semesterId = Value(semesterId),
       name = Value(name);
  static Insertable<TimetablePlan> custom({
    Expression<int>? id,
    Expression<int>? semesterId,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (semesterId != null) 'semester_id': semesterId,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TimetablePlansCompanion copyWith({
    Value<int>? id,
    Value<int>? semesterId,
    Value<String>? name,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TimetablePlansCompanion(
      id: id ?? this.id,
      semesterId: semesterId ?? this.semesterId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (semesterId.present) {
      map['semester_id'] = Variable<int>(semesterId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimetablePlansCompanion(')
          ..write('id: $id, ')
          ..write('semesterId: $semesterId, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ImportBatchesTable extends ImportBatches
    with TableInfo<$ImportBatchesTable, ImportBatche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportBatchesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileTypeMeta = const VerificationMeta(
    'fileType',
  );
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
    'file_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _summaryJsonMeta = const VerificationMeta(
    'summaryJson',
  );
  @override
  late final GeneratedColumn<String> summaryJson = GeneratedColumn<String>(
    'summary_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceName,
    fileType,
    importedAt,
    summaryJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportBatche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(
        _fileTypeMeta,
        fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileTypeMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    if (data.containsKey('summary_json')) {
      context.handle(
        _summaryJsonMeta,
        summaryJson.isAcceptableOrUnknown(
          data['summary_json']!,
          _summaryJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportBatche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportBatche(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_name'],
      )!,
      fileType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_type'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      summaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_json'],
      ),
    );
  }

  @override
  $ImportBatchesTable createAlias(String alias) {
    return $ImportBatchesTable(attachedDatabase, alias);
  }
}

class ImportBatche extends DataClass implements Insertable<ImportBatche> {
  final int id;
  final String sourceName;
  final String fileType;
  final DateTime importedAt;
  final String? summaryJson;
  const ImportBatche({
    required this.id,
    required this.sourceName,
    required this.fileType,
    required this.importedAt,
    this.summaryJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_name'] = Variable<String>(sourceName);
    map['file_type'] = Variable<String>(fileType);
    map['imported_at'] = Variable<DateTime>(importedAt);
    if (!nullToAbsent || summaryJson != null) {
      map['summary_json'] = Variable<String>(summaryJson);
    }
    return map;
  }

  ImportBatchesCompanion toCompanion(bool nullToAbsent) {
    return ImportBatchesCompanion(
      id: Value(id),
      sourceName: Value(sourceName),
      fileType: Value(fileType),
      importedAt: Value(importedAt),
      summaryJson: summaryJson == null && nullToAbsent
          ? const Value.absent()
          : Value(summaryJson),
    );
  }

  factory ImportBatche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportBatche(
      id: serializer.fromJson<int>(json['id']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      fileType: serializer.fromJson<String>(json['fileType']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      summaryJson: serializer.fromJson<String?>(json['summaryJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceName': serializer.toJson<String>(sourceName),
      'fileType': serializer.toJson<String>(fileType),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'summaryJson': serializer.toJson<String?>(summaryJson),
    };
  }

  ImportBatche copyWith({
    int? id,
    String? sourceName,
    String? fileType,
    DateTime? importedAt,
    Value<String?> summaryJson = const Value.absent(),
  }) => ImportBatche(
    id: id ?? this.id,
    sourceName: sourceName ?? this.sourceName,
    fileType: fileType ?? this.fileType,
    importedAt: importedAt ?? this.importedAt,
    summaryJson: summaryJson.present ? summaryJson.value : this.summaryJson,
  );
  ImportBatche copyWithCompanion(ImportBatchesCompanion data) {
    return ImportBatche(
      id: data.id.present ? data.id.value : this.id,
      sourceName: data.sourceName.present
          ? data.sourceName.value
          : this.sourceName,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      summaryJson: data.summaryJson.present
          ? data.summaryJson.value
          : this.summaryJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatche(')
          ..write('id: $id, ')
          ..write('sourceName: $sourceName, ')
          ..write('fileType: $fileType, ')
          ..write('importedAt: $importedAt, ')
          ..write('summaryJson: $summaryJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sourceName, fileType, importedAt, summaryJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportBatche &&
          other.id == this.id &&
          other.sourceName == this.sourceName &&
          other.fileType == this.fileType &&
          other.importedAt == this.importedAt &&
          other.summaryJson == this.summaryJson);
}

class ImportBatchesCompanion extends UpdateCompanion<ImportBatche> {
  final Value<int> id;
  final Value<String> sourceName;
  final Value<String> fileType;
  final Value<DateTime> importedAt;
  final Value<String?> summaryJson;
  const ImportBatchesCompanion({
    this.id = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.fileType = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.summaryJson = const Value.absent(),
  });
  ImportBatchesCompanion.insert({
    this.id = const Value.absent(),
    required String sourceName,
    required String fileType,
    this.importedAt = const Value.absent(),
    this.summaryJson = const Value.absent(),
  }) : sourceName = Value(sourceName),
       fileType = Value(fileType);
  static Insertable<ImportBatche> custom({
    Expression<int>? id,
    Expression<String>? sourceName,
    Expression<String>? fileType,
    Expression<DateTime>? importedAt,
    Expression<String>? summaryJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceName != null) 'source_name': sourceName,
      if (fileType != null) 'file_type': fileType,
      if (importedAt != null) 'imported_at': importedAt,
      if (summaryJson != null) 'summary_json': summaryJson,
    });
  }

  ImportBatchesCompanion copyWith({
    Value<int>? id,
    Value<String>? sourceName,
    Value<String>? fileType,
    Value<DateTime>? importedAt,
    Value<String?>? summaryJson,
  }) {
    return ImportBatchesCompanion(
      id: id ?? this.id,
      sourceName: sourceName ?? this.sourceName,
      fileType: fileType ?? this.fileType,
      importedAt: importedAt ?? this.importedAt,
      summaryJson: summaryJson ?? this.summaryJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (summaryJson.present) {
      map['summary_json'] = Variable<String>(summaryJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatchesCompanion(')
          ..write('id: $id, ')
          ..write('sourceName: $sourceName, ')
          ..write('fileType: $fileType, ')
          ..write('importedAt: $importedAt, ')
          ..write('summaryJson: $summaryJson')
          ..write(')'))
        .toString();
  }
}

class $SourceRecordsTable extends SourceRecords
    with TableInfo<$SourceRecordsTable, SourceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourceRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _importBatchIdMeta = const VerificationMeta(
    'importBatchId',
  );
  @override
  late final GeneratedColumn<int> importBatchId = GeneratedColumn<int>(
    'import_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id)',
    ),
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 128,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawContentMeta = const VerificationMeta(
    'rawContent',
  );
  @override
  late final GeneratedColumn<String> rawContent = GeneratedColumn<String>(
    'raw_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _normalizedJsonMeta = const VerificationMeta(
    'normalizedJson',
  );
  @override
  late final GeneratedColumn<String> normalizedJson = GeneratedColumn<String>(
    'normalized_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    importBatchId,
    fingerprint,
    rawContent,
    normalizedJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('import_batch_id')) {
      context.handle(
        _importBatchIdMeta,
        importBatchId.isAcceptableOrUnknown(
          data['import_batch_id']!,
          _importBatchIdMeta,
        ),
      );
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('raw_content')) {
      context.handle(
        _rawContentMeta,
        rawContent.isAcceptableOrUnknown(data['raw_content']!, _rawContentMeta),
      );
    }
    if (data.containsKey('normalized_json')) {
      context.handle(
        _normalizedJsonMeta,
        normalizedJson.isAcceptableOrUnknown(
          data['normalized_json']!,
          _normalizedJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {fingerprint},
  ];
  @override
  SourceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      importBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_batch_id'],
      ),
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      rawContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_content'],
      ),
      normalizedJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SourceRecordsTable createAlias(String alias) {
    return $SourceRecordsTable(attachedDatabase, alias);
  }
}

class SourceRecord extends DataClass implements Insertable<SourceRecord> {
  final int id;
  final int? importBatchId;
  final String fingerprint;
  final String? rawContent;
  final String? normalizedJson;
  final DateTime createdAt;
  const SourceRecord({
    required this.id,
    this.importBatchId,
    required this.fingerprint,
    this.rawContent,
    this.normalizedJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || importBatchId != null) {
      map['import_batch_id'] = Variable<int>(importBatchId);
    }
    map['fingerprint'] = Variable<String>(fingerprint);
    if (!nullToAbsent || rawContent != null) {
      map['raw_content'] = Variable<String>(rawContent);
    }
    if (!nullToAbsent || normalizedJson != null) {
      map['normalized_json'] = Variable<String>(normalizedJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SourceRecordsCompanion toCompanion(bool nullToAbsent) {
    return SourceRecordsCompanion(
      id: Value(id),
      importBatchId: importBatchId == null && nullToAbsent
          ? const Value.absent()
          : Value(importBatchId),
      fingerprint: Value(fingerprint),
      rawContent: rawContent == null && nullToAbsent
          ? const Value.absent()
          : Value(rawContent),
      normalizedJson: normalizedJson == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedJson),
      createdAt: Value(createdAt),
    );
  }

  factory SourceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceRecord(
      id: serializer.fromJson<int>(json['id']),
      importBatchId: serializer.fromJson<int?>(json['importBatchId']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      rawContent: serializer.fromJson<String?>(json['rawContent']),
      normalizedJson: serializer.fromJson<String?>(json['normalizedJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'importBatchId': serializer.toJson<int?>(importBatchId),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'rawContent': serializer.toJson<String?>(rawContent),
      'normalizedJson': serializer.toJson<String?>(normalizedJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SourceRecord copyWith({
    int? id,
    Value<int?> importBatchId = const Value.absent(),
    String? fingerprint,
    Value<String?> rawContent = const Value.absent(),
    Value<String?> normalizedJson = const Value.absent(),
    DateTime? createdAt,
  }) => SourceRecord(
    id: id ?? this.id,
    importBatchId: importBatchId.present
        ? importBatchId.value
        : this.importBatchId,
    fingerprint: fingerprint ?? this.fingerprint,
    rawContent: rawContent.present ? rawContent.value : this.rawContent,
    normalizedJson: normalizedJson.present
        ? normalizedJson.value
        : this.normalizedJson,
    createdAt: createdAt ?? this.createdAt,
  );
  SourceRecord copyWithCompanion(SourceRecordsCompanion data) {
    return SourceRecord(
      id: data.id.present ? data.id.value : this.id,
      importBatchId: data.importBatchId.present
          ? data.importBatchId.value
          : this.importBatchId,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      rawContent: data.rawContent.present
          ? data.rawContent.value
          : this.rawContent,
      normalizedJson: data.normalizedJson.present
          ? data.normalizedJson.value
          : this.normalizedJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceRecord(')
          ..write('id: $id, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('rawContent: $rawContent, ')
          ..write('normalizedJson: $normalizedJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    importBatchId,
    fingerprint,
    rawContent,
    normalizedJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceRecord &&
          other.id == this.id &&
          other.importBatchId == this.importBatchId &&
          other.fingerprint == this.fingerprint &&
          other.rawContent == this.rawContent &&
          other.normalizedJson == this.normalizedJson &&
          other.createdAt == this.createdAt);
}

class SourceRecordsCompanion extends UpdateCompanion<SourceRecord> {
  final Value<int> id;
  final Value<int?> importBatchId;
  final Value<String> fingerprint;
  final Value<String?> rawContent;
  final Value<String?> normalizedJson;
  final Value<DateTime> createdAt;
  const SourceRecordsCompanion({
    this.id = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.rawContent = const Value.absent(),
    this.normalizedJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SourceRecordsCompanion.insert({
    this.id = const Value.absent(),
    this.importBatchId = const Value.absent(),
    required String fingerprint,
    this.rawContent = const Value.absent(),
    this.normalizedJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : fingerprint = Value(fingerprint);
  static Insertable<SourceRecord> custom({
    Expression<int>? id,
    Expression<int>? importBatchId,
    Expression<String>? fingerprint,
    Expression<String>? rawContent,
    Expression<String>? normalizedJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (importBatchId != null) 'import_batch_id': importBatchId,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (rawContent != null) 'raw_content': rawContent,
      if (normalizedJson != null) 'normalized_json': normalizedJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SourceRecordsCompanion copyWith({
    Value<int>? id,
    Value<int?>? importBatchId,
    Value<String>? fingerprint,
    Value<String?>? rawContent,
    Value<String?>? normalizedJson,
    Value<DateTime>? createdAt,
  }) {
    return SourceRecordsCompanion(
      id: id ?? this.id,
      importBatchId: importBatchId ?? this.importBatchId,
      fingerprint: fingerprint ?? this.fingerprint,
      rawContent: rawContent ?? this.rawContent,
      normalizedJson: normalizedJson ?? this.normalizedJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (importBatchId.present) {
      map['import_batch_id'] = Variable<int>(importBatchId.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (rawContent.present) {
      map['raw_content'] = Variable<String>(rawContent.value);
    }
    if (normalizedJson.present) {
      map['normalized_json'] = Variable<String>(normalizedJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('rawContent: $rawContent, ')
          ..write('normalizedJson: $normalizedJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CoursesTable extends Courses with TableInfo<$CoursesTable, Course> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES timetable_plans (id)',
    ),
  );
  static const VerificationMeta _sourceRecordIdMeta = const VerificationMeta(
    'sourceRecordId',
  );
  @override
  late final GeneratedColumn<int> sourceRecordId = GeneratedColumn<int>(
    'source_record_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source_records (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 160,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherMeta = const VerificationMeta(
    'teacher',
  );
  @override
  late final GeneratedColumn<String> teacher = GeneratedColumn<String>(
    'teacher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    sourceRecordId,
    name,
    teacher,
    color,
    note,
    isHidden,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Course> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('source_record_id')) {
      context.handle(
        _sourceRecordIdMeta,
        sourceRecordId.isAcceptableOrUnknown(
          data['source_record_id']!,
          _sourceRecordIdMeta,
        ),
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
    if (data.containsKey('teacher')) {
      context.handle(
        _teacherMeta,
        teacher.isAcceptableOrUnknown(data['teacher']!, _teacherMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Course map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Course(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      sourceRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_record_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      teacher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CoursesTable createAlias(String alias) {
    return $CoursesTable(attachedDatabase, alias);
  }
}

class Course extends DataClass implements Insertable<Course> {
  final int id;
  final int planId;
  final int? sourceRecordId;
  final String name;
  final String? teacher;
  final String? color;
  final String? note;
  final bool isHidden;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Course({
    required this.id,
    required this.planId,
    this.sourceRecordId,
    required this.name,
    this.teacher,
    this.color,
    this.note,
    required this.isHidden,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<int>(planId);
    if (!nullToAbsent || sourceRecordId != null) {
      map['source_record_id'] = Variable<int>(sourceRecordId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || teacher != null) {
      map['teacher'] = Variable<String>(teacher);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_hidden'] = Variable<bool>(isHidden);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CoursesCompanion toCompanion(bool nullToAbsent) {
    return CoursesCompanion(
      id: Value(id),
      planId: Value(planId),
      sourceRecordId: sourceRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRecordId),
      name: Value(name),
      teacher: teacher == null && nullToAbsent
          ? const Value.absent()
          : Value(teacher),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isHidden: Value(isHidden),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Course.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Course(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int>(json['planId']),
      sourceRecordId: serializer.fromJson<int?>(json['sourceRecordId']),
      name: serializer.fromJson<String>(json['name']),
      teacher: serializer.fromJson<String?>(json['teacher']),
      color: serializer.fromJson<String?>(json['color']),
      note: serializer.fromJson<String?>(json['note']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int>(planId),
      'sourceRecordId': serializer.toJson<int?>(sourceRecordId),
      'name': serializer.toJson<String>(name),
      'teacher': serializer.toJson<String?>(teacher),
      'color': serializer.toJson<String?>(color),
      'note': serializer.toJson<String?>(note),
      'isHidden': serializer.toJson<bool>(isHidden),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Course copyWith({
    int? id,
    int? planId,
    Value<int?> sourceRecordId = const Value.absent(),
    String? name,
    Value<String?> teacher = const Value.absent(),
    Value<String?> color = const Value.absent(),
    Value<String?> note = const Value.absent(),
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Course(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    sourceRecordId: sourceRecordId.present
        ? sourceRecordId.value
        : this.sourceRecordId,
    name: name ?? this.name,
    teacher: teacher.present ? teacher.value : this.teacher,
    color: color.present ? color.value : this.color,
    note: note.present ? note.value : this.note,
    isHidden: isHidden ?? this.isHidden,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Course copyWithCompanion(CoursesCompanion data) {
    return Course(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      sourceRecordId: data.sourceRecordId.present
          ? data.sourceRecordId.value
          : this.sourceRecordId,
      name: data.name.present ? data.name.value : this.name,
      teacher: data.teacher.present ? data.teacher.value : this.teacher,
      color: data.color.present ? data.color.value : this.color,
      note: data.note.present ? data.note.value : this.note,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Course(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('sourceRecordId: $sourceRecordId, ')
          ..write('name: $name, ')
          ..write('teacher: $teacher, ')
          ..write('color: $color, ')
          ..write('note: $note, ')
          ..write('isHidden: $isHidden, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    sourceRecordId,
    name,
    teacher,
    color,
    note,
    isHidden,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Course &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.sourceRecordId == this.sourceRecordId &&
          other.name == this.name &&
          other.teacher == this.teacher &&
          other.color == this.color &&
          other.note == this.note &&
          other.isHidden == this.isHidden &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CoursesCompanion extends UpdateCompanion<Course> {
  final Value<int> id;
  final Value<int> planId;
  final Value<int?> sourceRecordId;
  final Value<String> name;
  final Value<String?> teacher;
  final Value<String?> color;
  final Value<String?> note;
  final Value<bool> isHidden;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CoursesCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.sourceRecordId = const Value.absent(),
    this.name = const Value.absent(),
    this.teacher = const Value.absent(),
    this.color = const Value.absent(),
    this.note = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CoursesCompanion.insert({
    this.id = const Value.absent(),
    required int planId,
    this.sourceRecordId = const Value.absent(),
    required String name,
    this.teacher = const Value.absent(),
    this.color = const Value.absent(),
    this.note = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : planId = Value(planId),
       name = Value(name);
  static Insertable<Course> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<int>? sourceRecordId,
    Expression<String>? name,
    Expression<String>? teacher,
    Expression<String>? color,
    Expression<String>? note,
    Expression<bool>? isHidden,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (sourceRecordId != null) 'source_record_id': sourceRecordId,
      if (name != null) 'name': name,
      if (teacher != null) 'teacher': teacher,
      if (color != null) 'color': color,
      if (note != null) 'note': note,
      if (isHidden != null) 'is_hidden': isHidden,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CoursesCompanion copyWith({
    Value<int>? id,
    Value<int>? planId,
    Value<int?>? sourceRecordId,
    Value<String>? name,
    Value<String?>? teacher,
    Value<String?>? color,
    Value<String?>? note,
    Value<bool>? isHidden,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CoursesCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      sourceRecordId: sourceRecordId ?? this.sourceRecordId,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      color: color ?? this.color,
      note: note ?? this.note,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (sourceRecordId.present) {
      map['source_record_id'] = Variable<int>(sourceRecordId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (teacher.present) {
      map['teacher'] = Variable<String>(teacher.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('sourceRecordId: $sourceRecordId, ')
          ..write('name: $name, ')
          ..write('teacher: $teacher, ')
          ..write('color: $color, ')
          ..write('note: $note, ')
          ..write('isHidden: $isHidden, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ClassSessionsTable extends ClassSessions
    with TableInfo<$ClassSessionsTable, ClassSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<int> courseId = GeneratedColumn<int>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES courses (id)',
    ),
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startSectionMeta = const VerificationMeta(
    'startSection',
  );
  @override
  late final GeneratedColumn<int> startSection = GeneratedColumn<int>(
    'start_section',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endSectionMeta = const VerificationMeta(
    'endSection',
  );
  @override
  late final GeneratedColumn<int> endSection = GeneratedColumn<int>(
    'end_section',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<int> weekStart = GeneratedColumn<int>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekEndMeta = const VerificationMeta(
    'weekEnd',
  );
  @override
  late final GeneratedColumn<int> weekEnd = GeneratedColumn<int>(
    'week_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekParityMeta = const VerificationMeta(
    'weekParity',
  );
  @override
  late final GeneratedColumn<String> weekParity = GeneratedColumn<String>(
    'week_parity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    courseId,
    weekday,
    startSection,
    endSection,
    weekStart,
    weekEnd,
    weekParity,
    location,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'class_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('start_section')) {
      context.handle(
        _startSectionMeta,
        startSection.isAcceptableOrUnknown(
          data['start_section']!,
          _startSectionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startSectionMeta);
    }
    if (data.containsKey('end_section')) {
      context.handle(
        _endSectionMeta,
        endSection.isAcceptableOrUnknown(data['end_section']!, _endSectionMeta),
      );
    } else if (isInserting) {
      context.missing(_endSectionMeta);
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('week_end')) {
      context.handle(
        _weekEndMeta,
        weekEnd.isAcceptableOrUnknown(data['week_end']!, _weekEndMeta),
      );
    } else if (isInserting) {
      context.missing(_weekEndMeta);
    }
    if (data.containsKey('week_parity')) {
      context.handle(
        _weekParityMeta,
        weekParity.isAcceptableOrUnknown(data['week_parity']!, _weekParityMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClassSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}course_id'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      startSection: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_section'],
      )!,
      endSection: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_section'],
      )!,
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_start'],
      )!,
      weekEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_end'],
      )!,
      weekParity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_parity'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ClassSessionsTable createAlias(String alias) {
    return $ClassSessionsTable(attachedDatabase, alias);
  }
}

class ClassSession extends DataClass implements Insertable<ClassSession> {
  final int id;
  final int courseId;

  /// ISO weekday, Monday = 1, Sunday = 7.
  final int weekday;
  final int startSection;
  final int endSection;
  final int weekStart;
  final int weekEnd;
  final String? weekParity;
  final String? location;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ClassSession({
    required this.id,
    required this.courseId,
    required this.weekday,
    required this.startSection,
    required this.endSection,
    required this.weekStart,
    required this.weekEnd,
    this.weekParity,
    this.location,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['course_id'] = Variable<int>(courseId);
    map['weekday'] = Variable<int>(weekday);
    map['start_section'] = Variable<int>(startSection);
    map['end_section'] = Variable<int>(endSection);
    map['week_start'] = Variable<int>(weekStart);
    map['week_end'] = Variable<int>(weekEnd);
    if (!nullToAbsent || weekParity != null) {
      map['week_parity'] = Variable<String>(weekParity);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ClassSessionsCompanion toCompanion(bool nullToAbsent) {
    return ClassSessionsCompanion(
      id: Value(id),
      courseId: Value(courseId),
      weekday: Value(weekday),
      startSection: Value(startSection),
      endSection: Value(endSection),
      weekStart: Value(weekStart),
      weekEnd: Value(weekEnd),
      weekParity: weekParity == null && nullToAbsent
          ? const Value.absent()
          : Value(weekParity),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ClassSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassSession(
      id: serializer.fromJson<int>(json['id']),
      courseId: serializer.fromJson<int>(json['courseId']),
      weekday: serializer.fromJson<int>(json['weekday']),
      startSection: serializer.fromJson<int>(json['startSection']),
      endSection: serializer.fromJson<int>(json['endSection']),
      weekStart: serializer.fromJson<int>(json['weekStart']),
      weekEnd: serializer.fromJson<int>(json['weekEnd']),
      weekParity: serializer.fromJson<String?>(json['weekParity']),
      location: serializer.fromJson<String?>(json['location']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'courseId': serializer.toJson<int>(courseId),
      'weekday': serializer.toJson<int>(weekday),
      'startSection': serializer.toJson<int>(startSection),
      'endSection': serializer.toJson<int>(endSection),
      'weekStart': serializer.toJson<int>(weekStart),
      'weekEnd': serializer.toJson<int>(weekEnd),
      'weekParity': serializer.toJson<String?>(weekParity),
      'location': serializer.toJson<String?>(location),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ClassSession copyWith({
    int? id,
    int? courseId,
    int? weekday,
    int? startSection,
    int? endSection,
    int? weekStart,
    int? weekEnd,
    Value<String?> weekParity = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ClassSession(
    id: id ?? this.id,
    courseId: courseId ?? this.courseId,
    weekday: weekday ?? this.weekday,
    startSection: startSection ?? this.startSection,
    endSection: endSection ?? this.endSection,
    weekStart: weekStart ?? this.weekStart,
    weekEnd: weekEnd ?? this.weekEnd,
    weekParity: weekParity.present ? weekParity.value : this.weekParity,
    location: location.present ? location.value : this.location,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ClassSession copyWithCompanion(ClassSessionsCompanion data) {
    return ClassSession(
      id: data.id.present ? data.id.value : this.id,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      startSection: data.startSection.present
          ? data.startSection.value
          : this.startSection,
      endSection: data.endSection.present
          ? data.endSection.value
          : this.endSection,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      weekEnd: data.weekEnd.present ? data.weekEnd.value : this.weekEnd,
      weekParity: data.weekParity.present
          ? data.weekParity.value
          : this.weekParity,
      location: data.location.present ? data.location.value : this.location,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassSession(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('weekday: $weekday, ')
          ..write('startSection: $startSection, ')
          ..write('endSection: $endSection, ')
          ..write('weekStart: $weekStart, ')
          ..write('weekEnd: $weekEnd, ')
          ..write('weekParity: $weekParity, ')
          ..write('location: $location, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    courseId,
    weekday,
    startSection,
    endSection,
    weekStart,
    weekEnd,
    weekParity,
    location,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassSession &&
          other.id == this.id &&
          other.courseId == this.courseId &&
          other.weekday == this.weekday &&
          other.startSection == this.startSection &&
          other.endSection == this.endSection &&
          other.weekStart == this.weekStart &&
          other.weekEnd == this.weekEnd &&
          other.weekParity == this.weekParity &&
          other.location == this.location &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ClassSessionsCompanion extends UpdateCompanion<ClassSession> {
  final Value<int> id;
  final Value<int> courseId;
  final Value<int> weekday;
  final Value<int> startSection;
  final Value<int> endSection;
  final Value<int> weekStart;
  final Value<int> weekEnd;
  final Value<String?> weekParity;
  final Value<String?> location;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ClassSessionsCompanion({
    this.id = const Value.absent(),
    this.courseId = const Value.absent(),
    this.weekday = const Value.absent(),
    this.startSection = const Value.absent(),
    this.endSection = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.weekEnd = const Value.absent(),
    this.weekParity = const Value.absent(),
    this.location = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ClassSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int courseId,
    required int weekday,
    required int startSection,
    required int endSection,
    required int weekStart,
    required int weekEnd,
    this.weekParity = const Value.absent(),
    this.location = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : courseId = Value(courseId),
       weekday = Value(weekday),
       startSection = Value(startSection),
       endSection = Value(endSection),
       weekStart = Value(weekStart),
       weekEnd = Value(weekEnd);
  static Insertable<ClassSession> custom({
    Expression<int>? id,
    Expression<int>? courseId,
    Expression<int>? weekday,
    Expression<int>? startSection,
    Expression<int>? endSection,
    Expression<int>? weekStart,
    Expression<int>? weekEnd,
    Expression<String>? weekParity,
    Expression<String>? location,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (weekday != null) 'weekday': weekday,
      if (startSection != null) 'start_section': startSection,
      if (endSection != null) 'end_section': endSection,
      if (weekStart != null) 'week_start': weekStart,
      if (weekEnd != null) 'week_end': weekEnd,
      if (weekParity != null) 'week_parity': weekParity,
      if (location != null) 'location': location,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ClassSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? courseId,
    Value<int>? weekday,
    Value<int>? startSection,
    Value<int>? endSection,
    Value<int>? weekStart,
    Value<int>? weekEnd,
    Value<String?>? weekParity,
    Value<String?>? location,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ClassSessionsCompanion(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      weekday: weekday ?? this.weekday,
      startSection: startSection ?? this.startSection,
      endSection: endSection ?? this.endSection,
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      weekParity: weekParity ?? this.weekParity,
      location: location ?? this.location,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<int>(courseId.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (startSection.present) {
      map['start_section'] = Variable<int>(startSection.value);
    }
    if (endSection.present) {
      map['end_section'] = Variable<int>(endSection.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<int>(weekStart.value);
    }
    if (weekEnd.present) {
      map['week_end'] = Variable<int>(weekEnd.value);
    }
    if (weekParity.present) {
      map['week_parity'] = Variable<String>(weekParity.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassSessionsCompanion(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('weekday: $weekday, ')
          ..write('startSection: $startSection, ')
          ..write('endSection: $endSection, ')
          ..write('weekStart: $weekStart, ')
          ..write('weekEnd: $weekEnd, ')
          ..write('weekParity: $weekParity, ')
          ..write('location: $location, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MergeConflictsTable extends MergeConflicts
    with TableInfo<$MergeConflictsTable, MergeConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MergeConflictsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES timetable_plans (id)',
    ),
  );
  static const VerificationMeta _importBatchIdMeta = const VerificationMeta(
    'importBatchId',
  );
  @override
  late final GeneratedColumn<int> importBatchId = GeneratedColumn<int>(
    'import_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id)',
    ),
  );
  static const VerificationMeta _currentRecordIdMeta = const VerificationMeta(
    'currentRecordId',
  );
  @override
  late final GeneratedColumn<int> currentRecordId = GeneratedColumn<int>(
    'current_record_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source_records (id)',
    ),
  );
  static const VerificationMeta _incomingRecordIdMeta = const VerificationMeta(
    'incomingRecordId',
  );
  @override
  late final GeneratedColumn<int> incomingRecordId = GeneratedColumn<int>(
    'incoming_record_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source_records (id)',
    ),
  );
  static const VerificationMeta _conflictTypeMeta = const VerificationMeta(
    'conflictType',
  );
  @override
  late final GeneratedColumn<String> conflictType = GeneratedColumn<String>(
    'conflict_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _resolutionJsonMeta = const VerificationMeta(
    'resolutionJson',
  );
  @override
  late final GeneratedColumn<String> resolutionJson = GeneratedColumn<String>(
    'resolution_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    importBatchId,
    currentRecordId,
    incomingRecordId,
    conflictType,
    status,
    resolutionJson,
    createdAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merge_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<MergeConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('import_batch_id')) {
      context.handle(
        _importBatchIdMeta,
        importBatchId.isAcceptableOrUnknown(
          data['import_batch_id']!,
          _importBatchIdMeta,
        ),
      );
    }
    if (data.containsKey('current_record_id')) {
      context.handle(
        _currentRecordIdMeta,
        currentRecordId.isAcceptableOrUnknown(
          data['current_record_id']!,
          _currentRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('incoming_record_id')) {
      context.handle(
        _incomingRecordIdMeta,
        incomingRecordId.isAcceptableOrUnknown(
          data['incoming_record_id']!,
          _incomingRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('conflict_type')) {
      context.handle(
        _conflictTypeMeta,
        conflictType.isAcceptableOrUnknown(
          data['conflict_type']!,
          _conflictTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conflictTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('resolution_json')) {
      context.handle(
        _resolutionJsonMeta,
        resolutionJson.isAcceptableOrUnknown(
          data['resolution_json']!,
          _resolutionJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MergeConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MergeConflict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      importBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_batch_id'],
      ),
      currentRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_record_id'],
      ),
      incomingRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}incoming_record_id'],
      ),
      conflictType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      resolutionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $MergeConflictsTable createAlias(String alias) {
    return $MergeConflictsTable(attachedDatabase, alias);
  }
}

class MergeConflict extends DataClass implements Insertable<MergeConflict> {
  final int id;
  final int planId;
  final int? importBatchId;
  final int? currentRecordId;
  final int? incomingRecordId;
  final String conflictType;
  final String status;
  final String? resolutionJson;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  const MergeConflict({
    required this.id,
    required this.planId,
    this.importBatchId,
    this.currentRecordId,
    this.incomingRecordId,
    required this.conflictType,
    required this.status,
    this.resolutionJson,
    required this.createdAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<int>(planId);
    if (!nullToAbsent || importBatchId != null) {
      map['import_batch_id'] = Variable<int>(importBatchId);
    }
    if (!nullToAbsent || currentRecordId != null) {
      map['current_record_id'] = Variable<int>(currentRecordId);
    }
    if (!nullToAbsent || incomingRecordId != null) {
      map['incoming_record_id'] = Variable<int>(incomingRecordId);
    }
    map['conflict_type'] = Variable<String>(conflictType);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || resolutionJson != null) {
      map['resolution_json'] = Variable<String>(resolutionJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  MergeConflictsCompanion toCompanion(bool nullToAbsent) {
    return MergeConflictsCompanion(
      id: Value(id),
      planId: Value(planId),
      importBatchId: importBatchId == null && nullToAbsent
          ? const Value.absent()
          : Value(importBatchId),
      currentRecordId: currentRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentRecordId),
      incomingRecordId: incomingRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(incomingRecordId),
      conflictType: Value(conflictType),
      status: Value(status),
      resolutionJson: resolutionJson == null && nullToAbsent
          ? const Value.absent()
          : Value(resolutionJson),
      createdAt: Value(createdAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory MergeConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MergeConflict(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int>(json['planId']),
      importBatchId: serializer.fromJson<int?>(json['importBatchId']),
      currentRecordId: serializer.fromJson<int?>(json['currentRecordId']),
      incomingRecordId: serializer.fromJson<int?>(json['incomingRecordId']),
      conflictType: serializer.fromJson<String>(json['conflictType']),
      status: serializer.fromJson<String>(json['status']),
      resolutionJson: serializer.fromJson<String?>(json['resolutionJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int>(planId),
      'importBatchId': serializer.toJson<int?>(importBatchId),
      'currentRecordId': serializer.toJson<int?>(currentRecordId),
      'incomingRecordId': serializer.toJson<int?>(incomingRecordId),
      'conflictType': serializer.toJson<String>(conflictType),
      'status': serializer.toJson<String>(status),
      'resolutionJson': serializer.toJson<String?>(resolutionJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  MergeConflict copyWith({
    int? id,
    int? planId,
    Value<int?> importBatchId = const Value.absent(),
    Value<int?> currentRecordId = const Value.absent(),
    Value<int?> incomingRecordId = const Value.absent(),
    String? conflictType,
    String? status,
    Value<String?> resolutionJson = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => MergeConflict(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    importBatchId: importBatchId.present
        ? importBatchId.value
        : this.importBatchId,
    currentRecordId: currentRecordId.present
        ? currentRecordId.value
        : this.currentRecordId,
    incomingRecordId: incomingRecordId.present
        ? incomingRecordId.value
        : this.incomingRecordId,
    conflictType: conflictType ?? this.conflictType,
    status: status ?? this.status,
    resolutionJson: resolutionJson.present
        ? resolutionJson.value
        : this.resolutionJson,
    createdAt: createdAt ?? this.createdAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  MergeConflict copyWithCompanion(MergeConflictsCompanion data) {
    return MergeConflict(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      importBatchId: data.importBatchId.present
          ? data.importBatchId.value
          : this.importBatchId,
      currentRecordId: data.currentRecordId.present
          ? data.currentRecordId.value
          : this.currentRecordId,
      incomingRecordId: data.incomingRecordId.present
          ? data.incomingRecordId.value
          : this.incomingRecordId,
      conflictType: data.conflictType.present
          ? data.conflictType.value
          : this.conflictType,
      status: data.status.present ? data.status.value : this.status,
      resolutionJson: data.resolutionJson.present
          ? data.resolutionJson.value
          : this.resolutionJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MergeConflict(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('currentRecordId: $currentRecordId, ')
          ..write('incomingRecordId: $incomingRecordId, ')
          ..write('conflictType: $conflictType, ')
          ..write('status: $status, ')
          ..write('resolutionJson: $resolutionJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    importBatchId,
    currentRecordId,
    incomingRecordId,
    conflictType,
    status,
    resolutionJson,
    createdAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MergeConflict &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.importBatchId == this.importBatchId &&
          other.currentRecordId == this.currentRecordId &&
          other.incomingRecordId == this.incomingRecordId &&
          other.conflictType == this.conflictType &&
          other.status == this.status &&
          other.resolutionJson == this.resolutionJson &&
          other.createdAt == this.createdAt &&
          other.resolvedAt == this.resolvedAt);
}

class MergeConflictsCompanion extends UpdateCompanion<MergeConflict> {
  final Value<int> id;
  final Value<int> planId;
  final Value<int?> importBatchId;
  final Value<int?> currentRecordId;
  final Value<int?> incomingRecordId;
  final Value<String> conflictType;
  final Value<String> status;
  final Value<String?> resolutionJson;
  final Value<DateTime> createdAt;
  final Value<DateTime?> resolvedAt;
  const MergeConflictsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.currentRecordId = const Value.absent(),
    this.incomingRecordId = const Value.absent(),
    this.conflictType = const Value.absent(),
    this.status = const Value.absent(),
    this.resolutionJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
  });
  MergeConflictsCompanion.insert({
    this.id = const Value.absent(),
    required int planId,
    this.importBatchId = const Value.absent(),
    this.currentRecordId = const Value.absent(),
    this.incomingRecordId = const Value.absent(),
    required String conflictType,
    this.status = const Value.absent(),
    this.resolutionJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
  }) : planId = Value(planId),
       conflictType = Value(conflictType);
  static Insertable<MergeConflict> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<int>? importBatchId,
    Expression<int>? currentRecordId,
    Expression<int>? incomingRecordId,
    Expression<String>? conflictType,
    Expression<String>? status,
    Expression<String>? resolutionJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? resolvedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (importBatchId != null) 'import_batch_id': importBatchId,
      if (currentRecordId != null) 'current_record_id': currentRecordId,
      if (incomingRecordId != null) 'incoming_record_id': incomingRecordId,
      if (conflictType != null) 'conflict_type': conflictType,
      if (status != null) 'status': status,
      if (resolutionJson != null) 'resolution_json': resolutionJson,
      if (createdAt != null) 'created_at': createdAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
    });
  }

  MergeConflictsCompanion copyWith({
    Value<int>? id,
    Value<int>? planId,
    Value<int?>? importBatchId,
    Value<int?>? currentRecordId,
    Value<int?>? incomingRecordId,
    Value<String>? conflictType,
    Value<String>? status,
    Value<String?>? resolutionJson,
    Value<DateTime>? createdAt,
    Value<DateTime?>? resolvedAt,
  }) {
    return MergeConflictsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      importBatchId: importBatchId ?? this.importBatchId,
      currentRecordId: currentRecordId ?? this.currentRecordId,
      incomingRecordId: incomingRecordId ?? this.incomingRecordId,
      conflictType: conflictType ?? this.conflictType,
      status: status ?? this.status,
      resolutionJson: resolutionJson ?? this.resolutionJson,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (importBatchId.present) {
      map['import_batch_id'] = Variable<int>(importBatchId.value);
    }
    if (currentRecordId.present) {
      map['current_record_id'] = Variable<int>(currentRecordId.value);
    }
    if (incomingRecordId.present) {
      map['incoming_record_id'] = Variable<int>(incomingRecordId.value);
    }
    if (conflictType.present) {
      map['conflict_type'] = Variable<String>(conflictType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (resolutionJson.present) {
      map['resolution_json'] = Variable<String>(resolutionJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MergeConflictsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('currentRecordId: $currentRecordId, ')
          ..write('incomingRecordId: $incomingRecordId, ')
          ..write('conflictType: $conflictType, ')
          ..write('status: $status, ')
          ..write('resolutionJson: $resolutionJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }
}

class $ReminderRulesTable extends ReminderRules
    with TableInfo<$ReminderRulesTable, ReminderRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderRulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES timetable_plans (id)',
    ),
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<int> courseId = GeneratedColumn<int>(
    'course_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES courses (id)',
    ),
  );
  static const VerificationMeta _minutesBeforeMeta = const VerificationMeta(
    'minutesBefore',
  );
  @override
  late final GeneratedColumn<int> minutesBefore = GeneratedColumn<int>(
    'minutes_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    courseId,
    minutesBefore,
    enabled,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    }
    if (data.containsKey('minutes_before')) {
      context.handle(
        _minutesBeforeMeta,
        minutesBefore.isAcceptableOrUnknown(
          data['minutes_before']!,
          _minutesBeforeMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      ),
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}course_id'],
      ),
      minutesBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes_before'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReminderRulesTable createAlias(String alias) {
    return $ReminderRulesTable(attachedDatabase, alias);
  }
}

class ReminderRule extends DataClass implements Insertable<ReminderRule> {
  final int id;
  final int? planId;
  final int? courseId;
  final int minutesBefore;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ReminderRule({
    required this.id,
    this.planId,
    this.courseId,
    required this.minutesBefore,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<int>(planId);
    }
    if (!nullToAbsent || courseId != null) {
      map['course_id'] = Variable<int>(courseId);
    }
    map['minutes_before'] = Variable<int>(minutesBefore);
    map['enabled'] = Variable<bool>(enabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReminderRulesCompanion toCompanion(bool nullToAbsent) {
    return ReminderRulesCompanion(
      id: Value(id),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
      courseId: courseId == null && nullToAbsent
          ? const Value.absent()
          : Value(courseId),
      minutesBefore: Value(minutesBefore),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReminderRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRule(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int?>(json['planId']),
      courseId: serializer.fromJson<int?>(json['courseId']),
      minutesBefore: serializer.fromJson<int>(json['minutesBefore']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int?>(planId),
      'courseId': serializer.toJson<int?>(courseId),
      'minutesBefore': serializer.toJson<int>(minutesBefore),
      'enabled': serializer.toJson<bool>(enabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReminderRule copyWith({
    int? id,
    Value<int?> planId = const Value.absent(),
    Value<int?> courseId = const Value.absent(),
    int? minutesBefore,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ReminderRule(
    id: id ?? this.id,
    planId: planId.present ? planId.value : this.planId,
    courseId: courseId.present ? courseId.value : this.courseId,
    minutesBefore: minutesBefore ?? this.minutesBefore,
    enabled: enabled ?? this.enabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReminderRule copyWithCompanion(ReminderRulesCompanion data) {
    return ReminderRule(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      minutesBefore: data.minutesBefore.present
          ? data.minutesBefore.value
          : this.minutesBefore,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRule(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('courseId: $courseId, ')
          ..write('minutesBefore: $minutesBefore, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    courseId,
    minutesBefore,
    enabled,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRule &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.courseId == this.courseId &&
          other.minutesBefore == this.minutesBefore &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ReminderRulesCompanion extends UpdateCompanion<ReminderRule> {
  final Value<int> id;
  final Value<int?> planId;
  final Value<int?> courseId;
  final Value<int> minutesBefore;
  final Value<bool> enabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ReminderRulesCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.courseId = const Value.absent(),
    this.minutesBefore = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReminderRulesCompanion.insert({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.courseId = const Value.absent(),
    this.minutesBefore = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<ReminderRule> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<int>? courseId,
    Expression<int>? minutesBefore,
    Expression<bool>? enabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (courseId != null) 'course_id': courseId,
      if (minutesBefore != null) 'minutes_before': minutesBefore,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReminderRulesCompanion copyWith({
    Value<int>? id,
    Value<int?>? planId,
    Value<int?>? courseId,
    Value<int>? minutesBefore,
    Value<bool>? enabled,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ReminderRulesCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      courseId: courseId ?? this.courseId,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<int>(courseId.value);
    }
    if (minutesBefore.present) {
      map['minutes_before'] = Variable<int>(minutesBefore.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRulesCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('courseId: $courseId, ')
          ..write('minutesBefore: $minutesBefore, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SemestersTable semesters = $SemestersTable(this);
  late final $TimetablePlansTable timetablePlans = $TimetablePlansTable(this);
  late final $ImportBatchesTable importBatches = $ImportBatchesTable(this);
  late final $SourceRecordsTable sourceRecords = $SourceRecordsTable(this);
  late final $CoursesTable courses = $CoursesTable(this);
  late final $ClassSessionsTable classSessions = $ClassSessionsTable(this);
  late final $MergeConflictsTable mergeConflicts = $MergeConflictsTable(this);
  late final $ReminderRulesTable reminderRules = $ReminderRulesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    semesters,
    timetablePlans,
    importBatches,
    sourceRecords,
    courses,
    classSessions,
    mergeConflicts,
    reminderRules,
  ];
}

typedef $$SemestersTableCreateCompanionBuilder =
    SemestersCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> nameManuallyEdited,
      required DateTime firstWeekMonday,
      Value<DateTime?> endDate,
      Value<String?> sessionTemplateJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$SemestersTableUpdateCompanionBuilder =
    SemestersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> nameManuallyEdited,
      Value<DateTime> firstWeekMonday,
      Value<DateTime?> endDate,
      Value<String?> sessionTemplateJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$SemestersTableReferences
    extends BaseReferences<_$AppDatabase, $SemestersTable, Semester> {
  $$SemestersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TimetablePlansTable, List<TimetablePlan>>
  _timetablePlansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timetablePlans,
    aliasName: $_aliasNameGenerator(
      db.semesters.id,
      db.timetablePlans.semesterId,
    ),
  );

  $$TimetablePlansTableProcessedTableManager get timetablePlansRefs {
    final manager = $$TimetablePlansTableTableManager(
      $_db,
      $_db.timetablePlans,
    ).filter((f) => f.semesterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_timetablePlansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SemestersTableFilterComposer
    extends Composer<_$AppDatabase, $SemestersTable> {
  $$SemestersTableFilterComposer({
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

  ColumnFilters<bool> get nameManuallyEdited => $composableBuilder(
    column: $table.nameManuallyEdited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstWeekMonday => $composableBuilder(
    column: $table.firstWeekMonday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionTemplateJson => $composableBuilder(
    column: $table.sessionTemplateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> timetablePlansRefs(
    Expression<bool> Function($$TimetablePlansTableFilterComposer f) f,
  ) {
    final $$TimetablePlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetablePlans,
      getReferencedColumn: (t) => t.semesterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablePlansTableFilterComposer(
            $db: $db,
            $table: $db.timetablePlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SemestersTableOrderingComposer
    extends Composer<_$AppDatabase, $SemestersTable> {
  $$SemestersTableOrderingComposer({
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

  ColumnOrderings<bool> get nameManuallyEdited => $composableBuilder(
    column: $table.nameManuallyEdited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstWeekMonday => $composableBuilder(
    column: $table.firstWeekMonday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionTemplateJson => $composableBuilder(
    column: $table.sessionTemplateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SemestersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SemestersTable> {
  $$SemestersTableAnnotationComposer({
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

  GeneratedColumn<bool> get nameManuallyEdited => $composableBuilder(
    column: $table.nameManuallyEdited,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstWeekMonday => $composableBuilder(
    column: $table.firstWeekMonday,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get sessionTemplateJson => $composableBuilder(
    column: $table.sessionTemplateJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> timetablePlansRefs<T extends Object>(
    Expression<T> Function($$TimetablePlansTableAnnotationComposer a) f,
  ) {
    final $$TimetablePlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetablePlans,
      getReferencedColumn: (t) => t.semesterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablePlansTableAnnotationComposer(
            $db: $db,
            $table: $db.timetablePlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SemestersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SemestersTable,
          Semester,
          $$SemestersTableFilterComposer,
          $$SemestersTableOrderingComposer,
          $$SemestersTableAnnotationComposer,
          $$SemestersTableCreateCompanionBuilder,
          $$SemestersTableUpdateCompanionBuilder,
          (Semester, $$SemestersTableReferences),
          Semester,
          PrefetchHooks Function({bool timetablePlansRefs})
        > {
  $$SemestersTableTableManager(_$AppDatabase db, $SemestersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SemestersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SemestersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SemestersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> nameManuallyEdited = const Value.absent(),
                Value<DateTime> firstWeekMonday = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> sessionTemplateJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SemestersCompanion(
                id: id,
                name: name,
                nameManuallyEdited: nameManuallyEdited,
                firstWeekMonday: firstWeekMonday,
                endDate: endDate,
                sessionTemplateJson: sessionTemplateJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> nameManuallyEdited = const Value.absent(),
                required DateTime firstWeekMonday,
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> sessionTemplateJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SemestersCompanion.insert(
                id: id,
                name: name,
                nameManuallyEdited: nameManuallyEdited,
                firstWeekMonday: firstWeekMonday,
                endDate: endDate,
                sessionTemplateJson: sessionTemplateJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SemestersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({timetablePlansRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (timetablePlansRefs) db.timetablePlans,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (timetablePlansRefs)
                    await $_getPrefetchedData<
                      Semester,
                      $SemestersTable,
                      TimetablePlan
                    >(
                      currentTable: table,
                      referencedTable: $$SemestersTableReferences
                          ._timetablePlansRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SemestersTableReferences(
                            db,
                            table,
                            p0,
                          ).timetablePlansRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.semesterId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SemestersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SemestersTable,
      Semester,
      $$SemestersTableFilterComposer,
      $$SemestersTableOrderingComposer,
      $$SemestersTableAnnotationComposer,
      $$SemestersTableCreateCompanionBuilder,
      $$SemestersTableUpdateCompanionBuilder,
      (Semester, $$SemestersTableReferences),
      Semester,
      PrefetchHooks Function({bool timetablePlansRefs})
    >;
typedef $$TimetablePlansTableCreateCompanionBuilder =
    TimetablePlansCompanion Function({
      Value<int> id,
      required int semesterId,
      required String name,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TimetablePlansTableUpdateCompanionBuilder =
    TimetablePlansCompanion Function({
      Value<int> id,
      Value<int> semesterId,
      Value<String> name,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TimetablePlansTableReferences
    extends BaseReferences<_$AppDatabase, $TimetablePlansTable, TimetablePlan> {
  $$TimetablePlansTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SemestersTable _semesterIdTable(_$AppDatabase db) =>
      db.semesters.createAlias(
        $_aliasNameGenerator(db.timetablePlans.semesterId, db.semesters.id),
      );

  $$SemestersTableProcessedTableManager get semesterId {
    final $_column = $_itemColumn<int>('semester_id')!;

    final manager = $$SemestersTableTableManager(
      $_db,
      $_db.semesters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_semesterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CoursesTable, List<Course>> _coursesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.courses,
    aliasName: $_aliasNameGenerator(db.timetablePlans.id, db.courses.planId),
  );

  $$CoursesTableProcessedTableManager get coursesRefs {
    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_coursesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MergeConflictsTable, List<MergeConflict>>
  _mergeConflictsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mergeConflicts,
    aliasName: $_aliasNameGenerator(
      db.timetablePlans.id,
      db.mergeConflicts.planId,
    ),
  );

  $$MergeConflictsTableProcessedTableManager get mergeConflictsRefs {
    final manager = $$MergeConflictsTableTableManager(
      $_db,
      $_db.mergeConflicts,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mergeConflictsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReminderRulesTable, List<ReminderRule>>
  _reminderRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderRules,
    aliasName: $_aliasNameGenerator(
      db.timetablePlans.id,
      db.reminderRules.planId,
    ),
  );

  $$ReminderRulesTableProcessedTableManager get reminderRulesRefs {
    final manager = $$ReminderRulesTableTableManager(
      $_db,
      $_db.reminderRules,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TimetablePlansTableFilterComposer
    extends Composer<_$AppDatabase, $TimetablePlansTable> {
  $$TimetablePlansTableFilterComposer({
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

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SemestersTableFilterComposer get semesterId {
    final $$SemestersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.semesterId,
      referencedTable: $db.semesters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SemestersTableFilterComposer(
            $db: $db,
            $table: $db.semesters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> coursesRefs(
    Expression<bool> Function($$CoursesTableFilterComposer f) f,
  ) {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mergeConflictsRefs(
    Expression<bool> Function($$MergeConflictsTableFilterComposer f) f,
  ) {
    final $$MergeConflictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mergeConflicts,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MergeConflictsTableFilterComposer(
            $db: $db,
            $table: $db.mergeConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reminderRulesRefs(
    Expression<bool> Function($$ReminderRulesTableFilterComposer f) f,
  ) {
    final $$ReminderRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableFilterComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimetablePlansTableOrderingComposer
    extends Composer<_$AppDatabase, $TimetablePlansTable> {
  $$TimetablePlansTableOrderingComposer({
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

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SemestersTableOrderingComposer get semesterId {
    final $$SemestersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.semesterId,
      referencedTable: $db.semesters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SemestersTableOrderingComposer(
            $db: $db,
            $table: $db.semesters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimetablePlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimetablePlansTable> {
  $$TimetablePlansTableAnnotationComposer({
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

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SemestersTableAnnotationComposer get semesterId {
    final $$SemestersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.semesterId,
      referencedTable: $db.semesters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SemestersTableAnnotationComposer(
            $db: $db,
            $table: $db.semesters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> coursesRefs<T extends Object>(
    Expression<T> Function($$CoursesTableAnnotationComposer a) f,
  ) {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mergeConflictsRefs<T extends Object>(
    Expression<T> Function($$MergeConflictsTableAnnotationComposer a) f,
  ) {
    final $$MergeConflictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mergeConflicts,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MergeConflictsTableAnnotationComposer(
            $db: $db,
            $table: $db.mergeConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reminderRulesRefs<T extends Object>(
    Expression<T> Function($$ReminderRulesTableAnnotationComposer a) f,
  ) {
    final $$ReminderRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimetablePlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimetablePlansTable,
          TimetablePlan,
          $$TimetablePlansTableFilterComposer,
          $$TimetablePlansTableOrderingComposer,
          $$TimetablePlansTableAnnotationComposer,
          $$TimetablePlansTableCreateCompanionBuilder,
          $$TimetablePlansTableUpdateCompanionBuilder,
          (TimetablePlan, $$TimetablePlansTableReferences),
          TimetablePlan,
          PrefetchHooks Function({
            bool semesterId,
            bool coursesRefs,
            bool mergeConflictsRefs,
            bool reminderRulesRefs,
          })
        > {
  $$TimetablePlansTableTableManager(
    _$AppDatabase db,
    $TimetablePlansTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimetablePlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimetablePlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimetablePlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> semesterId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TimetablePlansCompanion(
                id: id,
                semesterId: semesterId,
                name: name,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int semesterId,
                required String name,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TimetablePlansCompanion.insert(
                id: id,
                semesterId: semesterId,
                name: name,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimetablePlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                semesterId = false,
                coursesRefs = false,
                mergeConflictsRefs = false,
                reminderRulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (coursesRefs) db.courses,
                    if (mergeConflictsRefs) db.mergeConflicts,
                    if (reminderRulesRefs) db.reminderRules,
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
                        if (semesterId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.semesterId,
                                    referencedTable:
                                        $$TimetablePlansTableReferences
                                            ._semesterIdTable(db),
                                    referencedColumn:
                                        $$TimetablePlansTableReferences
                                            ._semesterIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (coursesRefs)
                        await $_getPrefetchedData<
                          TimetablePlan,
                          $TimetablePlansTable,
                          Course
                        >(
                          currentTable: table,
                          referencedTable: $$TimetablePlansTableReferences
                              ._coursesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TimetablePlansTableReferences(
                                db,
                                table,
                                p0,
                              ).coursesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mergeConflictsRefs)
                        await $_getPrefetchedData<
                          TimetablePlan,
                          $TimetablePlansTable,
                          MergeConflict
                        >(
                          currentTable: table,
                          referencedTable: $$TimetablePlansTableReferences
                              ._mergeConflictsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TimetablePlansTableReferences(
                                db,
                                table,
                                p0,
                              ).mergeConflictsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reminderRulesRefs)
                        await $_getPrefetchedData<
                          TimetablePlan,
                          $TimetablePlansTable,
                          ReminderRule
                        >(
                          currentTable: table,
                          referencedTable: $$TimetablePlansTableReferences
                              ._reminderRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TimetablePlansTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TimetablePlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimetablePlansTable,
      TimetablePlan,
      $$TimetablePlansTableFilterComposer,
      $$TimetablePlansTableOrderingComposer,
      $$TimetablePlansTableAnnotationComposer,
      $$TimetablePlansTableCreateCompanionBuilder,
      $$TimetablePlansTableUpdateCompanionBuilder,
      (TimetablePlan, $$TimetablePlansTableReferences),
      TimetablePlan,
      PrefetchHooks Function({
        bool semesterId,
        bool coursesRefs,
        bool mergeConflictsRefs,
        bool reminderRulesRefs,
      })
    >;
typedef $$ImportBatchesTableCreateCompanionBuilder =
    ImportBatchesCompanion Function({
      Value<int> id,
      required String sourceName,
      required String fileType,
      Value<DateTime> importedAt,
      Value<String?> summaryJson,
    });
typedef $$ImportBatchesTableUpdateCompanionBuilder =
    ImportBatchesCompanion Function({
      Value<int> id,
      Value<String> sourceName,
      Value<String> fileType,
      Value<DateTime> importedAt,
      Value<String?> summaryJson,
    });

final class $$ImportBatchesTableReferences
    extends BaseReferences<_$AppDatabase, $ImportBatchesTable, ImportBatche> {
  $$ImportBatchesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SourceRecordsTable, List<SourceRecord>>
  _sourceRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sourceRecords,
    aliasName: $_aliasNameGenerator(
      db.importBatches.id,
      db.sourceRecords.importBatchId,
    ),
  );

  $$SourceRecordsTableProcessedTableManager get sourceRecordsRefs {
    final manager = $$SourceRecordsTableTableManager(
      $_db,
      $_db.sourceRecords,
    ).filter((f) => f.importBatchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sourceRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MergeConflictsTable, List<MergeConflict>>
  _mergeConflictsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mergeConflicts,
    aliasName: $_aliasNameGenerator(
      db.importBatches.id,
      db.mergeConflicts.importBatchId,
    ),
  );

  $$MergeConflictsTableProcessedTableManager get mergeConflictsRefs {
    final manager = $$MergeConflictsTableTableManager(
      $_db,
      $_db.mergeConflicts,
    ).filter((f) => f.importBatchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mergeConflictsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImportBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableFilterComposer({
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

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sourceRecordsRefs(
    Expression<bool> Function($$SourceRecordsTableFilterComposer f) f,
  ) {
    final $$SourceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sourceRecords,
      getReferencedColumn: (t) => t.importBatchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.sourceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mergeConflictsRefs(
    Expression<bool> Function($$MergeConflictsTableFilterComposer f) f,
  ) {
    final $$MergeConflictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mergeConflicts,
      getReferencedColumn: (t) => t.importBatchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MergeConflictsTableFilterComposer(
            $db: $db,
            $table: $db.mergeConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableOrderingComposer({
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

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => column,
  );

  Expression<T> sourceRecordsRefs<T extends Object>(
    Expression<T> Function($$SourceRecordsTableAnnotationComposer a) f,
  ) {
    final $$SourceRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sourceRecords,
      getReferencedColumn: (t) => t.importBatchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mergeConflictsRefs<T extends Object>(
    Expression<T> Function($$MergeConflictsTableAnnotationComposer a) f,
  ) {
    final $$MergeConflictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mergeConflicts,
      getReferencedColumn: (t) => t.importBatchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MergeConflictsTableAnnotationComposer(
            $db: $db,
            $table: $db.mergeConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportBatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportBatchesTable,
          ImportBatche,
          $$ImportBatchesTableFilterComposer,
          $$ImportBatchesTableOrderingComposer,
          $$ImportBatchesTableAnnotationComposer,
          $$ImportBatchesTableCreateCompanionBuilder,
          $$ImportBatchesTableUpdateCompanionBuilder,
          (ImportBatche, $$ImportBatchesTableReferences),
          ImportBatche,
          PrefetchHooks Function({
            bool sourceRecordsRefs,
            bool mergeConflictsRefs,
          })
        > {
  $$ImportBatchesTableTableManager(_$AppDatabase db, $ImportBatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sourceName = const Value.absent(),
                Value<String> fileType = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<String?> summaryJson = const Value.absent(),
              }) => ImportBatchesCompanion(
                id: id,
                sourceName: sourceName,
                fileType: fileType,
                importedAt: importedAt,
                summaryJson: summaryJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sourceName,
                required String fileType,
                Value<DateTime> importedAt = const Value.absent(),
                Value<String?> summaryJson = const Value.absent(),
              }) => ImportBatchesCompanion.insert(
                id: id,
                sourceName: sourceName,
                fileType: fileType,
                importedAt: importedAt,
                summaryJson: summaryJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportBatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sourceRecordsRefs = false, mergeConflictsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sourceRecordsRefs) db.sourceRecords,
                    if (mergeConflictsRefs) db.mergeConflicts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sourceRecordsRefs)
                        await $_getPrefetchedData<
                          ImportBatche,
                          $ImportBatchesTable,
                          SourceRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._sourceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).sourceRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importBatchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mergeConflictsRefs)
                        await $_getPrefetchedData<
                          ImportBatche,
                          $ImportBatchesTable,
                          MergeConflict
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._mergeConflictsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).mergeConflictsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importBatchId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ImportBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportBatchesTable,
      ImportBatche,
      $$ImportBatchesTableFilterComposer,
      $$ImportBatchesTableOrderingComposer,
      $$ImportBatchesTableAnnotationComposer,
      $$ImportBatchesTableCreateCompanionBuilder,
      $$ImportBatchesTableUpdateCompanionBuilder,
      (ImportBatche, $$ImportBatchesTableReferences),
      ImportBatche,
      PrefetchHooks Function({bool sourceRecordsRefs, bool mergeConflictsRefs})
    >;
typedef $$SourceRecordsTableCreateCompanionBuilder =
    SourceRecordsCompanion Function({
      Value<int> id,
      Value<int?> importBatchId,
      required String fingerprint,
      Value<String?> rawContent,
      Value<String?> normalizedJson,
      Value<DateTime> createdAt,
    });
typedef $$SourceRecordsTableUpdateCompanionBuilder =
    SourceRecordsCompanion Function({
      Value<int> id,
      Value<int?> importBatchId,
      Value<String> fingerprint,
      Value<String?> rawContent,
      Value<String?> normalizedJson,
      Value<DateTime> createdAt,
    });

final class $$SourceRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $SourceRecordsTable, SourceRecord> {
  $$SourceRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportBatchesTable _importBatchIdTable(_$AppDatabase db) =>
      db.importBatches.createAlias(
        $_aliasNameGenerator(
          db.sourceRecords.importBatchId,
          db.importBatches.id,
        ),
      );

  $$ImportBatchesTableProcessedTableManager? get importBatchId {
    final $_column = $_itemColumn<int>('import_batch_id');
    if ($_column == null) return null;
    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importBatchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CoursesTable, List<Course>> _coursesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.courses,
    aliasName: $_aliasNameGenerator(
      db.sourceRecords.id,
      db.courses.sourceRecordId,
    ),
  );

  $$CoursesTableProcessedTableManager get coursesRefs {
    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.sourceRecordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_coursesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MergeConflictsTable, List<MergeConflict>>
  _currentMergeConflictsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.mergeConflicts,
        aliasName: $_aliasNameGenerator(
          db.sourceRecords.id,
          db.mergeConflicts.currentRecordId,
        ),
      );

  $$MergeConflictsTableProcessedTableManager get currentMergeConflicts {
    final manager = $$MergeConflictsTableTableManager(
      $_db,
      $_db.mergeConflicts,
    ).filter((f) => f.currentRecordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _currentMergeConflictsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MergeConflictsTable, List<MergeConflict>>
  _incomingMergeConflictsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.mergeConflicts,
        aliasName: $_aliasNameGenerator(
          db.sourceRecords.id,
          db.mergeConflicts.incomingRecordId,
        ),
      );

  $$MergeConflictsTableProcessedTableManager get incomingMergeConflicts {
    final manager = $$MergeConflictsTableTableManager(
      $_db,
      $_db.mergeConflicts,
    ).filter((f) => f.incomingRecordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _incomingMergeConflictsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SourceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SourceRecordsTable> {
  $$SourceRecordsTableFilterComposer({
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

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawContent => $composableBuilder(
    column: $table.rawContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedJson => $composableBuilder(
    column: $table.normalizedJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportBatchesTableFilterComposer get importBatchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> coursesRefs(
    Expression<bool> Function($$CoursesTableFilterComposer f) f,
  ) {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.sourceRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> currentMergeConflicts(
    Expression<bool> Function($$MergeConflictsTableFilterComposer f) f,
  ) {
    final $$MergeConflictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mergeConflicts,
      getReferencedColumn: (t) => t.currentRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MergeConflictsTableFilterComposer(
            $db: $db,
            $table: $db.mergeConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incomingMergeConflicts(
    Expression<bool> Function($$MergeConflictsTableFilterComposer f) f,
  ) {
    final $$MergeConflictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mergeConflicts,
      getReferencedColumn: (t) => t.incomingRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MergeConflictsTableFilterComposer(
            $db: $db,
            $table: $db.mergeConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SourceRecordsTable> {
  $$SourceRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawContent => $composableBuilder(
    column: $table.rawContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedJson => $composableBuilder(
    column: $table.normalizedJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportBatchesTableOrderingComposer get importBatchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SourceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourceRecordsTable> {
  $$SourceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawContent => $composableBuilder(
    column: $table.rawContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedJson => $composableBuilder(
    column: $table.normalizedJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ImportBatchesTableAnnotationComposer get importBatchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> coursesRefs<T extends Object>(
    Expression<T> Function($$CoursesTableAnnotationComposer a) f,
  ) {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.sourceRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> currentMergeConflicts<T extends Object>(
    Expression<T> Function($$MergeConflictsTableAnnotationComposer a) f,
  ) {
    final $$MergeConflictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mergeConflicts,
      getReferencedColumn: (t) => t.currentRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MergeConflictsTableAnnotationComposer(
            $db: $db,
            $table: $db.mergeConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> incomingMergeConflicts<T extends Object>(
    Expression<T> Function($$MergeConflictsTableAnnotationComposer a) f,
  ) {
    final $$MergeConflictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mergeConflicts,
      getReferencedColumn: (t) => t.incomingRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MergeConflictsTableAnnotationComposer(
            $db: $db,
            $table: $db.mergeConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourceRecordsTable,
          SourceRecord,
          $$SourceRecordsTableFilterComposer,
          $$SourceRecordsTableOrderingComposer,
          $$SourceRecordsTableAnnotationComposer,
          $$SourceRecordsTableCreateCompanionBuilder,
          $$SourceRecordsTableUpdateCompanionBuilder,
          (SourceRecord, $$SourceRecordsTableReferences),
          SourceRecord,
          PrefetchHooks Function({
            bool importBatchId,
            bool coursesRefs,
            bool currentMergeConflicts,
            bool incomingMergeConflicts,
          })
        > {
  $$SourceRecordsTableTableManager(_$AppDatabase db, $SourceRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourceRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> importBatchId = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<String?> rawContent = const Value.absent(),
                Value<String?> normalizedJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SourceRecordsCompanion(
                id: id,
                importBatchId: importBatchId,
                fingerprint: fingerprint,
                rawContent: rawContent,
                normalizedJson: normalizedJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> importBatchId = const Value.absent(),
                required String fingerprint,
                Value<String?> rawContent = const Value.absent(),
                Value<String?> normalizedJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SourceRecordsCompanion.insert(
                id: id,
                importBatchId: importBatchId,
                fingerprint: fingerprint,
                rawContent: rawContent,
                normalizedJson: normalizedJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SourceRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                importBatchId = false,
                coursesRefs = false,
                currentMergeConflicts = false,
                incomingMergeConflicts = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (coursesRefs) db.courses,
                    if (currentMergeConflicts) db.mergeConflicts,
                    if (incomingMergeConflicts) db.mergeConflicts,
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
                        if (importBatchId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.importBatchId,
                                    referencedTable:
                                        $$SourceRecordsTableReferences
                                            ._importBatchIdTable(db),
                                    referencedColumn:
                                        $$SourceRecordsTableReferences
                                            ._importBatchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (coursesRefs)
                        await $_getPrefetchedData<
                          SourceRecord,
                          $SourceRecordsTable,
                          Course
                        >(
                          currentTable: table,
                          referencedTable: $$SourceRecordsTableReferences
                              ._coursesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourceRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).coursesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceRecordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (currentMergeConflicts)
                        await $_getPrefetchedData<
                          SourceRecord,
                          $SourceRecordsTable,
                          MergeConflict
                        >(
                          currentTable: table,
                          referencedTable: $$SourceRecordsTableReferences
                              ._currentMergeConflictsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourceRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).currentMergeConflicts,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.currentRecordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (incomingMergeConflicts)
                        await $_getPrefetchedData<
                          SourceRecord,
                          $SourceRecordsTable,
                          MergeConflict
                        >(
                          currentTable: table,
                          referencedTable: $$SourceRecordsTableReferences
                              ._incomingMergeConflictsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourceRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).incomingMergeConflicts,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.incomingRecordId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SourceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourceRecordsTable,
      SourceRecord,
      $$SourceRecordsTableFilterComposer,
      $$SourceRecordsTableOrderingComposer,
      $$SourceRecordsTableAnnotationComposer,
      $$SourceRecordsTableCreateCompanionBuilder,
      $$SourceRecordsTableUpdateCompanionBuilder,
      (SourceRecord, $$SourceRecordsTableReferences),
      SourceRecord,
      PrefetchHooks Function({
        bool importBatchId,
        bool coursesRefs,
        bool currentMergeConflicts,
        bool incomingMergeConflicts,
      })
    >;
typedef $$CoursesTableCreateCompanionBuilder =
    CoursesCompanion Function({
      Value<int> id,
      required int planId,
      Value<int?> sourceRecordId,
      required String name,
      Value<String?> teacher,
      Value<String?> color,
      Value<String?> note,
      Value<bool> isHidden,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$CoursesTableUpdateCompanionBuilder =
    CoursesCompanion Function({
      Value<int> id,
      Value<int> planId,
      Value<int?> sourceRecordId,
      Value<String> name,
      Value<String?> teacher,
      Value<String?> color,
      Value<String?> note,
      Value<bool> isHidden,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$CoursesTableReferences
    extends BaseReferences<_$AppDatabase, $CoursesTable, Course> {
  $$CoursesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TimetablePlansTable _planIdTable(_$AppDatabase db) =>
      db.timetablePlans.createAlias(
        $_aliasNameGenerator(db.courses.planId, db.timetablePlans.id),
      );

  $$TimetablePlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<int>('plan_id')!;

    final manager = $$TimetablePlansTableTableManager(
      $_db,
      $_db.timetablePlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SourceRecordsTable _sourceRecordIdTable(_$AppDatabase db) =>
      db.sourceRecords.createAlias(
        $_aliasNameGenerator(db.courses.sourceRecordId, db.sourceRecords.id),
      );

  $$SourceRecordsTableProcessedTableManager? get sourceRecordId {
    final $_column = $_itemColumn<int>('source_record_id');
    if ($_column == null) return null;
    final manager = $$SourceRecordsTableTableManager(
      $_db,
      $_db.sourceRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceRecordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ClassSessionsTable, List<ClassSession>>
  _classSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.classSessions,
    aliasName: $_aliasNameGenerator(db.courses.id, db.classSessions.courseId),
  );

  $$ClassSessionsTableProcessedTableManager get classSessionsRefs {
    final manager = $$ClassSessionsTableTableManager(
      $_db,
      $_db.classSessions,
    ).filter((f) => f.courseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_classSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReminderRulesTable, List<ReminderRule>>
  _reminderRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderRules,
    aliasName: $_aliasNameGenerator(db.courses.id, db.reminderRules.courseId),
  );

  $$ReminderRulesTableProcessedTableManager get reminderRulesRefs {
    final manager = $$ReminderRulesTableTableManager(
      $_db,
      $_db.reminderRules,
    ).filter((f) => f.courseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CoursesTableFilterComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableFilterComposer({
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

  ColumnFilters<String> get teacher => $composableBuilder(
    column: $table.teacher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TimetablePlansTableFilterComposer get planId {
    final $$TimetablePlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.timetablePlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablePlansTableFilterComposer(
            $db: $db,
            $table: $db.timetablePlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceRecordsTableFilterComposer get sourceRecordId {
    final $$SourceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceRecordId,
      referencedTable: $db.sourceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.sourceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> classSessionsRefs(
    Expression<bool> Function($$ClassSessionsTableFilterComposer f) f,
  ) {
    final $$ClassSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.classSessions,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassSessionsTableFilterComposer(
            $db: $db,
            $table: $db.classSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reminderRulesRefs(
    Expression<bool> Function($$ReminderRulesTableFilterComposer f) f,
  ) {
    final $$ReminderRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableFilterComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableOrderingComposer({
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

  ColumnOrderings<String> get teacher => $composableBuilder(
    column: $table.teacher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TimetablePlansTableOrderingComposer get planId {
    final $$TimetablePlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.timetablePlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablePlansTableOrderingComposer(
            $db: $db,
            $table: $db.timetablePlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceRecordsTableOrderingComposer get sourceRecordId {
    final $$SourceRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceRecordId,
      referencedTable: $db.sourceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.sourceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableAnnotationComposer({
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

  GeneratedColumn<String> get teacher =>
      $composableBuilder(column: $table.teacher, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TimetablePlansTableAnnotationComposer get planId {
    final $$TimetablePlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.timetablePlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablePlansTableAnnotationComposer(
            $db: $db,
            $table: $db.timetablePlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceRecordsTableAnnotationComposer get sourceRecordId {
    final $$SourceRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceRecordId,
      referencedTable: $db.sourceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> classSessionsRefs<T extends Object>(
    Expression<T> Function($$ClassSessionsTableAnnotationComposer a) f,
  ) {
    final $$ClassSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.classSessions,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.classSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reminderRulesRefs<T extends Object>(
    Expression<T> Function($$ReminderRulesTableAnnotationComposer a) f,
  ) {
    final $$ReminderRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CoursesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoursesTable,
          Course,
          $$CoursesTableFilterComposer,
          $$CoursesTableOrderingComposer,
          $$CoursesTableAnnotationComposer,
          $$CoursesTableCreateCompanionBuilder,
          $$CoursesTableUpdateCompanionBuilder,
          (Course, $$CoursesTableReferences),
          Course,
          PrefetchHooks Function({
            bool planId,
            bool sourceRecordId,
            bool classSessionsRefs,
            bool reminderRulesRefs,
          })
        > {
  $$CoursesTableTableManager(_$AppDatabase db, $CoursesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> planId = const Value.absent(),
                Value<int?> sourceRecordId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> teacher = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CoursesCompanion(
                id: id,
                planId: planId,
                sourceRecordId: sourceRecordId,
                name: name,
                teacher: teacher,
                color: color,
                note: note,
                isHidden: isHidden,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int planId,
                Value<int?> sourceRecordId = const Value.absent(),
                required String name,
                Value<String?> teacher = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CoursesCompanion.insert(
                id: id,
                planId: planId,
                sourceRecordId: sourceRecordId,
                name: name,
                teacher: teacher,
                color: color,
                note: note,
                isHidden: isHidden,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CoursesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                planId = false,
                sourceRecordId = false,
                classSessionsRefs = false,
                reminderRulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (classSessionsRefs) db.classSessions,
                    if (reminderRulesRefs) db.reminderRules,
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
                        if (planId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.planId,
                                    referencedTable: $$CoursesTableReferences
                                        ._planIdTable(db),
                                    referencedColumn: $$CoursesTableReferences
                                        ._planIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (sourceRecordId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceRecordId,
                                    referencedTable: $$CoursesTableReferences
                                        ._sourceRecordIdTable(db),
                                    referencedColumn: $$CoursesTableReferences
                                        ._sourceRecordIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (classSessionsRefs)
                        await $_getPrefetchedData<
                          Course,
                          $CoursesTable,
                          ClassSession
                        >(
                          currentTable: table,
                          referencedTable: $$CoursesTableReferences
                              ._classSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoursesTableReferences(
                                db,
                                table,
                                p0,
                              ).classSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.courseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reminderRulesRefs)
                        await $_getPrefetchedData<
                          Course,
                          $CoursesTable,
                          ReminderRule
                        >(
                          currentTable: table,
                          referencedTable: $$CoursesTableReferences
                              ._reminderRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoursesTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.courseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoursesTable,
      Course,
      $$CoursesTableFilterComposer,
      $$CoursesTableOrderingComposer,
      $$CoursesTableAnnotationComposer,
      $$CoursesTableCreateCompanionBuilder,
      $$CoursesTableUpdateCompanionBuilder,
      (Course, $$CoursesTableReferences),
      Course,
      PrefetchHooks Function({
        bool planId,
        bool sourceRecordId,
        bool classSessionsRefs,
        bool reminderRulesRefs,
      })
    >;
typedef $$ClassSessionsTableCreateCompanionBuilder =
    ClassSessionsCompanion Function({
      Value<int> id,
      required int courseId,
      required int weekday,
      required int startSection,
      required int endSection,
      required int weekStart,
      required int weekEnd,
      Value<String?> weekParity,
      Value<String?> location,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ClassSessionsTableUpdateCompanionBuilder =
    ClassSessionsCompanion Function({
      Value<int> id,
      Value<int> courseId,
      Value<int> weekday,
      Value<int> startSection,
      Value<int> endSection,
      Value<int> weekStart,
      Value<int> weekEnd,
      Value<String?> weekParity,
      Value<String?> location,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ClassSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $ClassSessionsTable, ClassSession> {
  $$ClassSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CoursesTable _courseIdTable(_$AppDatabase db) =>
      db.courses.createAlias(
        $_aliasNameGenerator(db.classSessions.courseId, db.courses.id),
      );

  $$CoursesTableProcessedTableManager get courseId {
    final $_column = $_itemColumn<int>('course_id')!;

    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_courseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ClassSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ClassSessionsTable> {
  $$ClassSessionsTableFilterComposer({
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

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startSection => $composableBuilder(
    column: $table.startSection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endSection => $composableBuilder(
    column: $table.endSection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekEnd => $composableBuilder(
    column: $table.weekEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekParity => $composableBuilder(
    column: $table.weekParity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CoursesTableFilterComposer get courseId {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClassSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClassSessionsTable> {
  $$ClassSessionsTableOrderingComposer({
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

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startSection => $composableBuilder(
    column: $table.startSection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endSection => $composableBuilder(
    column: $table.endSection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekEnd => $composableBuilder(
    column: $table.weekEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekParity => $composableBuilder(
    column: $table.weekParity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CoursesTableOrderingComposer get courseId {
    final $$CoursesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableOrderingComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClassSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClassSessionsTable> {
  $$ClassSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<int> get startSection => $composableBuilder(
    column: $table.startSection,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endSection => $composableBuilder(
    column: $table.endSection,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<int> get weekEnd =>
      $composableBuilder(column: $table.weekEnd, builder: (column) => column);

  GeneratedColumn<String> get weekParity => $composableBuilder(
    column: $table.weekParity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CoursesTableAnnotationComposer get courseId {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClassSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClassSessionsTable,
          ClassSession,
          $$ClassSessionsTableFilterComposer,
          $$ClassSessionsTableOrderingComposer,
          $$ClassSessionsTableAnnotationComposer,
          $$ClassSessionsTableCreateCompanionBuilder,
          $$ClassSessionsTableUpdateCompanionBuilder,
          (ClassSession, $$ClassSessionsTableReferences),
          ClassSession,
          PrefetchHooks Function({bool courseId})
        > {
  $$ClassSessionsTableTableManager(_$AppDatabase db, $ClassSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> courseId = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<int> startSection = const Value.absent(),
                Value<int> endSection = const Value.absent(),
                Value<int> weekStart = const Value.absent(),
                Value<int> weekEnd = const Value.absent(),
                Value<String?> weekParity = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ClassSessionsCompanion(
                id: id,
                courseId: courseId,
                weekday: weekday,
                startSection: startSection,
                endSection: endSection,
                weekStart: weekStart,
                weekEnd: weekEnd,
                weekParity: weekParity,
                location: location,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int courseId,
                required int weekday,
                required int startSection,
                required int endSection,
                required int weekStart,
                required int weekEnd,
                Value<String?> weekParity = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ClassSessionsCompanion.insert(
                id: id,
                courseId: courseId,
                weekday: weekday,
                startSection: startSection,
                endSection: endSection,
                weekStart: weekStart,
                weekEnd: weekEnd,
                weekParity: weekParity,
                location: location,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClassSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({courseId = false}) {
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
                    if (courseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.courseId,
                                referencedTable: $$ClassSessionsTableReferences
                                    ._courseIdTable(db),
                                referencedColumn: $$ClassSessionsTableReferences
                                    ._courseIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$ClassSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClassSessionsTable,
      ClassSession,
      $$ClassSessionsTableFilterComposer,
      $$ClassSessionsTableOrderingComposer,
      $$ClassSessionsTableAnnotationComposer,
      $$ClassSessionsTableCreateCompanionBuilder,
      $$ClassSessionsTableUpdateCompanionBuilder,
      (ClassSession, $$ClassSessionsTableReferences),
      ClassSession,
      PrefetchHooks Function({bool courseId})
    >;
typedef $$MergeConflictsTableCreateCompanionBuilder =
    MergeConflictsCompanion Function({
      Value<int> id,
      required int planId,
      Value<int?> importBatchId,
      Value<int?> currentRecordId,
      Value<int?> incomingRecordId,
      required String conflictType,
      Value<String> status,
      Value<String?> resolutionJson,
      Value<DateTime> createdAt,
      Value<DateTime?> resolvedAt,
    });
typedef $$MergeConflictsTableUpdateCompanionBuilder =
    MergeConflictsCompanion Function({
      Value<int> id,
      Value<int> planId,
      Value<int?> importBatchId,
      Value<int?> currentRecordId,
      Value<int?> incomingRecordId,
      Value<String> conflictType,
      Value<String> status,
      Value<String?> resolutionJson,
      Value<DateTime> createdAt,
      Value<DateTime?> resolvedAt,
    });

final class $$MergeConflictsTableReferences
    extends BaseReferences<_$AppDatabase, $MergeConflictsTable, MergeConflict> {
  $$MergeConflictsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TimetablePlansTable _planIdTable(_$AppDatabase db) =>
      db.timetablePlans.createAlias(
        $_aliasNameGenerator(db.mergeConflicts.planId, db.timetablePlans.id),
      );

  $$TimetablePlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<int>('plan_id')!;

    final manager = $$TimetablePlansTableTableManager(
      $_db,
      $_db.timetablePlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportBatchesTable _importBatchIdTable(_$AppDatabase db) =>
      db.importBatches.createAlias(
        $_aliasNameGenerator(
          db.mergeConflicts.importBatchId,
          db.importBatches.id,
        ),
      );

  $$ImportBatchesTableProcessedTableManager? get importBatchId {
    final $_column = $_itemColumn<int>('import_batch_id');
    if ($_column == null) return null;
    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importBatchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SourceRecordsTable _currentRecordIdTable(_$AppDatabase db) =>
      db.sourceRecords.createAlias(
        $_aliasNameGenerator(
          db.mergeConflicts.currentRecordId,
          db.sourceRecords.id,
        ),
      );

  $$SourceRecordsTableProcessedTableManager? get currentRecordId {
    final $_column = $_itemColumn<int>('current_record_id');
    if ($_column == null) return null;
    final manager = $$SourceRecordsTableTableManager(
      $_db,
      $_db.sourceRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currentRecordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SourceRecordsTable _incomingRecordIdTable(_$AppDatabase db) =>
      db.sourceRecords.createAlias(
        $_aliasNameGenerator(
          db.mergeConflicts.incomingRecordId,
          db.sourceRecords.id,
        ),
      );

  $$SourceRecordsTableProcessedTableManager? get incomingRecordId {
    final $_column = $_itemColumn<int>('incoming_record_id');
    if ($_column == null) return null;
    final manager = $$SourceRecordsTableTableManager(
      $_db,
      $_db.sourceRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_incomingRecordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MergeConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $MergeConflictsTable> {
  $$MergeConflictsTableFilterComposer({
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

  ColumnFilters<String> get conflictType => $composableBuilder(
    column: $table.conflictType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolutionJson => $composableBuilder(
    column: $table.resolutionJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TimetablePlansTableFilterComposer get planId {
    final $$TimetablePlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.timetablePlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablePlansTableFilterComposer(
            $db: $db,
            $table: $db.timetablePlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableFilterComposer get importBatchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceRecordsTableFilterComposer get currentRecordId {
    final $$SourceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentRecordId,
      referencedTable: $db.sourceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.sourceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceRecordsTableFilterComposer get incomingRecordId {
    final $$SourceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incomingRecordId,
      referencedTable: $db.sourceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.sourceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MergeConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $MergeConflictsTable> {
  $$MergeConflictsTableOrderingComposer({
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

  ColumnOrderings<String> get conflictType => $composableBuilder(
    column: $table.conflictType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolutionJson => $composableBuilder(
    column: $table.resolutionJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TimetablePlansTableOrderingComposer get planId {
    final $$TimetablePlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.timetablePlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablePlansTableOrderingComposer(
            $db: $db,
            $table: $db.timetablePlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableOrderingComposer get importBatchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceRecordsTableOrderingComposer get currentRecordId {
    final $$SourceRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentRecordId,
      referencedTable: $db.sourceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.sourceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceRecordsTableOrderingComposer get incomingRecordId {
    final $$SourceRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incomingRecordId,
      referencedTable: $db.sourceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.sourceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MergeConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MergeConflictsTable> {
  $$MergeConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conflictType => $composableBuilder(
    column: $table.conflictType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get resolutionJson => $composableBuilder(
    column: $table.resolutionJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  $$TimetablePlansTableAnnotationComposer get planId {
    final $$TimetablePlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.timetablePlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablePlansTableAnnotationComposer(
            $db: $db,
            $table: $db.timetablePlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableAnnotationComposer get importBatchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceRecordsTableAnnotationComposer get currentRecordId {
    final $$SourceRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentRecordId,
      referencedTable: $db.sourceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceRecordsTableAnnotationComposer get incomingRecordId {
    final $$SourceRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incomingRecordId,
      referencedTable: $db.sourceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MergeConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MergeConflictsTable,
          MergeConflict,
          $$MergeConflictsTableFilterComposer,
          $$MergeConflictsTableOrderingComposer,
          $$MergeConflictsTableAnnotationComposer,
          $$MergeConflictsTableCreateCompanionBuilder,
          $$MergeConflictsTableUpdateCompanionBuilder,
          (MergeConflict, $$MergeConflictsTableReferences),
          MergeConflict,
          PrefetchHooks Function({
            bool planId,
            bool importBatchId,
            bool currentRecordId,
            bool incomingRecordId,
          })
        > {
  $$MergeConflictsTableTableManager(
    _$AppDatabase db,
    $MergeConflictsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MergeConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MergeConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MergeConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> planId = const Value.absent(),
                Value<int?> importBatchId = const Value.absent(),
                Value<int?> currentRecordId = const Value.absent(),
                Value<int?> incomingRecordId = const Value.absent(),
                Value<String> conflictType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> resolutionJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
              }) => MergeConflictsCompanion(
                id: id,
                planId: planId,
                importBatchId: importBatchId,
                currentRecordId: currentRecordId,
                incomingRecordId: incomingRecordId,
                conflictType: conflictType,
                status: status,
                resolutionJson: resolutionJson,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int planId,
                Value<int?> importBatchId = const Value.absent(),
                Value<int?> currentRecordId = const Value.absent(),
                Value<int?> incomingRecordId = const Value.absent(),
                required String conflictType,
                Value<String> status = const Value.absent(),
                Value<String?> resolutionJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
              }) => MergeConflictsCompanion.insert(
                id: id,
                planId: planId,
                importBatchId: importBatchId,
                currentRecordId: currentRecordId,
                incomingRecordId: incomingRecordId,
                conflictType: conflictType,
                status: status,
                resolutionJson: resolutionJson,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MergeConflictsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                planId = false,
                importBatchId = false,
                currentRecordId = false,
                incomingRecordId = false,
              }) {
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
                        if (planId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.planId,
                                    referencedTable:
                                        $$MergeConflictsTableReferences
                                            ._planIdTable(db),
                                    referencedColumn:
                                        $$MergeConflictsTableReferences
                                            ._planIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (importBatchId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.importBatchId,
                                    referencedTable:
                                        $$MergeConflictsTableReferences
                                            ._importBatchIdTable(db),
                                    referencedColumn:
                                        $$MergeConflictsTableReferences
                                            ._importBatchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (currentRecordId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.currentRecordId,
                                    referencedTable:
                                        $$MergeConflictsTableReferences
                                            ._currentRecordIdTable(db),
                                    referencedColumn:
                                        $$MergeConflictsTableReferences
                                            ._currentRecordIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (incomingRecordId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.incomingRecordId,
                                    referencedTable:
                                        $$MergeConflictsTableReferences
                                            ._incomingRecordIdTable(db),
                                    referencedColumn:
                                        $$MergeConflictsTableReferences
                                            ._incomingRecordIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$MergeConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MergeConflictsTable,
      MergeConflict,
      $$MergeConflictsTableFilterComposer,
      $$MergeConflictsTableOrderingComposer,
      $$MergeConflictsTableAnnotationComposer,
      $$MergeConflictsTableCreateCompanionBuilder,
      $$MergeConflictsTableUpdateCompanionBuilder,
      (MergeConflict, $$MergeConflictsTableReferences),
      MergeConflict,
      PrefetchHooks Function({
        bool planId,
        bool importBatchId,
        bool currentRecordId,
        bool incomingRecordId,
      })
    >;
typedef $$ReminderRulesTableCreateCompanionBuilder =
    ReminderRulesCompanion Function({
      Value<int> id,
      Value<int?> planId,
      Value<int?> courseId,
      Value<int> minutesBefore,
      Value<bool> enabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ReminderRulesTableUpdateCompanionBuilder =
    ReminderRulesCompanion Function({
      Value<int> id,
      Value<int?> planId,
      Value<int?> courseId,
      Value<int> minutesBefore,
      Value<bool> enabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ReminderRulesTableReferences
    extends BaseReferences<_$AppDatabase, $ReminderRulesTable, ReminderRule> {
  $$ReminderRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TimetablePlansTable _planIdTable(_$AppDatabase db) =>
      db.timetablePlans.createAlias(
        $_aliasNameGenerator(db.reminderRules.planId, db.timetablePlans.id),
      );

  $$TimetablePlansTableProcessedTableManager? get planId {
    final $_column = $_itemColumn<int>('plan_id');
    if ($_column == null) return null;
    final manager = $$TimetablePlansTableTableManager(
      $_db,
      $_db.timetablePlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CoursesTable _courseIdTable(_$AppDatabase db) =>
      db.courses.createAlias(
        $_aliasNameGenerator(db.reminderRules.courseId, db.courses.id),
      );

  $$CoursesTableProcessedTableManager? get courseId {
    final $_column = $_itemColumn<int>('course_id');
    if ($_column == null) return null;
    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_courseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReminderRulesTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableFilterComposer({
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

  ColumnFilters<int> get minutesBefore => $composableBuilder(
    column: $table.minutesBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TimetablePlansTableFilterComposer get planId {
    final $$TimetablePlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.timetablePlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablePlansTableFilterComposer(
            $db: $db,
            $table: $db.timetablePlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CoursesTableFilterComposer get courseId {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableOrderingComposer({
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

  ColumnOrderings<int> get minutesBefore => $composableBuilder(
    column: $table.minutesBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TimetablePlansTableOrderingComposer get planId {
    final $$TimetablePlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.timetablePlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablePlansTableOrderingComposer(
            $db: $db,
            $table: $db.timetablePlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CoursesTableOrderingComposer get courseId {
    final $$CoursesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableOrderingComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get minutesBefore => $composableBuilder(
    column: $table.minutesBefore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TimetablePlansTableAnnotationComposer get planId {
    final $$TimetablePlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.timetablePlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablePlansTableAnnotationComposer(
            $db: $db,
            $table: $db.timetablePlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CoursesTableAnnotationComposer get courseId {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderRulesTable,
          ReminderRule,
          $$ReminderRulesTableFilterComposer,
          $$ReminderRulesTableOrderingComposer,
          $$ReminderRulesTableAnnotationComposer,
          $$ReminderRulesTableCreateCompanionBuilder,
          $$ReminderRulesTableUpdateCompanionBuilder,
          (ReminderRule, $$ReminderRulesTableReferences),
          ReminderRule,
          PrefetchHooks Function({bool planId, bool courseId})
        > {
  $$ReminderRulesTableTableManager(_$AppDatabase db, $ReminderRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                Value<int?> courseId = const Value.absent(),
                Value<int> minutesBefore = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReminderRulesCompanion(
                id: id,
                planId: planId,
                courseId: courseId,
                minutesBefore: minutesBefore,
                enabled: enabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                Value<int?> courseId = const Value.absent(),
                Value<int> minutesBefore = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReminderRulesCompanion.insert(
                id: id,
                planId: planId,
                courseId: courseId,
                minutesBefore: minutesBefore,
                enabled: enabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReminderRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planId = false, courseId = false}) {
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
                    if (planId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.planId,
                                referencedTable: $$ReminderRulesTableReferences
                                    ._planIdTable(db),
                                referencedColumn: $$ReminderRulesTableReferences
                                    ._planIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (courseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.courseId,
                                referencedTable: $$ReminderRulesTableReferences
                                    ._courseIdTable(db),
                                referencedColumn: $$ReminderRulesTableReferences
                                    ._courseIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$ReminderRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderRulesTable,
      ReminderRule,
      $$ReminderRulesTableFilterComposer,
      $$ReminderRulesTableOrderingComposer,
      $$ReminderRulesTableAnnotationComposer,
      $$ReminderRulesTableCreateCompanionBuilder,
      $$ReminderRulesTableUpdateCompanionBuilder,
      (ReminderRule, $$ReminderRulesTableReferences),
      ReminderRule,
      PrefetchHooks Function({bool planId, bool courseId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SemestersTableTableManager get semesters =>
      $$SemestersTableTableManager(_db, _db.semesters);
  $$TimetablePlansTableTableManager get timetablePlans =>
      $$TimetablePlansTableTableManager(_db, _db.timetablePlans);
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db, _db.importBatches);
  $$SourceRecordsTableTableManager get sourceRecords =>
      $$SourceRecordsTableTableManager(_db, _db.sourceRecords);
  $$CoursesTableTableManager get courses =>
      $$CoursesTableTableManager(_db, _db.courses);
  $$ClassSessionsTableTableManager get classSessions =>
      $$ClassSessionsTableTableManager(_db, _db.classSessions);
  $$MergeConflictsTableTableManager get mergeConflicts =>
      $$MergeConflictsTableTableManager(_db, _db.mergeConflicts);
  $$ReminderRulesTableTableManager get reminderRules =>
      $$ReminderRulesTableTableManager(_db, _db.reminderRules);
}
