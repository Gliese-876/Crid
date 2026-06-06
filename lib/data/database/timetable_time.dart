import '../../core/time/period.dart' as core_time;

enum WeekParity {
  all,
  odd,
  even;

  bool includes(int week) {
    return switch (this) {
      WeekParity.all => true,
      WeekParity.odd => week.isOdd,
      WeekParity.even => week.isEven,
    };
  }

  static WeekParity fromDatabase(String? value) {
    return switch (value) {
      'odd' => WeekParity.odd,
      'even' => WeekParity.even,
      _ => WeekParity.all,
    };
  }

  String? get databaseValue {
    return this == WeekParity.all ? null : name;
  }
}

typedef LessonSlot = core_time.LessonTimeSlot;

const defaultBnuzLessonSlots = core_time.defaultLessonTimeSlots;

class ClassSessionInfo {
  const ClassSessionInfo({
    required this.sessionId,
    required this.courseId,
    required this.courseName,
    required this.weekday,
    required this.startSection,
    required this.endSection,
    required this.weekStart,
    required this.weekEnd,
    this.startMinuteOfDay,
    this.endMinuteOfDay,
    this.teacher,
    this.location,
    this.note,
    this.color,
    this.weekParity = WeekParity.all,
  });

  final int sessionId;
  final int courseId;
  final String courseName;
  final String? teacher;
  final String? location;
  final String? note;
  final String? color;

  /// ISO weekday, Monday = 1, Sunday = 7.
  final int weekday;
  final int startSection;
  final int endSection;
  final int? startMinuteOfDay;
  final int? endMinuteOfDay;
  final int weekStart;
  final int weekEnd;
  final WeekParity weekParity;
}

class ClassSessionOccurrence {
  const ClassSessionOccurrence({
    required this.session,
    required this.week,
    required this.start,
    required this.end,
  });

  final ClassSessionInfo session;
  final int week;
  final DateTime start;
  final DateTime end;
}

Iterable<ClassSessionOccurrence> expandClassSessionOccurrences({
  required ClassSessionInfo session,
  required DateTime firstWeekMonday,
  Iterable<LessonSlot> lessonSlots = defaultBnuzLessonSlots,
}) sync* {
  final range =
      session.startMinuteOfDay != null && session.endMinuteOfDay != null
      ? core_time.CourseTimeRange.fromClockTimes(
          startMinuteOfDay: session.startMinuteOfDay!,
          endMinuteOfDay: session.endMinuteOfDay!,
          lessonSlots: lessonSlots,
        )
      : core_time.CourseTimeRange.fromPeriods(
          session.startSection,
          session.endSection,
          lessonSlots: lessonSlots,
        );

  for (var week = session.weekStart; week <= session.weekEnd; week++) {
    if (!session.weekParity.includes(week)) {
      continue;
    }

    final date = DateTime(
      firstWeekMonday.year,
      firstWeekMonday.month,
      firstWeekMonday.day + ((week - 1) * 7) + (session.weekday - 1),
    );
    yield ClassSessionOccurrence(
      session: session,
      week: week,
      start: DateTime(
        date.year,
        date.month,
        date.day,
        range.startMinuteOfDay ~/ 60,
        range.startMinuteOfDay % 60,
      ),
      end: DateTime(
        date.year,
        date.month,
        date.day,
        range.endMinuteOfDay ~/ 60,
        range.endMinuteOfDay % 60,
      ),
    );
  }
}
