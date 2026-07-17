import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/ui/core/grid_view/miru_grid_tile.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/ui/features/history/views/history_view.dart';
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

void main() {
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
}
