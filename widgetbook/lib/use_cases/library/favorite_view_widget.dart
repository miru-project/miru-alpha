/// Mirrors test/ui/features/favorite/favorite_view_widget_test.dart states
/// for the catalog, plus richer mobile previews.
///
/// The extension list is populated with a small metadata set so a tile's
/// subtitle renders the source name instead of the "package not found" raw
/// key. Covers point at picsum placeholders, served through the catalog's
/// loopback image proxy (see `catalog_image_proxy.dart`) — ImageWidget always
/// routes through the core proxy, so no cover renders without it.
///
/// Every state renders inside [PhoneFrame] (412 wide → below the `lg`
/// breakpoint → the mobile branch), and the fake notifier applies type/tag
/// filters in memory so the header chips are interactive in the catalog.
library;

import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/features/favorite/views/favorite_view.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
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
      WidgetbookUseCase(
        name: 'Grid — populated · covers + mixed types',
        builder: _populatedGrid,
      ),
      WidgetbookUseCase(
        name: 'Grid — tag selected · badge + filtered',
        builder: _tagSelected,
      ),
      WidgetbookUseCase(
        name: 'Grid — type filtered · manga only',
        builder: _typeFiltered,
      ),
      WidgetbookUseCase(
        name: 'Long-press · remove sheet',
        builder: _removeSheet,
      ),
    ],
  );
}

/// A [FavoritePageNotifier] that keeps its state in memory and applies the
/// same filters the real notifier does, minus the database. This is what
/// makes the type chips and long-press remove work live in the catalog.
class _FakeFavoritePageNotifier extends FavoritePageNotifier {
  _FakeFavoritePageNotifier(FavoritePageState initial) : _initial = initial;

  FavoritePageState _initial;

  @override
  FavoritePageState build() => _initial;

  void _commit(FavoritePageState next) {
    _initial = next;
    state = next;
  }

  @override
  void filterWithType(Set<ExtensionType> type) {
    final filtered = type.isEmpty
        ? _initial.favorites
        : _initial.favorites
              .where((f) => type.contains(stringToExtensionType(f.type)))
              .toList();
    _commit(
      _initial.copyWith(selectedTypes: type, filteredFavorites: filtered),
    );
  }

  @override
  void filterFavoriteGroups(List<FavoriteGroup> groups) {
    final filtered = groups.isEmpty
        ? _initial.favorites
        : groups.expand((g) => g.favorites).toList();
    _commit(
      _initial.copyWith(
        selectedFavoriteGroups: groups,
        filteredFavorites: filtered,
      ),
    );
  }

  @override
  void toggleGroupName(String name) {
    final selected = _initial.selectedFavoriteGroups;
    final next = selected.any((g) => g.name == name)
        ? selected.where((g) => g.name != name).toList()
        : [
            ...selected,
            ..._initial.favoriteGroups.where((g) => g.name == name),
          ];
    filterFavoriteGroups(next);
  }

