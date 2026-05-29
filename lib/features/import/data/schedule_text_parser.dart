import '../../../core/time/period.dart';
import '../../../core/time/week_pattern.dart';
import '../domain/parsed_timetable.dart';

class CourseTextParser {
  const CourseTextParser();

  List<ParsedCourse> parseCourseLines({
    required List<String> lines,
    required int? fallbackWeekday,
    required PeriodRange? fallbackPeriod,
    required List<ParseWarning> warnings,
    String? rawText,
  }) {
    final cleaned = lines
        .map(_clean)
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    if (cleaned.isEmpty) {
      return const [];
    }

    final scheduleIndex = cleaned.indexWhere(_looksLikeScheduleText);
    if (scheduleIndex < 0) {
      return const [];
    }

    final name = _guessName(cleaned, scheduleIndex);
    if (name == null) {
      warnings.add(
        ParseWarning(
          message: 'Course fragment has schedule text but no course name.',
          code: ParseWarningCode.fragmentMissingName,
          rawContext: rawText ?? cleaned.join('\n'),
        ),
      );
      return const [];
    }

    final teacher = _guessTeacher(cleaned, name, scheduleIndex) ?? '';
    final location = _guessLocation(cleaned, scheduleIndex);
    return parseScheduleEntries(
      courseName: name,
      teacher: teacher,
      scheduleText: cleaned.sublist(scheduleIndex).join(','),
      fallbackWeekday: fallbackWeekday,
      fallbackPeriod: fallbackPeriod,
      fallbackLocation: location,
      warnings: warnings,
      rawText: rawText ?? cleaned.join('\n'),
    );
  }

  List<ParsedCourse> parseScheduleEntries({
    required String courseName,
    required String teacher,
    required String scheduleText,
    required int? fallbackWeekday,
    required PeriodRange? fallbackPeriod,
    required String? fallbackLocation,
    required List<ParseWarning> warnings,
    String? rawText,
  }) {
    final normalized = _clean(scheduleText);
    if (normalized.isEmpty) {
      return const [];
    }

    final courses = <ParsedCourse>[];
    for (final match in _scheduleEntryPattern.allMatches(normalized)) {
      final weekday =
          _weekdayFromText(match.namedGroup('weekday') ?? '') ??
          fallbackWeekday;
      if (weekday == null) {
        warnings.add(
          ParseWarning(
            message: 'Schedule entry has no recognizable weekday.',
            code: ParseWarningCode.missingWeekday,
            rawContext: match.group(0),
          ),
        );
        continue;
      }

      final period = _periodFromMatch(match) ?? fallbackPeriod;
      if (period == null) {
        warnings.add(
          ParseWarning(
            message: 'Schedule entry has no recognizable class period.',
            code: ParseWarningCode.missingPeriod,
            rawContext: match.group(0),
          ),
        );
        continue;
      }

      final weekText = match.namedGroup('weeks') ?? '';
      final weeks = WeekPattern.parse(weekText);
      if (weeks.weeks.isEmpty) {
        warnings.add(
          ParseWarning(
            message: 'Schedule entry has no recognizable week range.',
            code: ParseWarningCode.missingWeeks,
            rawContext: match.group(0),
          ),
        );
        continue;
      }

      final location = _clean(
        match.namedGroup('location') ?? fallbackLocation ?? '',
      );
      courses.add(
        ParsedCourse(
          name: courseName.trim(),
          teacher: teacher.trim(),
          location: location,
          weekday: weekday,
          period: period,
          weeks: weeks,
          rawText: rawText ?? normalized,
        ),
      );
    }

    if (courses.isEmpty && _looksLikeScheduleText(normalized)) {
      warnings.add(
        ParseWarning(
          message: 'No complete schedule entries were recognized.',
          code: ParseWarningCode.noCompleteEntries,
          rawContext: rawText ?? normalized,
        ),
      );
    }
    return courses;
  }
}

