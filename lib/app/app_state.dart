import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locale_controller.dart';
import '../data/database/app_database.dart';
import '../features/import/domain/parsed_exam_schedule.dart';
import '../features/import/domain/parsed_timetable.dart';
import '../features/reminder/data/local_notification_reminder_scheduler.dart';
import '../features/timetable/data/timetable_repository.dart';
import '../features/timetable/presentation/course_slot_model.dart';

const maxSemesterWeek = 30;

class SelectedWeekNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void setWeek(int value) {
    state = value.clamp(1, maxSemesterWeek);
  }

  void setToDate(DateTime firstWeekMonday, DateTime date) {
    setWeek(weekNumberForDate(firstWeekMonday: firstWeekMonday, date: date));
  }
}

final selectedWeekProvider = NotifierProvider<SelectedWeekNotifier, int>(
  SelectedWeekNotifier.new,
);

class TimetableAutoScrollRequestNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void request() {
    state += 1;
  }
}

final timetableAutoScrollRequestProvider =
    NotifierProvider<TimetableAutoScrollRequestNotifier, int>(
      TimetableAutoScrollRequestNotifier.new,
    );

int weekNumberForDate({
  required DateTime firstWeekMonday,
  required DateTime date,
}) {
  final start = DateTime(
    firstWeekMonday.year,
    firstWeekMonday.month,
    firstWeekMonday.day,
  );
  final target = DateTime(date.year, date.month, date.day);
  final days = target.difference(start).inDays;
  return ((days ~/ 7) + 1).clamp(1, maxSemesterWeek);
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  return TimetableRepository(ref.watch(appDatabaseProvider));
});

final reminderSchedulerProvider = Provider<ReminderSchedulerService>((ref) {
  return FlutterLocalReminderScheduler();
});

class TimetableController extends AsyncNotifier<TimetableSnapshot> {
  late TimetableRepository _repository;
  late ReminderSchedulerService _reminderScheduler;

  @override
  Future<TimetableSnapshot> build() async {
    _repository = ref.watch(timetableRepositoryProvider);
    _reminderScheduler = ref.watch(reminderSchedulerProvider);
    final snapshot = await _repository.loadSnapshot();
    await _rebuildReminders();
    return snapshot;
  }

  Future<void> saveCourse(CourseSlotDraft draft) async {
    await _repository.saveCourse(draft);
    await _rebuildReminders();
    ref.invalidateSelf();
  }

  Future<void> saveExam(ExamSlotDraft draft) async {
    await _repository.saveExam(draft);
    ref.invalidate(examSchedulesProvider);
    ref.invalidateSelf();
  }

  Future<void> deleteSession({
    required int courseId,
    required int sessionId,
  }) async {
    await _repository.deleteSession(courseId: courseId, sessionId: sessionId);
    await _rebuildReminders();
    ref.invalidateSelf();
  }

  Future<void> deleteExam(int examId) async {
    await _repository.deleteExam(examId);
    ref.invalidate(examSchedulesProvider);
    ref.invalidateSelf();
  }

  Future<ImportCommitSummary> commitImport(ParsedTimetable parsed) async {
    final summary = await _repository.commitImport(parsed);
    await _rebuildReminders();
    ref.invalidate(pendingConflictsProvider);
    ref.invalidate(importHistoryProvider);
    ref.invalidateSelf();
    return summary;
  }

  Future<ExamImportCommitSummary> commitExamImport(
    ParsedExamSchedule parsed,
  ) async {
    final summary = await _repository.commitExamImport(parsed);
    ref.invalidate(importHistoryProvider);
    ref.invalidate(examSchedulesProvider);
    ref.invalidateSelf();
    return summary;
  }

  Future<void> createPlan({
    required int semesterId,
    required String name,
    bool active = false,
  }) async {
    await _repository.createPlan(
      semesterId: semesterId,
      name: name,
      active: active,
    );
    if (active) {
      await _rebuildReminders();
    }
    ref.invalidateSelf();
  }

  Future<void> updatePlan({required int planId, required String name}) async {
    await _repository.updatePlan(planId: planId, name: name);
    ref.invalidateSelf();
  }

  Future<void> deletePlan(int planId) async {
    await _repository.deletePlan(planId);
    await _rebuildReminders();
    ref.invalidate(reminderSettingsProvider);
    ref.invalidate(pendingConflictsProvider);
    ref.invalidateSelf();
  }

  Future<DeletedPlanSnapshot> deletePlanForUndo(int planId) async {
    final snapshot = await _repository.deletePlanForUndo(planId);
    await _rebuildReminders();
    ref.invalidate(reminderSettingsProvider);
    ref.invalidate(pendingConflictsProvider);
    ref.invalidateSelf();
    return snapshot;
  }

  Future<void> restoreDeletedPlan(DeletedPlanSnapshot snapshot) async {
    await _repository.restoreDeletedPlan(snapshot);
    await _rebuildReminders();
    ref.invalidate(reminderSettingsProvider);
    ref.invalidate(pendingConflictsProvider);
    ref.invalidateSelf();
  }

  Future<void> createSemester({
    required String name,
    required DateTime firstWeekMonday,
    DateTime? endDate,
    bool nameManuallyEdited = false,
  }) async {
    await _repository.createSemester(
      name: name,
      firstWeekMonday: firstWeekMonday,
      endDate: endDate,
      nameManuallyEdited: nameManuallyEdited,
    );
    await _rebuildReminders();
    ref.invalidate(reminderSettingsProvider);
    ref.invalidateSelf();
  }

