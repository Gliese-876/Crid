# 更新日志

## 1.2.0-release - 2026-07-15

### 课表显示

- 新增“显示非本周课程”开关，Android 和 Windows 用户都可以在“设置 → 显示”中开启；开启后，未在所选周上课的课程仍会保留在课表对应位置，并以灰色遮罩区分。
- 该选项默认关闭，保持课表只显示所选周实际课程的原有行为；设置会在本地持久化。
- 周课表和全学期 PNG 导出提供独立的“显示非本周课程”开关，不会改动日常课表的显示偏好。

### Windows 原生能力

- 将 Android 课程提醒对应到 Windows 原生 Toast 通知：通过 C++/WinRT 查询系统通知可用状态，并从设置页直接打开 Windows 通知设置。
- 将“忽略免打扰”映射为 Windows 紧急通知场景，将“关闭提醒声音”映射为静音 Toast 音频；提醒进入系统调度队列后无需常驻后台进程。
- 为 Windows 通知补齐应用身份、Toast 激活器和通知图标，并让 Runner、MSIX 和通知共用课格图标资产。
- 增加 `.ics`、`.xls`、`.mht`、`.mhtml`、`.pdf` 和 `.txt` 的 MSIX 文件关联；从资源管理器双击受支持文件时，应用会直接进入导入预览。
- 保留 Windows 原生文件选择、保存和系统文件打开能力，使导入和导出使用桌面系统对话框。

### Windows 桌面界面

- 将桌面端主操作整理到持续可见的工具栏和可折叠 NavigationRail，补齐新建课程、导入、导出、设置、学期和方案上下文。
- 为导入、导出、课程编辑、设置、许可证和冲突页增加按路由区分的桌面内容宽度，不再把移动端卡片拉伸到整个窗口。
- 将设置页改为双栏桌面工作区，并用 Windows 原生提醒状态替代 Android 后台运行卡片。
- 将导入页改为“来源/历史 + 预览”双栏工作区，将导出页改为三任务卡桌面布局；方案和课程编辑页继续使用响应式双栏。
- 补齐简体中文、繁体中文和英文的 Windows、显示和导出文案。

### 数据稳定性与测试

- 将历史 Drift 数据库字段迁移改为幂等检查，修复迁移部分执行后再次启动可能因重复添加 `is_hidden` 字段而白屏的问题。
- 增加 Windows 通知映射、原生状态、文件激活、桌面布局、图标资产、显示偏好和数据库迁移恢复测试。
- 真实使用 Windows 可执行文件携带 ICS 路径启动，确认能进入导入页并解析 27 条课程、27 条新增和 0 个冲突。

### 安装与发布

- 将应用版本提升到 `1.2.0-release+3`，将 Windows MSIX 版本提升到 `1.2.0.0`。
- 增加一键安装/更新脚本。首次安装只需一次 UAC 确认以信任本地计算机证书，后续使用同一证书更新时无需再次提权。
- Windows Release 改为 ZIP 分发，统一包含公开证书、安装脚本和已签名 MSIX；私钥 PFX 不进入发布产物。
- 发布 Android `1.2.0-release` 正式签名 APK，包括一个覆盖 arm64-v8a、armeabi-v7a 和 x86_64 的通用包，以及三个分 ABI 安装包。
- 增加 Android 到 Windows 的功能对等矩阵，并更新 README 和开发文档中的 Windows 安装、原生能力与发布流程。

本次发布已验证：

- `flutter analyze`
- `flutter test`
- `android\gradlew.bat assembleRelease --offline`
- `android\gradlew.bat assembleRelease --offline -Psplit-per-abi=true`
- `flutter build windows --release --build-name=1.2.0-release --build-number=3`
- `dart run msix:create --certificate-password <local certificate password>`
- Android APK 包身份、版本、ABI 与发布签名检查
- Windows 安装脚本 PowerShell 语法、MSIX 清单版本、签名和 ZIP 内容检查


## 1.1.0-release - 2026-06-07

### 课表

- 将课表视图改为按 24 小时周视图显示课程块，课程位置和高度按具体分钟计算，不再依赖恰好整节次。
- 将日期栏固定在课表卡片顶部，纵向浏览时间轴时不再跟随左侧时间栏和课程块滚动。
- 将左侧时间栏固定在课表卡片左侧，左右滑动切换周次时不再跟随日期列横向移动，只随纵向时间轴滚动。
- 左侧时间栏在北京师范大学珠海校区官方作息时间内按 12 节课分行，在 8:00 前、午间空档和 21:30 后按整点分隔，同时继续支持一天 24 小时内任意分钟事件的准确定位。
- 课程块按真实起止分钟定位和计算高度，即使起止时间不在节次线或整点线上，也不会被强制贴齐参考线。
- 增加课程节次和具体分钟数之间的统一映射，课程、考试、导入、导出、提醒和备份恢复共用 `CourseTimeRange` 时间结构。
- 修复应用启动时自动定位偶尔停在中间周、或按当天而不是本周最早课程定位的问题；启动、点击底栏“课表”和点击“回到今天”时，会自动定位到当前周有课的最早时间，且不会在顶部留下大块空白。
- 点击顶部日期栏任意一天后，会自动定位到当前可见周的最早课程。
- 左右滑动切换周次时，会在横滑稳定且目标周仍然可见后自动定位到新周最早课程；连续横滑会取消旧周滚动任务，避免跳周和错滚。
- 修复左右滑动后自动定位依赖后续帧导致偶发不触发的问题，并修复从“方案”页返回“课表”页时不会重新自动定位的问题。
- 修复课表时间区域随周数换 key 导致 PageView 重建、连续横滑跳回第 2 周，以及之后可能无法继续跳到第 3 周的问题。
- 将课表自动滚动改为更慢、更舒缓的 Material 非线性缓出动画，并将目标改为课程块顶边严格对齐，不再保留顶部空隙。
- 略微拉高课表时间轴行距，使课程块更高、更易扫读。
- 略微调宽课表页主体区域，在保留边距的同时更充分利用屏幕宽度。
- 将手动新增/编辑课程的时间输入从整节次下拉调整为 `HH:mm` 开始和结束时间。
- 考试课程块现在可以从详情菜单进入同款编辑页，支持修改名称、轮次、地点、时间、周次和备注。
- 普通课程和考试课程都支持手动隐藏；隐藏后的考试也会进入“隐藏课程”列表并可恢复。
- 法定节假日显示策略改为普通课程和考试课程分别设置，均支持正常显示、变灰弱化和完全隐藏；默认普通课程变灰弱化，考试课程正常显示。

