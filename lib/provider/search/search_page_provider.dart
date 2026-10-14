import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'search_page_provider.g.dart';

/// Which installed sources a global query fans out to.
enum SearchScopeMode {
  /// Only the extensions the user pinned.
  pinned,

  /// Every installed extension.
  all,

  /// An explicit hand-picked subset ([SearchPageState.specificPackages]).
  specific,
}

/// Ordering of the aggregated global results.
enum SearchSortMode {
  /// Match quality first (exact > prefix > contains); pinned sources win ties.
  relevance,

  /// Newest `ExtensionListItem.update` first.
  latest,

  /// Pinned sources first, then alphabetically by source name.
  sourcePriority,
}

/// How the aggregated result list lays itself out: one flat grid ordered by
/// relevance, or one shelf per extension.
enum ResultsViewMode { relevance, byExtension }

/// Filter applied to the `/search` tab's source list (never to results).
enum SearchSourceStatus { all, pinned, unpinned }

/// Ordering of the `/search` tab's source list.
enum SearchSourceSort {
  /// Pinned sources first, then by name.
  pinned,
  name,
  version,
}

/// The content types a query may be narrowed to.
///
/// Mirrors the extension manifest's [ExtensionType] set minus `.all`, which is
/// a scope (serves every type) rather than a filterable type of its own.
const List<ExtensionType> kSearchContentTypes = [
  ExtensionType.bangumi,
  ExtensionType.manga,
  ExtensionType.fikushon,
];

class SearchPageState {
  final List<ExtensionMeta> metaData;
  final Set<String> pinnedExtensions;
  final String query;
  final Set<String> existedPinnedExtensions;
  final String? selectedLang;

  /// Selected content types; always a subset of [kSearchContentTypes]. An empty
  /// set is read as "every type".
  final Set<ExtensionType> contentTypes;

  final SearchScopeMode scopeMode;
  final Set<String> specificPackages;
  final SearchSortMode sort;

  /// Layout of the aggregated results: flat grid vs per-extension shelves.
  final ResultsViewMode resultsViewMode;

  /// Filters of the `/search` tab's *source list*. They live here instead of
  /// in widget state because the pill row is pinned under the search field
  /// while the cards scroll in the body — two widgets, one truth.
  final ExtensionType? sourceType;
  final SearchSourceStatus sourceStatus;
  final SearchSourceSort sourceSort;

  final bool open;
  final List<String> history;

  /// Bumped by [SearchPageNotifier.refilter] so setting changes force a
  /// rebuild without any data change.
  final int refilterTick;

  SearchPageState({
    required this.metaData,
    required this.pinnedExtensions,
    required this.query,
    required this.existedPinnedExtensions,
    this.selectedLang,
    Set<ExtensionType>? contentTypes,
    // Pinned by default, like the notifier's initial state: a global search
    // never fans out to every installed extension unless the user asks.
    this.scopeMode = SearchScopeMode.pinned,
    this.specificPackages = const {},
    this.sort = SearchSortMode.relevance,
    this.resultsViewMode = ResultsViewMode.relevance,
    this.sourceType,
    this.sourceStatus = SearchSourceStatus.all,
    this.sourceSort = SearchSourceSort.pinned,
    this.open = false,
    this.history = const [],
    this.refilterTick = 0,
  }) : contentTypes = contentTypes ?? kSearchContentTypes.toSet();

  /// True when the source list is unfiltered, i.e. its "All Sources" pill is
  /// the one showing.
  bool get sourceFiltersReset =>
      sourceType == null &&
      sourceStatus == SearchSourceStatus.all &&
      sourceSort == SearchSourceSort.pinned;

  /// True when the scope is the pinned subset. Derived, so the desktop bar's
  /// switch and the mobile scope pills can never disagree.
  bool get pinnedScope => scopeMode == SearchScopeMode.pinned;

  /// Single-type projection of [contentTypes] for the desktop bar's
  /// one-tab-at-a-time control; `null` means "no single type is selected".
  ExtensionType? get selectedType => switch (contentTypes.length) {
    1 => contentTypes.first,
    _ => null,
  };

  /// True when [contentTypes] is narrowed below "everything".
  bool get contentTypeFiltered =>
      contentTypes.isNotEmpty &&
      contentTypes.length < kSearchContentTypes.length;

  List<ExtensionMeta> get filteredMetaData {
    var result = metaData;
    // NSFW extensions stay hidden unless the user enabled them in settings.
    if (!MiruSettings.getSettingSync<bool>(SettingKey.enableNSFW)) {
      result = result.where((e) => !e.nsfw).toList();
    }
    if (selectedLang != null) {
      result = result.where((e) {
        final base = e.lang.split(RegExp(r'[-_]')).first;
        return base == selectedLang;
      }).toList();
    }
    if (contentTypeFiltered) {
      // An `all` extension serves every type, so narrowing the filter must not
      // silently drop it from the sources being queried.
      result = result
          .where(
            (e) => e.type == ExtensionType.all || contentTypes.contains(e.type),
          )
          .toList();
    }
    return result;
  }

