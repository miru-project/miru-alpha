// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DetailPageProvider)
final detailPageProviderProvider = DetailPageProviderProvider._();

final class DetailPageProviderProvider
    extends $NotifierProvider<DetailPageProvider, DetailPageProviderState> {
  DetailPageProviderProvider._()
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
    r'7d6796c0d4419db4b40dcf970374ac5981f7495f';

abstract class _$DetailPageProvider extends $Notifier<DetailPageProviderState> {
  DetailPageProviderState build();
  @$mustCallSuper
  @override
  void runBuild() {
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
    element.handleCreate(ref, build);
  }
}
