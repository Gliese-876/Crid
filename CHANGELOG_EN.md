# Changelog

## 1.2.0-release - 2026-07-15

### Timetable display

- Added a “show courses outside the current week” switch for both Android and Windows under Settings → Display. When enabled, courses not held in the selected week remain in their timetable positions and are distinguished with a gray overlay.
- The preference defaults to off, preserving the original behavior of showing only courses actually held in the selected week, and is persisted locally.
- Weekly and full-semester PNG export provides an independent switch for inactive-week courses, so exporting does not change the everyday timetable preference.

### Native Windows capabilities

- Mapped Android course reminders to native Windows toast notifications, including a C++/WinRT notification-status query and a direct link from Settings to Windows notification settings.
- Mapped “ignore Do Not Disturb” to the urgent Windows notification scenario and “mute reminder sound” to silent toast audio. Scheduled reminders remain owned by Windows and do not require a resident background process.
- Added Windows application identity, toast activation, and notification icon wiring so the runner, MSIX package, and toasts use the Crid icon assets.
- Added MSIX file associations for `.ics`, `.xls`, `.mht`, `.mhtml`, `.pdf`, and `.txt`. Opening a supported file from File Explorer now launches directly into the import preview.
- Kept import, export, and exported-file opening connected to native Windows file dialogs and shell handlers.

### Windows desktop interface

- Moved primary desktop actions into a persistent toolbar and collapsible NavigationRail, including course creation, import, export, settings, semester, and plan context.
- Added route-specific desktop content widths for import, export, editing, settings, licenses, and conflict handling instead of stretching mobile cards across the window.
- Rebuilt Settings as a two-column desktop workspace and replaced Android background-service controls with native Windows reminder status.
- Rebuilt Import as a source/history plus preview workspace and Export as a three-tile desktop workspace; plans and course editing retain responsive two-column layouts.
- Completed Simplified Chinese, Traditional Chinese, and English strings for the Windows, display, and export additions.

### Data reliability and tests

- Made historical Drift column migrations idempotent, fixing a startup blank screen when a partially applied migration attempted to add `is_hidden` again.
- Added regression coverage for Windows notification mapping and status, file activation, desktop layouts, icon assets, display preferences, and resumable database migration.
- Launched the real Windows executable with an ICS path and verified a populated import preview with 27 parsed courses, 27 additions, and no conflicts.

### Installation and release

- Raised the app version to `1.2.0-release+3` and the Windows MSIX version to `1.2.0.0`.
- Added a one-click install/update workflow. A first install uses one UAC confirmation to trust the machine certificate; later updates signed by the same certificate do not need elevation.
- Changed the Windows Release artifact to a ZIP containing the public certificate, installer scripts, and signed MSIX. The private PFX is never distributed.
- Published signed Android `1.2.0-release` APKs: one universal package covering arm64-v8a, armeabi-v7a, and x86_64, plus three ABI-specific packages.
- Added an Android-to-Windows feature parity matrix and updated the README and development documentation for Windows installation, native integration, and releases.

Validated for this release:

- `flutter analyze`
- `flutter test`
- `android\gradlew.bat assembleRelease --offline`
- `android\gradlew.bat assembleRelease --offline -Psplit-per-abi=true`
- `flutter build windows --release --build-name=1.2.0-release --build-number=3`
- `dart run msix:create --certificate-password <local certificate password>`
- Android APK identity, version, ABI, and release-signature checks
- PowerShell installer syntax, MSIX manifest version, signature, and ZIP content checks


## 1.1.0-release - 2026-06-07

### Timetable

- Changed the timetable into a 24-hour weekly view where course block position
  and height are calculated from exact minutes instead of whole class sections.
- Keeps the date header fixed at the top of the timetable card while the time
  axis and course blocks scroll vertically.
- Keeps the left time column pinned to the timetable card while horizontally
  swiping between weeks; it now only follows vertical time-axis scrolling.
- Uses the Beijing Normal University at Zhuhai official 12-lesson timetable
  during teaching hours, and whole-hour separators before 8:00, through midday
  gaps, and after 21:30, while keeping exact placement for events at any minute
  of the day.
- Places and sizes course blocks from their real start and end minutes, without
  snapping them to lesson or whole-hour guide lines when their times fall
  between separators.
- Added a unified mapping between class sections and clock minutes, with
  courses, exams, imports, exports, reminders, and backup/restore sharing the
  `CourseTimeRange` time model.
- Fixed startup auto-scroll occasionally stopping on an intermediate week, or
  choosing today's earliest class instead of the current week's earliest class;
  the app now scrolls to the earliest visible class in the current week when it
  opens, when the Timetable bottom-tab is selected, and when returning to
  today, without leaving a large blank area above the target class.
- Tapping any date in the header now scrolls to the current visible week's
  earliest class.
- Week swipes now keep the left time column's vertical position unchanged
  while the horizontal swipe is in progress, then scroll to the new week's
  earliest class after the swipe settles.
