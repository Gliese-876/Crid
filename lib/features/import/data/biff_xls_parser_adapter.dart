import '../../../core/file/import_file_type_detector.dart';
import '../domain/parsed_timetable.dart';
import 'legacy_xls_workbook.dart';
import 'schedule_text_parser.dart';
import 'timetable_parser.dart';

class BiffXlsParserAdapter implements TimetableParserAdapter {
  const BiffXlsParserAdapter({
    LegacyXlsWorkbookDecoder workbookDecoder = const LegacyXlsWorkbookDecoder(),
    CourseTextParser textParser = const CourseTextParser(),
  }) : _workbookDecoder = workbookDecoder,
       _textParser = textParser;

  final LegacyXlsWorkbookDecoder _workbookDecoder;
  final CourseTextParser _textParser;

  @override
  Future<ParsedTimetable> parse({
    required String sourceName,
    required List<int> bytes,
    DateTime? semesterFirstWeekMonday,
  }) async {
    final warnings = <ParseWarning>[];
    late final LegacyXlsWorkbook workbook;
    try {
      workbook = _workbookDecoder.decode(bytes);
    } on Object catch (error) {
      return ParsedTimetable(
        sourceName: sourceName,
        fileType: ImportFileType.biffXls,
        courses: const [],
        warnings: [
          ParseWarning(
            message: 'Unable to read BIFF .xls workbook: $error',
            code: ParseWarningCode.workbookReadFailed,
            severity: ParseWarningSeverity.error,
          ),
        ],
      );
    }

    final courses = <ParsedCourse>[];
    for (final sheet in workbook.sheets) {
      courses.addAll(_parseSheet(sheet, warnings));
    }

    final unique = <String, ParsedCourse>{};
    for (final course in courses) {
      unique[course.sourceFingerprint] = course;
    }

    if (unique.isEmpty) {
      warnings.add(
        const ParseWarning(
          message:
              'BIFF .xls was detected, but no complete timetable rows were recognized.',
          code: ParseWarningCode.noCompleteXlsRows,
          severity: ParseWarningSeverity.warning,
        ),
      );
    } else {
      warnings.add(
        ParseWarning(
          message:
              'BIFF .xls parsed from workbook cells (${unique.length} sessions recognized).',
          code: ParseWarningCode.xlsParsedSessions,
          severity: ParseWarningSeverity.info,
          count: unique.length,
        ),
      );
    }

    return ParsedTimetable(
      sourceName: sourceName,
      fileType: ImportFileType.biffXls,
      courses: List.unmodifiable(unique.values),
      warnings: List.unmodifiable(warnings),
    );
  }

  List<ParsedCourse> _parseSheet(
    LegacyXlsSheet sheet,
    List<ParseWarning> warnings,
  ) {
    final headerRow = _findHeaderRow(sheet);
    if (headerRow == null) {
      return const [];
    }

    final nameColumn = headerRow.columnFor('课程名称');
    final teacherColumn = headerRow.columnFor('任课教师');
    final scheduleColumn = headerRow.columnFor('上课时间地点');
    if (nameColumn == null || scheduleColumn == null) {
      return const [];
    }

    final courses = <ParsedCourse>[];
    final rows = sheet.cells.keys.toList()..sort();
    for (final row in rows.where((row) => row > headerRow.index)) {
      final courseName = sheet.valueAt(row, nameColumn)?.trim();
      final scheduleText = sheet.valueAt(row, scheduleColumn)?.trim();
      if (courseName == null ||
          courseName.isEmpty ||
          scheduleText == null ||
          scheduleText.isEmpty) {
        continue;
      }
      final teacher = teacherColumn == null
          ? ''
          : sheet.valueAt(row, teacherColumn)?.trim() ?? '';
      courses.addAll(
        _textParser.parseScheduleEntries(
          courseName: courseName,
          teacher: teacher,
          scheduleText: scheduleText,
          fallbackWeekday: null,
          fallbackPeriod: null,
          fallbackLocation: null,
          warnings: warnings,
          rawText:
              '${sheet.name} row ${row + 1}: $courseName / $teacher / $scheduleText',
        ),
      );
    }
    return courses;
  }

  _HeaderRow? _findHeaderRow(LegacyXlsSheet sheet) {
    for (final entry in sheet.cells.entries) {
      final normalizedByColumn = <int, String>{};
      for (final cell in entry.value.entries) {
        normalizedByColumn[cell.key] = _normalizeHeader(cell.value);
      }
      if (normalizedByColumn.containsValue('课程名称') &&
          normalizedByColumn.containsValue('上课时间地点')) {
        return _HeaderRow(index: entry.key, valuesByColumn: normalizedByColumn);
      }
    }
    return null;
  }
}

class _HeaderRow {
  const _HeaderRow({required this.index, required this.valuesByColumn});

  final int index;
  final Map<int, String> valuesByColumn;

  int? columnFor(String name) {
    for (final entry in valuesByColumn.entries) {
      if (entry.value == name) {
        return entry.key;
      }
    }
    return null;
  }
}

String _normalizeHeader(String value) {
  return value.replaceAll(RegExp(r'\s+'), '').trim();
}
