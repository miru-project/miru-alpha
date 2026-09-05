import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/ui/core/grid_view/miru_grid_tile.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/ui/features/history/views/history_view.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:forui/forui.dart';

class _FakeHistoryPageNotifier extends HistoryPageNotifier {
  _FakeHistoryPageNotifier(this._state);
  final HistoryPageState _state;

  @override
  HistoryPageState build() => _state;
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

class _FakeExtensionPageNotifier extends ExtensionPageNotifier {
  _FakeExtensionPageNotifier(this._state);
  final ExtensionPageModel _state;

  @override
  ExtensionPageModel build() => _state;
}

ApplicationState _appState() => ApplicationState(
  themeText: 'light',
  baseColor: 'zinc',
  primaryColor: 'zinc',
  themeData: ThemeUtils.getThemeData(MiruThemes.zinc.light),
  themeMode: ThemeMode.system,
  language: 'en',
);

History _history(int id, String title) => History(
  package: 'missing.pkg',
  url: 'https://episode/$id',
  detailUrl: 'https://detail/$id',
  type: 'bangumi',
  episodeGroupId: 0,
  episodeId: 0,
  title: title,
  episodeTitle: 'EP $id',
  progress: 50,
  totalProgress: 100,
  date: DateTime(2026, 1, 1),
);

/// Pumps [HistoryView] with [items]. The extension list is deliberately empty
/// so the resume path is exercised the way it fails in practice: a history row
/// that outlived its extension.
Future<void> pumpHistory(
  WidgetTester tester, {
  required List<History> items,
}) async {
  final container = ProviderContainer(
    overrides: [
      historyPageProvider.overrideWith(
        () => _FakeHistoryPageNotifier(
          HistoryPageState(history: items, filteredHistory: items),
        ),
      ),
      extensionPageProvider.overrideWith(
        () => _FakeExtensionPageNotifier(
          ExtensionPageModel(
            fetchedRepo: const [],
            extensionList: const [],
            installedPackages: const [],
            metaData: const [],
            sourceIndex: 0,
          ),
        ),
      ),
      applicationControllerProvider.overrideWith(
        () => _FakeApplicationController(_appState()),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.binding.setSurfaceSize(const Size(400, 900));
  addTearDown(() async => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: FTheme(
        data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HistoryView(),
              ),
              GoRoute(
                path: '/watch',
                builder: (context, state) => const SizedBox(),
              ),
              GoRoute(
                path: '/search/single/detail',
                builder: (context, state) => const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);

  testWidgets('HistoryView renders correctly', (WidgetTester tester) async {
    final historyState = HistoryPageState(
      history: const [],
      filteredHistory: const [],
    );

    final appState = ApplicationState(
      themeText: 'light',
      baseColor: 'zinc',
      primaryColor: 'zinc',
      themeData: ThemeUtils.getThemeData(MiruThemes.zinc.light),
      themeMode: ThemeMode.system,
      language: 'en',
    );

    final container = ProviderContainer(
      overrides: [
        historyPageProvider.overrideWith(
          () => _FakeHistoryPageNotifier(historyState),
        ),
        applicationControllerProvider.overrideWith(
          () => _FakeApplicationController(appState),
        ),
      ],
    );

    addTearDown(container.dispose);

    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: FTheme(
          data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
          child: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: MaterialApp.router(
              routerConfig: GoRouter(
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) => const HistoryView(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // HistoryView should build without throwing.
    expect(find.byType(HistoryView), findsOneWidget);
  });

  testWidgets('HistoryView shows histories in a grid', (
    WidgetTester tester,
  ) async {
    final histories = [
      History(
        package: 'test.package',
        url: 'https://example.com/1',
        detailUrl: 'https://example.com/1',
        type: 'manga',
        episodeGroupId: 0,
        episodeId: 0,
        title: 'Test History',
        episodeTitle: 'Ep 1',
        progress: 5,
        totalProgress: 10,
        date: DateTime.now(),
      ),
    ];
    final historyState = HistoryPageState(
      history: histories,
      filteredHistory: histories,
    );

    final appState = ApplicationState(
      themeText: 'light',
      baseColor: 'zinc',
      primaryColor: 'zinc',
      themeData: ThemeUtils.getThemeData(MiruThemes.zinc.light),
      themeMode: ThemeMode.system,
      language: 'en',
    );

    final container = ProviderContainer(
      overrides: [
        historyPageProvider.overrideWith(
          () => _FakeHistoryPageNotifier(historyState),
        ),
        applicationControllerProvider.overrideWith(
          () => _FakeApplicationController(appState),
        ),
      ],
    );

    addTearDown(container.dispose);

    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: FTheme(
          data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
          child: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: MaterialApp.router(
              routerConfig: GoRouter(
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) => const HistoryView(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HistoryView), findsOneWidget);
    expect(find.byType(MiruMobileTile), findsOneWidget);
  });

  testWidgets('long press offers watch, detail and delete', (tester) async {
    await pumpHistory(tester, items: [_history(1, 'Episode One')]);

    await tester.longPress(find.byType(MiruMobileTile));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('history_tools.watch'), findsOneWidget);
    expect(find.text('history_tools.go_to_detail'), findsOneWidget);
    expect(find.text('common.delete'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a row whose extension is gone does not crash', (
    tester,
  ) async {
    await pumpHistory(tester, items: [_history(1, 'Episode One')]);

    // Tap goes straight to the watch session, which must resolve the extension
    // first. The code this replaced called .first on an empty match list and
    // threw instead of reporting.
    await tester.tap(find.byType(MiruMobileTile));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.byType(MiruMobileTile), findsOneWidget);
  });
}
