import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Android launcher icon uses adaptive and themed resources', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final adaptiveIcon = File(
      'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
    ).readAsStringSync();
    final adaptiveRoundIcon = File(
      'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml',
    ).readAsStringSync();
    final lightColors = File(
      'android/app/src/main/res/values/colors.xml',
    ).readAsStringSync();
    final nightColors = File(
      'android/app/src/main/res/values-night/colors.xml',
    ).readAsStringSync();

    expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
    expect(manifest, contains('android:roundIcon="@mipmap/ic_launcher_round"'));
    expect(manifest, contains('android:enableOnBackInvokedCallback="false"'));
    for (final xml in [adaptiveIcon, adaptiveRoundIcon]) {
      expect(xml, contains('<adaptive-icon'));
      expect(
        xml,
        contains(
          '<background android:drawable="@color/ic_launcher_background"',
        ),
      );
      expect(
        xml,
        contains(
          '<foreground android:drawable="@mipmap/ic_launcher_foreground"',
        ),
      );
      expect(
        xml,
        contains(
          '<monochrome android:drawable="@mipmap/ic_launcher_monochrome"',
        ),
      );
    }
    expect(
      File(
        'android/app/src/main/res/drawable/ic_launcher_foreground.xml',
      ).existsSync(),
      isFalse,
    );
    expect(
      File(
        'android/app/src/main/res/drawable-night/ic_launcher_foreground.xml',
      ).existsSync(),
      isFalse,
    );
    expect(
      File(
        'android/app/src/main/res/drawable/ic_launcher_monochrome.xml',
      ).existsSync(),
      isFalse,
    );
    expect(lightColors, contains('ic_launcher_background'));
    expect(nightColors, contains('ic_launcher_background'));
    expect(
      File(
        'android/app/src/main/res/drawable/ic_stat_notification.xml',
      ).existsSync(),
      isTrue,
    );
  });

  test('Android notification and alarm receivers are declared', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final scheduler = File(
      'lib/features/reminder/data/local_notification_reminder_scheduler.dart',
    ).readAsStringSync();
    final service = File(
      'android/app/src/main/kotlin/app/crid/PersistentBackgroundService.kt',
    ).readAsStringSync();

    expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
    expect(manifest, contains('android.permission.SCHEDULE_EXACT_ALARM'));
    expect(
      manifest,
      contains(
        'android.app.action.SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED',
      ),
    );
    expect(
      manifest,
      contains(
        'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver',
      ),
    );
    expect(
      manifest,
      contains(
        'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
      ),
    );
    expect(
      scheduler,
      contains("AndroidInitializationSettings('ic_stat_notification')"),
    );
    expect(service, contains('R.drawable.ic_stat_notification'));
    expect(scheduler, contains("'class_reminders'"));
    expect(service, contains('CHANNEL_ID = "background_runtime"'));
    expect(
      File(
        'android/app/src/main/kotlin/app/crid/BackgroundRuntimeBootReceiver.kt',
      ).readAsStringSync(),
      contains(
        'AlarmManager.ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED',
      ),
    );
  });

  test('legacy launcher PNGs cover Android density buckets', () {
    const expectedSizes = {
      'mipmap-mdpi': (legacy: 48, adaptive: 108),
      'mipmap-hdpi': (legacy: 72, adaptive: 162),
      'mipmap-xhdpi': (legacy: 96, adaptive: 216),
      'mipmap-xxhdpi': (legacy: 144, adaptive: 324),
      'mipmap-xxxhdpi': (legacy: 192, adaptive: 432),
    };

    for (final entry in expectedSizes.entries) {
      final iconBytes = File(
        'android/app/src/main/res/${entry.key}/ic_launcher.png',
      ).readAsBytesSync();
      final roundIconBytes = File(
        'android/app/src/main/res/${entry.key}/ic_launcher_round.png',
      ).readAsBytesSync();
      expect(roundIconBytes, isNot(iconBytes));
      for (final name in ['ic_launcher.png', 'ic_launcher_round.png']) {
        final size = _pngSize(
          File('android/app/src/main/res/${entry.key}/$name').readAsBytesSync(),
        );
        expect(size, (entry.value.legacy, entry.value.legacy));
      }
      final foregroundSize = _pngSize(
        File(
          'android/app/src/main/res/${entry.key}/ic_launcher_foreground.png',
        ).readAsBytesSync(),
      );
      expect(foregroundSize, (entry.value.adaptive, entry.value.adaptive));
      final monochromeSize = _pngSize(
        File(
          'android/app/src/main/res/${entry.key}/ic_launcher_monochrome.png',
        ).readAsBytesSync(),
      );
      expect(monochromeSize, (entry.value.adaptive, entry.value.adaptive));
    }
  });

  test('adaptive launcher layers keep transparent corners', () async {
    const conservativeForegroundForXxxhdpi = 52 * 4;
    for (final name in [
      'ic_launcher_foreground.png',
      'ic_launcher_monochrome.png',
    ]) {
      final image = await _decodePng(
        File('android/app/src/main/res/mipmap-xxxhdpi/$name').readAsBytesSync(),
      );
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final bytes = data!.buffer.asUint8List();
      expect(_pixel(bytes, image.width, 0, 0).alpha, 0);
      expect(_pixel(bytes, image.width, image.width - 1, 0).alpha, 0);
      expect(_pixel(bytes, image.width, 0, image.height - 1).alpha, 0);
      expect(
        _pixel(bytes, image.width, image.width - 1, image.height - 1).alpha,
        0,
      );
      final bounds = _alphaBounds(bytes, image.width, image.height);
      expect(bounds.width, lessThanOrEqualTo(conservativeForegroundForXxxhdpi));
      expect(
        bounds.height,
        lessThanOrEqualTo(conservativeForegroundForXxxhdpi),
      );
    }
  });

  test(
    'launcher icon stays near geometric center with visual compensation',
    () async {
      final image = await _decodePng(
        File(
          'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
        ).readAsBytesSync(),
      );
      final visualOffset = await _visualCentroidOffset(image);
      final boundsOffset = await _subjectBoundsOffset(image);

      expect(boundsOffset.$1.abs(), lessThanOrEqualTo(4));
      expect(boundsOffset.$2.abs(), lessThanOrEqualTo(4));
      expect(visualOffset.$1.abs(), lessThanOrEqualTo(6));
      expect(visualOffset.$2.abs(), lessThanOrEqualTo(14));
    },
  );
}

