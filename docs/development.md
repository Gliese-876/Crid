# Crid App 开发文档

## 1. 项目目标

Crid（课格）是一款面向校园课表管理的应用，使用 Flutter 开发，同时适配 Android 与 Windows。应用采用 Material 3 设计语言，优先保证离线可用、导入稳定、编辑灵活，并支持提醒与导出。

第一版重点解决以下问题：

- 从教务系统或第三方课表工具导入课程表。
- 支持 `.xls`、HTML 表格型 `.xls`、`.ics` 三类文件。
- 在 Android 和 Windows 上提供一致但自适应的课表体验。
- 支持多学期、多课表方案。
- 支持课程编辑、导入合并、冲突 diff、课前提醒、ICS 导出和图片导出。

## 2. 技术栈

| 模块 | 技术选择 |
|---|---|
| 应用框架 | Flutter |
| 设计语言 | Material 3 |
| 平台 | Android、Windows |
| 状态管理 | Riverpod |
| 路由 | go_router |
| 本地数据库 | SQLite + Drift |
| 文件选择/保存 | file_picker |
| 本地通知 | flutter_local_notifications |
| `.xls` 解析 | 优先成熟第三方库；成熟度不足时通过 adapter 隔离并用样例回归测试兜底 |
| HTML 表格解析 | html |
| iCalendar/RRULE | 优先成熟 iCalendar/RRULE 第三方库 |
| 模型/codegen | Freezed、json_serializable、Drift generator |

## 2.1 第三方库选型原则

项目优先使用成熟第三方库，不重复实现已经被稳定解决的问题。第三方库必须先满足成熟度要求，再进入正式技术栈。

成熟第三方库应满足：

- 支持 Android 和 Windows，或明确为纯 Dart 实现且不依赖平台能力。
- 最近仍在维护，兼容当前 Flutter stable 和 Dart stable。
- API 稳定，有清晰文档、示例和测试。
- 下载量、使用者、issue 处理情况或社区反馈能证明其可靠性。
- License 允许在本项目中使用和分发。
- 对关键路径能力提供足够覆盖，避免为了使用库再写大量脆弱补丁。

选型规则：

- 路由、状态管理、数据库、通知、文件选择、HTML 解析、RRULE 展开等成熟领域，优先使用成熟第三方库。
- 课程表格式解析属于项目核心差异点。只有当第三方库足够成熟时才直接依赖；成熟度不足时必须放入 adapter 层，并保留替换空间。
- 不因为“有库”就使用库。若第三方库维护不足、平台支持不完整、行为不稳定或难以测试，应限制在 adapter 内，或实现最小可控解析逻辑。
- 所有进入导入、提醒、数据库和导出链路的第三方库，都必须有样例回归测试或集成测试覆盖。

## 3. 架构分层

项目采用 feature-first 目录结构，并在每个 feature 内保持清晰的 domain、data、presentation 边界。

推荐结构：

```text
lib/
  app/
    app.dart
    router.dart
    theme.dart
    adaptive_shell.dart
  core/
    time/
    file/
    platform/
    errors/
    utils/
  features/
    import/
    timetable/
    editor/
    reminder/
    export/
  data/
    database/
    migrations/
```

核心原则：

- UI 不直接操作数据库。
- 解析器不直接写入正式课表。
- 导入结果先进入 staging，再经过合并引擎。
- 平台能力通过 service/adapter 隔离。
- 领域模型与数据库模型分离，避免 UI 被 Drift 绑定。
- 成熟第三方库优先；成熟度不足或格式风险较高的依赖必须放在 adapter 后面，避免污染领域层和 UI 层。

## 4. 核心数据模型

主要实体包括：

| 实体 | 说明 |
|---|---|
| Semester | 学期信息，包含学期名、第一周周一、节次模板 |
| TimetablePlan | 同一学期下的课表方案，可标记 active |
| Course | 课程基础信息，如课程名、教师、颜色、备注 |
| ClassSession | 一条上课安排，包含星期、节次、周次、地点 |
| ImportBatch | 一次导入记录，保存文件名、类型、时间和摘要 |
| SourceRecord | 原始记录指纹，用于重复导入和 diff |
| MergeConflict | 自动合并失败时的冲突项 |
| ReminderRule | 提醒配置，如提前时间、是否启用 |

默认节次模板：

| 节次 | 时间 |
|---|---|
| 1-2 | 08:00-09:40 |
| 3-4 | 10:00-11:40 |
| 5-6 | 13:30-15:10 |
| 7-8 | 15:30-17:10 |
| 9-10 | 18:00-19:40 |
| 11-12 | 19:50-21:30 |

`.xls` 文件本身不包含真实日期，因此首次导入时必须由用户设置“第一周周一”。

## 5. 导入系统

导入流程分为五步：

1. 用户选择文件。
2. 根据 magic bytes、扩展名和内容识别文件类型。
3. 使用对应 parser 解析为统一的 `ParsedTimetable`。
4. 进入 staging，展示解析摘要。
5. 调用 merge engine，与目标课表方案合并。

三类文件处理策略：

| 文件类型 | 处理方式 |
|---|---|
| BIFF8 `.xls` | 优先评估成熟第三方库；若可用库成熟度不足，则通过 `BiffXlsParserAdapter` 隔离实现，并用样例和 golden 测试固定行为 |
| HTML `.xls` | 按 GBK 解码，用 HTML parser 提取表格 |
| `.ics` | 按 UTF-8 读取，优先使用成熟 iCalendar/RRULE 库解析 SUMMARY、DTSTART、DTEND、RRULE、LOCATION、DESCRIPTION |