### 导入、导出和数据

- ICS 导入、ICS 导出、导入预览、冲突差异页、课程提醒、课表图片导出和本地备份恢复均保留并使用精确分钟时间。
- 课表图片导出改为与真实课表页面一致的表头、左侧时间列、分隔线和课程块间距，并按每周有效课程/考试的最早开始到最晚结束精确裁剪，不再导出完整 24 小时时间轴。
- 提高课表图片 PNG 渲染倍率；整学期图片改为逐周渲染后在后台 isolate 中逐行流式编码 PNG，绕开超高 `Picture.toImage()` 的纹理高度限制，并避免一次性分配整张未压缩长图导致应用无响应或崩溃；修正导出表头日期、今日圆点和时间列整点标签的居中错位，加高表头留白。
- 课表图片导出与课表页面共用节假日课程显示策略，整周图片和整学期图片都会按设置正常显示、弱化或隐藏普通课程和考试课程。
- 为课程安排表增加 `startMinuteOfDay` 和 `endMinuteOfDay` 字段，并保留旧节次字段作为兼容派生数据。
- 为考试安排表增加手动隐藏字段；本地备份会同步导出和恢复精确分钟字段、考试隐藏状态和节假日显示策略。

### 界面

- 修复开放源代码许可列表中 `课格（Crid）` 许可重复出现的问题，保留顶部卡片作为应用自身许可入口。
- 修复许可详情页顶部重复标题卡导致正文轻微上浮的问题，详情正文现在直接从页面标题下方正常排版。
- 修复移动端课程详情底部弹窗动画生硬的问题，恢复更自然的进入和退出动画。
- 修复课程详情底部弹窗背景遮罩缺失的问题；遮罩覆盖顶栏和中间内容，不覆盖底栏，弹窗打开时只有未被遮罩的底栏仍可点击。
- 修复点击课程块打开底部弹窗时弹窗未贴紧底栏，以及底层课表被路由切换动画错误横向滑动的问题。
- 修复课表左右滑动时相邻周保留不同纵向滚动位置，导致可见时间范围在横滑过程中跳变的问题。
- 修复课表主体加宽后“今日课程”等底部栏目也被错误加宽的问题，底部栏目恢复标准页面边距。
- 微调课表日期栏高度、导出图片日期栏高度，以及课程详情底部菜单的编辑/关闭按钮右侧对齐。

### 发布

- 将应用版本变更为 `1.1.0-release+2`，将 Windows MSIX 版本变更为 `1.1.0.0`。
- 本次覆盖发布保持应用版本号和 Windows MSIX 版本号不变，重新生成 `v1.1.0-release` 发布产物。
- 同步简体中文、繁体中文和英文 README 中的最新正式版与安装包文件名。

