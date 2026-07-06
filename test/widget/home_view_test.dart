import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/home/views/home_view.dart';
import 'package:miru_alpha/provider/home/home_view_model.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:forui/forui.dart';

class _FakeHomeViewModel extends HomeViewModel {
  _FakeHomeViewModel(this._state);
  final HomeViewState _state;

  @override
  HomeViewState build() => _state;
}

class _FakeFavoritePageNotifier extends FavoritePageNotifier {
  _FakeFavoritePageNotifier(this._state);
  final FavoritePageState _state;

  @override
  FavoritePageState build() => _state;
}

class _FakeHistoryPageNotifier extends HistoryPageNotifier {
  _FakeHistoryPageNotifier(this._state);
  final HistoryPageState _state;

  @override
  HistoryPageState build() => _state;
}

class _FakeDownloadNotifier extends DownloadNotifier {
  _FakeDownloadNotifier(this._state);
  final AsyncValue<DownloadState> _state;

  @override
  AsyncValue<DownloadState> build() => _state;
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

void main() {
  testWidgets('HomeView renders correctly', (WidgetTester tester) async {
    final homeState = HomeViewState(
      favorites: const [],
      history: const [],
      downloads: const [],
      selectedTab: 0,
    );
    final favoriteState = FavoritePageState(
      favorites: const [],
      favoriteGroups: const [],
      filteredFavorites: const [],
      selectedFavoriteGroups: const [],
    );
    final historyState = HistoryPageState(
      history: const [],
      filteredHistory: const [],
    );
    final downloadState = AsyncData(DownloadState(
      history: const [],
      active: const [],
      page: 1,
      hasMore: true,
    ));
    final appState = ApplicationState(
      themeText: 'light',
      accentColor: AccentColors.zinc,
      themeData: ThemeUtils.getThemeData(FThemes.zinc.light),
      themeMode: ThemeMode.system,
      language: 'en',
    );

    final container = ProviderContainer(
      overrides: [
        homeViewModelProvider.overrideWith(() => _FakeHomeViewModel(homeState)),
        favoritePageProvider.overrideWith(() => _FakeFavoritePageNotifier(favoriteState)),
        historyPageProvider.overrideWith(() => _FakeHistoryPageNotifier(historyState)),
        downloadProvider.overrideWith(() => _FakeDownloadNotifier(downloadState)),
        applicationControllerProvider.overrideWith(() => _FakeApplicationController(appState)),
      ],
    );

    addTearDown(container.dispose);

    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: FTheme(
          data: ThemeUtils.getThemeData(FThemes.zinc.light),
          child: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: MaterialApp.router(
              routerConfig: GoRouter(
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) => const HomeView(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the HomeView renders
    expect(find.byType(HomeView), findsOneWidget);
    expect(find.byType(HomeViewDesktop), findsOneWidget);
  });
}