import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as p;

const cridWindowsNotificationAppName = 'Crid';
const cridWindowsNotificationAppUserModelId = 'Crid.App';
const cridWindowsNotificationActivatorGuid =
    '6f338c02-cb02-4d1d-8e6f-10a02e7c7ac3';

const cridWindowsNotificationIconAsset =
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png';

WindowsInitializationSettings buildCridWindowsNotificationSettings() {
  return WindowsInitializationSettings(
    appName: cridWindowsNotificationAppName,
    appUserModelId: cridWindowsNotificationAppUserModelId,
    guid: cridWindowsNotificationActivatorGuid,
    iconPath: Platform.isWindows
        ? p.join(
            p.dirname(Platform.resolvedExecutable),
            'data',
            'flutter_assets',
            cridWindowsNotificationIconAsset,
          )
        : null,
  );
}