本次发布已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release --build-name=1.1.0-release --build-number=2`
- `flutter build apk --release --split-per-abi --build-name=1.1.0-release --build-number=2`
- `flutter build windows --release --build-name=1.1.0-release --build-number=2`
- `dart run msix:create --certificate-password <local certificate password>`

## 1.0.1-release - 2026-06-05

### 导入

- 增加从 KINGOSOFT 教务系统 `.mht`、`.mhtml` 和 `.pdf` 导出文件导入考试安排。
- 增加通过直接粘贴教务系统考试安排文本导入考试安排。
- 修复导入考试安排后，考试只保存到考试安排列表而不会显示在课表周视图中的问题。
- 保留 `.xls` 课表导入，移除不含可提取课表的 `.html` 考试安排夹具支持表述。

### 数据

- 增加本地数据和设置备份到指定目录。
- 增加从本地备份文件恢复数据和设置。

### 提醒

- 重构课程提醒窗口，修复上课后倒计时显示负数的问题。
- 支持多个预设提醒时间节点、自定义提醒提前量、忽略免打扰，以及在静音模式下以振动形式提醒。
- 将“静音振动提醒”重命名为“关闭提醒声音”，明确默认提醒也会振动，开启该选项只会关闭提示音。
- Android 课程提醒通知继续使用高优先级提醒渠道；独立后台常驻通知保持低优先级服务通知，减少对用户的打扰。
- Android 13 及以上改用 `USE_EXACT_ALARM` 声明精确闹钟能力，Android 12/12L 继续使用 `SCHEDULE_EXACT_ALARM`，并保留不可用时回退到非精确调度的路径。

### 界面与文档

- 重构开放源代码许可页面，用懒加载列表和独立详情页替代一次性展开全部许可证文本，减少打开列表和查看详情时的卡顿。
- 将许可证相关可见文案从“第三方开源许可”调整为“开放源代码许可”，并在列表中补充课格自身的 Apache License 2.0 完整文本。
- 移除许可证列表和详情页中的“X 段许可文本”计数展示，并将课格自身许可统一显示为“课格（Crid）”。
- 调整课程信息菜单与弹窗遮罩，使浅色和深色模式使用更协调的 Material 3 遮罩色。
- 调整移动端课程详情浮层，使点击课程块后弹出的详情面板停留在底部导航栏上方。
- 修复移动端课程详情浮层的进入/退出动画和背景阴影效果，并让浮层背景与底部导航栏保持一致。
- 同步简体中文、繁体中文和英文 README。

### 隐私

- 匿名化 KINGOSOFT 考试安排夹具、课表夹具和 PDF 夹具中的个人信息与真实教务系统域名。

### 发布

- 将应用版本提升到 `1.0.1-release+2`，将 Windows MSIX 版本提升到 `1.0.1.0`。
- 将 Dart/Flutter 依赖同步到当前可解析的最新稳定版本。
- 迁移 Android app 模块，移除其对 Kotlin Gradle Plugin 的直接应用，降低未来 Flutter 构建兼容风险。
- Android 发布产物不再包含 AAB，仅保留通用 APK 和分 ABI APK。
- 本次补丁发布保持应用版本号和 Windows MSIX 版本号不变，重新生成 `v1.0.1-release` 发布产物。

本次发布已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release --build-name=1.0.1-release --build-number=2`
- `flutter build apk --release --split-per-abi --build-name=1.0.1-release --build-number=2`
- `flutter build windows --release --build-name=1.0.1-release --build-number=2`
- `dart run msix:create`

## 1.0.0-release - 2026-05-28

### 第一个正式版

- 在将此前所有发布产物视为 beta 构建后，开启第一个正式发布线。
- 将公开应用版本重置为 `1.0.0-release+1`，将 Windows MSIX 版本重置为 `1.0.0.0`。
- 将 Android 应用 ID 和 Windows MSIX 标识改为正式包身份 `app.crid.release`。
- 将此前发布产物移动到被忽略的 `beta_releases/` 目录，并创建新的被忽略的 `releases/` 目录用于正式发布产物。

### 发布签名

- 添加 Android 正式版签名，使用本地生成的正式版密钥库。
- 添加 Windows MSIX 签名元数据，并使用本地代码签名证书生成 v1.0.0-release Windows MSIX 包。

### 隐私

- 将被跟踪的真实导入夹具替换为等价的合成测试夹具。
- 仅在被忽略的本地备份目录中保留私有原始夹具。

本次发布已验证：

- `flutter test`
- `flutter build apk --release --build-name=1.0.0-release --build-number=1`
- `flutter build apk --release --split-per-abi --build-name=1.0.0-release --build-number=1`
- `flutter build appbundle --release --build-name=1.0.0-release --build-number=1`
- `flutter build windows --release --build-name=1.0.0-release --build-number=1`
- `dart run msix:create`

## 1.0.32 - 2026-05-28

### 应用身份

- 将面向用户的文案、Dart 包导入、Android 身份、Windows 二进制元数据、导出文件名和本地数据库文件名迁移到 课格 / Crid。

### 假期模式

- 在课程表网格中，将启用法定节假日模式后隐藏课程的日期标记为淡化的休息列。
- 将同样的假期休息列标记应用到当前周和全学期 PNG 导出。

### 发布

- 将应用版本提升到 `1.0.32+33`，将 Windows MSIX 版本提升到 `1.0.32.0`。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build windows --release`

## 1.0.31 - 2026-05-28

### 应用身份

- 将面向用户和平台的身份资源重命名为 课格 / Crid，包括 Dart 包导入、Android 包身份、Windows 二进制元数据、导出文件名和本地数据库文件名。
- 从资源路径、测试夹具、文档和生成的本地化输出中移除旧的学校专属命名。

### 发布

- 将应用版本提升到 `1.0.31+32`，将 Windows MSIX 版本提升到 `1.0.31.0`。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.30 - 2026-05-28

### Android 通知

- 当应用回到前台时重建课程提醒，包括从 Android 设置返回之后。
- 将滚动课程提醒窗口增加到四周，以减少应用不常打开时的提醒缺口。
- 如果平台或权限状态拒绝精确闹钟调度，则使用非精确闹钟重试已计划的课程提醒。
- 响应精确闹钟权限状态变化，使后台运行时能够在 Android 设置变更后恢复。

### 设置与本地化

- 简化 Android 后台运行设置卡片，只保留用户保持提醒稳定所需的控件。
- 优化受支持语言中的设置文案，包括使用更常见的中文术语“调休”来表述假期调整。
- 说明 Android 后台运行使用静默常驻通知，并保留电池和自启动设置入口。
- 本地化提醒通知、导入警告、Android 服务文本和月份标签。
- 在设置中添加第三方开源许可证入口。

### 发布

- 将应用版本提升到 `1.0.30+31`，将 Windows MSIX 版本提升到 `1.0.30.0`。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create --signtool-options "/fd SHA256 /f <test_certificate.pfx> /p 1234"`

