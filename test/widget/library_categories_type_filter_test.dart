import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/ui/features/favorite/views/favorite_view.dart';
import 'package:miru_alpha/ui/features/home/widget/library_categories.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

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

/// Tapping a row in the library page's TYPE section must land on the favorite
/// list with that type already filtered.
///
/// The rows used to push i18n display keys (`?type=media.video`), which
/// `stringToExtensionType` cannot parse — it falls back to
/// [ExtensionType.all], and the router reads that as "no filter". So every row
/// silently opened an unfiltered list.
void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);

  Future<Uri?> tapCategory(WidgetTester tester, String label) async {
    Uri? landed;

    final container = ProviderContainer(
      overrides: [
        favoritePageProvider.overrideWith(
          () => _FakeFavoritePageNotifier(
            FavoritePageState(
              favorites: const [],
              favoriteGroups: const [],
              filteredFavorites: const [],
              selectedFavoriteGroups: const [],
            ),
          ),
        ),
        applicationControllerProvider.overrideWith(
          () => _FakeApplicationController(
            ApplicationState(
              themeText: 'light',
              baseColor: 'zinc',
              primaryColor: 'zinc',
              themeData: ThemeUtils.getThemeData(MiruThemes.zinc.light),
              themeMode: ThemeMode.light,
              language: 'en',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, s) => const Scaffold(
            body: SingleChildScrollView(child: LibraryCategoryList()),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, s) => const SizedBox.shrink(),
          routes: [
            GoRoute(
              path: 'favorite',
              builder: (context, s) {
                landed = s.uri;
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: FTheme(
          data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );

    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
    return landed;
  }

  // i18n resolves to the key itself under test, so the labels are the keys.
  const cases = [
    ('media.video', ExtensionType.bangumi),
    ('media.manga', ExtensionType.manga),
    ('media.novel', ExtensionType.fikushon),
  ];

  for (final (label, expected) in cases) {
    testWidgets('$label opens the favorite list filtered to $expected', (
      tester,
    ) async {
      final uri = await tapCategory(tester, label);

      expect(uri, isNotNull, reason: 'tapping $label should navigate');

      // Same contract the router applies: a value it cannot parse would show an
      // unfiltered list, which is exactly the old bug.
      final raw = uri!.queryParameters['type'];
      expect(raw, isNotNull, reason: '$label must carry a ?type= filter');
      expect(
        stringToExtensionType(raw!),
        expected,
        reason: '$label pushed "$raw", which does not parse back to a filter',
      );
      expect(tester.takeException(), isNull);
    });
  }

  // The other half of the chain: once the router has parsed the type, the
  // favorite list must actually apply it to its provider.
  for (final (label, expected) in cases) {
    testWidgets('FavoriteView applies the $expected filter it is handed', (
      tester,
    ) async {
      final notifier = _RecordingFavoritePageNotifier();
      final container = ProviderContainer(
        overrides: [
          favoritePageProvider.overrideWith(() => notifier),
          applicationControllerProvider.overrideWith(
            () => _FakeApplicationController(
              ApplicationState(
                themeText: 'light',
                baseColor: 'zinc',
                primaryColor: 'zinc',
                themeData: ThemeUtils.getThemeData(MiruThemes.zinc.light),
                themeMode: ThemeMode.light,
                language: 'en',
              ),
            ),
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
            child: MaterialApp.router(
              routerConfig: GoRouter(
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, s) => FavoriteView(type: expected),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        notifier.appliedTypes,
        contains(expected),
        reason: '$label should reach the list as an active filter',
      );
      expect(
        container.read(favoritePageProvider.select((s) => s.selectedTypes)),
        {expected},
      );
    });
  }
}

/// Records every type filter the view pushes down to the provider.
class _RecordingFavoritePageNotifier extends FavoritePageNotifier {
  final List<ExtensionType?> appliedTypes = [];

  @override
  FavoritePageState build() => FavoritePageState(
    favorites: const [],
    favoriteGroups: const [],
    filteredFavorites: const [],
    selectedFavoriteGroups: const [],
  );

  @override
  void setTypeFilter(ExtensionType? type) {
    appliedTypes.add(type);
    super.setTypeFilter(type);
  }
}
