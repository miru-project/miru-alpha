import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/utils/store/database_service.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'favorite_page_provider.g.dart';

/// Per-favorite AniList summary, derived by matching a [Favorite] to an
/// AniList entry by title. `null` when the account is unlinked, the collection
/// hasn't loaded, or no entry matches.
class FavoriteAnilist {
  const FavoriteAnilist({
    required this.status,
    required this.progress,
    required this.total,
    required this.score,
    required this.unit,
  });

  /// AniList list status (WATCHING / COMPLETED / PAUSED / DROPPED / PLANNING).
  final String status;

  /// Episodes watched / chapters read.
  final int progress;

  /// Total episodes / chapters (0 when unknown).
  final int total;

  /// Mean score (0-100), or 0 when unscored.
  final double score;

  /// "Ep" for anime, "Ch" for manga — the unit for [progress]/[total].
  final String unit;

  /// A short label for the card subtitle, e.g. "WATCHING · Ep 8/12".
  String get progressLabel {
    if (total <= 0) return status;
    return '$status · $unit $progress/$total';
  }
}

/// Normalizes a title for matching: lowercase, strip punctuation and
/// bracketed release-group tags, collapse whitespace. AniList titles and
/// extension titles differ in casing/punctuation, so a loose match is the
/// only reliable join.
String normalizeTitle(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r'\[[^\]]*\]'), ' ')
      .replaceAll(RegExp(r'[^\w\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

enum FavoriteFilterMode { and, or }

class FavoritePageState {
  final List<Favorite> favorites;
  final List<Favorite> filteredFavorites;
  final List<FavoriteGroup> favoriteGroups;
  final List<FavoriteGroup> selectedFavoriteGroups;
  final Set<ExtensionType> selectedTypes;
  final FavoriteFilterMode filterMode;
  final String query;
  final Duration duration;
  final String filterSummary;
  // AniList join: normalized title → progress/score summary. Derived from
  // the AniList collections (watched in build). Empty when the account is
  // unlinked or nothing matches. Kept in the same state so the favorite page
  // is ONE service (no separate anilist lookup provider).
  final Map<String, FavoriteAnilist> anilistByTitle;
  FavoritePageState({
    required this.favorites,
    required this.favoriteGroups,
    required this.filteredFavorites,
    required this.selectedFavoriteGroups,
    this.selectedTypes = const {},
    this.filterMode = FavoriteFilterMode.or,
    this.query = '',
    this.duration = const Duration(days: 36500),
    this.filterSummary = '',
    this.anilistByTitle = const {},
  });

  FavoritePageState copyWith({
    List<Favorite>? favorites,
    List<FavoriteGroup>? favoriteGroups,
    List<Favorite>? filteredFavorites,
    List<FavoriteGroup>? selectedFavoriteGroups,
    Set<ExtensionType>? selectedTypes,
    FavoriteFilterMode? filterMode,
    String? query,
    Duration? duration,
    String? filterSummary,
    Map<String, FavoriteAnilist>? anilistByTitle,
  }) {
    return FavoritePageState(
      filteredFavorites: filteredFavorites ?? this.filteredFavorites,
      favorites: favorites ?? this.favorites,
      favoriteGroups: favoriteGroups ?? this.favoriteGroups,
      selectedFavoriteGroups:
          selectedFavoriteGroups ?? this.selectedFavoriteGroups,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      filterMode: filterMode ?? this.filterMode,
      query: query ?? this.query,
      duration: duration ?? this.duration,
      filterSummary: filterSummary ?? this.filterSummary,
      anilistByTitle: anilistByTitle ?? this.anilistByTitle,
    );
  }
}

@Riverpod(keepAlive: true)
class FavoritePageNotifier extends _$FavoritePageNotifier {
  @override
  FavoritePageState build() {
    // Watch the AniList collections so the join recomputes when AniList data
    // loads or refreshes (the single favorite service owns the AniList join
    // now — no separate lookup provider).
    final anime = ref.watch(anilistCollectionProvider(AnilistType.anime)).value;
    final manga = ref.watch(anilistCollectionProvider(AnilistType.manga)).value;
    Future.microtask(init);
    return FavoritePageState(
      favorites: [],
      favoriteGroups: [],
      filteredFavorites: [],
      selectedFavoriteGroups: [],
      selectedTypes: {},
      filterMode: FavoriteFilterMode.or,
      anilistByTitle: _joinAnilist(anime, manga),
    );
  }

  /// Joins the AniList anime + manga collections into a normalized-title →
  /// [FavoriteAnilist] map. Shared by `build()` so the favorite cards read the
  /// join from the state (via `select`) instead of a separate provider.
  Map<String, FavoriteAnilist> _joinAnilist(
    List<AnilistList>? anime,
    List<AnilistList>? manga,
  ) {
    if ((anime == null || anime.isEmpty) && (manga == null || manga.isEmpty)) {
      return const {};
    }
    final map = <String, FavoriteAnilist>{};
    void ingest(List<AnilistList>? lists, String mediaType) {
      if (lists == null) return;
      final unit = mediaType == 'ANIME' ? 'Ep' : 'Ch';
      for (final list in lists) {
        for (final entry in list.entries) {
          final media = entry.media;
          if (media == null) continue;
          final titles = [
            media.title.english,
            media.title.romaji,
            media.title.userPreferred,
            media.title.native,
          ].whereType<String>();
          final total =
              (mediaType == 'ANIME' ? media.episodes : media.chapters) ?? 0;
          final info = FavoriteAnilist(
            status: entry.status,
            progress: entry.progress,
            total: total,
            score: entry.score,
            unit: unit,
          );
          for (final title in titles) {
            map.putIfAbsent(normalizeTitle(title), () => info);
          }
        }
      }
    }

    ingest(anime, 'ANIME');
    ingest(manga, 'MANGA');
    return map;
  }

  // INIT
  Future<void> init() async {
    // Favorites read the backend DB; hold on the connection gate so a cold
    // start shows the section's loading state instead of a failed fetch.
    await ref.read(backendConnectionProvider.future);
    if (!ref.mounted) return;
    await refreshFavoritesAndGroup();
    _refilter();
  }

  //REFRESH
  Future<void> refreshFavoritesAndGroup() async {
    final futures = await Future.wait([
      DatabaseService.getAllFavoriteGroup(),
      DatabaseService.getAllFavorite(),
    ]);
    state = state.copyWith(
      favoriteGroups: futures[0] as List<FavoriteGroup>,
      favorites: futures[1] as List<Favorite>,
    );
    _refilter();
  }

  // DELETE
  void deleteFavorite(Favorite favorite) {
    state = state.copyWith(
      favorites: state.favorites.where((e) => e.id != favorite.id).toList(),
      filteredFavorites: state.filteredFavorites
          .where((e) => e.id != favorite.id)
          .toList(),
    );
    DatabaseService.deleteFavorite(favorite.url, favorite.package);
  }

  void deleteFavoriteGroup(FavoriteGroup favoriateGroup) {
    state = state.copyWith(
      favoriteGroups: state.favoriteGroups
          .where((e) => e.id != favoriateGroup.id)
          .toList(),
    );
    DatabaseService.deleteFavoriteGroup([favoriateGroup.name]);
  }

  // ADD
  void addFavorite(Favorite favorite) {
    state = state.copyWith(favorites: [favorite, ...state.favorites]);
  }

  void addFavoriteGroupbyName(String name) {
    state = state.copyWith(
      favoriteGroups: [
        FavoriteGroup(name: name, date: DateTime.now()),
        ...state.favoriteGroups,
      ],
    );
  }

  /// Single derivation: `filteredFavorites` is computed from the CURRENT
  /// state (selectedTypes + query + duration + selectedFavoriteGroups +
  /// filterMode). This is the ONE source of truth — no parallel cache. Every
  /// filter setter updates its state field and calls this.
  void _refilter() {
    final now = DateTime.now();
    // 1. Type filter.
    var result = state.selectedTypes.isEmpty
        ? state.favorites
        : state.favorites
              .where(
                (e) =>
                    state.selectedTypes.contains(stringToExtensionType(e.type)),
              )
              .toList();
    // 2. Keyword filter.
    if (state.query.isNotEmpty) {
      result = result.where((e) => e.title.contains(state.query)).toList();
    }
    // 3. Duration filter (added within X days).
    if (state.duration != const Duration(days: 36500)) {
      result = result
          .where((e) => now.difference(e.date) <= state.duration)
          .toList();
    }
    // 4. Group filter (AND/OR) — if groups are selected, narrow further.
    if (state.selectedFavoriteGroups.isNotEmpty) {
      result = favoritesInGroups(state.selectedFavoriteGroups)
          .where((f) => result.contains(f))
          .toList();
    }
    // Build the summary for the active-filter chip.
    final summary = <String>[];
    if (state.selectedTypes.isNotEmpty) {
      summary.add('type: ${state.selectedTypes.map((e) => e.name).join(',')}');
    }
    if (state.query.isNotEmpty) {
      summary.add('keyword: ${state.query}');
    }
    state = state.copyWith(
      filteredFavorites: result,
      filterSummary: summary.join(' | '),
    );
  }

  void filterWithType(Set<ExtensionType> type) {
    state = state.copyWith(selectedTypes: type);
    _refilter();
  }

  /// Convenience used by the router-driven list views. `null` or
  /// [ExtensionType.all] clears the type filter; otherwise a single type is
  /// applied.
  void setTypeFilter(ExtensionType? type) {
    filterWithType(type == null || type == ExtensionType.all ? {} : {type});
  }

  /// Toggle the AND/OR filtering mode for selected favorite groups.
  void setFilterMode(FavoriteFilterMode mode) {
    state = state.copyWith(filterMode: mode);
    _refilter();
  }

  void filterWithKeyword(String keyword) {
    state = state.copyWith(query: keyword);
    _refilter();
  }

  void filterWithDuration(Duration duration) {
    state = state.copyWith(duration: duration);
    _refilter();
  }

  // FILTER FAVORITE GROUPS
  //  At mobile home favorite page
  void filterFavoriteGroups(List<FavoriteGroup> favGroups) {
    state = state.copyWith(selectedFavoriteGroups: favGroups);
    _refilter();
  }

  /// Group-scoped favorites: the union (OR mode) or intersection (AND mode)
  /// of the given groups' favorites; every favorite when [favGroups] is
  /// empty. Hidden extensions contribute nothing to either. Shared by the
  /// favorites-page filter, the dashboard's Dynamic Feed, the tag strip and
  /// the manager sheet so all four read ONE selection.
  List<Favorite> favoritesInGroups(List<FavoriteGroup> favGroups) {
    // Read fresh each call — favorites changes never carry the hidden set,
    // so a cached read would leak hidden-extension favorites into the feed.
    final hidden = MiruSettings.getSettingSync<Set<String>>(
      SettingKey.hiddenExtension,
    );
    bool visible(Favorite f) => !hidden.contains(f.package);

    if (favGroups.isEmpty) {
      return hidden.isEmpty
          ? state.favorites
          : state.favorites.where(visible).toList();
    }
    // Match by name: the database keys groups by name, and a captured
    // [FavoriteGroup] object breaks equality after a favorites refresh.
    final favGroup = state.favoriteGroups
        .where((e) => favGroups.any((g) => g.name == e.name))
        .toList();
    if (hidden.isEmpty) {
      return state.filterMode == FavoriteFilterMode.and
          ? _intersectFavorites(favGroup)
          : favGroup.expand((e) => e.favorites).toList();
    }
    final visibleGroups = [
      for (final g in favGroup)
        FavoriteGroup(
          id: g.id,
          name: g.name,
          date: g.date,
          favorites: g.favorites.where(visible).toList(),
        ),
    ];
    return state.filterMode == FavoriteFilterMode.and
        ? _intersectFavorites(visibleGroups)
        : visibleGroups.expand((e) => e.favorites).toList();
  }

  /// Toggles a group in the selection BY NAME. The dashboard's tag strip and
  /// the manager sheet both call this, so the two surfaces cannot disagree
  /// about which groups the feed filters by.
  void toggleGroupName(String name) {
    final isSelected = state.selectedFavoriteGroups.any((g) => g.name == name);
    final next = isSelected
        ? state.selectedFavoriteGroups.where((g) => g.name != name).toList()
        : [
            ...state.selectedFavoriteGroups,
            ...state.favoriteGroups.where((g) => g.name == name),
          ];
    filterFavoriteGroups(next);
  }

  List<Favorite> _intersectFavorites(List<FavoriteGroup> groups) {
    if (groups.isEmpty) return [];
    final first = groups.first.favorites.toSet();
    var result = first;
    for (var i = 1; i < groups.length; i++) {
      result = result.intersection(groups[i].favorites.toSet());
    }
    // Preserve order from the first group
    return groups.first.favorites.where((f) => result.contains(f)).toList();
  }

  // CREATE FAVORITE GROUP
  Future<void> createFavoriteGroup(String name) async {
    final newGroup = await DatabaseService.putFavoriteGroup(name);
    state = state.copyWith(favoriteGroups: [newGroup, ...state.favoriteGroups]);
  }

  // UPDATE
  void updateFavorites({
    List<FavoriteGroup>? favoriteGroup,
    List<Favorite>? favorites,
  }) {
    state = state.copyWith(
      favoriteGroups: favoriteGroup ?? state.favoriteGroups,
      favorites: favorites ?? state.favorites,
    );
  }
}
