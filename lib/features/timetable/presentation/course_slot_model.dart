import 'package:flutter/material.dart';

import '../../../core/time/period.dart';

enum WeekParity { all, odd, even }

class CourseSlot {
  CourseSlot({
    required this.id,
    this.courseId,
    this.sessionId,
    this.examId,
    required this.name,
    required this.teacher,
    required this.location,
    required this.weekday,
    required this.timeRange,
    required this.startWeek,
    required this.endWeek,
    required this.parity,
    required this.color,
    this.notes = '',
    this.hidden = false,
  });

  final String id;
  final int? courseId;
  final int? sessionId;
  final int? examId;
  final String name;
  final String teacher;
  final String location;
  final int weekday;
  final CourseTimeRange timeRange;
  final int startWeek;
  final int endWeek;
  final WeekParity parity;
  final Color color;
  final String notes;
  final bool hidden;

  int get startPeriod => timeRange.period.start;

  int get endPeriod => timeRange.period.end;

  int get startMinuteOfDay => timeRange.startMinuteOfDay;

  int get endMinuteOfDay => timeRange.endMinuteOfDay;

  bool get isExam => examId != null;

  bool isActiveInWeek(int week) {
    if (hidden || week < startWeek || week > endWeek) {
      return false;
    }
    return switch (parity) {
      WeekParity.all => true,
      WeekParity.odd => week.isOdd,
      WeekParity.even => week.isEven,
    };
  }

  String get weekLabel {
    final parityLabel = switch (parity) {
      WeekParity.all => '',
      WeekParity.odd => ' odd',
      WeekParity.even => ' even',
    };
    return 'Weeks $startWeek-$endWeek$parityLabel';
  }

  String get timeLabel =>
      '${_minuteLabel(startMinuteOfDay)}-${_minuteLabel(endMinuteOfDay)}';
}

String _minuteLabel(int minuteOfDay) {
  final hour = minuteOfDay ~/ 60;
  final minute = minuteOfDay % 60;
  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}
