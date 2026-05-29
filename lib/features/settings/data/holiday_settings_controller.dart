import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'china_holiday_service.dart';

const _hideLegalHolidaysKey = 'holiday_hide_legal_holidays';
const _adjustmentModeKey = 'holiday_adjustment_mode';

final chinaHolidayServiceProvider = Provider<ChinaHolidayService>((ref) {
  return const ChinaHolidayService();
});

final holidaySettingsProvider =
    AsyncNotifierProvider<HolidaySettingsController, HolidaySettings>(
      HolidaySettingsController.new,
    );

final chinaHolidayScheduleProvider =
    FutureProvider.family<ChinaHolidaySchedule, int>((ref, year) {
      return ref.watch(chinaHolidayServiceProvider).loadYear(year);
    });

class HolidaySettingsController extends AsyncNotifier<HolidaySettings> {
  @override
  Future<HolidaySettings> build() async {
    final preferences = await SharedPreferences.getInstance();
    final rawMode = preferences.getString(_adjustmentModeKey);
    return HolidaySettings(
      hideLegalHolidays:
          preferences.getBool(_hideLegalHolidaysKey) ??
          HolidaySettings.defaults.hideLegalHolidays,
      adjustmentMode: HolidayAdjustmentMode.values.firstWhere(
        (mode) => mode.name == rawMode,
        orElse: () => HolidaySettings.defaults.adjustmentMode,
      ),
    );
  }

  Future<void> saveSettings(HolidaySettings settings) async {
    state = AsyncData(settings);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
      _hideLegalHolidaysKey,
      settings.hideLegalHolidays,
    );
    await preferences.setString(
      _adjustmentModeKey,
      settings.adjustmentMode.name,
    );
  }
}
