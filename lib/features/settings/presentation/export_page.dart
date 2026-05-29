import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crid/app/app_state.dart';
import 'package:crid/app/motion.dart';
import 'package:crid/core/theme/course_colors.dart';
import 'package:crid/features/settings/data/china_holiday_service.dart';
import 'package:crid/features/settings/data/holiday_settings_controller.dart';
import 'package:crid/features/timetable/data/timetable_repository.dart';
import 'package:crid/l10n/app_localizations.dart';
import 'package:crid/features/timetable/presentation/course_slot_model.dart';
import 'package:crid/l10n/l10n.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final exportFileServiceProvider = Provider<ExportFileService>(
  (ref) => const ExportFileService(),
);

class ExportFileService {
  const ExportFileService();

  Future<String?> saveFile({
    required String dialogTitle,
    required String fileName,
    required FileType type,
    required List<String> allowedExtensions,
    required Uint8List bytes,
  }) {
    return FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      type: type,
      allowedExtensions: allowedExtensions,
      bytes: bytes,
      lockParentWindow: true,
    );
  }

  Future<OpenResult> openFile(String path, {required String mimeType}) {
    return OpenFile.open(path, type: mimeType);
  }

  Future<String> openablePathFor({
    required String savedPath,
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (!Platform.isAndroid) {
      return savedPath;
    }
    final cacheDirectory = await getTemporaryDirectory();
    final file = File(p.join(cacheDirectory.path, 'exports', fileName));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}

class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key});

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage> {
  _ExportTask? _busyTask;

  @override
  Widget build(BuildContext context) {
    final busyTask = _busyTask;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        AnimatedSwitcher(
          duration: appMicroMotionDuration,
          switchInCurve: appMicroMotionCurve,
          switchOutCurve: appMicroMotionReverseCurve,
          child: busyTask == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(
                    semanticsLabel: context.l10n.preparingExport,
                  ),
                ),
        ),
        _ExportOptionCard(
          icon: Icons.event_available_outlined,
          title: context.l10n.icsCalendarExport,
          subtitle: context.l10n.icsCalendarExportSubtitle,
          actionLabel: context.l10n.exportIcs,
          busy: busyTask == _ExportTask.ics,
          onPressed: busyTask == null
              ? () => _runExport(_ExportTask.ics, _exportIcs)
              : null,
        ),
        const SizedBox(height: 12),
        _ExportOptionCard(
          icon: Icons.image_outlined,
          title: context.l10n.currentWeekImage,
          subtitle: context.l10n.currentWeekImageSubtitle,
          actionLabel: context.l10n.exportPng,
          busy: busyTask == _ExportTask.weekImage,
          onPressed: busyTask == null
              ? () => _runExport(_ExportTask.weekImage, _exportWeekImage)
              : null,
        ),
        const SizedBox(height: 12),
        _ExportOptionCard(
          icon: Icons.calendar_view_month_outlined,
          title: context.l10n.fullSemesterImage,
          subtitle: context.l10n.fullSemesterImageSubtitle,
          actionLabel: context.l10n.exportPng,
          busy: busyTask == _ExportTask.semesterImage,
          onPressed: busyTask == null
              ? () =>
                    _runExport(_ExportTask.semesterImage, _exportSemesterImage)
              : null,
        ),
      ],
    );
  }

  Future<void> _runExport(
    _ExportTask task,
    Future<void> Function() exportAction,
  ) async {
    if (_busyTask != null) {
      return;
    }
    setState(() {
      _busyTask = task;
    });
    await Future<void>.delayed(Duration.zero);
    try {
      await exportAction();
    } finally {
      if (mounted) {
        setState(() {
          _busyTask = null;
        });
      }
    }
  }

  Future<void> _exportIcs() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(timetableRepositoryProvider);
    final fileService = ref.read(exportFileServiceProvider);
    final content = await repository.exportActivePlanIcs();
    const fileName = 'crid.ics';
    final bytes = Uint8List.fromList(utf8.encode(content));
    final path = await fileService.saveFile(
      dialogTitle: l10n.exportTimetableCalendar,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['ics'],
      bytes: bytes,
    );
    if (path == null) {
      return;
    }
    final openPath = await fileService.openablePathFor(
      savedPath: path,
      fileName: fileName,
      bytes: bytes,
    );
    _showExportedSnackBar(
      messenger: messenger,
      l10n: l10n,
      fileService: fileService,
      path: path,
      openPath: openPath,
      mimeType: 'text/calendar',
    );
  }

  Future<void> _exportWeekImage() async {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final dayLabels = _dayLabels(context);
    final messenger = ScaffoldMessenger.of(context);
    final fileService = ref.read(exportFileServiceProvider);
    final week = ref.read(selectedWeekProvider);
    final snapshot = await ref.read(timetableRepositoryProvider).loadSnapshot();
    final dates = _datesForWeek(
      firstWeekMonday: snapshot.activeSemester.firstWeekMonday,
      week: week,
    );
    final holidaySettings = await ref.read(holidaySettingsProvider.future);
    final holidaySchedule = await ref.read(
      chinaHolidayScheduleProvider(dates.first.year).future,
    );
    final holidayRestDays = holidayRestDayFlags(
      dates: dates,
      settings: holidaySettings,
      schedule: holidaySchedule,
    );
    final bytes = await _renderWeekPng(
      theme: theme,
      week: week,
      title: '${snapshot.activeSemester.name} / ${snapshot.activePlan.name}',
      subtitle: l10n.weekNumber(week),
      monthLabel: _monthLabelForLocale(locale, dates),
      courses: snapshot.courses
          .where((course) => course.isActiveInWeek(week))
          .where(
            (course) => !_isHiddenByHoliday(
              course: course,
              dates: dates,
              settings: holidaySettings,
              schedule: holidaySchedule,
            ),
          ),
      dayLabels: dayLabels,
      dates: dates,
      holidayRestDays: holidayRestDays,
      weekLabelFor: (course) => _weekLabelForImage(l10n, course),
    );
    final fileName = 'crid-week-$week.png';
    final path = await fileService.saveFile(
      dialogTitle: l10n.exportTimetableImage,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['png'],
      bytes: bytes,
    );
    if (path == null) {
      return;
    }
    final openPath = await fileService.openablePathFor(
      savedPath: path,
      fileName: fileName,
      bytes: bytes,
    );
    _showExportedSnackBar(
      messenger: messenger,
      l10n: l10n,
      fileService: fileService,
      path: path,
      openPath: openPath,
      mimeType: 'image/png',
    );
  }

  Future<void> _exportSemesterImage() async {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final dayLabels = _dayLabels(context);
    final messenger = ScaffoldMessenger.of(context);
    final fileService = ref.read(exportFileServiceProvider);
    final snapshot = await ref.read(timetableRepositoryProvider).loadSnapshot();
    final holidaySettings = await ref.read(holidaySettingsProvider.future);
    final holidaySchedule = await ref.read(
      chinaHolidayScheduleProvider(
        snapshot.activeSemester.firstWeekMonday.year,
      ).future,
    );
    final weeks = _semesterExportWeeks(snapshot);
    final bytes = await _renderSemesterPng(
      theme: theme,
      weeks: weeks,
      title: '${snapshot.activeSemester.name} / ${snapshot.activePlan.name}',
      firstWeekMonday: snapshot.activeSemester.firstWeekMonday,
      monthLabelFor: (dates) => _monthLabelForLocale(locale, dates),
      courses: snapshot.courses,
      holidaySettings: holidaySettings,
      holidaySchedule: holidaySchedule,
      dayLabels: dayLabels,
      weekLabelFor: (course) => _weekLabelForImage(l10n, course),
      weekTitleFor: l10n.weekNumber,
    );
    const fileName = 'crid-semester.png';
    final path = await fileService.saveFile(
      dialogTitle: l10n.exportSemesterTimetableImage,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['png'],
      bytes: bytes,
    );
    if (path == null) {
      return;
    }
    final openPath = await fileService.openablePathFor(
      savedPath: path,
      fileName: fileName,
      bytes: bytes,
    );
    _showExportedSnackBar(
      messenger: messenger,
      l10n: l10n,
      fileService: fileService,
      path: path,
      openPath: openPath,
      mimeType: 'image/png',
    );
  }
}

