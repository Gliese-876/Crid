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

PeriodRange periodRangeFromTime(DateTime start, DateTime end) {
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;
  const slots = <(int, int, int)>[
    (8 * 60, 8 * 60 + 45, 1),
    (8 * 60 + 55, 9 * 60 + 40, 2),
    (10 * 60, 10 * 60 + 45, 3),
    (10 * 60 + 55, 11 * 60 + 40, 4),
    (13 * 60 + 30, 14 * 60 + 15, 5),
    (14 * 60 + 25, 15 * 60 + 10, 6),
    (15 * 60 + 30, 16 * 60 + 15, 7),
    (16 * 60 + 25, 17 * 60 + 10, 8),
    (18 * 60, 18 * 60 + 45, 9),
    (18 * 60 + 55, 19 * 60 + 40, 10),
    (19 * 60 + 50, 20 * 60 + 35, 11),
    (20 * 60 + 45, 21 * 60 + 30, 12),
  ];

  final startSlot = slots.firstWhere(
    (slot) => (startMinutes - slot.$1).abs() <= 20,
    orElse: () => slots.lastWhere(
      (slot) => startMinutes >= slot.$1,
      orElse: () => slots.first,
    ),
  );
  final endSlot = slots.firstWhere(
    (slot) => (endMinutes - slot.$2).abs() <= 20,
    orElse: () {
      for (final slot in slots) {
        if (endMinutes <= slot.$2) {
          return slot;
        }
      }
      return slots.last;
    },
  );
  if (endSlot.$3 >= startSlot.$3) {
    return PeriodRange(startSlot.$3, endSlot.$3);
  }
  return PeriodRange(startSlot.$3, startSlot.$3);
}
