// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anilist_track_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnilistTrackPage)
final anilistTrackPageProvider = AnilistTrackPageFamily._();

final class AnilistTrackPageProvider
    extends $NotifierProvider<AnilistTrackPage, AnilistTrackPageState> {
  AnilistTrackPageProvider._({
    required AnilistTrackPageFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'anilistTrackPageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$anilistTrackPageHash();

  @override
  String toString() {
    return r'anilistTrackPageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AnilistTrackPage create() => AnilistTrackPage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnilistTrackPageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnilistTrackPageState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AnilistTrackPageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$anilistTrackPageHash() => r'59dfda5131c8bf8812d52cee4921f6eeef7ec3ed';

final class AnilistTrackPageFamily extends $Family
    with
        $ClassFamilyOverride<
          AnilistTrackPage,
          AnilistTrackPageState,
          AnilistTrackPageState,
          AnilistTrackPageState,
          int
        > {
  AnilistTrackPageFamily._()
    : super(
        retry: null,
        name: r'anilistTrackPageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AnilistTrackPageProvider call(int mediaId) =>
      AnilistTrackPageProvider._(argument: mediaId, from: this);

  @override
  String toString() => r'anilistTrackPageProvider';
}

abstract class _$AnilistTrackPage extends $Notifier<AnilistTrackPageState> {
  late final _$args = ref.$arg as int;
  int get mediaId => _$args;

  AnilistTrackPageState build(int mediaId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AnilistTrackPageState, AnilistTrackPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AnilistTrackPageState, AnilistTrackPageState>,
              AnilistTrackPageState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
