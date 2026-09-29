// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_page_single_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Per-extension search provider backing the `/search/single` page.
///
/// Unlike the cross-extension [SearchPageProvider], it is scoped to one
/// installed extension ([SingleSearchPageState.pkg]) and carries that
/// extension's own filter catalogue. Pages increment [SingleSearchPageState.page]
/// as the grid is scrolled; only the committed [SingleSearchPageState.appliedFilter]
/// is sent to the extension when fetching results.
// @Riverpod(keepAlive: true)

@ProviderFor(SearchPageSingleProvider)
final searchPageSingleProviderProvider = SearchPageSingleProviderProvider._();

/// Per-extension search provider backing the `/search/single` page.
///
/// Unlike the cross-extension [SearchPageProvider], it is scoped to one
/// installed extension ([SingleSearchPageState.pkg]) and carries that
/// extension's own filter catalogue. Pages increment [SingleSearchPageState.page]
/// as the grid is scrolled; only the committed [SingleSearchPageState.appliedFilter]
/// is sent to the extension when fetching results.
// @Riverpod(keepAlive: true)
final class SearchPageSingleProviderProvider
    extends $NotifierProvider<SearchPageSingleProvider, SingleSearchPageState> {
  /// Per-extension search provider backing the `/search/single` page.
  ///
  /// Unlike the cross-extension [SearchPageProvider], it is scoped to one
  /// installed extension ([SingleSearchPageState.pkg]) and carries that
  /// extension's own filter catalogue. Pages increment [SingleSearchPageState.page]
  /// as the grid is scrolled; only the committed [SingleSearchPageState.appliedFilter]
  /// is sent to the extension when fetching results.
  // @Riverpod(keepAlive: true)
  SearchPageSingleProviderProvider._()
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
    r'30753c6044f866bcccc64109a37e053bbb46000e';

/// Per-extension search provider backing the `/search/single` page.
///
/// Unlike the cross-extension [SearchPageProvider], it is scoped to one
/// installed extension ([SingleSearchPageState.pkg]) and carries that
/// extension's own filter catalogue. Pages increment [SingleSearchPageState.page]
/// as the grid is scrolled; only the committed [SingleSearchPageState.appliedFilter]
/// is sent to the extension when fetching results.
// @Riverpod(keepAlive: true)

abstract class _$SearchPageSingleProvider
    extends $Notifier<SingleSearchPageState> {
  SingleSearchPageState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SingleSearchPageState, SingleSearchPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SingleSearchPageState, SingleSearchPageState>,
              SingleSearchPageState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