  @override
  void deleteFavorite(Favorite favorite) {
    _commit(
      _initial.copyWith(
        favorites: _initial.favorites
            .where((f) => f.id != favorite.id)
            .toList(),
        filteredFavorites: _initial.filteredFavorites
            .where((f) => f.id != favorite.id)
            .toList(),
      ),
    );
  }
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

/// The test's pump: width 412 keeps the mobile branch below the lg
/// breakpoint — [PhoneFrame] pins it.
Widget _favoriteView(
  BuildContext context, {
  required FavoritePageState state,
  List<ExtensionMeta> metaData = const [],
}) {
  MiruSettings.seedDefaults();
  final container = ProviderContainer(
    overrides: [
      favoritePageProvider.overrideWith(() => _FakeFavoritePageNotifier(state)),
      applicationControllerProvider.overrideWith(
        () => _FakeApplicationController(_appState()),
      ),
      extensionPageProvider.overrideWith(
        () => _FakeExtensionPageNotifier(
          ExtensionPageModel(
            fetchedRepo: const [],
            extensionList: const [],
            installedPackages: const [],
            metaData: metaData,
            sourceIndex: 0,
          ),
        ),
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
            // Tap-through target for a tile: a stub so opening a favorite in
            // the catalog does not hit an unregistered route.
            GoRoute(
              path: '/search/single/detail',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('probe-detail'))),
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

/// Picsum placeholder cover — `?random=<id>` keeps every tile's image unique.
String _cover(int id) => 'https://picsum.photos/200/300?random=$id';

Favorite _favorite(int id, String title, String type, String package) =>
    Favorite(
      id: id,
      package: package,
      url: 'https://example.com/favorite/$id',
      type: type,
      title: title,
      cover: _cover(id),
      date: DateTime(2026, 1, 1),
    );

final _videoMeta = ExtensionMeta(
  name: 'ExampleA',
  version: '1.0.0',
  author: 'catalog',
  license: 'MIT',
  lang: 'en',
  packageName: 'pkg.video',
  webSite: 'https://example.com',
  tags: [],
  api: 'v2',
  type: ExtensionType.bangumi,
);

final _mangaMeta = ExtensionMeta(
  name: 'ExampleB',
  version: '1.0.0',
  author: 'catalog',
  license: 'MIT',
  lang: 'en',
  packageName: 'pkg.manga',
  webSite: 'https://example.com',
  tags: [],
  api: 'v2',
  type: ExtensionType.manga,
);

final _novelMeta = ExtensionMeta(
  name: 'ExampleC',
  version: '1.0.0',
  author: 'catalog',
  license: 'MIT',
  lang: 'en',
  packageName: 'pkg.novel',
  webSite: 'https://example.com',
  tags: [],
  api: 'v2',
  type: ExtensionType.fikushon,
);

final _metaData = [_videoMeta, _mangaMeta, _novelMeta];

Widget _emptyView(BuildContext context) =>
    _favoriteView(context, state: _stateFor(const []));

Widget _oneFavorite(BuildContext context) => _favoriteView(
  context,
  state: _stateFor([_favorite(1, 'Test Favorite', 'manga', 'pkg.manga')]),
  metaData: _metaData,
);

Widget _populatedGrid(BuildContext context) => _favoriteView(
  context,
  state: _stateFor([
    _favorite(1, 'Daemons of the Shadow Realm', 'bangumi', 'pkg.video'),
    _favorite(2, 'Manga Title One', 'manga', 'pkg.manga'),
    _favorite(
      3,
      'A Very Long Light Novel Name That Wraps',
      'fikushon',
      'pkg.novel',
    ),
    _favorite(4, 'Second Manga', 'manga', 'pkg.manga'),
    _favorite(5, 'Anime Two', 'bangumi', 'pkg.video'),
    _favorite(6, 'Third Manga', 'manga', 'pkg.manga'),
  ]),
  metaData: _metaData,
);

Widget _tagSelected(BuildContext context) {
  final anime = [
    _favorite(1, 'Daemons of the Shadow Realm', 'bangumi', 'pkg.video'),
    _favorite(5, 'Anime Two', 'bangumi', 'pkg.video'),
  ];
  final manga = [
    _favorite(2, 'Manga Title One', 'manga', 'pkg.manga'),
    _favorite(4, 'Second Manga', 'manga', 'pkg.manga'),
  ];
  final novel = [_favorite(6, 'Novel One', 'fikushon', 'pkg.novel')];
  final groups = [
    FavoriteGroup(name: 'Anime', date: DateTime(2026, 1, 1), favorites: anime),
    FavoriteGroup(name: 'Manga', date: DateTime(2026, 1, 1), favorites: manga),
    FavoriteGroup(name: 'Novel', date: DateTime(2026, 1, 1), favorites: novel),
  ];
  return _favoriteView(
    context,
    state: FavoritePageState(
      favorites: [...anime, ...manga, ...novel],
      favoriteGroups: groups,
      filteredFavorites: [...anime, ...manga, ...novel],
      // Select all 3 groups → the rail shows 2 chips + a '+1' overflow chip.
      selectedFavoriteGroups: groups,
    ),
    metaData: _metaData,
  );
}

Widget _typeFiltered(BuildContext context) {
  final favorites = [
    _favorite(1, 'Daemons of the Shadow Realm', 'bangumi', 'pkg.video'),
    _favorite(2, 'Manga Title One', 'manga', 'pkg.manga'),
    _favorite(
      3,
      'A Very Long Light Novel Name That Wraps',
      'fikushon',
      'pkg.novel',
    ),
    _favorite(4, 'Second Manga', 'manga', 'pkg.manga'),
  ];
  return _favoriteView(
    context,
    state: FavoritePageState(
      favorites: favorites,
      favoriteGroups: const [],
      filteredFavorites: favorites.where((f) => f.type == 'manga').toList(),
      selectedFavoriteGroups: const [],
      selectedTypes: {ExtensionType.manga},
    ),
    metaData: _metaData,
  );
}

/// Static mirror of the sheet `showRemoveSheet` raises (see
/// `list_helpers.dart` → `showActionsSheet`): a card with the source title and
/// a single destructive remove row, anchored to the bottom of the phone.
Widget _removeSheet(BuildContext context) => PhoneFrame(
  child: MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          // Dimmed page behind the sheet, standing in for the favorites grid.
          ColoredBox(
            color: context.theme.colors.background,
            child: const SizedBox.expand(),
          ),
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.26),
            child: const SizedBox.expand(),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: _RemoveSheetPreview(),
          ),
        ],
      ),
    ),
  ),
);

class _RemoveSheetPreview extends StatelessWidget {
  const _RemoveSheetPreview();

  @override
  Widget build(BuildContext context) {
    return MiruCard(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: 20,
        ),
        child: FTileGroup(
          label: const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text('Test Favorite'),
          ),
          children: [
            FTile(
              prefix: Icon(
                FLucideIcons.heartMinus,
                color: context.theme.colors.destructive,
              ),
              title: const Text('Remove from favorites'),
              onPress: () {},
            ),
          ],
        ),
      ),
    );
  }
}
