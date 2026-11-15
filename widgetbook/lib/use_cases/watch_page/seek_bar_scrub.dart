/// Mirrors test/ui/features/watch/seek_bar_scrub_test.dart states for the
/// catalog.
///
/// Skipped states (behaviour with no distinct visuals):
/// - skipped: 'seekbar drag updates locally and seeks ONCE on release' —
///   live here: drag the line, release, and the fake's single seek lands.
/// - skipped: 'hold-to-3x is inert while the chrome is up' and 'chrome
///   flipping on mid-hold restores the rate' — notifier-speed behaviour;
///   the bare-surface use-case is the one representative surface.
/// - skipped: horizontal-drag seek preview ('M:SS / 24:00' outline text) —
///   transient gesture feedback; drag the overlay surface to see it.

library;

import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb;
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/mobile_gesture.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/seek_bar.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

const _url = 'https://example.com/daemons';

/// The mirrored-from-tests components of the seek bar scrub test.
List<WidgetbookComponent> buildSeekBarScrubComponents() => [
  WidgetbookComponent(
    name: 'SeekBar',
    useCases: [
      WidgetbookUseCase(
        name: 'At rest · slim 3px line (300x32)',
        builder: (context) {
          final vidPr = videoPlayerProvider(null);
          return catalogFrame(
            _Scope(
              create: () => ProviderContainer(
                overrides: [vidPr.overrideWith(_FakeScrubPlayer.new)],
              ),
              child: SizedBox(
                width: 300,
                height: 32,
                child: SeekBar(vidPr: vidPr),
              ),
            ),
          );
        },
      ),
      WidgetbookUseCase(
        name: 'Mid-video position · 12:00 / 24:00',
        builder: (context) {
          final vidPr = videoPlayerProvider(null);
          return catalogFrame(
            _Scope(
              create: () => ProviderContainer(
                overrides: [
                  vidPr.overrideWith(
                    () => _FakeScrubPlayer(
                      initialPosition: const Duration(minutes: 12),
                    ),
                  ),
                ],
              ),
              child: SizedBox(
                width: 300,
                height: 32,
                child: SeekBar(vidPr: vidPr),
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
      // The gesture surface: bare video placeholder at the test's deliberate
      // 800x600 (its tap thirds split off MediaQuery.width — in the catalog
      // that is the live workbench width). Double-tap left/right thirds to
      // seek ±10s with the burst; hold for 3x; vertical edges drag
      // brightness/volume (plugin answers absent on the desktop shell).
      WidgetbookUseCase(
        name: 'Bare surface · gestures armed (800x600)',
        builder: (context) {
          final vidPr = videoPlayerProvider(null);
          return _Canvas(
            size: const Size(800, 600),
            child: _Scope(
              create: () => ProviderContainer(
                overrides: [vidPr.overrideWith(_ZeroDurationPlayer.new)],
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

/// A phone-sized canvas with an explicit size (mirrors setSurfaceSize).
class _Canvas extends StatelessWidget {
  const _Canvas({required this.size, required this.child});

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: ColoredBox(
          color: context.theme.colors.background,
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

/// [VideoPlayerNotifier] without the real controller — serves playback
/// state in memory; duration stays ZERO so the overlay's fvp brightness
/// effect never runs (it demands MdkVideoPlayerPlatform, unavailable
/// outside the app).
class _ZeroDurationPlayer extends VideoPlayerNotifier {
  _ZeroDurationPlayer();

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

  @override
  void seek(Duration position) => state = state.copyWith(position: position);

  @override
  void setSpeed(double speed) => state = state.copyWith(speed: speed);
}

/// The seek bar's fake: 24-minute stream, seek + scrub marks in memory.
class _FakeScrubPlayer extends _ZeroDurationPlayer {
  _FakeScrubPlayer({this.initialPosition = Duration.zero});

  /// Shadows nothing: the notifier's `position` getter stays intact.
  final Duration initialPosition;

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
      position: initialPosition,
      showControls: true,
    );
  }
}
