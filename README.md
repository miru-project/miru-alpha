# Miru Alpha

[![Dev Build CI](https://github.com/miru-project/miru-alpha/actions/workflows/prbuild.yml/badge.svg)](https://github.com/miru-project/miru-alpha/actions/workflows/prbuild.yml)
[![Latest alpha pre-release](https://img.shields.io/github/v/release/miru-project/miru-alpha?include_prereleases&sort=semver)](https://github.com/miru-project/miru-alpha/releases)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](#license)
![Status: alpha](https://img.shields.io/badge/status-alpha-orange)

A modern rework of [miru_app](https://github.com/miru-project/miru-app).

Miru is a versatile, free and open-source application designed for streaming video, reading manga, and enjoying novels with a flexible third-party extension ecosystem. Available across **Android**, **Linux**, and **Windows**.

> **Status: alpha.** Core functionality works and is used daily in development, but APIs and extension contracts can still change between releases. Not yet hardened for general production use.

Miru ships **no content of its own** — everything you watch or read comes from extensions you install yourself, and you are responsible for what you install. If you want a curated, out-of-the-box catalogue with official sources, this is not that tool.

## Getting the app

Pre-built alpha releases are published on the
[Releases page](https://github.com/miru-project/miru-alpha/releases) — every
tag there is marked **pre-release**, and each one ships the same set of
artifacts:

| Platform | Artifact |
| --- | --- |
| Android | [app-arm64-v8a-release.apk](https://github.com/miru-project/miru-alpha/releases/latest/download/app-arm64-v8a-release.apk), [app-armeabi-v7a-release.apk](https://github.com/miru-project/miru-alpha/releases/latest/download/app-armeabi-v7a-release.apk), [app-x86_64-release.apk](https://github.com/miru-project/miru-alpha/releases/latest/download/app-x86_64-release.apk) |
| Linux | [Miru-Alpha-linux.tar.gz](https://github.com/miru-project/miru-alpha/releases/latest/download/Miru-Alpha-linux.tar.gz) |
| Windows | [Miru-Alpha-windows.zip](https://github.com/miru-project/miru-alpha/releases/latest/download/Miru-Alpha-windows.zip) |

For bleeding-edge builds from every push, use the
[Actions artifacts](https://github.com/miru-project/miru-alpha/actions) instead.
Notable changes are tracked in [CHANGELOG.md](CHANGELOG.md).

---

## Features

- **Three media types**: stream video, read manga and read novels from the same extension contract —
- **Video player**: stream HLS or MP4 with quality switching, external subtitles, 0.25×–3× speed and gesture controls (double-tap seek, edge volume / scrub)
- **Extensions**: install community extensions for any of the three types; modern v2 JS, legacy v1 JS (old miru repos work as-is) and Go extensions coexist
- **Extension store**: browse, filter, install, update and uninstall extensions from repo URLs, or import them by URL / file picker
- **In-app editor**: open any installed extension's source with syntax highlighting and save patches without leaving the app
- **Per-extension settings**: extensions register their own inputs, toggles and radio options, persist values, manage cookies and open webviews
- **Extension filters**: extensions define select / multi-select / range / text filters, applied in one shot when the dialog closes
- **Cast (experimental)**: throw the current stream to DLNA devices on your local network — scan, connect and control play / pause / seek / volume / mirror switching from the app, with subtitles burned in
- **Downloads**: queue, prioritise, pause and resume; interrupted downloads recover on restart, and HLS streams convert to a single MP4 automatically
- **History & favourites**: resume where you left off — safely, even if an extension reorders episodes — with a "Continue watching" shelf and grouped favourites
- **Torrent streaming**: paste a magnet or `.torrent` file, pick a file from the archive and start watching while it downloads
- **Manga reader**: read paged (left-to-right / right-to-left) or webtoon style, with brightness, colour inversion, page-gap and fit controls, bookmarks, chapter jump and zoom
- **Novel reader**: read paged, continuous or double-column with four reading themes, font controls, tap-edge and volume-key page turns
- **Global search**: run one query across pinned, all or hand-picked sources, sort by relevance / release date / priority, and see per-source failures with retry
- **Detail pages**: browse episode groups and mirrors, play downloaded files offline, pull TMDB metadata and track progress on AniList inline
- **Network privacy**: route traffic through HTTP / SOCKS proxies and browser-impersonating TLS identities
- **Logs & diagnostics**: capture app and backend logs plus crashes, export them for support, and watch what each extension requests live in the developer panel
- **Desktop & mobile in one**: a desktop sidebar shell and a mobile bottom-nav shell driven by breakpoints — sheets, pull-to-refresh and gestures on mobile, dialogs and wide layouts on desktop

---

## Architecture Overview

Miru Alpha separates presentation from network and data processing:

```text
┌────────────────────────────────────────────────────────┐
│                   Flutter Frontend                     │
│  UI (Watch, Detail, Download) ── Riverpod & MVVM       │
└───────────────────────────▲────────────────────────────┘
                            │ gRPC & Local HTTP Proxy
┌───────────────────────────▼────────────────────────────┐
│                  Go Backend (miru-core)                │
│  • gRPC Service Layer      • Extension Runtime (Go/JS) │
│  • HTTP Stream Proxy       • Torrent Engine & SQLite   │
└────────────────────────────────────────────────────────┘
```

The Flutter app communicates with an embedded or local Go backend via gRPC. All media fetching and extension requests are handled through the core service, guaranteeing unified proxying and security handling; images and media URLs additionally ride the local `/proxy` route so every fetch inherits the app's proxy and TLS settings.

Layout is breakpoint-driven (forui `sm` 640 / `lg` 1024): below `lg` the sidebar collapses into a mobile bottom-nav scaffold, and desktop and mobile have parallel widget trees for most screens (persistent sidebar, dialogs and inline dev panels on desktop; bottom navigation, sheets, pull-to-refresh and gesture-driven playback on mobile). The desktop window is freely resizable with a phone-sized floor; macOS gets native traffic-light positioning.

---

## Project Map

```text
lib/
  main.dart               App entry (release & debug share it)
  main_debug.dart         Debug entry: marionette binding for MCP/tooling
  app_bootstrap.dart      Core init + the debug-only phone-frame shell
  ui/features/            One folder per screen family: detail, download,
                          extension, extension_settings, favorite, history,
                          home, search, setting, tracking, watch, webview,
                          source_code, license, dev_tool
  ui/core/                Shared atoms (error display, cards, widgets)
  provider/               Riverpod state notifiers (watch, download,
                          extension, cast, home, ...)
  domain/ model/ data/    Entities, models, data layer
  utils/                  i18n (en/zh), logging, http (proxy client),
                          router, torrent/subtitle helpers
src/
  miru_core/miru-core/    Go backend: gRPC services, extension runtimes
                          (goja + Scriggo), stream proxy, torrent engine,
                          ent (SQLite), miru_cli
  ffmpeg_merge/           Native C++ HLS-segment merge library
test/
  unit/  provider/  ui/   Unit tests, notifier tests, per-feature widget
                          tests (incl. a watch layout matrix)
```

---

## Building from Source

### Prerequisites

Pinned to what CI builds with (`.github/workflows/prbuild.yml` → `release_alpha.yml`):

- **Flutter**: `3.47.7` (stable channel).
- **Go**: `1.27.3` — the backend is compiled to a shared library by the Dart build hook.
- **C++ toolchain** (CMake + a C++ compiler) — the native `ffmpeg_merge` library is built from source during the Flutter build.
- **Git** (with submodules — `src/miru_core/miru-core` is checked out with `submodules: true`).

The Android/Windows/Linux build steps also pass TMDB credentials as
compile-time constants (optional at runtime — TMDB metadata degrades
without them):

```bash
--dart-define=TMDB_API_KEY=<key> --dart-define=TMDB_ACCESS_TOKEN=<token>
```

---

### Platform Setup & Instructions

#### Linux

1. Install the required system packages (matches CI's apt list):
   - **Debian / Ubuntu**:

     ```bash
     sudo apt-get install -y ninja-build build-essential jq libasound2-dev libgtk-3-dev libwebkit2gtk-4.1-dev libsoup-3.0-dev
     ```

   - **Arch Linux**:

     ```bash
     sudo pacman -S --needed gtk3 webkit2gtk-4.1 git clang cmake ninja jq alsa-lib
     ```

2. Run or build the app:

   ```bash
   flutter run -d linux
   # or build release bundle:
   flutter build linux --release
   ```

   Verify your toolchain first if something fails early: `flutter doctor`
   and `go version` should both succeed.

#### Android

Ensure the **Android SDK**, **NDK**, and `go` are installed and properly configured in your environment. Native libraries are automatically compiled for each target ABI during the Flutter build hook.

```bash
flutter build apk --release
```

#### Windows

Ensure the **Desktop development with C++** workload in Visual Studio (or Build Tools) is installed, along with CMake.

```bash
flutter run -d windows
# or build release executable:
flutter build windows --release
```

---

## Developer Guide

### Code Generation & Tooling

Miru Alpha relies on code generation for Protobuf contracts, Riverpod state notifiers, and JSON serialization:

- **Generate Protobuf Definitions**:
  Regenerate Dart and Go gRPC / protobuf models:

  ```bash
  make gen-proto
  ```

- **Run Build Runner** (Riverpod & Freezed):

  ```bash
  # Single run:
  make build-runner

  # Continuous file-watch mode during development:
  make runner-build-watch
  ```

- **Scriggo Extension Dependencies** (Go Backend):
  When updating extension types in `src/miru_core/miru-core`:

  ```bash
  cd src/miru_core/miru-core
  make gen-deps
  ```

### Tests & Analysis

```bash
flutter analyze --no-pub   # lint; must stay clean
flutter test               # unit + provider + per-feature widget tests
```

Suites live in `test/unit`, `test/provider` and `test/ui`, grouped per feature.

### Technical & development reference

Deep technical detail — architecture internals (the `/proxy` route, watch
pipeline), extension runtimes and lifecycle, the video player pipeline
(mdk/libass subtitles, torrent streaming), download/conversion invariants,
the network stack, resume logic, logging, debug tooling, testing
conventions and known limitations — lives in
[DEVELOPMENT.md](DEVELOPMENT.md).

### Known limitations & non-goals

- **No built-in content.** Miru is a shell: streams, pages and chapters
  come entirely from user-installed extensions.
- **Alpha maturity.** Extension contracts and settings may change between
  releases; databases and downloads from older alphas may need a reset.
- **Persisted-but-unconsumed settings.** TTS (novel reader), hardware
  acceleration, subtitle font size/colour, auto-play-next, auto-download
  and auto-sync tracking exist in the settings model but are not wired up
  yet.
- **Platforms.** Android, Linux and Windows ship; iOS/macOS scaffolding
  exists but is untested day-to-day but should be possible.

---

## License

This project is licensed under the GPL-3.0 License.

## Download links

All release artifacts are published on the
[Releases page](https://github.com/miru-project/miru-alpha/releases) — pre-releases
are not exposed via `/releases/latest`, so download from the most recent
`*-alpha*` release there.

| Platform | Artifacts | Notes |
| --- | --- | --- |
| Android | `app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`, `app-x86_64-release.apk` | For most modern Android devices, use arm64-v8a |
| Linux | `Miru-Alpha-linux.tar.gz` | Extract and run the binary |
| Windows | `Miru-Alpha-windows.zip` | Extract and run Miru-alpha.exe |

You can also link directly by tag if you know it:
`https://github.com/miru-project/miru-alpha/releases/download/vX.Y.Z-alpha/<filename>`
