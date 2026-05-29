import 'package:crid/app/theme.dart';
import 'package:crid/core/theme/course_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('course palette is unique and large enough for timetable scanning', () {
    final uniqueRgbValues = accessibleCoursePalette
        .map((color) => color.toARGB32() & 0x00FFFFFF)
        .toSet();

    expect(accessibleCoursePalette, hasLength(greaterThanOrEqualTo(12)));
    expect(uniqueRgbValues, hasLength(accessibleCoursePalette.length));
  });

  test('course palette keeps white text readable without over-dark blocks', () {
    for (final color in accessibleCoursePalette) {
      final textColor = readableCourseTextColor(color);
      expect(
        textColor,
        courseTextColor,
        reason: 'Course foregrounds should always use white Monet tone.',
      );
      final contrast = contrastRatio(textColor, color);
      expect(
        contrast,
        greaterThanOrEqualTo(minCourseTextContrast),
        reason: 'Course color $color must be readable.',
      );
      expect(
        contrast,
        lessThanOrEqualTo(maxCourseTextContrast),
        reason: 'Course color $color should not be overly dark.',
      );
    }
  });

  test('course palette separates from timetable and app surfaces', () {
    for (final brightness in Brightness.values) {
      final theme = buildAppTheme(brightness);
      final colorScheme = theme.colorScheme;
      final surfaceColors = <String, Color>{
        'app background': theme.scaffoldBackgroundColor,
        'timetable body': theme.cardTheme.color!,
        'timetable header': colorScheme.surfaceContainerHighest,
      };

      for (final (index, courseColor) in accessibleCoursePalette.indexed) {
        for (final entry in surfaceColors.entries) {
          final contrast = contrastRatio(courseColor, entry.value);
          final visualDistance = courseColorVisualDistance(
            courseColor,
            entry.value,
          );

          expect(
            contrast,
            greaterThanOrEqualTo(minCourseSurfaceContrast),
            reason:
                'Course color #$index $courseColor is too close to ${entry.key} '
                '${entry.value} in $brightness mode.',
          );
          expect(
            visualDistance,
            greaterThanOrEqualTo(minCourseSurfaceVisualDistance),
            reason:
                'Course color #$index $courseColor does not visually separate from ${entry.key} '
                '${entry.value} in $brightness mode.',
          );
        }
      }
    }
  });

  test('course color assignment is deterministic', () {
    expect(
      courseColorForKey('linear-algebra'),
      courseColorForKey('linear-algebra'),
    );
    expect(courseColorForIndex(0), accessibleCoursePalette.first);
  });

  test('same-page color assignment keeps nearby courses visually distinct', () {
    final colors = distinctCourseColorsForKeys([
      'advanced mathematics',
      'linear algebra',
      'programming fundamentals',
      'college english',
      'physics lab',
      'data structures',
      'modern history',
      'sports',
      'discrete math',
      'writing seminar',
      'probability',
      'computer networks',
    ]);

    expect(colors.values.toSet(), hasLength(colors.length));
    for (final color in colors.values) {
      expect(accessibleCoursePalette, contains(color));
    }

    final entries = colors.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      for (var j = i + 1; j < entries.length; j++) {
        final distance = courseColorVisualDistance(
          entries[i].value,
          entries[j].value,
        );
        expect(
          distance,
          greaterThanOrEqualTo(minCourseColorVisualDistance),
          reason:
              '${entries[i].key} ${entries[i].value} and '
              '${entries[j].key} ${entries[j].value} are too similar.',
        );
      }
    }
  });
}
