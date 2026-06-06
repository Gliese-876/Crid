import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:charset/charset.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:mime/mime.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../core/file/import_file_type_detector.dart';
import '../domain/parsed_exam_schedule.dart';
import '../domain/parsed_timetable.dart';

class KingosoftExamParser {
  const KingosoftExamParser({
    ImportFileTypeDetector detector = const ImportFileTypeDetector(),
  }) : _detector = detector;

  final ImportFileTypeDetector _detector;

  Future<ParsedExamSchedule> parse({
    required String sourceName,
    required List<int> bytes,
  }) async {
    final fileType = _detector.detect(fileName: sourceName, bytes: bytes);
    final warnings = <ParseWarning>[];
    final exams = switch (fileType) {
      ImportFileType.mhtml => await _parseMhtml(bytes, warnings),
      ImportFileType.pdf => _parsePdf(bytes, warnings),
      ImportFileType.plainText => _parseText(_decodeText(bytes), warnings),
      _ => <ParsedExam>[],
    };

    if (exams.isEmpty) {
      warnings.add(
        ParseWarning(
          message: 'No complete KINGOSOFT exam schedule rows were recognized.',
          code: ParseWarningCode.noCompleteEntries,
          severity:
              fileType == ImportFileType.mhtml ||
                  fileType == ImportFileType.pdf ||
                  fileType == ImportFileType.plainText
              ? ParseWarningSeverity.warning
              : ParseWarningSeverity.error,
        ),
      );
    }

    final unique = <String, ParsedExam>{};
    for (final exam in exams) {
      unique[exam.sourceFingerprint] = exam;
    }

    return ParsedExamSchedule(
      sourceName: sourceName,
      fileType: fileType,
      exams: List.unmodifiable(unique.values),
      warnings: List.unmodifiable(warnings),
    );
  }

  Future<List<ParsedExam>> _parseMhtml(
    List<int> bytes,
    List<ParseWarning> warnings,
  ) async {
    final parts = await _decodeMhtmlParts(bytes, warnings);
    final exams = <ParsedExam>[];
    for (final part in parts) {
      if (!part.contentType.toLowerCase().contains('text/html')) {
        continue;
      }
      final htmlExams = _parseHtml(part.text, warnings);
      if (htmlExams.isNotEmpty) {
        exams.addAll(htmlExams);
      }
    }
    if (exams.isNotEmpty) {
      return exams;
    }
    return _parseText(parts.map((part) => part.text).join('\n'), warnings);
  }

  List<ParsedExam> _parsePdf(List<int> bytes, List<ParseWarning> warnings) {
    final document = PdfDocument(inputBytes: bytes);
    try {
      final extractor = PdfTextExtractor(document);
      final textExams = _parseText(extractor.extractText(), warnings);
      if (textExams.isNotEmpty) {
        return textExams;
      }
      return _parsePdfTextLines(extractor.extractTextLines());
    } finally {
      document.dispose();
    }
  }

  List<ParsedExam> _parsePdfTextLines(List<TextLine> lines) {
    final sortedLines = [...lines]
      ..sort((a, b) {
        final page = a.pageIndex.compareTo(b.pageIndex);
        if (page != 0) {
          return page;
        }
        final top = a.bounds.top.compareTo(b.bounds.top);
        if (top != 0) {
          return top;
        }
        return a.bounds.left.compareTo(b.bounds.left);
      });
    final anchors = sortedLines
        .where(
          (line) =>
              line.bounds.left >= 40 &&
              line.bounds.left <= 58 &&
              RegExp(
                r'^\d{1,2}\s+(随堂考|期末考试)',
              ).hasMatch(_normalizePdfGlyphs(line.text)),
        )
        .toList();
    final words = [
      for (final line in sortedLines)
        for (final word in line.wordCollection)
          if (_normalizePdfGlyphs(word.text).trim().isNotEmpty)
            _PdfWord(
              pageIndex: line.pageIndex,
              left: word.bounds.left,
              top: word.bounds.top,
              width: word.bounds.width,
              text: _normalizePdfGlyphs(word.text),
            ),
    ];
    final exams = <ParsedExam>[];
    for (var i = 0; i < anchors.length; i++) {
      final anchor = anchors[i];
      final nextAnchor = i + 1 < anchors.length ? anchors[i + 1] : null;
      final top = anchor.bounds.top - 8;
      final bottom =
          nextAnchor == null || nextAnchor.pageIndex != anchor.pageIndex
          ? anchor.bounds.top + 80
          : nextAnchor.bounds.top - 8;
      final rowWords = words
          .where(
            (word) =>
                word.pageIndex == anchor.pageIndex &&
                word.top >= top &&
                word.top < bottom,
          )
          .toList();
      final exam =
          _examFromPdfRow(rowWords) ??
          _parseLooseLine(_normalizePdfGlyphs(anchor.text));
      if (exam != null) {
        exams.add(exam);
      }
    }
    return exams;
  }