## 1.0.27 - 2026-05-26

### 导航

- 将导入、冲突处理、添加/编辑课程、导出和设置移动到独立的顶层页面，使这些流程中底部导航栏和导航栏轨道保持隐藏。
- 将 Android 页面转场切换为 iOS 风格的水平路由动画。

### Android

- 将新安装用户的提醒默认设为关闭，并且只在用户启用提醒时请求通知和精确闹钟权限。
- 将课程提醒和常驻后台运行时通知保留在不同通知渠道中。
- 使用 Material You 自适应、主题化、浅色和深色资源重建启动图标。

### 课程编辑

- 从新建课程表单中移除预填的课程名、教师和地点文本。

### 发布

- 将应用版本提升到 `1.0.27+28`，将 Windows MSIX 版本提升到 `1.0.27.0`。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.26 - 2026-05-26

### Android

- 禁用 predictive back 支持，并移除 predictive back 目标遮罩。
- 重做 Android 通知权限、精确闹钟处理、计划课程提醒、开机重排程和常驻后台服务通知。
- 添加 Android 后台服务状态检查，以及精确闹钟、通知访问、OEM 自启动/后台限制的设置入口。
- 添加专用通知状态图标，并刷新 Android 主题化启动图标资源，以便在 Android 16 上更稳妥地渲染。

### 课程表与导出

- 防止在课程表和方案目标之间切换时闪现被露出的背景。
- 修复学期图片导出，使其在包含课程的最后一周停止，而不是导出空白的最后一周。
- 修复 Android 导出文件打开逻辑：保留一个应用缓存副本供“打开”操作使用，同时仍保存到用户选择的位置。

### 发布

- 将应用版本提升到 `1.0.26+27`，将 Windows MSIX 版本提升到 `1.0.26.0`。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.25 - 2026-05-26

### 导航

- 修复从“方案”页触发 Android 返回时返回课程表，而不是退出应用。
- 添加由路由动画驱动的 predictive back 遮罩，覆盖被露出的目标表面，并遵循 Flutter 原生 predictive back 过渡模型。
- 为“添加课程”和“编辑课程”提供不同页面标题。

### 课程表

- 让课程表时间列比课程网格表面更浅。
- 在“方案”页添加“隐藏课程”恢复区域。
- 为已删除课程、已删除方案和已删除学期的提示条添加恢复操作。

### 导出

- 重做图片导出样式，使其匹配当前 Material 3 表面和课程卡片处理方式。
- 将学期图片导出改为从第 1 周拼接周视图，直到第一个空周或可选学期结束周为止，以先到者为准。
- 修复导出课程卡片文本重叠问题，并在保存导出文件后添加打开操作。

### 本地化与图标

- 本地化生成的默认学期名称，并在应用语言变化时同步未被手动编辑的名称。
- 重新平衡导入标签控件的图标对齐，并使用 Android 自适应图标安全间距和居中视觉重心重新生成启动图标。

### 发布

- 将应用版本提升到 `1.0.25+26`，将 Windows MSIX 版本提升到 `1.0.25.0`。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.24 - 2026-05-26

### Material 3 Expressive

- 收紧二级页面应用栏标题间距，使导入、导出和设置标题更靠近返回按钮。
- 重新平衡按钮、标签控件、徽标和分段控件的颜色角色，使页面操作更贴合各自屏幕，同时保留成对的浅色和深色主题。
- 增强课程表时间列与应用背景之间的色调区分。

### 导入

- 将导入合并流程的措辞改为面向用户的“审核”和“添加到课程表”语言，而不是偏暂存流程的术语。

### 导航

- 将课程表和方案切换改回同级目标导航，使 Android predictive back 不再突然露出课程表作为背景层。

### 应用图标

- 添加 Material 3 Expressive 应用图标，包括 Android 自适应、圆形和单色主题化图标资源，以及刷新后的 Windows 图标。
- 添加自动化图标资源覆盖，包括 Android 密度检查和视觉重心平衡检查。

### 发布

- 将应用版本提升到 `1.0.24+25`，将 Windows MSIX 版本提升到 `1.0.24.0`。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.23 - 2026-05-26

### Material 3 Expressive

- 再次减轻浅色模式表面处理，并调整深色模式配套表面，使两种主题保持匹配。
- 进一步增强课程表左侧时间列与应用背景之间的视觉区分，使用略微更明确的色调表面。
- 将课程表顶部栏的“添加课程”操作与相邻的导入、导出、更多菜单和设置按钮对齐。

### 动效

- 再次略微缩短共享应用微动效和菜单动画时长，使较大的界面过渡感觉更快。

### 发布

- 将应用版本提升到 `1.0.23+24`，将 Windows MSIX 版本提升到 `1.0.23.0`。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.22 - 2026-05-26

### Material 3 Expressive

- 再次减轻成对的浅色模式表面处理，并同步调整深色模式表面深度，使两种模式保持视觉匹配。
- 保持“今天”操作为圆角矩形，并保留直接的课程表工具栏操作顺序。

### 动效

- 略微缩短共享应用微动效和菜单动画时长，使较大的界面过渡更敏捷。
- 将课程表/方案工具栏操作过渡改为只动画变化的“添加课程”槽位，保持持久的导入、导出和设置操作稳定，防止按钮闪烁。

### 发布