enum _ExportTask { ics, weekImage, semesterImage }

void _showExportedSnackBar({
  required ScaffoldMessengerState messenger,
  required AppLocalizations l10n,
  required ExportFileService fileService,
  required String path,
  required String openPath,
  required String mimeType,
}) {
  messenger.showSnackBar(
    SnackBar(
      content: Text(l10n.exportedPath(path)),
      action: SnackBarAction(
        label: l10n.openExportedFile,
        onPressed: () {
          unawaited(
            _openExportedFile(messenger, l10n, fileService, openPath, mimeType),
          );
        },
      ),
    ),
  );
}

Future<void> _openExportedFile(
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  ExportFileService fileService,
  String path,
  String mimeType,
) async {
  final result = await fileService.openFile(path, mimeType: mimeType);
  if (result.type == ResultType.done) {
    return;
  }
  messenger.showSnackBar(
    SnackBar(content: Text(l10n.openExportedFileFailed(result.message))),
  );
}

bool _isHiddenByHoliday({
  required CourseSlot course,
  required List<DateTime> dates,
  required HolidaySettings settings,
  required ChinaHolidaySchedule schedule,
}) {
  if (course.weekday < 1 || course.weekday > dates.length) {
    return false;
  }
  return schedule.shouldHide(dates[course.weekday - 1], settings);
}

