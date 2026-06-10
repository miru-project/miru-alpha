// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anilist_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnilistAccount)
final anilistAccountProvider = AnilistAccountProvider._();

final class AnilistAccountProvider
    extends $AsyncNotifierProvider<AnilistAccount, AnilistUser?> {
  AnilistAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'anilistAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$anilistAccountHash();

  @$internal
  @override
  AnilistAccount create() => AnilistAccount();
}

String _$anilistAccountHash() => r'1d95b824dd0013eff4e3d3bb53af640380a346da';

abstract class _$AnilistAccount extends $AsyncNotifier<AnilistUser?> {
  FutureOr<AnilistUser?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AnilistUser?>, AnilistUser?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AnilistUser?>, AnilistUser?>,
              AsyncValue<AnilistUser?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(TrackingStatusFilter)
final trackingStatusFilterProvider = TrackingStatusFilterProvider._();

final class TrackingStatusFilterProvider
    extends $NotifierProvider<TrackingStatusFilter, String?> {
  TrackingStatusFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackingStatusFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackingStatusFilterHash();

  @$internal
  @override
  TrackingStatusFilter create() => TrackingStatusFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$trackingStatusFilterHash() =>
    r'9633717ba13154f4fad388a1db0d46ede37c1d4c';

abstract class _$TrackingStatusFilter extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(AnilistCollectionNotifier)
final anilistCollectionProvider = AnilistCollectionNotifierFamily._();

final class AnilistCollectionNotifierProvider
    extends
        $AsyncNotifierProvider<AnilistCollectionNotifier, List<AnilistList>> {
  AnilistCollectionNotifierProvider._({
    required AnilistCollectionNotifierFamily super.from,
    required AnilistType super.argument,
  }) : super(
         retry: null,
         name: r'anilistCollectionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$anilistCollectionNotifierHash();

  @override
  String toString() {
    return r'anilistCollectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AnilistCollectionNotifier create() => AnilistCollectionNotifier();

  @override
  bool operator ==(Object other) {
    return other is AnilistCollectionNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$anilistCollectionNotifierHash() =>
    r'ede5e2aa7b7231d3518881139fd4c91243ac9526';

final class AnilistCollectionNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          AnilistCollectionNotifier,
          AsyncValue<List<AnilistList>>,
          List<AnilistList>,
          FutureOr<List<AnilistList>>,
          AnilistType
        > {
  AnilistCollectionNotifierFamily._()
    : super(
        retry: null,
        name: r'anilistCollectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AnilistCollectionNotifierProvider call(AnilistType type) =>
      AnilistCollectionNotifierProvider._(argument: type, from: this);

  @override
  String toString() => r'anilistCollectionProvider';
}

abstract class _$AnilistCollectionNotifier
    extends $AsyncNotifier<List<AnilistList>> {
  late final _$args = ref.$arg as AnilistType;
  AnilistType get type => _$args;

  FutureOr<List<AnilistList>> build(AnilistType type);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<AnilistList>>, List<AnilistList>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AnilistList>>, List<AnilistList>>,
              AsyncValue<List<AnilistList>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
