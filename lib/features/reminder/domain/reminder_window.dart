import 'package:crypto/crypto.dart';

import '../../../data/database/timetable_time.dart';

const defaultReminderWindowDays = 28;

class ReminderCandidate {
  const ReminderCandidate({
    required this.notificationId,
    required this.sessionId,
    required this.courseId,
    required this.courseName,
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
  int windowDays = defaultReminderWindowDays,
  Iterable<LessonSlot> lessonSlots = defaultBnuzLessonSlots,
  String Function(int minutesBefore)? titleForMinutes,
}) {
  final windowEnd = now.add(Duration(days: windowDays));
  final candidates = <ReminderCandidate>[];

  for (final session in sessions) {
    for (final occurrence in expandClassSessionOccurrences(
      session: session,
      firstWeekMonday: firstWeekMonday,
      lessonSlots: lessonSlots,
    )) {
      final remindAt = occurrence.start.subtract(
        Duration(minutes: minutesBefore),
      );
      if (remindAt.isBefore(now) || remindAt.isAfter(windowEnd)) {
        continue;
      }

      candidates.add(
        ReminderCandidate(
          notificationId: _notificationIdFor(session, occurrence.start),
          sessionId: session.sessionId,
          courseId: session.courseId,
          courseName: session.courseName,
          startAt: occurrence.start,
          remindAt: remindAt,
          title:
              titleForMinutes?.call(minutesBefore) ??
              _fallbackTitle(minutesBefore),
          body: _bodyFor(session, occurrence.start),
          payload: 'class-session:${session.sessionId}:${occurrence.week}',
        ),
      );
    }
  }

  candidates.sort((a, b) => a.remindAt.compareTo(b.remindAt));
  return candidates;
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

int _notificationIdFor(ClassSessionInfo session, DateTime start) {
  final input =
      '${session.sessionId}|${session.courseId}|${start.toIso8601String()}';
  final hex = sha1.convert(input.codeUnits).toString().substring(0, 8);
  return int.parse(hex, radix: 16) & 0x7fffffff;
}
