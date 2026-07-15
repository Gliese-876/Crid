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
- Windows 原生通知、檔案總管檔案關聯和桌面寬螢幕工作區
- 調休自動調整
- 從教務系統匯入 `.xls` 格式的課表
- 從教務系統匯入 `.mht`、`.mhtml` 和 `.pdf` 格式的考試安排
- 透過直接貼上文字從教務系統匯入考試安排
- 將課表匯出為 `.ics` 和 `.png` 格式
- 本機備份和還原資料與設定
- 多語言支援
- 更多功能仍在開發中

## 如何安裝

正式版安裝包發布在 [GitHub Releases](https://github.com/Gliese-876/Crid/releases)。最新 Windows 版是 `v1.2.0`；Android 最新安裝包仍為 `v1.1.0`。

### Android

下載 `Crid-1.1.0-release-android.apk` 後直接安裝即可。如果系統提示不允許安裝未知來源應用，請在 Android 設定中為瀏覽器或檔案管理器開啟「安裝未知應用」權限。

也可以按裝置架構下載體積更小的分包：

- `Crid-1.1.0-release-android-arm64.apk`：大多數近年的 Android 手機
- `Crid-1.1.0-release-android-armeabi-v7a.apk`：較舊的 32 位 Android 裝置
- `Crid-1.1.0-release-android-x86_64.apk`：x86_64 模擬器或少數 x86_64 裝置

### Windows

1. 下載 `Crid-1.2.0-windows-x64.zip` 並完整解壓縮。
2. 按兩下 `Install-Crid.cmd`。
3. 首次安裝時同意一次 UAC 視窗，讓安裝器將隨附公開憑證寫入本機電腦的「受信任的人」憑證存放區；完成後從開始功能表開啟 Crid。

更新時下載並解壓縮新版 ZIP，再次執行 `Install-Crid.cmd` 即可。使用相同簽章憑證的後續更新通常不再需要 UAC。

如需手動安裝，可將 ZIP 內的 `.cer` 匯入 `Cert:\LocalMachine\TrustedPeople`，再執行：

```powershell
Add-AppxPackage -Path "C:\path\to\Crid-1.2.0-windows-x64.msix" -ForceApplicationShutdown -ForceUpdateFromAnyVersion
```

若安裝器顯示 `0x800B0109`，通常表示憑證沒有匯入本機電腦的受信任的人憑證存放區。

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
| `lib/features/settings/` | 設定頁、假期資料、Android 背景設定和 Windows 原生整合 |
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
- Windows 安裝包使用自簽名憑證，首次安裝需要一次 UAC 確認以建立本機信任
- Windows Toast 是否顯示仍受系統通知設定、專注輔助和組織原則影響

## 近期計畫

- [ ] 支援北京師範大學北京校區的課表檔案格式
- [ ] 優化通知系統的穩定性
- [ ] 繼續完善 Windows 鍵盤快速鍵、無障礙和更新體驗
- [ ] 增加小工具（Widgets）支援

## 遠期願景

- [ ] 支援以 BYOK 方式接入 AI 大模型，實現通用課表檔案格式解析
- [ ] 開發 iOS 和 macOS 版本

## 開源授權

本專案採用 [Apache License 2.0](LICENSE) 開源。你可以使用、修改、散布本專案程式碼，也可以在閉源專案中使用；散布時需要保留本專案的授權條款、著作權聲明和 [NOTICE](NOTICE) 中的歸屬聲明。
