<p align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" alt="課格應用程式圖示" width="104" height="104">
</p>

<h1 align="center">課格 / Crid</h1>

<p align="center">一款無廣告的開源課表，課程資料保存在本機，支援 Android 和 Windows。</p>

<p align="center">
  <a href="README.md">簡體中文</a> ·
  <a href="README_zh_Hant.md">繁體中文</a> ·
  <a href="README_en.md">English</a>
</p>

<p align="center">
  <a href="https://github.com/Gliese-876/Crid/releases/latest"><img alt="最新版本" src="https://img.shields.io/github/v/release/Gliese-876/Crid"></a>
  <img alt="支援平台：Android 和 Windows" src="https://img.shields.io/badge/platform-Android%20%7C%20Windows-2563eb">
  <a href="LICENSE"><img alt="Apache 2.0 授權條款" src="https://img.shields.io/github/license/Gliese-876/Crid"></a>
</p>

課格（Crid）是一款使用 Flutter 開發的課表應用程式，可管理課程、考試、學期和多套課表。使用課格無需註冊或登入，課程資料保存在本機。使用者可在應用程式內匯入、編輯、匯出和備份課程資料，也可設定課前提醒。

<p align="center">
  <a href="https://github.com/Gliese-876/Crid/releases/latest"><strong>下載最新版本</strong></a> ·
  <a href="CHANGELOG.md">更新日誌</a> ·
  <a href="docs/development.md">開發文件</a> ·
  <a href="docs/windows-feature-parity.md">Windows 功能對等表</a>
</p>

## 主要功能

### 課表與課程

- 可建立多個學期和多套課表，隨時切換、修改或刪除。
- 課程時間精確到分鐘，支援連續週次、單週和雙週。
- 可新增、編輯、隱藏和還原一般課程或考試。
- 「顯示非本週課程」預設關閉。啟用後，非本週課程將在原位置以灰色顯示。
- 節假日與補班期間，可分別將課程和考試設為正常顯示、灰色顯示或隱藏。

### 匯入與衝突處理

| 內容 | 支援的來源 | 處理方式 |
| --- | --- | --- |
| 課表 | `.ics` | 讀取課程、時間、地點、說明和重複規則 |
| 課表 | BIFF/HTML `.xls` | 讀取教務系統匯出的二進位表格或網頁表格 |
| 考試安排 | `.mht`、`.mhtml`、`.pdf`、`.txt` | 讀取考試場次、時間、地點、座位和備註 |
| 考試安排 | 剪貼簿文字 | 直接貼上從教務系統頁面複製的考試資訊 |

檔案匯入前會顯示預覽內容。使用者確認後，課格會自動去除重複項目並合併資料。遇到衝突時，使用者自行選擇處理方式。課格不會直接覆寫現有課表。

### 提醒、匯出與資料

- 課前提醒可設定多個預設時間，也可自訂提前分鐘數。提醒支援靜音和「忽略勿擾模式」選項。
- Android 透過系統通知和鬧鐘安排提醒。Windows 將提醒交由系統依排程傳送。關閉課格不會取消已排定的提醒。
- 可匯出標準 `.ics`、本週課表 PNG 圖片或全學期課表 PNG 圖片。
- 圖片匯出另有「顯示非本週課程」選項，不影響課表頁面的設定。
- 可在本機備份和還原課程資料與設定。
- 提供簡體中文、繁體中文和英文介面。

### Windows 原生適配

- Windows 大螢幕介面設有寬螢幕課表、可摺疊側邊欄和常駐工具列。匯入、匯出和設定頁面採用多欄版面。
- 檔案選擇、儲存和開啟均使用 Windows 系統功能，通知設定可從課格直接開啟。
- 安裝後可在檔案總管中按兩下 `.ics`、`.xls`、`.mht`、`.mhtml`、`.pdf` 或 `.txt`，直接進入匯入預覽。
- 程式視窗、安裝套件、開始功能表和 Toast 通知均使用課格圖示。

## 平台支援

