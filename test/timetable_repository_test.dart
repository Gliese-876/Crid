import 'package:crid/core/file/import_file_type_detector.dart';
import 'package:crid/core/theme/course_colors.dart';
import 'package:crid/core/time/period.dart';
import 'package:crid/core/time/week_pattern.dart';
import 'package:crid/data/database/app_database.dart';
import 'package:crid/features/import/domain/parsed_timetable.dart';
import 'package:crid/features/timetable/data/timetable_repository.dart';
import 'package:crid/features/timetable/presentation/course_slot_model.dart'
    as timetable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late TimetableRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = TimetableRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('new users start with an empty active timetable plan', () async {
    final snapshot = await repository.loadSnapshot();

    expect(snapshot.semesters, hasLength(1));
    expect(snapshot.plans, hasLength(1));
    expect(snapshot.activePlan.name, 'Main plan');
    expect(snapshot.courses, isEmpty);
  });

  test(
    'plans can be selected, edited, and deleted with stable fallback',
    () async {
      var snapshot = await repository.loadSnapshot();
      final originalPlanId = snapshot.activePlan.id;

      await repository.createPlan(
        semesterId: snapshot.activeSemester.id,
        name: 'Imported plan',
      );
      snapshot = await repository.loadSnapshot();
      final importedPlan = snapshot.plans.singleWhere(
        (plan) => plan.name == 'Imported plan',
      );

      await repository.setActivePlan(importedPlan.id);
      snapshot = await repository.loadSnapshot();
      expect(snapshot.activePlan.id, importedPlan.id);

      await repository.updatePlan(planId: importedPlan.id, name: 'Edited plan');
      snapshot = await repository.loadSnapshot();
      expect(snapshot.activePlan.name, 'Edited plan');

      await repository.deletePlan(importedPlan.id);
      snapshot = await repository.loadSnapshot();
      expect(snapshot.plans, hasLength(1));
      expect(snapshot.activePlan.id, originalPlanId);
      expect(snapshot.activePlan.isActive, isTrue);
    },
  );

  test(
    'import commit keeps multiple weekly slots for the same course',
    () async {
      final courses = [
        ParsedCourse(
          name: 'Discrete Math',
          teacher: 'Ada',
          location: 'A101',
          weekday: DateTime.monday,
          period: const PeriodRange(1, 2),
          weeks: WeekPattern.range(1, 16),
        ),
        ParsedCourse(
          name: 'Discrete Math',
          teacher: 'Ada',
          location: 'A101',
          weekday: DateTime.wednesday,
          period: const PeriodRange(3, 4),
          weeks: WeekPattern.range(1, 16),
        ),
        ParsedCourse(
          name: 'Discrete Math',
          teacher: 'Ada',
          location: 'A101',
          weekday: DateTime.friday,
          period: const PeriodRange(5, 6),
          weeks: WeekPattern.range(1, 16),
        ),
      ];

      final summary = await repository.commitImport(
        ParsedTimetable(
          sourceName: 'multi-slot-course.xls',
          fileType: ImportFileType.htmlXls,
          courses: courses,
        ),
      );

      expect(summary.added, 3);
      expect(summary.skipped, 0);
      expect(summary.diffs, 0);
      expect(summary.conflicts, 0);

      final snapshot = await repository.loadSnapshot();
      final imported = snapshot.courses
          .where((course) => course.name == 'Discrete Math')
          .toList();

      expect(imported, hasLength(3));
      expect(imported.map((course) => course.color).toSet(), hasLength(1));
      expect(
        imported.map(
          (course) =>
              '${course.weekday}:${course.startPeriod}-${course.endPeriod}',
        ),
        containsAll(['1:1-2', '3:3-4', '5:5-6']),
      );
    },
  );

  test(
    'manual slots with the same course name keep one stable color',
    () async {
      await repository.saveCourse(
        CourseSlotDraft(
          name: 'Cross Week Seminar',
          teacher: 'Ada',
          location: 'A101',
          weekday: DateTime.monday,
          startPeriod: 1,
          endPeriod: 2,
          startWeek: 1,
          endWeek: 8,
          parity: timetable.WeekParity.all,
          color: courseColorForIndex(0),
        ),
      );
      await repository.saveCourse(
        CourseSlotDraft(
          name: 'Cross Week Seminar',
          teacher: 'Ada',
          location: 'B202',
          weekday: DateTime.wednesday,
          startPeriod: 3,
          endPeriod: 4,
          startWeek: 9,
          endWeek: 16,
          parity: timetable.WeekParity.all,
          color: courseColorForIndex(1),
        ),
      );

      final snapshot = await repository.loadSnapshot();
      final seminarSlots = snapshot.courses
          .where((course) => course.name == 'Cross Week Seminar')
          .toList();

      expect(seminarSlots, hasLength(2));
      expect(seminarSlots.map((course) => course.color).toSet(), hasLength(1));
    },
  );

  test(
    'time conflicts can be force merged to keep concurrent courses',
    () async {
      final current = ParsedCourse(
        name: 'Linear Algebra',
        teacher: 'Ada',
        location: 'A101',
        weekday: DateTime.monday,
        period: const PeriodRange(1, 2),
        weeks: WeekPattern.range(1, 16),
      );
      final concurrent = ParsedCourse(
        name: 'Physics Lab',
        teacher: 'Grace',
        location: 'B202',
        weekday: DateTime.monday,
        period: const PeriodRange(1, 2),
        weeks: WeekPattern.range(1, 16),
      );

      await repository.commitImport(
        ParsedTimetable(
          sourceName: 'current.xls',
          fileType: ImportFileType.htmlXls,
          courses: [current],
        ),
      );

      final summary = await repository.commitImport(
        ParsedTimetable(
          sourceName: 'concurrent.xls',
          fileType: ImportFileType.htmlXls,
          courses: [concurrent],
        ),
      );

      expect(summary.added, 0);
      expect(summary.conflicts, 1);

      final conflicts = await repository.loadPendingConflicts();
      expect(conflicts, hasLength(1));
      expect(conflicts.single.isTimeConflict, isTrue);

      await repository.resolveConflict(
        conflicts.single.id,
        ConflictResolutionAction.keepBoth,
      );

      final snapshot = await repository.loadSnapshot();
      final mondayFirstPeriod = snapshot.courses
          .where(
            (course) =>
                course.weekday == DateTime.monday &&
                course.startPeriod == 1 &&
                course.endPeriod == 2,
          )
          .toList();

      expect(
        mondayFirstPeriod.map((course) => course.name),
        contains(current.name),
      );
      expect(
        mondayFirstPeriod.map((course) => course.name),
        contains(concurrent.name),
      );
      expect(await repository.loadPendingConflicts(), isEmpty);
    },
  );
}