- 将应用版本提升到 `1.0.22+23`，将 Windows MSIX 版本提升到 `1.0.22.0`。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.21 - 2026-05-26

### 启动

- 移除应用启动时的离屏设置页预热，使设置依赖、布局分支和异步状态只在需要时加载。
- 保留用于常见 Material 表面和课程块的轻量 shader 预热路径。

### Material 3 Expressive

- 减轻课程块 Monet 色调调色板，并略微放宽课程对比度阈值，同时保持浅色前景文本可读。
- 将浅色和深色主题表面重做为成对的 Material 3 Expressive 处理：浅色表面向白色抬升，深色表面向黑色下沉，并且两者保留相同动态颜色角色。
- 进一步减轻课程表外壳的成对表面处理，同时保持深色模式深度与浅色模式同步。
- 为卡片、应用栏、导航、输入框、标签控件、进度和浮动操作表面添加匹配的组件角色覆盖。
- 将“今天”浮动操作改为圆角矩形，而不是默认的扩展胶囊形。
- 调整课程表顶部栏，使“添加课程”、“导入”和“导出”除极窄屏幕外直接可见，并将“添加课程”放在“导入”和“导出”之前。

### 导航动效

- 恢复课程表和方案之间的原生 Material 路由过渡。
- 将核心目标导航改为前进入栈、后退出栈，使路由动效符合所选标签隐含的物理方向。
- 为课程表和方案之间切换时的右上角操作区域添加原生 Flutter 微动画。
- 略微缩短应用微动效和菜单动画时长，使界面过渡响应更快。

### 性能

- 在 PageView 滑动前预计算每个学期周的可见课程列表、日期和重叠布局，使水平切换周时手势期间的工作量更少。
- 保留现有课程表视觉，同时将周页面置于重绘边界和保活缓存之后。

### 测试

- 添加成对浅色/深色深度和匹配组件角色的主题覆盖。
- 添加课程表顶部栏操作顺序和圆角矩形“今天”操作的组件测试覆盖。
- 重新运行主题、课程颜色、课程表滑动、导航和完整回归覆盖。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.20 - 2026-05-26

### 导航动效

- 通过将课程表和方案两个核心目标视为标签级导航，而不是路由入栈/出栈过渡，修复二者切换时的闪烁。
- 保留二级工具的原生路由过渡，同时移除可能短暂暴露应用外壳背景的核心标签页面过渡。

### 性能

- 为设置页添加空闲时预热，使首次打开前离屏构建设置卡片、异步状态分支和布局。
- 保留课程表课程块定位动画和内部课程卡片滚动，同时保持周页面缓存，以获得更平滑的水平周滑动。

### 测试

- 在导航和预热变更后重新运行自适应应用外壳、设置、课程表滑动和课程卡片覆盖。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.19 - 2026-05-25

### 导航动效

- 重做路由过渡，使前进导航、反向导航、嵌套页面和源页面返回沿着由路由关系隐含的方向移动。
- 将顶部栏标题和操作过渡与页面动效对齐，而不是独立切换。
- 添加自定义左边缘返回预览，在完成返回操作前播放返回动画的开头片段。

### 微交互

- 为工具栏操作、周导航、浮动操作、课程块和课程列表行添加共享按压和悬停缩放反馈。
- 为课程详情对话框和底部弹层添加细微弹出入场动效。
- 扩展假期调整 Material 3 Expressive 菜单，加入动画触发反馈、选中项反馈和箭头旋转。

### 测试

- 添加核心导航、详情返回和嵌套页面的路由动效覆盖。
- 添加返回预览手势覆盖，包括仅边缘触发行为。
- 添加共享微交互覆盖，验证点击处理仍然保留。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.18 - 2026-05-25

### 设置

- 将设置改为独立的全屏对话框路由，使打开设置时底部导航栏和桌面导航轨道保持隐藏。
- 将右上角设置操作改回普通图标按钮，不使用填充色调背景。
- 将假期调整下拉框替换为自定义 Material 3 Expressive 菜单，包含圆角表面、选中状态处理和禁用状态样式。

### Android

- 移除应用的预测返回启用项，并强制 Android 页面过渡回到非预测式缩放过渡。

### 课程表颜色

- 重新平衡课程块颜色，使用更高的 tone 和 chroma，使其在浅色和深色主题中都能从课程表主体、课程表表头和应用背景中区分出来。
- 更新同页课程颜色分配逻辑，通过视觉距离选择颜色，减少近似重复的课程块颜色。

### 测试

- 更新全屏设置路由、普通设置操作和假期调整 Material 菜单的组件测试覆盖。
- 添加课程调色板覆盖，验证与应用和课程表表面的对比度和视觉区分。
- 添加主题覆盖，防止 predictive back 过渡回归。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.17 - 2026-05-25

### 导航

- 将设置从紧凑底部导航和宽屏 NavigationRail 中移出，改为顶部右侧应用栏/标题栏操作。
- 保留从课程表或方案打开设置时的来源感知返回行为。

### Material 3 Expressive

- 将应用颜色生成切换到 Flutter 的 expressive dynamic scheme variant，并使用更强的表面层级。
- 使用更具表现力的 Material 3 形状和状态更新应用栏、导航指示器、卡片、输入框、图标按钮、填充/描边按钮、开关、滑块和提示条。

### Android 提醒

