import 'dart:typed_data';

import 'package:crid/core/time/period.dart';
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
import 'package:image/image.dart' as img;

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
    expect(ics, isNot(contains('Sections:')));
  });

  test('ICS export uses stored clock minutes before section fallback', () {
    const preciseSession = ClassSessionInfo(
      sessionId: 2,
      courseId: 20,
      courseName: 'Minute Accurate Seminar',
      teacher: 'Dr. Lin',
      location: 'Teaching Building A101',
      weekday: DateTime.monday,
      startSection: 3,
      endSection: 4,
      startMinuteOfDay: 10 * 60 + 20,
      endMinuteOfDay: 12 * 60 + 20,
      weekStart: 1,
      weekEnd: 1,
      weekParity: WeekParity.all,
    );

    final ics = const IcsExportService().exportCalendar(
      calendarName: 'Spring Term',
      firstWeekMonday: DateTime(2026, 2, 23),
      sessions: [preciseSession],
      generatedAt: DateTime.utc(2026, 1, 1),
    );

    expect(ics, contains('DTSTART;TZID=Asia/Shanghai:20260223T102000'));
    expect(ics, contains('DTEND;TZID=Asia/Shanghai:20260223T122000'));
    expect(ics, contains(r'Time: 10:20-12:20'));
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
        'class-session:1:1:20',
        'class-session:1:2:20',
      ]);
    },
  );

  test('reminder window emits one notification for every selected offset', () {
    final reminders = buildRollingReminderWindow(
      sessions: [session],
      firstWeekMonday: DateTime(2026, 2, 23),
      now: DateTime(2026, 2, 23, 7),
      reminderOffsets: const [30, 10],
      windowDays: 1,
    );

    expect(reminders.map((item) => item.remindAt), [
      DateTime(2026, 2, 23, 7, 30),
      DateTime(2026, 2, 23, 7, 50),
    ]);
    expect(reminders.map((item) => item.payload), [
      'class-session:1:1:30',
      'class-session:1:1:10',
    ]);
  });

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
      'class-session:2:1:10',
      'class-session:2:3:10',
    ]);
  });

  test('reminder window uses stored clock minutes before section fallback', () {
    const preciseSession = ClassSessionInfo(
      sessionId: 3,
      courseId: 30,
      courseName: 'Minute Accurate Seminar',
      weekday: DateTime.monday,
      startSection: 3,
      endSection: 4,
      startMinuteOfDay: 10 * 60 + 20,
      endMinuteOfDay: 12 * 60 + 20,
      weekStart: 1,
      weekEnd: 1,
      weekParity: WeekParity.all,
    );

    final reminders = buildRollingReminderWindow(
      sessions: [preciseSession],
      firstWeekMonday: DateTime(2026, 2, 23),
      now: DateTime(2026, 2, 23, 9, 50),
      minutesBefore: 20,
      windowDays: 1,
    );

    expect(reminders, hasLength(1));
    expect(reminders.single.startAt, DateTime(2026, 2, 23, 10, 20));
    expect(reminders.single.remindAt, DateTime(2026, 2, 23, 10));
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
    expect(androidDetails.playSound, isTrue);
    expect(androidDetails.enableVibration, isTrue);
    expect(androidDetails.usesChronometer, isFalse);
    expect(androidDetails.chronometerCountDown, isFalse);
    expect(
      androidDetails.timeoutAfter,
      const Duration(minutes: 20).inMilliseconds,
    );
  });

  test('Android muted reminder channel still vibrates without sound', () {
    final reminder = buildRollingReminderWindow(
      sessions: [session],
      firstWeekMonday: DateTime(2026, 2, 23),
      now: DateTime(2026, 2, 23, 7, 30),
      minutesBefore: 20,
    ).first;

    final androidDetails = reminderNotificationDetailsFor(
      reminder,
      vibrateOnly: true,
    ).android!;

    expect(androidDetails.channelId, 'class_reminders_vibrate');
    expect(androidDetails.channelName, 'Class reminders without sound');
    expect(androidDetails.playSound, isFalse);
    expect(androidDetails.enableVibration, isTrue);
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
      courses: [
        ui.CourseSlot(
          id: '1',
          name: 'Advanced Mathematics',
          teacher: 'Dr. Lin',
          location: 'Teaching Building A101',
          weekday: DateTime.monday,
          timeRange: CourseTimeRange.fromPeriods(1, 2),
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

  test('week image export crops to exact active course bounds', () {
    final range = debugWeekImageExportTimeRange([
      ui.CourseSlot(
        id: '1',
        name: 'Morning Lab',
        teacher: 'Dr. Lin',
        location: 'Lab 101',
        weekday: DateTime.tuesday,
        timeRange: CourseTimeRange.fromClockTimes(
          startMinuteOfDay: 8 * 60 + 10,
          endMinuteOfDay: 9 * 60 + 5,
        ),
        startWeek: 1,
        endWeek: 1,
        parity: ui.WeekParity.all,
        color: const Color(0xFF4D73FF),
      ),
      ui.CourseSlot(
        id: '2',
        name: 'Evening Exam',
        teacher: '',
        location: 'Hall B',
        weekday: DateTime.friday,
        timeRange: CourseTimeRange.fromClockTimes(
          startMinuteOfDay: 18 * 60 + 20,
          endMinuteOfDay: 20 * 60 + 10,
        ),
        startWeek: 1,
        endWeek: 1,
        parity: ui.WeekParity.all,
        color: const Color(0xFF7C5CFF),
      ),
    ]);

    expect(range.startMinute, 8 * 60 + 10);
    expect(range.endMinute, 20 * 60 + 10);
  });

  test('week image export empty week uses official teaching day bounds', () {
    final range = debugWeekImageExportTimeRange(const []);

    expect(range.startMinute, defaultLessonTimeSlots.first.startMinuteOfDay);
    expect(range.endMinute, defaultLessonTimeSlots.last.endMinuteOfDay);
    expect(range.startMinute, isNot(0));
    expect(range.endMinute, isNot(minutesPerDay));
  });

  test('image export renders wider high-resolution timetable images', () {
    expect(debugWeekImageExportPixelWidth(), 4800);
    expect(debugSemesterWeekImageExportPixelWidth(), 3000);
  });

  test('semester png stitcher preserves rows and side padding', () {
    final firstWeek = img.Image(width: 2, height: 2, numChannels: 4);
    final secondWeek = img.Image(width: 2, height: 1, numChannels: 4);
    img.fill(firstWeek, color: img.ColorRgba8(0xe0, 0x21, 0x21, 0xff));
    img.fill(secondWeek, color: img.ColorRgba8(0x21, 0x5f, 0xe0, 0xff));

    final encoded = debugEncodeStackedSemesterPngForTest(
      weekPngs: [
        Uint8List.fromList(img.encodePng(firstWeek)),
        Uint8List.fromList(img.encodePng(secondWeek)),
      ],
      gap: 1,
      sidePadding: 1,
      backgroundColor: const Color(0xff102030),
    );
    final decoded = img.decodePng(encoded)!;

    expect(decoded.width, 4);
    expect(decoded.height, 4);
    expect(_rgba(decoded.getPixel(0, 0)), 0xff102030);
    expect(_rgba(decoded.getPixel(1, 0)), 0xffe02121);
    expect(_rgba(decoded.getPixel(2, 0)), 0xffe02121);
    expect(_rgba(decoded.getPixel(3, 0)), 0xff102030);
    expect(_rgba(decoded.getPixel(1, 2)), 0xff102030);
    expect(_rgba(decoded.getPixel(1, 3)), 0xff215fe0);
  });
}

int _rgba(img.Pixel pixel) {
  return ((pixel.a.toInt() & 0xff) << 24) |
      ((pixel.r.toInt() & 0xff) << 16) |
      ((pixel.g.toInt() & 0xff) << 8) |
      (pixel.b.toInt() & 0xff);
}
