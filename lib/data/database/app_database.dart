import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'timetable_time.dart';

part 'app_database.g.dart';

class Semesters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  BoolColumn get nameManuallyEdited =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get firstWeekMonday => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get sessionTemplateJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class TimetablePlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get semesterId => integer().references(Semesters, #id)();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class ImportBatches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sourceName => text().withLength(min: 1, max: 255)();
  TextColumn get fileType => text().withLength(min: 1, max: 32)();
  DateTimeColumn get importedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get summaryJson => text().nullable()();
}

class SourceRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get importBatchId =>
      integer().nullable().references(ImportBatches, #id)();
  TextColumn get fingerprint => text().withLength(min: 1, max: 128)();
  TextColumn get rawContent => text().nullable()();
  TextColumn get normalizedJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {fingerprint},
  ];
}

class Courses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId => integer().references(TimetablePlans, #id)();
  IntColumn get sourceRecordId =>
      integer().nullable().references(SourceRecords, #id)();
  TextColumn get name => text().withLength(min: 1, max: 160)();
  TextColumn get teacher => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class ClassSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get courseId => integer().references(Courses, #id)();

  /// ISO weekday, Monday = 1, Sunday = 7.
  IntColumn get weekday => integer()();
  IntColumn get startSection => integer()();
  IntColumn get endSection => integer()();
  IntColumn get startMinuteOfDay => integer().nullable()();
  IntColumn get endMinuteOfDay => integer().nullable()();
  IntColumn get weekStart => integer()();
  IntColumn get weekEnd => integer()();
  TextColumn get weekParity => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class MergeConflicts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId => integer().references(TimetablePlans, #id)();
  IntColumn get importBatchId =>
      integer().nullable().references(ImportBatches, #id)();
  @ReferenceName('currentMergeConflicts')
  IntColumn get currentRecordId =>
      integer().nullable().references(SourceRecords, #id)();
  @ReferenceName('incomingMergeConflicts')
  IntColumn get incomingRecordId =>
      integer().nullable().references(SourceRecords, #id)();
  TextColumn get conflictType => text().withLength(min: 1, max: 64)();
  TextColumn get status => text()
      .withLength(min: 1, max: 32)
      .withDefault(const Constant('pending'))();
  TextColumn get resolutionJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
}

class ReminderRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId =>
      integer().nullable().references(TimetablePlans, #id)();
  IntColumn get courseId => integer().nullable().references(Courses, #id)();
  IntColumn get minutesBefore => integer().withDefault(const Constant(20))();
  TextColumn get reminderOffsetsJson => text().nullable()();
  BoolColumn get ignoreDnd => boolean().withDefault(const Constant(false))();
  BoolColumn get vibrateOnly => boolean().withDefault(const Constant(false))();
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class ExamSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get importBatchId =>
      integer().nullable().references(ImportBatches, #id)();
  IntColumn get sourceRecordId =>
      integer().nullable().references(SourceRecords, #id)();
  TextColumn get examRound => text().withLength(min: 1, max: 160)();
  TextColumn get courseCode => text().nullable().withLength(max: 64)();
  TextColumn get courseName => text().withLength(min: 1, max: 180)();
  RealColumn get credits => real().nullable()();
  TextColumn get category => text().nullable().withLength(max: 160)();
  TextColumn get assessmentMethod => text().nullable().withLength(max: 64)();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime()();
  IntColumn get semesterWeek => integer()();
  IntColumn get weekday => integer()();
  TextColumn get location => text().nullable().withLength(max: 220)();
  TextColumn get seatNumber => text().nullable().withLength(max: 32)();
  TextColumn get rawText => text().nullable()();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    Semesters,
    TimetablePlans,
    Courses,
    ClassSessions,
    ImportBatches,
    SourceRecords,
    MergeConflicts,
    ReminderRules,
    ExamSchedules,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2 && !await _columnExists('semesters', 'end_date')) {
        await migrator.addColumn(semesters, semesters.endDate);
      }
      if (from < 3 &&
          !await _columnExists('semesters', 'name_manually_edited')) {
        await migrator.addColumn(semesters, semesters.nameManuallyEdited);
      }
      if (from < 4) {
        if (!await _columnExists('reminder_rules', 'reminder_offsets_json')) {
          await migrator.addColumn(
            reminderRules,
            reminderRules.reminderOffsetsJson,
          );
        }
        if (!await _columnExists('reminder_rules', 'ignore_dnd')) {
          await migrator.addColumn(reminderRules, reminderRules.ignoreDnd);
        }
        if (!await _columnExists('reminder_rules', 'vibrate_only')) {
          await migrator.addColumn(reminderRules, reminderRules.vibrateOnly);
        }
        if (!await _columnExists('exam_schedules', 'id')) {
          await migrator.createTable(examSchedules);
        }
      }
      if (from < 5) {
        if (!await _columnExists('class_sessions', 'start_minute_of_day')) {
          await migrator.addColumn(
            classSessions,
            classSessions.startMinuteOfDay,
          );
        }
        if (!await _columnExists('class_sessions', 'end_minute_of_day')) {
          await migrator.addColumn(classSessions, classSessions.endMinuteOfDay);
        }
      }
      if (from < 6 && !await _columnExists('exam_schedules', 'is_hidden')) {
        await migrator.addColumn(examSchedules, examSchedules.isHidden);
      }
    },
  );

  Future<bool> _columnExists(String tableName, String columnName) async {
    final columns = await customSelect('PRAGMA table_info("$tableName")').get();
    return columns.any((row) => row.read<String>('name') == columnName);
  }

  Future<List<ClassSessionInfo>> sessionsForPlan(int planId) async {
    final rows =
        await (select(classSessions).join([
                innerJoin(
                  courses,
                  courses.id.equalsExp(classSessions.courseId),
                ),
              ])
              ..where(courses.planId.equals(planId))
              ..where(courses.isHidden.equals(false)))
            .get();

    return rows.map((row) {
      final session = row.readTable(classSessions);
      final course = row.readTable(courses);
      return ClassSessionInfo(
        sessionId: session.id,
        courseId: course.id,
        courseName: course.name,
        teacher: course.teacher,
        location: session.location,
        note: session.note ?? course.note,
        color: course.color,
        weekday: session.weekday,
        startSection: session.startSection,
        endSection: session.endSection,
        startMinuteOfDay: session.startMinuteOfDay,
        endMinuteOfDay: session.endMinuteOfDay,
        weekStart: session.weekStart,
        weekEnd: session.weekEnd,
        weekParity: WeekParity.fromDatabase(session.weekParity),
      );
    }).toList();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'crid.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