- Fixed stale page-sync callbacks overriding user swipes, which could make a
  right swipe from week 15 jump to a non-adjacent week such as week 2.
- Fixed consecutive horizontal swipes rebuilding the timetable page state and
  jumping back to week 2, which could also prevent the next swipe from reaching
  week 3.
- Changed timetable auto-scroll to a slower, more comfortable Material
  nonlinear decelerate animation, and aligned the target class block's top edge
  exactly to the viewport top instead of leaving a small gap.
- Slightly increased timetable row spacing so course blocks are taller and
  easier to scan.
- Slightly widened the timetable content area while keeping a small edge inset.
- Changed manual course creation and editing from section dropdowns to exact
  `HH:mm` start and end time fields.
- Exam blocks can now open the same editor style from their details sheet, with
  editable name, round, location, time, week, and notes.
- Both ordinary courses and exam courses support manual hiding; hidden exams
  appear in the hidden-courses list and can be restored.
- Legal-holiday display behavior is now configured separately for ordinary
  courses and exams, with normal, dimmed, and hidden modes. The default dims
  ordinary courses and keeps exams normal.

### Import, Export, And Data

- Preserved exact clock minutes in ICS import/export, import previews, conflict
  diffs, course reminders, timetable image export, and local backup/restore.
- Timetable image export now matches the real timetable page header, left time
  column, guide lines, and course block spacing, and each exported week is
  cropped precisely from that week's earliest active course/exam to its latest
  end time instead of rendering a full 24-hour axis.
- Increased timetable PNG render scale; semester images are rendered week by
  week and streamed through a background isolate to avoid very tall
  `Picture.toImage()` textures and large uncompressed long-image allocations
  that could make the app unresponsive or crash.
- Timetable image export shares the timetable page's holiday display settings,
  so weekly and semester images can show, dim, or hide ordinary courses and
  exams according to the selected modes.
- Added `startMinuteOfDay` and `endMinuteOfDay` to class sessions while keeping
  the old section columns as derived compatibility data.
- Added a manual hidden flag to exam schedules. Local backups now export and
  restore exact minute fields, exam hidden state, and holiday display settings.

### Interface

- Fixed `课格（Crid）` appearing twice in the open-source license list; the top
  card is now the single entry point for the app's own license.
- Removed the duplicate title card from license details so the license body
  starts cleanly below the page title.
- Fixed the mobile course-details bottom sheet so its enter and exit motion no
  longer feels abrupt.
- Fixed the missing background scrim for the course-details sheet; the scrim
  covers the top bar and content area, leaves the bottom navigation uncovered,
  and only the uncovered bottom navigation remains interactive.
- Fixed course-details bottom sheets not sitting against the bottom navigation
  area and prevented the underlying timetable from sliding horizontally while
  the sheet opens.
- Fixed week swipes changing the visible time range mid-swipe because adjacent
  weeks kept separate vertical scroll positions.
- Fixed bottom timetable sections such as Today's Courses being widened with
  the main timetable grid; those sections now keep the standard page inset.
- Adjusted timetable date-header height, exported image date-header height, and
  the right-side alignment of the edit/close buttons in course details.

### Release

- Changed the app version to `1.1.0-release+2` and the Windows MSIX version to
  `1.1.0.0`.
- This overwrite release keeps the app version and Windows MSIX version
  unchanged and regenerates the `v1.1.0-release` artifacts.
- Updated Simplified Chinese, Traditional Chinese, and English README files
  with the latest official release and artifact filenames.

