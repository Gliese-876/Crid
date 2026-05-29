import 'dart:convert';
import 'dart:io';

import 'package:crid/core/file/import_file_type_detector.dart';
import 'package:crid/core/time/period.dart';
import 'package:crid/core/time/week_pattern.dart';
import 'package:crid/features/import/data/timetable_parser.dart';
import 'package:crid/features/import/domain/merge_engine.dart';
import 'package:crid/features/import/domain/parsed_timetable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImportFileTypeDetector', () {
    test('detects ICS, HTML xls, and BIFF magic bytes', () {
      const detector = ImportFileTypeDetector();

      expect(
        detector.detect(
          fileName: 'calendar.ics',
          bytes: utf8.encode('BEGIN:VCALENDAR\nVERSION:2.0\nEND:VCALENDAR'),
        ),
        ImportFileType.ics,
      );
      expect(
        detector.detect(
          fileName: 'table.xls',
          bytes: ascii.encode('<html><table></table></html>'),
        ),
        ImportFileType.htmlXls,
      );
      expect(
        detector.detect(
          fileName: 'legacy.xls',
          bytes: [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1],
        ),
        ImportFileType.biffXls,
      );
    });
  });

  group('WeekPattern', () {
    test('normalizes ranges, fullwidth symbols, and odd/even weeks', () {
      expect(WeekPattern.parse('1-15周').weeks, [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
      ]);
      expect(WeekPattern.parse('１－１５周 单周').weeks, [1, 3, 5, 7, 9, 11, 13, 15]);
      expect(WeekPattern.parse('2-8周 双周').weeks, [2, 4, 6, 8]);
      expect(WeekPattern.parse('13-13').weeks, [13]);
    });
  });

  group('PeriodRange', () {
    test('infers single and odd-length periods from lesson times', () {
      expect(
        periodRangeFromTime(
          DateTime(2026, 3, 2, 8),
          DateTime(2026, 3, 2, 8, 45),
        ),
        const PeriodRange(1, 1),
      );
      expect(
        periodRangeFromTime(
          DateTime(2026, 3, 2, 8, 55),
          DateTime(2026, 3, 2, 10, 45),
        ),
        const PeriodRange(2, 3),
      );
      expect(
        periodRangeFromTime(
          DateTime(2026, 3, 2, 8),
          DateTime(2026, 3, 2, 9, 40),
        ),
        const PeriodRange(1, 2),
      );
    });
  });

  group('TimetableImportParser', () {
    test('parses ICS events and expands simple RRULE weeks', () async {
      final ics = '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Crid Test//EN
BEGIN:VEVENT
UID:test-1
SUMMARY:合成线代
DTSTART;TZID=Asia/Shanghai:20260303T080000
DTEND;TZID=Asia/Shanghai:20260303T094000
RRULE:FREQ=WEEKLY;COUNT=3
LOCATION:示例楼A101 教师甲
DESCRIPTION:第1 - 2节\\n示例楼A101\\n教师甲
END:VEVENT
END:VCALENDAR
''';

      final parsed = await TimetableImportParser().parse(
        sourceName: '日历.ics',
        bytes: utf8.encode(ics),
        semesterFirstWeekMonday: DateTime(2026, 3, 2),
      );

      expect(
        parsed.warnings.map(
          (warning) => '${warning.message} ${warning.rawContext}',
        ),
        isEmpty,
      );
      expect(parsed.courses, hasLength(1));
      final course = parsed.courses.single;
      expect(course.name, '合成线代');
      expect(course.teacher, '教师甲');
      expect(course.location, '示例楼A101');
      expect(course.weekday, DateTime.tuesday);
      expect(course.period, const PeriodRange(1, 2));
      expect(course.weeks.weeks, [1, 2, 3]);
    });

    test('parses the BIFF xls sample through the isolated adapter', () async {
      final file = File('test/校园课表-2025-2026春季学期.xls');
      final parsed = await TimetableImportParser().parse(
        sourceName: file.path,
        bytes: await file.readAsBytes(),
      );

      expect(parsed.fileType, ImportFileType.biffXls);
      expect(parsed.courses, hasLength(38));
      expect(
        parsed.courses.map((course) => course.name),
        contains('合成编程课程（A）'),
      );
      expect(parsed.courses.map((course) => course.name), contains('合成学基础 Ⅱ'));
      expect(
        parsed.courses.map((course) => course.location),
        contains('示例楼A111(100)'),
      );
      expect(
        parsed.warnings.map((warning) => warning.message).join('\n'),
        contains('BIFF'),
      );
    });

    test('fully parses the synthetic HTML xls timetable grid', () async {
      final file = File('test/学生选课课程表.xls');
      final parsed = await TimetableImportParser().parse(
        sourceName: file.path,
        bytes: await file.readAsBytes(),
      );

      expect(parsed.fileType, ImportFileType.htmlXls);
      expect(parsed.courses, hasLength(38));
      expect(
        parsed.courses.where(
          (course) =>
              course.name == '合成理论' &&
              course.weekday == DateTime.saturday &&
              course.period == const PeriodRange(1, 4),
        ),
        isNotEmpty,
      );
      expect(
        parsed.courses.where(
          (course) =>
              course.name == '合成与政策2' &&
              course.weeks.parity == WeekParity.even &&
              course.weeks.weeks.join(',') == '10,12',
        ),
        isNotEmpty,
      );
    });

    test('fully parses the synthetic ICS timetable export', () async {
      final file = File('test/日历-大一下.ics');
      final parsed = await TimetableImportParser().parse(
        sourceName: file.path,
        bytes: await file.readAsBytes(),
        semesterFirstWeekMonday: DateTime(2026, 3, 2),
      );

      expect(parsed.fileType, ImportFileType.ics);
      expect(parsed.courses, hasLength(27));
      expect(
        parsed.courses.where(
          (course) =>
              course.name == '合成通识课程甲乙' &&
              course.weekday == DateTime.tuesday &&
              course.period == const PeriodRange(5, 6) &&
              course.weeks.weeks.first == 1 &&
              course.weeks.weeks.last == 15,
        ),
        isNotEmpty,
      );
    });
  });

  group('TimetableMergeEngine', () {
    test(
      'adds multiple weekly slots for the same course in one import batch',
      () {
        final monday = ParsedCourse(
          name: 'Discrete Math',
          teacher: 'Ada',
          location: 'A101',
          weekday: DateTime.monday,
          period: const PeriodRange(1, 2),
          weeks: WeekPattern.range(1, 16),
        );
        final wednesday = ParsedCourse(
          name: 'Discrete Math',
          teacher: 'Ada',
          location: 'A101',
          weekday: DateTime.wednesday,
          period: const PeriodRange(3, 4),
          weeks: WeekPattern.range(1, 16),
        );
        final friday = ParsedCourse(
          name: 'Discrete Math',
          teacher: 'Ada',
          location: 'A101',
          weekday: DateTime.friday,
          period: const PeriodRange(5, 6),
          weeks: WeekPattern.range(1, 16),
        );

        final result = const TimetableMergeEngine().merge(
          existing: const [],
          incoming: [monday, wednesday, friday],
        );

        expect(result.added, [monday, wednesday, friday]);
        expect(result.skipped, isEmpty);
        expect(result.diffs, isEmpty);
        expect(result.conflicts, isEmpty);
      },
    );

    test(
      'skips duplicates, adds new courses, diffs changed fields, and conflicts overlaps',
      () {
        final base = ParsedCourse(
          name: '高等数学',
          teacher: '教师甲',
          location: 'A101',
          weekday: DateTime.monday,
          period: const PeriodRange(1, 2),
          weeks: WeekPattern.parse('1-15周'),
        );
        final changed = ParsedCourse(
          name: '高等数学',
          teacher: '教师乙',
          location: 'A102',
          weekday: DateTime.monday,
          period: const PeriodRange(1, 2),
          weeks: WeekPattern.parse('1-15周'),
        );
        final newCourse = ParsedCourse(
          name: '大学英语',
          weekday: DateTime.tuesday,
          period: const PeriodRange(3, 4),
          weeks: WeekPattern.parse('1-15周'),
        );
        final conflict = ParsedCourse(
          name: '中国近现代史纲要',
          weekday: DateTime.monday,
          period: const PeriodRange(2, 3),
          weeks: WeekPattern.parse('1-15周'),
        );

        final result = const TimetableMergeEngine().merge(
          existing: [base],
          incoming: [base, changed, newCourse, conflict],
        );

        expect(result.skipped, hasLength(1));
        expect(result.added, [newCourse]);
        expect(
          result.diffs.single.changedFields,
          containsAll([MergeDiffField.teacher, MergeDiffField.location]),
        );
        expect(result.conflicts.single.incoming, conflict);
      },
    );
  });
}
