<p align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" alt="Crid app icon" width="104" height="104">
</p>

<h1 align="center">Crid</h1>

<p align="center">A local-first, ad-free, open-source timetable for Android and Windows.</p>

<p align="center">
  <a href="README.md">简体中文</a> ·
  <a href="README_zh_Hant.md">繁體中文</a> ·
  <a href="README_en.md">English</a>
</p>

<p align="center">
  <a href="https://github.com/Gliese-876/Crid/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/Gliese-876/Crid"></a>
  <img alt="Platforms: Android and Windows" src="https://img.shields.io/badge/platform-Android%20%7C%20Windows-2563eb">
  <a href="LICENSE"><img alt="Apache 2.0 license" src="https://img.shields.io/github/license/Gliese-876/Crid"></a>
</p>

Crid is a Flutter app for managing courses, exams, semesters, and timetable plans. It requires no account and stores timetable data locally. The app includes import, editing, reminders, export, and backup.

<p align="center">
  <a href="https://github.com/Gliese-876/Crid/releases/latest"><strong>Download the latest release</strong></a> ·
  <a href="CHANGELOG_EN.md">Changelog</a> ·
  <a href="docs/development.md">Development guide</a> ·
  <a href="docs/windows-feature-parity.md">Windows parity matrix</a>
</p>

## Features

### Timetables and courses

- Manage multiple semesters and timetable plans, including plan switching, editing, and deletion.
- Store exact start and end times, week ranges, odd weeks, and even weeks.
- Create, edit, hide, and restore regular courses or exams.
- “Show courses outside the current week” defaults to off. When enabled, courses not held in the selected week stay in position and appear in gray.
- Display, mute, or hide courses and exams according to holiday and make-up workday rules.

### Import and conflict handling

| Content | Supported source | Behavior |
| --- | --- | --- |
| Timetable | `.ics` | Parses events, locations, descriptions, and recurrence rules |
| Timetable | BIFF/HTML `.xls` | Detects binary or web-table exports from academic systems |
| Exam schedule | `.mht`, `.mhtml`, `.pdf`, `.txt` | Extracts exam round, time, location, seat, and notes |
| Exam schedule | Clipboard text | Accepts text copied directly from an academic-system page |

Every import enters a preview first, followed by deduplication, automatic merging, and explicit conflict handling. Existing timetables are never overwritten without review.

### Reminders, export, and data

- Configure multiple preset or custom reminder offsets, with sound, vibration, and Do Not Disturb options.
- Android uses system notifications and alarms. Windows uses scheduled system toasts and does not require Crid to remain running.
- Export standard `.ics`, a weekly PNG, or a full-semester PNG.
- Image export has its own inactive-week course option and does not alter the timetable page setting.
- Back up and restore timetable data and settings locally.
- Use the interface in Simplified Chinese, Traditional Chinese, or English.

### Native Windows experience

- Wide timetable workspace, collapsible navigation rail, persistent desktop toolbar, and multi-column import, export, and settings pages.
- Native Windows file pickers, save dialogs, shell file opening, and notification-settings entry points.
- File Explorer associations for `.ics`, `.xls`, `.mht`, `.mhtml`, `.pdf`, and `.txt`, opening directly into import preview.
- Consistent Crid icon assets across the runner, MSIX, Start menu, and toast notifications.

## Platform support

| Platform | Status | Distribution |
| --- | --- | --- |
| Android | Supported | Universal APK plus arm64-v8a, armeabi-v7a, and x86_64 packages |
| Windows 10/11 x64 | Supported | ZIP containing a signed MSIX, one-click installer, and public certificate |
| iOS / macOS | Not yet supported | Planned |
| Linux | Not yet supported | No release currently planned |

