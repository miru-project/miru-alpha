import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb;
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/mobile_gesture.dart';
import 'package:video_player/video_player.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/mobile_landscape_controls.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/player_overlay_atoms.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/side_settings_menu.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

const _url = 'https://example.com/daemons';

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

/// [VideoPlayerNotifier] without the real controller — no platform channels;
/// seek / setSpeed are in-memory so the dock's controls are drivable.
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
  }) {
    // The gesture overlay's brightness effect reads `videoPlayerController`
    // once the fake reports a duration — construct (never initialize) the
    // controller so no platform channel is touched (same seam as the
    // watch-page test fake).
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
/// brightness effect never runs (it demands MdkVideoPlayerPlatform, which a
/// widget test cannot provide). The double-tap seek math only needs
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

/// Landscape phone surface (below forui's lg breakpoint => mobile layout).
const _landscape = Size(851, 394);

Widget _harness(Widget child) => FTheme(
  data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
  child: MaterialApp(
    navigatorKey: RouterUtil.rootNavigatorKey,
    supportedLocales: FLocalizations.supportedLocales,
    localizationsDelegates: [
      I18nUtils.flutterI18nDelegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: Scaffold(body: child),
  ),
);

Future<
  (ProviderContainer, VideoPlayerNotifierProvider, EpisodeNotifierProvider)
>
_pumpControls(
  WidgetTester tester, {
  int episode = 0,
  _FakeVideoPlayer? fake,
  bool autoRotate = false,
  VoidCallback? onToggleAutoRotate,
}) async {
  final vidPr = videoPlayerProvider(null);
  final epProvider = episodeProvider(_param(episode: episode));
  final container = ProviderContainer(
    overrides: [vidPr.overrideWith(() => fake ?? _FakeVideoPlayer())],
  );
  addTearDown(container.dispose);

  await tester.binding.setSurfaceSize(_landscape);
  addTearDown(() async => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _harness(
        MobileLandscapeControls(
          vidPr: vidPr,
          epProvider: epProvider,
          title: 'Daemons of the Shadow Realm',
          episodeName: 'Ep 1 · Dera and Hana',
          videoType: 'HLS',
          onToggleFullscreen: () {},
          onClose: () {},
          autoRotate: autoRotate,
          onToggleAutoRotate: onToggleAutoRotate ?? () {},
        ),
      ),
    ),
  );
  // first frame mounts over the generated-notifier override
  await tester.pump();
  return (container, vidPr, epProvider);
}

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);
  setUp(() async {
    MiruSettings.setSettingSync(SettingKey.language, 'en');
  });

  testWidgets('renders the landscape dock at phone-landscape size', (
    tester,
  ) async {
    await _pumpControls(tester);

    // Portrait-parity header stack + episode line.
    expect(find.text('Now Playing'), findsOneWidget);
    expect(find.text('Daemons of the Shadow Realm'), findsOneWidget);
    expect(find.text('Ep 1 · Dera and Hana'), findsOneWidget);
    expect(find.text('Episodes'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    // The meta row's always-present speed chip (deep-links to the Speed pane).
    expect(find.text('1.0x'), findsOneWidget);
    expect(find.byIcon(FLucideIcons.minimize), findsOneWidget);
    // The lock retired from this header — the auto-rotation toggle (default
    // off) sits in its slot.
    expect(find.byIcon(FLucideIcons.lock), findsNothing);
    expect(find.byType(PlayerAutoRotateButton), findsOneWidget);
    expect(find.byIcon(FLucideIcons.cast), findsOneWidget);
    // The skip controls paint runtime-extracted glyphs (plain-icon fallback
    // while extraction is in flight), so tests target the stable keys.
    expect(find.byKey(const ValueKey('skip-prev')), findsOneWidget);
    expect(find.byKey(const ValueKey('skip-next')), findsOneWidget);

    // Audit fix 1: circle buttons keep a >=44px touch box.
    final rotateBox = tester.getSize(find.byType(PlayerAutoRotateButton));
    expect(rotateBox.width, greaterThanOrEqualTo(44));
    expect(rotateBox.height, greaterThanOrEqualTo(44));

    expect(tester.takeException(), isNull);
  });

  testWidgets('speed chip opens the side settings on the Speed pane', (
    tester,
  ) async {
    final (container, vidPr, _) = await _pumpControls(tester);

    expect(container.read(vidPr).showSettings, isFalse);
    // baseTab 1 (Episodes first), no mirrors: resolution 1 · subtitle 2 ·
    // speed 3.
    await tester.tap(find.text('1.0x'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(container.read(vidPr).showSettings, isTrue);
    expect(container.read(vidPr).settingsTab, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mirror chip deep-links into the docked panel', (tester) async {
    final fake = _MirrorTestVideoPlayer();
    final (container, vidPr, _) = await _pumpControls(tester, fake: fake);

    // The active mirror's name surfaces as a chip; tapping lands on the
    // Mirrors pane (baseTab when mirrors exist).
    expect(find.text('M1'), findsOneWidget);
    await tester.tap(find.text('M1'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(container.read(vidPr).showSettings, isTrue);
    expect(container.read(vidPr).settingsTab, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('episodes button opens the side settings menu', (tester) async {
    final (container, vidPr, _) = await _pumpControls(tester);

    expect(container.read(vidPr).showSettings, isFalse);
    await tester.tap(find.text('Episodes'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(container.read(vidPr).showSettings, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('auto-rotation toggle starts off and flips on tap', (
    tester,
  ) async {
    var toggles = 0;
    await _pumpControls(tester, onToggleAutoRotate: () => toggles++);

    expect(find.byType(PlayerAutoRotateButton), findsOneWidget);
    await tester.tap(find.byType(PlayerAutoRotateButton));
    await tester.pump(const Duration(milliseconds: 300));

    expect(toggles, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('center prev is disabled on the first episode, next advances', (
    tester,
  ) async {
    final (container, _, epProvider) = await _pumpControls(tester);

    final prevButton = tester.widget<FButton>(
      find.descendant(
        of: find.byKey(const ValueKey('skip-prev')),
        matching: find.byType(FButton),
      ),
    );
    expect(prevButton.onPress, isNull);

    await tester.tap(find.byKey(const ValueKey('skip-next')));
    // Let the 500ms skip-jog settle so teardown ends with no live ticker.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 100));

    expect(container.read(epProvider).selectedEpisodeIndex, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('landscape panel: group browse + individual episode selection', (
    tester,
  ) async {
    final vidPr = videoPlayerProvider(null);
    final epProvider = episodeProvider(_param(episode: 0));
    final container = ProviderContainer(
      overrides: [vidPr.overrideWith(() => _FakeVideoPlayer())],
    );
    addTearDown(container.dispose);

    await tester.binding.setSurfaceSize(_landscape);
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _harness(
          SideSettingsMenu(
            vidPr: vidPr,
            epProvdier: epProvider,
            width: 300,
            meta: _meta(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    // Group switcher + the current group's full episode list render with
    // human labels (bare backend names never leak through).
    expect(find.text('Season 1'), findsOneWidget);
    expect(find.text('Episode 1'), findsOneWidget);
    expect(find.text('Episode 3'), findsOneWidget);

    // Picking an episode loads it and dismisses the panel (the pane's
    // onClose toggles showSettings — the fake's initial value is false).
    await tester.tap(find.text('Episode 3'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(container.read(epProvider).selectedEpisodeIndex, 2);
    expect(container.read(vidPr).showSettings, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('double-tap sides seek ±10s and burst the animated time', (
    tester,
  ) async {
    final vidPr = videoPlayerProvider(null);
    final container = ProviderContainer(
      overrides: [vidPr.overrideWith(() => _GestureTestVideoPlayer())],
    );
    addTearDown(container.dispose);

    // NOTE: deliberately on the DEFAULT 800x600 surface — `setSurfaceSize`
    // does not propagate into the overlay's MediaQuery in this harness, and
    // the handler splits thirds off MediaQuery.width. Tap targets are
    // computed from the same 800px width the overlay sees.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _harness(
          MobileGestureOverlay(vidPr: vidPr, child: const SizedBox.expand()),
        ),
      ),
    );
    await tester.pump();

    // Right third (> 800*2/3 = 533.3): seek +10s and burst "+10s".
    await tester.tapAt(const Offset(600, 300));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(const Offset(600, 300));
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('+10s'), findsOneWidget);
    expect(container.read(vidPr).position, const Duration(seconds: 10));

    // The burst fades out after its 700ms run.
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('+10s'), findsNothing);

    // Left third (< 800/3 = 266.7): back 10s with the "-10s" burst.
    await tester.tapAt(const Offset(200, 300));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(const Offset(200, 300));
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('-10s'), findsOneWidget);
    // Seeks from the CURRENT position (10s after the right double-tap):
    // 10s - 10s = back to zero, proving the relative seek, not an absolute.
    expect(container.read(vidPr).position, Duration.zero);
    expect(tester.takeException(), isNull);
  });
}
