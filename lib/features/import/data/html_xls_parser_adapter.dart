import 'dart:convert';

import 'package:charset/charset.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../../../core/file/import_file_type_detector.dart';
import '../../../core/time/period.dart';
import '../domain/parsed_timetable.dart';
import 'schedule_text_parser.dart';
import 'timetable_parser.dart';

class HtmlXlsParserAdapter implements TimetableParserAdapter {
  const HtmlXlsParserAdapter({
    CourseTextParser textParser = const CourseTextParser(),
  }) : _textParser = textParser;

  final CourseTextParser _textParser;

  @override
  Future<ParsedTimetable> parse({
    required String sourceName,
    required List<int> bytes,
    DateTime? semesterFirstWeekMonday,
  }) async {
    final warnings = <ParseWarning>[];
    final decoded = _decodeHtml(bytes, warnings);
    final document = html_parser.parse(decoded);
    final courses = <ParsedCourse>[];

    for (final table in document.querySelectorAll('table')) {
      final gridCourses = _parseGridTable(table, warnings);
      courses.addAll(gridCourses);
      if (gridCourses.isEmpty) {
        courses.addAll(_parseLooseRows(table, warnings));
      }
    }

    final unique = <String, ParsedCourse>{};
    for (final course in courses) {
      unique[course.sourceFingerprint] = course;
    }

    if (unique.isEmpty) {
      warnings.add(
        const ParseWarning(
          message: 'No timetable courses were recognized from the HTML table.',
          code: ParseWarningCode.noCoursesFromHtml,
          severity: ParseWarningSeverity.warning,
        ),
      );
    }

    return ParsedTimetable(
      sourceName: sourceName,
      fileType: ImportFileType.htmlXls,
      courses: List.unmodifiable(unique.values),
      warnings: List.unmodifiable(warnings),
    );
  }

  List<ParsedCourse> _parseGridTable(
    dom.Element table,
    List<ParseWarning> warnings,
  ) {
    final grid = _buildTableGrid(table);
    if (grid.length < 2) {
      return const [];
    }

    final weekdayByColumn = <int, int>{};
    for (final row in grid.take(3)) {
      for (var column = 0; column < row.length; column++) {
        final weekday = _weekdayFromText(row[column].text);
        if (weekday != null) {
          weekdayByColumn[column] = weekday;
        }
      }
      if (weekdayByColumn.isNotEmpty) {
        break;
      }
    }
    if (weekdayByColumn.isEmpty) {
      return const [];
    }

    final courses = <ParsedCourse>[];
    for (final row in grid.skip(1)) {
      final fallbackPeriod = _periodFromRow(row);
      for (final entry in weekdayByColumn.entries) {
        if (entry.key >= row.length) {
          continue;
        }
        final cell = row[entry.key];
        for (final fragment in _courseFragmentsFromCell(cell.element)) {
          final lines = _lines(fragment);
          courses.addAll(
            _textParser.parseCourseLines(
              lines: lines,
              fallbackWeekday: entry.value,
              fallbackPeriod: fallbackPeriod,
              warnings: warnings,
              rawText: fragment,
            ),
          );
        }
      }
    }
    return courses;
  }

  List<ParsedCourse> _parseLooseRows(
    dom.Element table,
    List<ParseWarning> warnings,
  ) {
    final courses = <ParsedCourse>[];
    for (final row in table.querySelectorAll('tr')) {
      final text = _cellTextWithBreaks(row);
      final weekday = _weekdayFromText(text);
      PeriodRange? period;
      try {
        period = PeriodRange.parse(text);
      } on FormatException {
        period = null;
      }
      for (final fragment in _splitCourseFragments(text)) {
        courses.addAll(
          _textParser.parseCourseLines(
            lines: _lines(fragment),
            fallbackWeekday: weekday,
            fallbackPeriod: period,
            warnings: warnings,
            rawText: fragment,
          ),
        );
      }
    }
    return courses;
  }

  String _decodeHtml(List<int> bytes, List<ParseWarning> warnings) {
    final asciiPrefix = ascii.decode(
      bytes.take(bytes.length < 2048 ? bytes.length : 2048).toList(),
      allowInvalid: true,
    );
    final charsetMatch = RegExp(
      r'charset\s*=\s*["'
      ']?([a-zA-Z0-9_-]+)',
      caseSensitive: false,
    ).firstMatch(asciiPrefix);
    final charsetName = charsetMatch?.group(1)?.toLowerCase();

    if (charsetName == 'gbk' ||
        charsetName == 'gb2312' ||
        charsetName == 'gb18030') {
      return gbk.decode(bytes, allowMalformed: true);
    }

    try {
      return utf8.decode(bytes);
    } on FormatException {
      warnings.add(
        const ParseWarning(
          message: 'HTML was not valid UTF-8; decoded with GBK fallback.',
          code: ParseWarningCode.decodedWithFallback,
          severity: ParseWarningSeverity.info,
        ),
      );
      return gbk.decode(bytes, allowMalformed: true);
    }
  }