Verified for this release:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release --build-name=1.1.0-release --build-number=2`
- `flutter build apk --release --split-per-abi --build-name=1.1.0-release --build-number=2`
- `flutter build windows --release --build-name=1.1.0-release --build-number=2`
- `dart run msix:create --certificate-password <local certificate password>`

## 1.0.1-release - 2026-06-05

### Import

- Added KINGOSOFT academic-system exam schedule import from `.mht`, `.mhtml`, and `.pdf` exports.
- Added exam schedule import by pasting text copied from the academic system.
- Fixed imported exam schedules being saved to the exam list but not appearing in the timetable week view.
- Kept `.xls` timetable import and removed wording for unsupported `.html` exam schedule fixtures that do not contain extractable timetables.

### Data

- Added local backup of app data and settings to a selected directory.
- Added restore from a local backup file.

### Reminders

- Refactored the class reminder window and fixed negative countdown text after a class has started.
- Added multiple preset reminder offsets, custom reminder offsets, Do Not Disturb bypass, and vibration behavior for silent mode.
- Renamed "Vibration reminders" to "Mute reminder sound" so it is clear that default reminders also vibrate and this option only disables sound.
- Kept Android class reminders on a high-priority notification channel while keeping the separate persistent background-service notification low priority.
- Declared `USE_EXACT_ALARM` on Android 13 and later, kept `SCHEDULE_EXACT_ALARM` for Android 12/12L, and retained the fallback path to inexact scheduling when exact alarms are unavailable.

### Interface And Documentation

- Refactored the open-source licenses page to use a lazy list and separate detail pages instead of eagerly expanding all license text, reducing stutter when opening the list and viewing details.
- Reworded visible license copy from "Third-party licenses" to "Open-source licenses" and added Crid's full Apache License 2.0 text to the license list.
- Removed the "X license paragraphs" counters from license lists and detail pages, and consistently uses the localized app license name such as "课格（Crid）", "課格（Crid）", or "Crid".
- Adjusted course info menus and dialog scrims so light and dark modes use more harmonious Material 3 overlay colors.
- Adjusted the mobile course-details sheet so details opened from a course block stay above the bottom navigation bar.
- Restored the mobile course-details sheet enter/exit animation and background shadow, and matched the sheet background to the bottom navigation bar.
- Updated Simplified Chinese, Traditional Chinese, and English README files.

### Privacy

- Anonymized personal information and real academic-system domains in KINGOSOFT exam schedule fixtures, timetable fixtures, and the PDF fixture.

### Release

- Bumped the app version to `1.0.1-release+2` and the Windows MSIX version to `1.0.1.0`.
- Updated Dart/Flutter dependencies to the latest stable versions resolvable by the current dependency graph.
- Migrated the Android app module away from directly applying the Kotlin Gradle Plugin, reducing future Flutter build compatibility risk.
- Android release artifacts no longer include an AAB; only the universal APK and split-per-ABI APKs are published.
- This patch release keeps the app version and Windows MSIX version unchanged and regenerates the `v1.0.1-release` artifacts.

Verified for this release:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release --build-name=1.0.1-release --build-number=2`
- `flutter build apk --release --split-per-abi --build-name=1.0.1-release --build-number=2`
- `flutter build windows --release --build-name=1.0.1-release --build-number=2`
- `dart run msix:create`

## 1.0.0-release - 2026-05-28

### First Official Release

- Started the first official release line after treating all previous release artifacts as beta builds.
- Reset the public app version to `1.0.0-release+1` and the Windows MSIX version to `1.0.0.0`.
- Changed the Android application ID and Windows MSIX identity to the release package identity `app.crid.release`.
- Moved previous release artifacts to the ignored `beta_releases/` directory and created a new ignored `releases/` directory for official release artifacts.

### Release Signing

- Added Android release signing with a locally generated release keystore.
- Added Windows MSIX signing metadata and generated the v1.0.0-release Windows MSIX package with a local code-signing certificate.

### Privacy

- Replaced tracked real import fixtures with equivalent synthetic test fixtures.
- Kept private original fixtures only in an ignored local backup directory.

Verified for this release:

- `flutter test`
- `flutter build apk --release --build-name=1.0.0-release --build-number=1`
- `flutter build apk --release --split-per-abi --build-name=1.0.0-release --build-number=1`
- `flutter build appbundle --release --build-name=1.0.0-release --build-number=1`
- `flutter build windows --release --build-name=1.0.0-release --build-number=1`
- `dart run msix:create`

## 1.0.32 - 2026-05-28

### App Identity

- Moved app-facing copy, Dart package imports, Android identity, Windows binary metadata, export filenames, and local database filename to 课格 / Crid.

### Holiday Mode

- Marked dates hidden by the enabled statutory-holiday mode as muted rest columns in the timetable grid.
- Applied the same holiday-rest column marking to current-week and full-semester PNG exports.

### Release

- Bumped the app version to `1.0.32+33` and the Windows MSIX version to `1.0.32.0`.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build windows --release`

## 1.0.31 - 2026-05-28

### App Identity

- Renamed app-facing and platform identity resources to 课格 / Crid, including Dart package imports, Android package identity, Windows binary metadata, export filenames, and local database filename.
- Removed old school-specific naming from resource paths, test fixtures, documentation, and generated localization output.

### Release

- Bumped the app version to `1.0.31+32` and the Windows MSIX version to `1.0.31.0`.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.30 - 2026-05-28

### Android Notifications

- Rebuilt class reminders when the app returns to the foreground, including after Android settings changes.
- Increased the rolling class-reminder window to four weeks to reduce reminder gaps when the app is not opened frequently.
- Retried scheduled class reminders with inexact alarms if exact alarm scheduling is rejected by the platform or permission state.
- Reacted to exact-alarm permission state changes so the background runtime can recover after Android settings updates.

### Settings And Localization

- Simplified the Android background-running settings card and kept only the controls users need to keep reminders stable.
- Refined settings copy across supported locales, including holiday adjustment wording that uses the more familiar Chinese term for 调休.
- Clarified that Android background running uses a silent ongoing notification, and kept the battery and autostart settings entry points.
- Localized reminder notifications, import warnings, Android service text, and month labels.
- Added a third-party open-source licenses entry in Settings.

### Release

- Bumped the app version to `1.0.30+31` and the Windows MSIX version to `1.0.30.0`.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create --signtool-options "/fd SHA256 /f <test_certificate.pfx> /p 1234"`