- 将课程提醒改为显示 `XX 分钟后上课`，并附带课程时间、地点和教师详情。
- 让 Android 课程提醒通知在上课前保持常驻，并在课程开始时自动清除。
- 使用低重要性、无声音、无震动的服务渠道，降低常驻后台运行时通知的打扰。
- 为用户启用的常驻后台运行时服务添加开机/包替换恢复。

### 测试

- 更新右上角设置入口和核心路由返回行为的组件测试覆盖。
- 添加常驻倒计时和自动清除参数的提醒通知覆盖。
- 更新 expressive Material 3 表面圆角的主题覆盖。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.16 - 2026-05-22

### 颜色

- 在保留 Material You 颜色系统的同时，减轻应用表面处理。
- 提高课程表课程块 tone，使调色板不再显得过暗。
- 让课程块继续使用 Monet 色调颜色和白色 Monet 文本。
- 略微放宽课程文本对比度下限，同时增加上限，避免课程块过暗。

### 测试

- 更新主题和课程颜色测试，以适配更浅的对比范围。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.15 - 2026-05-21

### 导航

- 修复从设置返回方案时核心标签动画方向错误的问题。
- 保留原生前进导航，同时为向左移动的核心标签切换使用反向过渡。
- 将顶部栏标题和操作动效与页面方向对齐。

### 测试

- 添加设置到方案路径及其返回行为的覆盖。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.14 - 2026-05-21

### 课程表颜色

- 让每个课程块前景都使用浅色 Monet neutral tone。
- 重新平衡课程调色板，使用更深的 Monet tone，保持浅色文本可读。
- 保留通用的同页颜色区分逻辑，不使用课程专属规则。

### 测试

- 更新颜色测试，要求课程前景为浅色、前景/背景属于 Monet 调色板，并且同页颜色有视觉区分。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.13 - 2026-05-20

### 课程表颜色

- 重做课程着色，使同一课程的重复时段在不同周保持视觉一致。
- 添加同页颜色分配逻辑，在保持 Monet 色调调色板范围内的同时，避免接近的色相和灰度匹配。
- 将课程前景颜色切换为 Monet neutral tone，并进行 WCAG AA 对比度检查。

### 测试

- 添加同页颜色区分以及仅使用 Monet 前景/背景选择的覆盖。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.12 - 2026-05-20

### 假期模式

- 恢复内置的 2026 年中国假期安排作为首选来源，并对照中国政府通知进行验证。
- 保留对没有内置数据年份的在线假期获取，并在成功获取后本地缓存。
- 添加逐来源重试处理，再从 `holiday.ailcc.com` 回退到 `timor.tech`。
- 为 Android 正式版添加网络权限，使在线假期数据可以在调试/性能分析构建之外获取。

### 测试

- 添加内置假期优先级、来源重试、回退来源使用和缓存数据恢复的覆盖。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.11 - 2026-05-20

### 桌面端

- 将桌面导航和课程表呈现与 Android 体验同步。
- 添加可折叠桌面侧边栏，使课程表在大屏上可以回收横向空间。
- 更新桌面课程表表头，保留 Android 风格标题和当前周上下文。
- 调整高分辨率桌面课程表布局，使完整日期网格更可靠地适配屏幕。

### 测试

- 添加桌面主操作、可折叠导航、高分辨率课程表适配和设置显示控件的组件测试覆盖。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.10 - 2026-05-20

### 课程表 UI

- 将课程表网格角落表头替换为当前本地化月份标签。
- 直接在课程表日历表头中高亮今天。
- 将课程表网格下方列表改为显示今天的课程，而不是所选周的完整课程列表。
- 增大应用表面和输入框圆角，更贴近 Material You / MD3 样式。

### 设置

- 添加持久化显示设置，用于跟随系统主题、强制浅色主题或强制深色主题。

### 测试

- 添加本地化月份标签、今天课程列表过滤和手动深色主题偏好的组件测试覆盖。
- 添加更大 Material You 块和输入框圆角的主题覆盖。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.9 - 2026-05-20

### 课程表 UI

- 略微加深 Material You / Monet 课程表课程调色板，同时保持浅色课程文本。
- 增强圆角功能块卡片背景与应用页面背景之间的对比。

### 测试