  List<List<_GridCell>> _buildTableGrid(dom.Element table) {
    final rows = <List<_GridCell>>[];
    final pendingRowspans = <int, _PendingCell>{};

    for (final row in table.querySelectorAll('tr')) {
      final output = <_GridCell>[];
      var column = 0;

      void fillPending() {
        while (pendingRowspans.containsKey(column)) {
          final pending = pendingRowspans[column]!;
          output.add(pending.cell);
          pending.remainingRows -= 1;
          if (pending.remainingRows <= 0) {
            pendingRowspans.remove(column);
          }
          column += 1;
        }
      }

      for (final element in row.children.where(_isTableCell)) {
        fillPending();
        final colspan = _positiveSpan(element.attributes['colspan']);
        final rowspan = _positiveSpan(element.attributes['rowspan']);
        final cell = _GridCell(
          element: element,
          text: _cellTextWithBreaks(element),
        );
        for (var i = 0; i < colspan; i++) {
          output.add(cell);
          if (rowspan > 1) {
            pendingRowspans[column + i] = _PendingCell(
              cell: cell,
              remainingRows: rowspan - 1,
            );
          }
        }
        column += colspan;
      }
      fillPending();

      if (output.isNotEmpty) {
        rows.add(output);
      }
    }
    return rows;
  }

  PeriodRange? _periodFromRow(List<_GridCell> row) {
    for (final cell in row.take(3)) {
      try {
        return PeriodRange.parse(cell.text);
      } on FormatException {
        continue;
      }
    }
    return null;
  }

  Iterable<String> _courseFragmentsFromCell(dom.Element cell) sync* {
    final richFragments = cell
        .querySelectorAll('.xkinfo div')
        .map(_cellTextWithBreaks)
        .where((text) => text.trim().isNotEmpty)
        .toList(growable: false);
    if (richFragments.isNotEmpty) {
      yield* richFragments;
      return;
    }

    yield* _splitCourseFragments(_cellTextWithBreaks(cell));
  }

  bool _isTableCell(dom.Element element) =>
      element.localName == 'td' || element.localName == 'th';

  String _cellTextWithBreaks(dom.Element element) {
    final html = element.innerHtml
        .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</\s*p\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</\s*div\s*>', caseSensitive: false), '\n');
    return html_parser
            .parseFragment(html)
            .text
            ?.replaceAll(RegExp(r'[ \t\r]+'), ' ')
            .trim() ??
        '';
  }

  Iterable<String> _splitCourseFragments(String text) sync* {
    final normalized = text.replaceAll('\u00a0', ' ').trim();
    if (normalized.isEmpty) {
      return;
    }
    final chunks = normalized.split(RegExp(r'\n{2,}|-{5,}|={5,}'));
    for (final chunk in chunks) {
      final value = chunk.trim();
      if (value.isNotEmpty) {
        yield value;
      }
    }
  }

  int? _weekdayFromText(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), '');
    const names = {
      '周一': DateTime.monday,
      '星期一': DateTime.monday,
      '一': DateTime.monday,
      '周二': DateTime.tuesday,
      '星期二': DateTime.tuesday,
      '二': DateTime.tuesday,
      '周三': DateTime.wednesday,
      '星期三': DateTime.wednesday,
      '三': DateTime.wednesday,
      '周四': DateTime.thursday,
      '星期四': DateTime.thursday,
      '四': DateTime.thursday,
      '周五': DateTime.friday,
      '星期五': DateTime.friday,
      '五': DateTime.friday,
      '周六': DateTime.saturday,
      '星期六': DateTime.saturday,
      '六': DateTime.saturday,
      '周日': DateTime.sunday,
      '周天': DateTime.sunday,
      '星期日': DateTime.sunday,
      '星期天': DateTime.sunday,
      '日': DateTime.sunday,
      '天': DateTime.sunday,
    };
    for (final entry in names.entries) {
      if (normalized == entry.key || normalized.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  List<String> _lines(String text) {
    return text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }
}

class _GridCell {
  const _GridCell({required this.element, required this.text});

  final dom.Element element;
  final String text;
}

class _PendingCell {
  _PendingCell({required this.cell, required this.remainingRows});

  final _GridCell cell;
  int remainingRows;
}

int _positiveSpan(String? value) {
  final parsed = int.tryParse(value ?? '');
  if (parsed == null || parsed < 1) {
    return 1;
  }
  return parsed;
}