  // Package names that global search should iterate, honoring the scope mode
  // plus the content-type / language / NSFW filters behind
  // [filteredMetaData].
  Set<String> get searchScopePackages {
    final base = switch (scopeMode) {
      SearchScopeMode.pinned => existedPinnedExtensions,
      SearchScopeMode.all => metaData.map((e) => e.packageName).toSet(),
      SearchScopeMode.specific => specificPackages,
    };
    return base.intersection(
      filteredMetaData.map((e) => e.packageName).toSet(),
    );
  }

  // Recently visited extensions (newest first), backed by the fixed-size
  // RecentExtensions setting (updated when an extension's latest page is
  // opened), rather than parsed from search history.
  List<String> get recentExtensions => MiruSettings.getRecentExtensions();

  SearchPageState copyWith({
    List<ExtensionMeta>? metaData,
    Set<String>? pinnedExtensions,
    String? query,
    Set<String>? existedPinnedExtensions,
    String? selectedLang,
    Set<ExtensionType>? contentTypes,
    SearchScopeMode? scopeMode,
    Set<String>? specificPackages,
    SearchSortMode? sort,
    ResultsViewMode? resultsViewMode,
    ExtensionType? sourceType,
    bool clearSourceType = false,
    SearchSourceStatus? sourceStatus,
    SearchSourceSort? sourceSort,
    bool? open,
    List<String>? history,
    bool clearLang = false,
    int? refilterTick,
  }) {
    return SearchPageState(
      existedPinnedExtensions:
          existedPinnedExtensions ?? this.existedPinnedExtensions,
      metaData: metaData ?? this.metaData,
      pinnedExtensions: pinnedExtensions ?? this.pinnedExtensions,
      query: query ?? this.query,
      selectedLang: clearLang ? null : (selectedLang ?? this.selectedLang),
      contentTypes: contentTypes ?? this.contentTypes,
      scopeMode: scopeMode ?? this.scopeMode,
      specificPackages: specificPackages ?? this.specificPackages,
      sort: sort ?? this.sort,
      resultsViewMode: resultsViewMode ?? this.resultsViewMode,
      sourceType: clearSourceType ? null : (sourceType ?? this.sourceType),
      sourceStatus: sourceStatus ?? this.sourceStatus,
      sourceSort: sourceSort ?? this.sourceSort,
      open: open ?? this.open,
      history: history ?? this.history,
      refilterTick: refilterTick ?? this.refilterTick,
    );
  }
}

@Riverpod(keepAlive: true)
class SearchPageNotifier extends _$SearchPageNotifier {
  @override
  SearchPageState build() {
    // listen to extension page provider
    ref.listen(extensionPageProvider.select((e) => e.metaData), (prev, next) {
      final existedPinnedExtension = next
          .where(
            (ext) => MiruSettings.getSettingSync<Set<String>>(
              SettingKey.pinnedExtension,
            ).contains(ext.packageName),
          )
          .map((e) => e.packageName)
          .toSet();
      MiruSettings.setSettingSync(
        SettingKey.pinnedExtension,
        existedPinnedExtension.toString(),
      );
      state = state.copyWith(
        metaData: next,
        existedPinnedExtensions: existedPinnedExtension,
      );
    });

    final installed = ref.read(extensionPageProvider).metaData;
    final existedPinned = installed
        .where(
          (ext) => MiruSettings.getSettingSync<Set<String>>(
            SettingKey.pinnedExtension,
          ).contains(ext.packageName),
        )
        .map((e) => e.packageName)
        .toSet();

    return SearchPageState(
      metaData: installed,
      pinnedExtensions: {},
      query: '',
      existedPinnedExtensions: existedPinned,
      // Every global search opens on the pinned scope. Searching every
      // installed extension by default is one request per source per page,
      // straight at the origin servers, for results the user never asked to
      // fan out to; with nothing pinned the scope is simply empty and the
      // results body says so (`search.no_pinned`) instead of opening up.
      // The only thing that moves it off pinned is the user: the "Pinned
      // Only" switch, the scope pills, or the desktop bar.
      scopeMode: SearchScopeMode.pinned,
      history: _loadHistory(),
    );
  }

