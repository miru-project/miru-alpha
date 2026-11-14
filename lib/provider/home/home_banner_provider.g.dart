// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_banner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeBannerSelection)
final homeBannerSelectionProvider = HomeBannerSelectionProvider._();

final class HomeBannerSelectionProvider
    extends $NotifierProvider<HomeBannerSelection, HomeBannerSelectionState> {
  HomeBannerSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeBannerSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeBannerSelectionHash();

  @$internal
  @override
  HomeBannerSelection create() => HomeBannerSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeBannerSelectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeBannerSelectionState>(value),
    );
  }
}

String _$homeBannerSelectionHash() =>
    r'1e12b553317299e87ff29760d42216f937024950';

abstract class _$HomeBannerSelection
    extends $Notifier<HomeBannerSelectionState> {
  HomeBannerSelectionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<HomeBannerSelectionState, HomeBannerSelectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeBannerSelectionState, HomeBannerSelectionState>,
              HomeBannerSelectionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Home banner catalogue for the current [HomeBannerSelectionState].
///
/// keepAlive like [HomeTrending]: revisiting the home tab must not re-query
/// TMDB or AniList; the fetch re-runs only when the selection changes or
/// through [refresh]. Rides the backend connection gate first.

@ProviderFor(HomeBanner)
final homeBannerProvider = HomeBannerProvider._();

/// Home banner catalogue for the current [HomeBannerSelectionState].
///
/// keepAlive like [HomeTrending]: revisiting the home tab must not re-query
/// TMDB or AniList; the fetch re-runs only when the selection changes or
/// through [refresh]. Rides the backend connection gate first.
final class HomeBannerProvider
    extends $AsyncNotifierProvider<HomeBanner, List<HomeBannerItem>> {
  /// Home banner catalogue for the current [HomeBannerSelectionState].
  ///
  /// keepAlive like [HomeTrending]: revisiting the home tab must not re-query
  /// TMDB or AniList; the fetch re-runs only when the selection changes or
  /// through [refresh]. Rides the backend connection gate first.
  HomeBannerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeBannerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeBannerHash();

  @$internal
  @override
  HomeBanner create() => HomeBanner();
}

String _$homeBannerHash() => r'29997049417d32e1c4c74577e288ea2aa887c8e0';

/// Home banner catalogue for the current [HomeBannerSelectionState].
///
/// keepAlive like [HomeTrending]: revisiting the home tab must not re-query
/// TMDB or AniList; the fetch re-runs only when the selection changes or
/// through [refresh]. Rides the backend connection gate first.

abstract class _$HomeBanner extends $AsyncNotifier<List<HomeBannerItem>> {
  FutureOr<List<HomeBannerItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<HomeBannerItem>>, List<HomeBannerItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<HomeBannerItem>>,
                List<HomeBannerItem>
              >,
              AsyncValue<List<HomeBannerItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
