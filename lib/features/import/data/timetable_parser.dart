import '../../../core/file/import_file_type_detector.dart';
import '../domain/parsed_timetable.dart';
import 'biff_xls_parser_adapter.dart';
import 'html_xls_parser_adapter.dart';
import 'ics_parser_adapter.dart';

abstract class TimetableParserAdapter {
  Future<ParsedTimetable> parse({
    required String sourceName,
    required List<int> bytes,
    DateTime? semesterFirstWeekMonday,
  });
}

class TimetableImportParser {
  TimetableImportParser({
    ImportFileTypeDetector detector = const ImportFileTypeDetector(),
    HtmlXlsParserAdapter? htmlXlsParser,
    IcsParserAdapter? icsParser,
    BiffXlsParserAdapter? biffXlsParser,
  }) : _detector = detector,
       _htmlXlsParser = htmlXlsParser ?? const HtmlXlsParserAdapter(),
       _icsParser = icsParser ?? const IcsParserAdapter(),
       _biffXlsParser = biffXlsParser ?? const BiffXlsParserAdapter();

  final ImportFileTypeDetector _detector;
  final HtmlXlsParserAdapter _htmlXlsParser;
  final IcsParserAdapter _icsParser;
  final BiffXlsParserAdapter _biffXlsParser;

  Future<ParsedTimetable> parse({
    required String sourceName,
    required List<int> bytes,
    DateTime? semesterFirstWeekMonday,
  }) {
    final fileType = _detector.detect(fileName: sourceName, bytes: bytes);
    return switch (fileType) {
      ImportFileType.htmlXls => _htmlXlsParser.parse(
        sourceName: sourceName,
        bytes: bytes,
        semesterFirstWeekMonday: semesterFirstWeekMonday,
      ),
      ImportFileType.ics => _icsParser.parse(
        sourceName: sourceName,
        bytes: bytes,
        semesterFirstWeekMonday: semesterFirstWeekMonday,
      ),
      ImportFileType.biffXls => _biffXlsParser.parse(
        sourceName: sourceName,
        bytes: bytes,
        semesterFirstWeekMonday: semesterFirstWeekMonday,
      ),
      ImportFileType.unknown => Future.value(
        ParsedTimetable(
          sourceName: sourceName,
          fileType: ImportFileType.unknown,
          courses: const [],
          warnings: const [
            ParseWarning(
              message: 'Unsupported timetable file type.',
              code: ParseWarningCode.unsupportedFileType,
              severity: ParseWarningSeverity.error,
            ),
          ],
        ),
      ),
    };
  }
}
