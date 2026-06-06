import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../data/database/timetable_time.dart';
import '../domain/reminder_window.dart';

const defaultReminderScheduleWindowDays = defaultReminderWindowDays;

class ReminderScheduleResult {
  const ReminderScheduleResult({
    required this.scheduledCount,
    required this.platformAvailable,
    this.notificationsAllowed = true,
    this.exactAlarmAllowed = true,
  });

  final int scheduledCount;
  final bool platformAvailable;
  final bool notificationsAllowed;
  final bool exactAlarmAllowed;
}

class ReminderPermissionStatus {
  const ReminderPermissionStatus({
    required this.platformAvailable,
    this.notificationsAllowed = true,
    this.exactAlarmAllowed = true,
  });

  final bool platformAvailable;
  final bool notificationsAllowed;
  final bool exactAlarmAllowed;
}

abstract interface class ReminderSchedulerService {
  Future<ReminderPermissionStatus> requestPermissionsForScheduling();

  Future<bool> requestDoNotDisturbBypassIfSupported();

  Future<ReminderScheduleResult> scheduleRollingWindow({
    required Iterable<ClassSessionInfo> sessions,
    required DateTime firstWeekMonday,
    required DateTime now,
    int minutesBefore,
    Iterable<int>? reminderOffsets,
    bool ignoreDoNotDisturb,
    bool vibrateOnly,
    int windowDays = defaultReminderScheduleWindowDays,
    String Function(int minutesBefore)? titleForMinutes,
  });
}

class FlutterLocalReminderScheduler implements ReminderSchedulerService {
  FlutterLocalReminderScheduler({
    FlutterLocalNotificationsPlugin? plugin,
    NotificationDetails? notificationDetails,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _notificationDetails = notificationDetails;

  final FlutterLocalNotificationsPlugin _plugin;
  final NotificationDetails? _notificationDetails;
  var _initialized = false;
  var _requestedExactAlarmPermission = false;

  @override
  Future<ReminderPermissionStatus> requestPermissionsForScheduling() async {
    try {
      await _ensureInitialized();
      final notificationsAllowed =
          await _requestAndroidNotificationPermissionIfSupported();
      final exactAlarmAllowed = await _requestAndroidExactAlarmIfSupported();
      return ReminderPermissionStatus(
        platformAvailable: true,
        notificationsAllowed: notificationsAllowed,
        exactAlarmAllowed: exactAlarmAllowed,
      );
    } on Object {
      return const ReminderPermissionStatus(platformAvailable: false);
    }
  }

  @override
  Future<bool> requestDoNotDisturbBypassIfSupported() async {
    try {
      await _ensureInitialized();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) {
        return true;
      }
      if (await android.hasNotificationPolicyAccess() == true) {
        return true;
      }
      return await android.requestNotificationPolicyAccess() ?? false;
    } on Object {
      return false;
    }
  }

  @override
  Future<ReminderScheduleResult> scheduleRollingWindow({
    required Iterable<ClassSessionInfo> sessions,
    required DateTime firstWeekMonday,
    required DateTime now,
    int minutesBefore = 20,
    Iterable<int>? reminderOffsets,
    bool ignoreDoNotDisturb = false,
    bool vibrateOnly = false,
    int windowDays = defaultReminderScheduleWindowDays,
    String Function(int minutesBefore)? titleForMinutes,
  }) async {
    final candidates = buildRollingReminderWindow(
      sessions: sessions,
      firstWeekMonday: firstWeekMonday,
      now: now,
      minutesBefore: minutesBefore,
      reminderOffsets: reminderOffsets,
      windowDays: windowDays,
      titleForMinutes: titleForMinutes,
    );

    try {
      await _ensureInitialized();
      _ensureTimezone();
      await _cancelPendingIfSupported();
      final notificationsAllowed =
          await _areAndroidNotificationsEnabledIfSupported();
      if (!notificationsAllowed) {
        return const ReminderScheduleResult(
          scheduledCount: 0,
          platformAvailable: true,
          notificationsAllowed: false,
        );
      }
      var scheduleMode = candidates.isEmpty
          ? AndroidScheduleMode.inexactAllowWhileIdle
          : await _androidScheduleMode(requestPermission: false);
      try {
        await _scheduleCandidates(
          candidates,
          scheduleMode,
          ignoreDoNotDisturb: ignoreDoNotDisturb,
          vibrateOnly: vibrateOnly,
        );
      } on PlatformException catch (error) {
        if (scheduleMode != AndroidScheduleMode.exactAllowWhileIdle ||
            !_canRetryWithInexactAlarm(error)) {
          rethrow;
        }
        await _cancelPendingIfSupported();
        scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
        await _scheduleCandidates(
          candidates,
          scheduleMode,
          ignoreDoNotDisturb: ignoreDoNotDisturb,
          vibrateOnly: vibrateOnly,
        );
      }
      return ReminderScheduleResult(
        scheduledCount: candidates.length,
        platformAvailable: true,
        notificationsAllowed: notificationsAllowed,
        exactAlarmAllowed:
            candidates.isEmpty ||
            scheduleMode == AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on Object {
      return const ReminderScheduleResult(
        scheduledCount: 0,
        platformAvailable: false,
      );
    }
  }

  Future<void> _scheduleCandidates(
    Iterable<ReminderCandidate> candidates,
    AndroidScheduleMode scheduleMode, {
    required bool ignoreDoNotDisturb,
    required bool vibrateOnly,
  }) async {
    for (final candidate in candidates) {
      await _plugin.zonedSchedule(
        id: candidate.notificationId,
        title: candidate.title,
        body: candidate.body,
        scheduledDate: _shanghaiDateTime(candidate.remindAt),
        notificationDetails:
            _notificationDetails ??
            reminderNotificationDetailsFor(
              candidate,
              ignoreDoNotDisturb: ignoreDoNotDisturb,
              vibrateOnly: vibrateOnly,
            ),
        androidScheduleMode: scheduleMode,
        payload: candidate.payload,
      );
    }
  }

  bool _canRetryWithInexactAlarm(PlatformException error) {
    final details = [
      error.code,
      error.message,
      error.details?.toString(),
    ].whereType<String>().join(' ').toLowerCase();
    return details.isEmpty ||
        details.contains('exact') ||
        details.contains('alarm') ||
        details.contains('permission') ||
        details.contains('schedule_exact_alarm');
  }

  Future<void> _cancelPendingIfSupported() async {
    try {
      await _plugin.cancelAllPendingNotifications();
    } on Object {
      // Some desktop/test plugin backends do not implement pending cancellation.
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_notification'),
        windows: WindowsInitializationSettings(
          appName: 'Crid',
          appUserModelId: 'Crid.App',
          guid: '6f338c02-cb02-4d1d-8e6f-10a02e7c7ac3',
        ),
      ),
    );
    _initialized = true;
  }

  Future<bool> _areAndroidNotificationsEnabledIfSupported() async {
    try {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.areNotificationsEnabled() ??
          true;
    } on Object {
      // Older Android versions and non-Android backends do not expose this API.
      return true;
    }
  }

  Future<bool> _requestAndroidNotificationPermissionIfSupported() async {
    try {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          true;
    } on Object {
      // Permission APIs are platform/version specific.
      return true;
    }
  }

  Future<bool> _requestAndroidExactAlarmIfSupported() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return true;
    }
    final mode = await _androidScheduleMode(requestPermission: true);
    return mode == AndroidScheduleMode.exactAllowWhileIdle;
  }

