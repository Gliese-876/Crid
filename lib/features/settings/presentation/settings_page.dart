import 'package:crid/app/locale_controller.dart';
import 'package:crid/app/app_state.dart';
import 'package:crid/app/motion.dart';
import 'package:crid/app/theme_controller.dart';
import 'package:crid/features/settings/data/android_background_service.dart';
import 'package:crid/features/settings/data/china_holiday_service.dart';
import 'package:crid/features/settings/data/holiday_settings_controller.dart';
import 'package:crid/features/timetable/data/timetable_repository.dart';
import 'package:crid/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _currentAppVersion = '1.0.0-release';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(reminderSettingsProvider);
    final localeMode = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final androidBackgroundStatus = ref.watch(
      androidBackgroundRuntimeControllerProvider,
    );
    final holidaySettings = ref.watch(holidaySettingsProvider);
    final holidaySchedule = ref.watch(
      chinaHolidayScheduleProvider(DateTime.now().year),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        settings.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stackTrace) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.failedToLoadReminderSettings(error)),
            ),
          ),
          data: (value) => _ReminderCard(settings: value),
        ),
        const SizedBox(height: 12),
        _AndroidBackgroundCard(status: androidBackgroundStatus),
        const SizedBox(height: 12),
        localeMode.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stackTrace) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.failedToLoadLanguageSetting(error)),
            ),
          ),
          data: (value) => _LanguageCard(mode: value),
        ),
        const SizedBox(height: 12),
        holidaySettings.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stackTrace) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.failedToLoadHolidaySettings(error)),
            ),
          ),
          data: (value) =>
              _HolidayModeCard(settings: value, schedule: holidaySchedule),
        ),
        const SizedBox(height: 12),
        themeMode.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stackTrace) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.failedToLoadThemeSetting(error)),
            ),
          ),
          data: (value) => _ThemeModeCard(mode: value),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.balance_outlined),
                  title: Text(context.l10n.thirdPartyLicenses),
                  subtitle: Text(context.l10n.thirdPartyLicensesSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: context.l10n.appTitle,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.storage_outlined),
                  title: Text(context.l10n.localData),
                  subtitle: Text(context.l10n.localDataSubtitle),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline),
                  title: Text(context.l10n.appTitle),
                  subtitle: const Text(_currentAppVersion),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AndroidBackgroundCard extends StatelessWidget {
  const _AndroidBackgroundCard({required this.status});

  final AsyncValue<AndroidBackgroundStatus> status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.androidBackgroundSettings,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.androidBackgroundSettingsSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            status.when(
              loading: () => const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.android_outlined),
                title: LinearProgressIndicator(),
              ),
              error: (error, stackTrace) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.error_outline),
                title: Text(context.l10n.androidBackgroundSettings),
                subtitle: Text(
                  context.l10n.failedToLoadAndroidBackgroundStatus(error),
                ),
              ),
              data: (value) => _AndroidBackgroundSection(status: value),
            ),
          ],
        ),
      ),
    );
  }
}

class _AndroidBackgroundSection extends ConsumerWidget {
  const _AndroidBackgroundSection({required this.status});

  final AndroidBackgroundStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!status.available) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.android_outlined),
        title: Text(context.l10n.androidBackgroundSettings),
        subtitle: Text(context.l10n.androidBackgroundUnsupported),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: status.persistentBackgroundEnabled,
          onChanged: (value) => ref
              .read(androidBackgroundRuntimeControllerProvider.notifier)
              .setEnabled(value),
          title: Text(context.l10n.persistentBackgroundRuntime),
          subtitle: Text(
            status.batteryOptimizationIgnored
                ? context.l10n.persistentBackgroundRuntimeAllowed
                : context.l10n.persistentBackgroundRuntimeSubtitle,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => ref
                  .read(androidBackgroundServiceProvider)
                  .openBatterySettings(),
              icon: const Icon(Icons.battery_saver_outlined),
              label: Text(context.l10n.openBatterySettings),
            ),
            OutlinedButton.icon(
              onPressed: () => ref
                  .read(androidBackgroundServiceProvider)
                  .openAutoStartSettings(),
              icon: const Icon(Icons.power_settings_new_outlined),
              label: Text(context.l10n.openAutostartSettings),
            ),
            if (!status.batteryOptimizationIgnored)
              OutlinedButton.icon(
                onPressed: () => ref
                    .read(androidBackgroundServiceProvider)
                    .requestIgnoreBatteryOptimizations(),
                icon: const Icon(Icons.task_alt_outlined),
                label: Text(context.l10n.requestBatteryExemption),
              ),
          ],
        ),
      ],
    );
  }
}

class _ThemeModeCard extends ConsumerWidget {
  const _ThemeModeCard({required this.mode});

