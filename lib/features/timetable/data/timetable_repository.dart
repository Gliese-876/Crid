import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../../core/time/period.dart';
import '../../../core/time/week_pattern.dart' as import_time;
import '../../../core/theme/course_colors.dart';
import '../../../data/database/app_database.dart' hide MergeConflict;
import '../../../data/database/timetable_time.dart' as db_time;
import '../../export/data/ics_export_service.dart';
import '../../import/domain/merge_engine.dart';
import '../../import/domain/parsed_exam_schedule.dart';
import '../../import/domain/parsed_timetable.dart';
import '../presentation/course_slot_model.dart';

class SemesterSummary {
  const SemesterSummary({
    required this.id,
    required this.name,
    required this.nameManuallyEdited,
    required this.firstWeekMonday,
    this.endDate,
  });

  final int id;
  final String name;
  final bool nameManuallyEdited;
  final DateTime firstWeekMonday;
  final DateTime? endDate;
}

class PlanSummary {
  const PlanSummary({
    required this.id,
    required this.semesterId,
    required this.name,
    required this.isActive,
  });

  final int id;
  final int semesterId;
  final String name;
  final bool isActive;
}

class TimetableSnapshot {
  const TimetableSnapshot({
    required this.semesters,
    required this.plans,
    required this.activePlan,
    required this.activeSemester,
    required this.courses,
    required this.hiddenCourses,
  });

  final List<SemesterSummary> semesters;
  final List<PlanSummary> plans;
  final PlanSummary activePlan;
  final SemesterSummary activeSemester;
  final List<CourseSlot> courses;
  final List<HiddenCourseSummary> hiddenCourses;
}

class HiddenCourseSummary {
  const HiddenCourseSummary({
    required this.id,
    required this.name,
    required this.teacher,
    required this.sessionCount,
    this.isExam = false,
  });

  final int id;
  final String name;
  final String teacher;
  final int sessionCount;
  final bool isExam;
}

class DeletedPlanSnapshot {
  const DeletedPlanSnapshot({
    required this.plan,
    required this.courses,
    required this.sessions,
  });

  final TimetablePlan plan;
  final List<Course> courses;
  final List<ClassSession> sessions;
}

class DeletedSemesterSnapshot {
  const DeletedSemesterSnapshot({required this.semester, required this.plans});

  final Semester semester;
  final List<DeletedPlanSnapshot> plans;
}

class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    required this.reminderOffsets,
    this.ignoreDoNotDisturb = false,
    this.vibrateOnly = false,
  });

  factory ReminderSettings.legacy({
    required bool enabled,
    required int minutesBefore,
  }) {
    return ReminderSettings(enabled: enabled, reminderOffsets: [minutesBefore]);
  }

  static const defaults = ReminderSettings(
    enabled: false,
    reminderOffsets: [20],
  );

  final bool enabled;
  final List<int> reminderOffsets;
  final bool ignoreDoNotDisturb;
  final bool vibrateOnly;

  int get minutesBefore => reminderOffsets.isEmpty
      ? 20
      : reminderOffsets.reduce((a, b) => a < b ? a : b);

  ReminderSettings copyWith({
    bool? enabled,
    Iterable<int>? reminderOffsets,
    bool? ignoreDoNotDisturb,
    bool? vibrateOnly,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      reminderOffsets: _normalizedReminderOffsets(
        reminderOffsets ?? this.reminderOffsets,
      ),
      ignoreDoNotDisturb: ignoreDoNotDisturb ?? this.ignoreDoNotDisturb,
      vibrateOnly: vibrateOnly ?? this.vibrateOnly,
    );
  }
}

class CourseSlotDraft {
  const CourseSlotDraft({
    this.courseId,
    this.sessionId,
    required this.name,
    required this.teacher,
    required this.location,
    required this.weekday,
    required this.timeRange,
    required this.startWeek,
    required this.endWeek,
    required this.parity,
    required this.color,
    this.notes = '',
    this.hidden = false,
  });

  final int? courseId;
  final int? sessionId;
  final String name;
  final String teacher;
  final String location;
  final int weekday;
  final CourseTimeRange timeRange;
  final int startWeek;
  final int endWeek;
  final WeekParity parity;
  final Color color;
  final String notes;
  final bool hidden;

  int get startPeriod => timeRange.period.start;

  int get endPeriod => timeRange.period.end;
}

class ExamSlotDraft {
  const ExamSlotDraft({
    this.examId,
    required this.name,
    required this.examRound,
    required this.location,
    required this.weekday,
    required this.timeRange,
    required this.semesterWeek,
    this.notes = '',
    this.hidden = false,
  });

  final int? examId;
  final String name;
  final String examRound;
  final String location;
  final int weekday;
  final CourseTimeRange timeRange;
  final int semesterWeek;
  final String notes;
  final bool hidden;
}

class ImportCommitSummary {
  const ImportCommitSummary({
    required this.added,
    required this.skipped,
    required this.diffs,
    required this.conflicts,
  });

  final int added;
  final int skipped;
  final int diffs;
  final int conflicts;
}

class ExamImportCommitSummary {
  const ExamImportCommitSummary({required this.added, required this.skipped});

  final int added;
  final int skipped;
}

class ImportBatchSummary {
  const ImportBatchSummary({
    required this.id,
    required this.sourceName,
    required this.fileType,
    required this.importedAt,
    required this.summary,
  });

  final int id;
  final String sourceName;
  final String fileType;
  final DateTime importedAt;
  final String summary;
}

class ConflictEntry {
  const ConflictEntry({
    required this.id,
    required this.type,
    required this.status,
    required this.current,
    required this.incoming,
  });

  final int id;
  final String type;
  final String status;
  final ParsedCourse current;
  final ParsedCourse incoming;

  bool get isTimeConflict => type == 'time_overlap';
}

enum ConflictResolutionAction { keepCurrent, useImported, keepBoth, manualEdit }

class ActiveReminderData {
  const ActiveReminderData({
    required this.firstWeekMonday,
    required this.sessions,
  });

  final DateTime firstWeekMonday;
  final List<db_time.ClassSessionInfo> sessions;
}

class TimetableRepository {
  const TimetableRepository(this._db);

  final AppDatabase _db;

