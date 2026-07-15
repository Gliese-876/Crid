import 'dart:io';

import 'package:crid/features/reminder/data/notification_platform_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _defaultChannel = MethodChannel('app.crid/windows_runtime');

class WindowsReminderStatus {
  const WindowsReminderStatus({
    required this.available,
    required this.notificationsAllowed,
  });

  const WindowsReminderStatus.unsupported()
    : available = false,
      notificationsAllowed = false;

  final bool available;
  final bool notificationsAllowed;

  factory WindowsReminderStatus.fromMap(Map<Object?, Object?> map) {
    return WindowsReminderStatus(
      available: map['available'] as bool? ?? true,
      notificationsAllowed: map['notificationsAllowed'] as bool? ?? true,
    );
  }
}

class WindowsReminderService {
  WindowsReminderService({
    MethodChannel channel = _defaultChannel,
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _channel = channel,
       _notificationsPlugin =
           notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  final MethodChannel _channel;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  var _initialized = false;

  Future<WindowsReminderStatus> status() async {
    if (!_isWindowsRuntime) {
      return const WindowsReminderStatus.unsupported();
    }
    await _ensureNotificationsInitialized();
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'getStatus',
    );
    return WindowsReminderStatus.fromMap(result ?? const {});
  }

  Future<void> openNotificationSettings() async {
    if (!_isWindowsRuntime) {
      return;
    }
    await _channel.invokeMethod<void>('openNotificationSettings');
  }

  Future<void> _ensureNotificationsInitialized() async {
    if (_initialized) {
      return;
    }
    await _notificationsPlugin.initialize(
      settings: InitializationSettings(
        windows: buildCridWindowsNotificationSettings(),
      ),
    );
    _initialized = true;
  }
}

bool get _isWindowsRuntime =>
    defaultTargetPlatform == TargetPlatform.windows && Platform.isWindows;

final windowsReminderServiceProvider = Provider<WindowsReminderService>((ref) {
  return WindowsReminderService();
});

final windowsReminderStatusProvider = FutureProvider<WindowsReminderStatus>((
  ref,
) {
  return ref.watch(windowsReminderServiceProvider).status();
});
