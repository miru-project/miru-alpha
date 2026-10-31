import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_video_viewport.dart';
import 'package:video_player/video_player.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb;
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_tile.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_error_kind.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_error_state.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_header_section.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_loading_state.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_loading_viewport.dart';
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

WatchParams _param() => WatchParams(
  meta: _meta(),
  type: ExtensionType.bangumi,
  url: '$_url/ep1',
  selectedGroupIndex: 0,
  selectedEpisodeIndex: 0,
  name: 'Daemons of the Shadow Realm',
  detailImageUrl: '',
  detailUrl: _url,
  savePath: null,
  epGroup: _episodes(5),
);

pb.ExtensionWatch _v2watch() => pb.ExtensionWatch(
  groups: [
    pb.ExtensionMirrorGroup(
      title: 'Vidsrc',
      mirrors: [
        pb.ExtensionMirror(name: 'Mirror A', url: '$_url/mirror-a'),
        pb.ExtensionMirror(name: 'Mirror B', url: '$_url/mirror-b'),
      ],
    ),
  ],
  defaultGroup: 'Vidsrc',
  defaultIndex: 0,
);

/// [DownloadNotifier] without the database/gRPC init — the tile only reads
/// preparing/active lists.
class _FakeDownloads extends DownloadNotifier {
  @override
  AsyncValue<DownloadState> build() =>
      AsyncData(DownloadState(history: const [], active: const []));
}

/// [HistoryPageNotifier] without the database — the body only filters the
/// history list for the episode rows' progress marks.
class _FakeHistory extends HistoryPageNotifier {
  @override
  HistoryPageState build() =>
      HistoryPageState(history: const [], filteredHistory: const []);
}