- 添加主题覆盖，断言卡片块与页面背景有可见区分。
- 重新运行课程颜色和课程表组件测试覆盖。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build apk --release --split-per-abi`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.8 - 2026-05-20

### 课程表 UI

- 调整 Material You / Monet 课程颜色，使用更深的色调值，使课程表课程文本始终以浅色文本渲染。
- 添加共享课程文本颜色常量，并修复课程表块和课程表图片导出中的课程文本渲染，使其为白色。

### 测试

- 更新课程颜色测试，断言每个生成的课程颜色与浅色文本满足 WCAG AA 对比度。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.7 - 2026-05-20

### 课程表 UI

- 将课程表课程颜色切换为 Material You / Monet 风格的 HCT 色调调色板。
- 将 `material_color_utilities` 添加为显式依赖，使课程颜色从色调调色板生成，而不是使用固定手选十六进制颜色。
- 保留确定性的课程颜色分配，并自动选择黑/白课程卡片文本以满足 WCAG AA 对比度。

### 测试

- 针对生成调色板重新运行课程颜色和课程表组件测试覆盖。

完成这些变更后已验证：

- `flutter analyze --no-pub`
- `flutter test --no-pub`
- `flutter build apk --release --no-pub`
- `flutter build appbundle --release --no-pub`
- `flutter build windows --release --no-pub`
- `dart run msix:create`

## 1.0.6 - 2026-05-20

### 课程表 UI

- 将此前的高对比课程调色板替换为更平和的产品风格调色板，同时保留 WCAG AA 文本对比度。
- 移除课程卡片边缘描边，使课程表块使用干净的填充色表面。
- 增加课程表行高，并允许课程名称、地点和教师字段跨多行换行。
- 为极端文本长度添加内部课程卡片滚动，使字段在不缩小文本或溢出的情况下保持可用。
- 添加课程卡片语义标签，包含课程名称、地点和教师。

### 测试

- 扩展窄屏课程卡片覆盖，断言教师文本也存在。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.5 - 2026-05-20

### 课程表 UI

- 在课程表、方案和设置页面之间切换时添加原生顶部栏过渡。
- 将课程颜色切换为高对比、色盲友好的调色板，并对导入课程和手动创建课程使用确定性分配。
- 添加自动黑/白课程卡片文本选择和细微卡片描边，使完整调色板中的文本保持可读。
- 重做紧凑课程卡片布局，使标题、地点和教师详情更积极地使用可用块高度，同时不降低字号或溢出。

### 测试

- 添加颜色调色板唯一性、确定性分配和 WCAG AA 文本对比度覆盖。
- 添加窄屏组件测试覆盖，验证密集课程卡片详情不会溢出。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.4 - 2026-05-20

### 导入合并

- 修复同一课程有多个每周时段的导入，使每个不同的星期/节次都被保留。
- 添加强制合并时间冲突支持，使并行课程可以共存在同一课程表时段。
- 为同课程多时段导入和强制合并并行课程添加回归覆盖。

### 课程表 UI

- 将重叠课程表块改为并排渲染，而不是相互覆盖。
- 在“方案”页隐藏顶部栏的“添加课程”操作。
- 在“设置”页隐藏顶部栏的“导入”、“导出”和“添加课程”操作。
- 修复假期调整下拉框在带有长标签的窄屏上溢出的问题。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build appbundle --release`
- `flutter build windows --release`
- `dart run msix:create`

## 1.0.3 - 2026-05-20

### 导入解析

- 将 BIFF `.xls` 启发式逻辑替换为跨平台 OLE/BIFF 工作簿读取器，直接解析工作表单元格。
- 为真实校园课程表条目添加共享课程表文本解析，支持不同周的地点差异。
- 稳定真实 HTML `.xls`、BIFF `.xls` 和 WakeUp `.ics` 示例文件的解析。
- 移除简化表格解析器回退逻辑，并将导入测试重置为聚焦真实样例。

### 课程表数据

- 新用户现在从空课程表开始，而不是内置演示课程。
- 移除导入中心样例加载器和打包的演示 HTML 源。
- 添加仓库层覆盖，用于稳定方案选择、编辑和删除回退逻辑。

### 设置

- 将中文语言选择器中英语的标签改为 `English`。
- 内置 2026 年中国假期和补班日安排，用于离线假期调整。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`

## 1.0.2 - 2026-05-20

### 假期模式

- 添加假期模式设置卡片，包含法定节假日开关和调整模式选择器。
- 在应用启动时从年度 `holiday.ailcc.com` API 获取当年中国假期安排，必要时回退到 `timor.tech`，并在公共来源不可用时使用本地缓存。
- 解析通用年度假期数据，而不是依赖每年单独的应用内表。
- 在假期载荷被解析为可用年度数据后立即缓存。
- 从假期数据源区分法定节假日、调休休息日和补班日。
- 在选定假期日期隐藏课程表课程，而不删除课程记录。
- 将同样的当前周假期过滤应用到课程表图片导出。
- 为假期数据源解析和调整模式隐藏规则添加回归测试。

### 缺陷修复

- 防止重复的学期/方案删除提示和堆叠的删除提示条。
- 将未选中课程表方案徽标从“方案”改为“选择”。
- 添加英语作为手动语言选项，并生成英语本地化资源。

### 导航动画

- 让应用路由显式使用 Material `MaterialPage` 过渡，而不是自定义过渡曲线。
- 将编辑器保存/删除完成后的行为改为优先使用原生出栈动画，再回退到已存储的来源路径。
- 打开冲突处理页时保留精确的导入页来源路径。
- 将二级核心目标改为从其来源入栈，使系统返回手势按动画返回用户来源页面。

## 1.0.1 - 2026-05-19

### 国际化

- 添加 Flutter `gen_l10n` 本地化，包括简体中文（`zh`、`zh_CN`）和繁体中文（`zh_TW`）资源。
- 将 `MaterialApp.router` 接入生成的本地化委托和受支持语言环境。
- 添加语言环境解析，使 `zh_TW`、`zh_HK`、`zh_MO` 和 `zh-Hant` 系统使用繁体中文，其他中文语言环境使用简体中文。
- 本地化主应用外壳和首版 UI 表面：课程表、方案、导入、冲突、编辑器、导出和设置。
- 添加设置页语言选择器，支持系统、简体中文和繁体中文模式。
- 添加繁体中文系统语言环境切换的组件测试覆盖。
- 添加手动语言偏好覆盖系统语言环境的组件测试覆盖。

### 导航和课程表整理

- 将紧凑底部导航和宽屏 NavigationRail 缩减为核心流程：课程表、方案和设置。
- 将导入、课程创建和导出移动到顶部应用栏/标题栏操作。
- 为编辑器、导出、设置和导入冲突子页面添加来源感知返回处理。
- 添加 Android 返回处理，使二级顶层标签返回课程表，而不是在手势中途露出空白/启动器背景。
- 启用 Android 预测返回回调，以及用于可出栈路由的 Android 预测页面过渡。
- 为浅色和深色主题添加明确的 Android 窗口背景色。
- 从应用和开发文档中移除课程表方案比较功能，同时保留导入冲突处理。
- 将首页课程表重建为七天日历网格，使周一到周日无需横向滚动即可适配。
- 将周显示和上一周/下一周控件移动到顶部栏，并移除大型周摘要卡片。
- 为课程表星期表头添加日期标签，并在查看非当前周时添加“回到今天”浮动操作。
- 添加单节课和奇数长度课程块的首屏和 PNG 导出支持。
- 更新 ICS 时间推断，将精确课程时间映射到任意节次范围，而不是只支持两节连排课程块。
- 添加方案和学期编辑/删除流程，包括明确的学期开始日期选择和可选学期结束日期。
- 为持久化学期结束日期添加 Drift migration。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`