  Future<TimetableSnapshot> loadSnapshot() async {
    await ensureSeedData();

    final semesters = await _db.select(_db.semesters).get();
    final plans = await _db.select(_db.timetablePlans).get();
    final activePlanRow = plans.firstWhere(
      (plan) => plan.isActive,
      orElse: () => plans.first,
    );
    final activeSemesterRow = semesters.firstWhere(
      (semester) => semester.id == activePlanRow.semesterId,
    );
    final sessions = await _db.sessionsForPlan(activePlanRow.id);
    final exams = await loadExamSchedules(limit: null);
    final hiddenCourses = await _hiddenCoursesForPlan(activePlanRow.id);
    final colorByIdentity = _courseColorsForSessions(sessions);

    return TimetableSnapshot(
      semesters: [
        for (final semester in semesters)
          SemesterSummary(
            id: semester.id,
            name: semester.name,
            nameManuallyEdited: semester.nameManuallyEdited,
            firstWeekMonday: semester.firstWeekMonday,
            endDate: semester.endDate,
          ),
      ],
      plans: [
        for (final plan in plans)
          PlanSummary(
            id: plan.id,
            semesterId: plan.semesterId,
            name: plan.name,
            isActive: plan.isActive,
          ),
      ],
      activePlan: PlanSummary(
        id: activePlanRow.id,
        semesterId: activePlanRow.semesterId,
        name: activePlanRow.name,
        isActive: activePlanRow.isActive,
      ),
      activeSemester: SemesterSummary(
        id: activeSemesterRow.id,
        name: activeSemesterRow.name,
        nameManuallyEdited: activeSemesterRow.nameManuallyEdited,
        firstWeekMonday: activeSemesterRow.firstWeekMonday,
        endDate: activeSemesterRow.endDate,
      ),
      courses: [
        for (final session in sessions)
          _slotFromSession(session, colorByIdentity: colorByIdentity),
        for (final exam in exams)
          _slotFromExamSchedule(exam, courseColorByIdentity: colorByIdentity),
      ],
      hiddenCourses: hiddenCourses,
    );
  }

