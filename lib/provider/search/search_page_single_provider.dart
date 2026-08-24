import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb;
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/utils/core/log.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/features/search/extension_filter_view.dart';

part 'search_page_single_provider.g.dart';

/// Immutable snapshot describing the `/search/single` page's working state.
///
/// Holds the current keyword, the pagination cursor, the extension-declared
/// filter catalogue ([filter]/[filterOrder]), the in-progress selection
/// ([selected]) and the last [appliedFilter] actually used to fetch results.
/// The grid accumulates paged results in [result].
class SingleSearchPageState {
  final String query;
  final int page;
  bool isLoading;
  final List<ExtensionListItem> result;
  final Map<String, ExtensionFilter> filter;
  final List<String> filterOrder; // Stable order of filters
  final bool isUpdateFilter;
  final Map<String, List<String>>
  selected; // Keyed by filter key, values are option keys
  final proto.FilterSelection? appliedFilter;
  final String pkg;

  SingleSearchPageState({
    this.query = '',
    this.page = 1,
    this.isLoading = false,
    this.result = const [],
    this.filter = const {},
    this.filterOrder = const [],
    this.isUpdateFilter = false,
    this.selected = const {},
    this.appliedFilter,
    this.pkg = '',
  });

  SingleSearchPageState copyWith({
    String? query,
    int? page,
    bool? isLoading,
    List<ExtensionListItem>? result,
    Map<String, ExtensionFilter>? filter,
    List<String>? filterOrder,
    bool? isUpdateFilter,
    Map<String, List<String>>? selected,
    proto.FilterSelection? appliedFilter,
    String? pkg,
  }) {
    return SingleSearchPageState(
      query: query ?? this.query,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      filter: filter ?? this.filter,
      filterOrder: filterOrder ?? this.filterOrder,
      isUpdateFilter: isUpdateFilter ?? this.isUpdateFilter,
      selected: selected ?? this.selected,
      appliedFilter: appliedFilter ?? this.appliedFilter,
      pkg: pkg ?? this.pkg,
    );
  }

  /// Human-readable summary of every active filter selection, joining the
  /// selected option labels (in [filterOrder]) for the filtered-state chip row.
  String get filterSummary {
    final List<String> selectedLabels = [];
    for (final key in filterOrder) {
      final extFilter = filter[key];
      if (extFilter == null) continue;
      final selectedOptionKeys = selected[key];
      if (selectedOptionKeys == null || selectedOptionKeys.isEmpty) continue;

      final view = ExtensionFilterView.from(extFilter);
      final labelByKey = {for (final o in view.options) o.key: o.label};
      for (final optionKey in selectedOptionKeys) {
        if (labelByKey.containsKey(optionKey)) {
          selectedLabels.add(labelByKey[optionKey]!);
        }
      }
    }
    return selectedLabels.join(', ');
  }

  /// Flattened wire format of the current selection: single-select keys map to
  /// one value, multi/range keys to a list. Rows with no selection send an
  /// empty string so the extension keeps their filter untouched.
  Map<String, dynamic> get filterSelectionMap {
    final Map<String, dynamic> selection = {};
    for (final key in filterOrder) {
      final extFilter = filter[key];
      if (extFilter == null) continue;
      final optionKeys = selected[key];

      if (optionKeys == null || optionKeys.isEmpty) {
        selection[key] = "";
        continue;
      }

      final view = ExtensionFilterView.from(extFilter);
      if (view.isSingleSelect || view.max == 1) {
        selection[key] = optionKeys.first;
      } else {
        selection[key] = optionKeys;
      }
    }
    return selection;
  }

  /// Protobuf [proto.FilterSelection] derived from the currently [selected]
  /// option keys, ready to send to the extension endpoint.
  proto.FilterSelection get filterSelection {
    final s = proto.FilterSelection();
    for (final key in filterOrder) {
      final optionKeys = selected[key];
      if (optionKeys == null || optionKeys.isEmpty) continue;
      s.selections[key] = (proto.FilterSelectionValue()
        ..values.addAll(optionKeys));
    }
    return s;
  }
}

