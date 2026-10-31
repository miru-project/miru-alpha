# Development & Technical Reference

Deep technical detail for contributors and extension developers. For the
feature overview, build instructions and project map, see the
[README](README.md). Internal working conventions for agent-assisted
development live in `.agents/` (`rules.md`, `ui.md`, `network.md`,
`debug.md`).

---

## 1. Architecture internals

- **Process boundary**: the Flutter app embeds (or attaches to) `miru-core`,
  a Go binary exposing gRPC services. State notifiers (`lib/provider/`)
  call the gRPC clients; entities live in `lib/domain` + `lib/model`; the
  data layer (`lib/data`) maps protos to models.
- **Bootstrap contract**: on connect the backend sends a `HelloMiru`
  snapshot (settings + the merged extension list) and then republishes the
  extension list on every extension-folder change — a frontend list-replace
  can therefore never drop one runtime's extensions.
- **The `/proxy` route**: every image/media URL handed to a widget goes
  through miru-core's HTTP proxy. The rich form is
  `/proxy/<name>?__u=<b64url(target)>&__mh=<b64url(json headers)>`
  (+ `__tls=1&__tlsp=<profile>`), where `<name>` preserves the target's
  file name so players can sniff the container (`.m3u8`, `.vtt`). The proxy
  applies the encoded headers server-side — Referer-gated mirrors and
  Cloudflare-fronted CDNs resolve without the client ever setting headers.
- **Watch pipeline**: an extension's watch call resolves a URL (v2 results
  additionally carry mirror groups with a default group/index hint). The
  backend wraps every resolved stream URL with `proxyWatchURL` (headers
  + optional TLS profile are stripped from the forwarded set and applied
  server-side; torrent/magnet links are resolved into a local file tree
  instead). The frontend therefore opens proxy URLs, never raw upstream
  URLs, and mirror switching just re-requests another mirror's proxied URL.

## 2. Extension system

- **Runtimes**: JavaScript extensions execute on goja with the
  goja_nodejs event loop; Go extensions execute on a patched Scriggo fork
  (v2 only). JS API versioning is opt-in — an explicit `@apiVersion 2`
  manifest tag selects V2, and a missing, empty or unrecognised tag falls
  back to **V1, the legacy class-based runtime**, which is what keeps the
  original miru_app extension ecosystem running unchanged. The registry
  merges both runtimes — Go wins on a package-name collision — and is the
  single source of truth published to the frontend.
- **Legacy repos**: the app consumes the old miru-project repo index
  (`https://raw.githubusercontent.com/miru-project/repo/main/index.json`)
  exactly like a Miru Alpha repo — add it by URL in Settings → Repo. The
  default seeded repo is the Miru Alpha index
  (`appdevelpo/repo`, `miru_alpha` branch); both styles are plain JSON
  indexes of `.js` files and the install path is identical.
- **Lifecycle**: the store downloads `.js`/`.go` files into the extension
  directory (the suffix comes from the published path, so a Go extension
  lands as `<pkg>.go` and is picked up by the Scriggo directory scan);
  uninstall removes only the matching suffix. Update detection compares
  repo vs installed version with a semantic-version comparator.
- **Capabilities**: `registerSetting` (input/radio/toggle with defaults),
  per-extension persisted values, cookie management, webview opening,
  typed content filters (select, multi-select with min/max, range, text).
  The filter dialog stages edits and issues exactly one `createFilter`
  call plus one results refetch when it closes.
- **In-app editor**: installed extensions open in code_forge
  (atom-one-dark, JS highlighting) and can be saved back to disk from the
  app bar.

## 3. Video player pipeline

- **Engine**: the `video_player` interface is backed by fvp (mdk-sdk) on
  every platform, registered in `lib/app_bootstrap.dart` with
  `video.decoders: [D3D11, NVDEC, FFmpeg]`, a `2000+600000` buffer, and
  mdk log level `debug` (fvp's own `all` spams ~15 lines/s while a hidden
  surface plays).
- **Quality switching**: HLS master playlists are switched by re-opening
  the chosen variant rather than mid-stream trickery; mirrors switch by
  re-requesting another mirror's URL.
- **Subtitles**: two paths.
  - *Native (preferred)*: the selected subtitle URL rides the standard
    `/proxy` wrap (same as images — special fetching is the extension's
    job) and is handed to mdk via `setExternalSubtitle`, so libass renders
    it into the frame. Closing subtitles disables the mdk track.
  - *Fallback (non-fvp engines)*: the Dart overlay parses VTT into timed
    cues (`lib/utils/watch/subtitle.dart`), fetching with the stream's
    HTTP headers (`_streamHeaders`) — subtitle CDNs gate on the same
    Referer/User-Agent the video needs.
- **Torrent playback**: a magnet/`.torrent` resolves to a file tree
  (`ExtensionBangumiWatchTorrent`, identical shape for both runtimes); the
  player points at the local miru-core HTTP endpoint for the chosen file
  (range requests supported) and the torrent is deleted on dispose.
- **Mobile gestures**: double-tap ±10 s seek, right-edge vertical drag for
  volume (VolumeController), left-edge scrub, with the chrome collapsing
  to an unlock pill while locked.

## 4. Readers

- **Manga**: paged LTR/RTL and continuous webtoon share settings applied
  by the reader shell (brightness/wakelock), not the viewport; chapter
  ordering is per-extension (asc/desc) with a filterable drawer; dedicated
  zoom surfaces exist for both layouts.
- **Novel**: paged / continuous / double-column (with flipped variants),
  four themes, font/line-height/family configuration, tap-edge and
  volume-rocker turning.

## 5. Downloads & conversion

- **Scheduler**: max-concurrent limit, per-task priority, manual queue
  reordering, pause/resume/cancel; progress persists and is verified
  against the bytes on disk on restart (HLS/MP4/torrent-specific checks).