  ParsedExam? _examFromPdfRow(List<_PdfWord> words) {
    final rowNumber = _pdfColumn(words, 40, 62);
    if (int.tryParse(rowNumber) == null) {
      return null;
    }
    final round = _pdfColumn(words, 62, 162);
    final course = _pdfColumn(words, 162, 284);
    final credits = _pdfColumn(words, 284, 307);
    final category = _pdfColumn(words, 307, 366);
    final method = _pdfColumn(words, 366, 389);
    final time = _pdfColumn(words, 389, 506);
    final location = _normalizePdfLocation(_pdfColumn(words, 506, 620));
    if (round.isEmpty || course.isEmpty || time.isEmpty) {
      return null;
    }
    final parsedCourse = _parseCourse(course);
    final parsedTime = _parseExamTime(time);
    if (parsedCourse.name.isEmpty || parsedTime == null) {
      return null;
    }
    return ParsedExam(
      examRound: round,
      courseCode: parsedCourse.code,
      courseName: parsedCourse.name,
      credits: double.tryParse(credits),
      category: category,
      assessmentMethod: method,
      startAt: parsedTime.startAt,
      endAt: parsedTime.endAt,
      semesterWeek: parsedTime.week,
      weekday: parsedTime.weekday,
      location: location,
      seatNumber: '',
      rawText: [
        rowNumber,
        round,
        course,
        credits,
        category,
        method,
        time,
        location,
      ].join('\t'),
    );
  }

  List<ParsedExam> _parseHtml(String html, List<ParseWarning> warnings) {
    final document = html_parser.parse(html);
    final exams = <ParsedExam>[];
    for (final row in document.querySelectorAll('tr')) {
      final cells = <String, String>{};
      for (final cell in row.querySelectorAll('td,th')) {
        final name = cell.attributes['name']?.trim();
        if (name == null || name.isEmpty) {
          continue;
        }
        cells[name] = _htmlCellValue(cell);
      }
      final exam = _examFromNamedCells(cells);
      if (exam != null) {
        exams.add(exam);
      }
    }
    return exams;
  }

  ParsedExam? _examFromNamedCells(Map<String, String> cells) {
    final round = cells['kslcmc'] ?? '';
    final course = cells['kc'] ?? '';
    final time = cells['kssj'] ?? '';
    if (round.isEmpty || course.isEmpty || time.isEmpty) {
      return null;
    }
    final parsedTime = _parseExamTime(time);
    if (parsedTime == null) {
      return null;
    }
    final parsedCourse = _parseCourse(course);
    return ParsedExam(
      examRound: round,
      courseCode: parsedCourse.code,
      courseName: parsedCourse.name,
      credits: double.tryParse(cells['xf'] ?? ''),
      category: cells['lb'] ?? '',
      assessmentMethod: cells['khfs'] ?? '',
      startAt: parsedTime.startAt,
      endAt: parsedTime.endAt,
      semesterWeek: parsedTime.week,
      weekday: parsedTime.weekday,
      location: cells['ksdd'] ?? '',
      seatNumber: cells['zwh'] ?? '',
      rawText: cells.values.join('\t'),
    );
  }

  String _htmlCellValue(dom.Element cell) {
    final title = cell.attributes['title']?.trim();
    if (title != null && title.isNotEmpty) {
      return _normalizeWhitespace(title);
    }
    final html = cell.innerHtml
        .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</\s*div\s*>', caseSensitive: false), '\n');
    return _normalizeWhitespace(html_parser.parseFragment(html).text ?? '');
  }

  List<ParsedExam> _parseText(String text, List<ParseWarning> warnings) {
    final exams = <ParsedExam>[];
    final logicalLines = _logicalExamLines(text);
    for (final line in logicalLines) {
      final exam = _parseDelimitedLine(line) ?? _parseLooseLine(line);
      if (exam != null) {
        exams.add(exam);
      }
    }
    return exams;
  }

