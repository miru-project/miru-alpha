import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/ui/features/search/views/search_view.dart';
import 'package:miru_alpha/ui/features/search/view_models/search_view_model.dart';
import 'package:miru_alpha/domain/models/search.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

ExtensionMeta _meta(String pkg, String name) => ExtensionMeta(
  name: name,
  version: 'v0.0.1',
  author: 't',
  license: 'MIT',
  lang: 'en',
  packageName: pkg,
  webSite: 'https://example.com',
  tags: const [],
  api: 'v2',
  type: ExtensionType.bangumi,
);

class _FakeSearchViewModel extends SearchViewModel {
  @override
  Future<DomainSearchState> build() => Future.value(
    const DomainSearchState(extensions: [], query: '', isLoading: false),
  );
}

class _FakeSearchPage extends SearchPageNotifier {
  _FakeSearchPage(this._metas);
  final List<ExtensionMeta> _metas;

  @override
  SearchPageState build() => SearchPageState(
    metaData: _metas,
    pinnedExtensions: {},
    query: '',
    existedPinnedExtensions: {},
  );
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

void main() {
  testWidgets('DesktopSearchPage paints installed tiles', (
    WidgetTester tester,
  ) async {
    MiruSettings.seedDefaultsForTest();
    final appState = ApplicationState(
      themeText: 'light',
      baseColor: 'zinc',
      primaryColor: 'zinc',
      themeData: ThemeUtils.getThemeData(MiruThemes.zinc.light),
      themeMode: ThemeMode.system,
      language: 'en',
    );
    final metas = [_meta('a.pkg', 'Alpha'), _meta('b.pkg', 'Beta')];

    final container = ProviderContainer(
      overrides: [
        searchViewModelProvider.overrideWith(() => _FakeSearchViewModel()),
        searchPageProvider.overrideWith(() => _FakeSearchPage(metas)),
        applicationControllerProvider.overrideWith(
          () => _FakeApplicationController(appState),
        ),
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
    await tester.pumpAndSettle();

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
  });
}
