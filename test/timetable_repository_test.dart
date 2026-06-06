import 'package:crid/core/file/import_file_type_detector.dart';
import 'package:crid/core/theme/course_colors.dart';
import 'package:crid/core/time/period.dart';
import 'package:crid/core/time/week_pattern.dart';
import 'package:crid/data/database/app_database.dart';
import 'package:crid/features/import/domain/parsed_exam_schedule.dart';
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
          timeRange: CourseTimeRange.fromPeriods(1, 2),
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
          timeRange: CourseTimeRange.fromPeriods(3, 4),
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

  test('import commit preserves exact clock minutes across reload', () async {
    final range = CourseTimeRange.fromClockTimes(
      startMinuteOfDay: 10 * 60 + 20,
      endMinuteOfDay: 12 * 60 + 20,
    );

    final summary = await repository.commitImport(
      ParsedTimetable(
        sourceName: 'exact.ics',
        fileType: ImportFileType.ics,
        courses: [
          ParsedCourse(
            name: 'Minute Accurate Seminar',
            teacher: 'Ada',
            location: 'A101',
            weekday: DateTime.tuesday,
            period: range.period,
            timeRange: range,
            weeks: WeekPattern.range(1, 1),
          ),
        ],
      ),
    );

    expect(summary.added, 1);

    final snapshot = await repository.loadSnapshot();
    final course = snapshot.courses.singleWhere(
      (item) => item.name == 'Minute Accurate Seminar',
    );
    expect(course.startMinuteOfDay, 10 * 60 + 20);
    expect(course.endMinuteOfDay, 12 * 60 + 20);
    expect(course.startPeriod, 3);
    expect(course.endPeriod, 4);
  });

  test('exam imports appear as timetable blocks in their exam week', () async {
    final summary = await repository.commitExamImport(
      ParsedExamSchedule(
        sourceName: 'exam.txt',
        fileType: ImportFileType.plainText,
        exams: [
          ParsedExam(
            examRound: '期末考试（16-18周）轮次',
            courseCode: 'MAT11002',
            courseName: '数学分析Ⅱ',
            credits: 6,
            category: '专业课程/专业核心课',
            assessmentMethod: '考试',
            startAt: DateTime(2026, 6, 15, 10, 20),
            endAt: DateTime(2026, 6, 15, 12, 20),
            semesterWeek: 16,
            weekday: DateTime.monday,
            location: '励耘楼 励耘楼A302',
            seatNumber: '78',
            rawText: 'raw exam row',
          ),
        ],
      ),
    );

    expect(summary.added, 1);
    expect(summary.skipped, 0);

    final snapshot = await repository.loadSnapshot();
    final exam = snapshot.courses.singleWhere(
      (course) => course.id.startsWith('exam:'),
    );

    expect(exam.name, '数学分析Ⅱ');
    expect(exam.teacher, '期末考试（16-18周）轮次');
    expect(exam.location, contains('励耘楼A302'));
    expect(exam.location, contains('78'));
    expect(exam.weekday, DateTime.monday);
    expect(exam.startWeek, 16);
    expect(exam.endWeek, 16);
    expect(exam.startPeriod, 3);
    expect(exam.endPeriod, 4);
    expect(exam.startMinuteOfDay, 10 * 60 + 20);
    expect(exam.endMinuteOfDay, 12 * 60 + 20);
    expect(exam.courseId, isNull);
    expect(exam.sessionId, isNull);
    expect(exam.examId, isNotNull);
    expect(exam.isExam, isTrue);
    expect(exam.hidden, isFalse);
  });

  test('manual exam edits can hide and restore exam blocks', () async {
    await repository.saveExam(
      ExamSlotDraft(
        name: 'Database Systems Final',
        examRound: 'Final exam',
        location: 'Room 204',
        weekday: DateTime.friday,
        timeRange: CourseTimeRange.fromClockTimes(
          startMinuteOfDay: 14 * 60,
          endMinuteOfDay: 16 * 60,
        ),
        semesterWeek: 12,
      ),
    );

    var snapshot = await repository.loadSnapshot();
    final original = snapshot.courses.singleWhere(
      (course) => course.name == 'Database Systems Final',
    );

    await repository.saveExam(
      ExamSlotDraft(
        examId: original.examId,
        name: 'Database Systems Final Retake',
        examRound: 'Retake',
        location: 'Room 305',
        weekday: DateTime.saturday,
        timeRange: CourseTimeRange.fromClockTimes(
          startMinuteOfDay: 18 * 60,
          endMinuteOfDay: 20 * 60,
        ),
        semesterWeek: 13,
        notes: 'Bring ID card',
        hidden: true,
      ),
    );

    snapshot = await repository.loadSnapshot();
    expect(
      snapshot.courses.where(
        (course) => course.name == 'Database Systems Final Retake',
      ),
      isEmpty,
    );
    expect(snapshot.hiddenCourses, hasLength(1));
    expect(snapshot.hiddenCourses.single.name, 'Database Systems Final Retake');
    expect(snapshot.hiddenCourses.single.isExam, isTrue);

    final exams = await repository.loadExamSchedules(includeHidden: true);
    final hiddenExam = exams.singleWhere(
      (exam) => exam.courseName == 'Database Systems Final Retake',
    );
    expect(hiddenExam.isHidden, isTrue);
    expect(hiddenExam.rawText, 'Bring ID card');

    await repository.restoreHiddenExam(hiddenExam.id);

    snapshot = await repository.loadSnapshot();
    final restored = snapshot.courses.singleWhere(
      (course) => course.name == 'Database Systems Final Retake',
    );
    expect(restored.examId, hiddenExam.id);
    expect(restored.weekday, DateTime.saturday);
    expect(restored.startWeek, 13);
    expect(restored.location, 'Room 305');
    expect(restored.notes, contains('Bring ID card'));
  });

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