Widget _harness(Widget child) => FTheme(
  data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
  child: MaterialApp(
    // The .i18n extension resolves translations through the ROOT
    // navigator's context (I18nUtils) — without this key every key renders
    // raw and the Ahem test font blows the constraints.
    navigatorKey: RouterUtil.rootNavigatorKey,
    supportedLocales: FLocalizations.supportedLocales,
    localizationsDelegates: [
      I18nUtils.flutterI18nDelegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: Scaffold(body: child),
  ),
);

Future<(ProviderContainer, EpisodeNotifierProvider)> _pump(
  WidgetTester tester, {
  required Widget Function(EpisodeNotifierProvider epProvider) child,
}) async {
  final param = _param();
  final epProvider = episodeProvider(param);
  final container = ProviderContainer(
    overrides: [
      downloadProvider.overrideWith(() => _FakeDownloads()),
      historyPageProvider.overrideWith(() => _FakeHistory()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _harness(child(epProvider)),
    ),
  );
  await tester.pump();
  return (container, epProvider);
}

/// [VideoPlayerNotifier] whose state carries a video-request error (the
/// fvp 403 path) — [changeVideoQuality] records the re-request and clears
/// the error, standing in for a successful re-open.
class _FakeErrorVideoPlayer extends VideoPlayerNotifier {
  final requests = <String>[];

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
    // Duration ZERO: the gesture overlay's fvp brightness effect fires
    // whenever duration > 0 and demands MdkVideoPlayerPlatform — the
    // documented test seam (see the skill's widget-test-harness traps).
    return VideoPlayerTickState(
      // see the duration-zero note above
      v2watch: pb.ExtensionWatch(
        groups: [
          pb.ExtensionMirrorGroup(
            title: 'S1',
            mirrors: [
              pb.ExtensionMirror(name: 'Mirror A', url: '$_url/mirror-a'),
            ],
          ),
        ],
      ),
      playerError: 'Video muzzle: open failed: 403 Forbidden',
    );
  }

  @override
  void changeVideoQuality(String url) {
    requests.add(url);
    state = state.copyWith(clearPlayerError: true);
  }
}

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);
  setUp(() async {
    MiruSettings.setSettingSync(SettingKey.language, 'en');
  });

  group('WatchLoadingState', () {
    testWidgets('renders the loading viewport, status header and resolving '
        'episode list', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await _pump(
        tester,
        child: (epProvider) => WatchLoadingState(
          param: _param(),
          epProvider: epProvider,
          onBack: () {},
        ),
      );

      // Viewport telemetry (known metadata, no percent faked).
      // The 2026-10-30 loading overlay: the glass resolver disc carries the
      // extension's identity, the bottom band is a bare forui progress
      // track — the pill, the time row and the settings chips are gone.
      expect(find.text('Loading video...'), findsOneWidget);
      expect(find.textContaining('Resolving stream via'), findsOneWidget);
      expect(find.text('CONNECTING'), findsNothing);
      expect(find.text('00:00 / --:--'), findsNothing);
      expect(find.byType(FProgress), findsOneWidget);
      // Content body: real header + status meta + up next + tabs.
      expect(find.text('Now Loading'), findsOneWidget);
      expect(find.text('Ep 1'), findsOneWidget);
      expect(find.text('UP NEXT'), findsOneWidget);
      expect(find.text('Ep 2 · Episode 2'), findsOneWidget);
      expect(find.text('Episodes (5)'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      // The resolving row carries the loading pill + resolving subtitle;
      // the other rows stay plain (no badge).
      expect(find.text('Resolving stream...'), findsOneWidget);
      expect(find.text('Loading'), findsOneWidget);
      expect(find.text('Failed'), findsNothing);
      // No slow hint before 3s.
      expect(
        find.text(
          'Taking longer than usual — the extension bridge is still '
          'resolving.',
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('slow-bridge hint appears after 3 seconds of resolving', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await _pump(
        tester,
        child: (epProvider) => WatchLoadingState(
          param: _param(),
          epProvider: epProvider,
          onBack: () {},
        ),
      );

      await tester.pump(const Duration(seconds: 4));
      expect(
        find.textContaining('the extension bridge is still resolving'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('landscape-short surface (1000x520, still mobile layout): '
        'loading state fits without overflows', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 520));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await _pump(
        tester,
        child: (epProvider) => WatchLoadingState(
          param: _param(),
          epProvider: epProvider,
          onBack: () {},
        ),
      );

      expect(find.text('Loading video...'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('landscape-short surface (1000x520, still mobile layout): '
        'error state fits without overflows', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 520));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await _pump(
        tester,
        child: (epProvider) => WatchErrorState(
          param: _param(),
          epProvider: epProvider,
          error: WatchMirrorException(_v2watch(), Exception('gateway')),
          trace: StackTrace.current,
          onBack: () {},
          onRetry: () {},
          onSelectMirror: (_) {},
        ),
      );

      expect(find.text('Playback Interrupted'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disabled viewport shells are not tappable controls', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await _pump(
        tester,
        child: (epProvider) => WatchLoadingState(
          param: _param(),
          epProvider: epProvider,
          onBack: () {},
        ),
      );

      // The dimmed cast/shuffle/fullscreen placeholders must not be
      // interactive: an FButton would be a dead control. Scope to the
      // viewport canvas — the content body below legitimately carries
      // enabled buttons (Up Next, list controls).
      final viewportButtons = tester.widgetList<FButton>(
        find.descendant(
          of: find.byType(WatchLoadingViewport),
          matching: find.byType(FButton),
        ),
      );
      final enabledButtons = viewportButtons
          .where((b) => b.onPress != null)
          .length;
      // Only the back affordance is a real button in the loading viewport.
      expect(enabledButtons, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('WatchErrorState', () {
    testWidgets('renders the interruption card, diagnostics and failed row', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      var retries = 0;
      await _pump(
        tester,
        child: (epProvider) => WatchErrorState(
          param: _param(),
          epProvider: epProvider,
          error: Exception('HLS decrypt timeout after 8.2s'),
          trace: StackTrace.current,
          onBack: () {},
          onRetry: () => retries++,
          onSelectMirror: (_) {},
        ),
      );

      expect(find.text('Playback Interrupted'), findsOneWidget);
      expect(find.text('Could not retrieve media source.'), findsOneWidget);
      expect(find.text('Retry Connection'), findsOneWidget);
      // The dead scrubber mirrors the LOADED player's meta row (plain
      // timestamps — no bespoke "(Stream Interrupted)" suffix).
      expect(find.text('00:00 / --:--'), findsOneWidget);
      // Header status meta.
      expect(find.text('Episode 1 · Stream unavailable'), findsOneWidget);
      // The in-player diagnostics affordance (the accordion moved into the
      // error-details dialog).
      expect(find.text('Error details'), findsOneWidget);
      // The failed row: badge + row retry; other rows keep downloads.
      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      // A bare extension failure carries no mirrors — no switch control.
      expect(find.text('Switch Mirror'), findsNothing);
      expect(find.text('Select Fallback Mirror'), findsNothing);

      // Retry fires the page's watch invalidation.
      await tester.tap(find.text('Retry Connection'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(retries, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('error details dialog shows the dump and copy', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await _pump(
        tester,
        child: (epProvider) => WatchErrorState(
          param: _param(),
          epProvider: epProvider,
          error: Exception('HLS decrypt timeout after 8.2s'),
          trace: StackTrace.current,
          onBack: () {},
          onRetry: () {},
          onSelectMirror: (_) {},
        ),
      );

      await tester.tap(find.text('Error details'));
      await tester.pumpAndSettle();

      // The dialog carries the full diagnostics dump + the copy action.
      expect(find.text('Error details'), findsWidgets);
      expect(find.textContaining('HLS decrypt timeout'), findsWidgets);
      expect(find.text('Copy Log'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mirror failure surfaces Switch Mirror; picking one fires '
        'the selection', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      final picked = <String>[];
      await _pump(
        tester,
        child: (epProvider) => WatchErrorState(
          param: _param(),
          epProvider: epProvider,
          error: WatchMirrorException(_v2watch(), Exception('gateway 504')),
          trace: StackTrace.current,
          onBack: () {},
          onRetry: () {},
          onSelectMirror: picked.add,
        ),
      );

      // Only the viewport card carries the picker now (the diagnostics
      // panel moved into the error-details dialog).
      expect(find.text('Switch Mirror'), findsOneWidget);

      // Open the viewport picker and choose a mirror.
      await tester.tap(find.text('Switch Mirror'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Mirror A'), findsOneWidget);
      expect(find.text('Mirror B'), findsOneWidget);

      await tester.tap(find.text('Mirror B'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(picked, ['$_url/mirror-b']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Retry Connection uses the smaller size (user directive)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await _pump(
        tester,
        child: (epProvider) => WatchErrorState(
          param: _param(),
          epProvider: epProvider,
          error: Exception('gateway 504'),
          trace: StackTrace.current,
          onBack: () {},
          onRetry: () {},
          onSelectMirror: (_) {},
        ),
      );

      final box = tester.getSize(
        find.ancestor(
          of: find.text('Retry Connection'),
          matching: find.byType(FButton),
        ),
      );
      // The user directive: the SMALLER button size (sm) — the 40px md box
      // dwarfed the compacted card. sm stays within a compact band and
      // keeps a usable touch target.
      expect(box.height, greaterThanOrEqualTo(28));
      expect(box.height, lessThanOrEqualTo(38));
      expect(tester.takeException(), isNull);
    });
  });

  group('MobileDetailTile status variants', () {
    Detail detail() => Detail(
      title: 'Daemons',
      detailUrl: _url,
      package: 'test.pkg',
      episodes: _episodes(5),
    );

    Future<ProviderContainer> pumpTile(
      WidgetTester tester, {
      required Widget tile,
    }) async {
      final container = ProviderContainer(
        overrides: [downloadProvider.overrideWith(() => _FakeDownloads())],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: _harness(tile)),
      );
      await tester.pump();
      return container;
    }

    testWidgets('resolving row: loading pill, accent ordinal, no download', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await pumpTile(
        tester,
        tile: MobileDetailTile(
          item: _episodes(5).first.urls[0],
          idx: 0,
          position: 1,
          selectedGpIndex: 0,
          detail: detail(),
          meta: _meta(),
          detailUrl: _url,
          detailPr: null,
          history: null,
          isDownloaded: false,
          status: EpisodeTileStatus.resolving,
        ),
      );

      expect(find.text('Resolving stream...'), findsOneWidget);
      expect(find.text('Loading'), findsOneWidget);
      // The download affordance is replaced while resolving.
      expect(find.byIcon(FLucideIcons.arrowDownToLine), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('failed row: Failed badge, status detail, retry fires', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      var retries = 0;
      await pumpTile(
        tester,
        tile: MobileDetailTile(
          item: _episodes(5).first.urls[0],
          idx: 0,
          position: 1,
          selectedGpIndex: 0,
          detail: detail(),
          meta: _meta(),
          detailUrl: _url,
          detailPr: null,
          history: null,
          isDownloaded: false,
          status: EpisodeTileStatus.failed,
          statusDetail: 'Exception: gateway 504',
          onRetry: () => retries++,
        ),
      );

      expect(find.text('Failed'), findsOneWidget);
      expect(find.textContaining('gateway 504'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(retries, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('WatchHeaderSection statusMeta', () {
    testWidgets('overrides the default group · episode meta line', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      final param = _param();
      final epProvider = episodeProvider(param);
      final container = ProviderContainer(
        overrides: [downloadProvider.overrideWith(() => _FakeDownloads())],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _harness(
            WatchHeaderSection(
              showTitle: param.name,
              groupTitle: 'Season 1',
              episodeIndex: 0,
              episodeName: 'Episode 1',
              detail: Detail(
                title: param.name,
                detailUrl: param.detailUrl,
                package: param.meta.packageName,
              ),
              meta: param.meta,
              detailUrl: param.detailUrl,
              epProvider: epProvider,
              favorited: false,
              statusMeta: const Text('Custom status line'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Custom status line'), findsOneWidget);
      // The default meta line is gone.
      expect(find.text('Season 1 · Episode 1'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('watch error taxonomy', () {
    test('WatchMirrorException classifies as a video mirror error with '
        'fallback mirrors', () {
      final info = classifyWatchError(
        WatchMirrorException(_v2watch(), Exception('gateway 504')),
        StackTrace.current,
      );
      expect(info.kind, WatchErrorKind.mirror);
      // No widget context in a unit test — the label resolves to its key;
      // the localized form is asserted in the viewport test below.
      expect(info.categoryLabel, 'watch.error_mirror');
      expect(info.mirrors, hasLength(2));
      expect(info.message, contains('gateway 504'));
    });

    test('a bare extension failure classifies as an extension error carrying '
        'the stack trace', () {
      final trace = StackTrace.current;
      final info = classifyWatchError(
        Exception('extension compile failed'),
        trace,
      );
      expect(info.kind, WatchErrorKind.extension);
      expect(info.categoryLabel, 'watch.error_extension');
      expect(info.mirrors, isEmpty);
      // The diagnostics dump carries the STACK TRACE for extension errors.
      expect(info.detail, contains('extension compile failed'));
      expect(info.detail, contains('#0'));
    });

    test('video-request errors build the videoRequest variant from the '
        "engine's verbatim message", () {
      final info = WatchErrorInfo.videoRequest(
        'Video muzzle: open failed: 403 Forbidden',
      );
      expect(info.kind, WatchErrorKind.videoRequest);
      // Widget-level label assertion lives in the viewport test below.
      expect(info.categoryLabel, 'watch.error_video_request');
      expect(info.message, contains('403'));
    });
  });

  group('viewport video-request error card', () {
    testWidgets('renders the category, engine message, and retry; retry '
        're-requests the same url and clears the error', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      final vidPr = videoPlayerProvider(_url);
      final container = ProviderContainer(
        overrides: [vidPr.overrideWith(_FakeErrorVideoPlayer.new)],
      );
      addTearDown(container.dispose);
      container.listen(vidPr, (_, _) {});

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _harness(
            WatchVideoViewport(
              vidPr: vidPr,
              epProvider: episodeProvider(_param()),
              meta: _meta(),
              title: 'Daemons',
              episodeName: 'Ep 1',
              videoType: 'HLS',
              fullscreen: false,
              onToggleFullscreen: () {},
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Video request error'), findsOneWidget);
      expect(find.textContaining('403'), findsWidgets);
      expect(find.text('Playback Interrupted'), findsOneWidget);

      await tester.tap(find.text('Retry Connection'));
      await tester.pump(const Duration(milliseconds: 100));

      // Retry re-requested the SAME stream url and the healthy tick cleared
      // the card.
      final fake = container.read(vidPr.notifier) as _FakeErrorVideoPlayer;
      expect(fake.requests, [_url]);
      expect(find.text('Video request error'), findsNothing);
    });
  });
}
