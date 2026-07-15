// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '课格';

  @override
  String get navTimetable => '课表';

  @override
  String get navPlans => '方案';

  @override
  String get navImport => '导入';

  @override
  String get navEditor => '编辑';

  @override
  String get navExport => '导出';

  @override
  String get navSettings => '设置';

  @override
  String get collapseSidebar => '收起侧边栏';

  @override
  String get expandSidebar => '展开侧边栏';

  @override
  String get addCourse => '新增课程';

  @override
  String get backToTimetable => '返回课表';

  @override
  String get loadingTimetable => '正在加载课表';

  @override
  String failedToLoadTimetable(Object error) {
    return '课表加载失败：$error';
  }

  @override
  String weekNumber(int week) {
    return '第 $week 周';
  }

  @override
  String visibleSessionsThisWeek(int count) {
    return '本周 $count 个可见安排';
  }

  @override
  String get previousWeek => '上一周';

  @override
  String get nextWeek => '下一周';

  @override
  String get timeHeader => '时间';

  @override
  String get thisWeek => '本周课程';

  @override
  String get todayCourses => '今日课程';

  @override
  String get noCoursesToday => '今天没有课程';

  @override
  String get edit => '编辑';

  @override
  String get dayMon => '周一';

  @override
  String get dayTue => '周二';

  @override
  String get dayWed => '周三';

  @override
  String get dayThu => '周四';

  @override
  String get dayFri => '周五';

  @override
  String get daySat => '周六';

  @override
  String get daySun => '周日';

  @override
  String dayNumber(int weekday) {
    return '星期 $weekday';
  }

  @override
  String periodsValue(int start, int end) {
    return '第 $start-$end 节';
  }

  @override
  String weeksValue(int start, int end) {
    return '第 $start-$end 周';
  }

  @override
  String failedToLoadPlans(Object error) {
    return '方案加载失败：$error';
  }

  @override
  String get semesters => '学期';

  @override
  String get add => '添加';

  @override
  String firstMonday(String date) {
    return '第一周周一：$date';
  }

  @override
  String get current => '当前';

  @override
  String get timetablePlans => '课表方案';

  @override
  String get activeForRemindersAndExport => '用于提醒和默认导出';

  @override
  String get tapToMakeActive => '点击设为当前方案';

  @override
  String get active => '当前';

  @override
  String get plan => '方案';

  @override
  String get selectPlan => '选择';

  @override
  String get newPlan => '新建方案';

  @override
  String semesterName(int year, String month) {
    return '$year-$month 学期';
  }

  @override
  String planName(int number) {
    return '方案 $number';
  }

  @override
  String get courseSessionNotFound => '找不到课程安排。';

  @override
  String get newCourse => '新增课程';

  @override
  String get editCourse => '编辑课程';

  @override
  String get hideThisSession => '隐藏此安排';

  @override
  String get hideThisSessionSubtitle => '隐藏后课程保留在方案中，但不会显示在周视图里。';

  @override
  String get deleteSession => '删除安排';

  @override
  String get saveCourse => '保存课程';

  @override
  String get courseName => '课程名称';

  @override
  String get teacher => '教师';

  @override
  String get location => '地点';

  @override
  String get notes => '备注';

  @override
  String get weekday => '星期';

  @override
  String get startPeriod => '开始时间';

  @override
  String get endPeriod => '结束时间';

  @override
  String get startWeek => '开始周';

  @override
  String get endWeek => '结束周';

  @override
  String get allWeeks => '全部';

  @override
  String get oddWeeks => '单周';

  @override
  String get evenWeeks => '双周';

  @override
  String get requiredField => '必填';

  @override
  String get weekNumberValidation => '请输入 1-30';

  @override
  String get timeValidation => '请使用 HH:mm，且结束时间晚于开始时间。';

  @override
  String courseSaved(String course, int weekday, String start, String end) {
    return '已保存 $course：星期 $weekday，$start-$end。';
  }

  @override
  String get courseSessionDeleted => '课程安排已删除。';

  @override
  String get restore => '恢复';

  @override
  String get courseRestored => '课程已恢复';

  @override
  String get importCenter => '导入中心';

  @override
  String get importCenterSubtitle => '支持教务系统导出的课表文件，也可以导入日历文件。';

  @override
  String get chooseFile => '选择文件';

  @override
  String get pasteExamSchedule => '粘贴考试安排';

  @override
  String get pasteExamScheduleHint => '粘贴教务系统考试安排表中的文本。';

  @override
  String get importExamSchedule => '导入考试安排';

  @override
  String get loadSample => '加载样例';

  @override
  String get openDiff => '查看需确认课程';

  @override
  String get stagingPreview => '导入预览';

  @override
  String get merged => '已加入课表';

  @override
  String get waiting => '请选择文件';

  @override
  String get notCommitted => '可导入';

  @override
  String parsedCount(int count) {
    return '$count 条解析结果';
  }

  @override
  String newCount(int count) {
    return '$count 条新增';
  }

  @override
  String skippedCount(int count) {
    return '$count 条跳过';
  }

  @override
  String examParsedCount(int count) {
    return '$count 条考试安排';
  }

  @override
  String changeCount(int count) {
    return '$count 处变化';
  }

  @override
  String conflictCount(int count) {
    return '$count 个冲突';
  }

  @override
  String get applyStagingMerge => '加入课表';

  @override
  String get emptyPreview => '选择课表文件或加载样例，先预览将要导入的课程。';

  @override
  String importFailed(Object error) {
    return '导入失败：$error';
  }

  @override
  String committedSummary(int added, int diffs, int conflicts) {
    return '已加入 $added 个新安排；$diffs 处变化和 $conflicts 个时间重叠可继续确认。';
  }

  @override
  String examImportCommittedSummary(int added, int skipped) {
    return '已导入 $added 条考试安排，跳过 $skipped 条重复记录。';
  }

  @override
  String get importWarningUnsupportedFileType => '暂不支持这个文件类型，请选择课表表格或日历文件。';

  @override
  String get importWarningWorkbookReadFailed => '无法读取这个 .xls 文件，请确认文件没有损坏。';

  @override
  String get importWarningNoCompleteXlsRows => '已识别为课表文件，但没有找到完整课程。';

  @override
  String importWarningXlsParsedSessions(int count) {
    return '已从表格中识别 $count 个课程安排。';
  }

  @override
  String get importWarningNoCoursesFromHtml => '没有从表格中识别出课程。';

  @override
  String get importWarningDecodedWithFallback => '文件编码已自动转换。';

  @override
  String get importWarningFragmentMissingName => '有一段课程信息缺少课程名称，已跳过。';

  @override
  String get importWarningMissingWeekday => '有一条课程时间缺少星期，已跳过。';

  @override
  String get importWarningMissingPeriod => '有一条课程时间缺少节次，已跳过。';

  @override
  String get importWarningMissingWeeks => '有一条课程时间缺少周次，已跳过。';

  @override
  String get importWarningNoCompleteEntries => '检测到课程时间文本，但没有识别出完整课程。';

  @override
  String get importWarningIcsParseFailed => '无法读取这个日历文件，请确认文件格式正确。';

  @override
  String get importWarningSkippedIcsEvent => '日历中有一条事件缺少课程名称或时间，已跳过。';

  @override
  String get importWarningIcsRuleFallback => '有一条重复课程无法完整展开，已先按单次课程导入。';

  @override
  String get importWarningGenericError => '文件中有内容无法读取。';

  @override
  String get importWarningGenericWarning => '文件中有部分内容未能识别。';

  @override
  String get importWarningGenericInfo => '导入时已自动处理部分文件内容。';

  @override
  String get course => '课程';

  @override
  String get time => '时间';

  @override
  String get weeks => '周次';

  @override
  String get examRound => '考试轮次';

  @override
  String get examTime => '考试时间';

  @override
  String get seatNumber => '座位号';

  @override
  String get recentBatches => '最近导入';

  @override
  String failedToLoadHistory(Object error) {
    return '导入历史加载失败：$error';
  }

  @override
  String get noImportBatchesYet => '暂无导入记录';

  @override
  String get committedImportsAppearHere => '完成导入后会显示在这里。';

  @override
  String batchSubtitle(String type, String summary, String date) {
    return '$type - $summary - $date';
  }

  @override
  String failedToLoadConflicts(Object error) {
    return '冲突加载失败：$error';
  }

  @override
  String get noPendingConflicts => '暂无需要确认的导入课程。';

  @override
  String get conflictHandling => '冲突处理';

  @override
  String get conflictHandlingSubtitle => '请确认导入课程中需要选择的变化和时间重叠。';

  @override
  String changedFieldsCount(int count) {
    return '$count 处字段变化';
  }

  @override
  String timeConflictsCount(int count) {
    return '$count 个时间冲突';
  }

  @override
  String pendingCount(int count) {
    return '$count 项需确认';
  }

  @override
  String get conflict => '冲突';

  @override
  String get changed => '已变化';

  @override
  String get currentValue => '当前';

  @override
  String get importedValue => '导入';

  @override
  String get keepCurrent => '保留当前';

  @override
  String get useImported => '采用导入';

  @override
  String get keepBoth => '两者共存';

  @override
  String get forceMerge => '保留重叠课程';

  @override
  String get manualEdit => '手动编辑';

  @override
  String conflictMarked(String action) {
    return '已选择：$action。';
  }

  @override
  String courseSummary(
    int weekday,
    String period,
    String weeks,
    String teacher,
    String location,
  ) {
    return '星期 $weekday，第 $period 节，$weeks，$teacher，$location';
  }

  @override
  String get weekUnknown => '周次未知';

  @override
  String get teacherTbd => '教师待定';

  @override
  String get locationTbd => '地点待定';

  @override
  String changedFields(String fields) {
    return '变化：$fields';
  }

  @override
  String get timeOverlap => '时间重叠';

  @override
  String get icsCalendarExport => 'ICS 日历导出';

  @override
  String get icsCalendarExportSubtitle => '按北京时间导出，可导入系统日历。';

  @override
  String get exportIcs => '导出 .ics';

  @override
  String get currentWeekImage => '当前周图片';

  @override
  String get currentWeekImageSubtitle => '生成当前活动周的 PNG 课表快照。';

  @override
  String get fullSemesterImage => '整学期图片';

  @override
  String get fullSemesterImageSubtitle => '生成包含所有课程周次范围的 PNG 总览。';

  @override
  String get exportPng => '导出 PNG';

  @override
  String get exportTimetableCalendar => '导出课程日历';

  @override
  String get exportTimetableImage => '导出课表图片';

  @override
  String get exportSemesterTimetableImage => '导出整学期课表图片';

  @override
  String exportedPath(String path) {
    return '已导出 $path';
  }

  @override
  String get openExportedFile => '打开';

  @override
  String get preparingExport => '正在准备导出';

  @override
  String openExportedFileFailed(String message) {
    return '无法打开文件：$message';
  }

  @override
  String get fullSemester => '整学期';

  @override
  String failedToLoadReminderSettings(Object error) {
    return '提醒设置加载失败：$error';
  }

  @override
  String failedToLoadLanguageSetting(Object error) {
    return '语言设置加载失败：$error';
  }

  @override
  String failedToLoadThemeSetting(Object error) {
    return '主题设置加载失败：$error';
  }

  @override
  String failedToLoadTimetableDisplaySetting(Object error) {
    return '课表显示设置加载失败：$error';
  }

  @override
  String failedToLoadExportDisplaySetting(Object error) {
    return '导出显示设置加载失败：$error';
  }

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get display => '显示';

  @override
  String get showNonCurrentWeekCourses => '显示非本周课程';

  @override
  String get showNonCurrentWeekCoursesSubtitle => '开启后，非本周课程会以灰色显示在课表中。';

  @override
  String get exportDisplaySettings => '导出显示';

  @override
  String get showNonCurrentWeekCoursesInExportSubtitle =>
      '开启后，周课表和整学期 PNG 中的非本周课程会以灰色显示。';

  @override
  String get themeModeSystem => '跟随系统';

  @override
  String get themeModeLight => '浅色';

  @override
  String get themeModeDark => '深色';

  @override
  String get denseTimetable => '紧凑课表';

  @override
  String get denseTimetableSubtitle => '第一版已为自适应界面启用紧凑行距。';

  @override
  String get localData => '本地数据';

  @override
  String get localDataSubtitle => '课表、导入记录和提醒设置只保存在本机。';

  @override
  String get backupLocalData => '备份到本地';

  @override
  String get restoreLocalData => '从备份恢复';

  @override
  String backupCreated(String path) {
    return '备份已保存到 $path';
  }

  @override
  String get backupRestored => '数据和设置已恢复。';

  @override
  String localDataActionFailed(Object error) {
    return '本地数据操作失败：$error';
  }

  @override
  String get offlineAppSubtitle => '无需登录；课表和提醒都在本机处理。';

  @override
  String get thirdPartyLicenses => '开放源代码许可';

  @override
  String get thirdPartyLicensesSubtitle => '查看课格、Flutter 和依赖库的开放源代码许可。';

  @override
  String get appLicenseDisplayName => '课格（Crid）';

  @override
  String get appLicenseSummary =>
      '课格（Crid）采用 Apache License 2.0 开放源代码许可；分发时请保留 LICENSE 和 NOTICE 中的归属声明。';

  @override
  String get reminders => '课程提醒';

  @override
  String reminderNotificationTitle(int minutes) {
    return '$minutes 分钟后上课';
  }

  @override
  String get courseReminders => '课程提醒';

  @override
  String get courseRemindersSubtitle => '课程变化后自动更新未来四周的提醒。';

  @override
  String get androidBackgroundSettings => 'Android 后台运行';

  @override
  String get androidBackgroundSettingsSubtitle => '用于在系统限制后台任务时继续处理课程提醒。';

  @override
  String get androidBackgroundUnsupported => '这项设置仅在 Android 设备上可用。';

  @override
  String get androidDeviceStatusTitle => 'Android 设备';

  @override
  String androidDeviceStatus(
    String manufacturer,
    String model,
    String version,
  ) {
    return '$manufacturer $model，Android $version';
  }

  @override
  String failedToLoadAndroidBackgroundStatus(Object error) {
    return 'Android 后台状态加载失败：$error';
  }

  @override
  String get windowsReminderSettings => 'Windows 课程提醒';

  @override
  String get windowsReminderSettingsSubtitle =>
      'Windows 会通过系统调度已启用的提醒，关闭课格后也不需要保持后台运行。';

  @override
  String get windowsSystemNotifications => '系统通知';

  @override
  String get windowsNotificationsAllowed => '通知已开启，关闭课格后系统仍可显示已调度的提醒。';

  @override
  String get windowsNotificationsBlocked => 'Windows 通知已关闭，请在系统设置中开启以接收课程提醒。';

  @override
  String failedToLoadWindowsReminderStatus(Object error) {
    return 'Windows 提醒状态加载失败：$error';
  }

  @override
  String get persistentBackgroundRuntime => '持续后台运行';

  @override
  String get persistentBackgroundRuntimeSubtitle =>
      '开启后会在通知栏显示静默常驻通知，用于维持课程提醒的后台任务。';

  @override
  String get persistentBackgroundRuntimeAllowed =>
      '已获得电池优化豁免，后台任务受系统电池限制的影响会减少。';

  @override
  String get openNotificationSettings => '通知设置';

  @override
  String get openBatterySettings => '电池设置';

  @override
  String get openExactAlarmSettings => '精确闹钟权限';

  @override
  String get openAutostartSettings => '自启动设置';

  @override
  String get requestBatteryExemption => '申请后台运行权限';

  @override
  String get leadTime => '提前提醒';

  @override
  String minutesShort(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String get customReminderTime => '自定义时间';

  @override
  String get minutesBeforeClass => '上课前';

  @override
  String get minutesUnit => '分钟';

  @override
  String get ignoreDoNotDisturb => '忽略免打扰';

  @override
  String get ignoreDoNotDisturbSubtitle => 'Android 会打开系统授权页；授权后提醒渠道可绕过免打扰。';

  @override
  String get windowsIgnoreDoNotDisturbSubtitle =>
      'Windows 会将课程提醒标记为紧急通知，使其可以绕过免打扰。';

  @override
  String get vibrateReminder => '关闭提醒声音';

  @override
  String get vibrateReminderSubtitle => '课程提醒仍会振动，但不播放提示音。';

  @override
  String get windowsMuteReminderSoundSubtitle =>
      'Windows 会静音显示课程提醒；是否振动由设备和系统设置决定。';

  @override
  String get goToToday => '回到今天';

  @override
  String get delete => '删除';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get clear => '清除';

  @override
  String semesterEndDate(String date) {
    return '结束日期：$date';
  }

  @override
  String get semesterStartDate => '学期开始日（第一周周一）';

  @override
  String get semesterEndDateOptional => '结束日期（可选）';

  @override
  String get noSemesterEndDate => '未设置结束日期';

  @override
  String get chooseSemesterStartDate => '选择学期开始日（第一周周一）';

  @override
  String get chooseSemesterEndDate => '选择学期结束日期';

  @override
  String get addSemester => '添加学期';

  @override
  String get editSemester => '编辑学期';

  @override
  String get deleteSemester => '删除学期';

  @override
  String deleteSemesterConfirmation(String name) {
    return '确定删除“$name”及其中的课程表方案吗？';
  }

  @override
  String get cannotDeleteLastSemester => '至少需要保留一个学期';

  @override
  String get semesterDeleted => '学期已删除';

  @override
  String get editPlan => '编辑方案';

  @override
  String get deletePlan => '删除方案';

  @override
  String deletePlanConfirmation(String name) {
    return '确定删除“$name”吗？';
  }

  @override
  String get cannotDeleteLastPlan => '至少需要保留一个方案';

  @override
  String get planDeleted => '方案已删除';

  @override
  String get semesterNameLabel => '学期名称';

  @override
  String get planNameLabel => '方案名称';

  @override
  String get hiddenCourses => '已隐藏课程';

  @override
  String get hiddenCoursesSubtitle => '找回已从课表中隐藏的课程。';

  @override
  String get noHiddenCourses => '没有已隐藏课程';

  @override
  String sessionCount(num count) {
    return '$count 个安排';
  }

  @override
  String failedToLoadHolidaySettings(Object error) {
    return '放假模式设置加载失败：$error';
  }

  @override
  String get holidayMode => '放假模式';

  @override
  String get legalHolidays => '法定节假日';

  @override
  String get legalHolidaysSubtitle => '开启后自动隐藏中国法定节假日当天的课程，不删除课程记录。';

  @override
  String get holidayAdjustment => '调休';

  @override
  String get holidayAdjustmentSubtitle => '选择是否按官方调休安排显示课程。';

  @override
  String get holidayAdjustmentNoAdjustment => '不调休';

  @override
  String get holidayAdjustmentMakeUpWorkdays => '按调休安排上课';

  @override
  String get holidayAdjustmentNoMakeUpWorkdays => '调休补班日也休息';

  @override
  String holidayDataLoading(int year) {
    return '正在获取 $year 年中国节假日安排。';
  }

  @override
  String get holidayDataFailed => '暂时无法获取节假日安排，请稍后再试。';

  @override
  String holidayDataUnavailable(int year) {
    return '本机暂无 $year 年节假日安排。';
  }

  @override
  String holidayDataCached(int year) {
    return '正在使用上次获取的 $year 年中国节假日安排。';
  }

  @override
  String holidayDataUpdated(int year) {
    return '已获取 $year 年中国节假日安排。';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => '课格';

  @override
  String get navTimetable => '课表';

  @override
  String get navPlans => '方案';

  @override
  String get navImport => '导入';

  @override
  String get navEditor => '编辑';

  @override
  String get navExport => '导出';

  @override
  String get navSettings => '设置';

  @override
  String get collapseSidebar => '收起侧边栏';

  @override
  String get expandSidebar => '展开侧边栏';

  @override
  String get addCourse => '新增课程';

  @override
  String get backToTimetable => '返回课表';

  @override
  String get loadingTimetable => '正在加载课表';

  @override
  String failedToLoadTimetable(Object error) {
    return '课表加载失败：$error';
  }

  @override
  String weekNumber(int week) {
    return '第 $week 周';
  }

  @override
  String visibleSessionsThisWeek(int count) {
    return '本周 $count 个可见安排';
  }

  @override
  String get previousWeek => '上一周';

  @override
  String get nextWeek => '下一周';

  @override
  String get timeHeader => '时间';

  @override
  String get thisWeek => '本周课程';

  @override
  String get todayCourses => '今日课程';

  @override
  String get noCoursesToday => '今天没有课程';

  @override
  String get edit => '编辑';

  @override
  String get dayMon => '周一';

  @override
  String get dayTue => '周二';

  @override
  String get dayWed => '周三';

  @override
  String get dayThu => '周四';

  @override
  String get dayFri => '周五';

  @override
  String get daySat => '周六';

  @override
  String get daySun => '周日';

  @override
  String dayNumber(int weekday) {
    return '星期 $weekday';
  }

  @override
  String periodsValue(int start, int end) {
    return '第 $start-$end 节';
  }

  @override
  String weeksValue(int start, int end) {
    return '第 $start-$end 周';
  }

  @override
  String failedToLoadPlans(Object error) {
    return '方案加载失败：$error';
  }

  @override
  String get semesters => '学期';

  @override
  String get add => '添加';

  @override
  String firstMonday(String date) {
    return '第一周周一：$date';
  }

  @override
  String get current => '当前';

  @override
  String get timetablePlans => '课表方案';

  @override
  String get activeForRemindersAndExport => '用于提醒和默认导出';

  @override
  String get tapToMakeActive => '点击设为当前方案';

  @override
  String get active => '当前';

  @override
  String get plan => '方案';

  @override
  String get selectPlan => '选择';

  @override
  String get newPlan => '新建方案';

  @override
  String semesterName(int year, String month) {
    return '$year-$month 学期';
  }

  @override
  String planName(int number) {
    return '方案 $number';
  }

  @override
  String get courseSessionNotFound => '找不到课程安排。';

  @override
  String get newCourse => '新增课程';

  @override
  String get editCourse => '编辑课程';

  @override
  String get hideThisSession => '隐藏此安排';

  @override
  String get hideThisSessionSubtitle => '隐藏后课程保留在方案中，但不会显示在周视图里。';

  @override
  String get deleteSession => '删除安排';

  @override
  String get saveCourse => '保存课程';

  @override
  String get courseName => '课程名称';

  @override
  String get teacher => '教师';

  @override
  String get location => '地点';

  @override
  String get notes => '备注';

  @override
  String get weekday => '星期';

  @override
  String get startPeriod => '开始时间';

  @override
  String get endPeriod => '结束时间';

  @override
  String get startWeek => '开始周';

  @override
  String get endWeek => '结束周';

  @override
  String get allWeeks => '全部';

  @override
  String get oddWeeks => '单周';

  @override
  String get evenWeeks => '双周';

  @override
  String get requiredField => '必填';

  @override
  String get weekNumberValidation => '请输入 1-30';

  @override
  String get timeValidation => '请使用 HH:mm，且结束时间晚于开始时间。';

  @override
  String courseSaved(String course, int weekday, String start, String end) {
    return '已保存 $course：星期 $weekday，$start-$end。';
  }

  @override
  String get courseSessionDeleted => '课程安排已删除。';

  @override
  String get restore => '恢复';

  @override
  String get courseRestored => '课程已恢复';

  @override
  String get importCenter => '导入中心';

  @override
  String get importCenterSubtitle => '支持教务系统导出的课表文件，也可以导入日历文件。';

  @override
  String get chooseFile => '选择文件';

  @override
  String get pasteExamSchedule => '粘贴考试安排';

  @override
  String get pasteExamScheduleHint => '粘贴教务系统考试安排表中的文本。';

  @override
  String get importExamSchedule => '导入考试安排';

  @override
  String get loadSample => '加载样例';

  @override
  String get openDiff => '查看需确认课程';

  @override
  String get stagingPreview => '导入预览';

  @override
  String get merged => '已加入课表';

  @override
  String get waiting => '请选择文件';

  @override
  String get notCommitted => '可导入';

  @override
  String parsedCount(int count) {
    return '$count 条解析结果';
  }

  @override
  String newCount(int count) {
    return '$count 条新增';
  }

  @override
  String skippedCount(int count) {
    return '$count 条跳过';
  }

  @override
  String examParsedCount(int count) {
    return '$count 条考试安排';
  }

  @override
  String changeCount(int count) {
    return '$count 处变化';
  }

  @override
  String conflictCount(int count) {
    return '$count 个冲突';
  }

  @override
  String get applyStagingMerge => '加入课表';

  @override
  String get emptyPreview => '选择课表文件或加载样例，先预览将要导入的课程。';

  @override
  String importFailed(Object error) {
    return '导入失败：$error';
  }

  @override
  String committedSummary(int added, int diffs, int conflicts) {
    return '已加入 $added 个新安排；$diffs 处变化和 $conflicts 个时间重叠可继续确认。';
  }

  @override
  String examImportCommittedSummary(int added, int skipped) {
    return '已导入 $added 条考试安排，跳过 $skipped 条重复记录。';
  }

  @override
  String get importWarningUnsupportedFileType => '暂不支持这个文件类型，请选择课表表格或日历文件。';

  @override
  String get importWarningWorkbookReadFailed => '无法读取这个 .xls 文件，请确认文件没有损坏。';

  @override
  String get importWarningNoCompleteXlsRows => '已识别为课表文件，但没有找到完整课程。';

  @override
  String importWarningXlsParsedSessions(int count) {
    return '已从表格中识别 $count 个课程安排。';
  }

  @override
  String get importWarningNoCoursesFromHtml => '没有从表格中识别出课程。';

  @override
  String get importWarningDecodedWithFallback => '文件编码已自动转换。';

  @override
  String get importWarningFragmentMissingName => '有一段课程信息缺少课程名称，已跳过。';

  @override
  String get importWarningMissingWeekday => '有一条课程时间缺少星期，已跳过。';

  @override
  String get importWarningMissingPeriod => '有一条课程时间缺少节次，已跳过。';

  @override
  String get importWarningMissingWeeks => '有一条课程时间缺少周次，已跳过。';

  @override
  String get importWarningNoCompleteEntries => '检测到课程时间文本，但没有识别出完整课程。';

  @override
  String get importWarningIcsParseFailed => '无法读取这个日历文件，请确认文件格式正确。';

  @override
  String get importWarningSkippedIcsEvent => '日历中有一条事件缺少课程名称或时间，已跳过。';

  @override
  String get importWarningIcsRuleFallback => '有一条重复课程无法完整展开，已先按单次课程导入。';

  @override
  String get importWarningGenericError => '文件中有内容无法读取。';

  @override
  String get importWarningGenericWarning => '文件中有部分内容未能识别。';

  @override
  String get importWarningGenericInfo => '导入时已自动处理部分文件内容。';

  @override
  String get course => '课程';

  @override
  String get time => '时间';

  @override
  String get weeks => '周次';

  @override
  String get examRound => '考试轮次';

  @override
  String get examTime => '考试时间';

  @override
  String get seatNumber => '座位号';

  @override
  String get recentBatches => '最近导入';

  @override
  String failedToLoadHistory(Object error) {
    return '导入历史加载失败：$error';
  }

  @override
  String get noImportBatchesYet => '暂无导入记录';

  @override
  String get committedImportsAppearHere => '完成导入后会显示在这里。';

  @override
  String batchSubtitle(String type, String summary, String date) {
    return '$type - $summary - $date';
  }

  @override
  String failedToLoadConflicts(Object error) {
    return '冲突加载失败：$error';
  }

  @override
  String get noPendingConflicts => '暂无需要确认的导入课程。';

  @override
  String get conflictHandling => '冲突处理';

  @override
  String get conflictHandlingSubtitle => '请确认导入课程中需要选择的变化和时间重叠。';

  @override
  String changedFieldsCount(int count) {
    return '$count 处字段变化';
  }

  @override
  String timeConflictsCount(int count) {
    return '$count 个时间冲突';
  }

  @override
  String pendingCount(int count) {
    return '$count 项需确认';
  }

  @override
  String get conflict => '冲突';

  @override
  String get changed => '已变化';

  @override
  String get currentValue => '当前';

  @override
  String get importedValue => '导入';

  @override
  String get keepCurrent => '保留当前';

  @override
  String get useImported => '采用导入';

  @override
  String get keepBoth => '两者共存';

  @override
  String get forceMerge => '保留重叠课程';

  @override
  String get manualEdit => '手动编辑';

  @override
  String conflictMarked(String action) {
    return '已选择：$action。';
  }

  @override
  String courseSummary(
    int weekday,
    String period,
    String weeks,
    String teacher,
    String location,
  ) {
    return '星期 $weekday，第 $period 节，$weeks，$teacher，$location';
  }

  @override
  String get weekUnknown => '周次未知';

  @override
  String get teacherTbd => '教师待定';

  @override
  String get locationTbd => '地点待定';

  @override
  String changedFields(String fields) {
    return '变化：$fields';
  }

  @override
  String get timeOverlap => '时间重叠';

  @override
  String get icsCalendarExport => 'ICS 日历导出';

  @override
  String get icsCalendarExportSubtitle => '按北京时间导出，可导入系统日历。';

  @override
  String get exportIcs => '导出 .ics';

  @override
  String get currentWeekImage => '当前周图片';

  @override
  String get currentWeekImageSubtitle => '生成当前活动周的 PNG 课表快照。';

  @override
  String get fullSemesterImage => '整学期图片';

  @override
  String get fullSemesterImageSubtitle => '生成包含所有课程周次范围的 PNG 总览。';

  @override
  String get exportPng => '导出 PNG';

  @override
  String get exportTimetableCalendar => '导出课程日历';

  @override
  String get exportTimetableImage => '导出课表图片';

  @override
  String get exportSemesterTimetableImage => '导出整学期课表图片';

  @override
  String exportedPath(String path) {
    return '已导出 $path';
  }

  @override
  String get openExportedFile => '打开';

  @override
  String get preparingExport => '正在准备导出';

  @override
  String openExportedFileFailed(String message) {
    return '无法打开文件：$message';
  }

  @override
  String get fullSemester => '整学期';

  @override
  String failedToLoadReminderSettings(Object error) {
    return '提醒设置加载失败：$error';
  }

  @override
  String failedToLoadLanguageSetting(Object error) {
    return '语言设置加载失败：$error';
  }

  @override
  String failedToLoadThemeSetting(Object error) {
    return '主题设置加载失败：$error';
  }

  @override
  String failedToLoadTimetableDisplaySetting(Object error) {
    return '课表显示设置加载失败：$error';
  }

  @override
  String failedToLoadExportDisplaySetting(Object error) {
    return '导出显示设置加载失败：$error';
  }

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get display => '显示';

  @override
  String get showNonCurrentWeekCourses => '显示非本周课程';

  @override
  String get showNonCurrentWeekCoursesSubtitle => '开启后，非本周课程会以灰色显示在课表中。';

  @override
  String get exportDisplaySettings => '导出显示';

  @override
  String get showNonCurrentWeekCoursesInExportSubtitle =>
      '开启后，周课表和整学期 PNG 中的非本周课程会以灰色显示。';

  @override
  String get themeModeSystem => '跟随系统';

  @override
  String get themeModeLight => '浅色';

  @override
  String get themeModeDark => '深色';

  @override
  String get denseTimetable => '紧凑课表';

  @override
  String get denseTimetableSubtitle => '第一版已为自适应界面启用紧凑行距。';

  @override
  String get localData => '本地数据';

  @override
  String get localDataSubtitle => '课表、导入记录和提醒设置只保存在本机。';

  @override
  String get backupLocalData => '备份到本地';

  @override
  String get restoreLocalData => '从备份恢复';

  @override
  String backupCreated(String path) {
    return '备份已保存到 $path';
  }

  @override
  String get backupRestored => '数据和设置已恢复。';

  @override
  String localDataActionFailed(Object error) {
    return '本地数据操作失败：$error';
  }

  @override
  String get offlineAppSubtitle => '无需登录；课表和提醒都在本机处理。';

  @override
  String get thirdPartyLicenses => '开放源代码许可';

  @override
  String get thirdPartyLicensesSubtitle => '查看课格、Flutter 和依赖库的开放源代码许可。';

  @override
  String get appLicenseDisplayName => '课格（Crid）';

  @override
  String get appLicenseSummary =>
      '课格（Crid）采用 Apache License 2.0 开放源代码许可；分发时请保留 LICENSE 和 NOTICE 中的归属声明。';

  @override
  String get reminders => '课程提醒';

  @override
  String reminderNotificationTitle(int minutes) {
    return '$minutes 分钟后上课';
  }

  @override
  String get courseReminders => '课程提醒';

  @override
  String get courseRemindersSubtitle => '课程变化后自动更新未来四周的提醒。';

  @override
  String get androidBackgroundSettings => 'Android 后台运行';

  @override
  String get androidBackgroundSettingsSubtitle => '用于在系统限制后台任务时继续处理课程提醒。';

  @override
  String get androidBackgroundUnsupported => '这项设置仅在 Android 设备上可用。';

  @override
  String get androidDeviceStatusTitle => 'Android 设备';

  @override
  String androidDeviceStatus(
    String manufacturer,
    String model,
    String version,
  ) {
    return '$manufacturer $model，Android $version';
  }

  @override
  String failedToLoadAndroidBackgroundStatus(Object error) {
    return 'Android 后台状态加载失败：$error';
  }

  @override
  String get windowsReminderSettings => 'Windows 课程提醒';

  @override
  String get windowsReminderSettingsSubtitle =>
      'Windows 会通过系统调度已启用的提醒，关闭课格后也不需要保持后台运行。';

  @override
  String get windowsSystemNotifications => '系统通知';

  @override
  String get windowsNotificationsAllowed => '通知已开启，关闭课格后系统仍可显示已调度的提醒。';

  @override
  String get windowsNotificationsBlocked => 'Windows 通知已关闭，请在系统设置中开启以接收课程提醒。';

  @override
  String failedToLoadWindowsReminderStatus(Object error) {
    return 'Windows 提醒状态加载失败：$error';
  }

  @override
  String get persistentBackgroundRuntime => '持续后台运行';

  @override
  String get persistentBackgroundRuntimeSubtitle =>
      '开启后会在通知栏显示静默常驻通知，用于维持课程提醒的后台任务。';

  @override
  String get persistentBackgroundRuntimeAllowed =>
      '已获得电池优化豁免，后台任务受系统电池限制的影响会减少。';

  @override
  String get openNotificationSettings => '通知设置';

  @override
  String get openBatterySettings => '电池设置';

  @override
  String get openExactAlarmSettings => '精确闹钟权限';

  @override
  String get openAutostartSettings => '自启动设置';

  @override
  String get requestBatteryExemption => '申请后台运行权限';

  @override
  String get leadTime => '提前提醒';

  @override
  String minutesShort(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String get customReminderTime => '自定义时间';

  @override
  String get minutesBeforeClass => '上课前';

  @override
  String get minutesUnit => '分钟';

  @override
  String get ignoreDoNotDisturb => '忽略免打扰';

  @override
  String get ignoreDoNotDisturbSubtitle => 'Android 会打开系统授权页；授权后提醒渠道可绕过免打扰。';

  @override
  String get windowsIgnoreDoNotDisturbSubtitle =>
      'Windows 会将课程提醒标记为紧急通知，使其可以绕过免打扰。';

  @override
  String get vibrateReminder => '关闭提醒声音';

  @override
  String get vibrateReminderSubtitle => '课程提醒仍会振动，但不播放提示音。';

  @override
  String get windowsMuteReminderSoundSubtitle =>
      'Windows 会静音显示课程提醒；是否振动由设备和系统设置决定。';

  @override
  String get goToToday => '回到今天';

  @override
  String get delete => '删除';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get clear => '清除';

  @override
  String semesterEndDate(String date) {
    return '结束日期：$date';
  }

  @override
  String get semesterStartDate => '学期开始日（第一周周一）';

  @override
  String get semesterEndDateOptional => '结束日期（可选）';

  @override
  String get noSemesterEndDate => '未设置结束日期';

  @override
  String get chooseSemesterStartDate => '选择学期开始日（第一周周一）';

  @override
  String get chooseSemesterEndDate => '选择学期结束日期';

  @override
  String get addSemester => '添加学期';

  @override
  String get editSemester => '编辑学期';

  @override
  String get deleteSemester => '删除学期';

  @override
  String deleteSemesterConfirmation(String name) {
    return '确定删除“$name”及其中的课程表方案吗？';
  }

  @override
  String get cannotDeleteLastSemester => '至少需要保留一个学期';

  @override
  String get semesterDeleted => '学期已删除';

  @override
  String get editPlan => '编辑方案';

  @override
  String get deletePlan => '删除方案';

  @override
  String deletePlanConfirmation(String name) {
    return '确定删除“$name”吗？';
  }

  @override
  String get cannotDeleteLastPlan => '至少需要保留一个方案';

  @override
  String get planDeleted => '方案已删除';

  @override
  String get semesterNameLabel => '学期名称';

  @override
  String get planNameLabel => '方案名称';

  @override
  String get hiddenCourses => '已隐藏课程';

  @override
  String get hiddenCoursesSubtitle => '找回已从课表中隐藏的课程。';

  @override
  String get noHiddenCourses => '没有已隐藏课程';

  @override
  String sessionCount(num count) {
    return '$count 个安排';
  }

  @override
  String failedToLoadHolidaySettings(Object error) {
    return '放假模式设置加载失败：$error';
  }

  @override
  String get holidayMode => '放假模式';

  @override
  String get legalHolidays => '法定节假日';

  @override
  String get legalHolidaysSubtitle => '开启后自动隐藏中国法定节假日当天的课程，不删除课程记录。';

  @override
  String get holidayAdjustment => '调休';

  @override
  String get holidayAdjustmentSubtitle => '选择是否按官方调休安排显示课程。';

  @override
  String get holidayAdjustmentNoAdjustment => '不调休';

  @override
  String get holidayAdjustmentMakeUpWorkdays => '按调休安排上课';

  @override
  String get holidayAdjustmentNoMakeUpWorkdays => '调休补班日也休息';

  @override
  String holidayDataLoading(int year) {
    return '正在获取 $year 年中国节假日安排。';
  }

  @override
  String get holidayDataFailed => '暂时无法获取节假日安排，请稍后再试。';

  @override
  String holidayDataUnavailable(int year) {
    return '本机暂无 $year 年节假日安排。';
  }

  @override
  String holidayDataCached(int year) {
    return '正在使用上次获取的 $year 年中国节假日安排。';
  }

  @override
  String holidayDataUpdated(int year) {
    return '已获取 $year 年中国节假日安排。';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => '課格';

  @override
  String get navTimetable => '課表';

  @override
  String get navPlans => '方案';

  @override
  String get navImport => '匯入';

  @override
  String get navEditor => '編輯';

  @override
  String get navExport => '匯出';

  @override
  String get navSettings => '設定';

  @override
  String get collapseSidebar => '收起側邊欄';

  @override
  String get expandSidebar => '展開側邊欄';

  @override
  String get addCourse => '新增課程';

  @override
  String get backToTimetable => '返回課表';

  @override
  String get loadingTimetable => '正在載入課表';

  @override
  String failedToLoadTimetable(Object error) {
    return '課表載入失敗：$error';
  }

  @override
  String weekNumber(int week) {
    return '第 $week 週';
  }

  @override
  String visibleSessionsThisWeek(int count) {
    return '本週 $count 個可見安排';
  }

  @override
  String get previousWeek => '上一週';

  @override
  String get nextWeek => '下一週';

  @override
  String get timeHeader => '時間';

  @override
  String get thisWeek => '本週課程';

  @override
  String get todayCourses => '今日課程';

  @override
  String get noCoursesToday => '今天沒有課程';

  @override
  String get edit => '編輯';

  @override
  String get dayMon => '週一';

  @override
  String get dayTue => '週二';

  @override
  String get dayWed => '週三';

  @override
  String get dayThu => '週四';

  @override
  String get dayFri => '週五';

  @override
  String get daySat => '週六';

  @override
  String get daySun => '週日';

  @override
  String dayNumber(int weekday) {
    return '星期 $weekday';
  }

  @override
  String periodsValue(int start, int end) {
    return '第 $start-$end 節';
  }

  @override
  String weeksValue(int start, int end) {
    return '第 $start-$end 週';
  }

  @override
  String failedToLoadPlans(Object error) {
    return '方案載入失敗：$error';
  }

  @override
  String get semesters => '學期';

  @override
  String get add => '新增';

  @override
  String firstMonday(String date) {
    return '第一週週一：$date';
  }

  @override
  String get current => '目前';

  @override
  String get timetablePlans => '課表方案';

  @override
  String get activeForRemindersAndExport => '用於提醒和預設匯出';

  @override
  String get tapToMakeActive => '點選設為目前方案';

  @override
  String get active => '目前';

  @override
  String get plan => '方案';

  @override
  String get selectPlan => '選擇';

  @override
  String get newPlan => '新增方案';

  @override
  String semesterName(int year, String month) {
    return '$year-$month 學期';
  }

  @override
  String planName(int number) {
    return '方案 $number';
  }

  @override
  String get courseSessionNotFound => '找不到課程安排。';

  @override
  String get newCourse => '新增課程';

  @override
  String get editCourse => '編輯課程';

  @override
  String get hideThisSession => '隱藏此安排';

  @override
  String get hideThisSessionSubtitle => '隱藏後課程會保留在方案中，但不會顯示在週視圖裡。';

  @override
  String get deleteSession => '刪除安排';

  @override
  String get saveCourse => '儲存課程';

  @override
  String get courseName => '課程名稱';

  @override
  String get teacher => '教師';

  @override
  String get location => '地點';

  @override
  String get notes => '備註';

  @override
  String get weekday => '星期';

  @override
  String get startPeriod => '開始時間';

  @override
  String get endPeriod => '結束時間';

  @override
  String get startWeek => '開始週';

  @override
  String get endWeek => '結束週';

  @override
  String get allWeeks => '全部';

  @override
  String get oddWeeks => '單週';

  @override
  String get evenWeeks => '雙週';

  @override
  String get requiredField => '必填';

  @override
  String get weekNumberValidation => '請輸入 1-30';

  @override
  String get timeValidation => '請使用 HH:mm，且結束時間晚於開始時間。';

  @override
  String courseSaved(String course, int weekday, String start, String end) {
    return '已儲存 $course：星期 $weekday，$start-$end。';
  }

  @override
  String get courseSessionDeleted => '課程安排已刪除。';

  @override
  String get restore => '復原';

  @override
  String get courseRestored => '課程已復原';

  @override
  String get importCenter => '匯入中心';

  @override
  String get importCenterSubtitle => '支援教務系統匯出的課表檔案，也可以匯入日曆檔案。';

  @override
  String get chooseFile => '選擇檔案';

  @override
  String get pasteExamSchedule => '貼上考試安排';

  @override
  String get pasteExamScheduleHint => '貼上從教務系統考試安排表複製的文字。';

  @override
  String get importExamSchedule => '匯入考試安排';

  @override
  String get loadSample => '載入範例';

  @override
  String get openDiff => '查看需確認課程';

  @override
  String get stagingPreview => '匯入預覽';

  @override
  String get merged => '已加入課表';

  @override
  String get waiting => '請選擇檔案';

  @override
  String get notCommitted => '可匯入';

  @override
  String parsedCount(int count) {
    return '$count 筆解析結果';
  }

  @override
  String newCount(int count) {
    return '$count 筆新增';
  }

  @override
  String skippedCount(int count) {
    return '$count 筆跳過';
  }

  @override
  String examParsedCount(int count) {
    return '$count 筆考試安排';
  }

  @override
  String changeCount(int count) {
    return '$count 處變更';
  }

  @override
  String conflictCount(int count) {
    return '$count 個衝突';
  }

  @override
  String get applyStagingMerge => '加入課表';

  @override
  String get emptyPreview => '選擇課表檔案或載入範例，先預覽將要匯入的課程。';

  @override
  String importFailed(Object error) {
    return '匯入失敗：$error';
  }

  @override
  String committedSummary(int added, int diffs, int conflicts) {
    return '已加入 $added 個新安排；$diffs 處變更和 $conflicts 個時間重疊可繼續確認。';
  }

  @override
  String examImportCommittedSummary(int added, int skipped) {
    return '已匯入 $added 筆考試安排，跳過 $skipped 筆重複記錄。';
  }

  @override
  String get importWarningUnsupportedFileType => '暫不支援這個檔案類型，請選擇課表表格或日曆檔案。';

  @override
  String get importWarningWorkbookReadFailed => '無法讀取這個 .xls 檔案，請確認檔案沒有損壞。';

  @override
  String get importWarningNoCompleteXlsRows => '已識別為課表檔案，但沒有找到完整課程。';

  @override
  String importWarningXlsParsedSessions(int count) {
    return '已從表格中識別 $count 個課程安排。';
  }

  @override
  String get importWarningNoCoursesFromHtml => '沒有從表格中識別出課程。';

  @override
  String get importWarningDecodedWithFallback => '檔案編碼已自動轉換。';

  @override
  String get importWarningFragmentMissingName => '有一段課程資訊缺少課程名稱，已跳過。';

  @override
  String get importWarningMissingWeekday => '有一條課程時間缺少星期，已跳過。';

  @override
  String get importWarningMissingPeriod => '有一條課程時間缺少節次，已跳過。';

  @override
  String get importWarningMissingWeeks => '有一條課程時間缺少週次，已跳過。';

  @override
  String get importWarningNoCompleteEntries => '偵測到課程時間文字，但沒有識別出完整課程。';

  @override
  String get importWarningIcsParseFailed => '無法讀取這個日曆檔案，請確認檔案格式正確。';

  @override
  String get importWarningSkippedIcsEvent => '日曆中有一條事件缺少課程名稱或時間，已跳過。';

  @override
  String get importWarningIcsRuleFallback => '有一條重複課程無法完整展開，已先按單次課程匯入。';

  @override
  String get importWarningGenericError => '檔案中有內容無法讀取。';

  @override
  String get importWarningGenericWarning => '檔案中有部分內容未能識別。';

  @override
  String get importWarningGenericInfo => '匯入時已自動處理部分檔案內容。';

  @override
  String get course => '課程';

  @override
  String get time => '時間';

  @override
  String get weeks => '週次';

  @override
  String get examRound => '考試輪次';

  @override
  String get examTime => '考試時間';

  @override
  String get seatNumber => '座位號';

  @override
  String get recentBatches => '最近匯入';

  @override
  String failedToLoadHistory(Object error) {
    return '匯入歷史載入失敗：$error';
  }

  @override
  String get noImportBatchesYet => '尚無匯入記錄';

  @override
  String get committedImportsAppearHere => '完成匯入後會顯示在這裡。';

  @override
  String batchSubtitle(String type, String summary, String date) {
    return '$type - $summary - $date';
  }

  @override
  String failedToLoadConflicts(Object error) {
    return '衝突載入失敗：$error';
  }

  @override
  String get noPendingConflicts => '暫無需要確認的匯入課程。';

  @override
  String get conflictHandling => '衝突處理';

  @override
  String get conflictHandlingSubtitle => '請確認匯入課程中需要選擇的變更和時間重疊。';

  @override
  String changedFieldsCount(int count) {
    return '$count 處欄位變更';
  }

  @override
  String timeConflictsCount(int count) {
    return '$count 個時間衝突';
  }

  @override
  String pendingCount(int count) {
    return '$count 項需確認';
  }

  @override
  String get conflict => '衝突';

  @override
  String get changed => '已變更';

  @override
  String get currentValue => '目前';

  @override
  String get importedValue => '匯入';

  @override
  String get keepCurrent => '保留目前';

  @override
  String get useImported => '採用匯入';

  @override
  String get keepBoth => '兩者共存';

  @override
  String get forceMerge => '保留重疊課程';

  @override
  String get manualEdit => '手動編輯';

  @override
  String conflictMarked(String action) {
    return '已選擇：$action。';
  }

  @override
  String courseSummary(
    int weekday,
    String period,
    String weeks,
    String teacher,
    String location,
  ) {
    return '星期 $weekday，第 $period 節，$weeks，$teacher，$location';
  }

  @override
  String get weekUnknown => '週次未知';

  @override
  String get teacherTbd => '教師待定';

  @override
  String get locationTbd => '地點待定';

  @override
  String changedFields(String fields) {
    return '變更：$fields';
  }

  @override
  String get timeOverlap => '時間重疊';

  @override
  String get icsCalendarExport => 'ICS 日曆匯出';

  @override
  String get icsCalendarExportSubtitle => '按北京時間匯出，可匯入系統日曆。';

  @override
  String get exportIcs => '匯出 .ics';

  @override
  String get currentWeekImage => '目前週圖片';

  @override
  String get currentWeekImageSubtitle => '生成目前活動週的 PNG 課表快照。';

  @override
  String get fullSemesterImage => '整學期圖片';

  @override
  String get fullSemesterImageSubtitle => '生成包含所有課程週次範圍的 PNG 總覽。';

  @override
  String get exportPng => '匯出 PNG';

  @override
  String get exportTimetableCalendar => '匯出課程日曆';

  @override
  String get exportTimetableImage => '匯出課表圖片';

  @override
  String get exportSemesterTimetableImage => '匯出整學期課表圖片';

  @override
  String exportedPath(String path) {
    return '已匯出 $path';
  }

  @override
  String get openExportedFile => '開啟';

  @override
  String get preparingExport => '正在準備匯出';

  @override
  String openExportedFileFailed(String message) {
    return '無法開啟檔案：$message';
  }

  @override
  String get fullSemester => '整學期';

  @override
  String failedToLoadReminderSettings(Object error) {
    return '提醒設定載入失敗：$error';
  }

  @override
  String failedToLoadLanguageSetting(Object error) {
    return '語言設定載入失敗：$error';
  }

  @override
  String failedToLoadThemeSetting(Object error) {
    return '主題設定載入失敗：$error';
  }

  @override
  String failedToLoadTimetableDisplaySetting(Object error) {
    return '課表顯示設定載入失敗：$error';
  }

  @override
  String failedToLoadExportDisplaySetting(Object error) {
    return '匯出顯示設定載入失敗：$error';
  }

  @override
  String get language => '語言';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get display => '顯示';

  @override
  String get showNonCurrentWeekCourses => '顯示非本週課程';

  @override
  String get showNonCurrentWeekCoursesSubtitle => '開啟後，非本週課程會以灰色顯示在課表中。';

  @override
  String get exportDisplaySettings => '匯出顯示';

  @override
  String get showNonCurrentWeekCoursesInExportSubtitle =>
      '開啟後，週課表和整學期 PNG 中的非本週課程會以灰色顯示。';

  @override
  String get themeModeSystem => '跟隨系統';

  @override
  String get themeModeLight => '淺色';

  @override
  String get themeModeDark => '深色';

  @override
  String get denseTimetable => '緊湊課表';

  @override
  String get denseTimetableSubtitle => '第一版已為自適應介面啟用緊湊行距。';

  @override
  String get localData => '本地資料';

  @override
  String get localDataSubtitle => '課表、匯入記錄和提醒設定只保存在本機。';

  @override
  String get backupLocalData => '備份到本地';

  @override
  String get restoreLocalData => '從備份還原';

  @override
  String backupCreated(String path) {
    return '備份已儲存到 $path';
  }

  @override
  String get backupRestored => '資料和設定已還原。';

  @override
  String localDataActionFailed(Object error) {
    return '本地資料操作失敗：$error';
  }

  @override
  String get offlineAppSubtitle => '無需登入；課表和提醒都在本機處理。';

  @override
  String get thirdPartyLicenses => '開放原始碼授權';

  @override
  String get thirdPartyLicensesSubtitle => '查看課格、Flutter 和相依套件的開放原始碼授權。';

  @override
  String get appLicenseDisplayName => '課格（Crid）';

  @override
  String get appLicenseSummary =>
      '課格（Crid）採用 Apache License 2.0 開放原始碼授權；散布時請保留 LICENSE 和 NOTICE 中的歸屬聲明。';

  @override
  String get reminders => '課程提醒';

  @override
  String reminderNotificationTitle(int minutes) {
    return '$minutes 分鐘後上課';
  }

  @override
  String get courseReminders => '課程提醒';

  @override
  String get courseRemindersSubtitle => '課程變更後自動更新未來四週的提醒。';

  @override
  String get androidBackgroundSettings => 'Android 背景執行';

  @override
  String get androidBackgroundSettingsSubtitle => '用於在系統限制背景工作時繼續處理課程提醒。';

  @override
  String get androidBackgroundUnsupported => '這項設定僅在 Android 裝置上可用。';

  @override
  String get androidDeviceStatusTitle => 'Android 裝置';

  @override
  String androidDeviceStatus(
    String manufacturer,
    String model,
    String version,
  ) {
    return '$manufacturer $model，Android $version';
  }

  @override
  String failedToLoadAndroidBackgroundStatus(Object error) {
    return 'Android 背景狀態載入失敗：$error';
  }

  @override
  String get windowsReminderSettings => 'Windows 課程提醒';

  @override
  String get windowsReminderSettingsSubtitle =>
      'Windows 會透過系統排程已啟用的提醒，關閉課格後也不需要保持背景執行。';

  @override
  String get windowsSystemNotifications => '系統通知';

  @override
  String get windowsNotificationsAllowed => '通知已開啟，關閉課格後系統仍可顯示已排程的提醒。';

  @override
  String get windowsNotificationsBlocked => 'Windows 通知已關閉，請在系統設定中開啟以接收課程提醒。';

  @override
  String failedToLoadWindowsReminderStatus(Object error) {
    return 'Windows 提醒狀態載入失敗：$error';
  }

  @override
  String get persistentBackgroundRuntime => '持續背景執行';

  @override
  String get persistentBackgroundRuntimeSubtitle =>
      '開啟後會在通知列顯示靜默常駐通知，用於維持課程提醒的背景工作。';

  @override
  String get persistentBackgroundRuntimeAllowed =>
      '已取得電池最佳化豁免，背景工作受系統電池限制的影響會減少。';

  @override
  String get openNotificationSettings => '通知設定';

  @override
  String get openBatterySettings => '電池設定';

  @override
  String get openExactAlarmSettings => '精確鬧鐘權限';

  @override
  String get openAutostartSettings => '自啟動設定';

  @override
  String get requestBatteryExemption => '申請背景執行權限';

  @override
  String get leadTime => '提前提醒';

  @override
  String minutesShort(int minutes) {
    return '$minutes 分鐘';
  }

  @override
  String get customReminderTime => '自訂時間';

  @override
  String get minutesBeforeClass => '上課前';

  @override
  String get minutesUnit => '分鐘';

  @override
  String get ignoreDoNotDisturb => '忽略勿擾模式';

  @override
  String get ignoreDoNotDisturbSubtitle => 'Android 會開啟系統授權頁；授權後提醒頻道可繞過勿擾模式。';

  @override
  String get windowsIgnoreDoNotDisturbSubtitle =>
      'Windows 會將課程提醒標記為緊急通知，使其可以繞過勿擾模式。';

  @override
  String get vibrateReminder => '關閉提醒聲音';

  @override
  String get vibrateReminderSubtitle => '課程提醒仍會振動，但不播放提示音。';

  @override
  String get windowsMuteReminderSoundSubtitle =>
      'Windows 會靜音顯示課程提醒；是否振動由裝置和系統設定決定。';

  @override
  String get goToToday => '回到今天';

  @override
  String get delete => '刪除';

  @override
  String get save => '儲存';

  @override
  String get cancel => '取消';

  @override
  String get clear => '清除';

  @override
  String semesterEndDate(String date) {
    return '結束日期：$date';
  }

  @override
  String get semesterStartDate => '學期開始日（第一週週一）';

  @override
  String get semesterEndDateOptional => '結束日期（可選）';

  @override
  String get noSemesterEndDate => '未設定結束日期';

  @override
  String get chooseSemesterStartDate => '選擇學期開始日（第一週週一）';

  @override
  String get chooseSemesterEndDate => '選擇學期結束日期';

  @override
  String get addSemester => '新增學期';

  @override
  String get editSemester => '編輯學期';

  @override
  String get deleteSemester => '刪除學期';

  @override
  String deleteSemesterConfirmation(String name) {
    return '確定刪除「$name」及其中的課表方案嗎？';
  }

  @override
  String get cannotDeleteLastSemester => '至少需要保留一個學期';

  @override
  String get semesterDeleted => '學期已刪除';

  @override
  String get editPlan => '編輯方案';

  @override
  String get deletePlan => '刪除方案';

  @override
  String deletePlanConfirmation(String name) {
    return '確定刪除「$name」嗎？';
  }

  @override
  String get cannotDeleteLastPlan => '至少需要保留一個方案';

  @override
  String get planDeleted => '方案已刪除';

  @override
  String get semesterNameLabel => '學期名稱';

  @override
  String get planNameLabel => '方案名稱';

  @override
  String get hiddenCourses => '已隱藏課程';

  @override
  String get hiddenCoursesSubtitle => '找回已從課表中隱藏的課程。';

  @override
  String get noHiddenCourses => '沒有已隱藏課程';

  @override
  String sessionCount(num count) {
    return '$count 個安排';
  }

  @override
  String failedToLoadHolidaySettings(Object error) {
    return '放假模式設定載入失敗：$error';
  }

  @override
  String get holidayMode => '放假模式';

  @override
  String get legalHolidays => '法定節假日';

  @override
  String get legalHolidaysSubtitle => '開啟後自動隱藏中國法定節假日當天的課程，不刪除課程記錄。';

  @override
  String get holidayAdjustment => '調休';

  @override
  String get holidayAdjustmentSubtitle => '選擇是否按官方調休安排顯示課程。';

  @override
  String get holidayAdjustmentNoAdjustment => '不調休';

  @override
  String get holidayAdjustmentMakeUpWorkdays => '按調休安排上課';

  @override
  String get holidayAdjustmentNoMakeUpWorkdays => '調休補班日也休息';

  @override
  String holidayDataLoading(int year) {
    return '正在取得 $year 年中國節假日安排。';
  }

  @override
  String get holidayDataFailed => '暫時無法取得節假日安排，請稍後再試。';

  @override
  String holidayDataUnavailable(int year) {
    return '本機暫無 $year 年節假日安排。';
  }

  @override
  String holidayDataCached(int year) {
    return '正在使用上次取得的 $year 年中國節假日安排。';
  }

  @override
  String holidayDataUpdated(int year) {
    return '已取得 $year 年中國節假日安排。';
  }
}
