# Windows feature parity

This document records how Android capabilities map to Windows. A parity item is
complete only when the Windows implementation uses the corresponding operating
system capability where one exists; copying the Android UI alone is not enough.

| Capability | Android implementation | Windows implementation | Status |
| --- | --- | --- | --- |
| Scheduled course reminders | `AlarmManager` through `flutter_local_notifications` | Scheduled Windows toast notifications | Complete |
| Notification availability | Runtime permission and `NotificationManager` | Native `ToastNotifier.Setting` query over a C++ method channel | Complete |
| Notification settings | Android app notification settings intent | `ms-settings:notifications` opened by the Windows runner | Complete |
| Do Not Disturb override | Notification policy access | Urgent Windows notification scenario | Complete |
| Muted reminders | Silent Android notification channel | Silent Windows toast audio | Complete |
| Reminder survival after app exit | Boot receiver and optional foreground service | Windows owns the scheduled toast queue; no persistent app process is required | Complete |
| File selection | Android system document picker | Native Windows file picker | Complete |
| Open timetable file from Explorer | Android `VIEW` intent | MSIX file associations and Flutter launch-argument import | Complete |
| Export destination | Android document picker | Native Windows save dialog | Complete |
| Open exported file | Android content/file handler | Windows shell file handler | Complete |
| Application identity | Adaptive Android launcher assets | Runner ICO, MSIX logo, and toast icon/activator | Complete |
| Installation and update | APK package installer | Signed MSIX plus one-click script with one-time certificate UAC | Complete |
| Primary navigation | Mobile bottom navigation | Collapsible desktop navigation rail and persistent toolbar actions | Complete |
| Timetable workspace | Touch-first compact page | Wide timetable grid with desktop spacing and controls | Complete |
| Plans and editor | Single-column mobile flow | Responsive two-column desktop forms/panels | Complete |
| Import workspace | Stacked mobile cards | Source/history rail with side-by-side preview | Complete |
| Export workspace | Stacked mobile cards | Three-tile desktop export workspace | Complete |
| Settings | Stacked mobile sections | Two-column settings workspace with Windows runtime status | Complete |
| Secondary pages | Full-width mobile sheets/pages | Centered, route-specific desktop content widths | Complete |

Android battery optimization, manufacturer autostart panels, and the persistent
foreground service are intentionally not reproduced on Windows. Scheduled toast
notifications are registered with Windows and remain owned by the operating
system after Crid exits, so a resident background process would add cost without
improving reminder reliability.

## Regression gates

- `flutter analyze`
- `flutter test`
- `flutter build windows --release` and signed MSIX creation
- Launch the Windows executable with a supported file path and verify that the
  import workspace opens with a populated preview.
