import 'package:crypto/crypto.dart';

import '../../../data/database/timetable_time.dart';

const defaultReminderWindowDays = 28;

class ReminderCandidate {
  const ReminderCandidate({
    required this.notificationId,
    required this.sessionId,
    required this.courseId,
    required this.courseName,
    required this.minutesBefore,
    required this.startAt,
    required this.remindAt,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int notificationId;
  final int sessionId;
  final int courseId;
  final String courseName;
  final int minutesBefore;
  final DateTime startAt;
  final DateTime remindAt;
  final String title;
  final String body;
  final String payload;
}

List<ReminderCandidate> buildRollingReminderWindow({
  required Iterable<ClassSessionInfo> sessions,
  required DateTime firstWeekMonday,
  required DateTime now,
  int minutesBefore = 20,
  Iterable<int>? reminderOffsets,
  int windowDays = defaultReminderWindowDays,
  Iterable<LessonSlot> lessonSlots = defaultBnuzLessonSlots,
  String Function(int minutesBefore)? titleForMinutes,
}) {
  final windowEnd = now.add(Duration(days: windowDays));
  final offsets = _normalizedOffsets(reminderOffsets ?? [minutesBefore]);
  final candidates = <ReminderCandidate>[];

  for (final session in sessions) {
    for (final occurrence in expandClassSessionOccurrences(
      session: session,
      firstWeekMonday: firstWeekMonday,
      lessonSlots: lessonSlots,
    )) {
      for (final offset in offsets) {
        final remindAt = occurrence.start.subtract(Duration(minutes: offset));
        if (remindAt.isBefore(now) || remindAt.isAfter(windowEnd)) {
          continue;
        }

        candidates.add(
          ReminderCandidate(
            notificationId: _notificationIdFor(
              session,
              occurrence.start,
              offset,
            ),
            sessionId: session.sessionId,
            courseId: session.courseId,
            courseName: session.courseName,
            minutesBefore: offset,
            startAt: occurrence.start,
            remindAt: remindAt,
            title: titleForMinutes?.call(offset) ?? _fallbackTitle(offset),
            body: _bodyFor(session, occurrence.start),
            payload:
                'class-session:${session.sessionId}:${occurrence.week}:$offset',
          ),
        );
      }
    }
  }

  candidates.sort((a, b) => a.remindAt.compareTo(b.remindAt));
  return candidates;
}

List<int> _normalizedOffsets(Iterable<int> offsets) {
  final result =
      offsets.map((offset) => offset.clamp(0, 1440).toInt()).toSet().toList()
        ..sort();
  return result.isEmpty ? const [20] : result;
}

String _fallbackTitle(int minutesBefore) {
  return '$minutesBefore 分钟后上课';
}

String _bodyFor(ClassSessionInfo session, DateTime start) {
  final startText =
      '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
  final parts = <String>[
    session.courseName,
    startText,
    if (session.location?.isNotEmpty ?? false) session.location!,
    if (session.teacher?.isNotEmpty ?? false) session.teacher!,
  ];
  return parts.join(' - ');
}

int _notificationIdFor(
  ClassSessionInfo session,
  DateTime start,
  int minutesBefore,
) {
  final input =
      '${session.sessionId}|${session.courseId}|${start.toIso8601String()}|$minutesBefore';
  final hex = sha1.convert(input.codeUnits).toString().substring(0, 8);
  return int.parse(hex, radix: 16) & 0x7fffffff;
}
