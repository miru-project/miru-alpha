# Miru Alpha

A rework version of [miru_app](github.com/miru-project/miru-app)

## Getting Started

The project currently work in progress. To download the latest dev build, go to
[github actions](https://github.com/miru-project/miru-alpha/actions)

## Build

This project uses a GitHub Actions workflow to build artifacts for Android,
Windows and Linux. The sections below document how the CI builds match those
local steps so you can reproduce the outputs locally.

### Prerequisites

- Flutter (Flutter 3.41.1 stable). Install and ensure `flutter` is on PATH.
- Go ( Go 1.25.7). Install and ensure `go` is on PATH.

### Linux

Make sure the following depencies are exist.

```text
ninja-build, build-essential, libasound2-dev, libgtk-3-dev, libwebkit2gtk-4.1-0, libwebkit2gtk-4.1-dev, libsoup-3.0-0, libsoup-3.0-dev
```

### Android

Go to `projectPath/src/miru_core/miru-core/binary` and run the following
command.

```bash
go get golang.org/x/mobile/cmd/gomobile #for the first time
gomobile init  #for the first time
make build-android
```

## Progress and Future work

The plan has split into two stage basic (`2.0.0`) and advanced.

### Basic

The basic stage contains necessary components for apps to run at minimum
functionality.

#### Miru Core (backend)

##### Js Runtime (goja) V1

- [x] DOM (implement with linkedom)
- [x] Crypto Js

##### DB

- [x] Settings

#### App

##### Readview

- [x] Video player
- [x] Manga reader
- [ ] Novel reader

##### Extension

- [x] Search and install

### Advanced

#### Miru Core (backend)

- [x] Torrent support

##### Backup

- [x] webdav

##### Downloader

- [x] Mp4
- [x] Hls
- [ ] Torrent
- [ ] Manga
- [ ] Novel

##### DB

- [ ] Favorite
- [ ] History

#### App

- [ ] Anilist support
- [ ] Devtool
- [ ] Search filter

##### Download

- [ ] UI
- [x] FFmpeg

##### Video player

##### Manga Reader

- [ ] infinite scroll
- [ ] support Tortent

##### Novel reader

- [ ] support epub
- [ ] support Torrent
- [ ] Page view
- [ ] Integrate TTS (KokoroTTS)