  List<String> _loadHistory() {
    final raw = MiruSettings.getSettingSync<String>(SettingKey.searchHistory);
    if (raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const [];
  }

  void setMetaData(List<ExtensionMeta> metaData) {
    state = state.copyWith(metaData: metaData);
  }

  /// Bump to force widgets that read [SearchPageState.filteredMetaData] to
  /// rebuild after a display-affecting setting (Enable NSFW Content) changes.
  /// Refilters in place — metadata is never refetched.
  void refilter() {
    state = state.copyWith(refilterTick: DateTime.now().microsecondsSinceEpoch);
  }

  void setPinnedExtensions(Set<String> pinnedExtensions) {
    state = state.copyWith(pinnedExtensions: pinnedExtensions);
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setOpen(bool open) {
    state = state.copyWith(open: open);
  }

  void setExistedPinnedExtensions(Set<String> existedPinnedExtensions) {
    state = state.copyWith(existedPinnedExtensions: existedPinnedExtensions);
  }

  void setScopeMode(SearchScopeMode mode) {
    if (mode == state.scopeMode) return;
    state = state.copyWith(scopeMode: mode);
  }

  /// Desktop bar switch: `true` narrows to the pinned scope, `false` widens to
  /// every installed extension.
  void setPinnedScope(bool pinned) {
    setScopeMode(pinned ? SearchScopeMode.pinned : SearchScopeMode.all);
  }

  void toggleSpecificPackage(String packageName) {
    final next = {...state.specificPackages};
    if (!next.remove(packageName)) next.add(packageName);
    state = state.copyWith(specificPackages: next);
  }

  void setSelectedLang(String? lang) {
    state = state.copyWith(selectedLang: lang, clearLang: lang == null);
  }

  /// Single-type selection used by the desktop bar's tabs. `null` / `.all`
  /// clears the narrowing, anything else selects exactly that type.
  void setSelectedType(ExtensionType? type) {
    if (type == null || type == ExtensionType.all) {
      state = state.copyWith(contentTypes: kSearchContentTypes.toSet());
    } else {
      state = state.copyWith(contentTypes: {type});
    }
  }

  /// Content-type chips: toggling the last selected chip off re-selects every
  /// type rather than leaving the search with nothing to query.
  void toggleContentType(ExtensionType type) {
    if (!kSearchContentTypes.contains(type)) return;
    final next = {...state.contentTypes};
    if (next.contains(type)) {
      next.remove(type);
      if (next.isEmpty) next.addAll(kSearchContentTypes);
    } else {
      next.add(type);
    }
    state = state.copyWith(contentTypes: next);
  }

  void setSort(SearchSortMode sort) {
    state = state.copyWith(sort: sort);
  }

  /// One `/search` tab source-list filter changed. Separate methods instead of
  /// one: a type filter of `null` means "All", so it must not be confused with
  /// "the caller left this one alone".
  void setSourceType(ExtensionType? type) {
    state = state.copyWith(sourceType: type, clearSourceType: type == null);
  }

  void setSourceStatus(SearchSourceStatus status) {
    state = state.copyWith(sourceStatus: status);
  }

  void setSourceSort(SearchSourceSort sort) {
    state = state.copyWith(sourceSort: sort);
  }

  /// Flat relevance grid vs per-extension shelves.
  void setResultsViewMode(ResultsViewMode mode) {
    state = state.copyWith(resultsViewMode: mode);
  }

  /// Back to "All Sources": no type, every status, pinned-first order.
  void resetSourceFilters() {
    state = state.copyWith(
      clearSourceType: true,
      sourceStatus: SearchSourceStatus.all,
      sourceSort: SearchSourceSort.pinned,
    );
  }

  /// Applies the whole filter sheet draft in one state change, so the UI never
  /// rebuilds (or refetches) once per field.
  void setFilters({
    SearchScopeMode? scopeMode,
    Set<String>? specificPackages,
    Set<ExtensionType>? contentTypes,
    SearchSortMode? sort,
    String? selectedLang,
  }) {
    state = state.copyWith(
      scopeMode: scopeMode,
      specificPackages: specificPackages,
      contentTypes: contentTypes,
      sort: sort,
      selectedLang: selectedLang,
      clearLang: selectedLang != null && selectedLang.isEmpty,
    );
  }

  void addHistory(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final next = [
      trimmed,
      ...state.history.where((e) => e != trimmed),
    ].take(10).toList();
    state = state.copyWith(history: next);
    MiruSettings.setSettingSync(SettingKey.searchHistory, jsonEncode(next));
  }

  void removeHistory(String query) {
    final next = state.history.where((e) => e != query).toList();
    state = state.copyWith(history: next);
    MiruSettings.setSettingSync(SettingKey.searchHistory, jsonEncode(next));
  }

  void clearHistory() {
    state = state.copyWith(history: const []);
    MiruSettings.setSettingSync(
      SettingKey.searchHistory,
      jsonEncode(<String>[]),
    );
  }
}