导入 parser 必须输出统一结构：

```dart
class ParsedTimetable {
  final String sourceName;
  final ImportFileType fileType;
  final List<ParsedCourse> courses;
  final List<ParseWarning> warnings;
}
```

## 6. 合并与 Diff

重复导入或多来源导入时，采用类似 Git merge 的策略。

合并规则：

- 完全相同的记录跳过。
- 新课程自动加入。
- 同一课程的地点、教师、周次、节次变化进入 diff。
- 时间重叠但课程不同进入冲突。
- 冲突由用户选择保留当前、采用导入、两者共存或手动编辑。

用于判断同一记录的 key 应基于规范化字段：

```text
课程名 + 教师 + 星期 + 节次范围 + 周次规则 + 地点
```

规范化时需要处理：

- 中文空格和全角符号。
- `1-15周`、`1-15`、`13-13` 等周次表达。
- 单周、双周。
- 单元格内多个课程片段粘连。
- ICS 中 LOCATION 同时包含地点和教师的情况。

## 7. 课表方案

应用支持多学期、多课表方案。

每个学期可以有多个 `TimetablePlan`，但只有一个 active 方案。active 方案用于：

- 首页默认显示。
- 系统提醒调度。
- 默认 ICS 导出。
- 默认图片导出。

界面提供单课表视图，用于日常查看和编辑。导入差异与冲突继续通过冲突处理界面解决。

## 8. 课程编辑器

第一版提供完整课表编辑能力，包括：

- 新增课程。
- 修改课程名。
- 修改教师。
- 修改地点。
- 修改星期。
- 修改节次。
- 修改周次范围。
- 设置单双周。
- 添加备注。
- 删除课程安排。
- 隐藏课程。

编辑结果应保留来源信息，但允许用户覆盖导入内容。用户编辑后的记录在后续合并中优先级更高，避免再次导入时被静默覆盖。

## 9. 提醒系统

提醒采用滚动调度策略，只调度未来四周课程。

触发重建提醒的场景：

- 应用启动。
- 导入完成。
- 课程编辑完成。
- 切换 active 方案。
- 修改提醒提前量。
- 修改学期第一周日期。

默认提醒策略：

- 课前 20 分钟提醒。
- 用户可关闭全局提醒。
- 用户可按课程关闭提醒。
- Android 和 Windows 均使用 `flutter_local_notifications`。
- Windows 发布目标为 MSIX，以获得更稳定的通知能力。

提醒调度采用未来四周的滚动窗口，不应一次性排完整学期，避免平台限制和权限问题。

## 10. 导出系统

第一版支持两种导出：

### ICS 导出

从选定课表方案生成标准 iCalendar 文件。

要求：

- 每个 `ClassSession` 展开为对应 RRULE 或事件集合。
- 使用 Asia/Shanghai 时区。
- 保留课程名、地点、教师、节次。
- 导出的 ICS 应能被常见日历应用重新导入。

### 图片导出

使用 Flutter `RepaintBoundary` 捕获课表视图。

支持范围：

- 当前周课表图片。
- 整学期课表图片。
- 单课表视图。

## 11. UI 设计

整体使用 Material 3。

Android：

- 底部导航。
- 周视图优先。
- 课程详情用 bottom sheet 或页面跳转。
- 文件导入流程尽量线性。

Windows：

- NavigationRail。
- 宽屏支持多栏布局。
- 课表区域更密集。
- 适合鼠标操作和键盘快捷键的布局，但第一版不强制实现完整快捷键系统。

主要页面：

- 首页课表。
- 学期/方案管理。
- 导入中心。
- 冲突处理。
- 课程编辑。
- 导出页面。
- 设置页面。

## 12. 测试策略

第一版测试重点放在解析器和领域逻辑。

必须覆盖：

- 三个 `test/` 样例文件。
- BIFF `.xls` 解析。
- GBK HTML `.xls` 解析。
- UTF-8 `.ics` 解析。
- 周次范围解析。
- 单双周解析。
- 单元格内多个课程解析。
- ICS RRULE 展开。
- 重复导入去重。
- 自动合并。
- 冲突检测。
- ICS 导出后重新解析一致性。

UI 层做 smoke 测试即可：

- Android 宽度下首页可显示。
- Windows 宽屏下课表可显示。
- 导入预览页面可进入。
- 冲突 diff 页面可操作。
- 课程编辑页面可保存。

## 13. 发布与平台

Android：

- 常规 APK 构建；发布产物不再包含 AAB。
- 需要申请通知权限。
- 文件导入使用系统文件选择器。

Windows：

- 使用 MSIX 安装包。
- 需要配置应用身份、图标和通知能力。
- 文件导入和导出使用系统文件选择器。

第一版不支持：

- 云同步。
- 账号登录。
- Web 端。
- iOS/macOS。
- 直接连接教务系统。
- 自动识别所有高校课表格式。

## 14. 开发顺序建议

推荐按以下顺序开发：

1. 初始化 Flutter 工程、Material 3 theme、路由和自适应 shell。
2. 评估并锁定成熟第三方库；成熟度不足的能力先定义 adapter 接口。
3. 建立 Drift 数据库和核心领域模型。
4. 实现节次、周次、学期日期换算。
5. 实现三类文件 parser，并用样例测试固定行为。
6. 实现导入 staging、自动合并和冲突 diff。
7. 实现单课表视图和课程详情。
8. 实现完整课程编辑器。
9. 实现多学期、多方案和 active 方案切换。
10. 实现提醒系统。
11. 实现 ICS 导出和图片导出。
12. 完成 Android 与 Windows 验收测试。
