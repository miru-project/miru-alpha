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
    required (
      int,
      int,
      List<ExtensionEpisodeGroup>,
      String,
      bool,
      String,
      String,
      ExtensionType,
      String,
    )
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

String _$episodeNotifierHash() => r'95d21dff946ab4aef9b831265dfa2c5964b0069c';

final class EpisodeNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          EpisodeNotifier,
          EpisodeNotifierState,
          EpisodeNotifierState,
          EpisodeNotifierState,
          (
            int,
            int,
            List<ExtensionEpisodeGroup>,
            String,
            bool,
            String,
            String,
            ExtensionType,
            String,
          )
        > {
  EpisodeNotifierFamily._()
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
    String imageUrl,
    String detailUrl,
    ExtensionType type,
    String package,
  ) => EpisodeNotifierProvider._(
    argument: (
      groupIndex,
      episodeIndex,
      epGroup,
      name,
      flag,
      imageUrl,
      detailUrl,
      type,
      package,
    ),
    from: this,
  );

  @override
  String toString() => r'episodeProvider';
}

abstract class _$EpisodeNotifier extends $Notifier<EpisodeNotifierState> {
  late final _$args =
      ref.$arg
          as (
            int,
            int,
            List<ExtensionEpisodeGroup>,
            String,
            bool,
            String,
            String,
            ExtensionType,
            String,
          );
  int get groupIndex => _$args.$1;
  int get episodeIndex => _$args.$2;
  List<ExtensionEpisodeGroup> get epGroup => _$args.$3;
  String get name => _$args.$4;
  bool get flag => _$args.$5;
  String get imageUrl => _$args.$6;
  String get detailUrl => _$args.$7;
  ExtensionType get type => _$args.$8;
  String get package => _$args.$9;

  EpisodeNotifierState build(
    int groupIndex,
    int episodeIndex,
    List<ExtensionEpisodeGroup> epGroup,
    String name,
    bool flag,
    String imageUrl,
    String detailUrl,
    ExtensionType type,
    String package,
  );
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
    element.handleCreate(
      ref,
      () => build(
        _$args.$1,
        _$args.$2,
        _$args.$3,
        _$args.$4,
        _$args.$5,
        _$args.$6,
        _$args.$7,
        _$args.$8,
        _$args.$9,
      ),
    );
  }
}