- **Path layout**: `<root>/<Category>/<package>/<title>/<epGroup>/<epName><ext>`
  with every segment sanitised; per-category storage usage counts
  completed plus in-progress temp bytes.
- **HLS → MP4**: miru-core decrypts AES-128 segments; Flutter validates
  every segment exists and is non-empty (refusing to succeed on a
  truncated list) before the native `ffmpeg_merge` C++ library
  (`src/ffmpeg_merge`, built as a Flutter build hook) merges off the UI
  isolate. The status must reach COMPLETED before source segments are
  deleted — otherwise a failed merge would strand a task in "Converting"
  with its segments gone.

## 6. Network stack

- Proxy schemes: http, https, socks4, socks4a, socks5, socks5h — the
  scheme is preserved so the right dialer runs; credentials supported; a
  bounded pool caches proxy clients with LRU eviction; DNS results cache
  for 6 hours.
- TLS impersonation: requests can route through bogdanfinn/tls-client
  with a coherent webview identity (chrome_150, firefox_148, firefox_135,
  safari_16_0, safari_ios_26_0) — JA3/JA4 profile + matching User-Agent +
  header set, one identity chosen at random per install. Extensions opt a
  URL in via the reserved `Miru-TLS-Profile` header, which the proxy
  strips before the upstream fetch.
- **Boundary rule**: the app proxies what an extension hands it; working
  out a proxyable URL for a TLS-fingerprinted or token-gated source is the
  extension developer's responsibility.

## 7. Tracking & metadata

- **AniList**: OAuth runs in the Go backend, which captures the token
  fragment from a cookie; the app polls for the profile after launching
  the browser. Collection browsing splits by anime/manga and status;
  progress/score edit inline; trackers can be unlinked.
- **TMDB**: queried lazily on detail pages for genres, runtime, poster
  and cast; a movie-vs-TV misclassification retries with the other type.

## 8. Resume logic

Watched items store episode coordinates. On resume the saved watch URL is
matched against the current episode list first; stored indices are trusted
only while they still point at that URL, indices are bounds-checked
against a possibly-shrunk list, and a missing episode is reported as gone
rather than throwing — an extension that reorders episodes between runs
cannot resume the wrong one.

## 9. Logging & diagnostics

- All records go through `package:logging` and append to `miru.log` via
  the MiruLog listener — anything written with `dart:developer`'s `log` is
  invisible to support by design.
- Uncaught Flutter errors, platform-dispatcher errors and isolate errors
  land in a dedicated crash log; the Go server installs a per-request
  recover (bad request → HTTP 500, not a dead process) and keeps its own
  crash log for panics/fatals.
- Settings → Logging exports the Flutter log, Go log, Go crash log,
  captured crash log, or a bundle of all.
- The developer panel streams `DevLogEvent` / `DevNetworkEvent` from the
  backend: status, URL, package, duration and timestamp per request,
  colour-coded by status class, filterable per extension.

## 10. Debug tooling (debug builds only)

- `lib/main_debug.dart` initialises the marionette binding so MCP/CLI
  tooling can drive the live widget tree.
- On desktop debug builds `MiruMobilePreviewShell` renders the app in a
  412×915 phone frame: **Ctrl+Shift+P** swaps portrait/landscape,
  **Ctrl+Shift+D** bypasses the frame for full-bleed desktop breakpoints.
  The window itself is never resized or re-initialised, and
  release/profile builds never mount the shell.
- Testing convention: resize the view with
  `tester.view.physicalSize` + `devicePixelRatio` (with
  `addTearDown(tester.view.reset)`) — `binding.setSurfaceSize` does **not**
  refresh Flutter view metrics. Orientation branches use `LayoutBuilder`
  constraints, never `MediaQuery.sizeOf`.

## 11. Known limitations

- Persisted-but-unconsumed settings: TTS (novel reader), hardware
  acceleration, subtitle font size/colour, auto-play-next, auto-download,
  auto-sync tracking.
- iOS/macOS scaffolding exists; Android, Linux and Windows are the
  shipped targets.

## 12. Code generation

| Task | Command |
| --- | --- |
| Protobuf (Dart + Go) | `make gen-proto` |
| Riverpod/Freezed (single run) | `make build-runner` |
| Riverpod/Freezed (watch) | `make runner-build-watch` |
| Scriggo extension deps | `cd src/miru_core/miru-core && make gen-deps` |
| Lint | `flutter analyze --no-pub` |
| Tests | `flutter test` |

---

## 13. Release pipeline

`.github/workflows/release_alpha.yml` is tag-driven:

1. `prepare` checks out with full history (needed to diff for release notes),
   stamps the version from the tag (`tool/pubspec_from_tag.sh`), generates the
   release body (`tool/release_body.sh`) and creates the release with
   `ncipollo/release-action@v1` using `prerelease: true`.
2. `build-and-release-android` / `-windows` / `-linux` build the platform
   artifact and attach it to that same release, also with `prerelease: true`.

Every published tag therefore appears on
<https://github.com/miru-project/miru-alpha/releases> as a pre-release with
the same asset set: `app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`,
`app-x86_64-release.apk`, `Miru-Alpha-linux.tar.gz`, `Miru-Alpha-windows.zip`.

Every checkout in both workflows must use `submodules: true` — the build hook
fails with "Go module not found" when `src/miru_core/miru-core/go.mod` is
missing. `prbuild.yml` additionally publishes per-push dev artifacts through
`actions/upload-artifact`.

Toolchains are pinned in the workflow `env` block and match the README
prerequisites: Flutter `3.47.7`, Go `1.27.3`. No Rust toolchain is required —
the native layer is Go (backend shared library) and C++ (`ffmpeg_merge`).
