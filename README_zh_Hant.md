<p align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" alt="課格應用圖示" width="96" height="96">
</p>

<h1 align="center">課格 / Crid</h1>

<p align="center">
  <a href="README.md">簡體中文</a> |
  <a href="README_zh_Hant.md">繁體中文</a> |
  <a href="README_en.md">English</a>
</p>

課格（Crid）是一個使用 Flutter 開發的跨平台課表應用。它的目標是成為一個簡潔、美觀、易用的開源課表 App。

## 開發動機

當今市面上已經有許多成熟的課表 App。不過，它們往往是閉源甚至付費的，而免費版本又常常夾著廣告。2026 年 5 月的一天，當我終於受不了某課表 App 令人防不勝防的搖一搖跳轉和彈窗廣告後，我決定自己動手做一個。於是，在 AI 的幫助下，經過幾週開發，課格誕生了。

## 現有功能

- 查看和編輯課表
- 上課提醒
- 調休自動調整
- 從教務系統匯入 `.xls` 格式的課表
- 從教務系統匯入 `.mht`、`.mhtml` 和 `.pdf` 格式的考試安排
- 透過直接貼上文字從教務系統匯入考試安排
- 將課表匯出為 `.ics` 和 `.png` 格式
- 本機備份和還原資料與設定
- 多語言支援
- 更多功能仍在開發中

## 如何安裝

正式版安裝包發布在 [GitHub Releases](https://github.com/Gliese-876/Crid/releases)。目前最新正式版是 `v1.1.0-release`。

### Android

下載 `Crid-1.1.0-release-android.apk` 後直接安裝即可。如果系統提示不允許安裝未知來源應用，請在 Android 設定中為瀏覽器或檔案管理器開啟「安裝未知應用」權限。

也可以按裝置架構下載體積更小的分包：

- `Crid-1.1.0-release-android-arm64.apk`：大多數近年的 Android 手機
- `Crid-1.1.0-release-android-armeabi-v7a.apk`：較舊的 32 位 Android 裝置
- `Crid-1.1.0-release-android-x86_64.apk`：x86_64 模擬器或少數 x86_64 裝置

### Windows

下載這兩個檔案：

- `Crid-1.1.0-release-windows.msix`
- `Crid-1.1.0-release-windows.cer`

由於目前 Windows 安裝包使用自簽名憑證，安裝前需要先信任隨包提供的憑證。建議使用系統管理員 PowerShell 執行：

```powershell
$certPath = "C:\path\to\Crid-1.1.0-release-windows.cer"

Import-Certificate -FilePath $certPath -CertStoreLocation Cert:\LocalMachine\TrustedPeople
Import-Certificate -FilePath $certPath -CertStoreLocation Cert:\LocalMachine\Root
```

然後雙擊 `.msix` 安裝，或繼續在系統管理員 PowerShell 中執行：

```powershell
Add-AppxPackage -Path "C:\path\to\Crid-1.1.0-release-windows.msix"
```

如果安裝器提示 `0x800B0109`，通常代表憑證只匯入到了「目前使用者」，沒有匯入到「本機電腦」的受信任憑證儲存區。

## 技術結構

專案採用 feature-first 結構。主要目錄如下：

| 路徑 | 作用 |
| --- | --- |
| `lib/app/` | 應用入口、路由、自適應外殼、主題、語言和全域狀態 |
| `lib/data/database/` | Drift 資料庫、表結構和課程時間模型 |
| `lib/features/timetable/` | 課表首頁、方案管理和課表倉庫 |
| `lib/features/import/` | 檔案識別、課表解析、匯入預覽和衝突處理 |
| `lib/features/editor/` | 課程新增和編輯 |
| `lib/features/export/` | ICS 和圖片匯出 |
| `lib/features/reminder/` | 本機課程提醒和滾動提醒窗口 |
| `lib/features/settings/` | 設定頁、假期資料、Android 背景設定 |
| `lib/l10n/` | 簡體中文、繁體中文和英文文案 |
| `test/` | 匯入、提醒、匯出、主題、倉庫和介面測試 |

核心依賴：

- Flutter 和 Dart
- Riverpod
- go_router
- Drift 和 SQLite
- file_picker
- flutter_local_notifications
- html、charset、spreadsheet_decoder、mime、syncfusion_flutter_pdf
- icalendar_parser、rrule、timezone
- material_color_utilities

## 已知問題

- 目前主要支援解析北京師範大學珠海校區的課表和考試安排檔案
- 通知系統可能不穩定
- Windows 端尚不成熟，與 Android 端介面、功能差距較大

## 近期計畫

- [ ] 支援北京師範大學北京校區的課表檔案格式
- [ ] 優化通知系統的穩定性
- [ ] 改進 Windows 端的介面和功能，使其與 Android 端更加一致
- [ ] 增加小工具（Widgets）支援

## 遠期願景

- [ ] 支援以 BYOK 方式接入 AI 大模型，實現通用課表檔案格式解析
- [ ] 開發 iOS 和 macOS 版本

## 開源授權

本專案採用 [Apache License 2.0](LICENSE) 開源。你可以使用、修改、散布本專案程式碼，也可以在閉源專案中使用；散布時需要保留本專案的授權條款、著作權聲明和 [NOTICE](NOTICE) 中的歸屬聲明。
