// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_nav_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mirrors the active [DetailNavState]; null when no detail page has synced.
/// Never cleared on route exit: the top-bar buttons hide themselves off-detail
/// by watching the router, avoiding dispose/initState ordering races between
/// replaced detail routes.

@ProviderFor(DetailNav)
final detailNavProvider = DetailNavProvider._();

/// Mirrors the active [DetailNavState]; null when no detail page has synced.
/// Never cleared on route exit: the top-bar buttons hide themselves off-detail
/// by watching the router, avoiding dispose/initState ordering races between
/// replaced detail routes.
final class DetailNavProvider
    extends $NotifierProvider<DetailNav, DetailNavState?> {
  /// Mirrors the active [DetailNavState]; null when no detail page has synced.
  /// Never cleared on route exit: the top-bar buttons hide themselves off-detail
  /// by watching the router, avoiding dispose/initState ordering races between
  /// replaced detail routes.
  DetailNavProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'detailNavProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$detailNavHash();

  @$internal
  @override
  DetailNav create() => DetailNav();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DetailNavState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DetailNavState?>(value),
    );
  }
}

String _$detailNavHash() => r'88db69a1878f97c1a606e7f10257494045dcb9ca';

/// Mirrors the active [DetailNavState]; null when no detail page has synced.
/// Never cleared on route exit: the top-bar buttons hide themselves off-detail
/// by watching the router, avoiding dispose/initState ordering races between
/// replaced detail routes.

abstract class _$DetailNav extends $Notifier<DetailNavState?> {
  DetailNavState? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DetailNavState?, DetailNavState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DetailNavState?, DetailNavState?>,
              DetailNavState?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