  Iterable<String> _logicalExamLines(String text) sync* {
    final normalized = text
        .replaceAll('\u00a0', ' ')
        .replaceAll('\u3000', ' ')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    final lines = normalized
        .split('\n')
        .map(_normalizeWhitespace)
        .where((line) => line.isNotEmpty)
        .toList();
    final rowStart = RegExp(r'^\d{1,2}\s+');
    final buffer = StringBuffer();
    for (final line in lines) {
      if (rowStart.hasMatch(line) && buffer.isNotEmpty) {
        yield buffer.toString();
        buffer.clear();
      }
      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write(line);
    }
    if (buffer.isNotEmpty) {
      yield buffer.toString();
    }
  }

  ParsedExam? _parseDelimitedLine(String line) {
    final columns = line
        .split('\t')
        .map(_normalizeWhitespace)
        .where((column) => column.isNotEmpty)
        .toList();
    if (columns.length < 8) {
      return null;
    }
    final offset = int.tryParse(columns.first) == null ? 0 : 1;
    if (columns.length - offset < 8) {
      return null;
    }
    final parsedCourse = _parseCourse(columns[offset + 1]);
    final parsedTime = _parseExamTime(columns[offset + 5]);
    if (parsedCourse.name.isEmpty || parsedTime == null) {
      return null;
    }
    return ParsedExam(
      examRound: columns[offset],
      courseCode: parsedCourse.code,
      courseName: parsedCourse.name,
      credits: double.tryParse(columns[offset + 2]),
      category: columns[offset + 3],
      assessmentMethod: columns[offset + 4],
      startAt: parsedTime.startAt,
      endAt: parsedTime.endAt,
      semesterWeek: parsedTime.week,
      weekday: parsedTime.weekday,
      location: columns[offset + 6],
      seatNumber: columns.length > offset + 7 ? columns[offset + 7] : '',
      rawText: line,
    );
  }

  ParsedExam? _parseLooseLine(String line) {
    final match = RegExp(
      r'^\d{1,2}\s+'
      r'(?<round>.+?)\s+'
      r'(?<course>\[[A-Z0-9]+\].+?)\s+'
      r'(?<credits>\d+(?:\.\d+)?)\s+'
      r'(?<category>.+?)\s+'
      r'(?<method>考试|考查)\s+'
      r'(?<time>\d{4}-\d{2}-\d{2}\([^)]+\)\d{2}:\d{2}-\d{2}:\d{2})\s+'
      r'(?<rest>.+)$',
    ).firstMatch(line);
    if (match == null) {
      return null;
    }
    final parsedCourse = _parseCourse(match.namedGroup('course') ?? '');
    final parsedTime = _parseExamTime(match.namedGroup('time') ?? '');
    if (parsedCourse.name.isEmpty || parsedTime == null) {
      return null;
    }
    final rest = _normalizeWhitespace(match.namedGroup('rest') ?? '');
    final seatMatch = RegExp(r'\s+(?<seat>\d+)$').firstMatch(rest);
    final seat = seatMatch?.namedGroup('seat') ?? '';
    final location = seatMatch == null
        ? rest
        : rest.substring(0, seatMatch.start).trim();
    return ParsedExam(
      examRound: _normalizeWhitespace(match.namedGroup('round') ?? ''),
      courseCode: parsedCourse.code,
      courseName: parsedCourse.name,
      credits: double.tryParse(match.namedGroup('credits') ?? ''),
      category: _normalizeWhitespace(match.namedGroup('category') ?? ''),
      assessmentMethod: match.namedGroup('method') ?? '',
      startAt: parsedTime.startAt,
      endAt: parsedTime.endAt,
      semesterWeek: parsedTime.week,
      weekday: parsedTime.weekday,
      location: location,
      seatNumber: seat,
      rawText: line,
    );
  }

  _ParsedCourseName _parseCourse(String value) {
    final match = RegExp(
      r'^\s*\[(?<code>[^\]]+)\]\s*(?<name>.+)$',
    ).firstMatch(value);
    if (match == null) {
      return _ParsedCourseName('', _normalizeWhitespace(value));
    }
    return _ParsedCourseName(
      _normalizeWhitespace(match.namedGroup('code') ?? ''),
      _normalizeWhitespace(match.namedGroup('name') ?? ''),
    );
  }

