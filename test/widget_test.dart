import 'dart:async';
import 'dart:typed_data';

import 'package:crid/app/app.dart';
import 'package:crid/app/app_state.dart';
import 'package:crid/app/locale_controller.dart';
import 'package:crid/app/motion.dart';
import 'package:crid/app/theme_controller.dart';
import 'package:crid/core/theme/course_colors.dart';
import 'package:crid/core/time/period.dart';
import 'package:crid/data/database/app_database.dart';
import 'package:crid/data/database/timetable_time.dart' hide WeekParity;
import 'package:crid/features/reminder/data/local_notification_reminder_scheduler.dart';
import 'package:crid/features/settings/data/android_background_service.dart';
import 'package:crid/features/settings/data/china_holiday_service.dart';
import 'package:crid/features/settings/data/holiday_settings_controller.dart';
import 'package:crid/features/settings/presentation/export_page.dart';
import 'package:crid/features/settings/presentation/third_party_licenses_page.dart';
import 'package:crid/features/timetable/data/timetable_repository.dart';
import 'package:crid/features/timetable/presentation/course_slot_model.dart';
import 'package:crid/features/timetable/presentation/plan_management_page.dart';
import 'package:crid/features/timetable/presentation/timetable_home_page.dart';
import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final expectedInitialWeek = weekNumberForDate(
    firstWeekMonday: DateTime(2026, 2, 23),
    date: DateTime.now(),
  );

  Future<void> pumpApp(
    WidgetTester tester, {
    Locale? locale,
    Map<String, Object> preferences = const {},
    ChinaHolidayService? chinaHolidayService,
    ExportFileService? exportFileService,
    ReminderSchedulerService? reminderScheduler,
    AndroidBackgroundService? androidBackgroundService,
    FutureOr<void> Function(AppDatabase database)? seedDatabase,
  }) async {
    debugOpenSourceLicensePreloadEnabled = false;
    debugResetOpenSourceLicenseCache();
    addTearDown(() {
      debugOpenSourceLicensePreloadEnabled = true;
      debugResetOpenSourceLicenseCache();
    });
    SharedPreferences.setMockInitialValues(preferences);
    if (locale != null) {
      tester.platformDispatcher.localesTestValue = [locale];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    }
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    if (seedDatabase != null) {
      await seedDatabase(database);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          chinaHolidayServiceProvider.overrideWithValue(
            chinaHolidayService ?? const _FakeChinaHolidayService(),
          ),
          reminderSchedulerProvider.overrideWithValue(
            reminderScheduler ?? const _FakeReminderScheduler(),
          ),
          if (androidBackgroundService != null)
            androidBackgroundServiceProvider.overrideWithValue(
              androidBackgroundService,
            ),
          if (exportFileService != null)
            exportFileServiceProvider.overrideWithValue(exportFileService),
        ],
        child: const CridApp(),
      ),
    );

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('课表').evaluate().isNotEmpty ||
          find.text('Timetable').evaluate().isNotEmpty ||
          find.text('課表').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pumpAndSettle();
  }

  testWidgets('shows timetable on narrow screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    );

    expect(find.text('课表'), findsWidgets);
    expect(find.text('第 $expectedInitialWeek 周'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(2));
    expect(find.byTooltip('设置'), findsOneWidget);
    expect(find.text('Advanced Mathematics'), findsNothing);
  });

  testWidgets('shows navigation rail on wide screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Advanced Mathematics'), findsNothing);
  });

  testWidgets('desktop timetable exposes Android primary actions and context', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    expect(find.text('Timetable'), findsWidgets);
    expect(find.text('Week $expectedInitialWeek'), findsWidgets);
    expect(find.byType(PageView), findsOneWidget);
    expect(find.byTooltip('Previous week'), findsNothing);
    expect(find.byTooltip('Next week'), findsNothing);
    expect(find.text('Add course'), findsOneWidget);
    expect(find.byTooltip('Import'), findsOneWidget);
    expect(find.byTooltip('Export'), findsOneWidget);
  });

  testWidgets('timetable grid swipes horizontally between weeks', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    expect(find.text('Week $expectedInitialWeek'), findsWidgets);
    expect(
      tester.widget<PageView>(find.byType(PageView)).allowImplicitScrolling,
      isTrue,
    );

    await tester.dragFrom(
      tester.getTopLeft(find.byType(PageView).first) + const Offset(195, 120),
      const Offset(-320, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Week ${expectedInitialWeek + 1}'), findsWidgets);
  });

  testWidgets('timetable grid keeps advancing across consecutive swipes', (
    tester,
  ) async {
    if (expectedInitialWeek > maxSemesterWeek - 3) {
      return;
    }

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CridApp)),
    );
    await container
        .read(timetableControllerProvider.notifier)
        .saveCourse(
          CourseSlotDraft(
            name: 'Third Swipe Target',
            teacher: 'Professor Later',
            location: 'Room 1330',
            weekday: DateTime.monday,
            timeRange: CourseTimeRange.fromPeriods(5, 5),
            startWeek: expectedInitialWeek + 3,
            endWeek: expectedInitialWeek + 3,
            parity: WeekParity.all,
            color: courseColorForIndex(3),
          ),
        );
    await tester.pumpAndSettle();

    for (var index = 0; index < 3; index++) {
      await tester.dragFrom(
        tester.getTopLeft(find.byType(PageView).first) + const Offset(195, 120),
        const Offset(-320, 0),
      );
      await tester.pumpAndSettle();
    }

    expect(find.text('Week ${expectedInitialWeek + 3}'), findsWidgets);
    expect(
      _timetableScrollState(tester, expectedInitialWeek + 3).position.pixels,
      greaterThan(700),
    );
  });

  testWidgets('timetable grid swipes right to previous adjacent week', (
    tester,
  ) async {
    if (expectedInitialWeek <= 1) {
      return;
    }

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    expect(find.text('Week $expectedInitialWeek'), findsWidgets);

    await tester.dragFrom(
      tester.getTopLeft(find.byType(PageView).first) + const Offset(195, 120),
      const Offset(320, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Week ${expectedInitialWeek - 1}'), findsWidgets);
  });

  testWidgets('desktop navigation rail can be collapsed and expanded', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isTrue,
    );

    await tester.tap(find.byTooltip('Collapse sidebar'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isFalse,
    );

    await tester.tap(find.byTooltip('Expand sidebar'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isTrue,
    );
  });

  testWidgets('desktop timetable grid fits a high-resolution viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(2048, 1040));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    final gridBottom = tester.getBottomLeft(find.byType(Card).first).dy;

    expect(gridBottom, lessThanOrEqualTo(1040));
  });

  testWidgets('uses Traditional Chinese for zh-Hant system locale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );

    expect(find.text('課表'), findsWidgets);
    expect(find.text('第 $expectedInitialWeek 週'), findsWidgets);
  });

  testWidgets('uses English for en system locale', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    expect(find.text('Timetable'), findsWidgets);
    expect(
      find.text(DateFormat.MMMM('en').format(DateTime.now())),
      findsOneWidget,
    );
    expect(find.text('Week $expectedInitialWeek'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text("Today's courses"),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text("Today's courses"), findsOneWidget);
  });

  testWidgets('today section keeps standard compact page inset', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    expect(tester.getTopLeft(find.byType(Card).first).dx, lessThan(16));

    await tester.scrollUntilVisible(
      find.text("Today's courses"),
      600,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      tester.getTopLeft(find.text("Today's courses")).dx,
      closeTo(16, 0.1),
    );
  });

  testWidgets('today date highlight is circular', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    final colorScheme = Theme.of(
      tester.element(find.byType(TimetableHomePage)),
    ).colorScheme;
    final badgeFinder = find.byWidgetPredicate((widget) {
      if (widget is! AnimatedContainer) {
        return false;
      }
      final decoration = widget.decoration;
      return decoration is BoxDecoration &&
          decoration.shape == BoxShape.circle &&
          decoration.color == colorScheme.primary;
    });
    final badgeSize = tester.getSize(badgeFinder.first);

    expect(badgeFinder, findsOneWidget);
    expect(badgeSize.width, badgeSize.height);
  });

  testWidgets('time column surface separates from app background', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    final theme = Theme.of(tester.element(find.byType(TimetableHomePage)));
    final colorScheme = theme.colorScheme;
    final expectedTimeColumnColor = colorScheme.brightness == Brightness.light
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerHighest;
    final timeColumnCell = find.byWidgetPredicate((widget) {
      if (widget is! DecoratedBox) {
        return false;
      }
      final decoration = widget.decoration;
      if (decoration is! BoxDecoration) {
        return false;
      }
      return decoration.color == expectedTimeColumnColor;
    });

    expect(timeColumnCell, findsWidgets);
    expect(
      expectedTimeColumnColor.computeLuminance(),
      greaterThan(colorScheme.surfaceContainerHigh.computeLuminance()),
    );
  });

  testWidgets('timetable date header stays fixed above lesson time rows', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    final header = find.byKey(
      ValueKey('timetable-date-header-week-$expectedInitialWeek'),
    );
    final timeBody = find.byKey(const ValueKey('timetable-time-body'));

    expect(header, findsOneWidget);
    expect(timeBody, findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('12:00'), findsOneWidget);
    expect(find.textContaining('08:00'), findsWidgets);

    final headerTop = tester.getTopLeft(header).dy;
    await tester.drag(timeBody, const Offset(0, -320));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(header).dy, closeTo(headerTop, 0.1));
    expect(find.text('00:00'), findsOneWidget);
  });

  testWidgets('startup auto-scrolls to current week earliest course', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final today = DateTime.now();
    final earlyWeekday = today.weekday == DateTime.monday
        ? DateTime.tuesday
        : DateTime.monday;

    await pumpApp(
      tester,
      locale: const Locale('en'),
      seedDatabase: (database) async {
        final repository = TimetableRepository(database);
        await repository.ensureSeedData();
        await repository.saveCourse(
          CourseSlotDraft(
            name: 'Week Earliest Startup',
            teacher: 'Professor Dawn',
            location: 'Room 0800',
            weekday: earlyWeekday,
            timeRange: CourseTimeRange.fromPeriods(1, 1),
            startWeek: expectedInitialWeek,
            endWeek: expectedInitialWeek,
            parity: WeekParity.all,
            color: courseColorForIndex(0),
          ),
        );
        await repository.saveCourse(
          CourseSlotDraft(
            name: 'Today Later Startup',
            teacher: 'Professor Noon',
            location: 'Room 1330',
            weekday: today.weekday,
            timeRange: CourseTimeRange.fromPeriods(5, 5),
            startWeek: expectedInitialWeek,
            endWeek: expectedInitialWeek,
            parity: WeekParity.all,
            color: courseColorForIndex(1),
          ),
        );
      },
    );

    final scrollState = _timetableScrollState(tester, expectedInitialWeek);

    expect(scrollState.position.pixels, greaterThan(450));
    expect(scrollState.position.pixels, lessThan(650));
  });

  testWidgets('tapping any date header scrolls to week earliest course', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CridApp)),
    );
    await container
        .read(timetableControllerProvider.notifier)
        .saveCourse(
          CourseSlotDraft(
            name: 'Midday Header Target',
            teacher: 'Professor Noon',
            location: 'Room 1200',
            weekday: DateTime.wednesday,
            timeRange: CourseTimeRange.fromPeriods(5, 5),
            startWeek: expectedInitialWeek,
            endWeek: expectedInitialWeek,
            parity: WeekParity.all,
            color: courseColorForIndex(0),
          ),
        );
    await container
        .read(timetableControllerProvider.notifier)
        .saveCourse(
          CourseSlotDraft(
            name: 'Week Earliest Header Target',
            teacher: 'Professor Dawn',
            location: 'Room 0800',
            weekday: DateTime.monday,
            timeRange: CourseTimeRange.fromPeriods(1, 1),
            startWeek: expectedInitialWeek,
            endWeek: expectedInitialWeek,
            parity: WeekParity.all,
            color: courseColorForIndex(1),
          ),
        );
    await tester.pumpAndSettle();

    final scrollState = _timetableScrollState(tester, expectedInitialWeek);
    expect(scrollState.position.pixels, lessThan(100));

    final weekMonday = DateTime(
      2026,
      2,
      23,
    ).add(Duration(days: (expectedInitialWeek - 1) * 7));
    final clickedDate = weekMonday.add(const Duration(days: 2));
    final header = find.byKey(
      ValueKey('timetable-date-header-week-$expectedInitialWeek'),
    );
    await tester.tap(
      find.descendant(of: header, matching: find.text('${clickedDate.day}')),
    );
    await tester.pumpAndSettle();

    expect(scrollState.position.pixels, greaterThan(450));
    expect(scrollState.position.pixels, lessThan(650));
  });

  testWidgets(
    'week swipe scrolls to next week earliest course after settling',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpApp(tester, locale: const Locale('en'));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CridApp)),
      );
      await container
          .read(timetableControllerProvider.notifier)
          .saveCourse(
            CourseSlotDraft(
              name: 'Next Week Midday Target',
              teacher: 'Professor Noon',
              location: 'Room 1330',
              weekday: DateTime.monday,
              timeRange: CourseTimeRange.fromPeriods(5, 5),
              startWeek: expectedInitialWeek + 1,
              endWeek: expectedInitialWeek + 1,
              parity: WeekParity.all,
              color: courseColorForIndex(2),
            ),
          );
      await tester.pumpAndSettle();

      final scrollState = _timetableScrollState(tester, expectedInitialWeek);
      expect(scrollState.position.pixels, lessThan(100));

      await tester.dragFrom(
        tester.getTopLeft(find.byType(PageView).first) + const Offset(195, 120),
        const Offset(-320, 0),
      );
      await tester.pump();
      expect(scrollState.position.pixels, lessThan(100));
      await tester.pumpAndSettle();

      expect(find.text('Week ${expectedInitialWeek + 1}'), findsWidgets);
      final settledScrollState = _timetableScrollState(
        tester,
        expectedInitialWeek + 1,
      );
      expect(settledScrollState.position.pixels, greaterThan(700));
    },
  );

  testWidgets('timetable marks holiday-hidden days with a rest column', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final today = DateTime.now();
    final schedule = ChinaHolidaySchedule(
      year: today.year,
      legalHolidayDates: {_testDateKey(today)},
      adjustedRestDates: const {},
      makeUpWorkdayDates: const {},
    );

    await pumpApp(
      tester,
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      preferences: {
        'holiday_hide_legal_holidays': true,
        'holiday_adjustment_mode': HolidayAdjustmentMode.noAdjustment.name,
      },
      chinaHolidayService: _FakeChinaHolidayService({today.year: schedule}),
    );

    expect(
      find.byKey(ValueKey('holiday-rest-column-${today.weekday}')),
      findsOneWidget,
    );
  });

  testWidgets('Android back from a secondary tab returns to timetable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      seedDatabase: (database) async {
        final repository = TimetableRepository(database);
        await repository.ensureSeedData();
        await repository.saveCourse(
          CourseSlotDraft(
            name: '返回课表自动定位',
            teacher: 'Professor Noon',
            location: 'Room 1330',
            weekday: DateTime.monday,
            timeRange: CourseTimeRange.fromPeriods(5, 5),
            startWeek: expectedInitialWeek,
            endWeek: expectedInitialWeek,
            parity: WeekParity.all,
            color: courseColorForIndex(2),
          ),
        );
      },
    );
    final scrollState = _timetableScrollState(tester, expectedInitialWeek);
    scrollState.position.jumpTo(0);
    await tester.pump();
    expect(scrollState.position.pixels, lessThan(100));

    await tester.tap(find.text('方案').last);
    await tester.pumpAndSettle();

    expect(find.text('课表方案'), findsOneWidget);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator).first).canPop(),
      isFalse,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('第 $expectedInitialWeek 周'), findsWidgets);
    expect(
      _timetableScrollState(tester, expectedInitialWeek).position.pixels,
      greaterThan(700),
    );
  });

  testWidgets('returning from plans tab auto-scrolls timetable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      locale: const Locale('en'),
      seedDatabase: (database) async {
        final repository = TimetableRepository(database);
        await repository.ensureSeedData();
        await repository.saveCourse(
          CourseSlotDraft(
            name: 'Plans Return Target',
            teacher: 'Professor Noon',
            location: 'Room 1330',
            weekday: DateTime.monday,
            timeRange: CourseTimeRange.fromPeriods(5, 5),
            startWeek: expectedInitialWeek,
            endWeek: expectedInitialWeek,
            parity: WeekParity.all,
            color: courseColorForIndex(3),
          ),
        );
      },
    );
    final scrollState = _timetableScrollState(tester, expectedInitialWeek);
    scrollState.position.jumpTo(0);
    await tester.pump();
    expect(scrollState.position.pixels, lessThan(100));

    await tester.tap(find.text('Plans').last);
    await tester.pumpAndSettle();
    expect(find.text('Timetable plans'), findsOneWidget);

    await tester.tap(find.text('Timetable').last);
    await tester.pumpAndSettle();

    expect(find.text('Week $expectedInitialWeek'), findsWidgets);
    expect(
      _timetableScrollState(tester, expectedInitialWeek).position.pixels,
      greaterThan(700),
    );
  });

  testWidgets('core destinations slide horizontally when switching', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    await tester.tap(find.text('Plans').last);
    await tester.pump();
    await tester.pump(appCoreDestinationMotionDuration ~/ 2);

    expect(find.byType(TimetableHomePage), findsOneWidget);
    expect(find.byType(PlanManagementPage), findsOneWidget);
    expect(tester.getTopLeft(find.byType(TimetableHomePage)).dx, lessThan(0));
    expect(
      tester.getTopLeft(find.byType(PlanManagementPage)).dx,
      greaterThan(0),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Timetable').last);
    await tester.pump();
    await tester.pump(appCoreDestinationMotionDuration ~/ 2);

    expect(find.byType(TimetableHomePage), findsOneWidget);
    expect(find.byType(PlanManagementPage), findsOneWidget);
    expect(tester.getTopLeft(find.byType(TimetableHomePage)).dx, lessThan(0));
    expect(
      tester.getTopLeft(find.byType(PlanManagementPage)).dx,
      greaterThan(0),
    );
  });

  testWidgets('returning from settings to previous plans route pops route', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));
    await tester.tap(find.text('Plans').last);
    await tester.pumpAndSettle();

    expect(find.text('Timetable plans'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Reminders'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Timetable plans'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Week $expectedInitialWeek'), findsWidgets);
    expect(find.text('Timetable plans'), findsNothing);
  });

  testWidgets('system back from settings returns to timetable', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Reminders'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Week $expectedInitialWeek'), findsWidgets);
    expect(find.text('Reminders'), findsNothing);
  });

  testWidgets('secondary page titles sit close to the back button', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    await tester.tap(find.byTooltip('Import'));
    await tester.pumpAndSettle();
    _expectBackTitleGap(tester, 'Import');
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.text('Review imports'));
    await tester.pumpAndSettle();
    _expectBackTitleGap(tester, 'Conflict handling');
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Export'));
    await tester.pumpAndSettle();
    _expectBackTitleGap(tester, 'Export');
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    _expectBackTitleGap(tester, 'Settings');
  });

  testWidgets('manual language preference overrides system locale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      preferences: {'app_locale_mode': AppLocaleMode.simplifiedChinese.name},
    );

    expect(find.text('课表'), findsWidgets);
    expect(find.text('第 $expectedInitialWeek 周'), findsWidgets);
  });
  testWidgets('manual English preference is available', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      preferences: {'app_locale_mode': AppLocaleMode.english.name},
    );

    expect(find.text('Timetable'), findsWidgets);
    expect(find.text('Week $expectedInitialWeek'), findsWidgets);
  });

  testWidgets('manual dark theme preference overrides system theme', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      locale: const Locale('en'),
      preferences: {'app_theme_mode': AppThemeMode.dark.name},
    );

    final theme = Theme.of(tester.element(find.byType(TimetableHomePage)));
    expect(theme.brightness, Brightness.dark);
  });

  testWidgets('mobile timetable top bar shows direct actions in order', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    final addButton = find.byTooltip('Add course');
    final importButton = find.byTooltip('Import');
    final exportButton = find.byTooltip('Export');

    expect(addButton, findsOneWidget);
    expect(importButton, findsOneWidget);
    expect(exportButton, findsOneWidget);
    expect(find.byTooltip('Show menu'), findsNothing);
    expect(
      tester.getCenter(addButton).dx,
      lessThan(tester.getCenter(importButton).dx),
    );
    expect(
      tester.getCenter(importButton).dx,
      lessThan(tester.getCenter(exportButton).dx),
    );
    expect(
      (tester.getCenter(addButton).dy - tester.getCenter(importButton).dy)
          .abs(),
      lessThanOrEqualTo(1),
    );
    expect(
      (tester.getCenter(addButton).dy - tester.getCenter(exportButton).dy)
          .abs(),
      lessThanOrEqualTo(1),
    );
  });

  testWidgets('narrow timetable add action aligns with toolbar icons', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(340, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    final moreButton = find.byTooltip('Show menu');
    final addButton = find.byTooltip('Add course');
    final settingsButton = find.byTooltip('Settings');

    expect(moreButton, findsOneWidget);
    expect(addButton, findsOneWidget);
    expect(settingsButton, findsOneWidget);
    expect(
      (tester.getCenter(addButton).dy - tester.getCenter(moreButton).dy).abs(),
      lessThanOrEqualTo(1),
    );
    expect(
      (tester.getCenter(addButton).dy - tester.getCenter(settingsButton).dy)
          .abs(),
      lessThanOrEqualTo(1),
    );
  });

  testWidgets('stable toolbar actions persist when switching core pages', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    final importElement = tester.element(find.byTooltip('Import'));
    final exportElement = tester.element(find.byTooltip('Export'));

    await tester.tap(find.text('Plans').last);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Add course'), findsNothing);
    expect(tester.element(find.byTooltip('Import')), same(importElement));
    expect(tester.element(find.byTooltip('Export')), same(exportElement));
  });

  testWidgets('today button uses a rounded rectangle shape', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));
    await tester.dragFrom(
      tester.getTopLeft(find.byType(PageView).first) + const Offset(195, 120),
      const Offset(-320, 0),
    );
    await tester.pumpAndSettle();

    final todayFab = find.ancestor(
      of: find.text('Today'),
      matching: find.byType(FloatingActionButton),
    );
    final button = tester.widget<FloatingActionButton>(todayFab);
    final shape = button.shape;

    expect(todayFab, findsOneWidget);
    expect(shape, isA<RoundedRectangleBorder>());
    expect(
      (shape! as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(18),
    );
  });

  testWidgets('mobile top bar moves settings out of bottom navigation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    await tester.tap(find.text('Plans').last);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Add course'), findsNothing);
    expect(find.byTooltip('Import'), findsOneWidget);
    expect(find.byTooltip('Export'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
    final settingsButton = find.widgetWithIcon(
      IconButton,
      Icons.settings_outlined,
    );
    expect(settingsButton, findsOneWidget);
    expect(tester.widget<IconButton>(settingsButton).style, isNotNull);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byTooltip('Add course'), findsNothing);
    expect(find.byTooltip('Import'), findsNothing);
    expect(find.byTooltip('Export'), findsNothing);
    expect(find.byTooltip('Settings'), findsNothing);
  });

  testWidgets('export actions show progress while preparing a file', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final fileService = _BlockingExportFileService();
    await pumpApp(
      tester,
      locale: const Locale('en'),
      exportFileService: fileService,
    );

    await tester.tap(find.byTooltip('Export'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Export ICS'));
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    fileService.completeSave('C:\\tmp\\crid.ics');
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(LinearProgressIndicator).evaluate().isEmpty) {
        break;
      }
    }

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.textContaining('crid.ics'), findsOneWidget);
  });

  testWidgets('wide top bar moves settings out of navigation rail', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    await tester.tap(find.text('Plans').last);
    await tester.pumpAndSettle();

    expect(find.text('Add course'), findsNothing);
    expect(find.byTooltip('Import'), findsOneWidget);
    expect(find.byTooltip('Export'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
    final settingsButton = find.widgetWithIcon(
      IconButton,
      Icons.settings_outlined,
    );
    expect(settingsButton, findsOneWidget);
    expect(tester.widget<IconButton>(settingsButton).style, isNotNull);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Add course'), findsNothing);
    expect(find.byTooltip('Import'), findsNothing);
    expect(find.byTooltip('Export'), findsNothing);
    expect(find.byTooltip('Settings'), findsNothing);
  });

  testWidgets('desktop settings exposes Android display controls', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Display'),
      500,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Display'), findsOneWidget);
    expect(find.text('Follow system'), findsWidgets);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets(
    'Android background settings keep battery and autostart controls',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpApp(
        tester,
        locale: const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hans',
        ),
        androidBackgroundService: _FakeAndroidBackgroundService(),
      );

      await tester.tap(find.byTooltip('设置'));
      await tester.pumpAndSettle();

      expect(find.text('Android 后台运行'), findsOneWidget);
      expect(find.text('持续后台运行'), findsOneWidget);
      expect(find.text('电池设置'), findsOneWidget);
      expect(find.text('自启动设置'), findsOneWidget);
      expect(find.text('申请后台运行权限'), findsOneWidget);
      expect(find.text('让提醒更稳定'), findsNothing);
    },
  );

  testWidgets('settings info section shows licenses before app version', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    );

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -1600));
    await tester.pumpAndSettle();

    final licenses = find.text('开放源代码许可');
    final localData = find.text('本地数据');
    final appTitle = find.text('课格');

    expect(licenses, findsOneWidget);
    expect(localData, findsOneWidget);
    expect(appTitle, findsOneWidget);
    expect(find.text('1.1.0-release'), findsOneWidget);
    expect(find.text('无需登录；课表和提醒都在本机处理。'), findsNothing);

    expect(
      tester.getTopLeft(licenses).dy,
      lessThan(tester.getTopLeft(localData).dy),
    );
    expect(
      tester.getTopLeft(localData).dy,
      lessThan(tester.getTopLeft(appTitle).dy),
    );
  });

  testWidgets('open-source license page shows Crid license details', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    );

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('开放源代码许可'),
      600,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('开放源代码许可'));

    for (
      var i = 0;
      i < 100 && find.byType(CustomScrollView).evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(seconds: 1));
    final licenseScrollable = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.byType(Scrollable),
    );
    final appLicenseTitle = find.descendant(
      of: find.byType(ListTile),
      matching: find.text('课格（Crid）'),
    );
    expect(licenseScrollable, findsOneWidget);
    await tester.scrollUntilVisible(
      appLicenseTitle,
      600,
      scrollable: licenseScrollable,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('开放源代码许可'), findsWidgets);
    expect(appLicenseTitle, findsOneWidget);
    expect(find.textContaining('段许可文本'), findsNothing);

    await tester.tap(
      find.ancestor(of: appLicenseTitle, matching: find.byType(ListTile)),
    );
    for (
      var i = 0;
      i < 100 && find.textContaining('TERMS AND CONDITIONS').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Apache License'), findsWidgets);
    expect(find.textContaining('TERMS AND CONDITIONS'), findsWidgets);
    expect(find.text('课格（Crid）'), findsWidgets);
    expect(find.textContaining('段许可文本'), findsNothing);
    final detailList = find.byWidgetPredicate(
      (widget) =>
          widget is ListView &&
          widget.key.toString().contains('open-source-license-detail-Crid'),
    );
    final detailScrollable = find.descendant(
      of: detailList,
      matching: find.byType(Scrollable),
    );
    expect(detailList, findsOneWidget);
    expect(detailScrollable, findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Copyright 2026 Crid contributors'),
      1000,
      scrollable: detailScrollable,
    );

    expect(
      find.textContaining('Copyright 2026 Crid contributors'),
      findsOneWidget,
    );
  });

  testWidgets('holiday adjustment uses Material menu control', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Holiday mode'),
      500,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.byType(DropdownButtonFormField<HolidayAdjustmentMode>),
      findsNothing,
    );
    expect(find.byType(MenuAnchor), findsNothing);
    final adjustmentMenu = find.byType(PopupMenuButton<HolidayAdjustmentMode>);
    expect(adjustmentMenu, findsOneWidget);
    expect(
      tester
          .widget<PopupMenuButton<HolidayAdjustmentMode>>(adjustmentMenu)
          .popUpAnimationStyle,
      appMenuAnimationStyle,
    );
    final menuButton = tester.widget<PopupMenuButton<HolidayAdjustmentMode>>(
      adjustmentMenu,
    );
    expect(menuButton.shape, appMenuPanelShape);
    expect(menuButton.borderRadius, appMenuItemBorderRadius);
    expect(find.text('Do not adjust holidays'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Do not adjust holidays'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(adjustmentMenu);
    await tester.pumpAndSettle();
    await tester.tap(adjustmentMenu);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Follow adjusted class days').last);
    await tester.pumpAndSettle();

    expect(find.text('Follow adjusted class days'), findsOneWidget);
  });

  testWidgets('plan overflow menus use expressive popup styling', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));
    await tester.tap(find.text('Plans').last);
    await tester.pumpAndSettle();

    final planMenus = find.byWidgetPredicate((widget) {
      return widget is PopupMenuButton &&
          widget.shape == appMenuPanelShape &&
          widget.popUpAnimationStyle == appMenuAnimationStyle;
    });
    expect(planMenus, findsWidgets);

    await tester.tap(planMenus.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('editor field labels sit above input outlines', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    await tester.tap(find.text('Add course').last);
    await tester.pumpAndSettle();

    final labelBottom = tester.getBottomLeft(find.text('Course name')).dy;
    final fieldTop = tester.getTopLeft(find.byType(TextFormField).first).dy;

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Advanced Mathematics'), findsNothing);
    expect(labelBottom, lessThanOrEqualTo(fieldTop - 4));
  });

  testWidgets('reminder lead time exposes preset and custom controls', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile).first).value,
      isFalse,
    );
    expect(find.widgetWithText(FilterChip, '20 min'), findsOneWidget);
    expect(
      tester
          .widget<FilterChip>(find.widgetWithText(FilterChip, '20 min'))
          .selected,
      isTrue,
    );
    expect(find.widgetWithText(ActionChip, 'Custom time'), findsOneWidget);
  });

  testWidgets('resuming the app rebuilds the rolling reminder window', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final scheduler = _RecordingReminderScheduler();

    await pumpApp(
      tester,
      locale: const Locale('en'),
      reminderScheduler: scheduler,
    );
    await tester.pump(const Duration(milliseconds: 300));
    final initialScheduleCalls = scheduler.scheduleCalls;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    for (
      var i = 0;
      i < 10 && scheduler.scheduleCalls == initialScheduleCalls;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(scheduler.scheduleCalls, greaterThan(initialScheduleCalls));
    expect(
      scheduler.windowDays,
      everyElement(defaultReminderScheduleWindowDays),
    );
  });

  testWidgets('course block shows dense details without narrow overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CridApp)),
    );
    await container
        .read(timetableControllerProvider.notifier)
        .saveCourse(
          CourseSlotDraft(
            name: 'Accessible Systems Design Studio',
            teacher: 'Professor Rivera',
            location: 'Inclusive Lab 1208',
            weekday: DateTime.monday,
            timeRange: CourseTimeRange.fromPeriods(1, 1),
            startWeek: expectedInitialWeek,
            endWeek: expectedInitialWeek,
            parity: WeekParity.all,
            color: courseColorForIndex(0),
          ),
        );
    await tester.pumpAndSettle();

    expect(find.text('Accessible Systems Design Studio'), findsOneWidget);
    expect(find.textContaining('Inclusive Lab'), findsOneWidget);
    expect(find.text('Professor Rivera'), findsOneWidget);
    final courseMaterial = tester
        .widgetList<Material>(
          find.ancestor(
            of: find.text('Accessible Systems Design Studio'),
            matching: find.byType(Material),
          ),
        )
        .where(
          (widget) =>
              widget.borderRadius == BorderRadius.circular(8) &&
              widget.clipBehavior == Clip.antiAlias,
        )
        .single;
    expect(courseMaterial.borderRadius, BorderRadius.circular(8));
    expect(courseMaterial.clipBehavior, Clip.antiAlias);
    expect(tester.takeException(), isNull);
  });

  testWidgets('course details sheet stays above mobile bottom navigation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CridApp)),
    );
    await container
        .read(timetableControllerProvider.notifier)
        .saveCourse(
          CourseSlotDraft(
            name: 'Navigation Clearance Studio',
            teacher: 'Professor Hart',
            location: 'Room 404',
            weekday: DateTime.monday,
            timeRange: CourseTimeRange.fromPeriods(1, 1),
            startWeek: expectedInitialWeek,
            endWeek: expectedInitialWeek,
            parity: WeekParity.all,
            color: courseColorForIndex(0),
          ),
        );
    await tester.pumpAndSettle();

    final courseBlockElement = find
        .ancestor(
          of: find.text('Navigation Clearance Studio').first,
          matching: find.byType(Material),
        )
        .evaluate()
        .singleWhere((element) {
          final widget = element.widget;
          return widget is Material &&
              widget.borderRadius == BorderRadius.circular(8) &&
              widget.clipBehavior == Clip.antiAlias;
        });
    final courseBlockBox = courseBlockElement.renderObject! as RenderBox;
    final timetableLeft = tester.getTopLeft(find.byType(TimetableHomePage)).dx;
    await tester.tapAt(
      courseBlockBox.localToGlobal(courseBlockBox.size.center(Offset.zero)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 170));

    expect(
      tester.getTopLeft(find.byType(TimetableHomePage)).dx,
      closeTo(timetableLeft, 0.1),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Edit'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Professor Hart'), findsWidgets);

    final detailsSheet = find.byKey(const ValueKey('course-details-sheet'));
    expect(detailsSheet, findsOneWidget);
    final sheetMaterial = tester.widget<Material>(
      find.descendant(
        of: detailsSheet,
        matching: find.byWidgetPredicate(
          (widget) => widget is Material && widget.elevation == 6,
        ),
      ),
    );
    final theme = Theme.of(tester.element(find.byType(TimetableHomePage)));
    expect(sheetMaterial.color, theme.navigationBarTheme.backgroundColor);
    expect(sheetMaterial.shadowColor, isNot(Colors.transparent));
    final sheetBottom = tester.getBottomLeft(detailsSheet).dy;
    final navTop = tester.getTopLeft(find.byType(NavigationBar)).dy;
    expect(sheetBottom, closeTo(navTop, 0.1));

    await tester.tap(find.byTooltip('Close'));
    await tester.pump(appMicroMotionDuration ~/ 2);
    expect(detailsSheet, findsOneWidget);
    await tester.pumpAndSettle();
    expect(detailsSheet, findsNothing);
  });

  testWidgets('course details sheet leaves mobile bottom navigation usable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CridApp)),
    );
    await container
        .read(timetableControllerProvider.notifier)
        .saveCourse(
          CourseSlotDraft(
            name: 'Bottom Navigation Studio',
            teacher: 'Professor Vale',
            location: 'Room 512',
            weekday: DateTime.monday,
            timeRange: CourseTimeRange.fromPeriods(1, 1),
            startWeek: expectedInitialWeek,
            endWeek: expectedInitialWeek,
            parity: WeekParity.all,
            color: courseColorForIndex(0),
          ),
        );
    await tester.pumpAndSettle();

    final courseBlockElement = find
        .ancestor(
          of: find.text('Bottom Navigation Studio').first,
          matching: find.byType(Material),
        )
        .evaluate()
        .singleWhere((element) {
          final widget = element.widget;
          return widget is Material &&
              widget.borderRadius == BorderRadius.circular(8) &&
              widget.clipBehavior == Clip.antiAlias;
        });
    final courseBlockBox = courseBlockElement.renderObject! as RenderBox;
    await tester.tapAt(
      courseBlockBox.localToGlobal(courseBlockBox.size.center(Offset.zero)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('course-details-sheet')), findsOneWidget);

    await tester.tap(find.text('Plans').last);
    await tester.pumpAndSettle();

    expect(find.text('Timetable plans'), findsOneWidget);
  });

  testWidgets('today list shows only courses scheduled for today', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, locale: const Locale('en'));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CridApp)),
    );
    final today = DateTime.now();
    await container
        .read(timetableControllerProvider.notifier)
        .saveCourse(
          CourseSlotDraft(
            name: 'Today Systems Lab',
            teacher: 'Professor Chen',
            location: 'Studio 302',
            weekday: today.weekday,
            timeRange: CourseTimeRange.fromPeriods(3, 4),
            startWeek: expectedInitialWeek,
            endWeek: expectedInitialWeek,
            parity: WeekParity.all,
            color: courseColorForIndex(1),
          ),
        );
    await container
        .read(timetableControllerProvider.notifier)
        .saveCourse(
          CourseSlotDraft(
            name: 'Other Day Seminar',
            teacher: 'Professor Li',
            location: 'Room 210',
            weekday: today.weekday == DateTime.sunday
                ? DateTime.monday
                : today.weekday + 1,
            timeRange: CourseTimeRange.fromPeriods(3, 4),
            startWeek: expectedInitialWeek,
            endWeek: expectedInitialWeek,
            parity: WeekParity.all,
            color: courseColorForIndex(2),
          ),
        );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text("Today's courses"),
      600,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text("Today's courses"), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Today Systems Lab'),
        matching: find.byType(ListTile),
      ),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.text('Other Day Seminar'),
        matching: find.byType(ListTile),
      ),
      findsNothing,
    );
    expect(
      find.ancestor(
        of: find.textContaining('Studio 302'),
        matching: find.byType(ListTile),
      ),
      findsOneWidget,
    );
  });
}

