# Miru Alpha

A rework version of [miru_app](github.com/miru-project/miru-app)

## Getting Started

The project currently work in progress. To download the latest dev build, go to [github actions](https://github.com/miru-project/miru-alpha/actions)

## Build

This project uses a GitHub Actions workflow to build artifacts for Android, Windows and Linux. The sections below document how the CI builds match those local steps so you can reproduce the outputs locally.

### Prerequisites

- Flutter (Flutter 3.35.4 stable). Install and ensure `flutter` is on PATH.
- Go ( Go 1.25.1). Install and ensure `go` is on PATH.

### Linux

Make sure the following depencies are exist.

```text
ninja-build, build-essential, libasound2-dev, libgtk-3-dev, libwebkit2gtk-4.1-0, libwebkit2gtk-4.1-dev, libsoup-3.0-0, libsoup-3.0-dev
```

### Android

Go to  `projectPath/src/miru_core/miru-core/binary` and run the following command.

```bash
go get golang.org/x/mobile/cmd/gomobile #for the first time
gomobile init  #for the first time
gomobile bind -ldflags="-s -w" -o ../../android/libmiru-core.aar -target=android -androidapi 21
```
