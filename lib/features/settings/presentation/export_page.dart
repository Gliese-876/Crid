import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crid/app/app_state.dart';
import 'package:crid/app/motion.dart';
import 'package:crid/core/time/period.dart';
import 'package:crid/core/theme/course_colors.dart';
import 'package:crid/features/settings/data/china_holiday_service.dart';
import 'package:crid/features/settings/data/holiday_settings_controller.dart';
import 'package:crid/features/timetable/data/timetable_repository.dart';
import 'package:crid/l10n/app_localizations.dart';
import 'package:crid/features/timetable/presentation/course_slot_model.dart';
import 'package:crid/l10n/l10n.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
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
    final visibleCourses = snapshot.courses
        .where((course) => course.isActiveInWeek(week))
        .where(
          (course) => !_isHiddenByHoliday(
            course: course,
            dates: dates,
            settings: holidaySettings,
            schedule: holidaySchedule,
          ),
        )
        .toList();
    final bytes = await _renderWeekPng(
      theme: theme,
      week: week,
      title: '${snapshot.activeSemester.name} / ${snapshot.activePlan.name}',
      subtitle: l10n.weekNumber(week),
      monthLabel: _monthLabelForLocale(locale, dates),
      courses: visibleCourses,
      holidayMutedCourseIds: _holidayMutedCourseIds(
        courses: visibleCourses,
        dates: dates,
        settings: holidaySettings,
        schedule: holidaySchedule,
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

HolidayCourseDisplayMode _holidayDisplayMode({
  required CourseSlot course,
  required List<DateTime> dates,
  required HolidaySettings settings,
  required ChinaHolidaySchedule schedule,
}) {
  return holidayCourseDisplayModeForWeekday(
    weekday: course.weekday,
    isExam: course.isExam,
    dates: dates,
    settings: settings,
    schedule: schedule,
  );
}

bool _isHiddenByHoliday({
  required CourseSlot course,
  required List<DateTime> dates,
  required HolidaySettings settings,
  required ChinaHolidaySchedule schedule,
}) {
  return _holidayDisplayMode(
        course: course,
        dates: dates,
        settings: settings,
        schedule: schedule,
      ) ==
      HolidayCourseDisplayMode.hidden;
}

Set<String> _holidayMutedCourseIds({
  required Iterable<CourseSlot> courses,
  required List<DateTime> dates,
  required HolidaySettings settings,
  required ChinaHolidaySchedule schedule,
}) {
  return {
    for (final course in courses)
      if (_holidayDisplayMode(
            course: course,
            dates: dates,
            settings: settings,
            schedule: schedule,
          ) ==
          HolidayCourseDisplayMode.muted)
        course.id,
  };
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

TimetableImageExportTimeRange debugWeekImageExportTimeRange(
  Iterable<CourseSlot> courses,
) {
  return _weekImageExportTimeRange(courses);
}

int debugWeekImageExportPixelWidth() {
  return _exportScaledImageDimension(
    _exportImageWidth,
    _exportWeekImagePixelRatio,
  );
}

int debugSemesterWeekImageExportPixelWidth() {
  return _exportScaledImageDimension(
    _exportImageWidth,
    _exportSemesterWeekImagePixelRatio,
  );
}

class TimetableImageExportTimeRange {
  const TimetableImageExportTimeRange({
    required this.startMinute,
    required this.endMinute,
  }) : assert(startMinute >= 0),
       assert(endMinute > startMinute),
       assert(endMinute <= minutesPerDay);

  final int startMinute;
  final int endMinute;

  int get durationMinutes => endMinute - startMinute;
}

const _exportImageWidth = 2400.0;
const _exportWeekImagePixelRatio = 2.0;
const _exportSemesterWeekImagePixelRatio = 1.25;
const _exportHorizontalPadding = 64.0;
const _exportTitleTop = 36.0;
const _exportSubtitleTop = 84.0;
const _exportGridTop = 150.0;
const _exportHeaderHeight = 82.0;
const _exportHeaderWeekdayTop = 14.0;
const _exportHeaderDateTop = 48.0;
const _exportTodayCircleCenterY = 58.0;
const _exportTodayCircleRadius = 15.0;
const _exportGutterWidth = 108.0;
const _exportHourHeight = 72.0;
const _exportBottomPadding = 48.0;
const _exportSemesterWeekGap = 28.0;
const _exportSemesterSidePadding = 40.0;
const _exportSemesterPngCompressionLevel = 4;
const _exportMinimumCourseBlockHeight = 36.0;
const _exportCourseBlockVerticalInset = 1.0;

Future<Uint8List> _renderWeekPng({
  required ThemeData theme,
  required int week,
  required String title,
  required String subtitle,
  required String monthLabel,
  required Iterable<CourseSlot> courses,
  required Set<String> holidayMutedCourseIds,
  required List<String> dayLabels,
  required List<DateTime> dates,
  required List<bool> holidayRestDays,
  required String Function(CourseSlot course) weekLabelFor,
  double pixelRatio = _exportWeekImagePixelRatio,
}) async {
  assert(pixelRatio > 0);
  final courseList = courses.toList();
  final timeRange = _weekImageExportTimeRange(courseList);
  const width = _exportImageWidth;
  const gridLeft = _exportHorizontalPadding;
  const gridRight = width - _exportHorizontalPadding;
  const gridTop = _exportGridTop;
  const headerHeight = _exportHeaderHeight;
  const gutterWidth = _exportGutterWidth;
  const hourHeight = _exportHourHeight;
  final gridWidth = gridRight - gridLeft;
  final bodyTop = gridTop + headerHeight;
  final bodyHeight = _exportTimelineBodyHeight(timeRange, hourHeight);
  final height = bodyTop + bodyHeight + _exportBottomPadding;
  final dayGridLeft = gridLeft + gutterWidth;
  final dayWidth = (gridWidth - gutterWidth) / 7;
  final imageWidth = _exportScaledImageDimension(width, pixelRatio);
  final imageHeight = _exportScaledImageDimension(height, pixelRatio);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(pixelRatio);
  final colorScheme = theme.colorScheme;
  final timeColumnColor = colorScheme.brightness == Brightness.light
      ? colorScheme.surfaceContainerLow
      : colorScheme.surfaceContainerHighest;

  final paint = Paint()..color = colorScheme.surfaceContainerLowest;
  canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
  _drawText(
    canvas,
    title,
    const Offset(_exportHorizontalPadding, _exportTitleTop),
    34,
    colorScheme.onSurface,
    FontWeight.w700,
  );
  _drawText(
    canvas,
    subtitle,
    const Offset(_exportHorizontalPadding, _exportSubtitleTop),
    22,
    colorScheme.onSurfaceVariant,
    FontWeight.w500,
  );

  final gridPaint = Paint()
    ..color = colorScheme.outlineVariant
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;
  canvas.drawRect(
    Rect.fromLTWH(gridLeft, gridTop, gridWidth, headerHeight),
    Paint()..color = colorScheme.surfaceContainerHighest,
  );
  canvas.drawRect(
    Rect.fromLTWH(gridLeft, bodyTop, gutterWidth, bodyHeight),
    Paint()..color = timeColumnColor,
  );
  canvas.drawRect(
    Rect.fromLTWH(dayGridLeft, bodyTop, gridRight - dayGridLeft, bodyHeight),
    Paint()..color = colorScheme.surfaceContainerHigh,
  );
  for (var day = 0; day < DateTime.daysPerWeek; day++) {
    if (!_isHolidayRestDay(holidayRestDays, day)) {
      continue;
    }
    final x = dayGridLeft + dayWidth * day;
    canvas.drawRect(
      Rect.fromLTWH(x, gridTop, dayWidth, headerHeight + bodyHeight),
      Paint()..color = _holidayRestColumnColor(colorScheme),
    );
  }
  _drawTextInRect(
    canvas,
    monthLabel,
    Rect.fromLTWH(gridLeft, gridTop, gutterWidth, headerHeight),
    16,
    colorScheme.onSurfaceVariant,
    FontWeight.w700,
    maxLines: 1,
    textAlign: TextAlign.center,
  );
  for (var day = 0; day < dayLabels.length; day++) {
    final date = day < dates.length ? dates[day] : null;
    final isToday = date != null && DateUtils.isSameDay(date, DateTime.now());
    final holidayRestDay = _isHolidayRestDay(holidayRestDays, day);
    final cellLeft = dayGridLeft + dayWidth * day;
    final centerX = cellLeft + dayWidth / 2;
    _drawText(
      canvas,
      dayLabels[day],
      Offset(cellLeft, gridTop + _exportHeaderWeekdayTop),
      17,
      isToday
          ? colorScheme.primary
          : holidayRestDay
          ? colorScheme.onSurfaceVariant
          : colorScheme.onSurface,
      isToday || holidayRestDay ? FontWeight.w700 : FontWeight.w500,
      maxWidth: dayWidth,
      maxLines: 1,
      textAlign: TextAlign.center,
    );
    if (date != null) {
      if (isToday) {
        canvas.drawCircle(
          Offset(centerX, gridTop + _exportTodayCircleCenterY),
          _exportTodayCircleRadius,
          Paint()..color = colorScheme.primary,
        );
      }
      _drawText(
        canvas,
        '${date.day}',
        Offset(cellLeft, gridTop + _exportHeaderDateTop),
        14,
        isToday ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        isToday || holidayRestDay ? FontWeight.w700 : FontWeight.w500,
        maxWidth: dayWidth,
        maxLines: 1,
        textAlign: TextAlign.center,
      );
    }
  }

  for (final segment in _exportTimeColumnSegments(timeRange: timeRange)) {
    final startY =
        bodyTop +
        _exportMinuteOffset(segment.startMinute, timeRange, hourHeight);
    final endY =
        bodyTop + _exportMinuteOffset(segment.endMinute, timeRange, hourHeight);
    final rect = Rect.fromLTRB(gridLeft, startY, dayGridLeft, endY);
    canvas.drawRect(rect, Paint()..color = timeColumnColor);
    canvas.drawRect(rect, gridPaint);
    canvas.save();
    canvas.clipRect(rect);
    _drawTextInRect(
      canvas,
      segment.label,
      rect.deflate(6),
      13,
      colorScheme.onSurface,
      FontWeight.w600,
      maxLines: 3,
      textAlign: TextAlign.center,
    );
    canvas.restore();
  }

  for (final minute in _exportTimelineGuideMinutes(timeRange)) {
    final y = bodyTop + _exportMinuteOffset(minute, timeRange, hourHeight);
    canvas.drawLine(Offset(gridLeft, y), Offset(gridRight, y), gridPaint);
  }
  for (var day = 0; day <= 7; day++) {
    final x = dayGridLeft + dayWidth * day;
    canvas.drawLine(
      Offset(x, gridTop),
      Offset(x, bodyTop + bodyHeight),
      gridPaint,
    );
  }
  canvas.drawLine(
    Offset(gridLeft, gridTop),
    Offset(gridRight, gridTop),
    gridPaint,
  );
  canvas.drawLine(
    Offset(gridLeft, bodyTop),
    Offset(gridRight, bodyTop),
    gridPaint,
  );
  canvas.drawLine(
    Offset(gridLeft, bodyTop + bodyHeight),
    Offset(gridRight, bodyTop + bodyHeight),
    gridPaint,
  );

  for (final layout in _exportCourseBlockLayouts(courseList)) {
    final course = layout.course;
    if (course.weekday < 1 || course.weekday > 7) {
      continue;
    }
    final columnCount = layout.overlapCount < 1 ? 1 : layout.overlapCount;
    final columnGap = columnCount > 1 ? 2.0 : 0.0;
    final availableWidth = dayWidth - 4;
    final blockWidth =
        (availableWidth - columnGap * (columnCount - 1)) / columnCount;
    final startMinute = course.startMinuteOfDay
        .clamp(timeRange.startMinute, timeRange.endMinute - 1)
        .toInt();
    final endMinute = course.endMinuteOfDay
        .clamp(startMinute + 1, timeRange.endMinute)
        .toInt();
    final blockTop = _exportMinuteOffset(startMinute, timeRange, hourHeight);
    final naturalBlockHeight = math.max(
      _exportMinimumCourseBlockHeight,
      _exportMinuteOffset(endMinute, timeRange, hourHeight) -
          _exportMinuteOffset(startMinute, timeRange, hourHeight) -
          _exportCourseBlockVerticalInset * 2,
    );
    final maxBlockHeight = math.max(
      1.0,
      bodyHeight - blockTop - _exportCourseBlockVerticalInset,
    );
    final blockHeight = naturalBlockHeight
        .clamp(1.0, maxBlockHeight)
        .toDouble();
    final x =
        dayGridLeft +
        dayWidth * (course.weekday - 1) +
        2 +
        (blockWidth + columnGap) * layout.overlapIndex;
    final y = bodyTop + blockTop + _exportCourseBlockVerticalInset;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, blockWidth, blockHeight),
      const Radius.circular(8),
    );
    final mutedByHoliday = holidayMutedCourseIds.contains(course.id);
    final blockColor = mutedByHoliday
        ? _holidayMutedCourseColor(colorScheme)
        : course.color;
    canvas.drawRRect(rect, Paint()..color = blockColor);
    if (mutedByHoliday) {
      canvas.drawRRect(
        rect.deflate(0.5),
        Paint()
          ..color = colorScheme.outlineVariant.withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    canvas.save();
    canvas.clipRRect(rect);
    final textColor = mutedByHoliday
        ? colorScheme.onSurfaceVariant
        : readableCourseTextColor(course.color);
    var cursorY = y + 6;
    cursorY += _drawText(
      canvas,
      course.name,
      Offset(x + 7, cursorY),
      18,
      textColor,
      FontWeight.w700,
      maxWidth: blockWidth - 14,
      maxLines: blockHeight < 88 ? 1 : 2,
    );
    final details = [
      if (course.location.isNotEmpty) course.location,
      if (course.teacher.isNotEmpty) course.teacher,
      if (week == 0 && blockHeight >= 106) weekLabelFor(course),
    ];
    for (final detail in details) {
      if (cursorY + 16 > y + blockHeight - 6) {
        break;
      }
      cursorY += _drawText(
        canvas,
        detail,
        Offset(x + 7, cursorY + 2),
        13,
        textColor,
        FontWeight.w500,
        maxWidth: blockWidth - 14,
        maxLines: 1,
      );
    }
    canvas.restore();
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(imageWidth, imageHeight);
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
  final weekImages = <_EncodedWeekImage>[];
  for (final week in weeks) {
    final dates = _datesForWeek(firstWeekMonday: firstWeekMonday, week: week);
    final visibleCourses = courses
        .where((course) => course.isActiveInWeek(week))
        .where(
          (course) => !_isHiddenByHoliday(
            course: course,
            dates: dates,
            settings: holidaySettings,
            schedule: holidaySchedule,
          ),
        )
        .toList();
    final bytes = await _renderWeekPng(
      theme: theme,
      week: week,
      title: title,
      subtitle: weekTitleFor(week),
      monthLabel: monthLabelFor(dates),
      courses: visibleCourses,
      holidayMutedCourseIds: _holidayMutedCourseIds(
        courses: visibleCourses,
        dates: dates,
        settings: holidaySettings,
        schedule: holidaySchedule,
      ),
      dayLabels: dayLabels,
      holidayRestDays: holidayRestDayFlags(
        dates: dates,
        settings: holidaySettings,
        schedule: holidaySchedule,
      ),
      dates: dates,
      weekLabelFor: weekLabelFor,
      pixelRatio: _exportSemesterWeekImagePixelRatio,
    );
    final decodeInfo = img.PngDecoder().startDecode(bytes);
    if (decodeInfo == null) {
      throw StateError('Unable to inspect rendered timetable week image.');
    }
    weekImages.add(
      _EncodedWeekImage(
        bytes: bytes,
        width: decodeInfo.width,
        height: decodeInfo.height,
      ),
    );
    await Future<void>.delayed(Duration.zero);
  }

  final gap = _exportScaledImageDimension(
    _exportSemesterWeekGap,
    _exportSemesterWeekImagePixelRatio,
  );
  final width = weekImages.fold<int>(
    1,
    (maxWidth, image) => math.max(maxWidth, image.width),
  );
  final sidePadding = _exportScaledImageDimension(
    _exportSemesterSidePadding,
    _exportSemesterWeekImagePixelRatio,
  );
  final canvasWidth = width + sidePadding * 2;
  final height =
      weekImages.fold<int>(0, (sum, image) => sum + image.height) +
      math.max(0, weekImages.length - 1) * gap;
  final request = _SemesterPngEncodeRequest(
    images: [
      for (final image in weekImages)
        _EncodedWeekImagePayload(
          bytes: TransferableTypedData.fromList([image.bytes]),
          width: image.width,
          height: image.height,
        ),
    ],
    canvasWidth: canvasWidth,
    canvasHeight: height,
    gap: gap,
    sidePadding: sidePadding,
    backgroundRgba: _rgbaIntFromFlutterColor(
      theme.colorScheme.surfaceContainerLowest,
    ),
  );
  return compute(
    _encodeSemesterPngInBackground,
    request,
    debugLabel: 'semester-image-png-encode',
  );
}

class _EncodedWeekImage {
  const _EncodedWeekImage({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;
}

@visibleForTesting
Uint8List debugEncodeStackedSemesterPngForTest({
  required List<Uint8List> weekPngs,
  required int gap,
  required int sidePadding,
  required Color backgroundColor,
}) {
  final images = <_EncodedWeekImagePayload>[];
  var width = 1;
  var height = math.max(0, weekPngs.length - 1) * gap;
  for (final bytes in weekPngs) {
    final decodeInfo = img.PngDecoder().startDecode(bytes);
    if (decodeInfo == null) {
      throw StateError('Unable to inspect rendered timetable week image.');
    }
    width = math.max(width, decodeInfo.width);
    height += decodeInfo.height;
    images.add(
      _EncodedWeekImagePayload(
        bytes: TransferableTypedData.fromList([bytes]),
        width: decodeInfo.width,
        height: decodeInfo.height,
      ),
    );
  }
  return _encodeSemesterPngInBackground(
    _SemesterPngEncodeRequest(
      images: images,
      canvasWidth: width + sidePadding * 2,
      canvasHeight: height,
      gap: gap,
      sidePadding: sidePadding,
      backgroundRgba: _rgbaIntFromFlutterColor(backgroundColor),
    ),
  );
}

class _SemesterPngEncodeRequest {
  const _SemesterPngEncodeRequest({
    required this.images,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.gap,
    required this.sidePadding,
    required this.backgroundRgba,
  });

  final List<_EncodedWeekImagePayload> images;
  final int canvasWidth;
  final int canvasHeight;
  final int gap;
  final int sidePadding;
  final int backgroundRgba;
}

class _EncodedWeekImagePayload {
  const _EncodedWeekImagePayload({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final TransferableTypedData bytes;
  final int width;
  final int height;
}

Uint8List _encodeSemesterPngInBackground(_SemesterPngEncodeRequest request) {
  final output = BytesBuilder(copy: false)
    ..add(const [137, 80, 78, 71, 13, 10, 26, 10]);
  final ihdr = Uint8List(13);
  final ihdrData = ByteData.sublistView(ihdr)
    ..setUint32(0, request.canvasWidth)
    ..setUint32(4, request.canvasHeight);
  ihdrData
    ..setUint8(8, 8)
    ..setUint8(9, 6)
    ..setUint8(10, 0)
    ..setUint8(11, 0)
    ..setUint8(12, 0);
  _writePngChunk(output, 'IHDR', ihdr);

  final idatSink = ByteConversionSink.withCallback((compressedBytes) {
    _writePngChunk(output, 'IDAT', compressedBytes);
  });
  final zlibSink = ZLibEncoder(
    level: _exportSemesterPngCompressionLevel,
  ).startChunkedConversion(idatSink);
  final backgroundRow = _pngBackgroundRow(
    width: request.canvasWidth,
    rgba: request.backgroundRgba,
  );
  final compositedRow = Uint8List(backgroundRow.length);
  for (var imageIndex = 0; imageIndex < request.images.length; imageIndex++) {
    final payload = request.images[imageIndex];
    final encodedBytes = payload.bytes.materialize().asUint8List();
    final image = img.decodePng(encodedBytes);
    if (image == null) {
      throw StateError('Unable to decode rendered timetable week image.');
    }
    if (image.width != payload.width || image.height != payload.height) {
      throw StateError('Decoded timetable week image changed dimensions.');
    }
    final rgbaBytes = image.getBytes(order: img.ChannelOrder.rgba);
    final sourceStride = image.width * 4;
    final destinationStart = 1 + request.sidePadding * 4;
    for (var rowIndex = 0; rowIndex < image.height; rowIndex++) {
      compositedRow.setAll(0, backgroundRow);
      compositedRow.setRange(
        destinationStart,
        destinationStart + sourceStride,
        rgbaBytes,
        rowIndex * sourceStride,
      );
      zlibSink.add(compositedRow);
    }
    if (imageIndex < request.images.length - 1) {
      _addPngRows(zlibSink, backgroundRow, request.gap);
    }
  }
  zlibSink.close();
  _writePngChunk(output, 'IEND', const []);
  return output.takeBytes();
}

Uint8List _pngBackgroundRow({required int width, required int rgba}) {
  final row = Uint8List(1 + width * 4);
  final r = (rgba >> 24) & 0xff;
  final g = (rgba >> 16) & 0xff;
  final b = (rgba >> 8) & 0xff;
  final a = rgba & 0xff;
  for (var index = 1; index < row.length; index += 4) {
    row[index] = r;
    row[index + 1] = g;
    row[index + 2] = b;
    row[index + 3] = a;
  }
  return row;
}

void _addPngRows(Sink<List<int>> sink, Uint8List row, int count) {
  for (var index = 0; index < count; index++) {
    sink.add(row);
  }
}

void _writePngChunk(BytesBuilder output, String type, List<int> data) {
  final typeBytes = ascii.encode(type);
  output
    ..add(_uint32Bytes(data.length))
    ..add(typeBytes)
    ..add(data)
    ..add(_uint32Bytes(_pngCrc32(typeBytes, data)));
}

Uint8List _uint32Bytes(int value) {
  final bytes = Uint8List(4);
  ByteData.sublistView(bytes).setUint32(0, value);
  return bytes;
}

int _pngCrc32(List<int> typeBytes, List<int> data) {
  var crc = 0xffffffff;
  for (final byte in typeBytes) {
    crc = _crc32Table[(crc ^ byte) & 0xff] ^ (crc >>> 8);
  }
  for (final byte in data) {
    crc = _crc32Table[(crc ^ byte) & 0xff] ^ (crc >>> 8);
  }
  return (crc ^ 0xffffffff) & 0xffffffff;
}

final List<int> _crc32Table = _buildCrc32Table();

List<int> _buildCrc32Table() {
  return [for (var index = 0; index < 256; index++) _crc32TableEntry(index)];
}

int _crc32TableEntry(int value) {
  var crc = value;
  for (var bit = 0; bit < 8; bit++) {
    crc = (crc & 1) != 0 ? 0xedb88320 ^ (crc >>> 1) : crc >>> 1;
  }
  return crc;
}

int _rgbaIntFromFlutterColor(Color color) {
  return ((color.r * 255).round() << 24) |
      ((color.g * 255).round() << 16) |
      ((color.b * 255).round() << 8) |
      (color.a * 255).round();
}

int _exportScaledImageDimension(double logicalSize, double pixelRatio) {
  return math.max(1, (logicalSize * pixelRatio).ceil());
}

TimetableImageExportTimeRange _weekImageExportTimeRange(
  Iterable<CourseSlot> courses,
) {
  final activeCourses = courses
      .where((course) => course.weekday >= 1 && course.weekday <= 7)
      .toList();
  if (activeCourses.isEmpty) {
    return TimetableImageExportTimeRange(
      startMinute: defaultLessonTimeSlots.first.startMinuteOfDay,
      endMinute: defaultLessonTimeSlots.last.endMinuteOfDay,
    );
  }

  final startMinute = activeCourses
      .map((course) => course.startMinuteOfDay)
      .reduce(math.min)
      .clamp(0, minutesPerDay - 1)
      .toInt();
  final endMinute = activeCourses
      .map((course) => course.endMinuteOfDay)
      .reduce(math.max)
      .clamp(startMinute + 1, minutesPerDay)
      .toInt();
  return TimetableImageExportTimeRange(
    startMinute: startMinute,
    endMinute: endMinute,
  );
}

double _exportTimelineBodyHeight(
  TimetableImageExportTimeRange timeRange,
  double hourHeight,
) {
  return timeRange.durationMinutes * hourHeight / 60;
}

double _exportMinuteOffset(
  int minute,
  TimetableImageExportTimeRange timeRange,
  double hourHeight,
) {
  final visibleMinute = minute
      .clamp(timeRange.startMinute, timeRange.endMinute)
      .toInt();
  return (visibleMinute - timeRange.startMinute) * hourHeight / 60;
}

class _ExportTimeColumnSegment {
  const _ExportTimeColumnSegment({
    required this.startMinute,
    required this.endMinute,
    required this.label,
  });

  final int startMinute;
  final int endMinute;
  final String label;
}

List<_ExportTimeColumnSegment> _exportTimeColumnSegments({
  required TimetableImageExportTimeRange timeRange,
}) {
  final segments = <_ExportTimeColumnSegment>[];
  _addExportWholeHourSegments(
    segments,
    startMinute: 0,
    endMinute: defaultLessonTimeSlots.first.startMinuteOfDay,
  );

  for (var index = 0; index < defaultLessonTimeSlots.length; index++) {
    final slot = defaultLessonTimeSlots[index];
    segments.add(
      _ExportTimeColumnSegment(
        startMinute: slot.startMinuteOfDay,
        endMinute: slot.endMinuteOfDay,
        label: _exportLessonSlotLabel(slot),
      ),
    );
    final nextIndex = index + 1;
    if (nextIndex < defaultLessonTimeSlots.length) {
      _addExportWholeHourSegments(
        segments,
        startMinute: slot.endMinuteOfDay,
        endMinute: defaultLessonTimeSlots[nextIndex].startMinuteOfDay,
      );
    }
  }

  _addExportWholeHourSegments(
    segments,
    startMinute: defaultLessonTimeSlots.last.endMinuteOfDay,
    endMinute: minutesPerDay,
  );

  return [
    for (final segment in segments)
      if (segment.startMinute < timeRange.endMinute &&
          timeRange.startMinute < segment.endMinute)
        _ExportTimeColumnSegment(
          startMinute: math.max(segment.startMinute, timeRange.startMinute),
          endMinute: math.min(segment.endMinute, timeRange.endMinute),
          label: segment.label,
        ),
  ]..sort((a, b) => a.startMinute.compareTo(b.startMinute));
}

void _addExportWholeHourSegments(
  List<_ExportTimeColumnSegment> segments, {
  required int startMinute,
  required int endMinute,
}) {
  final firstWholeHour = ((startMinute + 59) ~/ 60) * 60;
  for (var minute = firstWholeHour; minute < endMinute; minute += 60) {
    segments.add(
      _ExportTimeColumnSegment(
        startMinute: minute,
        endMinute: math.min(minute + 60, endMinute),
        label: _minuteLabel(minute),
      ),
    );
  }
}

List<int> _exportTimelineGuideMinutes(TimetableImageExportTimeRange timeRange) {
  final minutes = <int>{timeRange.startMinute, timeRange.endMinute};
  _addExportWholeHourGuideMinutes(
    minutes,
    startMinute: 0,
    endMinute: defaultLessonTimeSlots.first.startMinuteOfDay,
  );
  for (var index = 0; index < defaultLessonTimeSlots.length; index++) {
    final slot = defaultLessonTimeSlots[index];
    minutes
      ..add(slot.startMinuteOfDay)
      ..add(slot.endMinuteOfDay);
    final nextIndex = index + 1;
    if (nextIndex < defaultLessonTimeSlots.length) {
      _addExportWholeHourGuideMinutes(
        minutes,
        startMinute: slot.endMinuteOfDay,
        endMinute: defaultLessonTimeSlots[nextIndex].startMinuteOfDay,
      );
    }
  }
  _addExportWholeHourGuideMinutes(
    minutes,
    startMinute: defaultLessonTimeSlots.last.endMinuteOfDay,
    endMinute: minutesPerDay,
  );
  return minutes
      .where(
        (minute) =>
            minute >= timeRange.startMinute && minute <= timeRange.endMinute,
      )
      .toList()
    ..sort();
}

void _addExportWholeHourGuideMinutes(
  Set<int> minutes, {
  required int startMinute,
  required int endMinute,
}) {
  final firstWholeHour = ((startMinute + 59) ~/ 60) * 60;
  for (var minute = firstWholeHour; minute <= endMinute; minute += 60) {
    minutes.add(minute);
  }
}

String _exportLessonSlotLabel(LessonTimeSlot slot) {
  return '${slot.section}\n${_minuteLabel(slot.startMinuteOfDay)}-'
      '${_minuteLabel(slot.endMinuteOfDay)}';
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
    var groupEndMinute = 0;

    void flushGroup() {
      if (group.isEmpty) {
        return;
      }
      layouts.addAll(_assignExportOverlapLanes(group));
      group = <CourseSlot>[];
      groupEndMinute = 0;
    }

    for (final course in sorted) {
      if (group.isEmpty || course.startMinuteOfDay < groupEndMinute) {
        group.add(course);
        groupEndMinute = math.max(groupEndMinute, course.endMinuteOfDay);
      } else {
        flushGroup();
        group.add(course);
        groupEndMinute = course.endMinuteOfDay;
      }
    }
    flushGroup();
  }
  return layouts;
}

int _compareExportCourseBlocks(CourseSlot a, CourseSlot b) {
  final byStart = a.startMinuteOfDay.compareTo(b.startMinuteOfDay);
  if (byStart != 0) {
    return byStart;
  }
  final byEnd = b.endMinuteOfDay.compareTo(a.endMinuteOfDay);
  if (byEnd != 0) {
    return byEnd;
  }
  return a.name.compareTo(b.name);
}

List<_ExportCourseBlockLayout> _assignExportOverlapLanes(
  List<CourseSlot> group,
) {
  final laneEndMinutes = <int>[];
  final laneByCourse = <CourseSlot, int>{};

  for (final course in group) {
    final lane = laneEndMinutes.indexWhere(
      (endMinute) => endMinute <= course.startMinuteOfDay,
    );
    if (lane == -1) {
      laneByCourse[course] = laneEndMinutes.length;
      laneEndMinutes.add(course.endMinuteOfDay);
    } else {
      laneByCourse[course] = lane;
      laneEndMinutes[lane] = course.endMinuteOfDay;
    }
  }

  final overlapCount = laneEndMinutes.length;
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

String _minuteLabel(int minuteOfDay) {
  final hour = minuteOfDay ~/ 60;
  final minute = minuteOfDay % 60;
  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
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

Color _holidayMutedCourseColor(ColorScheme colorScheme) {
  return Color.alphaBlend(
    colorScheme.onSurfaceVariant.withValues(
      alpha: colorScheme.brightness == Brightness.light ? 0.12 : 0.18,
    ),
    colorScheme.surfaceContainerHighest,
  );
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
  TextAlign textAlign = TextAlign.start,
}) {
  final painter = _layoutExportText(
    text,
    fontSize,
    color,
    weight,
    maxWidth: maxWidth,
    maxLines: maxLines,
    textAlign: textAlign,
  );
  final alignedOffset = _alignedExportTextOffset(
    offset: offset,
    maxWidth: maxWidth,
    painter: painter,
    textAlign: textAlign,
  );
  painter.paint(canvas, alignedOffset);
  return painter.height;
}

double _drawTextInRect(
  Canvas canvas,
  String text,
  Rect rect,
  double fontSize,
  Color color,
  FontWeight weight, {
  int maxLines = 2,
  TextAlign textAlign = TextAlign.start,
}) {
  final painter = _layoutExportText(
    text,
    fontSize,
    color,
    weight,
    maxWidth: rect.width,
    maxLines: maxLines,
    textAlign: textAlign,
  );
  final horizontalOffset = _alignedExportTextOffset(
    offset: rect.topLeft,
    maxWidth: rect.width,
    painter: painter,
    textAlign: textAlign,
  );
  final dy = rect.top + math.max(0, (rect.height - painter.height) / 2);
  painter.paint(canvas, Offset(horizontalOffset.dx, dy));
  return painter.height;
}

TextPainter _layoutExportText(
  String text,
  double fontSize,
  Color color,
  FontWeight weight, {
  required double maxWidth,
  required int maxLines,
  required TextAlign textAlign,
}) {
  return TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontSize: fontSize, color: color, fontWeight: weight),
    ),
    textDirection: ui.TextDirection.ltr,
    textAlign: textAlign,
    maxLines: maxLines,
    ellipsis: '...',
  )..layout(maxWidth: maxWidth);
}

Offset _alignedExportTextOffset({
  required Offset offset,
  required double maxWidth,
  required TextPainter painter,
  required TextAlign textAlign,
}) {
  var dx = offset.dx;
  if (textAlign == TextAlign.center) {
    dx += math.max(0, (maxWidth - painter.width) / 2);
  } else if (textAlign == TextAlign.end || textAlign == TextAlign.right) {
    dx += math.max(0, maxWidth - painter.width);
  }
  return Offset(dx, offset.dy);
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