ScrollableState _timetableScrollState(WidgetTester tester, int _) {
  final timeBody = find.byKey(const ValueKey('timetable-time-body'));
  final scrollable = find.descendant(
    of: timeBody,
    matching: find.byType(Scrollable),
  );
  return tester.state<ScrollableState>(scrollable.first);
}

void _expectBackTitleGap(WidgetTester tester, String title) {
  final appBar = find.byType(AppBar);
  final backButton = find.descendant(
    of: appBar,
    matching: find.byTooltip('Back'),
  );
  final titleText = find.descendant(of: appBar, matching: find.text(title));

  expect(backButton, findsOneWidget);
  expect(titleText, findsOneWidget);
  expect(
    tester.getTopLeft(titleText).dx - tester.getTopRight(backButton).dx,
    lessThanOrEqualTo(4),
  );
}

String _testDateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

class _FakeChinaHolidayService extends ChinaHolidayService {
  const _FakeChinaHolidayService([this.schedules = const {}]);

  final Map<int, ChinaHolidaySchedule> schedules;

  @override
  Future<ChinaHolidaySchedule> loadYear(int year) async {
    return schedules[year] ?? ChinaHolidaySchedule.empty(year);
  }
}

class _FakeAndroidBackgroundService extends AndroidBackgroundService {
  @override
  Future<AndroidBackgroundStatus> status() async {
    return const AndroidBackgroundStatus(
      available: true,
      manufacturer: 'OPPO',
      brand: 'OPPO',
      model: 'PKJ110',
      androidRelease: '16',
      sdkInt: 36,
      notificationsAllowed: true,
      exactAlarmsAllowed: true,
      batteryOptimizationIgnored: false,
      persistentBackgroundEnabled: true,
      persistentBackgroundRunning: true,
    );
  }
}

