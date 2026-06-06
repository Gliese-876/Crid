class PeriodRange {
  const PeriodRange(this.start, this.end)
    : assert(start > 0),
      assert(end >= start);

  factory PeriodRange.parse(String input) {
    final normalized = input
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('第', '')
        .replaceAll('節', '节')
        .replaceAll('－', '-')
        .replaceAll('—', '-')
        .replaceAll('–', '-');
    final match = RegExp(
      r'(\d{1,2})(?:[-~至到](\d{1,2}))?节?',
    ).firstMatch(normalized);
    if (match == null) {
      throw FormatException('No class period found in "$input".');
    }
    final start = int.parse(match.group(1)!);
    final end = int.parse(match.group(2) ?? match.group(1)!);
    return PeriodRange(start, end);
  }

  final int start;
  final int end;

  bool overlaps(PeriodRange other) => start <= other.end && other.start <= end;

  String get normalizedKey => '$start-$end';

  @override
  String toString() => normalizedKey;

  @override
  bool operator ==(Object other) =>
      other is PeriodRange && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}

const minutesPerDay = 24 * 60;

class LessonTimeSlot {
  const LessonTimeSlot({
    required this.section,
    required this.start,
    required this.end,
  });

  final int section;
  final ({int hour, int minute}) start;
  final ({int hour, int minute}) end;

  int get startMinuteOfDay => start.hour * 60 + start.minute;

  int get endMinuteOfDay => end.hour * 60 + end.minute;
}

const defaultLessonTimeSlots = <LessonTimeSlot>[
  LessonTimeSlot(
    section: 1,
    start: (hour: 8, minute: 0),
    end: (hour: 8, minute: 45),
  ),
  LessonTimeSlot(
    section: 2,
    start: (hour: 8, minute: 55),
    end: (hour: 9, minute: 40),
  ),
  LessonTimeSlot(
    section: 3,
    start: (hour: 10, minute: 0),
    end: (hour: 10, minute: 45),
  ),
  LessonTimeSlot(
    section: 4,
    start: (hour: 10, minute: 55),
    end: (hour: 11, minute: 40),
  ),
  LessonTimeSlot(
    section: 5,
    start: (hour: 13, minute: 30),
    end: (hour: 14, minute: 15),
  ),
  LessonTimeSlot(
    section: 6,
    start: (hour: 14, minute: 25),
    end: (hour: 15, minute: 10),
  ),
  LessonTimeSlot(
    section: 7,
    start: (hour: 15, minute: 30),
    end: (hour: 16, minute: 15),
  ),
  LessonTimeSlot(
    section: 8,
    start: (hour: 16, minute: 25),
    end: (hour: 17, minute: 10),
  ),
  LessonTimeSlot(
    section: 9,
    start: (hour: 18, minute: 0),
    end: (hour: 18, minute: 45),
  ),
  LessonTimeSlot(
    section: 10,
    start: (hour: 18, minute: 55),
    end: (hour: 19, minute: 40),
  ),
  LessonTimeSlot(
    section: 11,
    start: (hour: 19, minute: 50),
    end: (hour: 20, minute: 35),
  ),
  LessonTimeSlot(
    section: 12,
    start: (hour: 20, minute: 45),
    end: (hour: 21, minute: 30),
  ),
];

class CourseTimeRange {
  const CourseTimeRange({
    required this.period,
    required this.startMinuteOfDay,
    required this.endMinuteOfDay,
  }) : assert(startMinuteOfDay >= 0),
       assert(startMinuteOfDay < minutesPerDay),
       assert(endMinuteOfDay > 0),
       assert(endMinuteOfDay <= minutesPerDay),
       assert(endMinuteOfDay > startMinuteOfDay);

  factory CourseTimeRange.fromPeriods(
    int startPeriod,
    int endPeriod, {
    Iterable<LessonTimeSlot> lessonSlots = defaultLessonTimeSlots,
  }) {
    final period = PeriodRange(startPeriod, endPeriod);
    final slots = _sortedLessonSlots(lessonSlots);
    if (slots.isEmpty) {
      return CourseTimeRange(
        period: period,
        startMinuteOfDay: 0,
        endMinuteOfDay: minutesPerDay,
      );
    }

    final startSlot =
        lessonSlotForSection(startPeriod, lessonSlots: slots) ?? slots.first;
    final endSlot =
        lessonSlotForSection(endPeriod, lessonSlots: slots) ?? slots.last;
    final startMinute = startSlot.startMinuteOfDay;
    var endMinute = endSlot.endMinuteOfDay;
    if (endMinute <= startMinute) {
      endMinute = (startMinute + 45).clamp(1, minutesPerDay).toInt();
    }
    return CourseTimeRange(
      period: period,
      startMinuteOfDay: startMinute,
      endMinuteOfDay: endMinute,
    );
  }