List<DateTime> _datesForWeek({
  required DateTime firstWeekMonday,
  required int week,
}) {
  final monday = DateTime(
    firstWeekMonday.year,
    firstWeekMonday.month,
    firstWeekMonday.day,
  ).add(Duration(days: (week - 1) * 7));
  return [
    for (var day = 0; day < DateTime.daysPerWeek; day++)
      monday.add(Duration(days: day)),
  ];
}

List<int> _semesterExportWeeks(TimetableSnapshot snapshot) {
  final endDateWeek = snapshot.activeSemester.endDate == null
      ? maxSemesterWeek
      : weekNumberForDate(
          firstWeekMonday: snapshot.activeSemester.firstWeekMonday,
          date: snapshot.activeSemester.endDate!,
        );
  final boundedEndWeek = endDateWeek.clamp(1, maxSemesterWeek).toInt();
  final lastActiveWeek =
      Iterable<int>.generate(boundedEndWeek, (index) => index + 1).lastWhere(
        (week) => snapshot.courses.any((course) => course.isActiveInWeek(week)),
        orElse: () => 1,
      );
  final exportEndWeek = math.min(lastActiveWeek, boundedEndWeek);
  return [for (var week = 1; week <= exportEndWeek; week++) week];
}

List<int> debugSemesterExportWeeks(TimetableSnapshot snapshot) {
  return _semesterExportWeeks(snapshot);
}