## 1.0.27 - 2026-05-26

### Navigation

- Moved Import, Conflict Handling, Add/Edit Course, Export, and Settings into independent top-level pages so the bottom bar and navigation rail stay hidden on those workflows.
- Switched Android page transitions to the iOS-style horizontal route animation.

### Android

- Changed reminders to default off for new installs and request notification plus exact-alarm permissions only when the user enables reminders.
- Kept class reminders and the persistent background runtime notification on separate notification channels.
- Rebuilt launcher icons with Material You adaptive, themed, light, and dark resources.

### Course Editing

- Removed prefilled course name, teacher, and location text from the new-course form.

### Release

- Bumped the app version to `1.0.27+28` and the Windows MSIX version to `1.0.27.0`.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.26 - 2026-05-26

### Android

- Disabled predictive back support and removed the predictive-back destination scrim.
- Reworked Android notification permissions, exact-alarm handling, scheduled class reminders, boot rescheduling, and the persistent background-service notification.
- Added Android background-service status checks and settings entry points for exact alarms, notification access, and OEM autostart/background restrictions.
- Added a dedicated notification status icon and refreshed Android themed launcher-icon resources for safer Android 16 rendering.

### Timetable And Export

- Prevented timetable and plans destination switching from flashing the revealed background.
- Fixed semester image export so it stops at the last week containing courses instead of exporting an empty final week.
- Fixed Android exported-file opening by keeping an app-cache copy for the Open action while still saving to the user-selected destination.

### Release

- Bumped the app version to `1.0.26+27` and the Windows MSIX version to `1.0.26.0`.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.25 - 2026-05-26

### Navigation

- Fixed Android back behavior from Plans so it returns to the timetable instead of exiting the app.
- Added a route-animation-driven predictive-back scrim over the revealed destination surface, following Flutter's native predictive back transition model.
- Gave Add Course and Edit Course distinct page titles.

### Timetable

- Made the timetable time column lighter than the course grid surface.
- Added a Hidden Courses recovery section to the Plans page.
- Added Restore actions to deleted-course, deleted-plan, and deleted-semester snackbars.

### Export

- Reworked image export styling to match the current Material 3 surface and course-card treatment.
- Changed semester image export to stitch week views from week 1 through the first empty week or the optional semester end week, whichever comes first.
- Fixed exported course-card text overlap and added Open actions after saving exported files.

### Localization And Icons

- Localized generated default semester names and kept non-manually-edited names in sync when the app language changes.
- Rebalanced import chip icon alignment and regenerated launcher icons with Android adaptive-icon safe spacing and a centered visual mass.

### Release

- Bumped the app version to `1.0.25+26` and the Windows MSIX version to `1.0.25.0`.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.24 - 2026-05-26

### Material 3 Expressive

- Tightened secondary-page app bar title spacing so Import, Export, and Settings titles sit closer to their back buttons.
- Rebalanced button, chip, badge, and segmented-control color roles so page actions better match each screen while preserving paired light and dark themes.
- Increased the tonal separation between the timetable time column and course grid background.

### Import

- Reworded the import merge flow to use user-facing review and add-to-timetable language instead of staging-oriented terminology.

### Navigation

- Changed Timetable and Plans switching back to same-level destination navigation so Android predictive back no longer reveals the timetable as an abrupt background layer.

### App Icon

- Added a Material 3 Expressive app icon with Android adaptive, round, and monochrome themed-icon resources plus a refreshed Windows icon.
- Added automated icon asset coverage, including Android density checks and a visual-centroid balance check.

### Release

- Bumped the app version to `1.0.24+25` and the Windows MSIX version to `1.0.24.0`.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.23 - 2026-05-26

### Material 3 Expressive

- Lightened the light-mode surface treatment again and adjusted dark-mode paired surfaces to keep the two themes matched.
- Increased the visual separation between the timetable's left time column and the app background with a slightly more distinct tonal surface.
- Aligned the Timetable top-bar Add Course action with adjacent import, export, overflow, and settings buttons.

### Motion

- Slightly shortened shared app micro-motion and menu animation durations again so larger interface transitions feel faster.

### Release

- Bumped the app version to `1.0.23+24` and the Windows MSIX version to `1.0.23.0`.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.22 - 2026-05-26

### Material 3 Expressive

- Lightened the paired light-mode surface treatment again and adjusted dark-mode surface depth in step so the two modes remain visually matched.
- Kept the Today action as a rounded rectangle and preserved the direct Timetable toolbar action order.

### Motion

- Slightly shortened shared app micro-motion and menu animation durations so larger interface transitions feel snappier.
- Changed the Timetable/Plans toolbar action transition to animate only the changing Add Course slot, keeping the persistent Import, Export, and Settings actions stable and preventing button flicker.

### Release