/// Per-extension search provider backing the `/search/single` page.
///
/// Unlike the cross-extension [SearchPageProvider], it is scoped to one
/// installed extension ([SingleSearchPageState.pkg]) and carries that
/// extension's own filter catalogue. Pages increment [SingleSearchPageState.page]
/// as the grid is scrolled; only the committed [SingleSearchPageState.appliedFilter]
/// is sent to the extension when fetching results.
// @Riverpod(keepAlive: true)
@riverpod
class SearchPageSingleProvider extends _$SearchPageSingleProvider {
  @override
  SingleSearchPageState build() {
    return SingleSearchPageState();
  }

  /// Starts a fresh search for [q] on this extension, resetting pagination to
  /// page 1 and locking in the current selection as the applied filter so the
  /// grid refetches immediately.
  void setQuery(String q) async {
    state = state.copyWith(
      query: q,
      page: 1,
      isLoading: true,
      appliedFilter: state.filterSelection,
    );
  }

  /// Freezes the in-progress [SingleSearchPageState.selected] into
  /// [appliedFilter]. Until this is called, edited filter controls do not yet
  /// affect the displayed results.
  void commitFilters() {
    state = state.copyWith(appliedFilter: state.filterSelection);
  }

  void setPage(int p) => state = state.copyWith(page: p);

  void incPage() => state = state.copyWith(page: state.page + 1);

  void setLoading(bool l) => state = state.copyWith(isLoading: l);

  void setResult(List<ExtensionListItem> r) =>
      state = state.copyWith(result: r);

  void addResult(List<ExtensionListItem> r) =>
      state = state.copyWith(result: [...state.result, ...r]);

  void clearResult() => state = state.copyWith(result: []);

  /// Replaces the extension's filter catalogue and seeds each filter's default
  /// selection only when the row is still empty (preserves any user edits).
  void setFileNotifier(Map<String, ExtensionFilter> m) {
    final Map<String, List<String>> newSelected = Map.from(state.selected);
    for (final key in m.keys) {
      // Initialize if selection is empty and a default is available
      if (newSelected[key] == null || newSelected[key]!.isEmpty) {
        final def = _defaultSelection(m[key]!);
        newSelected[key] = def;
      }
    }
    state = state.copyWith(
      filter: Map.from(m),
      filterOrder: m.keys.toList(),
      selected: newSelected,
    );
  }

  /// Returns the default selection for a raw filter, covering all three filter
  /// kinds: the pre-selected option for selects, the default list for
  /// multi-selects, and the [defaultMin, defaultMax] pair for ranges.
  List<String> _defaultSelection(ExtensionFilter filter) {
    switch (filter.whichKind()) {
      case pb.ExtensionFilter_Kind.select:
        final d = filter.select.default_2;
        return d.isEmpty ? [] : [d];
      case pb.ExtensionFilter_Kind.multiSelect:
        return List.from(filter.multiSelect.default_4);
      case pb.ExtensionFilter_Kind.range:
        return [
          filter.range.defaultMin.toString(),
          filter.range.defaultMax.toString(),
        ];
      case pb.ExtensionFilter_Kind.notSet:
        return const [];
    }
  }

  void addFileNotifier(Map<String, ExtensionFilter> m) =>
      state = state.copyWith(filter: {...state.filter, ...m});

  void setIsUpdateFilter(bool v) => state = state.copyWith(isUpdateFilter: v);

  void setFilterValue(String key, List<String> val) async {
    final filter = state.filter[key];
    if (filter == null) return;

    final view = ExtensionFilterView.from(filter);
    final effectiveMin = view.isSingleSelect ? 1 : view.min;
    final effectiveMax = view.isSingleSelect ? 1 : view.max;

    List<String> newVal = val;
    // Enforce max count
    if (newVal.length > effectiveMax) {
      if (effectiveMax == 1) {
        newVal = [newVal.last];
      } else {
        newVal = newVal.take(effectiveMax).toList();
      }
    }

    // Enforce min count
    if (newVal.length < effectiveMin) {
      final current = state.selected[key] ?? [];
      if (current.length >= effectiveMin) {
        newVal = current;
      }
    }

    final newSelected = Map<String, List<String>>.from(state.selected);
    newSelected[key] = newVal;
    state = state.copyWith(selected: newSelected);
    await _updateFilters();
  }