  factory CourseTimeRange.fromClockTimes({
    required int startMinuteOfDay,
    required int endMinuteOfDay,
    Iterable<LessonTimeSlot> lessonSlots = defaultLessonTimeSlots,
  }) {
    final startMinute = clampMinuteOfDay(
      startMinuteOfDay,
    ).clamp(0, minutesPerDay - 1).toInt();
    final endMinute = clampMinuteOfDay(
      endMinuteOfDay,
    ).clamp(startMinute + 1, minutesPerDay).toInt();
    return CourseTimeRange(
      period: periodRangeFromMinutes(
        startMinute,
        endMinute,
        lessonSlots: lessonSlots,
      ),
      startMinuteOfDay: startMinute,
      endMinuteOfDay: endMinute,
    );
  }

  final PeriodRange period;
  final int startMinuteOfDay;
  final int endMinuteOfDay;

  bool overlaps(CourseTimeRange other) {
    return startMinuteOfDay < other.endMinuteOfDay &&
        other.startMinuteOfDay < endMinuteOfDay;
  }

  int get durationMinutes => endMinuteOfDay - startMinuteOfDay;
}

PeriodRange periodRangeFromTime(DateTime start, DateTime end) {
  return periodRangeFromMinutes(
    start.hour * 60 + start.minute,
    end.hour * 60 + end.minute,
  );
}

PeriodRange periodRangeFromMinutes(
  int startMinutes,
  int endMinutes, {
  Iterable<LessonTimeSlot> lessonSlots = defaultLessonTimeSlots,
}) {
  final slots = _sortedLessonSlots(lessonSlots);
  if (slots.isEmpty) {
    return const PeriodRange(1, 1);
  }
  final normalizedStart = clampMinuteOfDay(startMinutes);
  final normalizedEnd = clampMinuteOfDay(
    endMinutes,
  ).clamp(normalizedStart + 1, minutesPerDay).toInt();
  final overlappingSections = [
    for (final slot in slots)
      if (_rangesOverlap(
        normalizedStart,
        normalizedEnd,
        slot.startMinuteOfDay,
        slot.endMinuteOfDay,
      ))
        slot.section,
  ];

  if (overlappingSections.isNotEmpty) {
    return PeriodRange(overlappingSections.first, overlappingSections.last);
  }

  final startSlot = slots.firstWhere(
    (slot) => (normalizedStart - slot.startMinuteOfDay).abs() <= 20,
    orElse: () => slots.lastWhere(
      (slot) => normalizedStart >= slot.startMinuteOfDay,
      orElse: () => slots.first,
    ),
  );
  final endSlot = slots.firstWhere(
    (slot) => (normalizedEnd - slot.endMinuteOfDay).abs() <= 20,
    orElse: () {
      for (final slot in slots) {
        if (normalizedEnd <= slot.endMinuteOfDay) {
          return slot;
        }
      }
      return slots.last;
    },
  );
  if (endSlot.section >= startSlot.section) {
    return PeriodRange(startSlot.section, endSlot.section);
  }
  return PeriodRange(startSlot.section, startSlot.section);
}

LessonTimeSlot? lessonSlotForSection(
  int section, {
  Iterable<LessonTimeSlot> lessonSlots = defaultLessonTimeSlots,
}) {
  for (final slot in lessonSlots) {
    if (slot.section == section) {
      return slot;
    }
  }
  return null;
}

int clampMinuteOfDay(int minute) {
  return minute.clamp(0, minutesPerDay).toInt();
}

List<LessonTimeSlot> _sortedLessonSlots(Iterable<LessonTimeSlot> slots) {
  return [...slots]..sort((a, b) => a.section.compareTo(b.section));
}

bool _rangesOverlap(int startA, int endA, int startB, int endB) {
  return startA < endB && startB < endA;
}