  _ParsedExamTime? _parseExamTime(String value) {
    final match = RegExp(
      r'(?<date>\d{4}-\d{2}-\d{2})'
      r'\(\s*(?<week>\d{1,2})\s*周\s*星期?(?<weekday>[一二三四五六日天])\s*\)'
      r'\s*(?<start>\d{2}:\d{2})\s*-\s*(?<end>\d{2}:\d{2})',
    ).firstMatch(value);
    if (match == null) {
      return null;
    }
    final dateParts = match.namedGroup('date')!.split('-').map(int.parse);
    final date = dateParts.toList(growable: false);
    final startParts = match.namedGroup('start')!.split(':').map(int.parse);
    final endParts = match.namedGroup('end')!.split(':').map(int.parse);
    final start = startParts.toList(growable: false);
    final end = endParts.toList(growable: false);
    return _ParsedExamTime(
      startAt: DateTime(date[0], date[1], date[2], start[0], start[1]),
      endAt: DateTime(date[0], date[1], date[2], end[0], end[1]),
      week: int.parse(match.namedGroup('week')!),
      weekday: _weekdayFromChinese(match.namedGroup('weekday') ?? ''),
    );
  }

  int _weekdayFromChinese(String value) {
    return switch (value) {
      '一' => DateTime.monday,
      '二' => DateTime.tuesday,
      '三' => DateTime.wednesday,
      '四' => DateTime.thursday,
      '五' => DateTime.friday,
      '六' => DateTime.saturday,
      '日' || '天' => DateTime.sunday,
      _ => DateTime.monday,
    };
  }

  Future<List<_MhtmlPart>> _decodeMhtmlParts(
    List<int> bytes,
    List<ParseWarning> warnings,
  ) async {
    final raw = latin1.decode(bytes, allowInvalid: true);
    final headerEnd = _messageHeaderEnd(raw);
    if (headerEnd < 0) {
      return const [];
    }
    final headers = _parseHeaders(raw.substring(0, headerEnd));
    final boundary = _boundaryFromContentType(headers['content-type'] ?? '');
    if (boundary == null || boundary.isEmpty) {
      return const [];
    }
    final bodyText = raw.substring(headerEnd);
    final bodyBytes = Uint8List.fromList([13, 10, ...latin1.encode(bodyText)]);
    final parts = <_MhtmlPart>[];
    try {
      await for (final part in MimeMultipartTransformer(
        boundary,
      ).bind(Stream.value(bodyBytes))) {
        final partBytes = await _collectBytes(part);
        final contentType = part.headers['content-type'] ?? '';
        final transferEncoding =
            part.headers['content-transfer-encoding']?.toLowerCase() ?? '';
        final decodedBytes = _decodeTransfer(partBytes, transferEncoding);
        parts.add(
          _MhtmlPart(
            contentType: contentType,
            text: _decodePartText(decodedBytes, contentType),
          ),
        );
      }
    } on Object catch (error) {
      warnings.add(
        ParseWarning(
          message: 'MHTML multipart parsing failed: $error',
          code: ParseWarningCode.generic,
        ),
      );
    }
    return parts;
  }

  int _messageHeaderEnd(String raw) {
    final crlf = raw.indexOf('\r\n\r\n');
    if (crlf >= 0) {
      return crlf + 4;
    }
    final lf = raw.indexOf('\n\n');
    return lf >= 0 ? lf + 2 : -1;
  }

  Map<String, String> _parseHeaders(String rawHeaders) {
    final lines = rawHeaders.replaceAll('\r\n', '\n').split('\n');
    final unfolded = <String>[];
    for (final line in lines) {
      if ((line.startsWith(' ') || line.startsWith('\t')) &&
          unfolded.isNotEmpty) {
        unfolded[unfolded.length - 1] = '${unfolded.last} ${line.trimLeft()}';
      } else {
        unfolded.add(line);
      }
    }
    return {
      for (final line in unfolded)
        if (line.contains(':'))
          line.substring(0, line.indexOf(':')).trim().toLowerCase(): line
              .substring(line.indexOf(':') + 1)
              .trim(),
    };
  }

  String? _boundaryFromContentType(String value) {
    final match = RegExp(
      r'boundary\s*=\s*"?(?<boundary>[^";\r\n]+)"?',
      caseSensitive: false,
    ).firstMatch(value);
    return match?.namedGroup('boundary');
  }