- Bumped the app version to `1.0.22+23` and the Windows MSIX version to `1.0.22.0`.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.21 - 2026-05-26

### Startup

- Removed the offstage Settings page warm-up from app startup so Settings dependencies and layout are loaded only when needed.
- Kept the lightweight shader warm-up path for common Material surfaces and course blocks.

### Material 3 Expressive

- Lightened the course-block Monet tonal palette and relaxed the course contrast thresholds slightly while preserving readable light foreground text.
- Reworked light and dark theme surfaces as a paired Material 3 Expressive treatment: light surfaces lift toward white, dark surfaces sink toward black, and both keep the same dynamic color roles.
- Lightened the paired surface treatment further for the Timetable shell while keeping dark mode depth in step with the light mode changes.
- Added matching component role coverage for card, app bar, navigation, input, chip, progress, and floating action surfaces.
- Changed the "Today" floating action into a rounded rectangle instead of the default extended pill.
- Changed the Timetable top bar so Add Course, Import, and Export are directly visible except on extremely narrow screens, with Add Course placed before Import and Export.

### Navigation Motion

- Restored native Material route transitions between Timetable and Plans.
- Changed core destination navigation to push forward and pop backward so the route motion follows the physical direction implied by the selected tab.
- Added a native Flutter micro-animation for the top-right action area when switching between Timetable and Plans.
- Slightly shortened app micro-motion and menu animation durations so interface transitions feel more responsive.

### Performance

- Precomputed each semester week's visible course list, dates, and overlap layout before PageView swipes so horizontal week switching spends less work during the gesture.
- Preserved existing timetable visuals while keeping week pages behind repaint boundaries and keep-alive caching.

### Tests

- Added theme coverage for paired light/dark depth and matching component roles.
- Added widget coverage for Timetable top-bar action order and the rounded-rectangle Today action.
- Re-ran theme, course color, timetable swipe, navigation, and full regression coverage.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.20 - 2026-05-26

### Navigation Motion

- Fixed the flash when switching between Timetable and Plans by treating the two core destinations as tab-level navigation instead of route push/pop transitions.
- Kept native route transitions for secondary tools while removing the core-tab page transition that could briefly expose the shell background.

### Performance

- Added idle-time warm-up for the Settings page so first open builds its settings cards, async state branches, and layout offstage before the visible route is opened.
- Kept timetable course block positioning animation and internal course-card scrolling intact while retaining week-page caching for smoother horizontal week swipes.

### Tests

- Re-ran adaptive shell, settings, timetable swipe, and course-card coverage after the navigation and warm-up changes.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.19 - 2026-05-25

### Navigation Motion

- Reworked route transitions so forward navigation, reverse navigation, nested pages, and source returns move in the direction implied by their route relationship.
- Aligned top-bar title and action transitions with page motion instead of switching independently.
- Added a custom left-edge back preview that plays the opening segment of the return animation before completing the back action.

### Microinteractions

- Added shared press and hover scale feedback for toolbar actions, week navigation, floating actions, course blocks, and course list rows.
- Added subtle pop entrance motion for course detail dialogs and bottom sheets.
- Extended the Holiday adjustment Material 3 Expressive menu with animated trigger feedback, selected item feedback, and arrow rotation.

### Tests

- Added route motion coverage for core navigation, detail returns, and nested pages.
- Added back preview gesture coverage, including edge-only behavior.
- Added shared microinteraction coverage to verify tap handling is preserved.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.18 - 2026-05-25

### Settings

- Changed Settings into an independent fullscreen dialog route so the bottom navigation bar and desktop navigation rail stay hidden while Settings is open.
- Changed the top-right Settings action back to a plain icon button without a filled tonal backing.
- Replaced the Holiday adjustment dropdown with a custom Material 3 Expressive menu using rounded surfaces, selected-state treatment, and disabled-state styling.

### Android

- Removed the app's predictive back opt-in and forced the Android page transition back to the non-predictive zoom transition.

### Timetable Colors

- Rebalanced course block colors with higher tone and chroma so they stand apart from the timetable body, timetable header, and app background in light and dark themes.
- Updated same-page course color assignment to choose colors by visual distance, reducing near-duplicate course block colors.

### Tests

- Updated widget coverage for the fullscreen Settings route, plain Settings action, and Holiday adjustment Material menu.
- Added course palette coverage for contrast and visual separation from app and timetable surfaces.
- Added theme coverage to guard against predictive back transitions.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.17 - 2026-05-25

### Navigation

- Moved Settings out of the compact bottom navigation and wide navigation rail into the top-right app bar/header action.
- Preserved source-aware return behavior when opening Settings from Timetable or Plans.

### Material 3 Expressive

- Switched the app color generation to Flutter's expressive dynamic scheme variant with a stronger surface hierarchy.
- Updated app bars, navigation indicators, cards, inputs, icon buttons, filled/outlined buttons, switches, sliders, and snackbars with more expressive Material 3 shapes and states.

### Android Reminders

