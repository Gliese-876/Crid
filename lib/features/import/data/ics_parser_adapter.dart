import 'dart:convert';

import 'package:icalendar_parser/icalendar_parser.dart';

import '../../../core/file/import_file_type_detector.dart';
import '../../../core/time/period.dart';
import '../../../core/time/week_pattern.dart';
import '../domain/parsed_timetable.dart';
import 'timetable_parser.dart';

class IcsParserAdapter implements TimetableParserAdapter {
  const IcsParserAdapter();

  @override
  Future<ParsedTimetable> parse({
    required String sourceName,
    required List<int> bytes,
    DateTime? semesterFirstWeekMonday,
  }) async {
    final warnings = <ParseWarning>[];
    final content = utf8.decode(bytes, allowMalformed: true);
    ICalendar calendar;
    try {
      calendar = ICalendar.fromString(content);
    } catch (error) {
      return ParsedTimetable(
        sourceName: sourceName,
        fileType: ImportFileType.ics,
        courses: const [],
        warnings: [
          ParseWarning(
            message: 'Unable to parse ICS: $error',
            code: ParseWarningCode.icsParseFailed,
            severity: ParseWarningSeverity.error,
          ),
        ],
      );
    }

    final courses = <ParsedCourse>[];
    for (final event in calendar.data.where(
      (item) => item['type'] == 'VEVENT',
    )) {
      final parsed = _parseEvent(
        event,
        warnings: warnings,
        semesterFirstWeekMonday: semesterFirstWeekMonday,
      );
      if (parsed != null) {
        courses.add(parsed);
      }
    }

    return ParsedTimetable(
      sourceName: sourceName,
      fileType: ImportFileType.ics,
      courses: List.unmodifiable(courses),
      warnings: List.unmodifiable(warnings),
    );
  }

  ParsedCourse? _parseEvent(
    Map<String, dynamic> event, {
    required List<ParseWarning> warnings,
    required DateTime? semesterFirstWeekMonday,
  }) {
    final summary = (event['summary'] as String?)?.trim();
    final start = _parseIcsDateTime(event['dtstart']);
    final end = _parseIcsDateTime(event['dtend']);
    if (summary == null || summary.isEmpty || start == null || end == null) {
      warnings.add(
        ParseWarning(
          message: 'Skipped VEVENT without SUMMARY, DTSTART, or DTEND.',
          code: ParseWarningCode.skippedIcsEvent,
          rawContext: event.toString(),
        ),
      );
      return null;
    }

    final description =
        (event['description'] as String?)?.replaceAll(r'\n', '\n') ?? '';
    final locationAndTeacher = _splitLocationTeacher(
      (event['location'] as String?) ?? '',
      description,
    );

    final timeRange = CourseTimeRange.fromClockTimes(
      startMinuteOfDay: start.hour * 60 + start.minute,
      endMinuteOfDay: end.hour * 60 + end.minute,
    );
    final weeks = _weeksFromEvent(
      event,
      start,
      semesterFirstWeekMonday: semesterFirstWeekMonday,
      warnings: warnings,
    );

    return ParsedCourse(
      name: summary,
      teacher: locationAndTeacher.teacher,
      location: locationAndTeacher.location,
      weekday: start.weekday,
      period: timeRange.period,
      timeRange: timeRange,
      weeks: weeks,
      sourceId: event['uid'] as String?,
      rawText: event.toString(),
    );
  }

  WeekPattern _weeksFromEvent(
    Map<String, dynamic> event,
    DateTime start, {
    required DateTime? semesterFirstWeekMonday,
    required List<ParseWarning> warnings,
  }) {
    final rruleText = event['rrule'] as String?;
    if (rruleText == null || rruleText.isEmpty) {
      final week = _weekOf(start, semesterFirstWeekMonday ?? _mondayOf(start));
      return WeekPattern.single(week);
    }

    try {
      final firstWeekMonday = semesterFirstWeekMonday ?? _mondayOf(start);
      final instances = _expandWeeklyRrule(rruleText, start)
          .map((date) => _weekOf(date, firstWeekMonday))
          .where((week) => week > 0)
          .toSet();
      if (instances.isEmpty) {
        instances.add(_weekOf(start, firstWeekMonday));
      }
      return WeekPattern(instances, parity: _inferParity(instances));
    } catch (error) {
      warnings.add(
        ParseWarning(
          message: 'Unable to expand RRULE; kept DTSTART as a single week.',
          code: ParseWarningCode.icsRuleFallback,
          rawContext: '$rruleText ($error)',
        ),
      );
      return WeekPattern.single(
        _weekOf(start, semesterFirstWeekMonday ?? _mondayOf(start)),
      );
    }
  }

