# Miru Alpha

[![Dev Build CI](https://github.com/miru-project/miru-alpha/actions/workflows/prbuild.yml/badge.svg)](https://github.com/miru-project/miru-alpha/actions/workflows/prbuild.yml)
[![Latest alpha pre-release](https://img.shields.io/github/v/release/miru-project/miru-alpha?include_prereleases&sort=semver)](https://github.com/miru-project/miru-alpha/releases)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](#许可证)
![Status: alpha](https://img.shields.io/badge/status-alpha-orange)

[English](README.md) · **简体中文** · [繁體中文](README.zh-Hant.md)

[miru_app](https://github.com/miru-project/miru-app) 的现代化重写版本。

Miru 是一款媒体客户端，面向三类内容——**视频、漫画和小说**。它本身不内置任何
扩展，也没有自带片库：你观看或阅读的每一个条目，都由你安装的扩展来解析。
扩展就是普通的 JavaScript 或 Go 文件，任何人都能编写并托管。装好一个源，
搜索它，同一个应用就能播放、阅读和下载。

支持 Android、Linux 和 Windows。

## 获取应用

预编译的 alpha 版本发布在
[Releases 页面](https://github.com/miru-project/miru-alpha/releases)。那里的
每个发布标签都标记为 **pre-release**，并带有同一套产物：

| 平台 | 产物 |
| --- | --- |
| Android | `app-arm64-v8a-release.apk`、`app-armeabi-v7a-release.apk`、`app-x86_64-release.apk` |
| Linux | `Miru-Alpha-linux.tar.gz` |
| Windows | `Miru-Alpha-windows.zip` |

每次推送还会发布开发版构建，见
[Actions artifacts](https://github.com/miru-project/miru-alpha/actions)。
变更记录见 [CHANGELOG.md](CHANGELOG.md)。

---

## 功能

### 观看

- **视频播放器** —— HLS 与直链视频，支持清晰度切换、外挂字幕，以及八档
  0.25×–3× 倍速。
- **触控与键盘操作** —— 双击快进/快退 ±10 秒，右边缘上下拖动调音量、
  左边缘拖动调进度，方向键快进快退，空格暂停，全屏与屏幕常亮锁。
- **种子来源** —— 当源返回磁力链接或 `.torrent` 时，应用会解析出文件列表，
  边下载边播放视频文件。

### 阅读

- **漫画阅读器** —— 支持左右页、右左页与连续滚动（webtoon）三种模式，可逐页
  调节亮度、颜色反转、页间距、适配方式，并提供缩放、跳章和书签。
- **小说阅读器** —— 支持分页、连续与双栏三种版式，四款阅读主题，可调节字体、
  字号、行高与页边距，并可用点击区域或音量键翻页。

### 扩展来源

- **三类媒体共用一套扩展契约** —— 视频源、漫画源和小说源是同一种对象，
  因此只需一套安装模型。
- **三种扩展运行时** —— 新版 v2 JavaScript、旧版 v1 JavaScript（原版
  `miru-app` 仓库无需修改即可使用）以及 Go。
- **仓库商店** —— 添加仓库地址，浏览其中发布的扩展，并进行安装、更新或卸载；
  也可以按 URL 或从本地文件导入单个扩展。
- **由扩展定义的筛选器** —— 源自行声明下拉选择、多选、区间和文本四类控件；
  编辑会先暂存，关闭对话框时一次性提交，因此一次查询只产生一次请求。
- **每个扩展独立设置** —— 源可以注册自己的输入框、开关和单选选项并持久化保存，
  可以清除自己的 Cookie，当某个源需要真实登录时还能在内置 WebView 中打开其网站。
- **内置源码编辑器** —— 打开任意已安装扩展的源码，带语法高亮，并可直接把修改
  保存回磁盘，无需离开应用。

### 查找

- **全局搜索** —— 一次查询覆盖已置顶、未置顶或全部来源，可按相关度、最新更新
  或来源优先级排序，并列出每个来源的失败项且可重试。
- **页内清晰度与镜像** —— 某一集解析出多个码率时会弹出清晰度选择器而不是替你猜；
  源发布了镜像时，可直接在播放器中切换。

### 管理

- **下载** —— 队列支持逐任务优先级、暂停与继续、并发上限，并会把 HLS 流自动
  合并为单个 MP4。
- **重启不丢进度** —— 排队中和被中断的任务，在重启后会根据磁盘上实际存在的文件
  重建。
- **续播** —— “继续观看”书架与历史记录在扩展重排或重新编号剧集后依然正确：
  优先匹配已保存的 URL，找不到的剧集会报告为已失效，而不是续播到错误的一集。
- **分组收藏** —— 把条目标注到标签下，并可用 AND 或 OR 规则同时匹配多个标签。
- **离线播放** —— 三类媒体的已完成下载都可直接从下载页打开。

### 投屏

- **DLNA 投屏（实验性）** —— 发现局域网内的渲染设备，把当前推流投上去，并让
  播放/暂停/进度在两端保持同步（用电视遥控器操作也会同步回应用的位置），
  字幕会被烧录进画面，切换剧集时重新推流给设备。

### 网络

- **代理** —— 支持 HTTP、HTTPS、SOCKS4、SOCKS4a、SOCKS5、SOCKS5h，可带凭据。
- **浏览器 TLS 指纹** —— 可借用 Chrome、Firefox 或 Safari 的指纹（含匹配的
  User-Agent），用于拒绝非浏览器客户端的源。
- **本地媒体代理** —— 图片、视频和字幕 URL 会经由应用自身的代理重新请求，
  因此带 `Referer` 校验的镜像或带 token 的 CDN 都能直接播放，客户端不必逐请求
  拼装请求头。

### 诊断

- **日志** —— Flutter 与 Go 日志、两份崩溃日志，以及用于附上问题报告的分享/
  导出功能。
- **开发者面板** —— 控制台与实时网络日志，可查看每个扩展发出了哪些请求，
  并可按扩展筛选。

### 界面

- **一套代码，两套外壳** —— 按窗口宽度选择桌面侧边栏外壳或移动端底部导航外壳：
  桌面用对话框与宽栏网格，移动端用底部弹层、下拉刷新与手势播放。
- **主题与语言** —— 浅色与深色 Material 3 主题，支持种子配色，界面语言为
  英语和中文。

---

## 工作原理

```text
┌──────────────────────────────────────────────────────────┐
│                    Flutter 前端                          │
│   界面（观看 · 阅读 · 搜索 · 下载）                      │
│   Riverpod 状态 · MVVM                                   │
└───────────────────────────▲──────────────────────────────┘
                            │  gRPC  ·  本地 HTTP /proxy
┌───────────────────────────▼──────────────────────────────┐
│                  Go 后端（miru-core）                    │
│   gRPC 服务         扩展运行时（JS + Go）                │
│   流媒体代理        种子引擎          SQLite             │
└──────────────────────────────────────────────────────────┘
```

Flutter 应用通过 gRPC 与内嵌的 Go 后端通信。所有扩展调用和媒体请求都经过该后端，
这正是“一份代理配置 + 一份 TLS 身份”能覆盖应用加载的全部内容的原因。

Flutter 构建期间会编译两个原生部分（见 `hook/build.dart`）：

- Go 后端，按目标 ABI 编译为 `c-shared` 动态库；
- `ffmpeg_merge`，一个 C++ 库，负责把 HLS 分片拼接成单个 MP4（用于下载），
  以及为投屏重新封装流。

更深入的技术细节——`/proxy` 路由、观看链路、扩展生命周期、播放器链路、
下载不变量、续播逻辑与日志——见 [DEVELOPMENT.md](DEVELOPMENT.md)。

---

## 项目结构

```text
lib/
  main.dart               正式版入口
  main_debug.dart         调试入口：用于实时界面工具的 marionette 绑定
  app_bootstrap.dart      启动流程：日志、窗口、核心握手、路由
  ui/features/            每个界面族一个目录：home、search、detail、
                          watch/{video_player, manga_reader, novel_reader}、
                          download、history、favorite、extension、
                          extension_settings、setting、tracking、webview、
                          source_code、dev_tool、license
  ui/core/                共享组件：脚手架 + 侧边栏、卡片、对话框、下拉刷新、
                          动画、错误/空/加载状态
  provider/               Riverpod 状态：watch、download、extension、cast、
                          search、home、tracking、shell
  data/                   仓库层（面向领域），底层是 gRPC 服务
  domain/                 实体与用例（扩展与搜索筛选）
  model/                  由 protobuf 生成的传输模型
  miru_core/              后端客户端：gRPC 通道、事件流、代理 URL
  utils/                  i18n、日志与导出、路由、主题、下载、字幕、续播、
                          追踪客户端
src/
  miru_core/miru-core/    Go 后端（子模块）：gRPC 服务、扩展运行时
                          （goja JS + Scriggo Go）、流媒体代理、种子引擎、SQLite
  ffmpeg_merge/           C++ 辅助库：HLS 分片合并、投屏推流
  miru_core/windows/      Windows 预编译库
hook/build.dart           构建钩子：Go c-shared + ffmpeg_merge + FFmpeg 运行时
test/                     unit/、provider/、ui/、domain/、utils/
tool/                     发布工具（从标签取版本号、生成变更日志）
third_party/              内置插件：Linux 屏幕亮度
```

---

## 从源码构建

### 前置条件

与 CI 保持一致（见 `.github/workflows/prbuild.yml` 与 `release_alpha.yml`）：

- **Flutter** `3.50.0`，stable 通道
- **Go** `1.27.3` —— 后端由构建钩子编译为动态库
- **CMake** 与 **C++ 编译器** —— `ffmpeg_merge` 从源码编译
- **Git**，克隆时加 `--recurse-submodules`（`src/miru_core/miru-core` 是构建
  钩子必需的子模块）

TMDB 凭据是编译期常量。缺失时应用仍可运行，但详情页会失去元数据：

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

安装 Android SDK 与 NDK，然后：

```bash
flutter build apk --release                  # 单个 APK
flutter build apk --release --split-per-abi  # 按 ABI 拆分，与 CI 发布一致
```

### Windows

安装带“使用 C++ 的桌面开发”工作负载的 Visual Studio，以及 CMake，然后：

```bash
flutter run -d windows
# 或
flutter build windows --release
```

如果构建在早期就失败，先运行 `flutter doctor` 与 `go version`——构建钩子两者都需要。

---

## 开发

### 代码生成

| 任务 | 命令 |
| --- | --- |
| Protobuf（Dart + Go） | `make gen-proto` |
| Riverpod / Freezed，单次 | `make build-runner` |
| Riverpod / Freezed，监听 | `make runner-build-watch` |
| Scriggo 扩展依赖（Go） | `cd src/miru_core/miru-core && make gen-deps` |

### 测试与静态分析

```bash
flutter analyze --no-pub   # 必须保持零告警
flutter test               # 单元、provider、按功能的组件测试、集成测试
```

测试套件按功能分组：`test/unit`、`test/provider`、`test/ui`、`test/domain`、
`test/utils`，以及 `integration_test/`。

---

## 已知限制

- **不内置内容。** 应用不含任何扩展与片库，只预置官方仓库地址，让商店在首次
  启动时有内容可浏览。
- **alpha 契约。** 扩展 API 与设置可能在版本间变化；旧 alpha 的数据库与下载
  可能需要重置。
- **已存在但未接线的设置。** 小说阅读器的 TTS、硬件加速、字幕字号与颜色、
  自动播放下一集、自动下载、自动同步追踪——这些设置会被保存，但尚未生效。
- **平台。** 正式支持 Android、Linux 和 Windows。iOS 与 macOS 的骨架代码存在，
  理论上可以运行，但并非日常目标。

---

## 许可证

GPL-3.0，见 [LICENSE](LICENSE)。
