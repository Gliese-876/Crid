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
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(semesters, semesters.endDate);
      }
      if (from < 3) {
        await migrator.addColumn(semesters, semesters.nameManuallyEdited);
      }
    },
  );

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