- Changed class reminders to show `XX 分钟后上课` with course time, location, and teacher details.
- Made Android class reminder notifications ongoing before class and automatically clear at the class start time.
- Reduced persistent background runtime notification interruption with a low-importance, no-sound/no-vibration service channel.
- Added boot/package-replaced recovery for the user-enabled persistent background runtime service.

### Tests

- Updated widget coverage for the top-right Settings entry and core-route back behavior.
- Added reminder notification coverage for ongoing countdown and auto-clear parameters.
- Updated theme coverage for expressive Material 3 surface corners.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.16 - 2026-05-22

### Colors

- Lightened the app surface treatment while staying within the Material You color system.
- Raised timetable course block tones so the palette no longer feels overly dark.
- Kept course blocks on Monet tonal colors with white Monet text.
- Relaxed the course text contrast floor slightly while adding an upper bound to prevent over-dark blocks.

### Tests

- Updated theme and course color tests for the lighter contrast range.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.15 - 2026-05-21

### Navigation

- Fixed the core-tab animation direction when moving from Settings back to Plans.
- Preserved native forward navigation while using a reverse transition for leftward core-tab moves.
- Aligned top-bar title and action motion with the page direction.

### Tests

- Added coverage for the Settings to Plans path and its back behavior.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.14 - 2026-05-21

### Timetable Colors

- Kept every course block foreground on a light Monet neutral tone.
- Rebalanced the course palette to use darker Monet tones that keep light text readable.
- Preserved generic same-page color separation without course-specific rules.

### Tests

- Updated color tests to require light course foregrounds, Monet palette membership, and same-page visual separation.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.13 - 2026-05-20

### Timetable Colors

- Reworked course coloring so repeated slots for the same course stay visually consistent across weeks.
- Added same-page color assignment that avoids nearby hue and grayscale matches while staying within the Monet tonal palette.
- Switched course foreground colors to Monet neutral tones with WCAG AA contrast checks.

### Tests

- Added coverage for same-page color separation and Monet-only foreground/background choices.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.12 - 2026-05-20

### Holiday Mode

- Restored the built-in 2026 China holiday schedule as the preferred source and verified it against the China government notice.
- Kept online holiday fetching for years without built-in data, with local caching after successful fetches.
- Added per-source retry handling before falling back from `holiday.ailcc.com` to `timor.tech`.
- Added Android release internet permission so online holiday data can be fetched outside debug/profile builds.

### Tests

- Added coverage for built-in holiday precedence, source retry, fallback source use, and cached-data recovery.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.11 - 2026-05-20

### Desktop

- Synced desktop navigation and timetable presentation with the Android experience.
- Added a collapsible desktop sidebar so the timetable can reclaim horizontal space on large screens.
- Updated the desktop timetable header to preserve the Android-style title and current-week context.
- Tuned high-resolution desktop timetable layout so the full day grid fits on screen more reliably.

### Tests

- Added widget coverage for desktop primary actions, collapsible navigation, high-resolution timetable fitting, and settings display controls.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.10 - 2026-05-20

### Timetable UI

- Replaced the timetable grid corner header with the current localized month label.
- Highlighted today's date directly in the timetable calendar header.
- Changed the list below the timetable grid to show today's courses instead of the selected week's full course list.
- Increased app surface and input corner radii to better match Material You / MD3 styling.

### Settings

- Added a persisted display setting for following the system theme, forcing light theme, or forcing dark theme.

### Tests

- Added widget coverage for the localized month label, today's course list filtering, and manual dark theme preference.
- Added theme coverage for the larger Material You block and input corner radii.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.9 - 2026-05-20

### Timetable UI

- Darkened the Material You / Monet timetable course palette slightly while keeping light course text.
- Increased the contrast between rounded function-block card backgrounds and the app page background.

### Tests

- Added theme coverage to assert that card blocks visibly separate from the page background.
- Re-ran course color and timetable widget coverage.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.8 - 2026-05-20

### Timetable UI

- Adjusted Material You / Monet course colors to use darker tonal values so timetable course text always renders in light text.
- Added a shared course text color constant and fixed course text rendering to white for timetable blocks and timetable image export.

### Tests

- Updated course color tests to assert that every generated course color meets WCAG AA contrast with light text.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.7 - 2026-05-20

### Timetable UI

- Switched timetable course colors to Material You / Monet-style HCT tonal palettes.
- Added `material_color_utilities` as an explicit dependency so course colors are generated from tonal palettes instead of fixed hand-picked hex values.
- Kept deterministic course color assignment and automatic readable black/white text selection for WCAG AA contrast.

### Tests

- Re-ran course color and timetable widget coverage against the generated tonal palette.

Verified after these changes:

- `flutter analyze --no-pub`
- `flutter test --no-pub`
- `flutter build apk --release --no-pub`
- `flutter build appbundle --release --no-pub`
- `flutter build windows --release --no-pub`
- `dart run msix:create`