class _FakeReminderScheduler implements ReminderSchedulerService {
  const _FakeReminderScheduler();

  @override
  Future<ReminderPermissionStatus> requestPermissionsForScheduling() async {
    return const ReminderPermissionStatus(platformAvailable: true);
  }

  @override
  Future<bool> requestDoNotDisturbBypassIfSupported() async => true;

  @override
  Future<ReminderScheduleResult> scheduleRollingWindow({
    required Iterable<ClassSessionInfo> sessions,
    required DateTime firstWeekMonday,
    required DateTime now,
    int minutesBefore = 20,
    Iterable<int>? reminderOffsets,
    bool ignoreDoNotDisturb = false,
    bool vibrateOnly = false,
    int windowDays = defaultReminderScheduleWindowDays,
    String Function(int minutesBefore)? titleForMinutes,
  }) async {
    return const ReminderScheduleResult(
      scheduledCount: 0,
      platformAvailable: true,
    );
  }
}

class _RecordingReminderScheduler implements ReminderSchedulerService {
  int scheduleCalls = 0;
  final windowDays = <int>[];

  @override
  Future<ReminderPermissionStatus> requestPermissionsForScheduling() async {
    return const ReminderPermissionStatus(platformAvailable: true);
  }

  @override
  Future<bool> requestDoNotDisturbBypassIfSupported() async => true;

  @override
  Future<ReminderScheduleResult> scheduleRollingWindow({
    required Iterable<ClassSessionInfo> sessions,
    required DateTime firstWeekMonday,
    required DateTime now,
    int minutesBefore = 20,
    Iterable<int>? reminderOffsets,
    bool ignoreDoNotDisturb = false,
    bool vibrateOnly = false,
    int windowDays = defaultReminderScheduleWindowDays,
    String Function(int minutesBefore)? titleForMinutes,
  }) async {
    scheduleCalls += 1;
    this.windowDays.add(windowDays);
    return ReminderScheduleResult(
      scheduledCount: sessions.length,
      platformAvailable: true,
    );
  }
}

class _BlockingExportFileService extends ExportFileService {
  _BlockingExportFileService();

  final _saveCompleter = Completer<String?>();

  void completeSave(String? path) {
    _saveCompleter.complete(path);
  }

  @override
  Future<String?> saveFile({
    required String dialogTitle,
    required String fileName,
    required FileType type,
    required List<String> allowedExtensions,
    required Uint8List bytes,
  }) {
    return _saveCompleter.future;
  }

  @override
  Future<OpenResult> openFile(String path, {required String mimeType}) async {
    return OpenResult();
  }
}