  Future<void> ensureSeedData() async {
    await _db.transaction(() async {
      var semesters = await _db.select(_db.semesters).get();
      if (semesters.isEmpty) {
        final semesterId = await _db
            .into(_db.semesters)
            .insert(
              SemestersCompanion.insert(
                name: '2025-2026 Spring',
                firstWeekMonday: DateTime(2026, 2, 23),
              ),
            );
        await _db
            .into(_db.timetablePlans)
            .insert(
              TimetablePlansCompanion.insert(
                semesterId: semesterId,
                name: 'Main plan',
                isActive: const Value(true),
              ),
            );
        return;
      }

      final plans = await _db.select(_db.timetablePlans).get();
      var activePlan = plans.where((plan) => plan.isActive).firstOrNull;
      if (activePlan == null) {
        final targetSemesterId = plans.isNotEmpty
            ? plans.first.semesterId
            : semesters.first.id;
        final planId = await _db
            .into(_db.timetablePlans)
            .insert(
              TimetablePlansCompanion.insert(
                semesterId: targetSemesterId,
                name: 'Main plan',
                isActive: const Value(true),
              ),
            );
        activePlan = TimetablePlan(
          id: planId,
          semesterId: targetSemesterId,
          name: 'Main plan',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    });
  }

  Future<void> saveCourse(CourseSlotDraft draft, {int? planId}) async {
    final targetPlanId = planId ?? (await _activePlanId());
    await _db.transaction(() => _writeCourse(draft, planId: targetPlanId));
  }

  Future<void> saveExam(ExamSlotDraft draft) async {
    await ensureSeedData();
    await _db.transaction(() => _writeExam(draft));
  }

  Future<void> deleteSession({
    required int courseId,
    required int sessionId,
  }) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.classSessions,
      )..where((row) => row.id.equals(sessionId))).go();
      final remaining = await (_db.select(
        _db.classSessions,
      )..where((row) => row.courseId.equals(courseId))).get();
      if (remaining.isEmpty) {
        await (_db.delete(
          _db.courses,
        )..where((row) => row.id.equals(courseId))).go();
      }
    });
  }

  Future<void> deleteExam(int examId) async {
    await (_db.delete(
      _db.examSchedules,
    )..where((row) => row.id.equals(examId))).go();
  }

  Future<void> _writeCourse(
    CourseSlotDraft draft, {
    required int planId,
  }) async {
    final now = DateTime.now();
    final color = _courseColorForName(draft.name);
    final courseId =
        draft.courseId ??
        await _db
            .into(_db.courses)
            .insert(
              CoursesCompanion.insert(
                planId: planId,
                name: draft.name,
                teacher: Value(_nullable(draft.teacher)),
                color: Value(_colorToHex(color)),
                note: Value(_nullable(draft.notes)),
                isHidden: Value(draft.hidden),
                updatedAt: Value(now),
              ),
            );

    if (draft.courseId != null) {
      await (_db.update(
        _db.courses,
      )..where((row) => row.id.equals(courseId))).write(
        CoursesCompanion(
          name: Value(draft.name),
          teacher: Value(_nullable(draft.teacher)),
          color: Value(_colorToHex(color)),
          note: Value(_nullable(draft.notes)),
          isHidden: Value(draft.hidden),
          updatedAt: Value(now),
        ),
      );
    }

    final timeRange = draft.timeRange;
    final sessionCompanion = ClassSessionsCompanion(
      courseId: Value(courseId),
      weekday: Value(draft.weekday),
      startSection: Value(timeRange.period.start),
      endSection: Value(timeRange.period.end),
      startMinuteOfDay: Value(timeRange.startMinuteOfDay),
      endMinuteOfDay: Value(timeRange.endMinuteOfDay),
      weekStart: Value(draft.startWeek),
      weekEnd: Value(draft.endWeek),
      weekParity: Value(_parityToDatabase(draft.parity)),
      location: Value(_nullable(draft.location)),
      note: Value(_nullable(draft.notes)),
      updatedAt: Value(now),
    );
    if (draft.sessionId == null) {
      await _db.into(_db.classSessions).insert(sessionCompanion);
    } else {
      await (_db.update(_db.classSessions)
            ..where((row) => row.id.equals(draft.sessionId!)))
          .write(sessionCompanion);
    }
  }

  Future<void> _writeExam(ExamSlotDraft draft) async {
    final activePlanId = await _activePlanId();
    final activePlan = await (_db.select(
      _db.timetablePlans,
    )..where((row) => row.id.equals(activePlanId))).getSingle();
    final activeSemester = await (_db.select(
      _db.semesters,
    )..where((row) => row.id.equals(activePlan.semesterId))).getSingle();
    final date = activeSemester.firstWeekMonday.add(
      Duration(days: (draft.semesterWeek - 1) * 7 + draft.weekday - 1),
    );
    final startAt = _dateTimeAtMinute(date, draft.timeRange.startMinuteOfDay);
    final endAt = _dateTimeAtMinute(date, draft.timeRange.endMinuteOfDay);
    final companion = ExamSchedulesCompanion(
      examRound: Value(draft.examRound),
      courseName: Value(draft.name),
      startAt: Value(startAt),
      endAt: Value(endAt),
      semesterWeek: Value(draft.semesterWeek),
      weekday: Value(draft.weekday),
      location: Value(_nullable(draft.location)),
      seatNumber: const Value(null),
      rawText: Value(_nullable(draft.notes)),
      isHidden: Value(draft.hidden),
    );
    if (draft.examId == null) {
      await _db.into(_db.examSchedules).insert(companion);
      return;
    }
    await (_db.update(
      _db.examSchedules,
    )..where((row) => row.id.equals(draft.examId!))).write(companion);
  }

  Future<void> createPlan({
    required int semesterId,
    required String name,
    bool active = false,
  }) async {
    await _db.transaction(() async {
      if (active) {
        await (_db.update(
          _db.timetablePlans,
        )).write(const TimetablePlansCompanion(isActive: Value(false)));
      }
      await _db
          .into(_db.timetablePlans)
          .insert(
            TimetablePlansCompanion.insert(
              semesterId: semesterId,
              name: name,
              isActive: Value(active),
            ),
          );
    });
  }

  Future<void> updatePlan({required int planId, required String name}) async {
    await (_db.update(
      _db.timetablePlans,
    )..where((row) => row.id.equals(planId))).write(
      TimetablePlansCompanion(
        name: Value(name.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deletePlan(int planId) async {
    await _db.transaction(() async {
      final plan = await (_db.select(
        _db.timetablePlans,
      )..where((row) => row.id.equals(planId))).getSingle();
      final siblingPlans = await (_db.select(
        _db.timetablePlans,
      )..where((row) => row.semesterId.equals(plan.semesterId))).get();
      if (siblingPlans.length <= 1) {
        throw StateError('Cannot delete the last plan in a semester.');
      }
      final replacement = siblingPlans.firstWhere(
        (candidate) => candidate.id != planId,
      );
      await _deletePlanCascade(planId);
      if (plan.isActive) {
        await (_db.update(
          _db.timetablePlans,
        )).write(const TimetablePlansCompanion(isActive: Value(false)));
        await (_db.update(_db.timetablePlans)
              ..where((row) => row.id.equals(replacement.id)))
            .write(const TimetablePlansCompanion(isActive: Value(true)));
      }
    });
  }

  Future<DeletedPlanSnapshot> deletePlanForUndo(int planId) async {
    final snapshot = await _deletedPlanSnapshot(planId);
    await deletePlan(planId);
    return snapshot;
  }

  Future<void> restoreDeletedPlan(DeletedPlanSnapshot snapshot) async {
    await _db.transaction(() => _restoreDeletedPlan(snapshot));
  }

  Future<void> createSemester({
    required String name,
    required DateTime firstWeekMonday,
    DateTime? endDate,
    bool nameManuallyEdited = false,
  }) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.timetablePlans,
      )).write(const TimetablePlansCompanion(isActive: Value(false)));
      final semesterId = await _db
          .into(_db.semesters)
          .insert(
            SemestersCompanion.insert(
              name: name,
              nameManuallyEdited: Value(nameManuallyEdited),
              firstWeekMonday: firstWeekMonday,
              endDate: Value(endDate),
            ),
          );
      await _db
          .into(_db.timetablePlans)
          .insert(
            TimetablePlansCompanion.insert(
              semesterId: semesterId,
              name: 'Main plan',
              isActive: const Value(true),
            ),
          );
    });
  }

  Future<void> updateSemester({
    required int semesterId,
    required String name,
    required DateTime firstWeekMonday,
    DateTime? endDate,
    bool nameManuallyEdited = true,
  }) async {
    await (_db.update(
      _db.semesters,
    )..where((row) => row.id.equals(semesterId))).write(
      SemestersCompanion(
        name: Value(name.trim()),
        nameManuallyEdited: Value(nameManuallyEdited),
        firstWeekMonday: Value(
          DateTime(
            firstWeekMonday.year,
            firstWeekMonday.month,
            firstWeekMonday.day,
          ),
        ),
        endDate: Value(endDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> syncGeneratedSemesterNames(
    String Function(DateTime firstWeekMonday) nameForDate,
  ) async {
    await ensureSeedData();
    final semesters = await _db.select(_db.semesters).get();
    final now = DateTime.now();
    for (final semester in semesters) {
      if (semester.nameManuallyEdited) {
        continue;
      }
      final generatedName = nameForDate(semester.firstWeekMonday);
      if (generatedName.trim().isEmpty || generatedName == semester.name) {
        continue;
      }
      await (_db.update(
        _db.semesters,
      )..where((row) => row.id.equals(semester.id))).write(
        SemestersCompanion(name: Value(generatedName), updatedAt: Value(now)),
      );
    }
  }

  Future<void> restoreHiddenCourse(int courseId) async {
    await (_db.update(
      _db.courses,
    )..where((row) => row.id.equals(courseId))).write(
      CoursesCompanion(
        isHidden: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> restoreHiddenExam(int examId) async {
    await (_db.update(_db.examSchedules)..where((row) => row.id.equals(examId)))
        .write(const ExamSchedulesCompanion(isHidden: Value(false)));
  }

  Future<void> deleteSemester(int semesterId) async {
    await _db.transaction(() async {
      final semesters = await _db.select(_db.semesters).get();
      if (semesters.length <= 1) {
        throw StateError('Cannot delete the last semester.');
      }
      final plans = await (_db.select(
        _db.timetablePlans,
      )..where((row) => row.semesterId.equals(semesterId))).get();
      final deletingActive = plans.any((plan) => plan.isActive);
      for (final plan in plans) {
        await _deletePlanCascade(plan.id);
      }
      await (_db.delete(
        _db.semesters,
      )..where((row) => row.id.equals(semesterId))).go();
      if (deletingActive) {
        final replacementSemester = semesters.firstWhere(
          (semester) => semester.id != semesterId,
        );
        await _activateSemesterPlan(replacementSemester.id);
      }
    });
  }

  Future<DeletedSemesterSnapshot> deleteSemesterForUndo(int semesterId) async {
    final semester = await (_db.select(
      _db.semesters,
    )..where((row) => row.id.equals(semesterId))).getSingle();
    final plans = await (_db.select(
      _db.timetablePlans,
    )..where((row) => row.semesterId.equals(semesterId))).get();
    final planSnapshots = <DeletedPlanSnapshot>[];
    for (final plan in plans) {
      planSnapshots.add(await _deletedPlanSnapshot(plan.id));
    }
    final snapshot = DeletedSemesterSnapshot(
      semester: semester,
      plans: List.unmodifiable(planSnapshots),
    );
    await deleteSemester(semesterId);
    return snapshot;
  }

  Future<void> restoreDeletedSemester(DeletedSemesterSnapshot snapshot) async {
    await _db.transaction(() async {
      final restoredSemesterId = await _db
          .into(_db.semesters)
          .insert(
            SemestersCompanion.insert(
              name: snapshot.semester.name,
              nameManuallyEdited: Value(snapshot.semester.nameManuallyEdited),
              firstWeekMonday: snapshot.semester.firstWeekMonday,
              endDate: Value(snapshot.semester.endDate),
              sessionTemplateJson: Value(snapshot.semester.sessionTemplateJson),
              createdAt: Value(snapshot.semester.createdAt),
              updatedAt: Value(DateTime.now()),
            ),
          );
      for (final plan in snapshot.plans) {
        await _restoreDeletedPlan(plan, semesterId: restoredSemesterId);
      }
    });
  }

  Future<void> setActivePlan(int planId) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.timetablePlans,
      )).write(const TimetablePlansCompanion(isActive: Value(false)));
      await (_db.update(_db.timetablePlans)
            ..where((row) => row.id.equals(planId)))
          .write(const TimetablePlansCompanion(isActive: Value(true)));
    });
  }

  Future<void> setActiveSemester(int semesterId) async {
    await _db.transaction(() async {
      await _activateSemesterPlan(semesterId);
    });
  }

  Future<void> updateActiveSemesterFirstWeekMonday(DateTime date) async {
    final snapshot = await loadSnapshot();
    await (_db.update(
      _db.semesters,
    )..where((row) => row.id.equals(snapshot.activeSemester.id))).write(
      SemestersCompanion(
        firstWeekMonday: Value(DateTime(date.year, date.month, date.day)),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _activateSemesterPlan(int semesterId) async {
    var plans = await (_db.select(
      _db.timetablePlans,
    )..where((row) => row.semesterId.equals(semesterId))).get();
    if (plans.isEmpty) {
      final planId = await _db
          .into(_db.timetablePlans)
          .insert(
            TimetablePlansCompanion.insert(
              semesterId: semesterId,
              name: 'Main plan',
            ),
          );
      plans = await (_db.select(
        _db.timetablePlans,
      )..where((row) => row.id.equals(planId))).get();
    }

    await (_db.update(
      _db.timetablePlans,
    )).write(const TimetablePlansCompanion(isActive: Value(false)));
    await (_db.update(_db.timetablePlans)
          ..where((row) => row.id.equals(plans.first.id)))
        .write(const TimetablePlansCompanion(isActive: Value(true)));
  }

  Future<void> _deletePlanCascade(int planId) async {
    final courses = await (_db.select(
      _db.courses,
    )..where((row) => row.planId.equals(planId))).get();
    final courseIds = courses.map((course) => course.id).toList();

    for (final courseId in courseIds) {
      await (_db.delete(
        _db.classSessions,
      )..where((row) => row.courseId.equals(courseId))).go();
      await (_db.delete(
        _db.reminderRules,
      )..where((row) => row.courseId.equals(courseId))).go();
    }

    await (_db.delete(
      _db.reminderRules,
    )..where((row) => row.planId.equals(planId))).go();
    await (_db.delete(
      _db.mergeConflicts,
    )..where((row) => row.planId.equals(planId))).go();
    await (_db.delete(
      _db.courses,
    )..where((row) => row.planId.equals(planId))).go();
    await (_db.delete(
      _db.timetablePlans,
    )..where((row) => row.id.equals(planId))).go();
  }

  Future<DeletedPlanSnapshot> _deletedPlanSnapshot(int planId) async {
    final plan = await (_db.select(
      _db.timetablePlans,
    )..where((row) => row.id.equals(planId))).getSingle();
    final courses = await (_db.select(
      _db.courses,
    )..where((row) => row.planId.equals(planId))).get();
    final sessions = <ClassSession>[];
    for (final course in courses) {
      sessions.addAll(
        await (_db.select(
          _db.classSessions,
        )..where((row) => row.courseId.equals(course.id))).get(),
      );
    }
    return DeletedPlanSnapshot(
      plan: plan,
      courses: List.unmodifiable(courses),
      sessions: List.unmodifiable(sessions),
    );
  }

  Future<void> _restoreDeletedPlan(
    DeletedPlanSnapshot snapshot, {
    int? semesterId,
  }) async {
    final restoreAsActive = snapshot.plan.isActive;
    if (restoreAsActive) {
      await (_db.update(
        _db.timetablePlans,
      )).write(const TimetablePlansCompanion(isActive: Value(false)));
    }
    final restoredPlanId = await _db
        .into(_db.timetablePlans)
        .insert(
          TimetablePlansCompanion.insert(
            semesterId: semesterId ?? snapshot.plan.semesterId,
            name: snapshot.plan.name,
            isActive: Value(restoreAsActive),
            createdAt: Value(snapshot.plan.createdAt),
            updatedAt: Value(DateTime.now()),
          ),
        );
    final restoredCourseIds = <int, int>{};
    for (final course in snapshot.courses) {
      final restoredCourseId = await _db
          .into(_db.courses)
          .insert(
            CoursesCompanion.insert(
              planId: restoredPlanId,
              sourceRecordId: Value(course.sourceRecordId),
              name: course.name,
              teacher: Value(course.teacher),
              color: Value(course.color),
              note: Value(course.note),
              isHidden: Value(course.isHidden),
              createdAt: Value(course.createdAt),
              updatedAt: Value(DateTime.now()),
            ),
          );
      restoredCourseIds[course.id] = restoredCourseId;
    }
    for (final session in snapshot.sessions) {
      final restoredCourseId = restoredCourseIds[session.courseId];
      if (restoredCourseId == null) {
        continue;
      }
      await _db
          .into(_db.classSessions)
          .insert(
            ClassSessionsCompanion.insert(
              courseId: restoredCourseId,
              weekday: session.weekday,
              startSection: session.startSection,
              endSection: session.endSection,
              startMinuteOfDay: Value(session.startMinuteOfDay),
              endMinuteOfDay: Value(session.endMinuteOfDay),
              weekStart: session.weekStart,
              weekEnd: session.weekEnd,
              weekParity: Value(session.weekParity),
              location: Value(session.location),
              note: Value(session.note),
              createdAt: Value(session.createdAt),
              updatedAt: Value(DateTime.now()),
            ),
          );
    }
  }

  Future<ImportCommitSummary> commitImport(ParsedTimetable parsed) async {
    final planId = await _activePlanId();
    final result = await previewImport(parsed, planId: planId);

    await _db.transaction(() async {
      final batchId = await _db
          .into(_db.importBatches)
          .insert(
            ImportBatchesCompanion.insert(
              sourceName: parsed.sourceName,
              fileType: parsed.fileType.name,
              summaryJson: Value(
                jsonEncode({
                  'courses': parsed.courses.length,
                  'warnings': parsed.warnings.length,
                  'added': result.added.length,
                  'diffs': result.diffs.length,
                  'conflicts': result.conflicts.length,
                }),
              ),
            ),
          );

      for (final course in parsed.courses) {
        await _sourceRecordIdFor(course, batchId);
      }

      for (final course in result.added) {
        await _insertParsedCourse(course, planId: planId, batchId: batchId);
      }

      for (final diff in result.diffs) {
        await _insertMergeConflict(
          planId: planId,
          batchId: batchId,
          type:
              'diff:${diff.changedFields.map((field) => field.name).join(',')}',
          current: diff.existing,
          incoming: diff.incoming,
        );
      }

      for (final conflict in result.conflicts) {
        await _insertMergeConflict(
          planId: planId,
          batchId: batchId,
          type: 'time_overlap',
          current: conflict.existing,
          incoming: conflict.incoming,
        );
      }
    });

    return ImportCommitSummary(
      added: result.added.length,
      skipped: result.skipped.length,
      diffs: result.diffs.length,
      conflicts: result.conflicts.length,
    );
  }

  Future<ExamImportCommitSummary> commitExamImport(
    ParsedExamSchedule parsed,
  ) async {
    var added = 0;
    var skipped = 0;
    await _db.transaction(() async {
      final batchId = await _db
          .into(_db.importBatches)
          .insert(
            ImportBatchesCompanion.insert(
              sourceName: parsed.sourceName,
              fileType: parsed.fileType.name,
              summaryJson: Value(
                jsonEncode({
                  'exams': parsed.exams.length,
                  'warnings': parsed.warnings.length,
                }),
              ),
            ),
          );

      for (final exam in parsed.exams) {
        final inserted = await _insertParsedExam(exam, batchId: batchId);
        if (inserted) {
          added += 1;
        } else {
          skipped += 1;
        }
      }

      await (_db.update(
        _db.importBatches,
      )..where((row) => row.id.equals(batchId))).write(
        ImportBatchesCompanion(
          summaryJson: Value(
            jsonEncode({
              'exams': parsed.exams.length,
              'warnings': parsed.warnings.length,
              'added': added,
              'skipped': skipped,
            }),
          ),
        ),
      );
    });
    return ExamImportCommitSummary(added: added, skipped: skipped);
  }

  Future<List<ExamSchedule>> loadExamSchedules({
    int? limit = 80,
    bool includeHidden = false,
  }) {
    final query = _db.select(_db.examSchedules)
      ..orderBy([(row) => OrderingTerm.asc(row.startAt)]);
    if (!includeHidden) {
      query.where((row) => row.isHidden.equals(false));
    }
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<MergeResult> previewImport(
    ParsedTimetable parsed, {
    int? planId,
  }) async {
    final targetPlanId = planId ?? await _activePlanId();
    final existing = await _parsedCoursesForPlan(targetPlanId);
    return const TimetableMergeEngine().merge(
      existing: existing,
      incoming: parsed.courses,
    );
  }

  Future<List<ImportBatchSummary>> loadRecentImportBatches({
    int limit = 8,
  }) async {
    final rows =
        await (_db.select(_db.importBatches)
              ..orderBy([(row) => OrderingTerm.desc(row.importedAt)])
              ..limit(limit))
            .get();
    return [
      for (final row in rows)
        ImportBatchSummary(
          id: row.id,
          sourceName: row.sourceName,
          fileType: row.fileType,
          importedAt: row.importedAt,
          summary: _importBatchSummaryText(row.summaryJson),
        ),
    ];
  }

  Future<String> exportActivePlanIcs() async {
    final snapshot = await loadSnapshot();
    final sessions = await _db.sessionsForPlan(snapshot.activePlan.id);
    return _icsService.exportCalendar(
      calendarName:
          '${snapshot.activeSemester.name} / ${snapshot.activePlan.name}',
      firstWeekMonday: snapshot.activeSemester.firstWeekMonday,
      sessions: sessions,
    );
  }

  Future<ActiveReminderData> loadActiveReminderData() async {
    final snapshot = await loadSnapshot();
    return ActiveReminderData(
      firstWeekMonday: snapshot.activeSemester.firstWeekMonday,
      sessions: await _db.sessionsForPlan(snapshot.activePlan.id),
    );
  }

  Future<ReminderSettings> loadReminderSettings() async {
    final planId = await _activePlanId();
    final rule =
        await (_db.select(_db.reminderRules)..where(
              (row) => row.planId.equals(planId) & row.courseId.isNull(),
            ))
            .getSingleOrNull();
    if (rule == null) {
      return ReminderSettings.defaults;
    }
    final offsets = _decodeReminderOffsetsJson(
      rule.reminderOffsetsJson,
      fallback: rule.minutesBefore,
    );
    return ReminderSettings(
      enabled: rule.enabled,
      reminderOffsets: offsets,
      ignoreDoNotDisturb: rule.ignoreDnd,
      vibrateOnly: rule.vibrateOnly,
    );
  }

  Future<void> updateReminderSettings(ReminderSettings settings) async {
    final planId = await _activePlanId();
    final existing =
        await (_db.select(_db.reminderRules)..where(
              (row) => row.planId.equals(planId) & row.courseId.isNull(),
            ))
            .getSingleOrNull();
    final companion = ReminderRulesCompanion(
      planId: Value(planId),
      courseId: const Value(null),
      enabled: Value(settings.enabled),
      minutesBefore: Value(settings.minutesBefore.clamp(0, 1440)),
      reminderOffsetsJson: Value(jsonEncode(settings.reminderOffsets)),
      ignoreDnd: Value(settings.ignoreDoNotDisturb),
      vibrateOnly: Value(settings.vibrateOnly),
      updatedAt: Value(DateTime.now()),
    );
    if (existing == null) {
      await _db.into(_db.reminderRules).insert(companion);
    } else {
      await (_db.update(
        _db.reminderRules,
      )..where((row) => row.id.equals(existing.id))).write(companion);
    }
  }

  Future<List<ConflictEntry>> loadPendingConflicts() async {
    await ensureSeedData();
    final rows =
        await (_db.select(_db.mergeConflicts)
              ..where((row) => row.status.equals('pending'))
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();

    final conflicts = <ConflictEntry>[];
    for (final conflict in rows) {
      final current = await _sourceRecordById(conflict.currentRecordId);
      final incoming = await _sourceRecordById(conflict.incomingRecordId);
      if (current == null || incoming == null) {
        continue;
      }
      conflicts.add(
        ConflictEntry(
          id: conflict.id,
          type: conflict.conflictType,
          status: conflict.status,
          current: _parsedCourseFromSource(current),
          incoming: _parsedCourseFromSource(incoming),
        ),
      );
    }
    return conflicts;
  }

  Future<void> resolveConflict(
    int conflictId,
    ConflictResolutionAction action,
  ) async {
    final conflict = await (_db.select(
      _db.mergeConflicts,
    )..where((row) => row.id.equals(conflictId))).getSingle();
    final incoming = await _sourceRecordById(conflict.incomingRecordId);
    final current = await _sourceRecordById(conflict.currentRecordId);
    final incomingCourse = incoming == null
        ? null
        : _parsedCourseFromSource(incoming);
    final currentCourse = current == null
        ? null
        : _parsedCourseFromSource(current);

    await _db.transaction(() async {
      if (incomingCourse != null) {
        switch (action) {
          case ConflictResolutionAction.keepCurrent:
          case ConflictResolutionAction.manualEdit:
            break;
          case ConflictResolutionAction.useImported:
            final slot = currentCourse == null
                ? null
                : await _findSlotByFingerprint(
                    conflict.planId,
                    currentCourse.sourceFingerprint,
                  );
            await _writeCourse(
              _draftFromParsedCourse(
                incomingCourse,
                courseId: slot?.courseId,
                sessionId: slot?.sessionId,
              ),
              planId: conflict.planId,
            );
          case ConflictResolutionAction.keepBoth:
            await _insertParsedCourse(
              incomingCourse,
              planId: conflict.planId,
              batchId: conflict.importBatchId ?? await _latestBatchId(),
            );
        }
      }

      await (_db.update(
        _db.mergeConflicts,
      )..where((row) => row.id.equals(conflictId))).write(
        MergeConflictsCompanion(
          status: Value(action.name),
          resolutionJson: Value(
            jsonEncode({
              'action': action.name,
              'resolvedAt': DateTime.now().toIso8601String(),
            }),
          ),
          resolvedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<List<HiddenCourseSummary>> _hiddenCoursesForPlan(int planId) async {
    final courses =
        await (_db.select(_db.courses)
              ..where((row) => row.planId.equals(planId))
              ..where((row) => row.isHidden.equals(true))
              ..orderBy([(row) => OrderingTerm.asc(row.name)]))
            .get();
    final summaries = <HiddenCourseSummary>[];
    for (final course in courses) {
      final sessions = await (_db.select(
        _db.classSessions,
      )..where((row) => row.courseId.equals(course.id))).get();
      summaries.add(
        HiddenCourseSummary(
          id: course.id,
          name: course.name,
          teacher: course.teacher ?? '',
          sessionCount: sessions.length,
        ),
      );
    }
    final exams =
        await (_db.select(_db.examSchedules)
              ..where((row) => row.isHidden.equals(true))
              ..orderBy([(row) => OrderingTerm.asc(row.courseName)]))
            .get();
    for (final exam in exams) {
      summaries.add(
        HiddenCourseSummary(
          id: exam.id,
          name: exam.courseName,
          teacher: exam.examRound,
          sessionCount: 1,
          isExam: true,
        ),
      );
    }
    summaries.sort((a, b) => a.name.compareTo(b.name));
    return summaries;
  }

  Future<int> _activePlanId() async {
    await ensureSeedData();
    final plans = await _db.select(_db.timetablePlans).get();
    return plans
        .firstWhere((plan) => plan.isActive, orElse: () => plans.first)
        .id;
  }

  Future<SourceRecord?> _sourceRecordById(int? id) {
    if (id == null) {
      return Future<SourceRecord?>.value();
    }
    return (_db.select(
      _db.sourceRecords,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<int> _latestBatchId() async {
    final batch =
        await (_db.select(_db.importBatches)
              ..orderBy([(row) => OrderingTerm.desc(row.importedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (batch != null) {
      return batch.id;
    }
    return _db
        .into(_db.importBatches)
        .insert(
          ImportBatchesCompanion.insert(
            sourceName: 'Manual conflict resolution',
            fileType: 'manual',
          ),
        );
  }

  Future<CourseSlot?> _findSlotByFingerprint(
    int planId,
    String fingerprint,
  ) async {
    final sessions = await _db.sessionsForPlan(planId);
    for (final session in sessions) {
      final parsed = ParsedCourse(
        name: session.courseName,
        teacher: session.teacher ?? '',
        location: session.location ?? '',
        weekday: session.weekday,
        period: PeriodRange(session.startSection, session.endSection),
        timeRange: _timeRangeFromSession(session),
        weeks: import_time.WeekPattern.range(
          session.weekStart,
          session.weekEnd,
          parity: _toImportParity(session.weekParity),
        ),
      );
      if (parsed.sourceFingerprint == fingerprint) {
        return _slotFromSession(
          session,
          colorByIdentity: _courseColorsForSessions(sessions),
        );
      }
    }
    return null;
  }

  Future<List<ParsedCourse>> _parsedCoursesForPlan(int planId) async {
    final sessions = await _db.sessionsForPlan(planId);
    return sessions.map((session) {
      return ParsedCourse(
        name: session.courseName,
        teacher: session.teacher ?? '',
        location: session.location ?? '',
        weekday: session.weekday,
        period: PeriodRange(session.startSection, session.endSection),
        timeRange: _timeRangeFromSession(session),
        weeks: import_time.WeekPattern.range(
          session.weekStart,
          session.weekEnd,
          parity: _toImportParity(session.weekParity),
        ),
      );
    }).toList();
  }

  Future<bool> _insertParsedExam(
    ParsedExam exam, {
    required int batchId,
  }) async {
    final existing =
        await (_db.select(_db.sourceRecords)
              ..where((row) => row.fingerprint.equals(exam.sourceFingerprint)))
            .getSingleOrNull();
    if (existing != null) {
      return false;
    }
    final sourceRecordId = await _sourceRecordIdForExam(exam, batchId);
    await _db
        .into(_db.examSchedules)
        .insert(
          ExamSchedulesCompanion.insert(
            importBatchId: Value(batchId),
            sourceRecordId: Value(sourceRecordId),
            examRound: exam.examRound,
            courseCode: Value(_nullable(exam.courseCode)),
            courseName: exam.courseName,
            credits: Value(exam.credits),
            category: Value(_nullable(exam.category)),
            assessmentMethod: Value(_nullable(exam.assessmentMethod)),
            startAt: exam.startAt,
            endAt: exam.endAt,
            semesterWeek: exam.semesterWeek,
            weekday: exam.weekday,
            location: Value(_nullable(exam.location)),
            seatNumber: Value(_nullable(exam.seatNumber)),
            rawText: Value(exam.rawText),
          ),
        );
    return true;
  }

  Future<void> _insertParsedCourse(
    ParsedCourse parsed, {
    required int planId,
    required int batchId,
  }) async {
    final sourceRecordId = await _sourceRecordIdFor(parsed, batchId);
    final color = _courseColorForParsedCourse(parsed);
    final courseId = await _db
        .into(_db.courses)
        .insert(
          CoursesCompanion.insert(
            planId: planId,
            sourceRecordId: Value(sourceRecordId),
            name: parsed.name,
            teacher: Value(_nullable(parsed.teacher)),
            color: Value(_colorToHex(color)),
          ),
        );
    await _db
        .into(_db.classSessions)
        .insert(
          ClassSessionsCompanion.insert(
            courseId: courseId,
            weekday: parsed.weekday,
            startSection: parsed.timeRange.period.start,
            endSection: parsed.timeRange.period.end,
            startMinuteOfDay: Value(parsed.timeRange.startMinuteOfDay),
            endMinuteOfDay: Value(parsed.timeRange.endMinuteOfDay),
            weekStart: parsed.weeks.weeks.isEmpty
                ? 1
                : parsed.weeks.weeks.first,
            weekEnd: parsed.weeks.weeks.isEmpty ? 1 : parsed.weeks.weeks.last,
            weekParity: Value(_importParityToDatabase(parsed.weeks.parity)),
            location: Value(_nullable(parsed.location)),
          ),
        );
  }

  Future<int> _sourceRecordIdForExam(ParsedExam exam, int batchId) {
    return _db
        .into(_db.sourceRecords)
        .insert(
          SourceRecordsCompanion.insert(
            importBatchId: Value(batchId),
            fingerprint: exam.sourceFingerprint,
            rawContent: Value(exam.rawText),
            normalizedJson: Value(jsonEncode(exam.toNormalizedJson())),
          ),
        );
  }

  Future<int> _sourceRecordIdFor(ParsedCourse course, int batchId) async {
    final existing =
        await (_db.select(
              _db.sourceRecords,
            )..where((row) => row.fingerprint.equals(course.sourceFingerprint)))
            .getSingleOrNull();
    if (existing != null) {
      return existing.id;
    }
    return _db
        .into(_db.sourceRecords)
        .insert(
          SourceRecordsCompanion.insert(
            importBatchId: Value(batchId),
            fingerprint: course.sourceFingerprint,
            rawContent: Value(course.rawText),
            normalizedJson: Value(
              jsonEncode({
                'name': course.name,
                'teacher': course.teacher,
                'location': course.location,
                'weekday': course.weekday,
                'timeRange': {
                  'startMinuteOfDay': course.timeRange.startMinuteOfDay,
                  'endMinuteOfDay': course.timeRange.endMinuteOfDay,
                },
                'weeks': course.weeks.normalizedKey,
              }),
            ),
          ),
        );
  }

  Future<void> _insertMergeConflict({
    required int planId,
    required int batchId,
    required String type,
    required ParsedCourse current,
    required ParsedCourse incoming,
  }) async {
    final currentId = await _sourceRecordIdFor(current, batchId);
    final incomingId = await _sourceRecordIdFor(incoming, batchId);
    await _db
        .into(_db.mergeConflicts)
        .insert(
          MergeConflictsCompanion.insert(
            planId: planId,
            importBatchId: Value(batchId),
            currentRecordId: Value(currentId),
            incomingRecordId: Value(incomingId),
            conflictType: type,
          ),
        );
  }

  ParsedCourse _parsedCourseFromSource(SourceRecord record) {
    final normalized = jsonDecode(record.normalizedJson ?? '{}');
    if (normalized is! Map<String, Object?>) {
      return ParsedCourse(
        name: 'Unknown course',
        weekday: DateTime.monday,
        period: const PeriodRange(1, 2),
        weeks: import_time.WeekPattern.range(1, 1),
        rawText: record.rawContent,
        sourceFingerprint: record.fingerprint,
      );
    }

    final timeRangeJson = normalized['timeRange'];
    final startMinute = timeRangeJson is Map
        ? timeRangeJson['startMinuteOfDay'] as int?
        : normalized['startMinuteOfDay'] as int?;
    final endMinute = timeRangeJson is Map
        ? timeRangeJson['endMinuteOfDay'] as int?
        : normalized['endMinuteOfDay'] as int?;
    final weeksText = normalized['weeks'] as String? ?? '1';
    final weeks = [
      for (final part in weeksText.split(','))
        if (int.tryParse(part) != null) int.parse(part),
    ];
    final weekPattern = weeks.isEmpty
        ? import_time.WeekPattern.range(1, 1)
        : import_time.WeekPattern(weeks);
    final legacyPeriod = (normalized['period'] as String? ?? '1-2').split('-');
    final legacyPeriodRange = PeriodRange(
      int.tryParse(legacyPeriod.first) ?? 1,
      int.tryParse(
            legacyPeriod.length > 1 ? legacyPeriod.last : legacyPeriod.first,
          ) ??
          2,
    );
    final timeRange = startMinute != null && endMinute != null
        ? CourseTimeRange.fromClockTimes(
            startMinuteOfDay: startMinute,
            endMinuteOfDay: endMinute,
          )
        : CourseTimeRange.fromPeriods(
            legacyPeriodRange.start,
            legacyPeriodRange.end,
          );
    return ParsedCourse(
      name: normalized['name'] as String? ?? 'Unknown course',
      teacher: normalized['teacher'] as String? ?? '',
      location: normalized['location'] as String? ?? '',
      weekday: normalized['weekday'] as int? ?? DateTime.monday,
      period: timeRange.period,
      timeRange: timeRange,
      weeks: weekPattern,
      rawText: record.rawContent,
      sourceFingerprint: record.fingerprint,
    );
  }
}

String? _nullable(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

List<int> _normalizedReminderOffsets(Iterable<int> values) {
  final normalized =
      values
          .map((value) => value.clamp(0, 1440).toInt())
          .where((value) => value >= 0)
          .toSet()
          .toList()
        ..sort();
  if (normalized.isEmpty) {
    return const [20];
  }
  return List.unmodifiable(normalized);
}

List<int> _decodeReminderOffsetsJson(
  String? jsonValue, {
  required int fallback,
}) {
  if (jsonValue == null || jsonValue.trim().isEmpty) {
    return _normalizedReminderOffsets([fallback]);
  }
  try {
    final decoded = jsonDecode(jsonValue);
    if (decoded is List) {
      return _normalizedReminderOffsets(
        decoded.whereType<num>().map((value) => value.round()),
      );
    }
  } on FormatException {
    return _normalizedReminderOffsets([fallback]);
  }
  return _normalizedReminderOffsets([fallback]);
}

String _importBatchSummaryText(String? summaryJson) {
  if (summaryJson == null || summaryJson.isEmpty) {
    return 'Imported batch';
  }
  try {
    final summary = jsonDecode(summaryJson);
    if (summary is Map<String, Object?>) {
      return [
        if (summary['courses'] != null) '${summary['courses']} parsed',
        if (summary['exams'] != null) '${summary['exams']} exams',
        if (summary['added'] != null) '${summary['added']} added',
        if (summary['skipped'] != null) '${summary['skipped']} skipped',
        if (summary['diffs'] != null) '${summary['diffs']} diffs',
        if (summary['conflicts'] != null) '${summary['conflicts']} conflicts',
      ].join(' - ');
    }
  } on FormatException {
    return summaryJson;
  }
  return summaryJson;
}

Map<String, Color> _courseColorsForSessions(
  List<db_time.ClassSessionInfo> sessions,
) {
  return distinctCourseColorsForKeys(
    sessions.map((session) => _courseIdentityKeyForName(session.courseName)),
  );
}

CourseSlot _slotFromSession(
  db_time.ClassSessionInfo session, {
  required Map<String, Color> colorByIdentity,
}) {
  final identityKey = _courseIdentityKeyForName(session.courseName);
  final timeRange = _timeRangeFromSession(session);
  return CourseSlot(
    id: '${session.courseId}:${session.sessionId}',
    courseId: session.courseId,
    sessionId: session.sessionId,
    name: session.courseName,
    teacher: session.teacher ?? '',
    location: session.location ?? '',
    weekday: session.weekday,
    timeRange: timeRange,
    startWeek: session.weekStart,
    endWeek: session.weekEnd,
    parity: _fromDatabaseParity(session.weekParity),
    color: colorByIdentity[identityKey] ?? _courseColorForIdentity(identityKey),
    notes: session.note ?? '',
  );
}

CourseTimeRange _timeRangeFromSession(db_time.ClassSessionInfo session) {
  return session.startMinuteOfDay != null && session.endMinuteOfDay != null
      ? CourseTimeRange.fromClockTimes(
          startMinuteOfDay: session.startMinuteOfDay!,
          endMinuteOfDay: session.endMinuteOfDay!,
        )
      : CourseTimeRange.fromPeriods(session.startSection, session.endSection);
}

CourseSlot _slotFromExamSchedule(
  ExamSchedule exam, {
  required Map<String, Color> courseColorByIdentity,
}) {
  final timeRange = CourseTimeRange.fromClockTimes(
    startMinuteOfDay: _minuteOfDay(exam.startAt),
    endMinuteOfDay: _minuteOfDay(exam.endAt),
  );
  final identityKey = _courseIdentityKeyForName(exam.courseName);
  final color =
      courseColorByIdentity[identityKey] ??
      _courseColorForIdentity('exam:$identityKey');
  return CourseSlot(
    id: 'exam:${exam.id}',
    examId: exam.id,
    name: exam.courseName,
    teacher: exam.examRound,
    location: _examLocationLabel(exam),
    weekday: exam.weekday,
    timeRange: timeRange,
    startWeek: exam.semesterWeek,
    endWeek: exam.semesterWeek,
    parity: WeekParity.all,
    color: color,
    notes: _examNotesLabel(exam),
    hidden: exam.isHidden,
  );
}

int _minuteOfDay(DateTime value) => value.hour * 60 + value.minute;

DateTime _dateTimeAtMinute(DateTime date, int minuteOfDay) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    minuteOfDay ~/ 60,
    minuteOfDay % 60,
  );
}

String _examLocationLabel(ExamSchedule exam) {
  final parts = [
    if ((exam.location ?? '').trim().isNotEmpty) exam.location!.trim(),
    if ((exam.seatNumber ?? '').trim().isNotEmpty) exam.seatNumber!.trim(),
  ];
  return parts.join(' - ');
}

String _examNotesLabel(ExamSchedule exam) {
  final parts = [
    _formatExamDateTime(exam.startAt, exam.endAt),
    if ((exam.assessmentMethod ?? '').trim().isNotEmpty)
      exam.assessmentMethod!.trim(),
    if ((exam.courseCode ?? '').trim().isNotEmpty) exam.courseCode!.trim(),
    if (exam.importBatchId == null && (exam.rawText ?? '').trim().isNotEmpty)
      exam.rawText!.trim(),
  ];
  return parts.join(' - ');
}

String _formatExamDateTime(DateTime startAt, DateTime endAt) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  final date =
      '${startAt.year}-${twoDigits(startAt.month)}-${twoDigits(startAt.day)}';
  final start = '${twoDigits(startAt.hour)}:${twoDigits(startAt.minute)}';
  final end = '${twoDigits(endAt.hour)}:${twoDigits(endAt.minute)}';
  return '$date $start-$end';
}

CourseSlotDraft _draftFromParsedCourse(
  ParsedCourse parsed, {
  int? courseId,
  int? sessionId,
}) {
  return CourseSlotDraft(
    courseId: courseId,
    sessionId: sessionId,
    name: parsed.name,
    teacher: parsed.teacher,
    location: parsed.location,
    weekday: parsed.weekday,
    timeRange: parsed.timeRange,
    startWeek: parsed.weeks.weeks.isEmpty ? 1 : parsed.weeks.weeks.first,
    endWeek: parsed.weeks.weeks.isEmpty ? 1 : parsed.weeks.weeks.last,
    parity: _fromImportParity(parsed.weeks.parity),
    color: _courseColorForParsedCourse(parsed),
  );
}

Color _courseColorForParsedCourse(ParsedCourse parsed) {
  return _courseColorForIdentity(parsed.identityKey);
}

Color _courseColorForName(String name) {
  return _courseColorForIdentity(_courseIdentityKeyForName(name));
}

String _courseIdentityKeyForName(String name) {
  final identityKey = normalizeCourseText(name);
  if (identityKey.isEmpty) {
    return 'untitled-course';
  }
  return identityKey;
}

Color _courseColorForIdentity(String identityKey) {
  return courseColorForKey(identityKey);
}

String _colorToHex(Color color) {
  final value = color.toARGB32() & 0x00FFFFFF;
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

WeekParity _fromDatabaseParity(db_time.WeekParity parity) {
  return switch (parity) {
    db_time.WeekParity.all => WeekParity.all,
    db_time.WeekParity.odd => WeekParity.odd,
    db_time.WeekParity.even => WeekParity.even,
  };
}

db_time.WeekParity _toDatabaseParity(WeekParity parity) {
  return switch (parity) {
    WeekParity.all => db_time.WeekParity.all,
    WeekParity.odd => db_time.WeekParity.odd,
    WeekParity.even => db_time.WeekParity.even,
  };
}

String? _parityToDatabase(WeekParity parity) =>
    _toDatabaseParity(parity).databaseValue;

import_time.WeekParity _toImportParity(db_time.WeekParity parity) {
  return switch (parity) {
    db_time.WeekParity.all => import_time.WeekParity.all,
    db_time.WeekParity.odd => import_time.WeekParity.odd,
    db_time.WeekParity.even => import_time.WeekParity.even,
  };
}

String? _importParityToDatabase(import_time.WeekParity parity) {
  return switch (parity) {
    import_time.WeekParity.all => null,
    import_time.WeekParity.odd => 'odd',
    import_time.WeekParity.even => 'even',
  };
}

WeekParity _fromImportParity(import_time.WeekParity parity) {
  return switch (parity) {
    import_time.WeekParity.all => WeekParity.all,
    import_time.WeekParity.odd => WeekParity.odd,
    import_time.WeekParity.even => WeekParity.even,
  };
}

const _icsService = IcsExportService();
