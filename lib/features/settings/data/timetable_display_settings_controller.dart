import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const showNonCurrentWeekCoursesPreferenceKey = 'show_non_current_week_courses';

class ShowNonCurrentWeekCoursesController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(showNonCurrentWeekCoursesPreferenceKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final previous = state;
    state = AsyncData(enabled);
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(
        showNonCurrentWeekCoursesPreferenceKey,
        enabled,
      );
    } catch (error, stackTrace) {
      state = previous.hasValue ? previous : AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final showNonCurrentWeekCoursesProvider =
    AsyncNotifierProvider<ShowNonCurrentWeekCoursesController, bool>(
      ShowNonCurrentWeekCoursesController.new,
    );