  Future<void> updateSemester({
    required int semesterId,
    required String name,
    required DateTime firstWeekMonday,
    DateTime? endDate,
    bool nameManuallyEdited = true,
  }) async {
    await _repository.updateSemester(
      semesterId: semesterId,
      name: name,
      firstWeekMonday: firstWeekMonday,
      endDate: endDate,
      nameManuallyEdited: nameManuallyEdited,
    );
    await _rebuildReminders();
    ref.invalidate(reminderSettingsProvider);
    ref.invalidateSelf();
  }

  Future<void> deleteSemester(int semesterId) async {
    await _repository.deleteSemester(semesterId);
    await _rebuildReminders();
    ref.invalidate(reminderSettingsProvider);
    ref.invalidate(pendingConflictsProvider);
    ref.invalidateSelf();
  }

  Future<DeletedSemesterSnapshot> deleteSemesterForUndo(int semesterId) async {
    final snapshot = await _repository.deleteSemesterForUndo(semesterId);
    await _rebuildReminders();
    ref.invalidate(reminderSettingsProvider);
    ref.invalidate(pendingConflictsProvider);
    ref.invalidateSelf();
    return snapshot;
  }

  Future<void> restoreDeletedSemester(DeletedSemesterSnapshot snapshot) async {
    await _repository.restoreDeletedSemester(snapshot);
    await _rebuildReminders();
    ref.invalidate(reminderSettingsProvider);
    ref.invalidate(pendingConflictsProvider);
    ref.invalidateSelf();
  }

  Future<void> setActivePlan(int planId) async {
    await _repository.setActivePlan(planId);
    await _rebuildReminders();
    ref.invalidate(reminderSettingsProvider);
    ref.invalidate(pendingConflictsProvider);
    ref.invalidateSelf();
  }

  Future<void> setActiveSemester(int semesterId) async {
    await _repository.setActiveSemester(semesterId);
    await _rebuildReminders();
    ref.invalidate(reminderSettingsProvider);
    ref.invalidateSelf();
  }

  Future<void> updateActiveSemesterFirstWeekMonday(DateTime date) async {
    await _repository.updateActiveSemesterFirstWeekMonday(date);
    await _rebuildReminders();
    ref.invalidateSelf();
  }

  Future<void> syncGeneratedSemesterNames(
    String Function(DateTime firstWeekMonday) nameForDate,
  ) async {
    await _repository.syncGeneratedSemesterNames(nameForDate);
    ref.invalidateSelf();
  }

  Future<void> restoreHiddenCourse(int courseId) async {
    await _repository.restoreHiddenCourse(courseId);
    await _rebuildReminders();
    ref.invalidateSelf();
  }

  Future<void> restoreHiddenExam(int examId) async {
    await _repository.restoreHiddenExam(examId);
    ref.invalidate(examSchedulesProvider);
    ref.invalidateSelf();
  }

  Future<void> updateReminderSettings(ReminderSettings settings) async {
    var nextSettings = settings;
    if (settings.enabled) {
      final permissions = await _reminderScheduler
          .requestPermissionsForScheduling();
      if (!permissions.notificationsAllowed) {
        nextSettings = settings.copyWith(enabled: false);
      }
    }
    if (nextSettings.enabled && nextSettings.ignoreDoNotDisturb) {
      final dndAllowed = await _reminderScheduler
          .requestDoNotDisturbBypassIfSupported();
      if (!dndAllowed) {
        nextSettings = nextSettings.copyWith(ignoreDoNotDisturb: false);
      }
    }
    await _repository.updateReminderSettings(nextSettings);
    await _rebuildReminders();
    ref.invalidate(reminderSettingsProvider);
  }

  Future<void> rebuildReminders() {
    return _rebuildReminders();
  }

  Future<void> resolveConflict(
    int conflictId,
    ConflictResolutionAction action,
  ) async {
    await _repository.resolveConflict(conflictId, action);
    await _rebuildReminders();
    ref.invalidate(pendingConflictsProvider);
    ref.invalidateSelf();
  }

  Future<void> _rebuildReminders() async {
    final settings = await _repository.loadReminderSettings();
    final reminderData = await _repository.loadActiveReminderData();
    await _reminderScheduler.scheduleRollingWindow(
      sessions: settings.enabled ? reminderData.sessions : const [],
      firstWeekMonday: reminderData.firstWeekMonday,
      now: DateTime.now(),
      reminderOffsets: settings.reminderOffsets,
      ignoreDoNotDisturb: settings.ignoreDoNotDisturb,
      vibrateOnly: settings.vibrateOnly,
      windowDays: defaultReminderScheduleWindowDays,
      titleForMinutes: ref.read(reminderNotificationTitleProvider),
    );
  }
}

final timetableControllerProvider =
    AsyncNotifierProvider<TimetableController, TimetableSnapshot>(
      TimetableController.new,
    );

final sampleCoursesProvider = Provider<List<CourseSlot>>((ref) {
  return ref.watch(timetableControllerProvider).asData?.value.courses ??
      const [];
});

final reminderSettingsProvider = FutureProvider<ReminderSettings>((ref) {
  return ref.watch(timetableRepositoryProvider).loadReminderSettings();
});

final pendingConflictsProvider = FutureProvider<List<ConflictEntry>>((ref) {
  return ref.watch(timetableRepositoryProvider).loadPendingConflicts();
});

final importHistoryProvider = FutureProvider<List<ImportBatchSummary>>((ref) {
  return ref.watch(timetableRepositoryProvider).loadRecentImportBatches();
});

final examSchedulesProvider = FutureProvider<List<ExamSchedule>>((ref) {
  return ref.watch(timetableRepositoryProvider).loadExamSchedules();
});
