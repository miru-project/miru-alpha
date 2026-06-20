// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchPageNotifier)
final searchPageProvider = SearchPageNotifierProvider._();

final class SearchPageNotifierProvider
    extends $NotifierProvider<SearchPageNotifier, SearchPageState> {
  SearchPageNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchPageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchPageNotifierHash();

  @$internal
  @override
  SearchPageNotifier create() => SearchPageNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchPageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchPageState>(value),
    );
  }
}

String _$searchPageNotifierHash() =>
    r'd8fba467383d6a2291f5c661a3da99e63b5eba9a';

abstract class _$SearchPageNotifier extends $Notifier<SearchPageState> {
  SearchPageState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SearchPageState, SearchPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchPageState, SearchPageState>,
              SearchPageState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
