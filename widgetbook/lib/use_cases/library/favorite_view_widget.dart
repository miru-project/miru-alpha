/// Mirrors test/ui/features/favorite/favorite_view_widget_test.dart states
/// for the catalog.
///
/// The extension list is left at its default (empty) build exactly like the
/// test, so a tile's subtitle renders the "package not found" raw key —
/// expected without delegates. Long-press opens the remove sheet, tap is a
/// no-op for a missing extension — both interactive in the catalog. i18n
/// keys render raw here (expected).
library;

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/ui/features/favorite/views/favorite_view.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

WidgetbookComponent buildFavoriteViewComponent() {
  return WidgetbookComponent(
    name: 'FavoriteView',
    useCases: [
      WidgetbookUseCase(name: 'Empty — no favorites', builder: _emptyView),
      WidgetbookUseCase(
        name: 'Grid — one favorite tile (long-press for actions)',
        builder: _oneFavorite,
      ),
    ],
  );
}

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

ApplicationState _appState() => ApplicationState(
  themeText: 'light',
  baseColor: 'zinc',
  primaryColor: 'zinc',
  themeData: ThemeUtils.getThemeData(MiruThemes.zinc.light),
  themeMode: ThemeMode.system,
  language: 'en',
);

/// The test's pump: width 400 keeps the mobile branch below the lg
/// breakpoint — [PhoneFrame] pins it.
Widget _favoriteView(BuildContext context, FavoritePageState state) {
  final container = ProviderContainer(
    overrides: [
      favoritePageProvider.overrideWith(() => _FakeFavoritePageNotifier(state)),
      applicationControllerProvider.overrideWith(
        () => _FakeApplicationController(_appState()),
      ),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: PhoneFrame(
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
  );
}

FavoritePageState _stateFor(List<Favorite> favorites) => FavoritePageState(
  favorites: favorites,
  favoriteGroups: const [],
  filteredFavorites: favorites,
  selectedFavoriteGroups: const [],
);

Widget _emptyView(BuildContext context) =>
    _favoriteView(context, _stateFor(const []));

Widget _oneFavorite(BuildContext context) {
  final favorites = [
    Favorite(
      package: 'test.package',
      url: 'https://example.com/1',
      type: 'manga',
      title: 'Test Favorite',
      date: DateTime.now(),
    ),
  ];
  return _favoriteView(context, _stateFor(favorites));
}
