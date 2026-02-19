// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FavoritePageNotifier)
final favoritePageProvider = FavoritePageNotifierProvider._();

final class FavoritePageNotifierProvider
    extends $NotifierProvider<FavoritePageNotifier, FavoritePageState> {
  FavoritePageNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritePageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritePageNotifierHash();

  @$internal
  @override
  FavoritePageNotifier create() => FavoritePageNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoritePageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoritePageState>(value),
    );
  }
}

String _$favoritePageNotifierHash() =>
    r'b6b2cd1b22bdbb9228f51fcefa68450bc47d2ccc';

abstract class _$FavoritePageNotifier extends $Notifier<FavoritePageState> {
  FavoritePageState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FavoritePageState, FavoritePageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FavoritePageState, FavoritePageState>,
              FavoritePageState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