  Future<List<int>> _collectBytes(Stream<List<int>> stream) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in stream) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  List<int> _decodeTransfer(List<int> bytes, String transferEncoding) {
    return switch (transferEncoding) {
      'base64' => base64.decode(_asciiBody(bytes)),
      'quoted-printable' => _decodeQuotedPrintable(bytes),
      _ => bytes,
    };
  }

  String _asciiBody(List<int> bytes) {
    return ascii
        .decode(bytes, allowInvalid: true)
        .replaceAll(RegExp(r'\s+'), '');
  }

  List<int> _decodeQuotedPrintable(List<int> bytes) {
    final output = <int>[];
    for (var i = 0; i < bytes.length; i++) {
      final byte = bytes[i];
      if (byte != 0x3D || i + 1 >= bytes.length) {
        output.add(byte);
        continue;
      }
      final next = bytes[i + 1];
      if (next == 0x0D || next == 0x0A) {
        i += next == 0x0D && i + 2 < bytes.length && bytes[i + 2] == 0x0A
            ? 2
            : 1;
        continue;
      }
      if (i + 2 < bytes.length) {
        final high = _hexValue(bytes[i + 1]);
        final low = _hexValue(bytes[i + 2]);
        if (high >= 0 && low >= 0) {
          output.add(high * 16 + low);
          i += 2;
          continue;
        }
      }
      output.add(byte);
    }
    return output;
  }

  int _hexValue(int byte) {
    if (byte >= 0x30 && byte <= 0x39) {
      return byte - 0x30;
    }
    if (byte >= 0x41 && byte <= 0x46) {
      return byte - 0x41 + 10;
    }
    if (byte >= 0x61 && byte <= 0x66) {
      return byte - 0x61 + 10;
    }
    return -1;
  }

  String _decodePartText(List<int> bytes, String contentType) {
    final charsetMatch = RegExp(
      r'charset\s*=\s*"?(?<charset>[a-zA-Z0-9_-]+)"?',
      caseSensitive: false,
    ).firstMatch(contentType);
    final charsetName = charsetMatch?.namedGroup('charset')?.toLowerCase();
    if (charsetName == 'gbk' ||
        charsetName == 'gb2312' ||
        charsetName == 'gb18030') {
      return gbk.decode(bytes, allowMalformed: true);
    }
    return _decodeText(bytes);
  }

  String _decodeText(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return gbk.decode(bytes, allowMalformed: true);
    }
  }
}

class _MhtmlPart {
  const _MhtmlPart({required this.contentType, required this.text});

  final String contentType;
  final String text;
}

class _PdfWord {
  const _PdfWord({
    required this.pageIndex,
    required this.left,
    required this.top,
    required this.width,
    required this.text,
  });

  final int pageIndex;
  final double left;
  final double top;
  final double width;
  final String text;
}

class _ParsedCourseName {
  const _ParsedCourseName(this.code, this.name);

  final String code;
  final String name;
}

class _ParsedExamTime {
  const _ParsedExamTime({
    required this.startAt,
    required this.endAt,
    required this.week,
    required this.weekday,
  });

  final DateTime startAt;
  final DateTime endAt;
  final int week;
  final int weekday;
}

String _normalizeWhitespace(String input) {
  return input
      .replaceAll('\u00a0', ' ')
      .replaceAll('\u3000', ' ')
      .replaceAll(RegExp(r'[ \t\r\n]+'), ' ')
      .trim();
}

String _pdfColumn(List<_PdfWord> words, double start, double end) {
  final selected =
      words.where((word) => word.left >= start && word.left < end).toList()
        ..sort((a, b) {
          final top = a.top.compareTo(b.top);
          if (top != 0) {
            return top;
          }
          return a.left.compareTo(b.left);
        });
  return _normalizeWhitespace(selected.map((word) => word.text).join());
}

String _normalizePdfLocation(String value) {
  final normalized = _normalizeWhitespace(value);
  final match = RegExp(r'^(.+?[楼场馆])(.+)$').firstMatch(normalized);
  if (match == null) {
    return normalized;
  }
  return '${match.group(1)} ${match.group(2)}';
}

String _normalizePdfGlyphs(String value) {
  const replacements = {
    r'\(': '(',
    r'\)': ')',
    '⼀': '一',
    '⼆': '二',
    '⼤': '大',
    '⼼': '心',
    '⽅': '方',
    '⽇': '日',
    '⽣': '生',
    '⽤': '用',
    '⽂': '文',
    '⾸': '首',
    '⻚': '页',
    '⻘': '青',
    '⼾': '户',
    '⾼': '高',
    '⾰': '革',
    '⽚': '片',
  };
  var normalized = value;
  for (final entry in replacements.entries) {
    normalized = normalized.replaceAll(entry.key, entry.value);
  }
  return normalized;
}