## 1.0.6 - 2026-05-20

### Timetable UI

- Replaced the previous high-contrast course palette with a calmer product-style palette while preserving WCAG AA text contrast.
- Removed course-card edge strokes so timetable blocks use clean filled color surfaces.
- Increased timetable row height and allowed course name, location, and teacher fields to wrap across multiple lines.
- Added internal course-card scrolling for extreme text lengths so fields remain available without shrinking text or overflowing.
- Added course-card semantic labels that include the course name, location, and teacher.

### Tests

- Extended narrow-screen course-card coverage to assert that teacher text is also present.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.5 - 2026-05-20

### Timetable UI

- Added native top-bar transitions when switching between the timetable, plans, and settings pages.
- Switched course colors to a high-contrast, colorblind-friendly palette with deterministic assignment for imported and manually created courses.
- Added automatic black/white course-card text selection and subtle card strokes to keep text readable across the full palette.
- Reworked compact course-card layout so title, location, and teacher details use the available block height more aggressively without reducing font size or overflowing.

### Tests

- Added color-palette coverage for uniqueness, deterministic assignment, and WCAG AA text contrast.
- Added narrow-screen widget coverage for dense course-card details without overflow.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.4 - 2026-05-20

### Import Merging

- Fixed imports where the same course has multiple weekly slots so every distinct weekday/period is kept.
- Added support for force-merging time conflicts so concurrent courses can coexist in the same timetable slot.
- Added regression coverage for multi-slot same-course imports and force-merged concurrent courses.

### Timetable UI

- Changed overlapping timetable blocks to render side by side instead of covering each other.
- Hid the Add Course top-bar action on the Plans page.
- Hid Import, Export, and Add Course top-bar actions on the Settings page.
- Fixed the holiday adjustment dropdown overflowing on narrow screens with long labels.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.3 - 2026-05-20

### Import Parsing

- Replaced the BIFF `.xls` heuristic with a cross-platform OLE/BIFF workbook reader that parses worksheet cells directly.
- Added shared schedule-text parsing for real campus timetable entries with per-week location differences.
- Stabilized parsing for the real HTML `.xls`, BIFF `.xls`, and WakeUp `.ics` sample files.
- Removed the simplified table parser fallback and reset import tests to focus on real samples.

### Timetable Data

- New users now start with an empty timetable instead of built-in demo courses.
- Removed the import-center sample loader and bundled demo HTML source.
- Added repository coverage for stable plan selection, editing, and deletion fallback.

### Settings

- Changed the Chinese language-picker label for English to `English`.
- Built in the 2026 China holiday and makeup-workday schedule for offline holiday adjustment.

Verified after these changes:

- `flutter analyze`
- `flutter test`

## 1.0.2 - 2026-05-20

### Holiday Mode

- Added a holiday mode settings card with a legal-holiday switch and adjustment-mode selector.
- Fetches the current year's China holiday schedule from the yearly `holiday.ailcc.com` API on app startup, falls back to `timor.tech` if needed, and uses the local cache when public sources are unavailable.
- Parses generic yearly holiday data instead of relying on a per-year in-app table.
- Caches fetched holiday payloads immediately after they are parsed as usable yearly data.
- Distinguishes legal holidays, adjusted rest days, and makeup workdays from the holiday feed.
- Hides timetable courses on selected holiday dates without deleting course records.
- Applies the same current-week holiday filtering to timetable image export.
- Added regression tests for holiday feed parsing and adjustment-mode hiding rules.

### Bug Fixes

- Prevented duplicate semester/plan deletion prompts and stacked deletion snackbars.
- Changed the unselected timetable-plan badge from "方案" to "选择".
- Added English as a manual language option and generated English localization resources.

### Navigation Animation

- Made app routes explicitly use Material `MaterialPage` transitions instead of custom transition curves.
- Changed editor save/delete completion to prefer native pop animation before falling back to the stored source path.
- Preserved exact import-page source paths when opening conflict handling.
- Changed secondary core destinations to be pushed from their source so system back gestures animate back to the page the user came from.

## 1.0.1 - 2026-05-19

### Internationalization

- Added Flutter `gen_l10n` localization with Simplified Chinese (`zh`, `zh_CN`) and Traditional Chinese (`zh_TW`) resources.
- Wired `MaterialApp.router` to generated localization delegates and supported locales.
- Added locale resolution so `zh_TW`, `zh_HK`, `zh_MO`, and `zh-Hant` systems use Traditional Chinese, while other Chinese locales use Simplified Chinese.
- Localized the main app shell and first-version UI surfaces: timetable, plans, import, conflicts, editor, export, and settings.
- Added a settings-page language selector with system, Simplified Chinese, and Traditional Chinese modes.
- Added widget coverage for Traditional Chinese system locale switching.
- Added widget coverage for manual language preference overriding the system locale.

### Navigation and timetable cleanup

