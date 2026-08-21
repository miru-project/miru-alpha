import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/domain/models/search.dart';
import 'package:miru_alpha/domain/use_cases/filter_search.dart';

part 'search_view_model.g.dart';

@riverpod
class SearchViewModel extends _$SearchViewModel {
  @override
  Future<DomainSearchState> build() async {
    return const DomainSearchState(extensions: [], query: '', isLoading: false);
  }

  FilterSearchUseCase get _filterUseCase => FilterSearchUseCase();

  Future<void> search(String query) async {
    final provider = ref.read(searchPageProvider.notifier);
    provider.setQuery(query);
  }

  void applyFilter(DomainSearchFilter filter) {
    final current = state.value;
    if (current == null) return;

    final filtered = _filterUseCase(
      extensions: current.extensions,
      filter: filter,
    );

    state = AsyncValue.data(
      current.copyWith(
        extensions: filtered,
        selectedLang: filter.lang,
        selectedType: filter.type,
      ),
    );
  }
}
