# Miru Alpha

[![Dev Build CI](https://github.com/miru-project/miru-alpha/actions/workflows/prbuild.yml/badge.svg)](https://github.com/miru-project/miru-alpha/actions/workflows/prbuild.yml)
[![Latest alpha pre-release](https://img.shields.io/github/v/release/miru-project/miru-alpha?include_prereleases&sort=semver)](https://github.com/miru-project/miru-alpha/releases)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](#許可證)
![Status: alpha](https://img.shields.io/badge/status-alpha-orange)

[English](README.md) · [简体中文](README.zh-Hans.md) · **繁體中文**

[miru_app](https://github.com/miru-project/miru-app) 的現代化重寫版本。

Miru 是一款多媒體客戶端，面向三類內容——**影片、漫畫和小說**。它本身不內建任何
插件，也沒有自帶片源：你觀看或閱讀的每一個項目，都由你安裝的擴充功能來解析。
擴充功能就是普通的 JavaScript 或 Go 檔案，任何人都能撰寫並託管。裝好一個來源，
搜尋它，同一個應用就能播放、閱讀和下載。

支援 Android、Linux 和 Windows。

## 取得軟體

預先編譯的 alpha 版本發佈在
[Releases 頁面](https://github.com/miru-project/miru-alpha/releases)。那裡的
每一個發佈標籤都標記為 **pre-release**，並附帶同一套產物：

| 平台 | 產物 |
| --- | --- |
| Android | `app-arm64-v8a-release.apk`、`app-armeabi-v7a-release.apk`、`app-x86_64-release.apk` |
| Linux | `Miru-Alpha-linux.tar.gz` |
| Windows | `Miru-Alpha-windows.zip` |

每次推送還會上傳編譯開發版，見
[Actions artifacts](https://github.com/miru-project/miru-alpha/actions)。
變更記錄見 [CHANGELOG.md](CHANGELOG.md)。

---

## 功能

### 觀看

- **影片播放器** —— HLS 與直接連結影片，支援清晰度切換、外掛字幕，以及八段
  0.25×–3× 倍速。
- **觸控與鍵盤操作** —— 雙擊快轉/快退 ±10 秒，右邊緣上下拖動調音量、
  左邊緣拖動調進度，方向鍵快轉快退，空白鍵暫停，全螢幕與螢幕恆亮鎖定。
- **支援種子** —— 當來源回傳磁力連結或 `.torrent` 時，應用會解析出檔案清單，
  一邊下載一邊播放影片檔案。

### 閱讀

- **漫畫閱讀器** —— 支援左右頁、右左頁與連續捲動（webtoon）三種模式，可逐頁
  調整亮度、色彩反轉、頁間距、適配方式，並提供縮放、跳章和書籤。
- **小說閱讀器** —— 支援分頁、連續與雙欄三種版型，四款閱讀主題，可調整字型、
  字級、行高與頁邊距，並可用點擊區域或音量鍵翻頁。

### 擴充來源

- **三類媒體共用一套擴充功能契約** —— 影片來源、漫畫來源和小說來源是同一種物件，
  因此只需要一套安裝模型。
- **三種擴充功能執行環境** —— 新版 v2 JavaScript、舊版 v1 JavaScript（原版
  `miru-app` 儲存庫無需修改即可使用）以及 Go。
- **插件商店** —— 新增插件網址，瀏覽其中發佈的擴充功能，並進行安裝、更新或
  移除；也可以依網址或從本機檔案匯入單一擴充功能。
- **由插件定義的篩選器** —— 來源自行宣告下拉選單、多選、區間和文字四種變數；
  編輯會先暫存，關閉對話框時一次提交，因此一次查詢只會產生一次請求。
- **每個擴充功能獨立設定** —— 來源可以註冊自己的輸入框、開關和單選選項並持久化
  儲存，可以清除自己的 Cookie，當某個來源需要真實登入時還能在內建 WebView 中
  開啟其網站。
- **內建原始碼編輯器** —— 開啟任一已安裝擴充功能的原始碼，含語法強調，並可直接
  把修改儲存回本地，無需離開 app。

### 搜尋

- **廣域搜尋** —— 一次查詢涵蓋已置頂、未置頂或全部來源，可依相關度、最新更新
  或來源優先順序排序，並列出每個來源的失敗項目且可重試。
- **頁內清晰度與鏡像** —— 某一集解析出多個碼率時會彈出清晰度選擇器而不是替你猜；
  根據來源發佈了鏡像時，可以直接在播放器中切換。

### 管理

- **下載** —— 佇列支援逐項工作優先順序、暫停與繼續、並行上限，並會把 HLS 串流
  自動合併為單一 MP4。
- **重啟不遺失進度** —— 排隊中與被中斷的工作，在重啟後會依據本地上實際存在的
  檔案重建。
- **續播** ——「繼續觀看」書架與觀看紀錄在擴充功能重排或重新編號集數後仍然正確：
  優先比對已儲存的網址，找不到的集數會回報為已失效，而不是續播到錯誤的那一集。
- **分組收藏** —— 把條目標註到標籤下，並可用 AND 或 OR 規則同時比對多個標籤。
- **離線播放** —— 三類媒體的已完成下載都能直接從下載頁開啟。

### 投放

- **DLNA 投放（實驗性）** —— 發現區域網路內的渲染裝置，把目前的串流投放上去，
  並讓播放/暫停/進度在兩端保持同步（用電視遙控器操作也會同步回應用的位置），
  字幕會被燒錄進畫面，切換集數時重新推流給裝置。

### 網路

- **代理伺服器** —— 支援 HTTP、HTTPS、SOCKS4、SOCKS4a、SOCKS5、SOCKS5h，可帶
  認證資訊。
- **瀏覽器 TLS 指紋** —— 可借用 Chrome、Firefox 或 Safari 的指紋（含相符的
  User-Agent），用於拒絕非瀏覽器用戶端的來源。
- **本機媒體代理** —— 圖片、影片和字幕網址會經由應用自身的代理重新請求，
  因此帶 `Referer` 驗證的鏡像或帶 token 的 CDN 都能直接播放，用戶端不必逐個請求
  拼湊標頭。

### 診斷

- **日誌** —— Flutter 與 Go 日誌、兩份崩潰日誌，以及用於附上問題報告的分享/
  匯出功能。
- **開發者面板** —— 主控台與即時網路日誌，可檢視每個擴充功能發出了哪些請求，
  並可依擴充功能篩選。

### 介面

- **一套程式碼，兩套外殼** —— 依視窗寬度選擇桌面側邊欄外殼或行動版底部導覽
  外殼：桌面用對話框與寬欄網格，行動版用底部彈出層、下拉重新整理與手勢播放。
- **主題與語言** —— 淺色與深色 Material 3 主題，支援種子配色，介面語言為
  英語和中文。

---

## 運作原理

```text
┌──────────────────────────────────────────────────────────┐
│                    Flutter 前端                          │
│   畫面（觀看 · 閱讀 · 搜尋 · 下載）                      │
│   Riverpod 狀態 · MVVM                                   │
└───────────────────────────▲──────────────────────────────┘
                            │  gRPC  ·  本機 HTTP /proxy
┌───────────────────────────▼──────────────────────────────┐
│                  Go 後端（miru-core）                    │
│   gRPC 服務         擴充功能執行環境（JS + Go）          │
│   串流代理          種子引擎          SQLite             │
└──────────────────────────────────────────────────────────┘
```

Flutter 應用透過 gRPC 與內嵌的 Go 後端通訊。所有擴充功能呼叫和媒體請求都經過
該後端，這正是「一份代理設定 + 一份 TLS 身分」能涵蓋應用載入的全部內容的原因。

Flutter 編譯時會一併編譯兩個原生部分（見 `hook/build.dart`）：

- Go 後端，依目標 ABI 編譯為 `c-shared` 動態函式庫；
- `ffmpeg_merge`，一個 C++ 函式庫，負責把 HLS 片段拼接成單一 MP4（用於下載），
  以及為投放重新封裝串流。

更深入的技術細節——`/proxy` 路由、觀看流程、擴充功能生命週期、播放器流程、
下載不變式、續播邏輯與日誌——見 [DEVELOPMENT.md](DEVELOPMENT.md)。

---

## 專案結構

```text
lib/
  main.dart               正式版進入點
  main_debug.dart         除錯進入點：用於即時介面工具的 marionette 綁定
  app_bootstrap.dart      啟動流程：日誌、視窗、核心握手、路由
  ui/features/            每個畫面族一個目錄：home、search、detail、
                          watch/{video_player, manga_reader, novel_reader}、
                          download、history、favorite、extension、
                          extension_settings、setting、tracking、webview、
                          source_code、dev_tool、license
  ui/core/                共用元件：骨架 + 側邊欄、卡片、對話框、下拉重新整理、
                          動畫、錯誤/空/載入狀態
  provider/               Riverpod 狀態：watch、download、extension、cast、
                          search、home、tracking、shell
  data/                   資料存取層（面向領域），底層是 gRPC 服務
  domain/                 實體與用例（擴充功能與搜尋篩選）
  model/                  由 protobuf 產生的傳輸模型
  miru_core/              後端用戶端：gRPC 通道、事件流、代理網址
  utils/                  i18n、日誌與匯出、路由、主題、下載、字幕、續播、
                          追蹤用戶端
src/
  miru_core/miru-core/    Go 後端（子模組）：gRPC 服務、擴充功能執行環境
                          （goja JS + Scriggo Go）、串流代理、種子引擎、SQLite
  ffmpeg_merge/           C++ 輔助函式庫：HLS 片段合併、投放推流
  miru_core/windows/      Windows 預編譯函式庫
hook/build.dart           編譯掛鉤：Go c-shared + ffmpeg_merge + FFmpeg 執行環境
test/                     unit/、provider/、ui/、domain/、utils/
tool/                     發佈工具（從標籤取版本號、產生變更日誌）
third_party/              內建外掛：Linux 螢幕亮度
```

---

## 從原始碼編譯

### 前置條件

與 CI 保持一致（見 `.github/workflows/prbuild.yml` 與 `release_alpha.yml`）：

- **Flutter** `3.50.0`，stable 通道
- **Go** `1.27.3` —— 後端由編譯掛鉤編譯成動態函式庫
- **CMake** 與 **C++ 編譯器** —— `ffmpeg_merge` 從原始碼編譯
- **Git**，複製時加上 `--recurse-submodules`（`src/miru_core/miru-core` 是編譯
  掛鉤必要條件）

TMDB 認證資訊是編譯期常數。缺少時應用仍可執行，但詳情頁會失去詮釋資料：

```bash
flutter build <platform> --dart-define=TMDB_API_KEY=<key> \
                         --dart-define=TMDB_ACCESS_TOKEN=<token>
```

### Linux

```bash
# Debian / Ubuntu
sudo apt-get install -y ninja-build build-essential jq libasound2-dev \
     libgtk-3-dev libwebkit2gtk-4.1-dev libsoup-3.0-dev

# Arch
sudo pacman -S --needed gtk3 webkit2gtk-4.1 git clang cmake ninja jq alsa-lib

flutter run -d linux
# 或
flutter build linux --release
```

### Android

安裝 Android SDK 與 NDK，然後：

```bash
flutter build apk --release                  # 單一 APK
flutter build apk --release --split-per-abi  # 依 ABI 拆分，與 CI 發佈一致
```

### Windows

安裝含「使用 C++ 的桌面開發」工作負載的 Visual Studio，以及 CMake，然後：

```bash
flutter run -d windows
# 或
flutter build windows --release
```

如果編譯在早期就失敗，先執行 `flutter doctor` 與 `go version`——編譯掛鉤兩者都需要。

---

## 開發

### 程式碼產生

| 任務 | 指令 |
| --- | --- |
| Protobuf（Dart + Go） | `make gen-proto` |
| Riverpod / Freezed，單次 | `make build-runner` |
| Riverpod / Freezed，監聽 | `make runner-build-watch` |
| Scriggo 擴充功能相依（Go） | `cd src/miru_core/miru-core && make gen-deps` |

### 測試與靜態分析

```bash
flutter analyze --no-pub   # 必須保持零警告
flutter test               # 單元、provider、依功能的元件測試、整合測試
```

測試集區依功能分組：`test/unit`、`test/provider`、`test/ui`、`test/domain`、
`test/utils`，以及 `integration_test/`。

---

## 已知限制

- **不內建內容。** 應用不含任何擴充功能與片庫，只預設官方儲存庫網址，讓收藏庫在
  首次啟動時有內容可瀏覽。
- **alpha 階段。** 擴充功能 API 與設定可能在版本之間變更；舊 alpha 的資料庫與
  下載可能需要重設。
- **已存在但尚未接上的設定。** 小說閱讀器的 TTS、硬體加速、字幕字級與顏色、
  自動播放下一集、自動下載、自動同步追蹤——這些設定會被儲存，但尚未生效。
- **平台。** 正式支援 Android、Linux 和 Windows。iOS 與 macOS 的骨架程式碼存在，
  理論上可以執行，但並非日常目標。

---

## 許可證

GPL-3.0，見 [LICENSE](LICENSE)。