  void setSelected(Map<String, List<String>> val) async {
    state = state.copyWith(selected: val);
    await _updateFilters();
  }

  /// Sets a numeric [RangeFilter] value, clamping [from]/[to] to the filter's
  /// declared bounds. Range selections bypass the select/multi count limits.
  void setRangeFilter(String key, int from, int to) {
    final filter = state.filter[key];
    if (filter == null ||
        filter.whichKind() != pb.ExtensionFilter_Kind.range) {
      return;
    }
    final r = filter.range;
    final fromClamped = from.clamp(r.min, r.max);
    final toClamped = to.clamp(r.min, r.max);
    final newSelected = Map<String, List<String>>.from(state.selected);
    newSelected[key] = [fromClamped.toString(), toClamped.toString()];
    state = state.copyWith(selected: newSelected);
  }

  /// Resets a single filter key back to its extension-declared default.
  void resetFilterToDefault(String key) {
    final filter = state.filter[key];
    if (filter == null) return;
    final newSelected = Map<String, List<String>>.from(state.selected);
    newSelected[key] = _defaultSelection(filter);
    state = state.copyWith(selected: newSelected);
  }

  /// Clears a single filter key entirely (used for an explicit "All"/none
  /// choice on single-select filters, bypassing the min-selection limit).
  void clearFilterValue(String key) {
    final newSelected = Map<String, List<String>>.from(state.selected);
    newSelected[key] = [];
    state = state.copyWith(selected: newSelected);
  }

  Future<void> _updateFilters() async {
    // Update filters dynamically
    if (state.pkg.isNotEmpty) {
      final selectionProto = proto.FilterSelection();
      for (final key in state.filterOrder) {
        final extFilter = state.filter[key];
        if (extFilter == null) continue;
        final selectedOptionKeys = state.selected[key];
        if (selectedOptionKeys == null || selectedOptionKeys.isEmpty) {
          continue;
        }
        selectionProto.selections[key] = (proto.FilterSelectionValue()
          ..values.addAll(selectedOptionKeys));
      }

      try {
        final newFilters = await MiruCoreEndpoint.createFilter(
          state.pkg,
          filter: selectionProto,
        );

        final currentKeys = state.filterOrder;
        final newKeys = newFilters.keys.toList();

        final mergedKeys = [...currentKeys];
        for (final k in newKeys) {
          if (!mergedKeys.contains(k)) {
            mergedKeys.add(k);
          }
        }
        // Remove keys that are no longer present
        mergedKeys.removeWhere((k) => !newKeys.contains(k));

        state = state.copyWith(filter: newFilters, filterOrder: mergedKeys);
      } catch (e) {
        logger.info(e.toString());
      }
    }
  }

  void setPkg(String pkg) {
    if (state.pkg == pkg) return;
    state = SingleSearchPageState(pkg: pkg);
  }

  Future<void> fetchInitialFilters() async {
    if (state.pkg.isEmpty) return;
    try {
      final filters = await MiruCoreEndpoint.createFilter(state.pkg);
      setFileNotifier(filters);
      commitFilters();
    } catch (e) {
      logger.info(e.toString());
    }
  }

  Future<void> clearFiltersToDefault() async {
    final Map<String, List<String>> defaultSelected = {};
    for (final key in state.filterOrder) {
      defaultSelected[key] = _defaultSelection(state.filter[key]!);
    }

    // Check if changed
    bool changed = false;
    for (final key in state.filterOrder) {
      final current = state.selected[key] ?? [];
      final def = defaultSelected[key] ?? [];
      if (current.length != def.length ||
          !current.every((e) => def.contains(e))) {
        changed = true;
        break;
      }
    }

    if (changed) {
      state = state.copyWith(selected: defaultSelected);
      await _updateFilters();
    }
    commitFilters();
  }
}
