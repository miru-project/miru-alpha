// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_trending_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Trending catalogue for the home rail.
///
/// One merged query over AniList's public trending list (anime and manga
/// mixed), fetched once per app run and refreshed only through [refresh] —
/// keepAlive so revisiting the home tab never re-queries the API.

@ProviderFor(HomeTrending)
final homeTrendingProvider = HomeTrendingProvider._();

/// Trending catalogue for the home rail.
///
/// One merged query over AniList's public trending list (anime and manga
/// mixed), fetched once per app run and refreshed only through [refresh] —
/// keepAlive so revisiting the home tab never re-queries the API.
final class HomeTrendingProvider
    extends $AsyncNotifierProvider<HomeTrending, List<AnilistMedia>> {
  /// Trending catalogue for the home rail.
  ///
  /// One merged query over AniList's public trending list (anime and manga
  /// mixed), fetched once per app run and refreshed only through [refresh] —
  /// keepAlive so revisiting the home tab never re-queries the API.
  HomeTrendingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeTrendingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeTrendingHash();

  @$internal
  @override
  HomeTrending create() => HomeTrending();
}

String _$homeTrendingHash() => r'9b64a1879257f49c45d733b3e6b2bb86726906c5';

/// Trending catalogue for the home rail.
///
/// One merged query over AniList's public trending list (anime and manga
/// mixed), fetched once per app run and refreshed only through [refresh] —
/// keepAlive so revisiting the home tab never re-queries the API.

abstract class _$HomeTrending extends $AsyncNotifier<List<AnilistMedia>> {
  FutureOr<List<AnilistMedia>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<AnilistMedia>>, List<AnilistMedia>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AnilistMedia>>, List<AnilistMedia>>,
              AsyncValue<List<AnilistMedia>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
