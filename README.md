# Miru Alpha

A modern rework of [miru_app](https://github.com/miru-project/miru-app).

Miru is a versatile, free and open-source application designed for streaming video, reading manga, and enjoying novels with a flexible third-party extension ecosystem. Available across **Android**, **Linux**, and **Windows**.

To grab the latest development builds, visit [GitHub Actions Releases](https://github.com/miru-project/miru-alpha/actions).

---

## Features

- **Multi-Media Hub**: Seamless support for Anime/Video streaming (HLS, MP4), Manga reader, and Web Novels.
- **Integrated Torrent Engine**: Built-in BitTorrent support for streaming media directly via magnet links and `.torrent` files.
- **Extension Ecosystem**: Modular architecture supporting community-authored extensions in JavaScript and Go (Scriggo VM).
- **Network & Privacy**: Built-in HTTP, SOCKS4/5 proxy routing, and TLS fingerprint spoofing to protect media requests.
- **Cross-Platform Experience**: Modern, responsive UI powered by Flutter and Forui, paired with a high-performance Go backend (`miru-core`).

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

The Flutter app communicates with an embedded or local Go backend via gRPC. All media fetching and extension requests are handled through the core service, guaranteeing unified proxying and security handling.

---

## Building from Source

### Prerequisites

- **Flutter**: Flutter SDK (`>= 3.24.x` recommended, ensure `flutter` is on your `PATH`).
- **Go**: Go toolchain (`>= 1.22.x`, ensure `go` is on your `PATH`).
- **Git**

---

### Platform Setup & Instructions

#### Linux

1. Install the required system packages:
   - **Debian / Ubuntu**:

     ```bash
     sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev libwebkit2gtk-4.1-dev libasound2-dev jq
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

---

## License

This project is licensed under the GPL-3.0 License.
