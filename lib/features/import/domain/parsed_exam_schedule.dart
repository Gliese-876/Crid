import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../core/file/import_file_type_detector.dart';
import 'parsed_timetable.dart';

class ParsedExamSchedule {
  const ParsedExamSchedule({
    required this.sourceName,
    required this.fileType,
    required this.exams,
    this.warnings = const [],
  });

  final String sourceName;
  final ImportFileType fileType;
  final List<ParsedExam> exams;
  final List<ParseWarning> warnings;
}

class ParsedExam {
  ParsedExam({
    required this.examRound,
    required this.courseName,
    required this.startAt,
    required this.endAt,
    required this.semesterWeek,
    required this.weekday,
    this.courseCode = '',
    this.credits,
    this.category = '',
    this.assessmentMethod = '',
    this.location = '',
    this.seatNumber = '',
    this.rawText,
    String? sourceFingerprint,
  }) : sourceFingerprint =
           sourceFingerprint ??
           _fingerprint(
             examRound: examRound,
             courseCode: courseCode,
             courseName: courseName,
             startAt: startAt,
             endAt: endAt,
             location: location,
             seatNumber: seatNumber,
           );

  final String examRound;
  final String courseCode;
  final String courseName;
  final double? credits;
  final String category;
  final String assessmentMethod;
  final DateTime startAt;
  final DateTime endAt;
  final int semesterWeek;
  final int weekday;
  final String location;
  final String seatNumber;
  final String? rawText;
  final String sourceFingerprint;

  String get displayName {
    if (courseCode.isEmpty) {
      return courseName;
    }
    return '[$courseCode]$courseName';
  }

  Map<String, Object?> toNormalizedJson() {
    return {
      'examRound': examRound,
      'courseCode': courseCode,
      'courseName': courseName,
      'credits': credits,
      'category': category,
      'assessmentMethod': assessmentMethod,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'semesterWeek': semesterWeek,
      'weekday': weekday,
      'location': location,
      'seatNumber': seatNumber,
    };
  }

  static String _fingerprint({
    required String examRound,
    required String courseCode,
    required String courseName,
    required DateTime startAt,
    required DateTime endAt,
    required String location,
    required String seatNumber,
  }) {
    final key = [
      'exam',
      normalizeCourseText(examRound),
      normalizeCourseText(courseCode),
      normalizeCourseText(courseName),
      startAt.toIso8601String(),
      endAt.toIso8601String(),
      normalizeCourseText(location),
      normalizeCourseText(seatNumber),
    ].join('|');
    return sha1.convert(utf8.encode(key)).toString();
  }
}
