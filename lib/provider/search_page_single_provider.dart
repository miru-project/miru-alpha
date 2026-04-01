import 'dart:convert';

import 'package:miru_alpha/miru_core/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_alpha/model/index.dart';

part 'search_page_single_provider.g.dart';

class SingleSearchPageState {
  final String query;
  final int page;
  bool isLoading;
  final List<ExtensionListItem> result;
  final Map<String, ExtensionFilter> filter;
  final List<String> filterOrder; // Stable order of filters
  final bool isUpdateFilter;
  final Map<String, List<String>> selected; // Keyed by filter key, values are option keys
  final String appliedFilterJson;
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
    this.appliedFilterJson = '',
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
    String? appliedFilterJson,
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
      appliedFilterJson: appliedFilterJson ?? this.appliedFilterJson,
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

      final options = extFilter.options;
      for (final optionKey in selectedOptionKeys) {
        if (options.containsKey(optionKey)) {
          selectedLabels.add(options[optionKey]!);
        }
      }
    }
    return selectedLabels.join(', ');
  }

  Map<String, dynamic> get filterSelection {
    final Map<String, dynamic> selection = {};
    for (final key in filterOrder) {
      final extFilter = filter[key];
      if (extFilter == null) continue;
      final optionKeys = selected[key];

      if (optionKeys == null || optionKeys.isEmpty) {
        selection[key] = "";
        continue;
      }

      if (extFilter.max == 1) {
        selection[key] = optionKeys.first;
      } else {
        selection[key] = optionKeys;
      }
    }
    return selection;
  }

  String get filterSelectionJson => jsonEncode(filterSelection);
}

// @Riverpod(keepAlive: true)
@riverpod
class SearchPageSingleProvider extends _$SearchPageSingleProvider {
  @override
  SingleSearchPageState build() {
    return SingleSearchPageState();
  }

  // Mutators for fields that used to be ValueNotifiers
  void setQuery(String q) async {
    state = state.copyWith(
      query: q,
      page: 1,
      isLoading: true,
      appliedFilterJson: state.filterSelectionJson,
    );
  }

  void commitFilters() {
    state = state.copyWith(appliedFilterJson: state.filterSelectionJson);
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
      final extFilter = m[key]!;
      // Initialize if selection is empty and a default is available
      if (newSelected[key] == null || newSelected[key]!.isEmpty) {
        if (extFilter.hasDefault_4() && extFilter.default_4.isNotEmpty) {
          newSelected[key] = [extFilter.default_4];
        } else {
          newSelected[key] = [];
        }
      }
    }
    state = state.copyWith(
      filter: Map.from(m),
      filterOrder: m.keys.toList(),
      selected: newSelected,
    );
  }

  void addFileNotifier(Map<String, ExtensionFilter> m) =>
      state = state.copyWith(filter: {...state.filter, ...m});

  void setIsUpdateFilter(bool v) => state = state.copyWith(isUpdateFilter: v);

  void setFilterValue(String key, List<String> val) async {
    final filter = state.filter[key];
    if (filter == null) return;

    // Use default of 1 if min/max are 0 in direct accordance with user requirements
    final effectiveMin = filter.min == 0 ? 1 : filter.min;
    final effectiveMax = filter.max == 0 ? 1 : filter.max;

    List<String> newVal = val;
    // Enforce max count
    if (newVal.length > effectiveMax) {
      if (effectiveMax == 1) {
        // Radio behavior: if we exceed 1, take the newest selection (the last one)
        newVal = [newVal.last];
      } else {
        // Multi-select behavior: cap at max
        newVal = newVal.take(effectiveMax).toList();
      }
    }
    
    // Enforce min count
    if (newVal.length < effectiveMin) {
      // If the new selection is smaller than min, revert to previous or keep current if it's already at min
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
      final selection = <String, dynamic>{};
      for (final key in state.filterOrder) {
        final options = state.filter[key]?.options;
        if (options == null) continue;
        final selectedOptionKeys = state.selected[key] ?? [];

        if (state.filter[key]!.max == 1) {
          selection[key] = selectedOptionKeys.isEmpty ? "" : selectedOptionKeys.first;
        } else {
          selection[key] = selectedOptionKeys;
        }
      }

      try {
        final newFilters = await MiruCoreEndpoint.createFilter(
          state.pkg,
          filter: jsonEncode(selection),
        );
        
        // Merge new filters while maintaining order
        final currentKeys = state.filterOrder;
        final newKeys = newFilters.keys.toList();
        
        // We want to keep current keys in order, and add new ones at the end
        final mergedKeys = [...currentKeys];
        for (final k in newKeys) {
          if (!mergedKeys.contains(k)) {
            mergedKeys.add(k);
          }
        }
        // Remove keys that are no longer present
        mergedKeys.removeWhere((k) => !newKeys.contains(k));

        state = state.copyWith(
          filter: newFilters,
          filterOrder: mergedKeys,
        );
      } catch (e) {
        // Handle error or ignore
      }
    }
  }

  void setPkg(String pkg) => state = state.copyWith(pkg: pkg);

  Future<void> fetchInitialFilters() async {
    if (state.pkg.isEmpty) return;
    try {
      final filters = await MiruCoreEndpoint.createFilter(state.pkg);
      setFileNotifier(filters);
    } catch (e) {
      // Ignore
    }
  }
}
