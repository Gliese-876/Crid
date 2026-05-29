import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePreferenceKey = 'app_theme_mode';

enum AppThemeMode {
  system,
  light,
  dark;

  ThemeMode get themeMode {
    return switch (this) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };
  }
}

class ThemeController extends AsyncNotifier<AppThemeMode> {
  @override
  Future<AppThemeMode> build() async {
    final preferences = await SharedPreferences.getInstance();
    final rawValue = preferences.getString(_themeModePreferenceKey);
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == rawValue,
      orElse: () => AppThemeMode.system,
    );
  }

  Future<void> setMode(AppThemeMode mode) async {
    final previous = state;
    state = AsyncData(mode);
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_themeModePreferenceKey, mode.name);
    } catch (error, stackTrace) {
      state = previous.hasValue ? previous : AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final themeControllerProvider =
    AsyncNotifierProvider<ThemeController, AppThemeMode>(ThemeController.new);
