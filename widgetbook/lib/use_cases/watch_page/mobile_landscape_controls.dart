/// Mirrors test/ui/features/watch/mobile_landscape_controls_test.dart states
/// for the catalog.
///
/// Skipped states (behaviour with no distinct visuals):
/// - skipped: 'speed chip opens the side settings on the Speed pane' and
///   'episodes button opens the side settings menu' — chip taps flip
///   notifier flags; the docked panel's open state is the SideSettingsMenu
///   use-case below.
/// - skipped: 'next advances the episode' — live: tap skip-next on the dock.

library;

import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb;
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/mobile_gesture.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/mobile_landscape_controls.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/side_settings_menu.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';
import 'package:widgetbook/widgetbook.dart';

const _url = 'https://example.com/daemons';

/// The mirrored-from-tests components of the landscape controls test.
List<WidgetbookComponent> buildMobileLandscapeControlsComponents() => [
  WidgetbookComponent(
    name: 'MobileLandscapeControls',
    useCases: [
      WidgetbookUseCase(
        name: 'Dock · playing Ep 1 of 18 (Phone landscape 915x412)',
        builder: (context) {
          final vidPr = videoPlayerProvider(null);
          return _LandscapeCanvas(
            child: _Scope(
              create: () => ProviderContainer(
                overrides: [vidPr.overrideWith(_FakeVideoPlayer.new)],
              ),
              child: MobileLandscapeControls(
                vidPr: vidPr,
                epProvider: episodeProvider(_param(episode: 0)),
                title: 'Daemons of the Shadow Realm',
                episodeName: 'Ep 1 · Dera and Hana',
                videoType: 'HLS',
                onToggleFullscreen: () {},
                onClose: () {},
              ),
            ),
          );
        },
      ),
      WidgetbookUseCase(
        name: 'Dock · mid episode, both skips armed (915x412)',
        builder: (context) {
          final vidPr = videoPlayerProvider(null);
          return _LandscapeCanvas(
            child: _Scope(
              create: () => ProviderContainer(
                overrides: [vidPr.overrideWith(_FakeVideoPlayer.new)],
              ),
              child: MobileLandscapeControls(
                vidPr: vidPr,
                epProvider: episodeProvider(_param(episode: 5)),
                title: 'Daemons of the Shadow Realm',
                episodeName: 'Ep 6 · Dera and Hana',
                videoType: 'HLS',
                onToggleFullscreen: () {},
                onClose: () {},
              ),
            ),
          );
        },
      ),
      WidgetbookUseCase(
        name: 'Dock · auto-rotation armed (915x412)',
        builder: (context) {
          final vidPr = videoPlayerProvider(null);
          return _LandscapeCanvas(
            child: _Scope(
              create: () => ProviderContainer(
                overrides: [vidPr.overrideWith(_FakeVideoPlayer.new)],
              ),
              child: MobileLandscapeControls(
                vidPr: vidPr,
                epProvider: episodeProvider(_param(episode: 0)),
                title: 'Daemons of the Shadow Realm',
                episodeName: 'Ep 1 · Dera and Hana',
                videoType: 'HLS',
                onToggleFullscreen: () {},
                onClose: () {},
                autoRotate: true,
                onToggleAutoRotate: () {},
              ),
            ),
          );
        },
      ),
      WidgetbookUseCase(
        name: 'Dock · mirror chip M1, v2 source (915x412)',
        builder: (context) {
          final vidPr = videoPlayerProvider(null);
          return _LandscapeCanvas(
            child: _Scope(
              create: () => ProviderContainer(
                overrides: [vidPr.overrideWith(_MirrorTestVideoPlayer.new)],
              ),
              child: MobileLandscapeControls(
                vidPr: vidPr,
                epProvider: episodeProvider(_param(episode: 0)),
                title: 'Daemons of the Shadow Realm',
                episodeName: 'Ep 1 · Dera and Hana',
                videoType: 'HLS',
                onToggleFullscreen: () {},
                onClose: () {},
              ),
            ),
          );
        },
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'SideSettingsMenu',
    useCases: [
      WidgetbookUseCase(
        name: 'Landscape panel · Episodes pane, 300px (915x412)',
        builder: (context) {
          final vidPr = videoPlayerProvider(null);
          return _LandscapeCanvas(
            child: _Scope(
              create: () => ProviderContainer(
                overrides: [
                  vidPr.overrideWith(_FakeVideoPlayer.new),
                  historyPageProvider.overrideWith(_FakeHistory.new),
                  downloadProvider.overrideWith(_FakeDownloads.new),
                ],
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: SideSettingsMenu(
                  vidPr: vidPr,
                  epProvdier: episodeProvider(_param(episode: 0)),
                  width: 300,
                  meta: _meta(),
                ),
              ),
            ),
          );
        },
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'MobileGestureOverlay',
    useCases: [
      // On the test's deliberately default-sized surface (its tap thirds
      // split off MediaQuery.width — in the catalog that is the live
      // workbench width). Double-tap the LEFT third to seek back 10s
      // ('-10s' burst), the RIGHT third to seek forward ('+10s'), the
      // center to play/pause.
      WidgetbookUseCase(
        name: 'Double-tap sides seek ±10s (burst) · 800x600',
        builder: (context) {
          final vidPr = videoPlayerProvider(null);
          return _GestureCanvas(
            child: _Scope(
              create: () => ProviderContainer(
                overrides: [vidPr.overrideWith(_GestureTestVideoPlayer.new)],
              ),
              child: MobileGestureOverlay(
                vidPr: vidPr,
                child: const SizedBox.expand(),
              ),
            ),
          );
        },
      ),
    ],
  ),
];

/// The landscape phone canvas (915x412 — PhoneFrame swapped) over a black
/// video-canvas backdrop.
class _LandscapeCanvas extends StatelessWidget {
  const _LandscapeCanvas({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 915,
        height: 412,
        child: ColoredBox(
          color: context.theme.colors.background,
          child: ClipRect(child: child),
        ),
      ),
    );
  }
}

/// The gesture test's surface: the test keeps the DEFAULT 800x600 size on
/// purpose (see the use-case comment).
class _GestureCanvas extends StatelessWidget {
  const _GestureCanvas({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 800,
        height: 600,
        child: ColoredBox(
          color: Colors.black,
          child: ClipRect(child: child),
        ),
      ),
    );
  }
}

/// Holds one [ProviderContainer] for the use-case's lifetime.
class _Scope extends StatefulWidget {
  const _Scope({required this.create, required this.child});

  /// Builds the use-case's [ProviderContainer] (with its overrides) once.
  final ProviderContainer Function() create;
  final Widget child;

  @override
  State<_Scope> createState() => _ScopeState();
}

class _ScopeState extends State<_Scope> {
  late final ProviderContainer _container = widget.create();

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      UncontrolledProviderScope(container: _container, child: widget.child);
}

ExtensionMeta _meta() => ExtensionMeta(
  name: 'ExampleA',
  version: '2.0.0',
  author: 't',
  license: 'MIT',
  lang: 'en',
  packageName: 'test.pkg',
  webSite: 'https://example.com',
  description: 'test provider',
  tags: const [],
  api: 'v2',
  type: ExtensionType.bangumi,
);

List<ExtensionEpisodeGroup> _episodes(int count) => [
  ExtensionEpisodeGroup(
    title: 'Season 1',
    urls: [
      for (var i = 1; i <= count; i++)
        ExtensionEpisode(name: 'Episode $i', url: '$_url/ep$i'),
    ],
  ),
];

WatchParams _param({int episode = 0, int total = 18}) => WatchParams(
  meta: _meta(),
  type: ExtensionType.bangumi,
  url: '$_url/ep${episode + 1}',
  selectedGroupIndex: 0,
  selectedEpisodeIndex: episode,
  name: 'Daemons of the Shadow Realm',
  detailImageUrl: '',
  detailUrl: _url,
  savePath: null,
  epGroup: _episodes(total),
);

/// [VideoPlayerNotifier] without the real controller — no platform
/// channels; seek / setSpeed are in-memory so the dock's controls are
/// drivable.
class _FakeVideoPlayer extends VideoPlayerNotifier {
  @override
  VideoPlayerTickState build(
    String? mediaUrl, {
    List<pb.ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    Map<String, String>? headers,
    Size? initialRatio,
    ExtensionBangumiWatchTorrent? torrent,
    String? localPath,
    pb.ExtensionWatch? v2watch,
    Map<String, String> qualityMap = const {},
  }) {
    vidController = VideoPlayerController.networkUrl(Uri.parse(_url));
    return VideoPlayerTickState(
      isPlaying: true,
      speed: 1.0,
      duration: const Duration(minutes: 24),
      showControls: true,
    );
  }

  @override
  void seek(Duration position) => state = state.copyWith(position: position);

  @override
  void setSpeed(double speed) => state = state.copyWith(speed: speed);
}

/// Fake carrying a v2 watch result: one mirror group whose only mirror IS
/// the playing URL, so the mirror chip surfaces and deep-links.
class _MirrorTestVideoPlayer extends _FakeVideoPlayer {
  @override
  VideoPlayerTickState build(
    String? mediaUrl, {
    List<pb.ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    Map<String, String>? headers,
    Size? initialRatio,
    ExtensionBangumiWatchTorrent? torrent,
    String? localPath,
    pb.ExtensionWatch? v2watch,
    Map<String, String> qualityMap = const {},
  }) {
    vidController = VideoPlayerController.networkUrl(Uri.parse(_url));
    return VideoPlayerTickState(
      isPlaying: true,
      speed: 1.0,
      duration: const Duration(minutes: 24),
      showControls: true,
      v2watch: pb.ExtensionWatch(
        groups: [
          pb.ExtensionMirrorGroup(
            title: 'HD',
            mirrors: [pb.ExtensionMirror(name: 'M1', url: _url)],
          ),
        ],
      ),
    );
  }
}

/// Gesture-overlay variant: duration stays ZERO so the overlay's fvp
/// brightness effect never runs; the double-tap seek math only needs
/// position, which the fake tracks in memory.
class _GestureTestVideoPlayer extends _FakeVideoPlayer {
  @override
  VideoPlayerTickState build(
    String? mediaUrl, {
    List<pb.ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    Map<String, String>? headers,
    Size? initialRatio,
    ExtensionBangumiWatchTorrent? torrent,
    String? localPath,
    pb.ExtensionWatch? v2watch,
    Map<String, String> qualityMap = const {},
  }) {
    vidController = VideoPlayerController.networkUrl(Uri.parse(_url));
    return VideoPlayerTickState(
      isPlaying: true,
      speed: 1.0,
      duration: Duration.zero,
      showControls: true,
    );
  }
}

/// [DownloadNotifier] without the database/gRPC init.
class _FakeDownloads extends DownloadNotifier {
  @override
  AsyncValue<DownloadState> build() =>
      AsyncData(DownloadState(history: const [], active: const []));
}

/// [HistoryPageNotifier] without the database.
class _FakeHistory extends HistoryPageNotifier {
  @override
  HistoryPageState build() =>
      HistoryPageState(history: const [], filteredHistory: const []);
}
