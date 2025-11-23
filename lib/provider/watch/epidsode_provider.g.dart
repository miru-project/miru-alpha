// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epidsode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EpisodeNotifier)
const episodeProvider = EpisodeNotifierFamily._();

final class EpisodeNotifierProvider
    extends $NotifierProvider<EpisodeNotifier, EpisodeNotifierState> {
  const EpisodeNotifierProvider._({
    required EpisodeNotifierFamily super.from,
    required (int, int, List<ExtensionEpisodeGroup>, String, bool)
    super.argument,
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
        '$argument';
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

String _$episodeNotifierHash() => r'a5cb0e33bd1d63d4797600f4f8f34abf14e1e111';

final class EpisodeNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          EpisodeNotifier,
          EpisodeNotifierState,
          EpisodeNotifierState,
          EpisodeNotifierState,
          (int, int, List<ExtensionEpisodeGroup>, String, bool)
        > {
  const EpisodeNotifierFamily._()
    : super(
        retry: null,
        name: r'episodeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EpisodeNotifierProvider call(
    int groupIndex,
    int episodeIndex,
    List<ExtensionEpisodeGroup> epGroup,
    String name,
    bool flag,
  ) => EpisodeNotifierProvider._(
    argument: (groupIndex, episodeIndex, epGroup, name, flag),
    from: this,
  );

  @override
  String toString() => r'episodeProvider';
}

abstract class _$EpisodeNotifier extends $Notifier<EpisodeNotifierState> {
  late final _$args =
      ref.$arg as (int, int, List<ExtensionEpisodeGroup>, String, bool);
  int get groupIndex => _$args.$1;
  int get episodeIndex => _$args.$2;
  List<ExtensionEpisodeGroup> get epGroup => _$args.$3;
  String get name => _$args.$4;
  bool get flag => _$args.$5;

  EpisodeNotifierState build(
    int groupIndex,
    int episodeIndex,
    List<ExtensionEpisodeGroup> epGroup,
    String name,
    bool flag,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args.$1,
      _$args.$2,
      _$args.$3,
      _$args.$4,
      _$args.$5,
    );
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
