import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课格'**
  String get appTitle;

  /// No description provided for @navTimetable.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课表'**
  String get navTimetable;

  /// No description provided for @navPlans.
  ///
  /// In zh_Hans, this message translates to:
  /// **'方案'**
  String get navPlans;

  /// No description provided for @navImport.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导入'**
  String get navImport;

  /// No description provided for @navEditor.
  ///
  /// In zh_Hans, this message translates to:
  /// **'编辑'**
  String get navEditor;

  /// No description provided for @navExport.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导出'**
  String get navExport;

  /// No description provided for @navSettings.
  ///
  /// In zh_Hans, this message translates to:
  /// **'设置'**
  String get navSettings;

  /// No description provided for @collapseSidebar.
  ///
  /// In zh_Hans, this message translates to:
  /// **'收起侧边栏'**
  String get collapseSidebar;

  /// No description provided for @expandSidebar.
  ///
  /// In zh_Hans, this message translates to:
  /// **'展开侧边栏'**
  String get expandSidebar;

  /// No description provided for @addCourse.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新增课程'**
  String get addCourse;

  /// No description provided for @backToTimetable.
  ///
  /// In zh_Hans, this message translates to:
  /// **'返回课表'**
  String get backToTimetable;

  /// No description provided for @loadingTimetable.
  ///
  /// In zh_Hans, this message translates to:
  /// **'正在加载课表'**
  String get loadingTimetable;

  /// No description provided for @failedToLoadTimetable.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课表加载失败：{error}'**
  String failedToLoadTimetable(Object error);

  /// No description provided for @weekNumber.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第 {week} 周'**
  String weekNumber(int week);

  /// No description provided for @visibleSessionsThisWeek.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本周 {count} 个可见安排'**
  String visibleSessionsThisWeek(int count);

  /// No description provided for @previousWeek.
  ///
  /// In zh_Hans, this message translates to:
  /// **'上一周'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In zh_Hans, this message translates to:
  /// **'下一周'**
  String get nextWeek;

  /// No description provided for @timeHeader.
  ///
  /// In zh_Hans, this message translates to:
  /// **'时间'**
  String get timeHeader;

  /// No description provided for @thisWeek.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本周课程'**
  String get thisWeek;

  /// No description provided for @todayCourses.
  ///
  /// In zh_Hans, this message translates to:
  /// **'今日课程'**
  String get todayCourses;

  /// No description provided for @noCoursesToday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'今天没有课程'**
  String get noCoursesToday;

  /// No description provided for @edit.
  ///
  /// In zh_Hans, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @dayMon.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周一'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周二'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周三'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周四'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周五'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周六'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周日'**
  String get daySun;

  /// No description provided for @dayNumber.
  ///
  /// In zh_Hans, this message translates to:
  /// **'星期 {weekday}'**
  String dayNumber(int weekday);

  /// No description provided for @periodsValue.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第 {start}-{end} 节'**
  String periodsValue(int start, int end);

  /// No description provided for @weeksValue.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第 {start}-{end} 周'**
  String weeksValue(int start, int end);

  /// No description provided for @failedToLoadPlans.
  ///
  /// In zh_Hans, this message translates to:
  /// **'方案加载失败：{error}'**
  String failedToLoadPlans(Object error);

  /// No description provided for @semesters.
  ///
  /// In zh_Hans, this message translates to:
  /// **'学期'**
  String get semesters;

  /// No description provided for @add.
  ///
  /// In zh_Hans, this message translates to:
  /// **'添加'**
  String get add;

  /// No description provided for @firstMonday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第一周周一：{date}'**
  String firstMonday(String date);

  /// No description provided for @current.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前'**
  String get current;

  /// No description provided for @timetablePlans.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课表方案'**
  String get timetablePlans;

  /// No description provided for @activeForRemindersAndExport.
  ///
  /// In zh_Hans, this message translates to:
  /// **'用于提醒和默认导出'**
  String get activeForRemindersAndExport;

  /// No description provided for @tapToMakeActive.
  ///
  /// In zh_Hans, this message translates to:
  /// **'点击设为当前方案'**
  String get tapToMakeActive;

  /// No description provided for @active.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前'**
  String get active;

  /// No description provided for @plan.
  ///
  /// In zh_Hans, this message translates to:
  /// **'方案'**
  String get plan;

  /// No description provided for @selectPlan.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择'**
  String get selectPlan;

  /// No description provided for @newPlan.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新建方案'**
  String get newPlan;

  /// No description provided for @semesterName.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{year}-{month} 学期'**
  String semesterName(int year, String month);

  /// No description provided for @planName.
  ///
  /// In zh_Hans, this message translates to:
  /// **'方案 {number}'**
  String planName(int number);

  /// No description provided for @courseSessionNotFound.
  ///
  /// In zh_Hans, this message translates to:
  /// **'找不到课程安排。'**
  String get courseSessionNotFound;

  /// No description provided for @newCourse.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新增课程'**
  String get newCourse;

  /// No description provided for @editCourse.
  ///
  /// In zh_Hans, this message translates to:
  /// **'编辑课程'**
  String get editCourse;

  /// No description provided for @hideThisSession.
  ///
  /// In zh_Hans, this message translates to:
  /// **'隐藏此安排'**
  String get hideThisSession;

  /// No description provided for @hideThisSessionSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'隐藏后课程保留在方案中，但不会显示在周视图里。'**
  String get hideThisSessionSubtitle;

  /// No description provided for @deleteSession.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除安排'**
  String get deleteSession;

  /// No description provided for @saveCourse.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保存课程'**
  String get saveCourse;

  /// No description provided for @courseName.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课程名称'**
  String get courseName;

  /// No description provided for @teacher.
  ///
  /// In zh_Hans, this message translates to:
  /// **'教师'**
  String get teacher;

  /// No description provided for @location.
  ///
  /// In zh_Hans, this message translates to:
  /// **'地点'**
  String get location;

  /// No description provided for @notes.
  ///
  /// In zh_Hans, this message translates to:
  /// **'备注'**
  String get notes;

  /// No description provided for @weekday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'星期'**
  String get weekday;

  /// No description provided for @startPeriod.
  ///
  /// In zh_Hans, this message translates to:
  /// **'开始节次'**
  String get startPeriod;

  /// No description provided for @endPeriod.
  ///
  /// In zh_Hans, this message translates to:
  /// **'结束节次'**
  String get endPeriod;

  /// No description provided for @startWeek.
  ///
  /// In zh_Hans, this message translates to:
  /// **'开始周'**
  String get startWeek;

  /// No description provided for @endWeek.
  ///
  /// In zh_Hans, this message translates to:
  /// **'结束周'**
  String get endWeek;

  /// No description provided for @allWeeks.
  ///
  /// In zh_Hans, this message translates to:
  /// **'全部'**
  String get allWeeks;

  /// No description provided for @oddWeeks.
  ///
  /// In zh_Hans, this message translates to:
  /// **'单周'**
  String get oddWeeks;

  /// No description provided for @evenWeeks.
  ///
  /// In zh_Hans, this message translates to:
  /// **'双周'**
  String get evenWeeks;

  /// No description provided for @requiredField.
  ///
  /// In zh_Hans, this message translates to:
  /// **'必填'**
  String get requiredField;

  /// No description provided for @weekNumberValidation.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请输入 1-30'**
  String get weekNumberValidation;

  /// No description provided for @courseSaved.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已保存 {course}：星期 {weekday}，第 {start}-{end} 节。'**
  String courseSaved(String course, int weekday, int start, int end);

  /// No description provided for @courseSessionDeleted.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课程安排已删除。'**
  String get courseSessionDeleted;

  /// No description provided for @restore.
  ///
  /// In zh_Hans, this message translates to:
  /// **'恢复'**
  String get restore;

  /// No description provided for @courseRestored.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课程已恢复'**
  String get courseRestored;

  /// No description provided for @importCenter.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导入中心'**
  String get importCenter;

  /// No description provided for @importCenterSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'支持教务系统导出的课表文件，也可以导入日历文件。'**
  String get importCenterSubtitle;

  /// No description provided for @chooseFile.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择文件'**
  String get chooseFile;

  /// No description provided for @loadSample.
  ///
  /// In zh_Hans, this message translates to:
  /// **'加载样例'**
  String get loadSample;

  /// No description provided for @openDiff.
  ///
  /// In zh_Hans, this message translates to:
  /// **'查看需确认课程'**
  String get openDiff;

  /// No description provided for @stagingPreview.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导入预览'**
  String get stagingPreview;

  /// No description provided for @merged.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已加入课表'**
  String get merged;

  /// No description provided for @waiting.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请选择文件'**
  String get waiting;

  /// No description provided for @notCommitted.
  ///
  /// In zh_Hans, this message translates to:
  /// **'可导入'**
  String get notCommitted;

  /// No description provided for @parsedCount.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{count} 条解析结果'**
  String parsedCount(int count);

  /// No description provided for @newCount.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{count} 条新增'**
  String newCount(int count);

  /// No description provided for @changeCount.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{count} 处变化'**
  String changeCount(int count);

  /// No description provided for @conflictCount.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{count} 个冲突'**
  String conflictCount(int count);

  /// No description provided for @applyStagingMerge.
  ///
  /// In zh_Hans, this message translates to:
  /// **'加入课表'**
  String get applyStagingMerge;

  /// No description provided for @emptyPreview.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择课表文件或加载样例，先预览将要导入的课程。'**
  String get emptyPreview;

  /// No description provided for @importFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导入失败：{error}'**
  String importFailed(Object error);

  /// No description provided for @committedSummary.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已加入 {added} 个新安排；{diffs} 处变化和 {conflicts} 个时间重叠可继续确认。'**
  String committedSummary(int added, int diffs, int conflicts);

  /// No description provided for @importWarningUnsupportedFileType.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂不支持这个文件类型，请选择课表表格或日历文件。'**
  String get importWarningUnsupportedFileType;

  /// No description provided for @importWarningWorkbookReadFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无法读取这个 .xls 文件，请确认文件没有损坏。'**
  String get importWarningWorkbookReadFailed;

  /// No description provided for @importWarningNoCompleteXlsRows.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已识别为课表文件，但没有找到完整课程。'**
  String get importWarningNoCompleteXlsRows;

  /// No description provided for @importWarningXlsParsedSessions.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已从表格中识别 {count} 个课程安排。'**
  String importWarningXlsParsedSessions(int count);

  /// No description provided for @importWarningNoCoursesFromHtml.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有从表格中识别出课程。'**
  String get importWarningNoCoursesFromHtml;

  /// No description provided for @importWarningDecodedWithFallback.
  ///
  /// In zh_Hans, this message translates to:
  /// **'文件编码已自动转换。'**
  String get importWarningDecodedWithFallback;

  /// No description provided for @importWarningFragmentMissingName.
  ///
  /// In zh_Hans, this message translates to:
  /// **'有一段课程信息缺少课程名称，已跳过。'**
  String get importWarningFragmentMissingName;

  /// No description provided for @importWarningMissingWeekday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'有一条课程时间缺少星期，已跳过。'**
  String get importWarningMissingWeekday;

  /// No description provided for @importWarningMissingPeriod.
  ///
  /// In zh_Hans, this message translates to:
  /// **'有一条课程时间缺少节次，已跳过。'**
  String get importWarningMissingPeriod;

  /// No description provided for @importWarningMissingWeeks.
  ///
  /// In zh_Hans, this message translates to:
  /// **'有一条课程时间缺少周次，已跳过。'**
  String get importWarningMissingWeeks;

  /// No description provided for @importWarningNoCompleteEntries.
  ///
  /// In zh_Hans, this message translates to:
  /// **'检测到课程时间文本，但没有识别出完整课程。'**
  String get importWarningNoCompleteEntries;

  /// No description provided for @importWarningIcsParseFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无法读取这个日历文件，请确认文件格式正确。'**
  String get importWarningIcsParseFailed;

  /// No description provided for @importWarningSkippedIcsEvent.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日历中有一条事件缺少课程名称或时间，已跳过。'**
  String get importWarningSkippedIcsEvent;

  /// No description provided for @importWarningIcsRuleFallback.
  ///
  /// In zh_Hans, this message translates to:
  /// **'有一条重复课程无法完整展开，已先按单次课程导入。'**
  String get importWarningIcsRuleFallback;

  /// No description provided for @importWarningGenericError.
  ///
  /// In zh_Hans, this message translates to:
  /// **'文件中有内容无法读取。'**
  String get importWarningGenericError;

  /// No description provided for @importWarningGenericWarning.
  ///
  /// In zh_Hans, this message translates to:
  /// **'文件中有部分内容未能识别。'**
  String get importWarningGenericWarning;

  /// No description provided for @importWarningGenericInfo.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导入时已自动处理部分文件内容。'**
  String get importWarningGenericInfo;

  /// No description provided for @course.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课程'**
  String get course;

  /// No description provided for @time.
  ///
  /// In zh_Hans, this message translates to:
  /// **'时间'**
  String get time;

  /// No description provided for @weeks.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周次'**
  String get weeks;

  /// No description provided for @recentBatches.
  ///
  /// In zh_Hans, this message translates to:
  /// **'最近导入'**
  String get recentBatches;

  /// No description provided for @failedToLoadHistory.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导入历史加载失败：{error}'**
  String failedToLoadHistory(Object error);

  /// No description provided for @noImportBatchesYet.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无导入记录'**
  String get noImportBatchesYet;

  /// No description provided for @committedImportsAppearHere.
  ///
  /// In zh_Hans, this message translates to:
  /// **'完成导入后会显示在这里。'**
  String get committedImportsAppearHere;

  /// No description provided for @batchSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{type} - {summary} - {date}'**
  String batchSubtitle(String type, String summary, String date);

  /// No description provided for @failedToLoadConflicts.
  ///
  /// In zh_Hans, this message translates to:
  /// **'冲突加载失败：{error}'**
  String failedToLoadConflicts(Object error);

  /// No description provided for @noPendingConflicts.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无需要确认的导入课程。'**
  String get noPendingConflicts;

  /// No description provided for @conflictHandling.
  ///
  /// In zh_Hans, this message translates to:
  /// **'冲突处理'**
  String get conflictHandling;

  /// No description provided for @conflictHandlingSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请确认导入课程中需要选择的变化和时间重叠。'**
  String get conflictHandlingSubtitle;

  /// No description provided for @changedFieldsCount.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{count} 处字段变化'**
  String changedFieldsCount(int count);

  /// No description provided for @timeConflictsCount.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{count} 个时间冲突'**
  String timeConflictsCount(int count);

  /// No description provided for @pendingCount.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{count} 项需确认'**
  String pendingCount(int count);

  /// No description provided for @conflict.
  ///
  /// In zh_Hans, this message translates to:
  /// **'冲突'**
  String get conflict;

  /// No description provided for @changed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已变化'**
  String get changed;

  /// No description provided for @currentValue.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前'**
  String get currentValue;

  /// No description provided for @importedValue.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导入'**
  String get importedValue;

  /// No description provided for @keepCurrent.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保留当前'**
  String get keepCurrent;

  /// No description provided for @useImported.
  ///
  /// In zh_Hans, this message translates to:
  /// **'采用导入'**
  String get useImported;

  /// No description provided for @keepBoth.
  ///
  /// In zh_Hans, this message translates to:
  /// **'两者共存'**
  String get keepBoth;

  /// No description provided for @forceMerge.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保留重叠课程'**
  String get forceMerge;

  /// No description provided for @manualEdit.
  ///
  /// In zh_Hans, this message translates to:
  /// **'手动编辑'**
  String get manualEdit;

  /// No description provided for @conflictMarked.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已选择：{action}。'**
  String conflictMarked(String action);

  /// No description provided for @courseSummary.
  ///
  /// In zh_Hans, this message translates to:
  /// **'星期 {weekday}，第 {period} 节，{weeks}，{teacher}，{location}'**
  String courseSummary(
    int weekday,
    String period,
    String weeks,
    String teacher,
    String location,
  );

  /// No description provided for @weekUnknown.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周次未知'**
  String get weekUnknown;

  /// No description provided for @teacherTbd.
  ///
  /// In zh_Hans, this message translates to:
  /// **'教师待定'**
  String get teacherTbd;

  /// No description provided for @locationTbd.
  ///
  /// In zh_Hans, this message translates to:
  /// **'地点待定'**
  String get locationTbd;

  /// No description provided for @changedFields.
  ///
  /// In zh_Hans, this message translates to:
  /// **'变化：{fields}'**
  String changedFields(String fields);

  /// No description provided for @timeOverlap.
  ///
  /// In zh_Hans, this message translates to:
  /// **'时间重叠'**
  String get timeOverlap;

  /// No description provided for @icsCalendarExport.
  ///
  /// In zh_Hans, this message translates to:
  /// **'ICS 日历导出'**
  String get icsCalendarExport;

  /// No description provided for @icsCalendarExportSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'按北京时间导出，可导入系统日历。'**
  String get icsCalendarExportSubtitle;

  /// No description provided for @exportIcs.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导出 .ics'**
  String get exportIcs;

  /// No description provided for @currentWeekImage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前周图片'**
  String get currentWeekImage;

  /// No description provided for @currentWeekImageSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'生成当前活动周的 PNG 课表快照。'**
  String get currentWeekImageSubtitle;

  /// No description provided for @fullSemesterImage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'整学期图片'**
  String get fullSemesterImage;

  /// No description provided for @fullSemesterImageSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'生成包含所有课程周次范围的 PNG 总览。'**
  String get fullSemesterImageSubtitle;

  /// No description provided for @exportPng.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导出 PNG'**
  String get exportPng;

  /// No description provided for @exportTimetableCalendar.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导出课程日历'**
  String get exportTimetableCalendar;

  /// No description provided for @exportTimetableImage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导出课表图片'**
  String get exportTimetableImage;

  /// No description provided for @exportSemesterTimetableImage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导出整学期课表图片'**
  String get exportSemesterTimetableImage;

  /// No description provided for @exportedPath.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已导出 {path}'**
  String exportedPath(String path);

  /// No description provided for @openExportedFile.
  ///
  /// In zh_Hans, this message translates to:
  /// **'打开'**
  String get openExportedFile;

  /// No description provided for @preparingExport.
  ///
  /// In zh_Hans, this message translates to:
  /// **'正在准备导出'**
  String get preparingExport;

  /// No description provided for @openExportedFileFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无法打开文件：{message}'**
  String openExportedFileFailed(String message);

  /// No description provided for @fullSemester.
  ///
  /// In zh_Hans, this message translates to:
  /// **'整学期'**
  String get fullSemester;

  /// No description provided for @failedToLoadReminderSettings.
  ///
  /// In zh_Hans, this message translates to:
  /// **'提醒设置加载失败：{error}'**
  String failedToLoadReminderSettings(Object error);

  /// No description provided for @failedToLoadLanguageSetting.
  ///
  /// In zh_Hans, this message translates to:
  /// **'语言设置加载失败：{error}'**
  String failedToLoadLanguageSetting(Object error);

  /// No description provided for @failedToLoadThemeSetting.
  ///
  /// In zh_Hans, this message translates to:
  /// **'主题设置加载失败：{error}'**
  String failedToLoadThemeSetting(Object error);

  /// No description provided for @language.
  ///
  /// In zh_Hans, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In zh_Hans, this message translates to:
  /// **'跟随系统'**
  String get languageSystem;

  /// No description provided for @languageSimplifiedChinese.
  ///
  /// In zh_Hans, this message translates to:
  /// **'简体中文'**
  String get languageSimplifiedChinese;

  /// No description provided for @languageTraditionalChinese.
  ///
  /// In zh_Hans, this message translates to:
  /// **'繁體中文'**
  String get languageTraditionalChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In zh_Hans, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @display.
  ///
  /// In zh_Hans, this message translates to:
  /// **'显示'**
  String get display;

  /// No description provided for @themeModeSystem.
  ///
  /// In zh_Hans, this message translates to:
  /// **'跟随系统'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In zh_Hans, this message translates to:
  /// **'浅色'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In zh_Hans, this message translates to:
  /// **'深色'**
  String get themeModeDark;

  /// No description provided for @denseTimetable.
  ///
  /// In zh_Hans, this message translates to:
  /// **'紧凑课表'**
  String get denseTimetable;

  /// No description provided for @denseTimetableSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第一版已为自适应界面启用紧凑行距。'**
  String get denseTimetableSubtitle;

  /// No description provided for @localData.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本地数据'**
  String get localData;

  /// No description provided for @localDataSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课表、导入记录和提醒设置只保存在本机。'**
  String get localDataSubtitle;

  /// No description provided for @offlineAppSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无需登录；课表和提醒都在本机处理。'**
  String get offlineAppSubtitle;

  /// No description provided for @thirdPartyLicenses.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第三方开源许可'**
  String get thirdPartyLicenses;

  /// No description provided for @thirdPartyLicensesSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'查看 Flutter 和依赖库的开源许可。'**
  String get thirdPartyLicensesSubtitle;

  /// No description provided for @reminders.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课程提醒'**
  String get reminders;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{minutes} 分钟后上课'**
  String reminderNotificationTitle(int minutes);

  /// No description provided for @courseReminders.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课程提醒'**
  String get courseReminders;

  /// No description provided for @courseRemindersSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'课程变化后自动更新未来四周的提醒。'**
  String get courseRemindersSubtitle;

  /// No description provided for @androidBackgroundSettings.
  ///
  /// In zh_Hans, this message translates to:
  /// **'Android 后台运行'**
  String get androidBackgroundSettings;

  /// No description provided for @androidBackgroundSettingsSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'用于在系统限制后台任务时继续处理课程提醒。'**
  String get androidBackgroundSettingsSubtitle;

  /// No description provided for @androidBackgroundUnsupported.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这项设置仅在 Android 设备上可用。'**
  String get androidBackgroundUnsupported;

  /// No description provided for @androidDeviceStatusTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'Android 设备'**
  String get androidDeviceStatusTitle;

  /// No description provided for @androidDeviceStatus.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{manufacturer} {model}，Android {version}'**
  String androidDeviceStatus(String manufacturer, String model, String version);

  /// No description provided for @failedToLoadAndroidBackgroundStatus.
  ///
  /// In zh_Hans, this message translates to:
  /// **'Android 后台状态加载失败：{error}'**
  String failedToLoadAndroidBackgroundStatus(Object error);

  /// No description provided for @persistentBackgroundRuntime.
  ///
  /// In zh_Hans, this message translates to:
  /// **'持续后台运行'**
  String get persistentBackgroundRuntime;

  /// No description provided for @persistentBackgroundRuntimeSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'开启后会在通知栏显示静默常驻通知，用于维持课程提醒的后台任务。'**
  String get persistentBackgroundRuntimeSubtitle;

  /// No description provided for @persistentBackgroundRuntimeAllowed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已获得电池优化豁免，后台任务受系统电池限制的影响会减少。'**
  String get persistentBackgroundRuntimeAllowed;

  /// No description provided for @openNotificationSettings.
  ///
  /// In zh_Hans, this message translates to:
  /// **'通知设置'**
  String get openNotificationSettings;

  /// No description provided for @openBatterySettings.
  ///
  /// In zh_Hans, this message translates to:
  /// **'电池设置'**
  String get openBatterySettings;

  /// No description provided for @openExactAlarmSettings.
  ///
  /// In zh_Hans, this message translates to:
  /// **'精确闹钟权限'**
  String get openExactAlarmSettings;

  /// No description provided for @openAutostartSettings.
  ///
  /// In zh_Hans, this message translates to:
  /// **'自启动设置'**
  String get openAutostartSettings;

  /// No description provided for @requestBatteryExemption.
  ///
  /// In zh_Hans, this message translates to:
  /// **'申请后台运行权限'**
  String get requestBatteryExemption;

  /// No description provided for @leadTime.
  ///
  /// In zh_Hans, this message translates to:
  /// **'提前提醒'**
  String get leadTime;

  /// No description provided for @minutesShort.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{minutes} 分钟'**
  String minutesShort(int minutes);

  /// No description provided for @goToToday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'回到今天'**
  String get goToToday;

  /// No description provided for @delete.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In zh_Hans, this message translates to:
  /// **'清除'**
  String get clear;

  /// No description provided for @semesterEndDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'结束日期：{date}'**
  String semesterEndDate(String date);

  /// No description provided for @semesterStartDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'学期开始日（第一周周一）'**
  String get semesterStartDate;

  /// No description provided for @semesterEndDateOptional.
  ///
  /// In zh_Hans, this message translates to:
  /// **'结束日期（可选）'**
  String get semesterEndDateOptional;

  /// No description provided for @noSemesterEndDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未设置结束日期'**
  String get noSemesterEndDate;

  /// No description provided for @chooseSemesterStartDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择学期开始日（第一周周一）'**
  String get chooseSemesterStartDate;

  /// No description provided for @chooseSemesterEndDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择学期结束日期'**
  String get chooseSemesterEndDate;

  /// No description provided for @addSemester.
  ///
  /// In zh_Hans, this message translates to:
  /// **'添加学期'**
  String get addSemester;

  /// No description provided for @editSemester.
  ///
  /// In zh_Hans, this message translates to:
  /// **'编辑学期'**
  String get editSemester;

  /// No description provided for @deleteSemester.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除学期'**
  String get deleteSemester;

  /// No description provided for @deleteSemesterConfirmation.
  ///
  /// In zh_Hans, this message translates to:
  /// **'确定删除“{name}”及其中的课程表方案吗？'**
  String deleteSemesterConfirmation(String name);

  /// No description provided for @cannotDeleteLastSemester.
  ///
  /// In zh_Hans, this message translates to:
  /// **'至少需要保留一个学期'**
  String get cannotDeleteLastSemester;

  /// No description provided for @semesterDeleted.
  ///
  /// In zh_Hans, this message translates to:
  /// **'学期已删除'**
  String get semesterDeleted;

  /// No description provided for @editPlan.
  ///
  /// In zh_Hans, this message translates to:
  /// **'编辑方案'**
  String get editPlan;

  /// No description provided for @deletePlan.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除方案'**
  String get deletePlan;

  /// No description provided for @deletePlanConfirmation.
  ///
  /// In zh_Hans, this message translates to:
  /// **'确定删除“{name}”吗？'**
  String deletePlanConfirmation(String name);

  /// No description provided for @cannotDeleteLastPlan.
  ///
  /// In zh_Hans, this message translates to:
  /// **'至少需要保留一个方案'**
  String get cannotDeleteLastPlan;

  /// No description provided for @planDeleted.
  ///
  /// In zh_Hans, this message translates to:
  /// **'方案已删除'**
  String get planDeleted;

  /// No description provided for @semesterNameLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'学期名称'**
  String get semesterNameLabel;

  /// No description provided for @planNameLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'方案名称'**
  String get planNameLabel;

  /// No description provided for @hiddenCourses.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已隐藏课程'**
  String get hiddenCourses;

  /// No description provided for @hiddenCoursesSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'找回已从课表中隐藏的课程。'**
  String get hiddenCoursesSubtitle;

  /// No description provided for @noHiddenCourses.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有已隐藏课程'**
  String get noHiddenCourses;

  /// No description provided for @sessionCount.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{count} 个安排'**
  String sessionCount(num count);

  /// No description provided for @failedToLoadHolidaySettings.
  ///
  /// In zh_Hans, this message translates to:
  /// **'放假模式设置加载失败：{error}'**
  String failedToLoadHolidaySettings(Object error);

  /// No description provided for @holidayMode.
  ///
  /// In zh_Hans, this message translates to:
  /// **'放假模式'**
  String get holidayMode;

  /// No description provided for @legalHolidays.
  ///
  /// In zh_Hans, this message translates to:
  /// **'法定节假日'**
  String get legalHolidays;

  /// No description provided for @legalHolidaysSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'开启后自动隐藏中国法定节假日当天的课程，不删除课程记录。'**
  String get legalHolidaysSubtitle;

  /// No description provided for @holidayAdjustment.
  ///
  /// In zh_Hans, this message translates to:
  /// **'调休'**
  String get holidayAdjustment;

  /// No description provided for @holidayAdjustmentSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择是否按官方调休安排显示课程。'**
  String get holidayAdjustmentSubtitle;

  /// No description provided for @holidayAdjustmentNoAdjustment.
  ///
  /// In zh_Hans, this message translates to:
  /// **'不调休'**
  String get holidayAdjustmentNoAdjustment;

  /// No description provided for @holidayAdjustmentMakeUpWorkdays.
  ///
  /// In zh_Hans, this message translates to:
  /// **'按调休安排上课'**
  String get holidayAdjustmentMakeUpWorkdays;

  /// No description provided for @holidayAdjustmentNoMakeUpWorkdays.
  ///
  /// In zh_Hans, this message translates to:
  /// **'调休补班日也休息'**
  String get holidayAdjustmentNoMakeUpWorkdays;

  /// No description provided for @holidayDataLoading.
  ///
  /// In zh_Hans, this message translates to:
  /// **'正在获取 {year} 年中国节假日安排。'**
  String holidayDataLoading(int year);

  /// No description provided for @holidayDataFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂时无法获取节假日安排，请稍后再试。'**
  String get holidayDataFailed;

  /// No description provided for @holidayDataUnavailable.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本机暂无 {year} 年节假日安排。'**
  String holidayDataUnavailable(int year);

  /// No description provided for @holidayDataCached.
  ///
  /// In zh_Hans, this message translates to:
  /// **'正在使用上次获取的 {year} 年中国节假日安排。'**
  String holidayDataCached(int year);

  /// No description provided for @holidayDataUpdated.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已获取 {year} 年中国节假日安排。'**
  String holidayDataUpdated(int year);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
