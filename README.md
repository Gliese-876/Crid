<p align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" alt="课格应用图标" width="96" height="96">
</p>

<h1 align="center">课格 / Crid</h1>

<p align="center">
  <a href="README.md">简体中文</a> |
  <a href="README_zh_Hant.md">繁體中文</a> |
  <a href="README_en.md">English</a>
</p>

课格（Crid）是一个使用 Flutter 开发的跨平台课程表应用。它的目标是成为一个简洁、美观、易用的开源课程表 App。

## 开发动机

当今市面上已经有许多成熟的课程表 App。但是，它们往往是闭源甚至付费的，而免费版本又常常夹着广告。2026 年 5 月的一天，当我终于受不了某课程表 App 令人防不胜防的摇一摇跳转和弹窗广告后，我决定自己动手做一个。于是，在 AI 的帮助下，经过几周开发，课格诞生了。

## 现有功能

- 查看和编辑课表
- 上课提醒
- Windows 原生通知、资源管理器文件关联和桌面宽屏工作区
- 调休自动调整
- 从教务系统导入 `.xls` 格式的课表
- 从教务系统导入 `.mht`、`.mhtml` 和 `.pdf` 格式的考试安排
- 通过直接粘贴文本从教务系统导入考试安排
- 将课表导出为 `.ics` 和 `.png` 格式
- 本地备份和恢复数据与设置
- 多语言支持
- 更多功能仍在开发中

## 如何安装

正式版安装包发布在 [GitHub Releases](https://github.com/Gliese-876/Crid/releases)。最新 Windows 版是 `v1.2.0`；Android 最新安装包仍为 `v1.1.0`。

### Android

下载 `Crid-1.1.0-release-android.apk` 后直接安装即可。如果系统提示不允许安装未知来源应用，请在 Android 设置中为浏览器或文件管理器开启“安装未知应用”权限。

也可以按设备架构下载体积更小的分包：

- `Crid-1.1.0-release-android-arm64.apk`：大多数近年的 Android 手机
- `Crid-1.1.0-release-android-armeabi-v7a.apk`：较老的 32 位 Android 设备
- `Crid-1.1.0-release-android-x86_64.apk`：x86_64 模拟器或少数 x86_64 设备

### Windows

1. 下载 `Crid-1.2.0-windows-x64.zip` 并完整解压。
2. 双击 `Install-Crid.cmd`。
3. 首次安装时同意一次 UAC 弹窗，以便将随包公开证书写入本地计算机的“受信任人”证书存储；安装完成后从开始菜单打开 Crid。

更新时下载并解压新版 ZIP，再次双击 `Install-Crid.cmd` 即可。使用同一签名证书的后续更新通常不再需要 UAC。

如需手动安装，可将 ZIP 内的 `.cer` 导入 `Cert:\LocalMachine\TrustedPeople`，再运行：

```powershell
Add-AppxPackage -Path "C:\path\to\Crid-1.2.0-windows-x64.msix" -ForceApplicationShutdown -ForceUpdateFromAnyVersion
```

如果安装器提示 `0x800B0109`，通常说明证书没有导入到“本地计算机”的受信任人证书存储。

## 技术结构

项目采用 feature-first 结构。主要目录如下：

| 路径 | 作用 |
| --- | --- |
| `lib/app/` | 应用入口、路由、自适应外壳、主题、语言和全局状态 |
| `lib/data/database/` | Drift 数据库、表结构和课程时间模型 |
| `lib/features/timetable/` | 课表首页、方案管理和课表仓库 |
| `lib/features/import/` | 文件识别、课表解析、导入预览和冲突处理 |
| `lib/features/editor/` | 课程新增和编辑 |
| `lib/features/export/` | ICS 和图片导出 |
| `lib/features/reminder/` | 本地课程提醒和滚动提醒窗口 |
| `lib/features/settings/` | 设置页、假期数据、Android 后台设置和 Windows 原生集成 |
| `lib/l10n/` | 简体中文、繁体中文和英文文案 |
| `test/` | 导入、提醒、导出、主题、仓库和界面测试 |

核心依赖：

- Flutter 和 Dart
- Riverpod
- go_router
- Drift 和 SQLite
- file_picker
- flutter_local_notifications
- html、charset、spreadsheet_decoder、mime、syncfusion_flutter_pdf
- icalendar_parser、rrule、timezone
- material_color_utilities

## 已知问题

- 目前主要支持解析北京师范大学珠海校区的课表和考试安排文件
- Windows 安装包使用自签名证书，首次安装需要一次 UAC 确认以建立本机信任
- Windows Toast 是否显示仍受系统通知开关、专注助手和组织策略影响

## 近期计划

- [ ] 支持北京师范大学北京校区的课表文件格式
- [ ] 优化通知系统的稳定性
- [ ] 继续完善 Windows 键盘快捷键、无障碍和自动更新体验
- [ ] 增加小组件（Widgets）支持

## 远期愿景

- [ ] 支持以 BYOK 方式接入 AI 大模型，实现通用课表文件格式解析
- [ ] 开发 iOS 和 macOS 版本

## 开源协议

本项目采用 [Apache License 2.0](LICENSE) 开源。你可以使用、修改、分发本项目代码，也可以在闭源项目中使用；分发时需要保留本项目的许可证、版权声明和 [NOTICE](NOTICE) 中的归属声明。
