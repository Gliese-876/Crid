import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _channel = MethodChannel('app.crid/android_background');

class AndroidBackgroundStatus {
  const AndroidBackgroundStatus({
    required this.available,
    required this.manufacturer,
    required this.brand,
    required this.model,
    required this.androidRelease,
    required this.sdkInt,
    required this.notificationsAllowed,
    required this.exactAlarmsAllowed,
    required this.batteryOptimizationIgnored,
    required this.persistentBackgroundEnabled,
    required this.persistentBackgroundRunning,
  });

  const AndroidBackgroundStatus.unsupported()
    : available = false,
      manufacturer = '',
      brand = '',
      model = '',
      androidRelease = '',
      sdkInt = 0,
      notificationsAllowed = false,
      exactAlarmsAllowed = false,
      batteryOptimizationIgnored = false,
      persistentBackgroundEnabled = false,
      persistentBackgroundRunning = false;

  final bool available;
  final String manufacturer;
  final String brand;
  final String model;
  final String androidRelease;
  final int sdkInt;
  final bool notificationsAllowed;
  final bool exactAlarmsAllowed;
  final bool batteryOptimizationIgnored;
  final bool persistentBackgroundEnabled;
  final bool persistentBackgroundRunning;

  factory AndroidBackgroundStatus.fromMap(Map<Object?, Object?> map) {
    return AndroidBackgroundStatus(
      available: map['available'] as bool? ?? true,
      manufacturer: map['manufacturer'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      model: map['model'] as String? ?? '',
      androidRelease: map['androidRelease'] as String? ?? '',
      sdkInt: map['sdkInt'] as int? ?? 0,
      notificationsAllowed: map['notificationsAllowed'] as bool? ?? true,
      exactAlarmsAllowed: map['exactAlarmsAllowed'] as bool? ?? true,
      batteryOptimizationIgnored:
          map['batteryOptimizationIgnored'] as bool? ?? false,
      persistentBackgroundEnabled:
          map['persistentBackgroundEnabled'] as bool? ?? false,
      persistentBackgroundRunning:
          map['persistentBackgroundRunning'] as bool? ?? false,
    );
  }
}

class AndroidBackgroundService {
  Future<AndroidBackgroundStatus> status() async {
    if (!_isAndroidRuntime) {
      return const AndroidBackgroundStatus.unsupported();
    }
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'getStatus',
    );
    return AndroidBackgroundStatus.fromMap(result ?? const {});
  }

  Future<AndroidBackgroundStatus> setPersistentBackgroundEnabled(
    bool enabled,
  ) async {
    if (!_isAndroidRuntime) {
      return const AndroidBackgroundStatus.unsupported();
    }
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'setPersistentBackgroundEnabled',
      {'enabled': enabled},
    );
    return AndroidBackgroundStatus.fromMap(result ?? const {});
  }

  Future<void> openNotificationSettings() {
    return _invokeAndroidOnly('openNotificationSettings');
  }

  Future<void> openBatterySettings() {
    return _invokeAndroidOnly('openBatteryOptimizationSettings');
  }

  Future<void> openExactAlarmSettings() {
    return _invokeAndroidOnly('openExactAlarmSettings');
  }

  Future<void> openAutoStartSettings() {
    return _invokeAndroidOnly('openAutoStartSettings');
  }

  Future<void> requestIgnoreBatteryOptimizations() {
    return _invokeAndroidOnly('requestIgnoreBatteryOptimizations');
  }

  Future<void> _invokeAndroidOnly(String method, [Object? arguments]) async {
    if (!_isAndroidRuntime) {
      return;
    }
    await _channel.invokeMethod<void>(method, arguments);
  }
}

bool get _isAndroidRuntime =>
    defaultTargetPlatform == TargetPlatform.android && Platform.isAndroid;

final androidBackgroundServiceProvider = Provider<AndroidBackgroundService>((
  ref,
) {
  return AndroidBackgroundService();
});

final androidBackgroundStatusProvider = FutureProvider<AndroidBackgroundStatus>(
  (ref) {
    return ref.watch(androidBackgroundServiceProvider).status();
  },
);

final androidBackgroundRuntimeControllerProvider =
    AsyncNotifierProvider<
      AndroidBackgroundRuntimeController,
      AndroidBackgroundStatus
    >(AndroidBackgroundRuntimeController.new);

class AndroidBackgroundRuntimeController
    extends AsyncNotifier<AndroidBackgroundStatus> {
  @override
  Future<AndroidBackgroundStatus> build() {
    return ref.watch(androidBackgroundServiceProvider).status();
  }

  Future<void> setEnabled(bool enabled) async {
    state = const AsyncLoading<AndroidBackgroundStatus>();
    state = await AsyncValue.guard(() async {
      final service = ref.read(androidBackgroundServiceProvider);
      final status = await service.setPersistentBackgroundEnabled(enabled);
      ref.invalidate(androidBackgroundStatusProvider);
      return status;
    });
  }
}
