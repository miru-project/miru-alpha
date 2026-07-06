import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/favorite/views/favorite_view.dart';
import 'package:miru_alpha/ui/features/favorite/view_models/favorite_view_model.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:forui/forui.dart';

class _FakeFavoriteViewModel extends FavoriteViewModel {
  _FakeFavoriteViewModel(this._state);
  final FavoriteViewState _state;

  @override
  Future<FavoriteViewState> build() => Future.value(_state);
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

void main() {
  testWidgets('FavoriteView renders correctly', (WidgetTester tester) async {
    final favoriteState = FavoriteViewState(
      groups: const [],
      favorites: const [],
    );

    final appState = ApplicationState(
      themeText: 'light',
      accentColor: AccentColors.zinc,
      themeData: ThemeUtils.getThemeData(FThemes.zinc.light),
      themeMode: ThemeMode.system,
      language: 'en',
    );

    final container = ProviderContainer(
      overrides: [
        favoriteViewModelProvider.overrideWith(() => _FakeFavoriteViewModel(favoriteState)),
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
}
