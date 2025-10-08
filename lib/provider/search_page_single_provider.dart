import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_app_new/model/index.dart';

part 'search_page_single_provider.g.dart';

class SingleSearchPageState {
  final String query;
  final int page;
  bool isLoading;
  final List<ExtensionListItem> result;
  final Map<String, ExtensionFilter> fileNotifier;
  final bool isUpdateFilter;
  final List<List<int>> selected;

  SingleSearchPageState({
    this.query = '',
    this.page = 1,
    this.isLoading = false,
    this.result = const [],
    this.fileNotifier = const {},
    this.isUpdateFilter = false,
    this.selected = const [],
  });

  SingleSearchPageState copyWith({
    String? query,
    int? page,
    bool? isLoading,
    List<ExtensionListItem>? result,
    Map<String, ExtensionFilter>? fileNotifier,
    bool? isUpdateFilter,
    List<List<int>>? selected,
  }) {
    return SingleSearchPageState(
      query: query ?? this.query,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      fileNotifier: fileNotifier ?? this.fileNotifier,
      isUpdateFilter: isUpdateFilter ?? this.isUpdateFilter,
      selected: selected ?? this.selected,
    );
  }
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
    state = state.copyWith(query: q, page: 1, isLoading: true);
    // // state.isLoading = true;
    // final result = await ExtensionEndpoint.search(
    //   'all',
    //   q,
    //   1,
    //   filter: state.fileNotifier,
    // );
    // state = state.copyWith(result: result, isLoading: false);
  }

  void setPage(int p) => state = state.copyWith(page: p);

  void incPage() => state = state.copyWith(page: state.page + 1);

  void setLoading(bool l) => state = state.copyWith(isLoading: l);

  void setResult(List<ExtensionListItem> r) =>
      state = state.copyWith(result: r);

  void addResult(List<ExtensionListItem> r) =>
      state = state.copyWith(result: [...state.result, ...r]);

  void clearResult() => state = state.copyWith(result: []);

  void setFileNotifier(Map<String, ExtensionFilter> m) =>
      state = state.copyWith(fileNotifier: Map.from(m));

  void addFileNotifier(Map<String, ExtensionFilter> m) =>
      state = state.copyWith(fileNotifier: {...state.fileNotifier, ...m});

  void setIsUpdateFilter(bool v) => state = state.copyWith(isUpdateFilter: v);

  void initializeSelected(int len) =>
      state = state.copyWith(selected: List.generate(len, (_) => <int>[]));

  void setSelectedIndex(int index, List<int> val) {
    final newSelected = List<List<int>>.from(state.selected);
    if (index >= newSelected.length) newSelected.length = index + 1;
    newSelected[index] = val;
    state = state.copyWith(selected: newSelected);
  }
}
