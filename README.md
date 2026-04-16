# Miru Alpha

A rework version of [miru_app](github.com/miru-project/miru-app)

## Getting Started

FOSS app for videos, comics, and novels with extension support available on Windows, Android and Linux (Rework of miru-app WIP). To download the latest dev build, go to [github actions](https://github.com/miru-project/miru-alpha/actions)

## Build

This project uses a GitHub Actions workflow to build artifacts for Android,
Windows and Linux. The sections below document how the CI builds match those
local steps so you can reproduce the outputs locally.

### Prerequisites

- Flutter (Flutter 3.41.X stable). Install and ensure `flutter` is on PATH.
- Go ( Go 1.26.X). Install and ensure `go` is on PATH.

### Linux

Make sure the following depencies are exist.

```text
gtk3 wpewebkit git clang cmake ninja jq alsa-utils alsa-plugins
```

### Android

Go to `projectPath/src/miru_core/miru-core/binary` and run the following
command.

```bash
go get golang.org/x/mobile/cmd/gomobile #for the first time
gomobile init  #for the first time
make build-android
```
