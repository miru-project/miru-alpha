// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_page_single_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchPageSingleProvider)
const searchPageSingleProviderProvider = SearchPageSingleProviderProvider._();

final class SearchPageSingleProviderProvider
    extends $NotifierProvider<SearchPageSingleProvider, SingleSearchPageState> {
  const SearchPageSingleProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchPageSingleProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchPageSingleProviderHash();

  @$internal
  @override
  SearchPageSingleProvider create() => SearchPageSingleProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SingleSearchPageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SingleSearchPageState>(value),
    );
  }
}

String _$searchPageSingleProviderHash() =>
    r'e5aaedbcb8ab749e0bce522a7d1bc4fbbaf86955';

abstract class _$SearchPageSingleProvider
    extends $Notifier<SingleSearchPageState> {
  SingleSearchPageState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SingleSearchPageState, SingleSearchPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SingleSearchPageState, SingleSearchPageState>,
              SingleSearchPageState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
