import 'package:collection/collection.dart';

import 'parsed_timetable.dart';

enum MergeDiffField { teacher, location, weeks, periods }

class CourseDiff {
  const CourseDiff({
    required this.existing,
    required this.incoming,
    required this.changedFields,
  });

  final ParsedCourse existing;
  final ParsedCourse incoming;
  final List<MergeDiffField> changedFields;
}

class MergeConflict {
  const MergeConflict({
    required this.existing,
    required this.incoming,
    required this.reason,
  });

  final ParsedCourse existing;
  final ParsedCourse incoming;
  final String reason;
}

class MergeResult {
  const MergeResult({
    required this.added,
    required this.skipped,
    required this.diffs,
    required this.conflicts,
  });

  final List<ParsedCourse> added;
  final List<ParsedCourse> skipped;
  final List<CourseDiff> diffs;
  final List<MergeConflict> conflicts;
}

class TimetableMergeEngine {
  const TimetableMergeEngine();

  MergeResult merge({
    required List<ParsedCourse> existing,
    required List<ParsedCourse> incoming,
  }) {
    final existingCourses = List<ParsedCourse>.unmodifiable(existing);
    final occupiedCourses = [...existingCourses];
    final seenFingerprints = existingCourses
        .map((course) => course.sourceFingerprint)
        .toSet();
    final added = <ParsedCourse>[];
    final skipped = <ParsedCourse>[];
    final diffs = <CourseDiff>[];
    final conflicts = <MergeConflict>[];

    for (final incomingCourse in incoming) {
      if (seenFingerprints.contains(incomingCourse.sourceFingerprint)) {
        skipped.add(incomingCourse);
        continue;
      }
      seenFingerprints.add(incomingCourse.sourceFingerprint);

      final sameCourseSlot = existingCourses.firstWhereOrNull(
        (course) => _sameCourseSlot(course, incomingCourse),
      );
      if (sameCourseSlot != null) {
        final changedFields = _changedFields(sameCourseSlot, incomingCourse);
        if (changedFields.isNotEmpty) {
          diffs.add(
            CourseDiff(
              existing: sameCourseSlot,
              incoming: incomingCourse,
              changedFields: changedFields,
            ),
          );
        }
        continue;
      }

      final overlap = occupiedCourses.firstWhereOrNull(
        (course) =>
            course.identityKey != incomingCourse.identityKey &&
            course.overlapsInTime(incomingCourse),
      );
      if (overlap != null) {
        conflicts.add(
          MergeConflict(
            existing: overlap,
            incoming: incomingCourse,
            reason: 'Time overlap with a different course.',
          ),
        );
        continue;
      }

      added.add(incomingCourse);
      occupiedCourses.add(incomingCourse);
    }

    return MergeResult(
      added: List.unmodifiable(added),
      skipped: List.unmodifiable(skipped),
      diffs: List.unmodifiable(diffs),
      conflicts: List.unmodifiable(conflicts),
    );
  }

  bool _sameCourseSlot(ParsedCourse existing, ParsedCourse incoming) {
    return existing.identityKey == incoming.identityKey &&
        existing.weekday == incoming.weekday &&
        existing.period == incoming.period;
  }

  List<MergeDiffField> _changedFields(
    ParsedCourse existing,
    ParsedCourse incoming,
  ) {
    final fields = <MergeDiffField>[];
    if (normalizeCourseText(existing.teacher) !=
        normalizeCourseText(incoming.teacher)) {
      fields.add(MergeDiffField.teacher);
    }
    if (normalizeCourseText(existing.location) !=
        normalizeCourseText(incoming.location)) {
      fields.add(MergeDiffField.location);
    }
    if (existing.weeks != incoming.weeks) {
      fields.add(MergeDiffField.weeks);
    }
    if (existing.period != incoming.period ||
        existing.weekday != incoming.weekday) {
      fields.add(MergeDiffField.periods);
    }
    return fields;
  }
}
