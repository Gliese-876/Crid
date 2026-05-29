import 'package:crid/app/motion.dart';
import 'package:flutter/material.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final generatedScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF4D73FF),
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.expressive,
    contrastLevel: brightness == Brightness.light ? 0.08 : 0.2,
  );
  final colorScheme = _expressiveSurfaceScheme(generatedScheme);
  final blockBackgroundColor = colorScheme.surfaceContainerHigh;
  final capsuleColor = _containerAccent(
    colorScheme.surfaceContainerHighest,
    colorScheme.secondaryContainer,
    brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surfaceContainerLowest,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: blockBackgroundColor,
      elevation: 0,
      surfaceTintColor: colorScheme.primary.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorColor: _containerAccent(
        colorScheme.secondaryContainer,
        colorScheme.tertiaryContainer,
        brightness,
      ),
      indicatorShape: const StadiumBorder(),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorColor: colorScheme.secondaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
      selectedLabelTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: const Size(48, 44),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        minimumSize: const Size(48, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: const StadiumBorder(),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.tertiaryContainer,
      foregroundColor: colorScheme.onTertiaryContainer,
      shape: const StadiumBorder(),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        minimumSize: const Size(48, 44),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: const StadiumBorder(),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.36)),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
        hoverColor: colorScheme.primary.withValues(alpha: 0.08),
        focusColor: colorScheme.primary.withValues(alpha: 0.10),
        highlightColor: colorScheme.primary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colorScheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shape: appMenuPanelShape,
      menuPadding: const EdgeInsets.symmetric(vertical: 8),
      position: PopupMenuPosition.under,
    ),
    menuTheme: MenuThemeData(style: _menuPanelStyle(colorScheme)),
    menuBarTheme: MenuBarThemeData(style: _menuPanelStyle(colorScheme)),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: _menuPanelStyle(colorScheme),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerLow;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant;
        }),
        side: WidgetStatePropertyAll(
          BorderSide(color: colorScheme.outlineVariant),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.primaryContainer,
      thumbColor: colorScheme.primary,
      overlayColor: colorScheme.primary.withValues(alpha: 0.12),
      trackHeight: 6,
    ),
    switchTheme: SwitchThemeData(
      thumbIcon: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Icon(Icons.check, size: 16);
        }
        return null;
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: capsuleColor,
      selectedColor: colorScheme.primaryContainer,
      side: BorderSide(
        color: colorScheme.outlineVariant.withValues(alpha: .72),
      ),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      secondaryLabelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
    ),
    dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
    listTileTheme: ListTileThemeData(
      iconColor: colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.primaryContainer.withValues(alpha: 0.44),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}

MenuStyle _menuPanelStyle(ColorScheme colorScheme) {
  return MenuStyle(
    backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    elevation: const WidgetStatePropertyAll(3),
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 8)),
    shape: const WidgetStatePropertyAll(appMenuPanelShape),
  );
}

ColorScheme _expressiveSurfaceScheme(ColorScheme scheme) {
  return scheme.copyWith(
    surfaceContainerLowest: _pairedSurface(
      scheme.surfaceContainerLowest,
      scheme.primaryContainer,
      scheme.brightness,
      tint: 0.05,
      lightLift: 0.30,
      darkSink: 0.034,
    ),
    surfaceContainerLow: _pairedSurface(
      scheme.surfaceContainerLow,
      scheme.secondaryContainer,
      scheme.brightness,
      tint: 0.06,
      lightLift: 0.28,
      darkSink: 0.038,
    ),
    surfaceContainer: _pairedSurface(
      scheme.surfaceContainer,
      scheme.tertiaryContainer,
      scheme.brightness,
      tint: 0.07,
      lightLift: 0.26,
      darkSink: 0.042,
    ),
    surfaceContainerHigh: _pairedSurface(
      scheme.surfaceContainerHigh,
      scheme.primaryContainer,
      scheme.brightness,
      tint: 0.08,
      lightLift: 0.24,
      darkSink: 0.056,
    ),
    surfaceContainerHighest: _pairedSurface(
      scheme.surfaceContainerHighest,
      scheme.secondaryContainer,
      scheme.brightness,
      tint: 0.10,
      lightLift: 0.22,
      darkSink: 0.066,
    ),
  );
}

Color _containerAccent(Color base, Color accent, Brightness brightness) {
  final mixed = Color.alphaBlend(accent.withValues(alpha: 0.18), base);
  return brightness == Brightness.light
      ? Color.lerp(mixed, Colors.white, 0.04)!
      : Color.lerp(mixed, Colors.black, 0.04)!;
}

Color _pairedSurface(
  Color surface,
  Color accent,
  Brightness brightness, {
  required double tint,
  required double lightLift,
  required double darkSink,
}) {
  final tinted = _blendSurface(surface, accent, amount: tint);
  return brightness == Brightness.light
      ? Color.lerp(tinted, Colors.white, lightLift)!
      : Color.lerp(tinted, Colors.black, darkSink)!;
}

Color _blendSurface(Color surface, Color accent, {double amount = 0.06}) {
  return Color.alphaBlend(accent.withValues(alpha: amount), surface);
}
