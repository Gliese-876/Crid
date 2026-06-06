import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../core/file/import_file_type_detector.dart';
import '../../../core/time/period.dart';
import '../../../core/time/week_pattern.dart';

enum ParseWarningSeverity { info, warning, error }

enum ParseWarningCode {
  generic,
  unsupportedFileType,
  workbookReadFailed,
  noCompleteXlsRows,
  xlsParsedSessions,
  noCoursesFromHtml,
  decodedWithFallback,
  fragmentMissingName,
  missingWeekday,
  missingPeriod,
  missingWeeks,
  noCompleteEntries,
  icsParseFailed,
  skippedIcsEvent,
  icsRuleFallback,
}

class ParseWarning {
  const ParseWarning({
    required this.message,
    this.code = ParseWarningCode.generic,
    this.severity = ParseWarningSeverity.warning,
    this.rawContext,
    this.count,
  });

  final String message;
  final ParseWarningCode code;
  final ParseWarningSeverity severity;
  final String? rawContext;
  final int? count;
}

class ParsedTimetable {
  const ParsedTimetable({
    required this.sourceName,
    required this.fileType,
    required this.courses,
    this.warnings = const [],
  });

  final String sourceName;
  final ImportFileType fileType;
  final List<ParsedCourse> courses;
  final List<ParseWarning> warnings;
}

class ParsedCourse {
  ParsedCourse({
    required this.name,
    required this.weekday,
    required PeriodRange period,
    required this.weeks,
    CourseTimeRange? timeRange,
    this.teacher = '',
    this.location = '',
    this.sourceId,
    this.rawText,
    String? sourceFingerprint,
  }) : timeRange =
           timeRange ?? CourseTimeRange.fromPeriods(period.start, period.end),
       period =
           (timeRange ?? CourseTimeRange.fromPeriods(period.start, period.end))
               .period,
       sourceFingerprint =
           sourceFingerprint ??
           _fingerprint(
             name: name,
             teacher: teacher,
             weekday: weekday,
             timeRange:
                 timeRange ??
                 CourseTimeRange.fromPeriods(period.start, period.end),
             weeks: weeks,
             location: location,
           );

  final String name;
  final String teacher;
  final String location;
  final int weekday;
  final PeriodRange period;
  final CourseTimeRange timeRange;
  final WeekPattern weeks;
  final String? sourceId;
  final String? rawText;
  final String sourceFingerprint;

  ParsedCourse copyWith({
    String? name,
    String? teacher,
    String? location,
    int? weekday,
    PeriodRange? period,
    CourseTimeRange? timeRange,
    WeekPattern? weeks,
    String? sourceId,
    String? rawText,
    String? sourceFingerprint,
  }) {
    return ParsedCourse(
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      weekday: weekday ?? this.weekday,
      period: period ?? this.period,
      timeRange: timeRange ?? this.timeRange,
      weeks: weeks ?? this.weeks,
      sourceId: sourceId ?? this.sourceId,
      rawText: rawText ?? this.rawText,
      sourceFingerprint: sourceFingerprint,
    );
  }

  String get identityKey => normalizeCourseText(name);

  String get scheduleKey =>
      [weekday, timeRangeKey, weeks.normalizedKey].join('|');

  bool overlapsInTime(ParsedCourse other) {
    return weekday == other.weekday &&
        timeRange.overlaps(other.timeRange) &&
        weeks.overlaps(other.weeks);
  }

  String get timeRangeKey =>
      '${timeRange.startMinuteOfDay}-${timeRange.endMinuteOfDay}';

  static String _fingerprint({
    required String name,
    required String teacher,
    required int weekday,
    required CourseTimeRange timeRange,
    required WeekPattern weeks,
    required String location,
  }) {
    final key = [
      normalizeCourseText(name),
      normalizeCourseText(teacher),
      weekday,
      '${timeRange.startMinuteOfDay}-${timeRange.endMinuteOfDay}',
      weeks.normalizedKey,
      normalizeCourseText(location),
    ].join('|');
    return sha1.convert(utf8.encode(key)).toString();
  }
}

String normalizeCourseText(String input) {
  return input
      .replaceAll('\u3000', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();
}
