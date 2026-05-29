import 'package:flutter/material.dart';

enum WeekParity { all, odd, even }

class CourseSlot {
  const CourseSlot({
    required this.id,
    this.courseId,
    this.sessionId,
    required this.name,
    required this.teacher,
    required this.location,
    required this.weekday,
    required this.startPeriod,
    required this.endPeriod,
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
  final String name;
  final String teacher;
  final String location;
  final int weekday;
  final int startPeriod;
  final int endPeriod;
  final int startWeek;
  final int endWeek;
  final WeekParity parity;
  final Color color;
  final String notes;
  final bool hidden;

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

  String get periodLabel => 'Periods $startPeriod-$endPeriod';
}