final _scheduleEntryPattern = RegExp(
  r'(?<weeks>\d{1,2}\s*(?:[-~至到]\s*\d{1,2})?\s*(?:周)?\s*(?:[（(]?\s*[单双]\s*(?:周)?\s*[）)]?)?)'
  r'\s*(?<weekday>[一二三四五六日天]?)\s*'
  r'\[\s*(?<start>\d{1,2})\s*(?:[-~至到]\s*(?<end>\d{1,2}))?\s*\]'
  r'\s*(?<location>[^,，;；\n]*)',
);

bool _looksLikeScheduleText(String value) {
  return RegExp(r'\d{1,2}').hasMatch(value) &&
      (value.contains('[') || value.contains('节') || value.contains('周'));
}

String? _guessName(List<String> lines, int scheduleIndex) {
  for (final line in lines.take(scheduleIndex)) {
    if (_looksLikeLabel(line) ||
        _looksLikeLocation(line) ||
        _looksLikeScheduleText(line)) {
      continue;
    }
    return _stripLabel(line, const ['课程', '名称', '课程名称']);
  }
  return null;
}

String? _guessTeacher(
  List<String> lines,
  String courseName,
  int scheduleIndex,
) {
  for (final line in lines.take(scheduleIndex)) {
    if (line == courseName ||
        _looksLikeLocation(line) ||
        _looksLikeScheduleText(line)) {
      continue;
    }
    final labeled = _valueAfterLabel(line, const ['教师', '老师', '任课教师']);
    if (labeled != null) {
      return labeled;
    }
    if (!_looksLikeLabel(line)) {
      return line;
    }
  }
  return null;
}

String? _guessLocation(List<String> lines, int scheduleIndex) {
  for (final line in lines.skip(scheduleIndex + 1)) {
    final labeled = _valueAfterLabel(line, const ['地点', '教室', '上课地点']);
    if (labeled != null) {
      return labeled;
    }
    if (_looksLikeLocation(line)) {
      return line;
    }
  }
  return null;
}

PeriodRange? _periodFromMatch(RegExpMatch match) {
  final start = int.tryParse(match.namedGroup('start') ?? '');
  if (start == null) {
    return null;
  }
  final end = int.tryParse(match.namedGroup('end') ?? '') ?? start;
  return PeriodRange(start, end);
}

int? _weekdayFromText(String value) {
  final normalized = value.replaceAll(RegExp(r'\s+'), '');
  if (normalized.contains('一')) return DateTime.monday;
  if (normalized.contains('二')) return DateTime.tuesday;
  if (normalized.contains('三')) return DateTime.wednesday;
  if (normalized.contains('四')) return DateTime.thursday;
  if (normalized.contains('五')) return DateTime.friday;
  if (normalized.contains('六')) return DateTime.saturday;
  if (normalized.contains('日') || normalized.contains('天')) {
    return DateTime.sunday;
  }
  return null;
}

String? _valueAfterLabel(String text, List<String> labels) {
  for (final label in labels) {
    final match = RegExp('$label[:：\\s]*([^\\n;；]+)').firstMatch(text);
    final value = match?.group(1)?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }
  return null;
}

String _stripLabel(String text, List<String> labels) {
  var result = text.trim();
  for (final label in labels) {
    result = result.replaceFirst(RegExp('^$label[:：\\s]*'), '');
  }
  return result.trim();
}

bool _looksLikeLabel(String value) {
  return RegExp(r'^(课程|名称|课程名称|教师|老师|任课教师|地点|教室|上课地点)[:：]').hasMatch(value);
}

bool _looksLikeLocation(String text) {
  return RegExp(
    r'(楼|馆|校内|教室|room|[A-Za-z]\d{2,})',
    caseSensitive: false,
  ).hasMatch(text);
}

String _clean(String input) {
  return input
      .replaceAll('\u00a0', ' ')
      .replaceAll('\u3000', ' ')
      .replaceAll(RegExp(r'[ \t\r]+'), ' ')
      .trim();
}
