import 'dart:async';
import 'dart:math' as math;

import 'package:crid/app/app_state.dart';
import 'package:crid/app/motion.dart';
import 'package:crid/app/theme.dart';
import 'package:crid/core/time/period.dart';
import 'package:crid/core/theme/course_colors.dart';
import 'package:crid/features/settings/data/china_holiday_service.dart';
import 'package:crid/features/settings/data/holiday_settings_controller.dart';
import 'package:crid/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'course_slot_model.dart';

const _timelineStartMinute = 0;
const _timelineEndMinute = minutesPerDay;
const _timelineDurationMinutes = _timelineEndMinute - _timelineStartMinute;
const _minimumCourseBlockHeight = 40.0;
const _courseBlockVerticalInset = 0.5;
const _timetableScrollDuration = Duration(milliseconds: 520);
const _timetableScrollCurve = Easing.emphasizedDecelerate;
const _courseSheetTransitionDuration = Duration(milliseconds: 340);
const _courseSheetReverseTransitionDuration = Duration(milliseconds: 220);

class TimetableHomePage extends ConsumerStatefulWidget {
  const TimetableHomePage({super.key});

  @override
  ConsumerState<TimetableHomePage> createState() => _TimetableHomePageState();
}

class _TimetableHomePageState extends ConsumerState<TimetableHomePage> {
  int? _lastSyncedSemesterId;