### `0039b94` 之后的进展

已实现：

- 将 UI 接入 Drift 支持的课程表仓库，用于种子恢复、活动方案加载、课程保存/删除、导入提交、冲突解决、提醒、ICS 导出和导入历史。
- 添加受控 BIFF `.xls` 适配器，从打包样例中提取课程样记录，而不是只返回警告输出。
- 将导入预览改为与当前活动方案比较，而不是与空课程表比较。
- 持久化导入批次、来源记录、新增课时和待处理差异/冲突记录。
- 将静态冲突页面替换为实时待处理冲突，并添加保留当前、使用导入、两者都保留和手动编辑状态操作。
- 让课程详情打开所选课时的编辑器；保存编辑现在会更新同一课程/课时，编辑器也可以删除课时。
- 通过 `ReminderRules` 持久化提醒启用状态和提前时间，并在设置、导入、编辑和活动方案切换后重建滚动提醒。
- 初始化本地通知，并在支持的平台请求 Android 通知权限。
- 通过保存文件流程接入当前活动方案 ICS 导出和当前周 PNG 导出。
- 将静态导入历史替换为持久化的最近批次。
- 修复课程表表头，使其显示活动学期/方案，并允许一个可见时间单元格内有多个课时。
- 添加可从导入中心编辑活动学期第一周周一的功能。
- 添加学期创建和从方案管理中切换学期的功能。
- 添加全学期 PNG 导出以及当前周 PNG 导出。
- 将 Android 包身份更新为 `app.crid`，将应用标签更新为 `Crid`。
- 添加带项目身份的 MSIX 打包，并验证 MSIX 创建。

完成这些变更后已验证：

- `flutter analyze`
- `flutter test`
- `flutter build windows --debug`
- `flutter build apk --debug`
- `flutter build apk --release`
- `flutter build appbundle --release`
- `dart run msix:create`

剩余约束：

- BIFF `.xls` 支持仍是隔离的启发式适配器，不是完整的 BIFF8 工作表解码器。
- `.xls` 导入使用活动学期的第一周周一；现在可以在导入中心导入前编辑该日期。
- Android 正式版签名仍使用脚手架调试签名配置进行本地质量验证，必须在外部分发前替换。

### `1d2c268` 之后的基线状态

仓库现在包含 Crid 应用的第一个 Flutter 基线。

已实现：

- Android 和 Windows Flutter 项目脚手架。
- 使用 Riverpod 和 `go_router` 的 Material 3 应用外壳。
- 自适应导航：紧凑底部导航和宽屏导航轨道。
- 课程表、方案管理、导入中心、冲突差异、课程编辑器、导出和设置表面。
- 校园课程节次和单双周的核心时间辅助逻辑。
- `.ics`、HTML 表格 `.xls` 和 BIFF `.xls` 的导入类型检测。
- HTML 表格 `.xls`、`.ics` 和隔离 BIFF 回退逻辑的解析器适配器。
- 用于重复项、差异、新增项和时间冲突的内存合并引擎。
- 用于学期、方案、课程、课时、导入批次、来源记录、冲突和提醒规则的 Drift 数据结构定义。
- 使用 `Asia/Shanghai` 的 ICS 导出服务。
- 提醒滚动窗口计算和本地通知适配器边界。
- 围绕 `RepaintBoundary` 的图片导出服务边界。
- 导入逻辑、导出/提醒逻辑和自适应 UI 冒烟覆盖的回归测试。

基线已验证：

- `flutter analyze`
- `flutter test`
- `flutter build windows --debug`
- `flutter build apk --debug`

完成文档中首版范围前仍需收尾的已知缺口：

- BIFF `.xls` 解析仍只产生警告，尚未提取真实课程。
- UI 状态大多仍在内存中；Drift 尚未接入仓库或用户流程。
- 导入暂存预览会解析文件，但尚未持久化批次、来源记录或合并后的课程课时。
- 冲突操作仍是视觉占位。
- 课程编辑器会校验字段，但尚未持久化编辑。
- 多学期和多方案管理只是视觉呈现。
- 活动方案切换尚未由存储支持。
- 双课程表比较尚未在导入差异页面之外实现。
- 提醒初始化、权限和重建触发尚未接入应用生命周期。
- 导出页尚未接入文件保存流程或选定方案。
- Android 包身份、通知权限、Windows MSIX 身份和发布资源仍是默认/脚手架值。