The current release is `v1.2.0`. All official packages are available from [GitHub Releases](https://github.com/Gliese-876/Crid/releases/latest).

## Install and update

### Android

For most users, download `Crid-1.2.0-release-android.apk`. This universal package covers arm64-v8a, armeabi-v7a, and x86_64, so it is the safest choice when the device architecture is unknown.

Smaller architecture-specific packages are also available:

| File | Intended devices |
| --- | --- |
| `Crid-1.2.0-release-android-arm64.apk` | Most recent Android phones and tablets |
| `Crid-1.2.0-release-android-armeabi-v7a.apk` | Older 32-bit Android devices |
| `Crid-1.2.0-release-android-x86_64.apk` | x86_64 emulators and a small number of x86_64 devices |

Open the downloaded APK to install it. If Android blocks the package, grant the browser or file manager permission to install unknown apps. Installing a newer APK updates Crid while retaining existing app data.

### Windows

1. Download `Crid-1.2.0-windows-x64.zip` and extract all files to a local folder.
2. Double-click `Install-Crid.cmd`.
3. Approve one UAC prompt on the first install. The script adds the bundled public certificate to the Local Machine Trusted People store, verifies the package, and installs the MSIX.
4. Open Crid from the Start menu.

To update, extract the new ZIP and run `Install-Crid.cmd` again. Later releases using the same signing certificate normally do not require another UAC prompt.

<details>
<summary>Manual Windows installation and common errors</summary>

Import the bundled `.cer` into `Cert:\LocalMachine\TrustedPeople`, then run:

```powershell
Add-AppxPackage -Path "C:\path\to\Crid-1.2.0-windows-x64.msix" -ForceApplicationShutdown -ForceUpdateFromAnyVersion
```

Error `0x800B0109` normally means the certificate was not imported into the Local Machine Trusted People store. Toast delivery also remains subject to Windows notification settings, Focus Assist, and organization policy.

</details>

### Verify a download

`SHA256SUMS.txt` in the Release covers every APK and the Windows ZIP. In PowerShell, run:

```powershell
Get-FileHash .\Crid-1.2.0-release-android.apk -Algorithm SHA256
```

Compare the result with the matching entry in `SHA256SUMS.txt`.

## Quick start

1. Create a semester and confirm the Monday of its first week. `.xls` files usually contain no real dates, so this controls week conversion.
2. Create a timetable plan manually or import a timetable or exam file.
3. Review additions, duplicates, changes, and conflicts in import preview before writing to the target plan.
4. Use Settings → Display to decide whether inactive-week courses should appear in gray.
5. Enable course reminders as needed, then configure lead time, sound, and Do Not Disturb behavior.
6. Use Export to create ICS, weekly images, or full-semester images. Use Settings to create a local backup.

## Import compatibility

Academic-system parsers are currently developed and tested primarily against real exports from Beijing Normal University at Zhuhai. Generic ICS input works more broadly, while `.xls`, MHTML, and PDF layouts from other institutions may require an additional adapter. When reporting an unsupported file, remove personal information before attaching a sample.

## Development

### Requirements

- Flutter stable and its bundled Dart SDK.
- Android: Android Studio, Android SDK, and an emulator or physical device.
- Windows: Windows 10/11 and Visual Studio with the Desktop development with C++ workload.

### Clone and run

```powershell
git clone https://github.com/Gliese-876/Crid.git
cd Crid
flutter pub get
flutter gen-l10n
flutter run -d windows
```

For Android, replace the last line with `flutter run -d <device-id>`. Run `flutter devices` to list available targets.

### Quality checks

```powershell
flutter analyze
flutter test
flutter build apk --release
flutter build windows --release
```

See the [development guide](docs/development.md) for signing, packaging, and release steps. Private keys, keystores, certificate passwords, and the Windows PFX must never be committed or included in a public Release.

### Repository layout

| Path | Responsibility |
| --- | --- |
| `lib/app/` | Entry point, routing, adaptive shell, theme, and locale |
| `lib/data/database/` | Drift database, migrations, and course time model |
| `lib/features/timetable/` | Timetable home, semesters, plans, and repository |
| `lib/features/import/` | File detection, parsing, preview, merging, and conflicts |
| `lib/features/editor/` | Course and exam editing |
| `lib/features/reminder/` | Reminder rules and platform notification scheduling |
| `lib/features/export/` | ICS and image export |
| `lib/features/settings/` | Settings, holidays, backup, and native integration |
| `lib/l10n/` | Simplified Chinese, Traditional Chinese, and English resources |
| `test/` | Parser, database, reminder, export, and UI regression tests |

The core stack includes Flutter, Material 3, Riverpod, go_router, Drift/SQLite, file_picker, and flutter_local_notifications. The [development guide](docs/development.md) describes the data model, import pipeline, and platform design in more detail.

## Documentation

- [Chinese changelog](CHANGELOG.md)
- [English changelog](CHANGELOG_EN.md)
- [Development and release guide](docs/development.md)
- [Android-to-Windows feature parity matrix](docs/windows-feature-parity.md)

## Current limitations

- Institution-specific parsers currently focus on Beijing Normal University at Zhuhai. Other institutions or redesigned source pages may not parse correctly.
- Official clients are currently limited to Android and Windows x64; iOS, macOS, and Linux are not available.
- Windows uses a self-signed MSIX, so the first install requires one UAC prompt to establish certificate trust. Notification delivery remains subject to Windows policy.
- Crid does not yet include an automatic updater. New releases must be downloaded and installed over the existing version.

## Roadmap

- Add support for Beijing Normal University Beijing campus and more academic-system formats.
- Continue improving notification reliability, Windows keyboard use, accessibility, and updates.
- Explore desktop and mobile widgets, followed by iOS and macOS clients.
- Explore optional BYOK AI parsing for previously unknown timetable formats.

## Contributing

Issues and pull requests are welcome. When sharing an import sample, remove names, student IDs, class rosters, seat numbers, and other personal data first. For platform-specific bugs, include the Android or Windows version and clear reproduction steps.

## Project principles

Crid focuses on course management. It contains no ads or shake-triggered redirects. Timetable data can be exported and backed up freely. The complete source code is public and can be inspected, modified, or built independently. The mobile and desktop versions follow the conventions of their respective platforms.

## License

Crid is licensed under the [Apache License 2.0](LICENSE). Keep the license, copyright notices, and attribution in [NOTICE](NOTICE) when using, modifying, or redistributing the project.
