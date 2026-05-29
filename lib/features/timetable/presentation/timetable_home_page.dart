import 'package:crid/app/app_state.dart';
import 'package:crid/app/motion.dart';
import 'package:crid/core/theme/course_colors.dart';
import 'package:crid/features/settings/data/china_holiday_service.dart';
import 'package:crid/features/settings/data/holiday_settings_controller.dart';
import 'package:crid/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'course_slot_model.dart';

const _periodNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
const _periodStartTimes = [
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

class TimetableHomePage extends ConsumerStatefulWidget {
  const TimetableHomePage({super.key});

  @override
  ConsumerState<TimetableHomePage> createState() => _TimetableHomePageState();
}

class _TimetableHomePageState extends ConsumerState<TimetableHomePage> {
  int? _lastSyncedSemesterId;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(timetableControllerProvider);
    final snapshotData = snapshot.asData?.value;
    final today = DateTime.now();

    if (snapshotData != null &&
        _lastSyncedSemesterId != snapshotData.activeSemester.id) {
      _lastSyncedSemesterId = snapshotData.activeSemester.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref
            .read(selectedWeekProvider.notifier)
            .setToDate(snapshotData.activeSemester.firstWeekMonday, today);
      });
    }

    if (snapshot.isLoading && !snapshot.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError && !snapshot.hasValue) {
      return Center(
        child: Text(context.l10n.failedToLoadTimetable(snapshot.error!)),
      );
    }
    final firstWeekMonday =
        snapshotData?.activeSemester.firstWeekMonday ??
        _mondayOf(DateTime.now());
    final holidaySettings =
        ref.watch(holidaySettingsProvider).asData?.value ??
        HolidaySettings.defaults;
    final holidaySchedule =
        ref
            .watch(chinaHolidayScheduleProvider(firstWeekMonday.year))
            .asData
            ?.value ??
        ChinaHolidaySchedule.empty(firstWeekMonday.year);
    final List<CourseSlot> courses =
        snapshotData?.courses ?? ref.watch(sampleCoursesProvider);
    final todayWeek = weekNumberForDate(
      firstWeekMonday: firstWeekMonday,
      date: today,
    );
    final todayDates = _datesForWeek(
      firstWeekMonday: firstWeekMonday,
      week: todayWeek,
    );
    final todayCourses = courses
        .where((course) => course.weekday == today.weekday)
        .where((course) => course.isActiveInWeek(todayWeek))
        .where(
          (course) => !_isHiddenByHoliday(
            course: course,
            dates: todayDates,
            settings: holidaySettings,
            schedule: holidaySchedule,
          ),
        )
        .toList();
    final currentWeek = snapshotData == null
        ? null
        : weekNumberForDate(
            firstWeekMonday: snapshotData.activeSemester.firstWeekMonday,
            date: today,
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        const bottomPadding = 96.0;
        final gridAvailableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight - bottomPadding
            : null;
        return Stack(
          children: [
            ListView(
              padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
              children: [
                _TimetableGrid(
                  courses: courses,
                  firstWeekMonday: firstWeekMonday,
                  holidaySettings: holidaySettings,
                  holidaySchedule: holidaySchedule,
                  availableHeight: gridAvailableHeight,
                ),
                const SizedBox(height: 16),
                _TodayCourseList(courses: todayCourses),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: _TodayWeekButton(currentWeek: currentWeek),
            ),
          ],
        );
      },
    );
  }
}

class _TodayWeekButton extends ConsumerWidget {
  const _TodayWeekButton({required this.currentWeek});

  final int? currentWeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week = ref.watch(selectedWeekProvider);
    final showTodayButton = currentWeek != null && currentWeek != week;
    return AnimatedSwitcher(
      duration: appMicroMotionDuration,
      switchInCurve: appMicroMotionCurve,
      switchOutCurve: appMicroMotionReverseCurve,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: showTodayButton
          ? FloatingActionButton.extended(
              key: const ValueKey('today-button'),
              onPressed: () {
                ref.read(selectedWeekProvider.notifier).setWeek(currentWeek!);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              icon: const Icon(Icons.today_outlined),
              label: Text(context.l10n.goToToday),
            )
          : const SizedBox.shrink(key: ValueKey('today-button-off')),
    );
  }
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

class _TimetableGrid extends ConsumerStatefulWidget {
  const _TimetableGrid({
    required this.courses,
    required this.firstWeekMonday,
    required this.holidaySettings,
    required this.holidaySchedule,
    required this.availableHeight,
  });

