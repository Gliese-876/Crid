// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Crid';

  @override
  String get navTimetable => 'Timetable';

  @override
  String get navPlans => 'Plans';

  @override
  String get navImport => 'Import';

  @override
  String get navEditor => 'Editor';

  @override
  String get navExport => 'Export';

  @override
  String get navSettings => 'Settings';

  @override
  String get collapseSidebar => 'Collapse sidebar';

  @override
  String get expandSidebar => 'Expand sidebar';

  @override
  String get addCourse => 'Add course';

  @override
  String get backToTimetable => 'Back to timetable';

  @override
  String get loadingTimetable => 'Loading timetable';

  @override
  String failedToLoadTimetable(Object error) {
    return 'Failed to load timetable: $error';
  }

  @override
  String weekNumber(int week) {
    return 'Week $week';
  }

  @override
  String visibleSessionsThisWeek(int count) {
    return '$count visible sessions this week';
  }

  @override
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

  @override
  String get timeHeader => 'Time';

  @override
  String get thisWeek => 'This week';

  @override
  String get todayCourses => 'Today\'s courses';

  @override
  String get noCoursesToday => 'No courses today';

  @override
  String get edit => 'Edit';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String dayNumber(int weekday) {
    return 'Weekday $weekday';
  }

  @override
  String periodsValue(int start, int end) {
    return 'Periods $start-$end';
  }

  @override
  String weeksValue(int start, int end) {
    return 'Weeks $start-$end';
  }

  @override
  String failedToLoadPlans(Object error) {
    return 'Failed to load plans: $error';
  }

  @override
  String get semesters => 'Semesters';

  @override
  String get add => 'Add';

  @override
  String firstMonday(String date) {
    return 'First-week Monday: $date';
  }

  @override
  String get current => 'Current';

  @override
  String get timetablePlans => 'Timetable plans';

  @override
  String get activeForRemindersAndExport =>
      'Used for reminders and default export';

  @override
  String get tapToMakeActive => 'Tap to make current';

  @override
  String get active => 'Current';

  @override
  String get plan => 'Plan';

  @override
  String get selectPlan => 'Select';

  @override
  String get newPlan => 'New plan';

  @override
  String semesterName(int year, String month) {
    return '$year-$month semester';
  }

  @override
  String planName(int number) {
    return 'Plan $number';
  }

  @override
  String get courseSessionNotFound => 'Course session not found.';

  @override
  String get newCourse => 'New course';

  @override
  String get editCourse => 'Edit course';

  @override
  String get hideThisSession => 'Hide this session';

  @override
  String get hideThisSessionSubtitle =>
      'Hidden sessions stay in the database but do not appear on the timetable.';

  @override
  String get deleteSession => 'Delete session';

  @override
  String get saveCourse => 'Save course';

  @override
  String get courseName => 'Course name';

  @override
  String get teacher => 'Teacher';

  @override
  String get location => 'Location';

  @override
  String get notes => 'Notes';

  @override
  String get weekday => 'Weekday';

  @override
  String get startPeriod => 'Start time';

  @override
  String get endPeriod => 'End time';

  @override
  String get startWeek => 'Start week';

  @override
  String get endWeek => 'End week';

  @override
  String get allWeeks => 'All weeks';

  @override
  String get oddWeeks => 'Odd weeks';

  @override
  String get evenWeeks => 'Even weeks';

  @override
  String get requiredField => 'Required';

  @override
  String get weekNumberValidation => 'Enter a value from 1 to 30.';

  @override
  String get timeValidation =>
      'Use HH:mm and make the end time later than the start time.';

  @override
  String courseSaved(String course, int weekday, String start, String end) {
    return 'Saved $course: weekday $weekday, $start-$end.';
  }

  @override
  String get courseSessionDeleted => 'Course session deleted';

  @override
  String get restore => 'Restore';

  @override
  String get courseRestored => 'Course restored';

  @override
  String get importCenter => 'Import center';

  @override
  String get importCenterSubtitle =>
      'Import timetable files from the academic system or calendar files.';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get pasteExamSchedule => 'Paste exam schedule';

  @override
  String get pasteExamScheduleHint =>
      'Paste the exam schedule text copied from the academic system.';

  @override
  String get importExamSchedule => 'Import exam schedule';

  @override
  String get loadSample => 'Load sample';

  @override
  String get openDiff => 'Review imports';

  @override
  String get stagingPreview => 'Import preview';

  @override
  String get merged => 'Added to timetable';

  @override
  String get waiting => 'Choose a file';

  @override
  String get notCommitted => 'Ready to add';

  @override
  String parsedCount(int count) {
    return '$count parsed';
  }

  @override
  String newCount(int count) {
    return '$count new';
  }

  @override
  String skippedCount(int count) {
    return '$count skipped';
  }

  @override
  String examParsedCount(int count) {
    return '$count exams';
  }

  @override
  String changeCount(int count) {
    return '$count changed';
  }

  @override
  String conflictCount(int count) {
    return '$count conflicts';
  }

  @override
  String get applyStagingMerge => 'Add to timetable';

  @override
  String get emptyPreview =>
      'Import a timetable file to preview what will be added.';

  @override
  String importFailed(Object error) {
    return 'Import failed: $error';
  }

  @override
  String committedSummary(int added, int diffs, int conflicts) {
    return 'Added $added new sessions. $diffs updates and $conflicts overlaps remain for review.';
  }

  @override
  String examImportCommittedSummary(int added, int skipped) {
    return 'Imported $added exam records and skipped $skipped duplicates.';
  }

  @override
  String get importWarningUnsupportedFileType =>
      'This file type is not supported yet. Choose a timetable spreadsheet or calendar file.';

  @override
  String get importWarningWorkbookReadFailed =>
      'Could not read this .xls file. Check that the file is not damaged.';

  @override
  String get importWarningNoCompleteXlsRows =>
      'The file looks like a timetable, but no complete courses were found.';

  @override
  String importWarningXlsParsedSessions(int count) {
    return 'Recognized $count class sessions from the spreadsheet.';
  }

  @override
  String get importWarningNoCoursesFromHtml =>
      'No courses were recognized from the table.';

  @override
  String get importWarningDecodedWithFallback =>
      'The file encoding was converted automatically.';

  @override
  String get importWarningFragmentMissingName =>
      'One course block was missing a course name and was skipped.';

  @override
  String get importWarningMissingWeekday =>
      'One class time was missing a weekday and was skipped.';

  @override
  String get importWarningMissingPeriod =>
      'One class time was missing class periods and was skipped.';

  @override
  String get importWarningMissingWeeks =>
      'One class time was missing week numbers and was skipped.';

  @override
  String get importWarningNoCompleteEntries =>
      'Class-time text was found, but no complete courses were recognized.';

  @override
  String get importWarningIcsParseFailed =>
      'Could not read this calendar file. Check that the file format is valid.';

  @override
  String get importWarningSkippedIcsEvent =>
      'One calendar event was missing a course name or time and was skipped.';

  @override
  String get importWarningIcsRuleFallback =>
      'One repeating course could not be fully expanded and was imported as a single class.';

  @override
  String get importWarningGenericError =>
      'Some file content could not be read.';

  @override
  String get importWarningGenericWarning =>
      'Some file content could not be recognized.';

  @override
  String get importWarningGenericInfo =>
      'Some file content was handled automatically during import.';

  @override
  String get course => 'Course';

  @override
  String get time => 'Time';

  @override
  String get weeks => 'Weeks';

  @override
  String get examRound => 'Exam round';

  @override
  String get examTime => 'Exam time';

  @override
  String get seatNumber => 'Seat';

  @override
  String get recentBatches => 'Recent batches';

  @override
  String failedToLoadHistory(Object error) {
    return 'Failed to load import history: $error';
  }

  @override
  String get noImportBatchesYet => 'No import batches yet';

  @override
  String get committedImportsAppearHere => 'Finished imports will appear here.';

  @override
  String batchSubtitle(String type, String summary, String date) {
    return '$type - $summary - $date';
  }

  @override
  String failedToLoadConflicts(Object error) {
    return 'Failed to load conflicts: $error';
  }

  @override
  String get noPendingConflicts => 'No imports need review';

  @override
  String get conflictHandling => 'Conflict handling';

  @override
  String get conflictHandlingSubtitle =>
      'Review imported courses that need a choice before they can be added cleanly.';

  @override
  String changedFieldsCount(int count) {
    return '$count changed fields';
  }

  @override
  String timeConflictsCount(int count) {
    return '$count time conflicts';
  }

  @override
  String pendingCount(int count) {
    return '$count need review';
  }

  @override
  String get conflict => 'Conflict';

  @override
  String get changed => 'Changed';

  @override
  String get currentValue => 'Current';

  @override
  String get importedValue => 'Imported';

  @override
  String get keepCurrent => 'Keep current';

  @override
  String get useImported => 'Use imported';

  @override
  String get keepBoth => 'Keep both';

  @override
  String get forceMerge => 'Keep overlapping';

  @override
  String get manualEdit => 'Manual edit';

  @override
  String conflictMarked(String action) {
    return 'Choice saved: $action.';
  }

  @override
  String courseSummary(
    int weekday,
    String period,
    String weeks,
    String teacher,
    String location,
  ) {
    return 'Weekday $weekday, period $period, $weeks, $teacher, $location';
  }

  @override
  String get weekUnknown => 'Week unknown';

  @override
  String get teacherTbd => 'Teacher TBD';

  @override
  String get locationTbd => 'Location TBD';

  @override
  String changedFields(String fields) {
    return 'Changed fields';
  }

  @override
  String get timeOverlap => 'Time overlap';

  @override
  String get icsCalendarExport => 'ICS calendar export';

  @override
  String get icsCalendarExportSubtitle =>
      'Export the active timetable as a calendar file.';

  @override
  String get exportIcs => 'Export ICS';

  @override
  String get currentWeekImage => 'Current-week image';

  @override
  String get currentWeekImageSubtitle =>
      'Capture the visible timetable week as a PNG.';

  @override
  String get fullSemesterImage => 'Full-semester image';

  @override
  String get fullSemesterImageSubtitle =>
      'Capture every teaching week as one long PNG.';

  @override
  String get exportPng => 'Export PNG';

  @override
  String get exportTimetableCalendar => 'Export timetable calendar';

  @override
  String get exportTimetableImage => 'Export timetable image';

  @override
  String get exportSemesterTimetableImage => 'Export semester timetable image';

  @override
  String exportedPath(String path) {
    return 'Exported to $path';
  }

  @override
  String get openExportedFile => 'Open';

  @override
  String get preparingExport => 'Preparing export';

  @override
  String openExportedFileFailed(String message) {
    return 'Could not open file: $message';
  }

  @override
  String get fullSemester => 'Full semester';

  @override
  String failedToLoadReminderSettings(Object error) {
    return 'Failed to load reminder settings: $error';
  }

  @override
  String failedToLoadLanguageSetting(Object error) {
    return 'Failed to load language setting: $error';
  }

  @override
  String failedToLoadThemeSetting(Object error) {
    return 'Failed to load theme setting: $error';
  }

  @override
  String failedToLoadTimetableDisplaySetting(Object error) {
    return 'Failed to load timetable display setting: $error';
  }

  @override
  String failedToLoadExportDisplaySetting(Object error) {
    return 'Failed to load export display setting: $error';
  }

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Follow system';

  @override
  String get languageSimplifiedChinese => 'Simplified Chinese';

  @override
  String get languageTraditionalChinese => 'Traditional Chinese';

  @override
  String get languageEnglish => 'English';

  @override
  String get display => 'Display';

  @override
  String get showNonCurrentWeekCourses =>
      'Show courses outside the current week';

  @override
  String get showNonCurrentWeekCoursesSubtitle =>
      'Courses not held in the selected week appear in gray on the timetable.';

  @override
  String get exportDisplaySettings => 'Export display';

  @override
  String get showNonCurrentWeekCoursesInExportSubtitle =>
      'Courses not held in each week appear in gray in weekly and full-semester PNG exports.';

  @override
  String get themeModeSystem => 'Follow system';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get denseTimetable => 'Dense timetable';

  @override
  String get denseTimetableSubtitle => 'Reserved for a future compact view.';

  @override
  String get localData => 'Local data';

  @override
  String get localDataSubtitle =>
      'Timetables, imports, and reminders are stored on this device.';

  @override
  String get backupLocalData => 'Back up locally';

  @override
  String get restoreLocalData => 'Restore from backup';

  @override
  String backupCreated(String path) {
    return 'Backup saved to $path';
  }

  @override
  String get backupRestored => 'Data and settings restored.';

  @override
  String localDataActionFailed(Object error) {
    return 'Local data action failed: $error';
  }

  @override
  String get offlineAppSubtitle =>
      'Offline-first timetable app for campus schedules.';

  @override
  String get thirdPartyLicenses => 'Open-source licenses';

  @override
  String get thirdPartyLicensesSubtitle =>
      'View open-source licenses for Crid, Flutter, and app dependencies.';

  @override
  String get appLicenseDisplayName => 'Crid';

  @override
  String get appLicenseSummary =>
      'Crid is licensed under Apache License 2.0. Keep LICENSE and NOTICE attribution when redistributing.';

  @override
  String get reminders => 'Reminders';

  @override
  String reminderNotificationTitle(int minutes) {
    return 'Class starts in $minutes min';
  }

  @override
  String get courseReminders => 'Course reminders';

  @override
  String get courseRemindersSubtitle =>
      'Automatically update reminders for the next four weeks after timetable changes.';

  @override
  String get androidBackgroundSettings => 'Android background running';

  @override
  String get androidBackgroundSettingsSubtitle =>
      'Allows course reminders to continue when the system limits background tasks.';

  @override
  String get androidBackgroundUnsupported =>
      'This setting is available on Android devices only.';

  @override
  String get androidDeviceStatusTitle => 'Android device';

  @override
  String androidDeviceStatus(
    String manufacturer,
    String model,
    String version,
  ) {
    return '$manufacturer $model, Android $version';
  }

  @override
  String failedToLoadAndroidBackgroundStatus(Object error) {
    return 'Failed to load Android background status: $error';
  }

  @override
  String get windowsReminderSettings => 'Windows reminders';

  @override
  String get windowsReminderSettingsSubtitle =>
      'Windows schedules enabled reminders with the system, so Crid does not need to remain open.';

  @override
  String get windowsSystemNotifications => 'System notifications';

  @override
  String get windowsNotificationsAllowed =>
      'Enabled. Scheduled reminders can appear after Crid is closed.';

  @override
  String get windowsNotificationsBlocked =>
      'Notifications are disabled in Windows. Enable them in system settings to receive course reminders.';

  @override
  String failedToLoadWindowsReminderStatus(Object error) {
    return 'Failed to load Windows reminder status: $error';
  }

  @override
  String get persistentBackgroundRuntime => 'Continuous background running';

  @override
  String get persistentBackgroundRuntimeSubtitle =>
      'Shows a silent ongoing notification in the notification shade to maintain background reminder tasks.';

  @override
  String get persistentBackgroundRuntimeAllowed =>
      'Battery optimization exemption is enabled, reducing the effect of system battery limits on background tasks.';

  @override
  String get openNotificationSettings => 'Notifications';

  @override
  String get openBatterySettings => 'Battery settings';

  @override
  String get openExactAlarmSettings => 'Exact alarm access';

  @override
  String get openAutostartSettings => 'Autostart';

  @override
  String get requestBatteryExemption => 'Request background access';

  @override
  String get leadTime => 'Remind me before class';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get customReminderTime => 'Custom time';

  @override
  String get minutesBeforeClass => 'Before class';

  @override
  String get minutesUnit => 'min';

  @override
  String get ignoreDoNotDisturb => 'Bypass Do Not Disturb';

  @override
  String get ignoreDoNotDisturbSubtitle =>
      'Android opens a system access page; after approval, the reminder channel can bypass DND.';

  @override
  String get windowsIgnoreDoNotDisturbSubtitle =>
      'Windows marks course reminders as urgent so they can break through Do Not Disturb.';

  @override
  String get vibrateReminder => 'Mute reminder sound';

  @override
  String get vibrateReminderSubtitle =>
      'Class reminders still vibrate, but no sound is played.';

  @override
  String get windowsMuteReminderSoundSubtitle =>
      'Windows shows course reminders silently; vibration depends on the device and system settings.';

  @override
  String get goToToday => 'Today';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String semesterEndDate(String date) {
    return 'End date: $date';
  }

  @override
  String get semesterStartDate => 'Semester start date';

  @override
  String get semesterEndDateOptional => 'Semester end date (optional)';

  @override
  String get noSemesterEndDate => 'No end date';

  @override
  String get chooseSemesterStartDate => 'Choose first-week Monday';

  @override
  String get chooseSemesterEndDate => 'Choose semester end date';

  @override
  String get addSemester => 'Add semester';

  @override
  String get editSemester => 'Edit semester';

  @override
  String get deleteSemester => 'Delete semester';

  @override
  String deleteSemesterConfirmation(String name) {
    return 'Delete semester \"$name\"? Courses and plans in it will be removed.';
  }

  @override
  String get cannotDeleteLastSemester => 'At least one semester is required.';

  @override
  String get semesterDeleted => 'Semester deleted';

  @override
  String get editPlan => 'Edit plan';

  @override
  String get deletePlan => 'Delete plan';

  @override
  String deletePlanConfirmation(String name) {
    return 'Delete plan \"$name\"? Courses in it will be removed.';
  }

  @override
  String get cannotDeleteLastPlan =>
      'At least one plan is required in the active semester.';

  @override
  String get planDeleted => 'Plan deleted';

  @override
  String get semesterNameLabel => 'Semester name';

  @override
  String get planNameLabel => 'Plan name';

  @override
  String get hiddenCourses => 'Hidden courses';

  @override
  String get hiddenCoursesSubtitle =>
      'Restore courses that were hidden from the timetable.';

  @override
  String get noHiddenCourses => 'No hidden courses';

  @override
  String sessionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String failedToLoadHolidaySettings(Object error) {
    return 'Failed to load holiday mode settings: $error';
  }

  @override
  String get holidayMode => 'Holiday mode';

  @override
  String get legalHolidays => 'Legal holidays';

  @override
  String get legalHolidaysSubtitle =>
      'Automatically hide courses on China legal holiday dates without deleting course records.';

  @override
  String get holidayAdjustment => 'Holiday adjustment';

  @override
  String get holidayAdjustmentSubtitle =>
      'Choose whether classes follow the official holiday adjustment schedule.';

  @override
  String get holidayAdjustmentNoAdjustment => 'Do not adjust holidays';

  @override
  String get holidayAdjustmentMakeUpWorkdays => 'Follow adjusted class days';

  @override
  String get holidayAdjustmentNoMakeUpWorkdays =>
      'Rest on adjusted makeup days';

  @override
  String holidayDataLoading(int year) {
    return 'Fetching China holiday schedule for $year.';
  }

  @override
  String get holidayDataFailed =>
      'Could not fetch the holiday schedule. Try again later.';

  @override
  String holidayDataUnavailable(int year) {
    return 'No holiday schedule for $year is saved on this device.';
  }

  @override
  String holidayDataCached(int year) {
    return 'Using the last holiday schedule fetched for $year.';
  }

  @override
  String holidayDataUpdated(int year) {
    return 'Fetched China holiday schedule for $year.';
  }
}
