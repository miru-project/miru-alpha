// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FavoriteViewModel)
final favoriteViewModelProvider = FavoriteViewModelProvider._();

final class FavoriteViewModelProvider
    extends $AsyncNotifierProvider<FavoriteViewModel, FavoriteViewState> {
  FavoriteViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteViewModelHash();

  @$internal
  @override
  FavoriteViewModel create() => FavoriteViewModel();
}

String _$favoriteViewModelHash() => r'469c5bf3fa7499a99622f0bb11d65a003f9053a7';

abstract class _$FavoriteViewModel extends $AsyncNotifier<FavoriteViewState> {
  FutureOr<FavoriteViewState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<FavoriteViewState>, FavoriteViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FavoriteViewState>, FavoriteViewState>,
              AsyncValue<FavoriteViewState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
