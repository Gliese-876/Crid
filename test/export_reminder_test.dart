import 'package:crid/features/settings/presentation/export_page.dart';
import 'package:crid/features/timetable/data/timetable_repository.dart';
import 'package:crid/features/timetable/presentation/course_slot_model.dart'
    as ui;
import 'package:crid/data/database/timetable_time.dart';
import 'package:crid/features/export/data/ics_export_service.dart';
import 'package:crid/features/reminder/data/local_notification_reminder_scheduler.dart';
import 'package:crid/features/reminder/domain/reminder_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icalendar_parser/icalendar_parser.dart';

void main() {
  const session = ClassSessionInfo(
    sessionId: 1,
    courseId: 10,
    courseName: 'Advanced Mathematics',
    teacher: 'Dr. Lin',
    location: 'Teaching Building A101',
    weekday: DateTime.monday,
    startSection: 1,
    endSection: 2,
    weekStart: 1,
    weekEnd: 4,
    weekParity: WeekParity.all,
  );

  test('ICS export emits parseable Asia/Shanghai recurring events', () {
    final ics = const IcsExportService().exportCalendar(
      calendarName: 'Spring Term',
      firstWeekMonday: DateTime(2026, 2, 23),
      sessions: [session],
      generatedAt: DateTime.utc(2026, 1, 1),
    );

    final calendar = ICalendar.fromString(ics);
    final events = calendar.data
        .where((entry) => entry['type'] == 'VEVENT')
        .toList();

    expect(calendar.version, '2.0');
    expect(events, hasLength(1));
    expect(events.single['summary'], 'Advanced Mathematics');
    expect(events.single['location'], 'Teaching Building A101');
    expect(events.single['rrule'], 'FREQ=WEEKLY;INTERVAL=1;COUNT=4');
    expect(ics, contains('X-WR-TIMEZONE:Asia/Shanghai'));
    expect(ics, contains('DTSTART;TZID=Asia/Shanghai:20260223T080000'));
    expect(ics, contains('DTEND;TZID=Asia/Shanghai:20260223T094000'));
  });

  test(
    'reminder window keeps only future reminders inside rolling two weeks',
    () {
      final reminders = buildRollingReminderWindow(
        sessions: [session],
        firstWeekMonday: DateTime(2026, 2, 23),
        now: DateTime(2026, 2, 23, 7, 30),
        minutesBefore: 20,
        windowDays: 14,
      );

      expect(reminders, hasLength(2));
      expect(reminders.first.remindAt, DateTime(2026, 2, 23, 7, 40));
      expect(reminders.first.startAt, DateTime(2026, 2, 23, 8));
      expect(reminders.first.title, '20 分钟后上课');
      expect(
        reminders.first.body,
        'Advanced Mathematics - 08:00 - Teaching Building A101 - Dr. Lin',
      );
      expect(reminders.last.remindAt, DateTime(2026, 3, 2, 7, 40));
      expect(reminders.map((item) => item.payload), [
        'class-session:1:1',
        'class-session:1:2',
      ]);
    },
  );

  test('reminder window respects odd and even week filters', () {
    const oddSession = ClassSessionInfo(
      sessionId: 2,
      courseId: 20,
      courseName: 'College English',
      weekday: DateTime.wednesday,
      startSection: 3,
      endSection: 4,
      weekStart: 1,
      weekEnd: 6,
      weekParity: WeekParity.odd,
    );

    final reminders = buildRollingReminderWindow(
      sessions: [oddSession],
      firstWeekMonday: DateTime(2026, 2, 23),
      now: DateTime(2026, 2, 23),
      minutesBefore: 10,
      windowDays: 21,
    );

    expect(reminders.map((item) => item.payload), [
      'class-session:2:1',
      'class-session:2:3',
    ]);
  });

  test('reminder notification title follows the app locale', () {
    final reminders = buildRollingReminderWindow(
      sessions: [session],
      firstWeekMonday: DateTime(2026, 2, 23),
      now: DateTime(2026, 2, 23, 7, 30),
      minutesBefore: 20,
      titleForMinutes: (minutes) => 'Class starts in $minutes min',
    );

    expect(reminders.first.title, 'Class starts in 20 min');
  });

  test('Android reminder notification stays until class starts', () {
    final reminder = buildRollingReminderWindow(
      sessions: [session],
      firstWeekMonday: DateTime(2026, 2, 23),
      now: DateTime(2026, 2, 23, 7, 30),
      minutesBefore: 20,
    ).first;

    final androidDetails = reminderNotificationDetailsFor(reminder).android!;

    expect(androidDetails.ongoing, isTrue);
    expect(androidDetails.autoCancel, isFalse);
    expect(androidDetails.usesChronometer, isTrue);
    expect(androidDetails.chronometerCountDown, isTrue);
    expect(
      androidDetails.timeoutAfter,
      const Duration(minutes: 20).inMilliseconds,
    );
  });

  test('semester image export stops at the last active course week', () {
    final semester = SemesterSummary(
      id: 1,
      name: 'Spring Term',
      nameManuallyEdited: false,
      firstWeekMonday: DateTime(2026, 2, 23),
      endDate: DateTime(2026, 4, 5),
    );
    const plan = PlanSummary(
      id: 1,
      semesterId: 1,
      name: 'Default',
      isActive: true,
    );
    final snapshot = TimetableSnapshot(
      semesters: [semester],
      plans: const [plan],
      activePlan: plan,
      activeSemester: semester,
      courses: const [
        ui.CourseSlot(
          id: '1',
          name: 'Advanced Mathematics',
          teacher: 'Dr. Lin',
          location: 'Teaching Building A101',
          weekday: DateTime.monday,
          startPeriod: 1,
          endPeriod: 2,
          startWeek: 1,
          endWeek: 4,
          parity: ui.WeekParity.all,
          color: Color(0xFF4D73FF),
        ),
      ],
      hiddenCourses: const [],
    );

    expect(debugSemesterExportWeeks(snapshot), [1, 2, 3, 4]);
  });
}
