<p align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" alt="课格应用图标" width="104" height="104">
</p>

<h1 align="center">课格 / Crid</h1>

<p align="center">一款无广告的开源课程表，课程数据保存在本机，支持 Android 和 Windows。</p>

<p align="center">
  <a href="README.md">简体中文</a> ·
  <a href="README_zh_Hant.md">繁體中文</a> ·
  <a href="README_en.md">English</a>
</p>

<p align="center">
  <a href="https://github.com/Gliese-876/Crid/releases/latest"><img alt="最新版本" src="https://img.shields.io/github/v/release/Gliese-876/Crid"></a>
  <img alt="支持平台：Android 和 Windows" src="https://img.shields.io/badge/platform-Android%20%7C%20Windows-2563eb">
  <a href="LICENSE"><img alt="Apache 2.0 许可证" src="https://img.shields.io/github/license/Gliese-876/Crid"></a>
</p>

课格（Crid）是一款使用 Flutter 开发的课程表应用，可管理课程、考试、学期和多套课表。使用课格无需注册或登录，课程数据保存在本机。用户可在应用内导入、编辑、导出和备份课程数据，也可设置课前提醒。

<p align="center">
  <a href="https://github.com/Gliese-876/Crid/releases/latest"><strong>下载最新版</strong></a> ·
  <a href="CHANGELOG.md">更新日志</a> ·
  <a href="docs/development.md">开发文档</a> ·
  <a href="docs/windows-feature-parity.md">Windows 功能对等表</a>
</p>

## 主要功能

### 课表与课程

- 可创建多个学期和多套课表，随时切换、修改或删除。
- 课程时间精确到分钟，支持连续周、单周和双周。
- 可新增、编辑、隐藏和恢复普通课程或考试。
- “显示非本周课程”默认关闭。启用后，非本周课程将在原位置以灰色显示。
- 节假日与调休期间，可分别将课程和考试设为正常显示、灰色显示或隐藏。

### 导入与冲突处理

| 内容 | 支持的来源 | 处理方式 |
| --- | --- | --- |
| 课程表 | `.ics` | 读取课程、时间、地点、说明和重复规则 |
| 课程表 | BIFF/HTML `.xls` | 读取教务系统导出的二进制表格或网页表格 |
| 考试安排 | `.mht`、`.mhtml`、`.pdf`、`.txt` | 读取考试场次、时间、地点、座位和备注 |
| 考试安排 | 剪贴板文字 | 直接粘贴从教务系统页面复制的考试信息 |

文件导入前会显示预览内容。用户确认后，课格会自动去重并合并数据。遇到冲突时，用户自行选择处理方式。课格不会直接覆盖现有课表。

### 提醒、导出与数据

- 课前提醒可设置多个预设时间，也可自定义提前分钟数。提醒支持静音和“忽略免打扰”选项。
- Android 通过系统通知和闹钟安排提醒。Windows 将提醒交由系统定时发送。关闭课格不会取消已经安排的提醒。
- 可导出标准 `.ics`、当前周课表 PNG 图片或全学期课表 PNG 图片。
- 图片导出另有“显示非本周课程”选项，不影响课表页面的设置。
- 可在本机备份和恢复课程数据与设置。
- 提供简体中文、繁体中文和英文界面。

### Windows 原生适配

- Windows 大屏界面设有宽屏课表、可折叠侧栏和常驻工具栏。导入、导出和设置页面采用多栏布局。
- 文件选择、保存和打开均调用 Windows 系统功能，通知设置可从课格直接打开。
- 安装后可在资源管理器中双击 `.ics`、`.xls`、`.mht`、`.mhtml`、`.pdf` 或 `.txt`，直接进入导入预览。
- 程序窗口、安装包、开始菜单和 Toast 通知均使用课格图标。

## 平台支持

| 平台 | 状态 | 下载内容 |
| --- | --- | --- |
| Android | 已发布 | 通用 APK，另有 arm64-v8a、armeabi-v7a、x86_64 架构专用安装包 |
| Windows 10/11 x64 | 已发布 | ZIP 内含已签名 MSIX、一键安装脚本和签名证书（不含私钥） |
| iOS / macOS | 未发布 | 已列入路线图 |
| Linux | 未发布 | 暂无发布计划 |