  final List<CourseSlot> courses;
  final DateTime firstWeekMonday;
  final HolidaySettings holidaySettings;
  final ChinaHolidaySchedule holidaySchedule;
  final double? availableHeight;

  @override
  ConsumerState<_TimetableGrid> createState() => _TimetableGridState();
}

class _TimetableGridState extends ConsumerState<_TimetableGrid> {
  late final PageController _pageController;
  late List<_WeekGridData> _weekGridData;
  late int _visibleWeek;

  @override
  void initState() {
    super.initState();
    _weekGridData = _buildWeekGridData();
    _visibleWeek = ref
        .read(selectedWeekProvider)
        .clamp(1, maxSemesterWeek)
        .toInt();
    _pageController = PageController(initialPage: _visibleWeek - 1);
  }

  @override
  void didUpdateWidget(covariant _TimetableGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldRefreshWeekData(oldWidget)) {
      _weekGridData = _buildWeekGridData();
    }
    final selectedWeek = ref
        .read(selectedWeekProvider)
        .clamp(1, maxSemesterWeek)
        .toInt();
    _syncPageController(selectedWeek);
  }

  void _syncPageController(int selectedWeek) {
    if (selectedWeek == _visibleWeek) {
      return;
    }
    _visibleWeek = selectedWeek;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
      _pageController.animateToPage(
        selectedWeek - 1,
        duration: appMicroMotionDuration,
        curve: appMicroMotionCurve,
      );
    });
  }

  bool _shouldRefreshWeekData(_TimetableGrid oldWidget) {
    return !identical(widget.courses, oldWidget.courses) ||
        widget.firstWeekMonday != oldWidget.firstWeekMonday ||
        widget.holidaySettings != oldWidget.holidaySettings ||
        !identical(widget.holidaySchedule, oldWidget.holidaySchedule);
  }

  List<_WeekGridData> _buildWeekGridData() {
    return List.unmodifiable([
      for (var week = 1; week <= maxSemesterWeek; week++)
        _weekGridDataFor(week),
    ]);
  }

  _WeekGridData _weekGridDataFor(int week) {
    final dates = _datesForWeek(
      firstWeekMonday: widget.firstWeekMonday,
      week: week,
    );
    final holidayRestDays = holidayRestDayFlags(
      dates: dates,
      settings: widget.holidaySettings,
      schedule: widget.holidaySchedule,
    );
    final activeCourses = List<CourseSlot>.unmodifiable(
      widget.courses
          .where((course) => course.isActiveInWeek(week))
          .where(
            (course) => !_isHiddenByHoliday(
              course: course,
              dates: dates,
              settings: widget.holidaySettings,
              schedule: widget.holidaySchedule,
            ),
          ),
    );
    return _WeekGridData(
      week: week,
      dates: List.unmodifiable(dates),
      holidayRestDays: List.unmodifiable(holidayRestDays),
      layouts: List.unmodifiable(_courseBlockLayouts(activeCourses)),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedWeek = ref
        .watch(selectedWeekProvider)
        .clamp(1, maxSemesterWeek)
        .toInt();
    _syncPageController(selectedWeek);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;
        final gridWidth = constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 32;
        final gutterWidth = isCompact ? 42.0 : 64.0;
        final headerHeight = isCompact ? 46.0 : 50.0;
        final basePeriodHeight = isCompact ? 76.0 : 84.0;
        final periodHeight = _periodHeightForViewport(
          compact: isCompact,
          headerHeight: headerHeight,
          basePeriodHeight: basePeriodHeight,
          availableHeight: widget.availableHeight,
        );
        final dayWidth = (gridWidth - gutterWidth) / 7;
        final gridHeight = headerHeight + periodHeight * _periodNumbers.length;

        return Card(
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: gridWidth,
            height: gridHeight,
            child: PageView.builder(
              controller: _pageController,
              itemCount: maxSemesterWeek,
              allowImplicitScrolling: true,
              clipBehavior: Clip.hardEdge,
              onPageChanged: (index) {
                final week = index + 1;
                if (week == _visibleWeek) {
                  return;
                }
                _visibleWeek = week;
                ref.read(selectedWeekProvider.notifier).setWeek(week);
              },
              itemBuilder: (context, index) {
                final weekData = _weekGridData[index];
                return RepaintBoundary(
                  child: _TimetableGridPage(
                    key: ValueKey('week-${weekData.week}'),
                    layouts: weekData.layouts,
                    dates: weekData.dates,
                    holidayRestDays: weekData.holidayRestDays,
                    width: gridWidth,
                    gutterWidth: gutterWidth,
                    dayWidth: dayWidth,
                    headerHeight: headerHeight,
                    periodHeight: periodHeight,
                    compact: isCompact,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _WeekGridData {
  const _WeekGridData({
    required this.week,
    required this.dates,
    required this.holidayRestDays,
    required this.layouts,
  });

  final int week;
  final List<DateTime> dates;
  final List<bool> holidayRestDays;
  final List<_CourseBlockLayout> layouts;
}

class _TimetableGridPage extends StatefulWidget {
  const _TimetableGridPage({
    super.key,
    required this.layouts,
    required this.dates,
    required this.holidayRestDays,
    required this.width,
    required this.gutterWidth,
    required this.dayWidth,
    required this.headerHeight,
    required this.periodHeight,
    required this.compact,
  });

  final List<_CourseBlockLayout> layouts;
  final List<DateTime> dates;
  final List<bool> holidayRestDays;
  final double width;
  final double gutterWidth;
  final double dayWidth;
  final double headerHeight;
  final double periodHeight;
  final bool compact;

  @override
  State<_TimetableGridPage> createState() => _TimetableGridPageState();
}

class _TimetableGridPageState extends State<_TimetableGridPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
        _CalendarGridChrome(
          width: widget.width,
          gutterWidth: widget.gutterWidth,
          dayWidth: widget.dayWidth,
          headerHeight: widget.headerHeight,
          periodHeight: widget.periodHeight,
          compact: widget.compact,
          dates: widget.dates,
          holidayRestDays: widget.holidayRestDays,
        ),
        for (final layout in widget.layouts)
          _CalendarCourseBlock(
            key: ValueKey(layout.course.id),
            course: layout.course,
            overlapIndex: layout.overlapIndex,
            overlapCount: layout.overlapCount,
            gutterWidth: widget.gutterWidth,
            dayWidth: widget.dayWidth,
            headerHeight: widget.headerHeight,
            periodHeight: widget.periodHeight,
            compact: widget.compact,
            onTap: () => _showCourseDetails(context, layout.course),
          ),
      ],
    );
  }
}

class _CourseBlockLayout {
  const _CourseBlockLayout({
    required this.course,
    required this.overlapIndex,
    required this.overlapCount,
  });

  final CourseSlot course;
  final int overlapIndex;
  final int overlapCount;
}

double _periodHeightForViewport({
  required bool compact,
  required double headerHeight,
  required double basePeriodHeight,
  required double? availableHeight,
}) {
  if (compact || availableHeight == null || !availableHeight.isFinite) {
    return basePeriodHeight;
  }

  const minDesktopPeriodHeight = 64.0;
  final fittedPeriodHeight =
      (availableHeight - headerHeight) / _periodNumbers.length;
  return fittedPeriodHeight
      .clamp(minDesktopPeriodHeight, basePeriodHeight)
      .toDouble();
}

List<_CourseBlockLayout> _courseBlockLayouts(List<CourseSlot> courses) {
  final layouts = <_CourseBlockLayout>[];
  final coursesByDay = <int, List<CourseSlot>>{};

  for (final course in courses) {
    if (course.weekday < 1 || course.weekday > 7) {
      layouts.add(
        _CourseBlockLayout(course: course, overlapIndex: 0, overlapCount: 1),
      );
      continue;
    }
    coursesByDay.putIfAbsent(course.weekday, () => []).add(course);
  }

  for (final dayCourses in coursesByDay.values) {
    final sorted = [...dayCourses]..sort(_compareCourseBlocks);
    var group = <CourseSlot>[];
    var groupEndPeriod = 0;

    void flushGroup() {
      if (group.isEmpty) {
        return;
      }
      layouts.addAll(_assignOverlapLanes(group));
      group = <CourseSlot>[];
      groupEndPeriod = 0;
    }

    for (final course in sorted) {
      if (group.isEmpty || course.startPeriod <= groupEndPeriod) {
        group.add(course);
        if (course.endPeriod > groupEndPeriod) {
          groupEndPeriod = course.endPeriod;
        }
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

int _compareCourseBlocks(CourseSlot a, CourseSlot b) {
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

List<_CourseBlockLayout> _assignOverlapLanes(List<CourseSlot> group) {
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
      _CourseBlockLayout(
        course: course,
        overlapIndex: laneByCourse[course] ?? 0,
        overlapCount: overlapCount,
      ),
  ];
}

class _CalendarGridChrome extends StatelessWidget {
  const _CalendarGridChrome({
    required this.width,
    required this.gutterWidth,
    required this.dayWidth,
    required this.headerHeight,
    required this.periodHeight,
    required this.compact,
    required this.dates,
    required this.holidayRestDays,
  });

  final double width;
  final double gutterWidth;
  final double dayWidth;
  final double headerHeight;
  final double periodHeight;
  final bool compact;
  final List<DateTime> dates;
  final List<bool> holidayRestDays;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final outline = colorScheme.outlineVariant;
    final timeColumnColor = colorScheme.brightness == Brightness.light
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerHighest;
    final dayLabels = compact
        ? _compactDayLabels(context)
        : _dayLabels(context);
    final monthLabel = _monthLabel(context, dates);

    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          width: width,
          height: headerHeight,
          child: ColoredBox(color: colorScheme.surfaceContainerHighest),
        ),
        Positioned(
          left: 0,
          top: 0,
          width: gutterWidth,
          height: headerHeight,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  monthLabel,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
        for (var day = 0; day < DateTime.daysPerWeek; day++)
          if (_isHolidayRestDay(holidayRestDays, day))
            Positioned(
              key: ValueKey('holiday-rest-column-${day + 1}'),
              left: gutterWidth + dayWidth * day,
              top: 0,
              width: dayWidth,
              height: headerHeight + periodHeight * _periodNumbers.length,
              child: ColoredBox(color: _holidayRestColumnColor(colorScheme)),
            ),
        for (var day = 0; day < dayLabels.length; day++)
          Positioned(
            left: gutterWidth + dayWidth * day,
            top: 0,
            width: dayWidth,
            height: headerHeight,
            child: _DayHeaderCell(
              label: dayLabels[day],
              date: dates[day],
              holidayRestDay: _isHolidayRestDay(holidayRestDays, day),
              compact: compact,
            ),
          ),
        for (var index = 0; index < _periodNumbers.length; index++)
          Positioned(
            left: 0,
            top: headerHeight + periodHeight * index,
            width: gutterWidth,
            height: periodHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: timeColumnColor,
                border: Border(
                  right: BorderSide(color: outline),
                  bottom: BorderSide(color: outline),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_periodNumbers[index]}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      _periodStartTimes[index],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        for (var row = 0; row <= _periodNumbers.length; row++)
          Positioned(
            left: gutterWidth,
            top: headerHeight + periodHeight * row,
            width: width - gutterWidth,
            height: 1,
            child: ColoredBox(color: outline),
          ),
        for (var day = 0; day <= 7; day++)
          Positioned(
            left: gutterWidth + dayWidth * day,
            top: 0,
            width: 1,
            height: headerHeight + periodHeight * _periodNumbers.length,
            child: ColoredBox(color: outline),
          ),
      ],
    );
  }
}

class _CalendarCourseBlock extends StatelessWidget {
  const _CalendarCourseBlock({
    super.key,
    required this.course,
    required this.overlapIndex,
    required this.overlapCount,
    required this.gutterWidth,
    required this.dayWidth,
    required this.headerHeight,
    required this.periodHeight,
    required this.compact,
    required this.onTap,
  });

  final CourseSlot course;
  final int overlapIndex;
  final int overlapCount;
  final double gutterWidth;
  final double dayWidth;
  final double headerHeight;
  final double periodHeight;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (course.weekday < 1 || course.weekday > 7) {
      return const SizedBox.shrink();
    }
    final start = course.startPeriod.clamp(1, _periodNumbers.length).toInt();
    final end = course.endPeriod.clamp(start, _periodNumbers.length).toInt();
    final columnCount = overlapCount < 1 ? 1 : overlapCount;
    final columnIndex = overlapIndex.clamp(0, columnCount - 1).toInt();
    final columnGap = columnCount > 1 ? 2.0 : 0.0;
    final availableWidth = dayWidth - 4;
    final width =
        (availableWidth - columnGap * (columnCount - 1)) / columnCount;
    final left =
        gutterWidth +
        dayWidth * (course.weekday - 1) +
        2 +
        (width + columnGap) * columnIndex;
    final top = headerHeight + periodHeight * (start - 1) + 2;
    final height = periodHeight * (end - start + 1) - 4;

    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return AnimatedPositioned(
      duration: disableAnimations ? Duration.zero : appMicroMotionDuration,
      curve: appMicroMotionCurve,
      left: left,
      top: top,
      width: width,
      height: height,
      child: _CourseCard(course: course, compact: compact, onTap: onTap),
    );
  }
}

class _DayHeaderCell extends StatelessWidget {
  const _DayHeaderCell({
    required this.label,
    required this.date,
    required this.holidayRestDay,
    required this.compact,
  });

  final String label;
  final DateTime date;
  final bool holidayRestDay;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final badgeSize = compact ? 24.0 : 26.0;
    final labelStyle =
        (compact
                ? Theme.of(context).textTheme.labelSmall
                : Theme.of(context).textTheme.labelLarge)
            ?.copyWith(
              color: isToday
                  ? colorScheme.primary
                  : holidayRestDay
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurface,
              fontWeight: isToday || holidayRestDay ? FontWeight.w700 : null,
            );
    final dateStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: isToday ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
      fontWeight: isToday || holidayRestDay ? FontWeight.w700 : null,
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: labelStyle, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: appMicroMotionDuration,
            curve: appMicroMotionCurve,
            width: badgeSize,
            height: badgeSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isToday ? colorScheme.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text('${date.day}', style: dateStyle),
          ),
        ],
      ),
    );
  }
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

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.compact,
    required this.onTap,
  });

  final CourseSlot course;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = readableCourseTextColor(course.color);
    const borderRadius = BorderRadius.all(Radius.circular(8));
    final semanticParts = [
      course.name,
      course.location,
      course.teacher,
    ].where((part) => part.trim().isNotEmpty).join(', ');

    return Material(
      color: course.color,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        label: semanticParts,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 4 : 7,
              vertical: compact ? 3 : 6,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final details = [
                  course.location.trim(),
                  course.teacher.trim(),
                ].where((part) => part.isNotEmpty).toList();
                final titleUpperBound = (constraints.maxHeight - 2)
                    .clamp(0.0, constraints.maxHeight)
                    .toDouble();
                final titleMaxHeight = details.isEmpty
                    ? constraints.maxHeight
                    : (constraints.maxHeight * 0.55)
                          .clamp(0.0, titleUpperBound)
                          .toDouble();
                final titleStyle = TextStyle(
                  fontSize: compact ? 11 : null,
                  fontWeight: FontWeight.w700,
                  height: 1.08,
                  color: textColor,
                );
                final detailStyle = TextStyle(
                  fontSize: compact ? 10 : null,
                  fontWeight: FontWeight.w500,
                  height: 1.08,
                  color: textColor,
                );

                return ClipRect(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: titleMaxHeight),
                        child: ScrollConfiguration(
                          behavior: const _CourseCardScrollBehavior(),
                          child: SingleChildScrollView(
                            primary: false,
                            physics: const ClampingScrollPhysics(),
                            child: Text(
                              course.name,
                              style: titleStyle,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                      ),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: const _CourseCardScrollBehavior(),
                            child: SingleChildScrollView(
                              primary: false,
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final detail in details)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(
                                        detail,
                                        style: detailStyle,
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseCardScrollBehavior extends ScrollBehavior {
  const _CourseCardScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

List<String> _compactDayLabels(BuildContext context) {
  return _dayLabels(
    context,
  ).map((label) => label.replaceFirst(RegExp(r'^(周|週|星期)'), '')).toList();
}

String _monthLabel(BuildContext context, List<DateTime> dates) {
  final monthDate = _monthDateForHeader(dates);
  final locale = Localizations.localeOf(context);
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

DateTime _mondayOf(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return normalized.subtract(Duration(days: normalized.weekday - 1));
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

class _TodayCourseList extends StatelessWidget {
  const _TodayCourseList({required this.courses});

  final List<CourseSlot> courses;

  @override
  Widget build(BuildContext context) {
    final ordered = [...courses]
      ..sort((a, b) {
        final byStart = a.startPeriod.compareTo(b.startPeriod);
        return byStart == 0 ? a.endPeriod.compareTo(b.endPeriod) : byStart;
      });
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.todayCourses,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: appMicroMotionDuration,
          switchInCurve: appMicroMotionCurve,
          switchOutCurve: appMicroMotionReverseCurve,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: ordered.isEmpty
              ? Padding(
                  key: const ValueKey('today-empty'),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    context.l10n.noCoursesToday,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Column(
                  key: ValueKey(ordered.map((course) => course.id).join(',')),
                  children: [
                    for (final course in ordered)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(backgroundColor: course.color),
                        title: Text(course.name),
                        subtitle: Text(
                          '${_periodLabel(context, course)}  '
                          '${course.location}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showCourseDetails(context, course),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

void _showCourseDetails(BuildContext context, CourseSlot course) {
  final returnPath = GoRouterState.of(context).uri.toString();
  final details = _CourseDetails(course: course, returnPath: returnPath);
  if (MediaQuery.sizeOf(context).width < 700) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => details,
    );
    return;
  }

  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: details,
      ),
    ),
  );
}

class _CourseDetails extends StatelessWidget {
  const _CourseDetails({required this.course, required this.returnPath});

  final CourseSlot course;
  final String returnPath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  course.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: context.l10n.edit,
                onPressed: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  router.push(
                    Uri(
                      path: '/editor',
                      queryParameters: {'slot': course.id, 'from': returnPath},
                    ).toString(),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailLine(icon: Icons.person_outline, text: course.teacher),
          _DetailLine(icon: Icons.place_outlined, text: course.location),
          _DetailLine(
            icon: Icons.schedule_outlined,
            text:
                '${_dayLabels(context)[course.weekday - 1]}, '
                '${_periodLabel(context, course)}, '
                '${_weekLabel(context, course)}',
          ),
          if (course.notes.isNotEmpty)
            _DetailLine(icon: Icons.notes_outlined, text: course.notes),
        ],
      ),
    );
  }
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

String _periodLabel(BuildContext context, CourseSlot course) {
  return context.l10n.periodsValue(course.startPeriod, course.endPeriod);
}

String _weekLabel(BuildContext context, CourseSlot course) {
  final base = context.l10n.weeksValue(course.startWeek, course.endWeek);
  return switch (course.parity) {
    WeekParity.all => base,
    WeekParity.odd => '$base ${context.l10n.oddWeeks}',
    WeekParity.even => '$base ${context.l10n.evenWeeks}',
  };
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
