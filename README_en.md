<p align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" alt="Crid app icon" width="96" height="96">
</p>

<h1 align="center">Crid</h1>

<p align="center">
  <a href="README.md">简体中文</a> |
  <a href="README_zh_Hant.md">繁體中文</a> |
  <a href="README_en.md">English</a>
</p>

Crid is a cross-platform timetable app built with Flutter. Its goal is to be a clean, good-looking, easy-to-use open source timetable app.

## Motivation

There are already many mature timetable apps. However, many of them are closed source or paid, while their free versions are often filled with ads. One day in May 2026, after finally getting tired of a timetable app's hard-to-avoid shake-to-open redirects and pop-up ads, I decided to build my own. With help from AI and a few weeks of development, Crid was born.

## Current Features

- View and edit timetables
- Course reminders
- Native Windows notifications, File Explorer associations, and wide desktop workspaces
- Automatic make-up workday adjustment
- Import `.xls` timetables from academic systems
- Import `.mht`, `.mhtml`, and `.pdf` exam schedules from academic systems
- Import exam schedules by pasting text copied from academic systems
- Export timetables as `.ics` and `.png` files
- Local backup and restore for data and settings
- Multi-language support
- More features are still in development

## Installation

Release builds are published on [GitHub Releases](https://github.com/Gliese-876/Crid/releases). The latest Windows release is `v1.2.0`; the latest Android package remains `v1.1.0`.

### Android

Download `Crid-1.1.0-release-android.apk` and install it directly. If Android blocks installation from unknown sources, enable the “Install unknown apps” permission for your browser or file manager.

Smaller architecture-specific APKs are also available:

- `Crid-1.1.0-release-android-arm64.apk`: most recent Android phones
- `Crid-1.1.0-release-android-armeabi-v7a.apk`: older 32-bit Android devices
- `Crid-1.1.0-release-android-x86_64.apk`: x86_64 emulators or a small number of x86_64 devices

### Windows

1. Download and fully extract `Crid-1.2.0-windows-x64.zip`.
2. Double-click `Install-Crid.cmd`.
3. On the first install, approve the single UAC prompt that adds the bundled public certificate to the Local Machine Trusted People store. Open Crid from the Start menu when installation finishes.

To update, extract the newer ZIP and run `Install-Crid.cmd` again. Later updates signed with the same certificate normally do not require UAC.

For a manual install, import the bundled `.cer` into `Cert:\LocalMachine\TrustedPeople`, then run:

```powershell
Add-AppxPackage -Path "C:\path\to\Crid-1.2.0-windows-x64.msix" -ForceApplicationShutdown -ForceUpdateFromAnyVersion
```

Error `0x800B0109` usually means the certificate was not added to the Local Machine Trusted People store.

## Technical Structure

The project uses a feature-first structure. The main directories are:

| Path | Purpose |
| --- | --- |
| `lib/app/` | App entry, routing, adaptive shell, theme, locale, and global state |
| `lib/data/database/` | Drift database, table schema, and course time models |
| `lib/features/timetable/` | Timetable home, plan management, and timetable repository |
| `lib/features/import/` | File detection, timetable parsing, import preview, and conflict handling |
| `lib/features/editor/` | Course creation and editing |
| `lib/features/export/` | ICS and image export |
| `lib/features/reminder/` | Local course reminders and rolling reminder window |
| `lib/features/settings/` | Settings, holiday data, Android background controls, and native Windows integration |
| `lib/l10n/` | Simplified Chinese, Traditional Chinese, and English strings |
| `test/` | Import, reminder, export, theme, repository, and UI tests |

Core dependencies:

- Flutter and Dart
- Riverpod
- go_router
- Drift and SQLite
- file_picker
- flutter_local_notifications
- html, charset, spreadsheet_decoder, mime, syncfusion_flutter_pdf
- icalendar_parser, rrule, timezone
- material_color_utilities

## Known Issues

- Timetable and exam parsing is currently focused on Beijing Normal University Zhuhai campus files
- The Windows MSIX uses a self-signed certificate, so the first install needs one UAC confirmation to establish machine trust
- Windows toast delivery is still subject to system notification settings, Focus Assist, and organization policy

## Near-Term Plan

- [ ] Support the timetable file format used by Beijing Normal University Beijing campus
- [ ] Improve notification stability
- [ ] Continue improving Windows keyboard shortcuts, accessibility, and update experience
- [ ] Add widget support

## Long-Term Vision

- [ ] Support BYOK access to AI models for general timetable file parsing
- [ ] Develop iOS and macOS versions

## License

This project is licensed under the [Apache License 2.0](LICENSE). You may use, modify, and distribute the code, including in closed-source projects. When redistributing it, keep this project's license, copyright notices, and the attribution notice in [NOTICE](NOTICE).
