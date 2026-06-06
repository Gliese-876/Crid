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
- 调休自动调整
- 从教务系统导入 `.xls` 格式的课表
- 从教务系统导入 `.mht`、`.mhtml` 和 `.pdf` 格式的考试安排
- 通过直接粘贴文本从教务系统导入考试安排
- 将课表导出为 `.ics` 和 `.png` 格式
- 本地备份和恢复数据与设置
- 多语言支持
- 更多功能仍在开发中

## 如何安装

正式版安装包发布在 [GitHub Releases](https://github.com/Gliese-876/Crid/releases)。目前最新正式版是 `v1.1.0-release`。

### Android

下载 `Crid-1.1.0-release-android.apk` 后直接安装即可。如果系统提示不允许安装未知来源应用，请在 Android 设置中为浏览器或文件管理器开启“安装未知应用”权限。

也可以按设备架构下载体积更小的分包：

- `Crid-1.1.0-release-android-arm64.apk`：大多数近年的 Android 手机
- `Crid-1.1.0-release-android-armeabi-v7a.apk`：较老的 32 位 Android 设备
- `Crid-1.1.0-release-android-x86_64.apk`：x86_64 模拟器或少数 x86_64 设备

### Windows

下载这两个文件：

- `Crid-1.1.0-release-windows.msix`
- `Crid-1.1.0-release-windows.cer`

由于当前 Windows 安装包使用自签名证书，安装前需要先信任随包提供的证书。建议使用管理员 PowerShell 执行：

```powershell
$certPath = "C:\path\to\Crid-1.1.0-release-windows.cer"

Import-Certificate -FilePath $certPath -CertStoreLocation Cert:\LocalMachine\TrustedPeople
Import-Certificate -FilePath $certPath -CertStoreLocation Cert:\LocalMachine\Root
```

然后双击 `.msix` 安装，或继续在管理员 PowerShell 中执行：

```powershell
Add-AppxPackage -Path "C:\path\to\Crid-1.1.0-release-windows.msix"
```

如果安装器提示 `0x800B0109`，通常说明证书只导入到了“当前用户”，没有导入到“本地计算机”的受信任证书存储。

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
| `lib/features/settings/` | 设置页、假期数据、Android 后台设置 |
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
- 通知系统可能不稳定
- Windows 端尚不成熟，与 Android 端界面、功能差距较大

## 近期计划

- [ ] 支持北京师范大学北京校区的课表文件格式
- [ ] 优化通知系统的稳定性
- [ ] 改进 Windows 端的界面和功能，使其与 Android 端更加一致
- [ ] 增加小组件（Widgets）支持

## 远期愿景

- [ ] 支持以 BYOK 方式接入 AI 大模型，实现通用课表文件格式解析
- [ ] 开发 iOS 和 macOS 版本

## 开源协议

本项目采用 [Apache License 2.0](LICENSE) 开源。你可以使用、修改、分发本项目代码，也可以在闭源项目中使用；分发时需要保留本项目的许可证、版权声明和 [NOTICE](NOTICE) 中的归属声明。