(int width, int height) _pngSize(List<int> bytes) {
  const pngSignatureLength = 8;
  const ihdrWidthOffset = pngSignatureLength + 8;
  final width = _readUint32(bytes, ihdrWidthOffset);
  final height = _readUint32(bytes, ihdrWidthOffset + 4);
  return (width, height);
}

int _readUint32(List<int> bytes, int offset) {
  return bytes[offset] << 24 |
      bytes[offset + 1] << 16 |
      bytes[offset + 2] << 8 |
      bytes[offset + 3];
}

Future<ui.Image> _decodePng(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}

Future<(double x, double y)> _visualCentroidOffset(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final bytes = data!.buffer.asUint8List();
  final width = image.width;
  final height = image.height;
  final corners = [
    _pixel(bytes, width, 0, 0),
    _pixel(bytes, width, width - 1, 0),
    _pixel(bytes, width, 0, height - 1),
    _pixel(bytes, width, width - 1, height - 1),
  ];
  final background = (
    red: corners.map((color) => color.red).reduce((a, b) => a + b) / 4,
    green: corners.map((color) => color.green).reduce((a, b) => a + b) / 4,
    blue: corners.map((color) => color.blue).reduce((a, b) => a + b) / 4,
  );
  var sx = 0.0;
  var sy = 0.0;
  var mass = 0.0;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final pixel = _pixel(bytes, width, x, y);
      final contrast =
          ((pixel.red - background.red).abs() +
              (pixel.green - background.green).abs() +
              (pixel.blue - background.blue).abs()) /
          765;
      final pixelMass = (pixel.alpha / 255) * contrast;
      sx += x * pixelMass;
      sy += y * pixelMass;
      mass += pixelMass;
    }
  }

  return (sx / mass - (width - 1) / 2, sy / mass - (height - 1) / 2);
}

Future<(double x, double y)> _subjectBoundsOffset(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final bytes = data!.buffer.asUint8List();
  final width = image.width;
  final height = image.height;
  final background = _pixel(bytes, width, 0, 0);
  var left = width;
  var top = height;
  var right = 0;
  var bottom = 0;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final pixel = _pixel(bytes, width, x, y);
      final contrast =
          ((pixel.red - background.red).abs() +
              (pixel.green - background.green).abs() +
              (pixel.blue - background.blue).abs()) /
          765;
      if (pixel.alpha < 240 || contrast < .045) {
        continue;
      }
      left = x < left ? x : left;
      top = y < top ? y : top;
      right = x > right ? x : right;
      bottom = y > bottom ? y : bottom;
    }
  }

  return (
    (left + right) / 2 - (width - 1) / 2,
    (top + bottom) / 2 - (height - 1) / 2,
  );
}

({int red, int green, int blue, int alpha}) _pixel(
  List<int> bytes,
  int width,
  int x,
  int y,
) {
  final offset = (y * width + x) * 4;
  return (
    red: bytes[offset],
    green: bytes[offset + 1],
    blue: bytes[offset + 2],
    alpha: bytes[offset + 3],
  );
}

({int width, int height}) _alphaBounds(List<int> bytes, int width, int height) {
  var left = width;
  var top = height;
  var right = -1;
  var bottom = -1;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final alpha = bytes[(y * width + x) * 4 + 3];
      if (alpha < 16) {
        continue;
      }
      left = x < left ? x : left;
      top = y < top ? y : top;
      right = x > right ? x : right;
      bottom = y > bottom ? y : bottom;
    }
  }

  return (width: right - left + 1, height: bottom - top + 1);
}