| 平台 | 狀態 | 下載內容 |
| --- | --- | --- |
| Android | 已發布 | 通用 APK，另有 arm64-v8a、armeabi-v7a、x86_64 架構專用安裝套件 |
| Windows 10/11 x64 | 已發布 | ZIP 內含已簽章 MSIX、一鍵安裝指令碼和簽章憑證（不含私密金鑰） |
| iOS / macOS | 未發布 | 已列入路線圖 |
| Linux | 未發布 | 暫無發布計畫 |

最新版本為 `v1.2.0`，可從 [GitHub Releases](https://github.com/Gliese-876/Crid/releases/latest) 下載。

## 安裝與更新

### Android

無法確認裝置的處理器架構時，建議下載 `Crid-1.2.0-release-android.apk`。通用安裝套件支援 arm64-v8a、armeabi-v7a 和 x86_64。

如需容量較小的安裝套件，可依處理器架構選擇：

| 檔案 | 適用裝置 |
| --- | --- |
| `Crid-1.2.0-release-android-arm64.apk` | 大多數近年的 Android 手機和平板電腦 |
| `Crid-1.2.0-release-android-armeabi-v7a.apk` | 較舊的 32 位元 Android 裝置 |
| `Crid-1.2.0-release-android-x86_64.apk` | x86_64 模擬器或少數 x86_64 裝置 |

下載後安裝 APK。若系統阻止安裝，請在系統設定中允許瀏覽器或檔案管理員安裝不明應用程式。安裝新版 APK 不會清除原有資料。

### Windows

1. 下載 `Crid-1.2.0-windows-x64.zip`，將全部檔案解壓縮到本機資料夾。
2. 按兩下 `Install-Crid.cmd`。
3. 首次安裝時，系統會顯示一次 UAC 確認視窗。指令碼會將壓縮檔內的簽章憑證（不含私密金鑰）加入本機電腦的「受信任的人」憑證存放區，驗證簽章後安裝 MSIX。
4. 從開始功能表啟動 Crid。

更新時下載新版 ZIP，解壓縮後重新執行 `Install-Crid.cmd`。簽章憑證未變更時，通常不會再次出現 UAC 提示。

<details>
<summary>Windows 手動安裝與疑難排解</summary>

先將 ZIP 內的 `.cer` 匯入 `Cert:\LocalMachine\TrustedPeople`，再執行：

```powershell
Add-AppxPackage -Path "C:\path\to\Crid-1.2.0-windows-x64.msix" -ForceApplicationShutdown -ForceUpdateFromAnyVersion
```

錯誤 `0x800B0109` 通常表示憑證未匯入本機電腦的「受信任的人」憑證存放區。Windows 通知能否送達取決於系統通知設定、專注輔助和組織原則。

</details>

### 驗證下載

發布頁面提供 `SHA256SUMS.txt`，列出所有 APK 和 Windows ZIP 的 SHA-256。可在 PowerShell 中執行：

```powershell
Get-FileHash .\Crid-1.2.0-release-android.apk -Algorithm SHA256
```

將命令輸出與 `SHA256SUMS.txt` 中對應檔案的值比較。

## 快速開始

1. 建立學期並確認第一週的星期一。教務系統匯出的 `.xls` 通常不含實際日期，匯入前需要設定該日期。
2. 手動建立課表，或匯入課表和考試安排檔案。
3. 在匯入預覽中檢查新增、重複、變更和衝突，確認後寫入課表。
4. 在「設定 → 顯示」中選擇是否以灰色顯示非本週課程。
5. 視需要啟用課前提醒，設定提前時間、聲音和勿擾選項。
6. 在匯出頁面產生 ICS、週課表圖片或完整學期圖片。在設定頁面備份資料。

## 支援的匯入檔案

教務系統檔案解析目前主要使用北京師範大學珠海校區的實際匯出檔案測試。ICS 的適用範圍較廣。其他學校的 `.xls`、MHTML 或 PDF 版面不同，可能暫時無法識別。回報此類問題前，請刪除檔案中的姓名、學號、座位等個人資料，並附上樣本和問題說明。

## 開發

### 準備環境

- Flutter stable 和隨附的 Dart SDK。
- Android Studio、Android SDK、模擬器或實體裝置。
- Windows 10/11、Visual Studio（安裝「使用 C++ 的桌面開發」工作負載）。

### 下載程式碼並執行

```powershell
git clone https://github.com/Gliese-876/Crid.git
cd Crid
flutter pub get
flutter gen-l10n
flutter run -d windows
```

執行 Android 版時，將最後一行改為 `flutter run -d <device-id>`。裝置編號可透過 `flutter devices` 查看。

### 檢查程式碼並建置

```powershell
flutter analyze
flutter test
flutter build apk --release
flutter build windows --release
```

簽章、打包和發布步驟見 [開發文件](docs/development.md)。私密金鑰、金鑰庫、憑證密碼和 Windows PFX 不得提交至程式碼儲存庫，也不得包含在公開發布套件中。

### 專案結構

| 路徑 | 職責 |
| --- | --- |
| `lib/app/` | 應用程式入口、路由、自適應介面、主題和語言 |
| `lib/data/database/` | Drift 資料庫、遷移與課程時間模型 |
| `lib/features/timetable/` | 課表首頁、學期、方案和資料存取 |
| `lib/features/import/` | 檔案識別、解析、匯入預覽、合併和衝突處理 |
| `lib/features/editor/` | 課程和考試編輯 |
| `lib/features/reminder/` | 提醒規則和各平台的通知排程 |
| `lib/features/export/` | ICS 與圖片匯出 |
| `lib/features/settings/` | 設定、假期、備份和系統原生功能 |
| `lib/l10n/` | 簡體中文、繁體中文和英文資源 |
| `test/` | 解析、資料庫、提醒、匯出和介面回歸測試 |

專案使用 Flutter、Material 3、Riverpod、go_router、Drift/SQLite、file_picker 和 flutter_local_notifications。資料模型、匯入流程和平台實作見 [開發文件](docs/development.md)。

## 文件

- [中文更新日誌](CHANGELOG.md)
- [English changelog](CHANGELOG_EN.md)
- [開發與發布文件](docs/development.md)
- [Android 到 Windows 功能對等表](docs/windows-feature-parity.md)

## 目前限制

- 教務系統檔案目前主要支援北京師範大學珠海校區的格式。其他學校或改版後的頁面可能無法正確識別。
- 目前僅發布 Android 和 Windows x64 版本，暫不支援 iOS、macOS 和 Linux。
- Windows 安裝套件使用自簽章憑證。首次安裝時，安裝指令碼需要一次 UAC 授權，才能將憑證加入信任清單。Windows 系統設定可能影響通知送達。
- 課格尚未提供自動更新功能。新版本需要從 GitHub Releases 下載並安裝。

## 路線圖

- 支援北京師範大學北京校區和更多學校的課表檔案。
- 提升通知穩定性，改善 Windows 鍵盤操作、無障礙支援和更新方式。
- 開發桌面版和行動版小工具，逐步支援 iOS 和 macOS。
- 研究在使用者自行提供金鑰（BYOK）的前提下呼叫 AI 模型，用於解析尚未支援的課表格式。

## 參與開發

歡迎提交 [Issue](https://github.com/Gliese-876/Crid/issues) 或 Pull Request。提交匯入問題前，請刪除姓名、學號、課程成員、座位等個人資訊。回報 Android 或 Windows 問題時，請註明系統版本和重現步驟。

## 專案理念

課格專注於課程管理，不含廣告。搖動裝置不會開啟其他頁面。使用者可以匯出和備份課程資料。專案公開全部原始碼，任何人均可查看、修改和自行建置。行動版和桌面版各自遵循所屬平台的操作習慣。

## 開源授權

本專案採用 [Apache License 2.0](LICENSE)。使用、修改或散布本專案時，請保留授權條款、著作權聲明和 [NOTICE](NOTICE) 中的署名資訊。