  Iterable<DateTime> _expandWeeklyRrule(
    String rruleText,
    DateTime start,
  ) sync* {
    final normalized = rruleText.startsWith('RRULE:')
        ? rruleText.substring('RRULE:'.length)
        : rruleText;
    final parts = <String, String>{};
    for (final part in normalized.split(';')) {
      final equals = part.indexOf('=');
      if (equals <= 0) {
        continue;
      }
      parts[part.substring(0, equals).toUpperCase()] = part
          .substring(equals + 1)
          .trim();
    }

    if ((parts['FREQ'] ?? '').toUpperCase() != 'WEEKLY') {
      yield start;
      return;
    }

    final interval = int.tryParse(parts['INTERVAL'] ?? '')?.clamp(1, 52) ?? 1;
    final count = int.tryParse(parts['COUNT'] ?? '');
    final until = _parseRruleUntil(parts['UNTIL']);
    final maxInstances = count ?? 80;
    var cursor = start;
    var emitted = 0;
    while (emitted < maxInstances && emitted < 80) {
      if (until != null && cursor.isAfter(until)) {
        break;
      }
      yield cursor;
      emitted += 1;
      cursor = cursor.add(Duration(days: 7 * interval));
    }
  }

  DateTime? _parseRruleUntil(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parsed = _parseCompactDateTime(value);
    if (parsed == null) {
      return null;
    }
    return parsed;
  }

  DateTime? _parseIcsDateTime(Object? value) {
    if (value is IcsDateTime) {
      return _parseCompactDateTime(value.dt);
    }
    if (value is String) {
      return _parseCompactDateTime(value);
    }
    return null;
  }

  DateTime? _parseCompactDateTime(String value) {
    final isUtc = value.endsWith('Z');
    final normalized = value.endsWith('Z')
        ? value.substring(0, value.length - 1)
        : value;
    final match = RegExp(
      r'^(\d{4})(\d{2})(\d{2})(?:T(\d{2})(\d{2})(\d{2})?)?$',
    ).firstMatch(normalized);
    if (match == null) {
      return DateTime.tryParse(value);
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final hour = int.parse(match.group(4) ?? '0');
    final minute = int.parse(match.group(5) ?? '0');
    final second = int.parse(match.group(6) ?? '0');
    if (isUtc) {
      return DateTime.utc(
        year,
        month,
        day,
        hour,
        minute,
        second,
      ).add(const Duration(hours: 8));
    }
    return DateTime(year, month, day, hour, minute, second);
  }

  ({String location, String teacher}) _splitLocationTeacher(
    String location,
    String description,
  ) {
    final descriptionLines = description
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final teacherFromDescription = descriptionLines.length >= 3
        ? descriptionLines.last
        : null;
    final cleaned = location.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (teacherFromDescription != null &&
        !cleaned.endsWith(teacherFromDescription)) {
      return (location: cleaned, teacher: teacherFromDescription);
    }

    final parts = cleaned.split(' ');
    if (parts.length >= 2) {
      final teacher = parts.last;
      final room = parts.take(parts.length - 1).join(' ');
      if (_looksLikeTeacher(teacher) && _looksLikeLocation(room)) {
        return (location: room, teacher: teacher);
      }
    }
    return (location: cleaned, teacher: teacherFromDescription ?? '');
  }

  bool _looksLikeTeacher(String value) {
    return RegExp(r'^[\u4e00-\u9fa5]{2,5}$').hasMatch(value) ||
        value.length <= 24 && !RegExp(r'\d').hasMatch(value);
  }

  bool _looksLikeLocation(String value) {
    return RegExp(
      r'(楼|室|教|校区|room|[a-zA-Z]\d{2,})',
      caseSensitive: false,
    ).hasMatch(value);
  }

  DateTime _mondayOf(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday - DateTime.monday));
  }

  int _weekOf(DateTime date, DateTime firstWeekMonday) {
    final day = DateTime(date.year, date.month, date.day);
    final monday = DateTime(
      firstWeekMonday.year,
      firstWeekMonday.month,
      firstWeekMonday.day,
    );
    return day.difference(monday).inDays ~/ 7 + 1;
  }

  WeekParity _inferParity(Set<int> weeks) {
    if (weeks.length < 2) {
      return WeekParity.all;
    }
    if (weeks.every((week) => week.isOdd)) {
      return WeekParity.odd;
    }
    if (weeks.every((week) => week.isEven)) {
      return WeekParity.even;
    }
    return WeekParity.all;
  }
}
