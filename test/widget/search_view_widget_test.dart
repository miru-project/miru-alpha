import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/search/views/search_view.dart';
import 'package:miru_alpha/ui/features/search/view_models/search_view_model.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/domain/models/search.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:forui/forui.dart';

class _FakeSearchViewModel extends SearchViewModel {
  _FakeSearchViewModel(this._state);
  final DomainSearchState _state;

  @override
  Future<DomainSearchState> build() => Future.value(_state);
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

void main() {
  testWidgets('SearchView renders correctly', (WidgetTester tester) async {
    final searchState = const DomainSearchState(
      extensions: [],
      query: '',
      isLoading: false,
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
        searchViewModelProvider.overrideWith(() => _FakeSearchViewModel(searchState)),
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
          data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
          child: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: MaterialApp.router(
              routerConfig: GoRouter(
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) => const SearchView(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // SearchView should build without throwing.
    expect(find.byType(SearchView), findsOneWidget);
  });
}
