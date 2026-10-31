import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb;
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_error_state.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_loading_state.dart';
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
  api: '2',
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
      title: 'Server 1',
      mirrors: [
        pb.ExtensionMirror(name: 'Mirror A', url: '$_url/mirror-a'),
        pb.ExtensionMirror(name: 'Mirror B', url: '$_url/mirror-b'),
      ],
    ),
  ],
  defaultGroup: 'Server 1',
  defaultIndex: 0,
);

class _FakeDownloads extends DownloadNotifier {
  @override
  AsyncValue<DownloadState> build() =>
      AsyncData(DownloadState(history: const [], active: const []));
}

class _FakeHistory extends HistoryPageNotifier {
  @override
  HistoryPageState build() =>
      HistoryPageState(history: const [], filteredHistory: const []);
}

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

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);
  setUp(() async {
    MiruSettings.setSettingSync(SettingKey.language, 'en');
  });

  // Every error/loading surface x every shape the app really renders in —
  // each cell asserts ZERO layout exceptions (the rule-28 layout bar).
  const surfaces = <String, Size>{
    'small-phone': Size(320, 700),
    'phone': Size(360, 844),
    'phone-tall': Size(412, 915),
    'landscape-short': Size(1000, 520),
    'landscape-phone': Size(915, 412),
  };

  for (final entry in surfaces.entries) {
    group('layout matrix ${entry.key} ${entry.value}', () {
      testWidgets('loading state: no layout exceptions', (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = entry.value;
        addTearDown(tester.view.reset);

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
            child: _harness(
              WatchLoadingState(
                param: param,
                epProvider: epProvider,
                onBack: () {},
              ),
            ),
          ),
        );
        await tester.pump();
        // Past the 3s slow-bridge threshold: the hint appears too.
        await tester.pump(const Duration(seconds: 4));

        // The 2026-10-30 overlay: identity copy + the forui track; the
        // 4s pump also proves the animated shimmer/ticker frames stay
        // exception-free.
        expect(find.text('Loading video...'), findsOneWidget);
        expect(find.byType(FProgress), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('error state (mirror failure): no layout exceptions', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = entry.value;
        addTearDown(tester.view.reset);
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
            child: _harness(
              WatchErrorState(
                param: param,
                epProvider: epProvider,
                error: WatchMirrorException(
                  _v2watch(),
                  Exception('gateway 504'),
                ),
                trace: StackTrace.current,
                onBack: () {},
                onRetry: () {},
                onSelectMirror: (_) {},
              ),
            ),
          ),
        );
        await tester.pump();
        // Open the diagnostics accordion: the mono dump + actions row is the
        // densest surface in the error body.
        expect(find.text('Playback Interrupted'), findsOneWidget);
        final err = tester.takeException();
        expect(err, isNull);
      });

      testWidgets('error state (plain failure + long message): no layout '
          'exceptions', (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = entry.value;
        addTearDown(tester.view.reset);
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
            child: _harness(
              WatchErrorState(
                param: param,
                epProvider: epProvider,
                error: Exception(
                  'gRPC Error (code: 2, UNKNOWN): Js exception:stack: Error: '
                  'gateway 504: mirror resolve timeout at mirror '
                  '(example.watchfail.v2.js:62:9(3)) with a very long '
                  'trailing explanation that wraps across several lines',
                ),
                trace: StackTrace.current,
                onBack: () {},
                onRetry: () {},
                onSelectMirror: (_) {},
              ),
            ),
          ),
        );
        await tester.pump();
        final landscape = entry.value.aspectRatio > 1;
        if (!landscape) {
          // Portrait: the in-player 'Error details' ghost button pops the
          // diagnostics dialog (full dump + copy) — exercise it at every
          // phone shape.
          await tester.tap(find.text('Error details'));
          await tester.pumpAndSettle();
          expect(find.byType(FDialog), findsOneWidget);
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      });
    });
  }
}
