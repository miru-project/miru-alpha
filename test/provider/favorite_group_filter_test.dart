import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/ui/features/favorite/views/favorite_view.dart'
    show compareFavoriteGroupNames;
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// Seeds the notifier directly (no gRPC): the flat favorites list and the
/// groups' NESTED favorites are built as distinct instances with equal
/// fields — the shape two separate DB reads (getAllFavorite +
/// getAllFavoriteGroup) produce, which the group filter must join by value.
class _FakeFavoritePageNotifier extends FavoritePageNotifier {
  _FakeFavoritePageNotifier(this._state);
  final FavoritePageState _state;

  @override
  FavoritePageState build() => _state;
}

Favorite _fav(String url) => Favorite(
  package: 'test.package',
  url: url,
  type: 'manga',
  title: 'T $url',
  date: DateTime(2026, 1, 1),
);

FavoriteGroup _group(String name, List<String> urls) => FavoriteGroup(
  name: name,
  date: DateTime(2026, 1, 1),
  favorites: [for (final u in urls) _fav(u)],
);

FavoritePageState _seedState({
  required List<FavoriteGroup> groups,
  FavoriteFilterMode mode = FavoriteFilterMode.or,
}) {
  final flat = [_fav('a'), _fav('b'), _fav('c')];
  return FavoritePageState(
    favorites: flat,
    favoriteGroups: groups,
    filteredFavorites: flat,
    selectedFavoriteGroups: const [],
    filterMode: mode,
  );
}

void main() {
  setUp(MiruSettings.seedDefaultsForTest);

  ProviderContainer container(FavoritePageState state) {
    final c = ProviderContainer(
      overrides: [
        favoritePageProvider.overrideWith(
          () => _FakeFavoritePageNotifier(state),
        ),
      ],
    );
    addTearDown(c.dispose);
    // Mount the notifier before driving it.
    c.read(favoritePageProvider.notifier);
    return c;
  }

  test('selecting a group filters the flat list across DB reads', () {
    final g = _group('g', ['a', 'c']);
    final c = container(_seedState(groups: [g]));

    c.read(favoritePageProvider.notifier).filterFavoriteGroups([g]);

    expect(c.read(favoritePageProvider).filteredFavorites.map((f) => f.url), [
      'a',
      'c',
    ]);
  });

  test('toggleGroupName (mobile tag chip path) filters by the named group', () {
    final g = _group('g', ['b']);
    final c = container(_seedState(groups: [g]));

    c.read(favoritePageProvider.notifier).toggleGroupName('g');

    final state = c.read(favoritePageProvider);
    expect(state.selectedFavoriteGroups.map((g) => g.name), ['g']);
    expect(state.filteredFavorites.map((f) => f.url), ['b']);
  });

  test('AND mode intersects two overlapping groups', () {
    final g1 = _group('g1', ['a', 'b']);
    final g2 = _group('g2', ['b', 'c']);
    final c = container(
      _seedState(groups: [g1, g2], mode: FavoriteFilterMode.and),
    );

    c.read(favoritePageProvider.notifier).filterFavoriteGroups([g1, g2]);

    expect(c.read(favoritePageProvider).filteredFavorites.map((f) => f.url), [
      'b',
    ]);
  });

  test('OR mode lists both groups without duplicating a shared favorite', () {
    final g1 = _group('g1', ['a', 'b']);
    final g2 = _group('g2', ['b', 'c']);
    final c = container(
      _seedState(groups: [g1, g2], mode: FavoriteFilterMode.or),
    );

    c.read(favoritePageProvider.notifier).filterFavoriteGroups([g1, g2]);

    expect(c.read(favoritePageProvider).filteredFavorites.map((f) => f.url), [
      'a',
      'b',
      'c',
    ]);
  });

  test('untoggling the only selected group restores the full list', () {
    final g = _group('g', ['a']);
    final c = container(_seedState(groups: [g]));
    final notifier = c.read(favoritePageProvider.notifier);

    notifier.toggleGroupName('g');
    expect(c.read(favoritePageProvider).filteredFavorites, hasLength(1));

    notifier.toggleGroupName('g');
    expect(c.read(favoritePageProvider).filteredFavorites.map((f) => f.url), [
      'a',
      'b',
      'c',
    ]);
  });

  test('non-ASCII tag (あ１) toggles and filters by its exact name', () {
    final g = _group('あ１', ['b']);
    final c = container(_seedState(groups: [g]));

    c.read(favoritePageProvider.notifier).toggleGroupName('あ１');

    final state = c.read(favoritePageProvider);
    expect(state.selectedFavoriteGroups.map((g) => g.name), ['あ１']);
    expect(state.filteredFavorites.map((f) => f.url), ['b']);
  });

  test('non-ASCII tag with different outer whitespace still selects', () {
    final g = _group('あ１', ['b']);
    final c = container(_seedState(groups: [g]));

    c.read(favoritePageProvider.notifier).toggleGroupName(' あ１ ');

    final state = c.read(favoritePageProvider);
    expect(state.selectedFavoriteGroups.map((g) => g.name), ['あ１']);
    expect(state.filteredFavorites.map((f) => f.url), ['b']);
  });

  test('favoriteGroupKey trims and case-folds so equivalent names match', () {
    expect(favoriteGroupKey('あ１'), favoriteGroupKey(' あ１ '));
    expect(favoriteGroupKey('Anime'), favoriteGroupKey(' anime '));
    expect(favoriteGroupKey('Anime'), 'anime');
  });

  test('non-ASCII tag names sort deterministically and case-insensitively', () {
    final names = ['banana', 'Apple', 'あ１', 'いちご', 'apple'];
    final sorted = [...names]..sort(compareFavoriteGroupNames);

    // Case-folded: 'Apple'/'apple' group together before 'banana'; non-ASCII
    // tags sort after the ASCII ones by code point, and the sort is stable.
    expect(sorted, ['Apple', 'apple', 'banana', 'あ１', 'いちご']);

    // Sorting is a total order: comparing every pair is antisymmetric.
    for (final a in names) {
      for (final b in names) {
        final ab = compareFavoriteGroupNames(a, b);
        final ba = compareFavoriteGroupNames(b, a);
        if (ab == 0) {
          expect(ba, 0);
        } else {
          expect(ab < 0 ? ba > 0 : ba < 0, isTrue);
        }
      }
    }
  });

  test('Favorite equality joins the flat list to a group edge by value', () {
    // Two distinct instances of the same (package, url) — the shape the two
    // DB reads produce — must compare equal, while a different url must not.
    final a = _fav('a');
    final same = Favorite(
      package: 'test.package',
      url: 'a',
      type: 'manga',
      title: 'T a',
      date: DateTime(2026, 1, 1),
    );
    expect(a, same);
    expect(a.hashCode, same.hashCode);
    expect(a == _fav('b'), isFalse);
  });
}
