import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeModePreferenceKey = 'app_locale_mode';

enum AppLocaleMode {
  system,
  simplifiedChinese,
  traditionalChinese,
  english;

  Locale? get locale {
    return switch (this) {
      AppLocaleMode.system => null,
      AppLocaleMode.simplifiedChinese => const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
      ),
      AppLocaleMode.traditionalChinese => const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
      ),
      AppLocaleMode.english => const Locale('en'),
    };
  }
}

class LocaleController extends AsyncNotifier<AppLocaleMode> {
  @override
  Future<AppLocaleMode> build() async {
    final preferences = await SharedPreferences.getInstance();
    final rawValue = preferences.getString(_localeModePreferenceKey);
    return AppLocaleMode.values.firstWhere(
      (mode) => mode.name == rawValue,
      orElse: () => AppLocaleMode.system,
    );
  }

  Future<void> setMode(AppLocaleMode mode) async {
    final previous = state;
    state = AsyncData(mode);
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_localeModePreferenceKey, mode.name);
    } catch (error, stackTrace) {
      state = previous.hasValue ? previous : AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final localeControllerProvider =
    AsyncNotifierProvider<LocaleController, AppLocaleMode>(
      LocaleController.new,
    );

final reminderNotificationTitleProvider =
    NotifierProvider<ReminderNotificationTitleController, String Function(int)>(
      ReminderNotificationTitleController.new,
    );

class ReminderNotificationTitleController
    extends Notifier<String Function(int)> {
  @override
  String Function(int minutesBefore) build() {
    return (minutesBefore) => '$minutesBefore 分钟后上课';
  }

  void setTitleBuilder(String Function(int minutesBefore) builder) {
    state = builder;
  }
}

Locale? localeForMode(AppLocaleMode mode) => mode.locale;