Future<Uint8List> _renderWeekPng({
  required ThemeData theme,
  required int week,
  required String title,
  required String subtitle,
  required String monthLabel,
  required Iterable<CourseSlot> courses,
  required List<String> dayLabels,
  required List<DateTime> dates,
  required List<bool> holidayRestDays,
  required String Function(CourseSlot course) weekLabelFor,
}) async {
  const width = 1600.0;
  const height = 1000.0;
  const left = 120.0;
  const top = 150.0;
  const headerHeight = 54.0;
  const rowHeight = 66.0;
  const dayWidth = (width - left - 48) / 7;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final colorScheme = theme.colorScheme;
  final timeColumnColor = colorScheme.brightness == Brightness.light
      ? colorScheme.surfaceContainerLow
      : colorScheme.surfaceContainerHighest;

  final paint = Paint()..color = colorScheme.surfaceContainerLowest;
  canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), paint);
  _drawText(
    canvas,
    title,
    const Offset(48, 36),
    34,
    colorScheme.onSurface,
    FontWeight.w700,
  );
  _drawText(
    canvas,
    subtitle,
    const Offset(48, 84),
    22,
    colorScheme.onSurfaceVariant,
    FontWeight.w500,
  );

  const periods = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  const times = [
    '08:00',
    '08:55',
    '10:00',
    '10:55',
    '13:30',
    '14:25',
    '15:30',
    '16:25',
    '18:00',
    '18:55',
    '19:50',
    '20:45',
  ];

  final gridPaint = Paint()
    ..color = colorScheme.outlineVariant
    ..strokeWidth = 1;
  canvas.drawRect(
    Rect.fromLTWH(48, top, width - 96, headerHeight),
    Paint()..color = colorScheme.surfaceContainerHighest,
  );
  canvas.drawRect(
    Rect.fromLTWH(
      48,
      top + headerHeight,
      left - 48,
      rowHeight * periods.length,
    ),
    Paint()..color = timeColumnColor,
  );
  canvas.drawRect(
    Rect.fromLTWH(
      left,
      top + headerHeight,
      width - left - 48,
      rowHeight * periods.length,
    ),
    Paint()..color = colorScheme.surfaceContainerHigh,
  );
  for (var day = 0; day < DateTime.daysPerWeek; day++) {
    if (!_isHolidayRestDay(holidayRestDays, day)) {
      continue;
    }
    final x = left + dayWidth * day;
    canvas.drawRect(
      Rect.fromLTWH(
        x,
        top,
        dayWidth,
        headerHeight + rowHeight * periods.length,
      ),
      Paint()..color = _holidayRestColumnColor(colorScheme),
    );
  }
  _drawText(
    canvas,
    monthLabel,
    const Offset(64, top + 17),
    16,
    colorScheme.onSurfaceVariant,
    FontWeight.w700,
    maxWidth: left - 80,
    maxLines: 1,
  );
  for (var day = 0; day < dayLabels.length; day++) {
    final date = day < dates.length ? dates[day] : null;
    final isToday = date != null && DateUtils.isSameDay(date, DateTime.now());
    final holidayRestDay = _isHolidayRestDay(holidayRestDays, day);
    final centerX = left + dayWidth * day + dayWidth / 2;
    _drawText(
      canvas,
      dayLabels[day],
      Offset(centerX - 30, top + 8),
      17,
      isToday
          ? colorScheme.primary
          : holidayRestDay
          ? colorScheme.onSurfaceVariant
          : colorScheme.onSurface,
      isToday || holidayRestDay ? FontWeight.w700 : FontWeight.w500,
      maxWidth: 60,
      maxLines: 1,
    );
    if (date != null) {
      if (isToday) {
        canvas.drawCircle(
          Offset(centerX, top + 38),
          14,
          Paint()..color = colorScheme.primary,
        );
      }
      _drawText(
        canvas,
        '${date.day}',
        Offset(centerX - 14, top + 28),
        14,
        isToday ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        isToday || holidayRestDay ? FontWeight.w700 : FontWeight.w500,
        maxWidth: 28,
        maxLines: 1,
      );
    }
  }
  for (var row = 0; row < periods.length; row++) {
    final y = top + headerHeight + rowHeight * row;
    canvas.drawLine(Offset(48, y), Offset(width - 48, y), gridPaint);
    _drawText(
      canvas,
      '${periods[row]}',
      Offset(78, y + 18),
      19,
      colorScheme.onSurface,
      FontWeight.w700,
      maxWidth: 32,
      maxLines: 1,
    );
    _drawText(
      canvas,
      times[row],
      Offset(66, y + 43),
      14,
      colorScheme.onSurfaceVariant,
      FontWeight.w400,
      maxWidth: 56,
      maxLines: 1,
    );
  }
  for (var day = 0; day <= 7; day++) {
    final x = left + dayWidth * day;
    canvas.drawLine(
      Offset(x, top),
      Offset(x, top + headerHeight + rowHeight * periods.length),
      gridPaint,
    );
  }

  for (final layout in _exportCourseBlockLayouts(courses.toList())) {
    final course = layout.course;
    if (course.weekday < 1 || course.weekday > 7) {
      continue;
    }
    final columnCount = layout.overlapCount < 1 ? 1 : layout.overlapCount;
    final columnGap = columnCount > 1 ? 3.0 : 0.0;
    final availableWidth = dayWidth - 16;
    final blockWidth =
        (availableWidth - columnGap * (columnCount - 1)) / columnCount;
    final start = course.startPeriod.clamp(1, periods.length).toInt();
    final end = course.endPeriod.clamp(start, periods.length).toInt();
    final row = start - 1;
    final blockHeight = rowHeight * (end - start + 1) - 16;
    final x =
        left +
        dayWidth * (course.weekday - 1) +
        8 +
        (blockWidth + columnGap) * layout.overlapIndex;
    final y = top + headerHeight + rowHeight * row + 8;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, blockWidth, blockHeight),
      const Radius.circular(10),
    );
    canvas.drawRRect(rect, Paint()..color = course.color);
    canvas.save();
    canvas.clipRRect(rect);
    final textColor = readableCourseTextColor(course.color);
    var cursorY = y + 12;
    cursorY += _drawText(
      canvas,
      course.name,
      Offset(x + 14, cursorY),
      18,
      textColor,
      FontWeight.w700,
      maxWidth: blockWidth - 28,
      maxLines: blockHeight < 88 ? 1 : 2,
    );
    final details = [
      if (course.location.isNotEmpty) course.location,
      if (course.teacher.isNotEmpty) course.teacher,
      if (week == 0 && blockHeight >= 106) weekLabelFor(course),
    ];
    for (final detail in details) {
      if (cursorY + 18 > y + blockHeight - 8) {
        break;
      }
      cursorY += _drawText(
        canvas,
        detail,
        Offset(x + 14, cursorY + 3),
        13,
        textColor,
        FontWeight.w500,
        maxWidth: blockWidth - 28,
        maxLines: 1,
      );
    }
    canvas.restore();
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(width.toInt(), height.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

Future<Uint8List> _renderSemesterPng({
  required ThemeData theme,
  required List<int> weeks,
  required String title,
  required DateTime firstWeekMonday,
  required String Function(List<DateTime> dates) monthLabelFor,
  required List<CourseSlot> courses,
  required HolidaySettings holidaySettings,
  required ChinaHolidaySchedule holidaySchedule,
  required List<String> dayLabels,
  required String Function(CourseSlot course) weekLabelFor,
  required String Function(int week) weekTitleFor,
}) async {
  final weekImages = <ui.Image>[];
  for (final week in weeks) {
    final dates = _datesForWeek(firstWeekMonday: firstWeekMonday, week: week);
    final bytes = await _renderWeekPng(
      theme: theme,
      week: week,
      title: title,
      subtitle: weekTitleFor(week),
      monthLabel: monthLabelFor(dates),
      courses: courses
          .where((course) => course.isActiveInWeek(week))
          .where(
            (course) => !_isHiddenByHoliday(
              course: course,
              dates: dates,
              settings: holidaySettings,
              schedule: holidaySchedule,
            ),
          ),
      dayLabels: dayLabels,
      holidayRestDays: holidayRestDayFlags(
        dates: dates,
        settings: holidaySettings,
        schedule: holidaySchedule,
      ),
      dates: dates,
      weekLabelFor: weekLabelFor,
    );
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    weekImages.add(frame.image);
  }

  const gap = 28;
  final width = weekImages.fold<int>(
    1,
    (maxWidth, image) => math.max(maxWidth, image.width),
  );
  final height =
      weekImages.fold<int>(0, (sum, image) => sum + image.height) +
      math.max(0, weekImages.length - 1) * gap;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = theme.colorScheme.surfaceContainerLowest,
  );
  var top = 0.0;
  for (final image in weekImages) {
    canvas.drawImage(image, Offset(0, top), Paint());
    top += image.height + gap;
  }
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

class _ExportCourseBlockLayout {
  const _ExportCourseBlockLayout({
    required this.course,
    required this.overlapIndex,
    required this.overlapCount,
  });

  final CourseSlot course;
  final int overlapIndex;
  final int overlapCount;
}

List<_ExportCourseBlockLayout> _exportCourseBlockLayouts(
  List<CourseSlot> courses,
) {
  final layouts = <_ExportCourseBlockLayout>[];
  final coursesByDay = <int, List<CourseSlot>>{};
  for (final course in courses) {
    if (course.weekday < 1 || course.weekday > 7) {
      continue;
    }
    coursesByDay.putIfAbsent(course.weekday, () => []).add(course);
  }

  for (final dayCourses in coursesByDay.values) {
    final sorted = [...dayCourses]..sort(_compareExportCourseBlocks);
    var group = <CourseSlot>[];
    var groupEndPeriod = 0;

    void flushGroup() {
      if (group.isEmpty) {
        return;
      }
      layouts.addAll(_assignExportOverlapLanes(group));
      group = <CourseSlot>[];
      groupEndPeriod = 0;
    }

    for (final course in sorted) {
      if (group.isEmpty || course.startPeriod <= groupEndPeriod) {
        group.add(course);
        groupEndPeriod = math.max(groupEndPeriod, course.endPeriod);
      } else {
        flushGroup();
        group.add(course);
        groupEndPeriod = course.endPeriod;
      }
    }
    flushGroup();
  }
  return layouts;
}

int _compareExportCourseBlocks(CourseSlot a, CourseSlot b) {
  final byStart = a.startPeriod.compareTo(b.startPeriod);
  if (byStart != 0) {
    return byStart;
  }
  final byEnd = b.endPeriod.compareTo(a.endPeriod);
  if (byEnd != 0) {
    return byEnd;
  }
  return a.name.compareTo(b.name);
}

List<_ExportCourseBlockLayout> _assignExportOverlapLanes(
  List<CourseSlot> group,
) {
  final laneEndPeriods = <int>[];
  final laneByCourse = <CourseSlot, int>{};

  for (final course in group) {
    final lane = laneEndPeriods.indexWhere(
      (endPeriod) => endPeriod < course.startPeriod,
    );
    if (lane == -1) {
      laneByCourse[course] = laneEndPeriods.length;
      laneEndPeriods.add(course.endPeriod);
    } else {
      laneByCourse[course] = lane;
      laneEndPeriods[lane] = course.endPeriod;
    }
  }

  final overlapCount = laneEndPeriods.length;
  return [
    for (final course in group)
      _ExportCourseBlockLayout(
        course: course,
        overlapIndex: laneByCourse[course] ?? 0,
        overlapCount: overlapCount,
      ),
  ];
}

List<String> _dayLabels(BuildContext context) {
  final l10n = context.l10n;
  return [
    l10n.dayMon,
    l10n.dayTue,
    l10n.dayWed,
    l10n.dayThu,
    l10n.dayFri,
    l10n.daySat,
    l10n.daySun,
  ];
}

String _monthLabelForLocale(Locale locale, List<DateTime> dates) {
  final monthDate = _monthDateForHeader(dates);
  return DateFormat.MMMM(locale.toString()).format(monthDate);
}

DateTime _monthDateForHeader(List<DateTime> dates) {
  final today = DateTime.now();
  for (final date in dates) {
    if (DateUtils.isSameDay(date, today)) {
      return today;
    }
  }
  return dates.isEmpty ? today : dates[dates.length ~/ 2];
}

bool _isHolidayRestDay(List<bool> restDays, int zeroBasedDay) {
  return zeroBasedDay >= 0 &&
      zeroBasedDay < restDays.length &&
      restDays[zeroBasedDay];
}

Color _holidayRestColumnColor(ColorScheme colorScheme) {
  final alpha = colorScheme.brightness == Brightness.light ? 0.08 : 0.14;
  return colorScheme.onSurface.withValues(alpha: alpha);
}

String _weekLabelForImage(AppLocalizations l10n, CourseSlot course) {
  final base = l10n.weeksValue(course.startWeek, course.endWeek);
  return switch (course.parity) {
    WeekParity.all => base,
    WeekParity.odd => '$base ${l10n.oddWeeks}',
    WeekParity.even => '$base ${l10n.evenWeeks}',
  };
}

double _drawText(
  Canvas canvas,
  String text,
  Offset offset,
  double fontSize,
  Color color,
  FontWeight weight, {
  double maxWidth = 900,
  int maxLines = 2,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontSize: fontSize, color: color, fontWeight: weight),
    ),
    textDirection: ui.TextDirection.ltr,
    maxLines: maxLines,
    ellipsis: '...',
  )..layout(maxWidth: maxWidth);
  painter.paint(canvas, offset);
  return painter.height;
}

class _ExportOptionCard extends StatelessWidget {
  const _ExportOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.busy,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(subtitle),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonal(
              onPressed: onPressed,
              child: AnimatedSwitcher(
                duration: appMicroMotionDuration,
                switchInCurve: appMicroMotionCurve,
                switchOutCurve: appMicroMotionReverseCurve,
                child: busy
                    ? SizedBox.square(
                        key: const ValueKey('busy'),
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          semanticsLabel: context.l10n.preparingExport,
                        ),
                      )
                    : Text(actionLabel, key: const ValueKey('label')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
