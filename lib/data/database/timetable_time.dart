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

class LessonSlot {
  const LessonSlot({
    required this.section,
    required this.start,
    required this.end,
  });

  final int section;
  final ({int hour, int minute}) start;
  final ({int hour, int minute}) end;
}

const defaultBnuzLessonSlots = <LessonSlot>[
  LessonSlot(
    section: 1,
    start: (hour: 8, minute: 0),
    end: (hour: 8, minute: 45),
  ),
  LessonSlot(
    section: 2,
    start: (hour: 8, minute: 55),
    end: (hour: 9, minute: 40),
  ),
  LessonSlot(
    section: 3,
    start: (hour: 10, minute: 0),
    end: (hour: 10, minute: 45),
  ),
  LessonSlot(
    section: 4,
    start: (hour: 10, minute: 55),
    end: (hour: 11, minute: 40),
  ),
  LessonSlot(
    section: 5,
    start: (hour: 13, minute: 30),
    end: (hour: 14, minute: 15),
  ),
  LessonSlot(
    section: 6,
    start: (hour: 14, minute: 25),
    end: (hour: 15, minute: 10),
  ),
  LessonSlot(
    section: 7,
    start: (hour: 15, minute: 30),
    end: (hour: 16, minute: 15),
  ),
  LessonSlot(
    section: 8,
    start: (hour: 16, minute: 25),
    end: (hour: 17, minute: 10),
  ),
  LessonSlot(
    section: 9,
    start: (hour: 18, minute: 0),
    end: (hour: 18, minute: 45),
  ),
  LessonSlot(
    section: 10,
    start: (hour: 18, minute: 55),
    end: (hour: 19, minute: 40),
  ),
  LessonSlot(
    section: 11,
    start: (hour: 19, minute: 50),
    end: (hour: 20, minute: 35),
  ),
  LessonSlot(
    section: 12,
    start: (hour: 20, minute: 45),
    end: (hour: 21, minute: 30),
  ),
];

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
  final startSlot = lessonSlots.firstWhere(
    (slot) => slot.section == session.startSection,
    orElse: () => throw ArgumentError.value(
      session.startSection,
      'session.startSection',
      'No lesson slot exists for this section.',
    ),
  );
  final endSlot = lessonSlots.firstWhere(
    (slot) => slot.section == session.endSection,
    orElse: () => throw ArgumentError.value(
      session.endSection,
      'session.endSection',
      'No lesson slot exists for this section.',
    ),
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
        startSlot.start.hour,
        startSlot.start.minute,
      ),
      end: DateTime(
        date.year,
        date.month,
        date.day,
        endSlot.end.hour,
        endSlot.end.minute,
      ),
    );
  }
}
