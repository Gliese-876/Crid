import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

import '../../../core/time/period.dart' as core_time;
import '../../../data/database/timetable_time.dart';

class IcsExportService {
  const IcsExportService();

  String exportCalendar({
    required String calendarName,
    required DateTime firstWeekMonday,
    required Iterable<ClassSessionInfo> sessions,
    DateTime? generatedAt,
    Iterable<LessonSlot> lessonSlots = defaultBnuzLessonSlots,
  }) {
    final nowUtc = (generatedAt ?? DateTime.now()).toUtc();
    final lines = <String>[
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Crid//Crid Flutter//EN',
      'CALSCALE:GREGORIAN',
      'METHOD:PUBLISH',
      'X-WR-CALNAME:${_escape(calendarName)}',
      'X-WR-TIMEZONE:Asia/Shanghai',
      'BEGIN:VTIMEZONE',
      'TZID:Asia/Shanghai',
      'BEGIN:STANDARD',
      'DTSTART:19700101T000000',
      'TZOFFSETFROM:+0800',
      'TZOFFSETTO:+0800',
      'TZNAME:CST',
      'END:STANDARD',
      'END:VTIMEZONE',
    ];

    for (final session in sessions) {
      final recurrence = _recurrenceFor(session);
      if (recurrence == null) {
        continue;
      }

      final timeRange = _timeRangeForSession(session, lessonSlots: lessonSlots);
      final start = _dateTimeForWeek(
        firstWeekMonday: firstWeekMonday,
        week: recurrence.firstWeek,
        weekday: session.weekday,
        minuteOfDay: timeRange.startMinuteOfDay,
      );
      final end = _dateTimeForWeek(
        firstWeekMonday: firstWeekMonday,
        week: recurrence.firstWeek,
        weekday: session.weekday,
        minuteOfDay: timeRange.endMinuteOfDay,
      );

      lines
        ..add('BEGIN:VEVENT')
        ..add('UID:${_uidFor(session, start)}')
        ..add('DTSTAMP:${_formatUtc(nowUtc)}')
        ..add('DTSTART;TZID=Asia/Shanghai:${_formatLocal(start)}')
        ..add('DTEND;TZID=Asia/Shanghai:${_formatLocal(end)}')
        ..add(
          'RRULE:FREQ=WEEKLY;INTERVAL=${recurrence.interval};COUNT=${recurrence.count}',
        )
        ..add('SUMMARY:${_escape(session.courseName)}')
        ..add('LOCATION:${_escape(session.location ?? '')}')
        ..add('DESCRIPTION:${_escape(_descriptionFor(session, timeRange))}')
        ..add('END:VEVENT');
    }

    lines.add('END:VCALENDAR');
    return '${lines.map(_foldLine).join('\r\n')}\r\n';
  }
}

class _Recurrence {
  const _Recurrence({
    required this.firstWeek,
    required this.interval,
    required this.count,
  });

  final int firstWeek;
  final int interval;
  final int count;
}

_Recurrence? _recurrenceFor(ClassSessionInfo session) {
  var firstWeek = session.weekStart;
  while (firstWeek <= session.weekEnd &&
      !session.weekParity.includes(firstWeek)) {
    firstWeek++;
  }
  if (firstWeek > session.weekEnd) {
    return null;
  }

  final interval = session.weekParity == WeekParity.all ? 1 : 2;
  var count = 0;
  for (var week = firstWeek; week <= session.weekEnd; week += interval) {
    if (session.weekParity.includes(week)) {
      count++;
    }
  }
  return _Recurrence(firstWeek: firstWeek, interval: interval, count: count);
}

DateTime _dateTimeForWeek({
  required DateTime firstWeekMonday,
  required int week,
  required int weekday,
  required int minuteOfDay,
}) {
  final date = DateTime(
    firstWeekMonday.year,
    firstWeekMonday.month,
    firstWeekMonday.day + ((week - 1) * 7) + (weekday - 1),
  );
  return DateTime(
    date.year,
    date.month,
    date.day,
    minuteOfDay ~/ 60,
    minuteOfDay % 60,
  );
}

core_time.CourseTimeRange _timeRangeForSession(
  ClassSessionInfo session, {
  required Iterable<LessonSlot> lessonSlots,
}) {
  return session.startMinuteOfDay != null && session.endMinuteOfDay != null
      ? core_time.CourseTimeRange.fromClockTimes(
          startMinuteOfDay: session.startMinuteOfDay!,
          endMinuteOfDay: session.endMinuteOfDay!,
          lessonSlots: lessonSlots,
        )
      : core_time.CourseTimeRange.fromPeriods(
          session.startSection,
          session.endSection,
          lessonSlots: lessonSlots,
        );
}

String _descriptionFor(
  ClassSessionInfo session,
  core_time.CourseTimeRange timeRange,
) {
  final parts = <String>[
    if (session.teacher?.isNotEmpty ?? false) 'Teacher: ${session.teacher}',
    'Time: ${_minuteLabel(timeRange.startMinuteOfDay)}-${_minuteLabel(timeRange.endMinuteOfDay)}',
    'Weeks: ${session.weekStart}-${session.weekEnd}${_parityLabel(session.weekParity)}',
    if (session.note?.isNotEmpty ?? false) 'Note: ${session.note}',
  ];
  return parts.join('\\n');
}

String _minuteLabel(int minuteOfDay) {
  final hour = minuteOfDay ~/ 60;
  final minute = minuteOfDay % 60;
  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}

String _parityLabel(WeekParity parity) {
  return switch (parity) {
    WeekParity.all => '',
    WeekParity.odd => ' odd weeks',
    WeekParity.even => ' even weeks',
  };
}

String _uidFor(ClassSessionInfo session, DateTime start) {
  final input = [
    session.sessionId,
    session.courseId,
    session.courseName,
    session.teacher,
    session.location,
    start.toIso8601String(),
  ].join('|');
  return '${sha1.convert(input.codeUnits)}@crid.local';
}

String _formatLocal(DateTime value) {
  return DateFormat("yyyyMMdd'T'HHmmss").format(value);
}

String _formatUtc(DateTime value) {
  return "${DateFormat("yyyyMMdd'T'HHmmss").format(value)}Z";
}

String _escape(String value) {
  return value
      .replaceAll('\\', r'\\')
      .replaceAll('\n', r'\n')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,');
}

String _foldLine(String line) {
  if (utf8.encode(line).length <= 75) {
    return line;
  }

  final buffer = StringBuffer();
  var first = true;
  var current = StringBuffer();
  var currentBytes = 0;

  for (final rune in line.runes) {
    final char = String.fromCharCode(rune);
    final charBytes = utf8.encode(char).length;
    final limit = first ? 75 : 74;
    if (currentBytes + charBytes > limit) {
      buffer
        ..write(current)
        ..write('\r\n ');
      current = StringBuffer();
      currentBytes = 0;
      first = false;
    }
    current.write(char);
    currentBytes += charBytes;
  }
  buffer.write(current);
  return buffer.toString();
}
