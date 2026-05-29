import 'package:collection/collection.dart';

enum WeekParity { all, odd, even }

class WeekPattern {
  WeekPattern(Iterable<int> weeks, {this.parity = WeekParity.all})
    : weeks = List.unmodifiable((weeks.toSet().toList()..sort()));

  factory WeekPattern.range(
    int start,
    int end, {
    WeekParity parity = WeekParity.all,
  }) {
    final lower = start <= end ? start : end;
    final upper = start <= end ? end : start;
    return WeekPattern([
      for (var week = lower; week <= upper; week++)
        if (_matchesParity(week, parity)) week,
    ], parity: parity);
  }

  factory WeekPattern.single(int week) => WeekPattern([week]);

  factory WeekPattern.parse(String input, {int defaultMaxWeek = 20}) {
    final normalized = normalizeWeekText(input);
    var parity = WeekParity.all;
    if (normalized.contains('单周') || normalized.contains('单')) {
      parity = WeekParity.odd;
    } else if (normalized.contains('双周') || normalized.contains('双')) {
      parity = WeekParity.even;
    }

    final weeks = <int>{};
    final rangePattern = RegExp(r'(\d{1,2})(?:[-~至到](\d{1,2}))?');
    for (final match in rangePattern.allMatches(normalized)) {
      final start = int.parse(match.group(1)!);
      final end = int.parse(match.group(2) ?? match.group(1)!);
      for (var week = start; week <= end; week++) {
        if (_matchesParity(week, parity)) {
          weeks.add(week);
        }
      }
    }

    if (weeks.isEmpty && parity != WeekParity.all) {
      for (var week = 1; week <= defaultMaxWeek; week++) {
        if (_matchesParity(week, parity)) {
          weeks.add(week);
        }
      }
    }

    return WeekPattern(weeks, parity: parity);
  }

  final List<int> weeks;
  final WeekParity parity;

  bool contains(int week) => weeks.contains(week);

  bool overlaps(WeekPattern other) => weeks.any(other.weeks.contains);

  String get normalizedKey => weeks.join(',');

  @override
  String toString() => normalizedKey;

  @override
  bool operator ==(Object other) =>
      other is WeekPattern &&
      parity == other.parity &&
      const ListEquality<int>().equals(weeks, other.weeks);

  @override
  int get hashCode =>
      Object.hash(parity, const ListEquality<int>().hash(weeks));

  static bool _matchesParity(int week, WeekParity parity) {
    return switch (parity) {
      WeekParity.all => true,
      WeekParity.odd => week.isOdd,
      WeekParity.even => week.isEven,
    };
  }
}

String normalizeWeekText(String input) {
  const fullWidthDigits = '０１２３４５６７８９';
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    final digitIndex = fullWidthDigits.indexOf(char);
    if (digitIndex >= 0) {
      buffer.write(digitIndex);
      continue;
    }
    buffer.write(switch (char) {
      '－' || '—' || '–' || '～' || '~' => '-',
      '，' || '、' || ';' || '；' => ',',
      '（' => '(',
      '）' => ')',
      '\u3000' => '',
      _ => char,
    });
  }
  return buffer
      .toString()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll('星期', '周')
      .replaceAll('第', '')
      .replaceAll('周周', '周');
}