  void _openCourseDetails(CourseSlot course, {required bool useInlineSheet}) {
    if (useInlineSheet) {
      _showCourseDetailsSheet(context, course);
      return;
    }
    _showCourseDetailsDialog(context, course);
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(timetableControllerProvider);
    final snapshotData = snapshot.asData?.value;
    final autoScrollRequest = ref.watch(timetableAutoScrollRequestProvider);
    final today = DateTime.now();
    final isSyncingActiveSemester =
        snapshotData != null &&
        _lastSyncedSemesterId != snapshotData.activeSemester.id;

    if (isSyncingActiveSemester) {
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
        const sectionHorizontalPadding = 16.0;
        final useInlineCourseDetails = constraints.maxWidth < 700;
        final gridHorizontalPadding = _timetablePageHorizontalPadding(
          constraints.maxWidth,
        );
        final gridAvailableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight - bottomPadding
            : null;
        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, bottomPadding),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: gridHorizontalPadding,
                  ),
                  child: _TimetableGrid(
                    courses: courses,
                    firstWeekMonday: firstWeekMonday,
                    holidaySettings: holidaySettings,
                    holidaySchedule: holidaySchedule,
                    semesterId: snapshotData?.activeSemester.id,
                    selectedWeekOverride:
                        isSyncingActiveSemester && currentWeek != null
                        ? currentWeek
                        : null,
                    autoScrollRequest: autoScrollRequest,
                    availableHeight: gridAvailableHeight,
                    onCourseSelected: (course) => _openCourseDetails(
                      course,
                      useInlineSheet: useInlineCourseDetails,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: sectionHorizontalPadding,
                  ),
                  child: _TodayCourseList(
                    courses: todayCourses,
                    onCourseSelected: (course) => _openCourseDetails(
                      course,
                      useInlineSheet: useInlineCourseDetails,
                    ),
                  ),
                ),
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
                ref.read(timetableAutoScrollRequestProvider.notifier).request();
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

double _timetablePageHorizontalPadding(double width) {
  if (!width.isFinite || width < 560) {
    return 8;
  }
  return 12;
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

bool _isMutedByHoliday({
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
      HolidayCourseDisplayMode.muted;
}

int? _earliestCourseStartMinute({
  required List<CourseSlot> courses,
  required int week,
  required List<DateTime> dates,
  required HolidaySettings settings,
  required ChinaHolidaySchedule schedule,
}) {
  int? earliest;
  for (final course in courses) {
    if (!course.isActiveInWeek(week) ||
        _isHiddenByHoliday(
          course: course,
          dates: dates,
          settings: settings,
          schedule: schedule,
        )) {
      continue;
    }
    earliest = earliest == null
        ? course.startMinuteOfDay
        : math.min(earliest, course.startMinuteOfDay);
  }
  return earliest;
}

double _autoScrollOffsetForMinute(int minute, {required double hourHeight}) {
  return math.max(
    0,
    _minuteOffset(minute, hourHeight) + _courseBlockVerticalInset,
  );
}

class _TimetableGrid extends ConsumerStatefulWidget {
  const _TimetableGrid({
    required this.courses,
    required this.firstWeekMonday,
    required this.holidaySettings,
    required this.holidaySchedule,
    required this.semesterId,
    required this.selectedWeekOverride,
    required this.autoScrollRequest,
    required this.availableHeight,
    required this.onCourseSelected,
  });

  final List<CourseSlot> courses;
  final DateTime firstWeekMonday;
  final HolidaySettings holidaySettings;
  final ChinaHolidaySchedule holidaySchedule;
  final int? semesterId;
  final int? selectedWeekOverride;
  final int autoScrollRequest;
  final double? availableHeight;
  final ValueChanged<CourseSlot> onCourseSelected;

  @override
  ConsumerState<_TimetableGrid> createState() => _TimetableGridState();
}

class _TimetableGridState extends ConsumerState<_TimetableGrid> {
  late final PageController _pageController;
  late final ScrollController _timelineScrollController;
  late List<_WeekGridData> _weekGridData;
  late int _visibleWeek;
  int? _scheduledPageSyncWeek;
  int _weekAutoScrollGeneration = 0;
  Timer? _weekAutoScrollFallbackTimer;
  ValueNotifier<bool>? _pageScrollSettleNotifier;
  VoidCallback? _pageScrollSettleListener;
  int? _autoScrolledSemesterId;
  int? _lastHandledAutoScrollRequest;
  bool _completedInitialAutoScroll = false;

  @override
  void initState() {
    super.initState();
    _weekGridData = _buildWeekGridData();
    _visibleWeek = ref
        .read(selectedWeekProvider)
        .clamp(1, maxSemesterWeek)
        .toInt();
    _pageController = PageController(initialPage: _visibleWeek - 1);
    _timelineScrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant _TimetableGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldRefreshWeekData(oldWidget)) {
      _weekGridData = _buildWeekGridData();
    }
    _syncPageController(_targetSelectedWeek(watch: false));
  }

  void _syncPageController(int selectedWeek) {
    final targetWeek = selectedWeek.clamp(1, maxSemesterWeek).toInt();
    if (targetWeek == _visibleWeek || _scheduledPageSyncWeek == targetWeek) {
      return;
    }
    _cancelPendingWeekAutoScroll();
    _scheduledPageSyncWeek = targetWeek;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final week = _scheduledPageSyncWeek;
      _scheduledPageSyncWeek = null;
      if (!mounted || week == null || week == _visibleWeek) {
        return;
      }
      if (!_pageController.hasClients) {
        _syncPageController(week);
        return;
      }
      _visibleWeek = week;
      _pageController.jumpToPage(week - 1);
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
    final holidayMutedCourseIds = {
      for (final course in activeCourses)
        if (_isMutedByHoliday(
          course: course,
          dates: dates,
          settings: widget.holidaySettings,
          schedule: widget.holidaySchedule,
        ))
          course.id,
    };
    return _WeekGridData(
      week: week,
      dates: List.unmodifiable(dates),
      holidayRestDays: List.unmodifiable(holidayRestDays),
      holidayMutedCourseIds: Set.unmodifiable(holidayMutedCourseIds),
      layouts: List.unmodifiable(_courseBlockLayouts(activeCourses)),
    );
  }

  @override
  void dispose() {
    _clearWeekAutoScrollWaiters();
    _pageController.dispose();
    _timelineScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedWeek = _targetSelectedWeek(watch: true);
    _syncPageController(selectedWeek);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;
        final gridWidth = constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 32;
        final gutterWidth = isCompact ? 48.0 : 64.0;
        final headerHeight = _timetableHeaderHeight(isCompact);
        final hourHeight = _hourHeightForViewport(
          compact: isCompact,
          headerHeight: headerHeight,
          baseHourHeight: _baseHourHeight(isCompact),
          availableHeight: widget.availableHeight,
        );
        final dayWidth = (gridWidth - gutterWidth) / 7;
        final bodyHeight = _timelineBodyHeight(hourHeight);
        final desiredGridHeight = headerHeight + bodyHeight;
        final minGridHeight = headerHeight + (isCompact ? 360.0 : 420.0);
        final gridHeight =
            widget.availableHeight != null && widget.availableHeight!.isFinite
            ? widget.availableHeight!
                  .clamp(
                    math.min(minGridHeight, desiredGridHeight),
                    desiredGridHeight,
                  )
                  .toDouble()
            : desiredGridHeight;
        final visibleWeekData = _weekGridData[selectedWeek - 1];
        _maybeScheduleAutoScroll(
          selectedWeek: selectedWeek,
          hourHeight: hourHeight,
        );

        return Card(
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: gridWidth,
            height: gridHeight,
            child: Column(
              children: [
                _CalendarGridHeader(
                  key: ValueKey(
                    'timetable-date-header-week-${visibleWeekData.week}',
                  ),
                  width: gridWidth,
                  gutterWidth: gutterWidth,
                  dayWidth: dayWidth,
                  headerHeight: headerHeight,
                  compact: isCompact,
                  dates: visibleWeekData.dates,
                  holidayRestDays: visibleWeekData.holidayRestDays,
                  onDateSelected: () {
                    _scrollToWeekEarliestCourse(
                      week: visibleWeekData.week,
                      hourHeight: hourHeight,
                      animate: true,
                    );
                  },
                ),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: const _TimetableBodyScrollBehavior(),
                    child: SingleChildScrollView(
                      key: const ValueKey('timetable-time-body'),
                      controller: _timelineScrollController,
                      child: SizedBox(
                        width: gridWidth,
                        height: bodyHeight,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ColoredBox(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                              ),
                            ),
                            _CalendarTimeColumn(
                              width: gutterWidth,
                              hourHeight: hourHeight,
                              compact: isCompact,
                            ),
                            Positioned(
                              left: gutterWidth,
                              top: 0,
                              right: 0,
                              bottom: 0,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: maxSemesterWeek,
                                allowImplicitScrolling: true,
                                clipBehavior: Clip.hardEdge,
                                onPageChanged: (index) {
                                  final week = index + 1;
                                  _scheduledPageSyncWeek = null;
                                  _visibleWeek = week;
                                  if (ref.read(selectedWeekProvider) != week) {
                                    ref
                                        .read(selectedWeekProvider.notifier)
                                        .setWeek(week);
                                  }
                                  _scheduleWeekAutoScrollAfterHorizontalSettle(
                                    week: week,
                                    hourHeight: hourHeight,
                                  );
                                },
                                itemBuilder: (context, index) {
                                  final weekData = _weekGridData[index];
                                  return RepaintBoundary(
                                    child: _TimetableGridPage(
                                      key: ValueKey('week-${weekData.week}'),
                                      layouts: weekData.layouts,
                                      holidayRestDays: weekData.holidayRestDays,
                                      holidayMutedCourseIds:
                                          weekData.holidayMutedCourseIds,
                                      width: gridWidth - gutterWidth,
                                      dayWidth: dayWidth,
                                      hourHeight: hourHeight,
                                      compact: isCompact,
                                      onCourseSelected: widget.onCourseSelected,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _targetSelectedWeek({required bool watch}) {
    final selectedWeek = watch
        ? ref.watch(selectedWeekProvider)
        : ref.read(selectedWeekProvider);
    return (widget.selectedWeekOverride ?? selectedWeek)
        .clamp(1, maxSemesterWeek)
        .toInt();
  }

  void _maybeScheduleAutoScroll({
    required int selectedWeek,
    required double hourHeight,
  }) {
    final shouldHandleStartup =
        widget.semesterId != null &&
        _autoScrolledSemesterId != widget.semesterId;
    final shouldHandleRequest =
        _lastHandledAutoScrollRequest != widget.autoScrollRequest;
    if (!shouldHandleStartup && !shouldHandleRequest) {
      return;
    }

    if (shouldHandleStartup) {
      _autoScrolledSemesterId = widget.semesterId;
    }
    if (shouldHandleRequest) {
      _lastHandledAutoScrollRequest = widget.autoScrollRequest;
    }

    final earliestMinute = _earliestCourseStartMinute(
      courses: widget.courses,
      week: selectedWeek,
      dates: _datesForWeek(
        firstWeekMonday: widget.firstWeekMonday,
        week: selectedWeek,
      ),
      settings: widget.holidaySettings,
      schedule: widget.holidaySchedule,
    );
    if (earliestMinute == null) {
      return;
    }

    final targetOffset = _autoScrollOffsetForMinute(
      earliestMinute,
      hourHeight: hourHeight,
    );
    final animate = _completedInitialAutoScroll;
    _completedInitialAutoScroll = true;
    _scheduleTimelineScroll(targetOffset, animate: animate);
  }

  void _scrollToWeekEarliestCourse({
    required int week,
    required double hourHeight,
    required bool animate,
  }) {
    final earliestMinute = _earliestCourseStartMinute(
      courses: widget.courses,
      week: week,
      dates: _datesForWeek(firstWeekMonday: widget.firstWeekMonday, week: week),
      settings: widget.holidaySettings,
      schedule: widget.holidaySchedule,
    );
    if (earliestMinute == null) {
      return;
    }
    _scheduleTimelineScroll(
      _autoScrollOffsetForMinute(earliestMinute, hourHeight: hourHeight),
      animate: animate,
    );
  }

  void _scheduleWeekAutoScrollAfterHorizontalSettle({
    required int week,
    required double hourHeight,
  }) {
    _cancelPendingWeekAutoScroll();
    final generation = _weekAutoScrollGeneration;

    void tryScroll() {
      if (!mounted || generation != _weekAutoScrollGeneration) {
        return;
      }
      if (_visibleWeek != week || ref.read(selectedWeekProvider) != week) {
        return;
      }
      if (!_pageController.hasClients ||
          _pageController.position.isScrollingNotifier.value) {
        return;
      }
      _clearWeekAutoScrollWaiters();
      _scrollToWeekEarliestCourse(
        week: week,
        hourHeight: hourHeight,
        animate: true,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _weekAutoScrollGeneration) {
        return;
      }
      if (!_pageController.hasClients) {
        return;
      }
      final notifier = _pageController.position.isScrollingNotifier;
      void listener() {
        if (!notifier.value) {
          tryScroll();
        }
      }

      _pageScrollSettleNotifier = notifier;
      _pageScrollSettleListener = listener;
      notifier.addListener(listener);
      if (!notifier.value) {
        tryScroll();
        return;
      }
      _weekAutoScrollFallbackTimer = Timer(
        _timetableScrollDuration + const Duration(milliseconds: 120),
        tryScroll,
      );
    });
  }

  void _cancelPendingWeekAutoScroll() {
    _weekAutoScrollGeneration++;
    _clearWeekAutoScrollWaiters();
  }

  void _clearWeekAutoScrollWaiters() {
    _weekAutoScrollFallbackTimer?.cancel();
    _weekAutoScrollFallbackTimer = null;
    final listener = _pageScrollSettleListener;
    final notifier = _pageScrollSettleNotifier;
    if (listener != null && notifier != null) {
      notifier.removeListener(listener);
    }
    _pageScrollSettleListener = null;
    _pageScrollSettleNotifier = null;
  }

  void _scheduleTimelineScroll(
    double targetOffset, {
    required bool animate,
    int attemptsRemaining = 30,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (!_timelineScrollController.hasClients) {
        if (attemptsRemaining > 0) {
          _scheduleTimelineScroll(
            targetOffset,
            animate: animate,
            attemptsRemaining: attemptsRemaining - 1,
          );
        }
        return;
      }
      final position = _timelineScrollController.position;
      if (targetOffset > position.maxScrollExtent &&
          position.maxScrollExtent <= position.minScrollExtent &&
          attemptsRemaining > 0) {
        _scheduleTimelineScroll(
          targetOffset,
          animate: animate,
          attemptsRemaining: attemptsRemaining - 1,
        );
        return;
      }
      final target = targetOffset
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble();
      final disableAnimations =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (!animate || disableAnimations) {
        position.jumpTo(target);
        return;
      }
      _timelineScrollController.animateTo(
        target,
        duration: _timetableScrollDuration,
        curve: _timetableScrollCurve,
      );
    });
  }
}

class _WeekGridData {
  const _WeekGridData({
    required this.week,
    required this.dates,
    required this.holidayRestDays,
    required this.holidayMutedCourseIds,
    required this.layouts,
  });

  final int week;
  final List<DateTime> dates;
  final List<bool> holidayRestDays;
  final Set<String> holidayMutedCourseIds;
  final List<_CourseBlockLayout> layouts;
}

class _TimetableGridPage extends StatefulWidget {
  const _TimetableGridPage({
    super.key,
    required this.layouts,
    required this.holidayRestDays,
    required this.holidayMutedCourseIds,
    required this.width,
    required this.dayWidth,
    required this.hourHeight,
    required this.compact,
    required this.onCourseSelected,
  });

  final List<_CourseBlockLayout> layouts;
  final List<bool> holidayRestDays;
  final Set<String> holidayMutedCourseIds;
  final double width;
  final double dayWidth;
  final double hourHeight;
  final bool compact;
  final ValueChanged<CourseSlot> onCourseSelected;

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
    final bodyHeight = _timelineBodyHeight(widget.hourHeight);
    return SizedBox(
      width: widget.width,
      height: bodyHeight,
      child: Stack(
        children: [
          _CalendarGridBody(
            width: widget.width,
            dayWidth: widget.dayWidth,
            hourHeight: widget.hourHeight,
            holidayRestDays: widget.holidayRestDays,
          ),
          for (final layout in widget.layouts)
            _CalendarCourseBlock(
              key: ValueKey(layout.course.id),
              course: layout.course,
              overlapIndex: layout.overlapIndex,
              overlapCount: layout.overlapCount,
              gutterWidth: 0,
              dayWidth: widget.dayWidth,
              hourHeight: widget.hourHeight,
              compact: widget.compact,
              mutedByHoliday: widget.holidayMutedCourseIds.contains(
                layout.course.id,
              ),
              onTap: () => widget.onCourseSelected(layout.course),
            ),
        ],
      ),
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

double _timetableHeaderHeight(bool compact) => compact ? 52.0 : 58.0;

double _baseHourHeight(bool compact) => compact ? 64.0 : 72.0;

double _hourHeightForViewport({
  required bool compact,
  required double headerHeight,
  required double baseHourHeight,
  required double? availableHeight,
}) {
  if (compact || availableHeight == null || !availableHeight.isFinite) {
    return baseHourHeight;
  }

  const minDesktopHourHeight = 32.0;
  final fittedHourHeight =
      (availableHeight - headerHeight) * 60 / _timelineDurationMinutes;
  return fittedHourHeight
      .clamp(minDesktopHourHeight, baseHourHeight)
      .toDouble();
}

double _timelineBodyHeight(double hourHeight) {
  return _timelineDurationMinutes * hourHeight / 60;
}

double _minuteOffset(int minute, double hourHeight) {
  final visibleMinute = minute
      .clamp(_timelineStartMinute, _timelineEndMinute)
      .toInt();
  return (visibleMinute - _timelineStartMinute) * hourHeight / 60;
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
    var groupEndMinute = 0;

    void flushGroup() {
      if (group.isEmpty) {
        return;
      }
      layouts.addAll(_assignOverlapLanes(group));
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

int _compareCourseBlocks(CourseSlot a, CourseSlot b) {
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

List<_CourseBlockLayout> _assignOverlapLanes(List<CourseSlot> group) {
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
      _CourseBlockLayout(
        course: course,
        overlapIndex: laneByCourse[course] ?? 0,
        overlapCount: overlapCount,
      ),
  ];
}

class _CalendarGridHeader extends StatelessWidget {
  const _CalendarGridHeader({
    super.key,
    required this.width,
    required this.gutterWidth,
    required this.dayWidth,
    required this.headerHeight,
    required this.compact,
    required this.dates,
    required this.holidayRestDays,
    required this.onDateSelected,
  });

  final double width;
  final double gutterWidth;
  final double dayWidth;
  final double headerHeight;
  final bool compact;
  final List<DateTime> dates;
  final List<bool> holidayRestDays;
  final VoidCallback onDateSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final outline = colorScheme.outlineVariant;
    final dayLabels = compact
        ? _compactDayLabels(context)
        : _dayLabels(context);
    final monthLabel = _monthLabel(context, dates);

    return Stack(
      children: [
        SizedBox(width: width, height: headerHeight),
        Positioned.fill(
          child: ColoredBox(color: colorScheme.surfaceContainerHighest),
        ),
        for (var day = 0; day < DateTime.daysPerWeek; day++)
          if (_isHolidayRestDay(holidayRestDays, day))
            Positioned(
              key: ValueKey('holiday-rest-column-${day + 1}'),
              left: gutterWidth + dayWidth * day,
              top: 0,
              width: dayWidth,
              height: headerHeight,
              child: ColoredBox(color: _holidayRestColumnColor(colorScheme)),
            ),
        Positioned(
          left: 0,
          top: 0,
          width: gutterWidth,
          height: headerHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: outline),
                bottom: BorderSide(color: outline),
              ),
            ),
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
              onTap: onDateSelected,
            ),
          ),
        for (var day = 0; day <= 7; day++)
          Positioned(
            left: gutterWidth + dayWidth * day,
            top: 0,
            width: 1,
            height: headerHeight,
            child: ColoredBox(color: outline),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 1,
          child: ColoredBox(color: outline),
        ),
      ],
    );
  }
}

class _CalendarTimeColumn extends StatelessWidget {
  const _CalendarTimeColumn({
    required this.width,
    required this.hourHeight,
    required this.compact,
  });

  final double width;
  final double hourHeight;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final outline = colorScheme.outlineVariant;
    final timeColumnColor = colorScheme.brightness == Brightness.light
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerHighest;
    final bodyHeight = _timelineBodyHeight(hourHeight);

    return SizedBox(
      width: width,
      height: bodyHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: timeColumnColor,
                border: Border(right: BorderSide(color: outline)),
              ),
            ),
          ),
          for (final segment in _timeColumnSegments(compact: compact))
            Positioned(
              key: ValueKey(segment.key),
              left: 0,
              top: _minuteOffset(segment.startMinute, hourHeight),
              width: width,
              height:
                  _minuteOffset(segment.endMinute, hourHeight) -
                  _minuteOffset(segment.startMinute, hourHeight),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: timeColumnColor,
                  border: Border(
                    top: BorderSide(color: outline),
                    right: BorderSide(color: outline),
                    bottom: BorderSide(color: outline),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 6),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        segment.label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CalendarGridBody extends StatelessWidget {
  const _CalendarGridBody({
    required this.width,
    required this.dayWidth,
    required this.hourHeight,
    required this.holidayRestDays,
  });

  final double width;
  final double dayWidth;
  final double hourHeight;
  final List<bool> holidayRestDays;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final outline = colorScheme.outlineVariant;
    final bodyHeight = _timelineBodyHeight(hourHeight);
    final guideMinutes = _timelineGuideMinutes();

    return Stack(
      children: [
        for (var day = 0; day < DateTime.daysPerWeek; day++)
          if (_isHolidayRestDay(holidayRestDays, day))
            Positioned(
              key: ValueKey('holiday-rest-body-column-${day + 1}'),
              left: dayWidth * day,
              top: 0,
              width: dayWidth,
              height: bodyHeight,
              child: ColoredBox(color: _holidayRestColumnColor(colorScheme)),
            ),
        for (final minute in guideMinutes)
          Positioned(
            left: 0,
            top: _minuteOffset(minute, hourHeight),
            width: width,
            height: 1,
            child: ColoredBox(color: outline),
          ),
        for (var day = 0; day <= 7; day++)
          Positioned(
            left: dayWidth * day,
            top: 0,
            width: 1,
            height: bodyHeight,
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
    required this.hourHeight,
    required this.compact,
    required this.mutedByHoliday,
    required this.onTap,
  });

  final CourseSlot course;
  final int overlapIndex;
  final int overlapCount;
  final double gutterWidth;
  final double dayWidth;
  final double hourHeight;
  final bool compact;
  final bool mutedByHoliday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (course.weekday < 1 || course.weekday > 7) {
      return const SizedBox.shrink();
    }
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
    final startMinute = course.startMinuteOfDay
        .clamp(_timelineStartMinute, _timelineEndMinute - 1)
        .toInt();
    final endMinute = course.endMinuteOfDay
        .clamp(startMinute + 1, _timelineEndMinute)
        .toInt();
    final top =
        _minuteOffset(startMinute, hourHeight) + _courseBlockVerticalInset;
    final height = math.max(
      _minimumCourseBlockHeight,
      _minuteOffset(endMinute, hourHeight) -
          _minuteOffset(startMinute, hourHeight) -
          _courseBlockVerticalInset * 2,
    );

    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return AnimatedPositioned(
      duration: disableAnimations ? Duration.zero : appMicroMotionDuration,
      curve: appMicroMotionCurve,
      left: left,
      top: top,
      width: width,
      height: height,
      child: _CourseCard(
        course: course,
        compact: compact,
        mutedByHoliday: mutedByHoliday,
        onTap: onTap,
      ),
    );
  }
}

class _DayHeaderCell extends StatelessWidget {
  const _DayHeaderCell({
    required this.label,
    required this.date,
    required this.holidayRestDay,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final bool holidayRestDay;
  final bool compact;
  final VoidCallback onTap;

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

    return InkWell(
      onTap: onTap,
      child: Center(
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
    required this.mutedByHoliday,
    required this.onTap,
  });

  final CourseSlot course;
  final bool compact;
  final bool mutedByHoliday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = mutedByHoliday
        ? _holidayMutedCourseColor(colorScheme)
        : course.color;
    final textColor = mutedByHoliday
        ? colorScheme.onSurfaceVariant
        : readableCourseTextColor(course.color);
    const borderRadius = BorderRadius.all(Radius.circular(8));
    final semanticParts = [
      course.name,
      course.location,
      course.teacher,
    ].where((part) => part.trim().isNotEmpty).join(', ');

    return Material(
      color: backgroundColor,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: mutedByHoliday
              ? Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.72),
                )
              : null,
        ),
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
                          constraints: BoxConstraints(
                            maxHeight: titleMaxHeight,
                          ),
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
                                        padding: const EdgeInsets.only(
                                          bottom: 2,
                                        ),
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
      ),
    );
  }
}

Color _holidayMutedCourseColor(ColorScheme colorScheme) {
  return Color.alphaBlend(
    colorScheme.onSurfaceVariant.withValues(
      alpha: colorScheme.brightness == Brightness.light ? 0.12 : 0.18,
    ),
    colorScheme.surfaceContainerHighest,
  );
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

class _TimetableBodyScrollBehavior extends ScrollBehavior {
  const _TimetableBodyScrollBehavior();

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

class _TimeColumnSegment {
  const _TimeColumnSegment({
    required this.key,
    required this.startMinute,
    required this.endMinute,
    required this.label,
  });

  final String key;
  final int startMinute;
  final int endMinute;
  final String label;
}

List<_TimeColumnSegment> _timeColumnSegments({required bool compact}) {
  final segments = <_TimeColumnSegment>[];
  _addWholeHourSegments(
    segments,
    startMinute: _timelineStartMinute,
    endMinute: defaultLessonTimeSlots.first.startMinuteOfDay,
  );

  for (var index = 0; index < defaultLessonTimeSlots.length; index++) {
    final slot = defaultLessonTimeSlots[index];
    segments.add(
      _TimeColumnSegment(
        key: 'lesson-row-${slot.section}',
        startMinute: slot.startMinuteOfDay,
        endMinute: slot.endMinuteOfDay,
        label: _lessonSlotLabel(slot, compact: compact),
      ),
    );
    final nextIndex = index + 1;
    if (nextIndex < defaultLessonTimeSlots.length) {
      _addWholeHourSegments(
        segments,
        startMinute: slot.endMinuteOfDay,
        endMinute: defaultLessonTimeSlots[nextIndex].startMinuteOfDay,
      );
    }
  }

  _addWholeHourSegments(
    segments,
    startMinute: defaultLessonTimeSlots.last.endMinuteOfDay,
    endMinute: _timelineEndMinute,
  );
  return segments..sort((a, b) => a.startMinute.compareTo(b.startMinute));
}

void _addWholeHourSegments(
  List<_TimeColumnSegment> segments, {
  required int startMinute,
  required int endMinute,
}) {
  final firstWholeHour = ((startMinute + 59) ~/ 60) * 60;
  for (var minute = firstWholeHour; minute < endMinute; minute += 60) {
    segments.add(
      _TimeColumnSegment(
        key: 'hour-row-$minute',
        startMinute: minute,
        endMinute: math.min(minute + 60, endMinute),
        label: _minuteLabel(minute),
      ),
    );
  }
}

List<int> _timelineGuideMinutes() {
  final minutes = <int>{0, minutesPerDay};
  _addWholeHourGuideMinutes(
    minutes,
    startMinute: _timelineStartMinute,
    endMinute: defaultLessonTimeSlots.first.startMinuteOfDay,
  );
  for (var index = 0; index < defaultLessonTimeSlots.length; index++) {
    final slot = defaultLessonTimeSlots[index];
    minutes
      ..add(slot.startMinuteOfDay)
      ..add(slot.endMinuteOfDay);
    final nextIndex = index + 1;
    if (nextIndex < defaultLessonTimeSlots.length) {
      _addWholeHourGuideMinutes(
        minutes,
        startMinute: slot.endMinuteOfDay,
        endMinute: defaultLessonTimeSlots[nextIndex].startMinuteOfDay,
      );
    }
  }
  _addWholeHourGuideMinutes(
    minutes,
    startMinute: defaultLessonTimeSlots.last.endMinuteOfDay,
    endMinute: _timelineEndMinute,
  );
  return minutes.toList()..sort();
}

void _addWholeHourGuideMinutes(
  Set<int> minutes, {
  required int startMinute,
  required int endMinute,
}) {
  final firstWholeHour = ((startMinute + 59) ~/ 60) * 60;
  for (var minute = firstWholeHour; minute <= endMinute; minute += 60) {
    minutes.add(minute);
  }
}

String _lessonSlotLabel(LessonTimeSlot slot, {required bool compact}) {
  final start = _minuteLabel(slot.startMinuteOfDay);
  final end = _minuteLabel(slot.endMinuteOfDay);
  if (compact) {
    return '${slot.section}\n$start\n$end';
  }
  return '${slot.section}\n$start-$end';
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
  const _TodayCourseList({
    required this.courses,
    required this.onCourseSelected,
  });

  final List<CourseSlot> courses;
  final ValueChanged<CourseSlot> onCourseSelected;

  @override
  Widget build(BuildContext context) {
    final ordered = [...courses]
      ..sort((a, b) {
        final byStart = a.startMinuteOfDay.compareTo(b.startMinuteOfDay);
        return byStart == 0
            ? a.endMinuteOfDay.compareTo(b.endMinuteOfDay)
            : byStart;
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
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(backgroundColor: course.color),
                          title: Text(course.name),
                          subtitle: Text(
                            '${_courseTimeLabel(course)}  '
                            '${course.location}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => onCourseSelected(course),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

void _showCourseDetailsDialog(BuildContext context, CourseSlot course) {
  final returnPath = GoRouterState.of(context).uri.toString();
  final details = _CourseDetails(course: course, returnPath: returnPath);
  final colorScheme = Theme.of(context).colorScheme;
  showDialog<void>(
    context: context,
    barrierColor: appModalScrimColor(colorScheme),
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: details,
      ),
    ),
  );
}

void _showCourseDetailsSheet(BuildContext context, CourseSlot course) {
  final returnPath = GoRouterState.of(context).uri.toString();
  Navigator.of(
    context,
  ).push(_CourseDetailsSheetRoute(course: course, returnPath: returnPath));
}

class _CourseDetailsSheetRoute extends PopupRoute<void> {
  _CourseDetailsSheetRoute({required this.course, required this.returnPath});

  final CourseSlot course;
  final String returnPath;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => _courseSheetTransitionDuration;

  @override
  Duration get reverseTransitionDuration =>
      _courseSheetReverseTransitionDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _CourseDetailsSheetOverlay(
      animation: animation,
      course: course,
      returnPath: returnPath,
    );
  }
}

class _CourseDetailsSheetOverlay extends StatelessWidget {
  const _CourseDetailsSheetOverlay({
    required this.animation,
    required this.course,
    required this.returnPath,
  });

  final Animation<double> animation;
  final CourseSlot course;
  final String returnPath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final slideAnimation = curvedAnimation.drive(
      Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero),
    );

    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
          child: FadeTransition(
            opacity: curvedAnimation,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: ColoredBox(color: appModalScrimColor(colorScheme)),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SlideTransition(
            position: slideAnimation,
            child: _CourseDetailsSheet(
              key: const ValueKey<String>('course-details-sheet'),
              child: _CourseDetails(
                course: course,
                returnPath: returnPath,
                onClose: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CourseDetailsSheet extends StatelessWidget {
  const _CourseDetailsSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final navigationBarBackground =
        Theme.of(context).navigationBarTheme.backgroundColor ??
        colorScheme.surfaceContainerLow;
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Material(
          color: navigationBarBackground,
          surfaceTintColor: Colors.transparent,
          elevation: 6,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.24),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const SizedBox(width: 32, height: 4),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseDetails extends StatelessWidget {
  const _CourseDetails({
    required this.course,
    required this.returnPath,
    this.onClose,
  });

  final CourseSlot course;
  final String returnPath;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final canEdit =
        (course.courseId != null && course.sessionId != null) ||
        course.examId != null;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 12, 24),
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
              if (canEdit)
                IconButton(
                  tooltip: context.l10n.edit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 48,
                    height: 48,
                  ),
                  onPressed: () {
                    final router = GoRouter.of(context);
                    if (onClose == null) {
                      Navigator.of(context).pop();
                    } else {
                      onClose!();
                    }
                    router.push(
                      Uri(
                        path: '/editor',
                        queryParameters: {
                          'slot': course.id,
                          'from': returnPath,
                        },
                      ).toString(),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
              if (onClose != null)
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 48,
                    height: 48,
                  ),
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
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
                '${_courseTimeLabel(course)}, '
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

String _courseTimeLabel(CourseSlot course) {
  return '${_minuteLabel(course.startMinuteOfDay)}-'
      '${_minuteLabel(course.endMinuteOfDay)}';
}

String _minuteLabel(int minuteOfDay) {
  final hour = minuteOfDay ~/ 60;
  final minute = minuteOfDay % 60;
  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
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
