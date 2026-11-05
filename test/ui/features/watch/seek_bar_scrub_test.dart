import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb;
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/mobile_gesture.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/seek_bar.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:video_player/video_player.dart';

const _url = 'https://example.com/daemons';

/// [VideoPlayerNotifier] without the real controller — no platform channels.
/// Records seeks + scrub markers so the seekbar's deferred-seek contract is
/// assertable in memory.
class _RecordingVideoPlayer extends VideoPlayerNotifier {
  final seeks = <Duration>[];
  final scrubMarks = <bool>[];

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
  void seek(Duration position) {
    seeks.add(position);
    state = state.copyWith(position: position);
  }

  @override
  void setScrubbing(bool v) => scrubMarks.add(v);

  @override
  void setSpeed(double speed) => state = state.copyWith(speed: speed);
}

/// Duration stays ZERO so the overlay's fvp brightness effect never runs
/// (it demands MdkVideoPlayerPlatform, unavailable in widget tests).
class _ZeroDurationVideoPlayer extends _RecordingVideoPlayer {
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

Widget _harness(Widget child) => FTheme(
  data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
  child: MaterialApp(
    supportedLocales: FLocalizations.supportedLocales,
    localizationsDelegates: [
      I18nUtils.flutterI18nDelegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: Scaffold(body: child),
  ),
);

Future<(ProviderContainer, _RecordingVideoPlayer)> _pumpSeekBar(
  WidgetTester tester,
) async {
  final vidPr = videoPlayerProvider(null);
  final fake = _RecordingVideoPlayer();
  final container = ProviderContainer(
    overrides: [vidPr.overrideWith(() => fake)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _harness(
        Center(
          child: SizedBox(width: 300, height: 32, child: SeekBar(vidPr: vidPr)),
        ),
      ),
    ),
  );
  await tester.pump();
  return (container, fake);
}

Future<(ProviderContainer, VideoPlayerNotifierProvider)> _pumpOverlay(
  WidgetTester tester,
) async {
  final vidPr = videoPlayerProvider(null);
  final fake = _ZeroDurationVideoPlayer();
  final container = ProviderContainer(
    overrides: [vidPr.overrideWith(() => fake)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _harness(
        MobileGestureOverlay(vidPr: vidPr, child: const SizedBox.expand()),
      ),
    ),
  );
  await tester.pump();
  return (container, vidPr);
}

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);
  setUp(() {
    MiruSettings.setSettingSync(SettingKey.language, 'en');
  });

  testWidgets('seekbar drag updates locally and seeks ONCE on release', (
    tester,
  ) async {
    final (container, fake) = await _pumpSeekBar(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(mui.Slider)),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();

    // Mid-drag: nothing has hit the player — no seek, scrub session marked.
    expect(fake.seeks, isEmpty);
    expect(fake.scrubMarks, [true]);

    await gesture.up();
    await tester.pump();

    // Release: exactly one seek, and the scrub session closed.
    expect(fake.seeks.length, 1);
    expect(fake.seeks.single.inMilliseconds, greaterThan(0));
    expect(fake.scrubMarks, [true, false]);
  });

  testWidgets('hold-to-3x is inert while the chrome is up (seekbar surface)', (
    tester,
  ) async {
    final (container, vidPr) = await _pumpOverlay(tester);
    expect(container.read(vidPr).showControls, isTrue);

    final gesture = await tester.startGesture(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 700));

    // The long-press recognizer is unregistered with the chrome visible —
    // a hold on the (seekbar-bearing) surface must not warp the speed.
    expect(container.read(vidPr).speed, 1.0);

    await gesture.up();
    await tester.pump();
    expect(container.read(vidPr).speed, 1.0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hold-to-3x works on the bare video and restores on release', (
    tester,
  ) async {
    final (container, vidPr) = await _pumpOverlay(tester);
    container.read(vidPr.notifier).setShowControls(false);
    await tester.pump();

    final gesture = await tester.startGesture(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 700));
    expect(container.read(vidPr).speed, 3.0);

    await gesture.up();
    await tester.pump();
    expect(container.read(vidPr).speed, 1.0);
  });

  testWidgets('chrome flipping on mid-hold restores the rate (no stuck 3x)', (
    tester,
  ) async {
    final (container, vidPr) = await _pumpOverlay(tester);
    container.read(vidPr.notifier).setShowControls(false);
    await tester.pump();

    // Hold starts on bare video: 3x boost.
    final gesture = await tester.startGesture(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 700));
    expect(container.read(vidPr).speed, 3.0);

    // The chrome flips on mid-hold in the wild (a second-finger tap fires
    // onTap — its double-tap arena dance is out of scope here), so flip the
    // state directly: the end callback unregisters and the restore must
    // come from the disable effect.
    container.read(vidPr.notifier).setShowControls(true);
    await tester.pump();

    expect(container.read(vidPr).speed, 1.0);

    await gesture.up();
    // Leave no pending auto-hide timer behind.
    container.read(vidPr.notifier).setShowControls(false);
    await tester.pump();
  });
}
