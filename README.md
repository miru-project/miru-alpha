# Miru Alpha

[![Dev Build CI](https://github.com/miru-project/miru-alpha/actions/workflows/prbuild.yml/badge.svg)](https://github.com/miru-project/miru-alpha/actions/workflows/prbuild.yml)
[![Latest alpha pre-release](https://img.shields.io/github/v/release/miru-project/miru-alpha?include_prereleases&sort=semver)](https://github.com/miru-project/miru-alpha/releases)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](#license)
![Status: alpha](https://img.shields.io/badge/status-alpha-orange)

A rework of [miru_app](https://github.com/miru-project/miru-app).

**English** · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

Miru is a media client for three things — **video, manga and novels**. It
bundles no extensions and no catalogue: every title you watch or read is
resolved by an extension you installed. Extensions are plain JavaScript or Go
files that anyone can write and host. Install a source, search it, and the same
app streams, reads and downloads from it.

Android, Linux and Windows.

## Getting the app

Pre-built alpha builds are on the
[Releases page](https://github.com/miru-project/miru-alpha/releases). Every
release tag there is marked **pre-release** and carries the same asset set:

| Platform | Artifact |
| --- | --- |
| Android | `app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`, `app-x86_64-release.apk` |
| Linux | `Miru-Alpha-linux.tar.gz` |
| Windows | `Miru-Alpha-windows.zip` |

Every push also publishes dev builds as
[Actions artifacts](https://github.com/miru-project/miru-alpha/actions).
Changes are listed in [CHANGELOG.md](CHANGELOG.md).

---

## Features

### Watch

- **Video player** — HLS and direct video with quality switching, external
  subtitles, and 0.25×–3× speed in eight steps.
- **Touch and keyboard control** — double-tap to seek ±10 s, drag the right
  edge for volume and the left edge to scrub, arrow keys to seek, space to
  pause, fullscreen and screen-wake lock.
- **Torrent sources** — when a source returns a magnet link or `.torrent`, the
  file tree is resolved and the video file streams while it downloads.

### Read

- **Manga reader** — paged left-to-right, paged right-to-left, or continuous
  webtoon, with per-page brightness, colour inversion, page gaps, fit modes,
  zoom, chapter jump and bookmarks.
- **Novel reader** — paged, continuous or double-column, four reading themes,
  font family / size / line-height / margin controls, and page turns by tap
  zones or the volume rocker.

### Sources

- **One extension contract for all three media types** — a video source, a
  scanlation source and a novel source are the same kind of object, so one
  install model covers everything.
- **Three extension runtimes** — modern v2 JavaScript, legacy v1 JavaScript
  (original `miru-app` repositories work unchanged) and Go.
- **Repository store** — add repository URLs, browse what they publish, and
  install, update or uninstall. Import a single extension by URL or from a
  file instead.
- **Extension-defined filters** — a source declares its own select,
  multi-select, range and text controls; edits are staged and applied in one
  shot when the dialog closes, so a query costs one round-trip.
- **Per-extension settings** — a source registers its own inputs, toggles and
  radio options and persists them, can clear its cookies, and can open its
  website in an embedded webview when a source needs a real login.
- **In-app source editor** — open any installed extension with syntax
  highlighting and save a patch back to disk without leaving the app.

### Finding things

- **Global search** — one query across pinned, unpinned or all sources,
  sorted by relevance, newest release or source priority, with per-source
  failures listed and retryable.
- **Resolutions and mirrors on the page** — an episode that resolves to
  several bitrates opens a resolution picker instead of guessing, and a
  source that publishes mirrors lets you switch between them from the player.

### Keeping things

- **Downloads** — a queue with per-task priority, pause and resume, a cap on
  concurrent transfers, and automatic conversion of an HLS stream into a
  single MP4.
- **Restart-safe progress** — queued and interrupted tasks are rebuilt from
  what is actually on disk after a restart.
- **Resume** — a "continue watching" shelf and history that stay correct when
  an extension reorders or renumbers its episodes: the saved URL is matched
  first, and a missing episode is reported as gone instead of resuming the
  wrong one.
- **Favourites in groups** — file titles under tags and match several tags at
  once with AND or OR rules.
- **Offline playback** — finished downloads for all three media types open
  from the download page.

### Cast

- **DLNA casting (experimental)** — find renderers on the local network, push
  the current stream to them, and keep play / pause / seek in sync in both
  directions (the TV remote moves the app's position too), with subtitles
  burned in and episode switches re-pushing the renderer.

### Network

- **Proxies** — route traffic over HTTP, HTTPS, SOCKS4, SOCKS4a, SOCKS5 or
  SOCKS5h, with credentials.
- **Browser TLS identities** — borrow a Chrome, Firefox or Safari fingerprint
  (matching User-Agent) for sources that reject non-browser clients.
- **A local media proxy** — images, video and subtitle URLs are re-requested
  through the app's own proxy, so a `Referer`-gated mirror or a token-gated
  CDN plays without the client assembling headers per request.

### Diagnostics

- **Logs** — Flutter and Go logs, both crash logs, and a share/export action
  for attaching them to a bug report.
- **Developer panel** — a console and a live network log of what each
  extension requested, filterable per extension.

### Interface

- **One codebase, two shells** — a desktop sidebar shell and a mobile
  bottom-nav shell chosen by width: dialogs and wide grids on desktop, sheets,
  pull-to-refresh and gesture playback on mobile.
- **Theming and languages** — light and dark Material 3 themes with seed
  colours, English and Chinese.

---

## How it works

```text
┌──────────────────────────────────────────────────────────┐
│                    Flutter frontend                      │
│   screens (watch · read · search · download)             │
│   Riverpod state · MVVM                                  │
└───────────────────────────▲──────────────────────────────┘
                            │  gRPC  ·  local HTTP /proxy
┌───────────────────────────▼──────────────────────────────┐
│                    Go backend (miru-core)                │
│   gRPC services     extension runtimes (JS + Go)         │
│   stream proxy      torrent engine     SQLite            │
└──────────────────────────────────────────────────────────┘
```

The Flutter app talks to an embedded Go backend over gRPC. Every extension
call and every media fetch goes through that backend, which is what makes one
proxy configuration and one TLS identity apply to everything the app loads.

Two native pieces are compiled during the Flutter build (see
`hook/build.dart`):

- the Go backend, built as a `c-shared` library per target ABI;
- `ffmpeg_merge`, a C++ library that concatenates HLS segments into a single
  MP4 for downloads and remuxes streams for casting.

Deep technical detail — the `/proxy` route, watch pipeline, extension
lifecycle, player pipeline, download invariants, resume logic and logging —
lives in [DEVELOPMENT.md](DEVELOPMENT.md).

---

## Project map

```text
lib/
  main.dart               Release entry point
  main_debug.dart         Debug entry: marionette binding for live-UI tooling
  app_bootstrap.dart      Startup: logging, window, core handshake, router
  ui/features/            One folder per screen family: home, search, detail,
                          watch/{video_player, manga_reader, novel_reader},
                          download, history, favorite, extension,
                          extension_settings, setting, tracking, webview,
                          source_code, dev_tool, license
  ui/core/                Shared widgets: scaffold + sidebar, cards, dialogs,
                          refresh, animations, error/empty/loading states
  provider/               Riverpod state: watch, download, extension, cast,
                          search, home, tracking, shell
  data/                   Repositories (domain-facing) over gRPC services
  domain/                 Entities and use cases (extension and search filtering)
  model/                  Protobuf-backed wire models
  miru_core/              Backend client: gRPC channels, event stream, proxy URL
  utils/                  i18n, logging + export, router, themes, downloads,
                          subtitles, resume, tracking clients
src/
  miru_core/miru-core/    Go backend (submodule): gRPC services, extension
                          runtimes (goja JS + Scriggo Go), stream proxy,
                          torrent engine, SQLite
  ffmpeg_merge/           C++ helpers: HLS segment merge, cast streaming
  miru_core/windows/      Windows prebuilt library
hook/build.dart           Build hook: Go c-shared + ffmpeg_merge + FFmpeg runtimes
test/                     unit/, provider/, ui/, domain/, utils/
tool/                     Release tooling (version from tag, changelog)
third_party/              Vendored plugin: Linux screen brightness
```

---

## Building from source

### Prerequisites

Pinned to what CI uses (`.github/workflows/prbuild.yml` and
`release_alpha.yml`):

- **Flutter** `3.50.0`, stable channel
- **Go** `1.27.3` — the backend is compiled to a shared library by the build hook
- **CMake** and a **C++ compiler** — `ffmpeg_merge` is built from source
- **Git**, and clone with `--recurse-submodules` (`src/miru_core/miru-core` is a
  submodule the build hook requires)

TMDB credentials are compile-time constants. Without them the app runs, but
detail pages lose metadata:

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
# or
flutter build linux --release
```

### Android

Install the Android SDK and NDK, then:

```bash
flutter build apk --release            # single APK
flutter build apk --release --split-per-abi   # per-ABI, as CI ships
```

### Windows

Install Visual Studio with "Desktop development with C++", plus CMake, then:

```bash
flutter run -d windows
# or
flutter build windows --release
```

If a build fails early, run `flutter doctor` and `go version` before anything
else — the build hook needs both.

---

## Development

### Code generation

| Task | Command |
| --- | --- |
| Protobuf (Dart + Go) | `make gen-proto` |
| Riverpod / Freezed, single run | `make build-runner` |
| Riverpod / Freezed, watch | `make runner-build-watch` |
| Scriggo extension deps (Go) | `cd src/miru_core/miru-core && make gen-deps` |

### Tests and analysis

```bash
flutter analyze --no-pub   # must stay clean
flutter test               # unit, provider, per-feature widget, integration
```

Suites are grouped by feature: `test/unit`, `test/provider`, `test/ui`,
`test/domain`, `test/utils`, and `integration_test/`.

## Known limitations

- **No built-in content.** The app ships no extensions and no catalogue; it
  only seeds the official repository URL so the store has something to browse
  on first launch.
- **Alpha contracts.** Extension APIs and settings may change between
  releases; databases and downloads from older alphas may need a reset.
- **Settings that exist but do nothing yet.** TTS in the novel reader,
  hardware acceleration, subtitle font size and colour, auto-play-next,
  auto-download, and auto-sync tracking are stored but not wired up.
- **Platforms.** Android, Linux and Windows ship. The iOS and macOS
  scaffolding exists and should work, but is not a daily target.

---

## License

GPL-3.0. See [LICENSE](LICENSE).