  Future<AndroidScheduleMode> _androidScheduleMode({
    required bool requestPermission,
  }) async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }

    try {
      if (await android.canScheduleExactNotifications() == true) {
        return AndroidScheduleMode.exactAllowWhileIdle;
      }
      if (requestPermission &&
          !_requestedExactAlarmPermission &&
          await android.requestExactAlarmsPermission() == true) {
        return AndroidScheduleMode.exactAllowWhileIdle;
      }
      if (requestPermission) {
        _requestedExactAlarmPermission = true;
      }
    } on Object {
      // Exact alarm APIs are Android-version specific; inexact scheduling is
      // the compatible fallback when the platform or user rejects the request.
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }
}

NotificationDetails reminderNotificationDetailsFor(
  ReminderCandidate candidate, {
  bool ignoreDoNotDisturb = false,
  bool vibrateOnly = false,
}) {
  _ensureTimezone();
  final timeoutAfter = candidate.startAt
      .difference(candidate.remindAt)
      .inMilliseconds;
  final channelSuffix = [
    if (ignoreDoNotDisturb) 'dnd',
    if (vibrateOnly) 'vibrate',
  ].join('_');
  final channelId = channelSuffix.isEmpty
      ? 'class_reminders'
      : 'class_reminders_$channelSuffix';
  return NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      vibrateOnly ? 'Class reminders without sound' : 'Class reminders',
      channelDescription: 'Upcoming class reminders',
      channelBypassDnd: ignoreDoNotDisturb,
      playSound: !vibrateOnly,
      enableVibration: true,
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: false,
      ongoing: true,
      onlyAlertOnce: true,
      showWhen: true,
      when: _shanghaiDateTime(candidate.startAt).millisecondsSinceEpoch,
      usesChronometer: false,
      chronometerCountDown: false,
      timeoutAfter: timeoutAfter > 0 ? timeoutAfter : null,
      category: AndroidNotificationCategory.reminder,
    ),
    windows: const WindowsNotificationDetails(),
  );
}

var _timezoneReady = false;

void _ensureTimezone() {
  if (_timezoneReady) {
    return;
  }
  tz_data.initializeTimeZones();
  _timezoneReady = true;
}

tz.Location _shanghaiLocation() => tz.getLocation('Asia/Shanghai');

tz.TZDateTime _shanghaiDateTime(DateTime value) {
  return tz.TZDateTime(
    _shanghaiLocation(),
    value.year,
    value.month,
    value.day,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
}