  final AppThemeMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.display,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            RadioGroup<AppThemeMode>(
              groupValue: mode,
              onChanged: (value) => _setMode(ref, value),
              child: Column(
                children: [
                  RadioListTile<AppThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    value: AppThemeMode.system,
                    title: Text(context.l10n.themeModeSystem),
                  ),
                  RadioListTile<AppThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    value: AppThemeMode.light,
                    title: Text(context.l10n.themeModeLight),
                  ),
                  RadioListTile<AppThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    value: AppThemeMode.dark,
                    title: Text(context.l10n.themeModeDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setMode(WidgetRef ref, AppThemeMode? value) {
    if (value == null || value == mode) {
      return;
    }
    ref.read(themeControllerProvider.notifier).setMode(value);
  }
}

class _HolidayModeCard extends ConsumerWidget {
  const _HolidayModeCard({required this.settings, required this.schedule});

  final HolidaySettings settings;
  final AsyncValue<ChinaHolidaySchedule> schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentYear = DateTime.now().year;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.holidayMode,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              _scheduleStatus(context, schedule, currentYear),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: settings.hideLegalHolidays,
              onChanged: (value) =>
                  _save(ref, settings.copyWith(hideLegalHolidays: value)),
              title: Text(context.l10n.legalHolidays),
              subtitle: Text(context.l10n.legalHolidaysSubtitle),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: settings.hideLegalHolidays,
              title: Text(context.l10n.holidayAdjustment),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _HolidayAdjustmentMenu(
                  enabled: settings.hideLegalHolidays,
                  value: settings.adjustmentMode,
                  onSelected: (value) =>
                      _save(ref, settings.copyWith(adjustmentMode: value)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(WidgetRef ref, HolidaySettings settings) {
    return ref.read(holidaySettingsProvider.notifier).saveSettings(settings);
  }
}

class _HolidayAdjustmentMenu extends StatefulWidget {
  const _HolidayAdjustmentMenu({
    required this.enabled,
    required this.value,
    required this.onSelected,
  });

  final bool enabled;
  final HolidayAdjustmentMode value;
  final ValueChanged<HolidayAdjustmentMode> onSelected;

  @override
  State<_HolidayAdjustmentMenu> createState() => _HolidayAdjustmentMenuState();
}

class _HolidayAdjustmentMenuState extends State<_HolidayAdjustmentMenu> {
  var _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLabel = _adjustmentModeLabel(context, widget.value);
    final disabledColor = colorScheme.onSurface.withValues(alpha: 0.38);

    final trigger = Semantics(
      button: true,
      enabled: widget.enabled,
      value: currentLabel,
      child: AnimatedContainer(
        duration: appMicroMotionDuration,
        curve: appMicroMotionCurve,
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.enabled
              ? colorScheme.surfaceContainerLow
              : colorScheme.surfaceContainerLow.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _menuOpen
                ? colorScheme.primary.withValues(alpha: 0.72)
                : widget.enabled
                ? colorScheme.outlineVariant
                : colorScheme.outlineVariant.withValues(alpha: 0.48),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_repeat_outlined,
              color: widget.enabled ? colorScheme.primary : disabledColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                currentLabel,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: widget.enabled ? colorScheme.onSurface : disabledColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: _menuOpen ? 0.5 : 0,
              duration: appMicroMotionDuration,
              curve: appMicroMotionCurve,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: widget.enabled
                    ? colorScheme.onSurfaceVariant
                    : disabledColor,
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final menuWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth.clamp(280.0, double.infinity).toDouble()
                : 280.0;
            return PopupMenuButton<HolidayAdjustmentMode>(
              enabled: widget.enabled,
              tooltip: MaterialLocalizations.of(context).showMenuTooltip,
              borderRadius: appMenuItemBorderRadius,
              position: PopupMenuPosition.under,
              offset: const Offset(0, 8),
              shape: appMenuPanelShape,
              constraints: BoxConstraints(
                minWidth: menuWidth,
                maxWidth: menuWidth,
              ),
              clipBehavior: Clip.antiAlias,
              popUpAnimationStyle: appMenuAnimationStyle,
              onOpened: () {
                setState(() {
                  _menuOpen = true;
                });
              },
              onCanceled: () {
                setState(() {
                  _menuOpen = false;
                });
              },
              onSelected: (mode) {
                setState(() {
                  _menuOpen = false;
                });
                widget.onSelected(mode);
              },
              itemBuilder: (context) => [
                for (final mode in HolidayAdjustmentMode.values)
                  _HolidayAdjustmentMenuItem(
                    value: mode,
                    selected: mode == widget.value,
                    label: _adjustmentModeLabel(context, mode),
                  ),
              ],
              child: trigger,
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.holidayAdjustmentSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: widget.enabled
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _HolidayAdjustmentMenuItem extends PopupMenuEntry<HolidayAdjustmentMode> {
  const _HolidayAdjustmentMenuItem({
    required this.value,
    required this.selected,
    required this.label,
  });

  final HolidayAdjustmentMode value;
  final bool selected;
  final String label;

  @override
  double get height => 52;

  @override
  bool represents(HolidayAdjustmentMode? value) {
    return value == this.value;
  }

  @override
  State<_HolidayAdjustmentMenuItem> createState() =>
      _HolidayAdjustmentMenuItemState();
}

class _HolidayAdjustmentMenuItemState
    extends State<_HolidayAdjustmentMenuItem> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = widget.selected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: widget.selected
            ? colorScheme.secondaryContainer
            : Colors.transparent,
        shape: const RoundedSuperellipseBorder(
          borderRadius: appMenuItemBorderRadius,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const RoundedSuperellipseBorder(
            borderRadius: appMenuItemBorderRadius,
          ),
          onTap: () => Navigator.of(context).pop(widget.value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                widget.selected
                    ? Icon(Icons.check_rounded, color: foregroundColor)
                    : const SizedBox(width: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: widget.selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _scheduleStatus(
  BuildContext context,
  AsyncValue<ChinaHolidaySchedule> schedule,
  int year,
) {
  return schedule.when(
    loading: () => context.l10n.holidayDataLoading(year),
    error: (error, stackTrace) => context.l10n.holidayDataFailed,
    data: (value) {
      if (value.legalHolidayDates.isEmpty &&
          value.adjustedRestDates.isEmpty &&
          value.makeUpWorkdayDates.isEmpty) {
        return context.l10n.holidayDataUnavailable(year);
      }
      return value.fromCache
          ? context.l10n.holidayDataCached(year)
          : context.l10n.holidayDataUpdated(year);
    },
  );
}

String _adjustmentModeLabel(BuildContext context, HolidayAdjustmentMode mode) {
  return switch (mode) {
    HolidayAdjustmentMode.noAdjustment =>
      context.l10n.holidayAdjustmentNoAdjustment,
    HolidayAdjustmentMode.makeUpWorkdays =>
      context.l10n.holidayAdjustmentMakeUpWorkdays,
    HolidayAdjustmentMode.noMakeUpWorkdays =>
      context.l10n.holidayAdjustmentNoMakeUpWorkdays,
  };
}

class _LanguageCard extends ConsumerWidget {
  const _LanguageCard({required this.mode});

  final AppLocaleMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.language,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            RadioGroup<AppLocaleMode>(
              groupValue: mode,
              onChanged: (value) => _setMode(ref, value),
              child: Column(
                children: [
                  RadioListTile<AppLocaleMode>(
                    contentPadding: EdgeInsets.zero,
                    value: AppLocaleMode.system,
                    title: Text(context.l10n.languageSystem),
                  ),
                  RadioListTile<AppLocaleMode>(
                    contentPadding: EdgeInsets.zero,
                    value: AppLocaleMode.simplifiedChinese,
                    title: Text(context.l10n.languageSimplifiedChinese),
                  ),
                  RadioListTile<AppLocaleMode>(
                    contentPadding: EdgeInsets.zero,
                    value: AppLocaleMode.traditionalChinese,
                    title: Text(context.l10n.languageTraditionalChinese),
                  ),
                  RadioListTile<AppLocaleMode>(
                    contentPadding: EdgeInsets.zero,
                    value: AppLocaleMode.english,
                    title: Text(context.l10n.languageEnglish),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setMode(WidgetRef ref, AppLocaleMode? value) {
    if (value == null || value == mode) {
      return;
    }
    ref.read(localeControllerProvider.notifier).setMode(value);
  }
}

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard({required this.settings});

  final ReminderSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.reminders,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: settings.enabled,
              onChanged: (value) =>
                  _save(ref, settings.copyWith(enabled: value)),
              title: Text(context.l10n.courseReminders),
              subtitle: Text(context.l10n.courseRemindersSubtitle),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.leadTime,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Slider(
                          value: settings.minutesBefore.toDouble(),
                          min: 5,
                          max: 60,
                          divisions: 11,
                          label: context.l10n.minutesShort(
                            settings.minutesBefore,
                          ),
                          onChanged: settings.enabled
                              ? (value) => _save(
                                  ref,
                                  settings.copyWith(
                                    minutesBefore: value.round(),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 72,
                        child: Text(
                          context.l10n.minutesShort(settings.minutesBefore),
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(WidgetRef ref, ReminderSettings settings) {
    return ref
        .read(timetableControllerProvider.notifier)
        .updateReminderSettings(settings);
  }
}

extension on ReminderSettings {
  ReminderSettings copyWith({bool? enabled, int? minutesBefore}) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      minutesBefore: minutesBefore ?? this.minutesBefore,
    );
  }
}
