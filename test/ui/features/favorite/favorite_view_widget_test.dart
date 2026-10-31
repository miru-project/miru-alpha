import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/ui/core/grid_view/miru_grid_tile.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/ui/features/favorite/views/favorite_view.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:forui/forui.dart';

class _FakeFavoritePageNotifier extends FavoritePageNotifier {
  _FakeFavoritePageNotifier(this._state);
  final FavoritePageState _state;

  @override
  FavoritePageState build() => _state;
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

void main() {
  testWidgets('FavoriteView renders correctly', (WidgetTester tester) async {
    final favoriteState = FavoritePageState(
      favorites: const [],
      favoriteGroups: const [],
      filteredFavorites: const [],
      selectedFavoriteGroups: const [],
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
        favoritePageProvider.overrideWith(
          () => _FakeFavoritePageNotifier(favoriteState),
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
                    builder: (context, state) => const FavoriteView(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // FavoriteView should build without throwing.
    expect(find.byType(FavoriteView), findsOneWidget);
  });

  testWidgets('FavoriteView shows favorites in a grid', (
    WidgetTester tester,
  ) async {
    final favorites = [
      Favorite(
        package: 'test.package',
        url: 'https://example.com/1',
        type: 'manga',
        title: 'Test Favorite',
        date: DateTime.now(),
      ),
    ];
    final favoriteState = FavoritePageState(
      favorites: favorites,
      favoriteGroups: const [],
      filteredFavorites: favorites,
      selectedFavoriteGroups: const [],
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
        favoritePageProvider.overrideWith(
          () => _FakeFavoritePageNotifier(favoriteState),
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
                    builder: (context, state) => const FavoriteView(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(FavoriteView), findsOneWidget);
    expect(find.byType(MiruMobileTile), findsOneWidget);
  });
}
