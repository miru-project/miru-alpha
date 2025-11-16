// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DetailPageProvider)
const detailPageProviderProvider = DetailPageProviderProvider._();

final class DetailPageProviderProvider
    extends $NotifierProvider<DetailPageProvider, DetailPageProviderState> {
  const DetailPageProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'detailPageProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$detailPageProviderHash();

  @$internal
  @override
  DetailPageProvider create() => DetailPageProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DetailPageProviderState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DetailPageProviderState>(value),
    );
  }
}

String _$detailPageProviderHash() =>
    r'be46518217220abd65ff2755b1299852735a6ebe';

abstract class _$DetailPageProvider extends $Notifier<DetailPageProviderState> {
  DetailPageProviderState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<DetailPageProviderState, DetailPageProviderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DetailPageProviderState, DetailPageProviderState>,
              DetailPageProviderState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
