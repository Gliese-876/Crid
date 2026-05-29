import 'package:flutter/material.dart';
import 'package:material_color_utilities/palettes/tonal_palette.dart';

final courseTextColor = Color(TonalPalette.of(0, 0).get(100));
const minCourseTextContrast = 3.75;
const maxCourseTextContrast = 8.4;
const minCourseColorVisualDistance = .094;
const minCourseSurfaceContrast = 1.75;
const minCourseSurfaceVisualDistance = .16;

const _monetAccentChroma = 58.0;
const _monetBalancedChroma = 46.0;
const _monetVividChroma = 74.0;

const _monetCourseSeeds = <({double hue, double chroma, int tone})>[
  (hue: 6, chroma: _monetBalancedChroma, tone: 54),
  (hue: 34, chroma: _monetAccentChroma, tone: 54),
  (hue: 62, chroma: _monetBalancedChroma, tone: 54),
  (hue: 92, chroma: _monetBalancedChroma, tone: 54),
  (hue: 122, chroma: _monetBalancedChroma, tone: 54),
  (hue: 152, chroma: _monetAccentChroma, tone: 54),
  (hue: 182, chroma: _monetBalancedChroma, tone: 54),
  (hue: 212, chroma: _monetAccentChroma, tone: 54),
  (hue: 218, chroma: _monetVividChroma, tone: 54),
  (hue: 286, chroma: _monetVividChroma, tone: 54),
  (hue: 318, chroma: _monetVividChroma, tone: 54),
  (hue: 332, chroma: _monetAccentChroma, tone: 54),
  (hue: 20, chroma: _monetAccentChroma, tone: 48),
  (hue: 50, chroma: _monetBalancedChroma, tone: 48),
  (hue: 80, chroma: _monetBalancedChroma, tone: 48),
  (hue: 110, chroma: _monetBalancedChroma, tone: 48),
  (hue: 140, chroma: _monetBalancedChroma, tone: 48),
  (hue: 170, chroma: _monetBalancedChroma, tone: 48),
  (hue: 200, chroma: _monetBalancedChroma, tone: 48),
  (hue: 230, chroma: _monetAccentChroma, tone: 48),
  (hue: 310, chroma: _monetVividChroma, tone: 48),
  (hue: 300, chroma: _monetVividChroma, tone: 54),
  (hue: 320, chroma: _monetBalancedChroma, tone: 48),
  (hue: 350, chroma: _monetBalancedChroma, tone: 48),
];

final accessibleCoursePalette = List<Color>.unmodifiable(
  _monetCourseSeeds.map(
    (seed) => Color(TonalPalette.of(seed.hue, seed.chroma).get(seed.tone)),
  ),
);

Map<String, Color> distinctCourseColorsForKeys(Iterable<String> keys) {
  final uniqueKeys = keys.where((key) => key.trim().isNotEmpty).toSet().toList()
    ..sort();
  final paletteIndices = _distinctPaletteIndices(uniqueKeys.length);
  final assigned = <String, Color>{};

  for (var index = 0; index < uniqueKeys.length; index++) {
    assigned[uniqueKeys[index]] =
        accessibleCoursePalette[paletteIndices[index % paletteIndices.length]];
  }

  return Map.unmodifiable(assigned);
}

List<int> _distinctPaletteIndices(int count) {
  if (count <= 0) {
    return const [];
  }

  final targetCount = count.clamp(1, accessibleCoursePalette.length);
  final selected = <int>[0];
  while (selected.length < targetCount) {
    var bestCandidate = 0;
    var bestScore = double.negativeInfinity;

    for (
      var candidate = 0;
      candidate < accessibleCoursePalette.length;
      candidate++
    ) {
      if (selected.contains(candidate)) {
        continue;
      }
      final trial = [...selected, candidate];
      final score =
          _minimumPaletteDistance(trial) +
          _averagePaletteDistance(trial) * .08 -
          candidate * .0001;

      if (score > bestScore) {
        bestScore = score;
        bestCandidate = candidate;
      }
    }
    selected.add(bestCandidate);
  }

  return List.unmodifiable(selected);
}

double _minimumPaletteDistance(List<int> indices) {
  if (indices.length < 2) {
    return 1.0;
  }
  var minimum = double.infinity;
  for (var i = 0; i < indices.length; i++) {
    for (var j = i + 1; j < indices.length; j++) {
      final distance = courseColorVisualDistance(
        accessibleCoursePalette[indices[i]],
        accessibleCoursePalette[indices[j]],
      );
      if (distance < minimum) {
        minimum = distance;
      }
    }
  }
  return minimum;
}

double _averagePaletteDistance(List<int> indices) {
  if (indices.length < 2) {
    return 1.0;
  }
  var total = 0.0;
  var count = 0;
  for (var i = 0; i < indices.length; i++) {
    for (var j = i + 1; j < indices.length; j++) {
      total += courseColorVisualDistance(
        accessibleCoursePalette[indices[i]],
        accessibleCoursePalette[indices[j]],
      );
      count++;
    }
  }
  return total / count;
}

Color courseColorForKey(String key) {
  return courseColorForIndex(_stableHash(key));
}

Color courseColorForIndex(int index) {
  return accessibleCoursePalette[index.abs() % accessibleCoursePalette.length];
}

Color readableCourseTextColor(Color background) {
  return courseTextColor;
}

double courseColorVisualDistance(Color a, Color b) {
  final aHsl = HSLColor.fromColor(a);
  final bHsl = HSLColor.fromColor(b);
  final hueDistance = _hueDistance(aHsl.hue, bHsl.hue) / 180;
  final luminanceDistance =
      (a.computeLuminance() - b.computeLuminance()).abs() * 2.4;
  final saturationDistance = (aHsl.saturation - bHsl.saturation).abs();
  final grayscaleSeparation = luminanceDistance.clamp(0.0, 1.0);
  return hueDistance * .58 +
      grayscaleSeparation * .34 +
      saturationDistance * .08;
}

double contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

int _stableHash(String input) {
  var hash = 0x811C9DC5;
  for (final code in input.codeUnits) {
    hash ^= code;
    hash = (hash * 0x01000193) & 0x7FFFFFFF;
  }
  return hash;
}

double _hueDistance(double a, double b) {
  final direct = (a - b).abs();
  return direct < 360 - direct ? direct : 360 - direct;
}
