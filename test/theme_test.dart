import 'package:crid/app/motion.dart';
import 'package:crid/app/theme.dart';
import 'package:crid/core/theme/course_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('card blocks contrast with the page background', () {
    final blockContrasts = <Brightness, double>{};
    for (final brightness in Brightness.values) {
      final theme = buildAppTheme(brightness);
      final cardColor = theme.cardTheme.color;

      expect(cardColor, isNotNull);
      final blockContrast = contrastRatio(
        cardColor!,
        theme.scaffoldBackgroundColor,
      );
      blockContrasts[brightness] = blockContrast;

      expect(
        blockContrast,
        greaterThanOrEqualTo(1.08),
        reason:
            'Card blocks should still stand apart from $brightness background.',
      );
      expect(
        blockContrast,
        lessThanOrEqualTo(1.45),
        reason:
            'Card blocks should avoid an overly heavy $brightness contrast.',
      );
    }

    expect(
      (blockContrasts[Brightness.light]! - blockContrasts[Brightness.dark]!)
          .abs(),
      lessThanOrEqualTo(0.24),
      reason: 'Light and dark block depth should feel like paired themes.',
    );
  });

  test('light and dark modes use matching expressive component roles', () {
    for (final brightness in Brightness.values) {
      final theme = buildAppTheme(brightness);
      final colorScheme = theme.colorScheme;

      expect(theme.scaffoldBackgroundColor, colorScheme.surfaceContainerLowest);
      expect(
        theme.appBarTheme.backgroundColor,
        colorScheme.surfaceContainerLowest,
      );
      expect(theme.cardTheme.color, colorScheme.surfaceContainerHigh);
      expect(
        theme.inputDecorationTheme.fillColor,
        colorScheme.surfaceContainerLow,
      );
      expect(
        theme.navigationBarTheme.backgroundColor,
        colorScheme.surfaceContainerLow,
      );
      expect(
        theme.navigationRailTheme.backgroundColor,
        colorScheme.surfaceContainerLow,
      );
      expect(
        theme.floatingActionButtonTheme.backgroundColor,
        colorScheme.tertiaryContainer,
      );
      expect(
        theme.floatingActionButtonTheme.foregroundColor,
        colorScheme.onTertiaryContainer,
      );
    }
  });

  test('uses expressive Material 3 corners for block surfaces', () {
    final theme = buildAppTheme(Brightness.light);
    final cardShape = theme.cardTheme.shape;
    final inputBorder = theme.inputDecorationTheme.border;
    final popupMenuShape = theme.popupMenuTheme.shape;
    final menuPanelShape = theme.menuTheme.style?.shape?.resolve(
      <WidgetState>{},
    );

    expect(cardShape, isA<RoundedRectangleBorder>());
    expect(
      (cardShape! as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(24),
    );
    expect(inputBorder, isA<OutlineInputBorder>());
    expect(
      (inputBorder! as OutlineInputBorder).borderRadius,
      BorderRadius.circular(20),
    );
    expect(popupMenuShape, appMenuPanelShape);
    expect(menuPanelShape, appMenuPanelShape);
  });

  test('uses iOS-style Android route transitions without predictive scrim', () {
    final theme = buildAppTheme(Brightness.light);
    final androidTransition =
        theme.pageTransitionsTheme.builders[TargetPlatform.android];

    expect(androidTransition, isA<CupertinoPageTransitionsBuilder>());
    expect(androidTransition?.transitionDuration, appPageTransitionDuration);
    expect(
      androidTransition?.reverseTransitionDuration,
      appPageReverseTransitionDuration,
    );
    expect(
      androidTransition,
      isNot(isA<PredictiveBackPageTransitionsBuilder>()),
    );
  });

  test('uses medium standard Material motion tokens', () {
    expect(appCoreDestinationMotionDuration, Durations.medium4);
    expect(appPageTransitionDuration, const Duration(milliseconds: 500));
    expect(appPageReverseTransitionDuration, const Duration(milliseconds: 500));
    expect(appMicroMotionCurve, Easing.standardDecelerate);
    expect(appMicroMotionReverseCurve, Easing.standardAccelerate);
    expect(appCoreDestinationMotionCurve, Easing.standard);
    expect(appMenuAnimationStyle.duration, isNull);
    expect(appMenuAnimationStyle.reverseDuration, isNull);
    expect(appMenuAnimationStyle.curve, Easing.standardDecelerate);
    expect(appMenuAnimationStyle.reverseCurve, Easing.standardAccelerate);
  });
}
