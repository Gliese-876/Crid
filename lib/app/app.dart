import 'dart:async';

import 'package:crid/app/locale_controller.dart';
import 'package:crid/app/router.dart';
import 'package:crid/app/app_state.dart';
import 'package:crid/app/theme.dart';
import 'package:crid/app/theme_controller.dart';
import 'package:crid/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CridApp extends ConsumerWidget {
  const CridApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final localeMode =
        ref.watch(localeControllerProvider).asData?.value ??
        AppLocaleMode.system;
    final themeMode =
        ref.watch(themeControllerProvider).asData?.value ?? AppThemeMode.system;

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: themeMode.themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeForMode(localeMode),
      localeListResolutionCallback: _resolveLocale,
      routerConfig: router,
      builder: (context, child) => _ReminderLifecycleSync(
        child: _GeneratedSemesterNameSync(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _ReminderLifecycleSync extends ConsumerStatefulWidget {
  const _ReminderLifecycleSync({required this.child});

  final Widget child;

  @override
  ConsumerState<_ReminderLifecycleSync> createState() =>
      _ReminderLifecycleSyncState();
}

class _ReminderLifecycleSyncState extends ConsumerState<_ReminderLifecycleSync>
    with WidgetsBindingObserver {
  static const _resumeRebuildCooldown = Duration(minutes: 5);

  DateTime? _lastResumeRebuildAt;
  var _rebuildInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _rebuildRemindersAfterResume();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _rebuildRemindersAfterResume() {
    final now = DateTime.now();
    final lastRebuildAt = _lastResumeRebuildAt;
    if (lastRebuildAt != null &&
        now.difference(lastRebuildAt) < _resumeRebuildCooldown) {
      return;
    }
    if (_rebuildInFlight) {
      return;
    }
    _lastResumeRebuildAt = now;
    _rebuildInFlight = true;
    unawaited(_rebuildRemindersWhenReady());
  }

  Future<void> _rebuildRemindersWhenReady() async {
    try {
      await ref.read(timetableControllerProvider.future);
      if (!mounted) {
        return;
      }
      await ref.read(timetableControllerProvider.notifier).rebuildReminders();
    } on Object {
      // Returning from Android settings should never break the visible app.
    } finally {
      _rebuildInFlight = false;
    }
  }
}

class _GeneratedSemesterNameSync extends ConsumerStatefulWidget {
  const _GeneratedSemesterNameSync({required this.child});

  final Widget child;

  @override
  ConsumerState<_GeneratedSemesterNameSync> createState() =>
      _GeneratedSemesterNameSyncState();
}

class _GeneratedSemesterNameSyncState
    extends ConsumerState<_GeneratedSemesterNameSync> {
  String? _lastLocaleTag;

  @override
  Widget build(BuildContext context) {
    final localeTag = Localizations.localeOf(context).toString();
    if (_lastLocaleTag != localeTag) {
      _lastLocaleTag = localeTag;
      final l10n = AppLocalizations.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref
            .read(reminderNotificationTitleProvider.notifier)
            .setTitleBuilder(l10n.reminderNotificationTitle);
        ref
            .read(timetableControllerProvider.notifier)
            .syncGeneratedSemesterNames(
              (firstWeekMonday) => l10n.semesterName(
                firstWeekMonday.year,
                firstWeekMonday.month.toString().padLeft(2, '0'),
              ),
            );
        unawaited(
          ref.read(timetableControllerProvider.notifier).rebuildReminders(),
        );
      });
    }
    return widget.child;
  }
}

Locale _resolveLocale(
  List<Locale>? preferredLocales,
  Iterable<Locale> supportedLocales,
) {
  for (final locale in preferredLocales ?? const <Locale>[]) {
    if (locale.languageCode == 'en') {
      return const Locale('en');
    }
    if (locale.languageCode != 'zh') {
      continue;
    }
    final country = locale.countryCode?.toUpperCase();
    final script = locale.scriptCode?.toLowerCase();
    if (script == 'hant' ||
        country == 'TW' ||
        country == 'HK' ||
        country == 'MO') {
      return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
    }
    return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
  }
  return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
}