- Reduced compact bottom navigation and wide NavigationRail to the core flows: timetable, plans, and settings.
- Moved import, course creation, and export into the top app bar/header actions.
- Added source-aware return handling for editor, export, settings, and import conflict subpages.
- Added Android back handling so secondary top-level tabs return to the timetable instead of exposing a blank/launcher background mid-gesture.
- Enabled Android predictive back callbacks and Android predictive page transitions for poppable routes.
- Added explicit Android window background colors for light and dark themes.
- Removed the timetable plan comparison feature from the app and development documentation while keeping import conflict handling.
- Rebuilt the home timetable as a seven-day calendar grid that fits Monday through Sunday without horizontal scrolling.
- Moved week display and previous/next week controls into the top bar and removed the large week summary card.
- Added day-of-month labels to the timetable weekday header and a floating "back to today" action when viewing a non-current week.
- Added first-screen and PNG export support for single-period and odd-length course blocks.
- Updated ICS time inference to map exact lesson times to arbitrary section ranges instead of only two-section blocks.
- Added plan and semester editing/deletion flows, including explicit semester start-date selection and optional semester end dates.
- Added a Drift migration for persisted semester end dates.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`

### Progress after `0039b94`

Implemented:

- Wired the UI to a Drift-backed timetable repository for seed recovery, active plan loading, course save/delete, import commits, conflict resolution, reminders, ICS export, and import history.
- Added a controlled BIFF `.xls` adapter that extracts course-like records from the bundled sample instead of returning warning-only output.
- Changed import preview to compare against the current active plan instead of an empty timetable.
- Persisted import batches, source records, added sessions, and pending diff/conflict records.
- Replaced the static conflict page with live pending conflicts and actions for keep current, use imported, keep both, and manual edit status.
- Made course details open the editor for the selected session; saving edits now updates the same course/session and the editor can delete a session.
- Persisted reminder enablement and lead time through `ReminderRules`, and rebuilt rolling reminders after settings, imports, edits, and active-plan switches.
- Initialized local notifications and requested Android notification permission when supported.
- Wired current active plan ICS export and current-week PNG export through save-file flows.
- Replaced static import history with persisted recent batches.
- Fixed timetable header to show the active semester/plan and allowed multiple sessions in one visible time cell.
- Added active-semester first-week Monday editing from the import center.
- Added semester creation and semester switching from plan management.
- Added full-semester PNG export alongside current-week PNG export.
- Updated Android package identity to `app.crid` and app label to `Crid`.
- Added MSIX packaging with project identity and verified MSIX creation.

Verified after these changes:

- `flutter analyze`
- `flutter test`
- `flutter build windows --debug`
- `flutter build apk --debug`
- `flutter build apk --release`
- `flutter build appbundle --release`
- `dart run msix:create`

Remaining constraints:

- BIFF `.xls` support is still an isolated heuristic adapter, not a full BIFF8 worksheet decoder.
- `.xls` import uses the active semester's first-week Monday; it can now be edited before import from the import center.
- Android release signing still uses the scaffold debug signing config for local QA and must be replaced before external distribution.

### Baseline status after `1d2c268`

The repository now contains the first Flutter baseline for the Crid app.

Implemented:

- Android and Windows Flutter project scaffold.
- Material 3 app shell with Riverpod and `go_router`.
- Adaptive navigation: compact bottom navigation and wide-screen navigation rail.
- Timetable, plan management, import center, conflict diff, course editor, export, and settings surfaces.
- Core time helpers for campus lesson periods and week parity.
- Import type detection for `.ics`, HTML-table `.xls`, and BIFF `.xls`.
- Parser adapters for HTML-table `.xls`, `.ics`, and isolated BIFF fallback.
- In-memory merge engine for duplicates, diffs, additions, and time conflicts.
- Drift schema for semesters, plans, courses, sessions, import batches, source records, conflicts, and reminder rules.
- ICS export service using `Asia/Shanghai`.
- Reminder rolling-window calculation and local notification adapter boundary.
- Image export service boundary around `RepaintBoundary`.
- Regression tests for import logic, export/reminder logic, and adaptive UI smoke coverage.

Verified at baseline:

- `flutter analyze`
- `flutter test`
- `flutter build windows --debug`
- `flutter build apk --debug`

Known gaps to close before the documented first-version scope is complete:

- BIFF `.xls` parsing is warning-only and does not extract real courses yet.
- UI state is mostly in-memory; Drift is not wired into repositories or user workflows.
- Import staging preview parses files but does not persist batches, source records, or merged course sessions.
- Conflict actions are visual placeholders.
- Course editor validates fields but does not persist edits.
- Multi-semester and multi-plan management is visual only.
- Active plan switching is not backed by storage.
- Dual timetable comparison is not implemented beyond the import diff page.
- Reminder initialization, permissions, and rebuild triggers are not wired into app lifecycle.
- Export page is not wired to file-save flows or selected plans.
- Android package identity, notification permission, Windows MSIX identity, and release assets are still default/scaffold values.
