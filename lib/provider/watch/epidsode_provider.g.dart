// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epidsode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EpisodeNotifier)
const episodeProvider = EpisodeNotifierProvider._();

final class EpisodeNotifierProvider
    extends $NotifierProvider<EpisodeNotifier, EpisodeNotifierState> {
  const EpisodeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'episodeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$episodeNotifierHash();

  @$internal
  @override
  EpisodeNotifier create() => EpisodeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EpisodeNotifierState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EpisodeNotifierState>(value),
    );
  }
}

String _$episodeNotifierHash() => r'17521be3b108ae0957ebfe7846c9a2d9402b786e';

abstract class _$EpisodeNotifier extends $Notifier<EpisodeNotifierState> {
  EpisodeNotifierState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<EpisodeNotifierState, EpisodeNotifierState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EpisodeNotifierState, EpisodeNotifierState>,
              EpisodeNotifierState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