最新版本为 `v1.2.0`，可从 [GitHub Releases](https://github.com/Gliese-876/Crid/releases/latest) 下载。

## 安装与更新

### Android

无法确定设备的处理器架构时，建议下载 `Crid-1.2.0-release-android.apk`。通用安装包支持 arm64-v8a、armeabi-v7a 和 x86_64。

如需体积较小的安装包，可按处理器架构选择：

| 文件 | 适用设备 |
| --- | --- |
| `Crid-1.2.0-release-android-arm64.apk` | 大多数近年的 Android 手机和平板 |
| `Crid-1.2.0-release-android-armeabi-v7a.apk` | 较老的 32 位 Android 设备 |
| `Crid-1.2.0-release-android-x86_64.apk` | x86_64 模拟器或少数 x86_64 设备 |

下载后安装 APK。若系统阻止安装，请为浏览器或文件管理器授予“安装未知应用”权限。安装新版 APK 不会清除原有数据。

### Windows

1. 下载 `Crid-1.2.0-windows-x64.zip`，将全部文件解压到本机文件夹。
2. 双击 `Install-Crid.cmd`。
3. 首次安装时，系统会显示一次 UAC 确认窗口。脚本会将压缩包内的签名证书（不含私钥）加入本地计算机的“受信任的人”证书存储，验证签名后安装 MSIX。
4. 从开始菜单启动 Crid。

更新时下载新版 ZIP，解压后重新运行 `Install-Crid.cmd`。签名证书未变更时，通常不会再次出现 UAC 提示。

<details>
<summary>Windows 手动安装与故障排查</summary>

先将 ZIP 内的 `.cer` 导入 `Cert:\LocalMachine\TrustedPeople`，再运行：

```powershell
Add-AppxPackage -Path "C:\path\to\Crid-1.2.0-windows-x64.msix" -ForceApplicationShutdown -ForceUpdateFromAnyVersion
```

错误 `0x800B0109` 通常表示证书未导入本地计算机的“受信任的人”证书存储。Windows 通知能否送达取决于系统通知开关、专注助手和组织策略。

</details>

### 校验下载

发布页面提供 `SHA256SUMS.txt`，列出所有 APK 和 Windows ZIP 的 SHA-256。可以在 PowerShell 中运行：

```powershell
Get-FileHash .\Crid-1.2.0-release-android.apk -Algorithm SHA256
```

将命令输出与 `SHA256SUMS.txt` 中对应文件的值比较。

## 快速开始

1. 新建学期并确认第一周的星期一。教务系统导出的 `.xls` 通常不含实际日期，导入前需要设置该日期。
2. 手动新建课表，或导入课程表和考试安排文件。
3. 在导入预览中检查新增、重复、改动和冲突，确认后写入课表。
4. 在“设置 → 显示”中选择是否用灰色显示非本周课程。
5. 按需启用课前提醒，设置提前时间、声音和免打扰选项。
6. 在导出页生成 ICS、周课表图片或全学期图片。在设置页备份数据。

## 支持的导入文件

教务系统文件解析目前主要使用北京师范大学珠海校区的实际导出文件测试。ICS 的适用范围较广。其他学校的 `.xls`、MHTML 或 PDF 排版不同，可能暂时无法识别。提交此类问题前，请删除文件中的姓名、学号、座位等个人信息，并附上样例和问题说明。

## 开发

### 准备环境

- Flutter stable 和随附的 Dart SDK。
- Android Studio、Android SDK、模拟器或实体设备。
- Windows 10/11、Visual Studio（安装“使用 C++ 的桌面开发”工作负载）。

### 下载代码并运行

```powershell
git clone https://github.com/Gliese-876/Crid.git
cd Crid
flutter pub get
flutter gen-l10n
flutter run -d windows
```

运行 Android 版时，将最后一行改为 `flutter run -d <device-id>`。设备编号可通过 `flutter devices` 查看。

### 检查代码并构建

```powershell
flutter analyze
flutter test
flutter build apk --release
flutter build windows --release
```

签名、打包和发布步骤见 [开发文档](docs/development.md)。私钥、密钥库、证书密码和 Windows PFX 不得提交至仓库，也不得包含在公开发布包中。

### 项目结构

| 路径 | 职责 |
| --- | --- |
| `lib/app/` | 应用入口、路由、自适应界面、主题和语言 |
| `lib/data/database/` | Drift 数据库、迁移与课程时间模型 |
| `lib/features/timetable/` | 课表首页、学期、方案和数据读写 |
| `lib/features/import/` | 文件识别、解析、导入预览、合并和冲突处理 |
| `lib/features/editor/` | 课程和考试编辑 |
| `lib/features/reminder/` | 提醒规则和各平台的通知调度 |
| `lib/features/export/` | ICS 与图片导出 |
| `lib/features/settings/` | 设置、假期、备份和系统原生功能 |
| `lib/l10n/` | 简体中文、繁体中文和英文资源 |
| `test/` | 解析、数据库、提醒、导出和界面回归测试 |

项目使用 Flutter、Material 3、Riverpod、go_router、Drift/SQLite、file_picker 和 flutter_local_notifications。数据模型、导入流程和平台实现见 [开发文档](docs/development.md)。

## 文档

- [中文更新日志](CHANGELOG.md)
- [English changelog](CHANGELOG_EN.md)
- [开发与发布文档](docs/development.md)
- [Android 到 Windows 功能对等表](docs/windows-feature-parity.md)

## 当前限制

- 教务系统文件目前主要支持北京师范大学珠海校区的格式。其他学校或改版后的页面可能无法正确识别。
- 目前只发布 Android 和 Windows x64 版本，暂不支持 iOS、macOS 和 Linux。
- Windows 安装包使用自签名证书。首次安装时，安装脚本需要一次 UAC 授权，才能将证书加入信任列表。Windows 系统设置可能影响通知送达。
- 课格尚未提供自动更新功能。新版本需要从 GitHub Releases 下载并安装。

## 路线图

- 适配北京师范大学北京校区和更多学校的课表文件。
- 提高通知稳定性，完善 Windows 键盘操作、无障碍支持和更新方式。
- 开发桌面版和移动版小组件，逐步支持 iOS 和 macOS。
- 研究在用户自行提供密钥（BYOK）的前提下调用 AI 模型，用于解析尚未适配的课表格式。

## 参与开发

欢迎提交 [Issue](https://github.com/Gliese-876/Crid/issues) 或 Pull Request。报告导入问题前，请删除姓名、学号、课程成员、座位等个人信息。报告 Android 或 Windows 问题时，请写明系统版本和复现步骤。

## 项目理念

课格专注于课程管理，不含广告。摇动设备不会触发页面跳转。用户可以导出和备份课程数据。项目公开全部源代码，任何人均可查看、修改和自行构建。移动版和桌面版分别遵循相应平台的操作习惯。

## 开源协议

本项目采用 [Apache License 2.0](LICENSE)。使用、修改或分发本项目时，请保留许可证、版权声明和 [NOTICE](NOTICE) 中的署名信息。
