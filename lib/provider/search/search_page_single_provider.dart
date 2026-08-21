import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/utils/core/log.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/features/search/extension_filter_view.dart';

part 'search_page_single_provider.g.dart';

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

// @Riverpod(keepAlive: true)
@riverpod
class SearchPageSingleProvider extends _$SearchPageSingleProvider {
  @override
  SingleSearchPageState build() {
    return SingleSearchPageState();
  }

  void setQuery(String q) async {
    state = state.copyWith(
      query: q,
      page: 1,
      isLoading: true,
      appliedFilter: state.filterSelection,
    );
  }

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

  void setFileNotifier(Map<String, ExtensionFilter> m) {
    final Map<String, List<String>> newSelected = Map.from(state.selected);
    for (final key in m.keys) {
      final view = ExtensionFilterView.from(m[key]!);
      // Initialize if selection is empty and a default is available
      if (newSelected[key] == null || newSelected[key]!.isEmpty) {
        final def = _defaultSelection(view);
        newSelected[key] = def;
      }
    }
    state = state.copyWith(
      filter: Map.from(m),
      filterOrder: m.keys.toList(),
      selected: newSelected,
    );
  }

  /// Returns the default selection for a filter view: the first default value
  /// for multi-select, or an empty list otherwise.
  List<String> _defaultSelection(ExtensionFilterView view) {
    if (view.defaultSelect.isNotEmpty) return [view.defaultSelect];
    if (view.defaultMultiSelect.isNotEmpty) {
      return List.from(view.defaultMultiSelect);
    }
    return [];
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

  void clearFiltersToDefault() async {
    final Map<String, List<String>> defaultSelected = {};
    for (final key in state.filterOrder) {
      final view = ExtensionFilterView.from(state.filter[key]!);
      defaultSelected[key] = _defaultSelection(view);
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
