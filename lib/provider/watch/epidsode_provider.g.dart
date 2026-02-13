// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epidsode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EpisodeNotifier)
final episodeProvider = EpisodeNotifierFamily._();

final class EpisodeNotifierProvider
    extends $NotifierProvider<EpisodeNotifier, EpisodeNotifierState> {
  EpisodeNotifierProvider._({
    required EpisodeNotifierFamily super.from,
    required WatchParams super.argument,
  }) : super(
         retry: null,
         name: r'episodeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$episodeNotifierHash();

  @override
  String toString() {
    return r'episodeProvider'
        ''
        '($argument)';
  }

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

  @override
  bool operator ==(Object other) {
    return other is EpisodeNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$episodeNotifierHash() => r'00c609f6fcfc2d4e8137b35fb6e4e7c667af2a54';

final class EpisodeNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          EpisodeNotifier,
          EpisodeNotifierState,
          EpisodeNotifierState,
          EpisodeNotifierState,
          WatchParams
        > {
  EpisodeNotifierFamily._()
    : super(
        retry: null,
        name: r'episodeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EpisodeNotifierProvider call(WatchParams param) =>
      EpisodeNotifierProvider._(argument: param, from: this);

  @override
  String toString() => r'episodeProvider';
}

abstract class _$EpisodeNotifier extends $Notifier<EpisodeNotifierState> {
  late final _$args = ref.$arg as WatchParams;
  WatchParams get param => _$args;

  EpisodeNotifierState build(WatchParams param);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EpisodeNotifierState, EpisodeNotifierState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EpisodeNotifierState, EpisodeNotifierState>,
              EpisodeNotifierState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
