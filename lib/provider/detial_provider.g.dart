// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detial_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Detial)
final detialProvider = DetialFamily._();

final class DetialProvider extends $NotifierProvider<Detial, DetialState> {
  DetialProvider._({
    required DetialFamily super.from,
    required (String, {ExtensionMeta meta}) super.argument,
  }) : super(
         retry: null,
         name: r'detialProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detialHash();

  @override
  String toString() {
    return r'detialProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  Detial create() => Detial();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DetialState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DetialState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DetialProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detialHash() => r'd193685a69ec8c551cdc2012ccaec1634d7e1357';

final class DetialFamily extends $Family
    with
        $ClassFamilyOverride<
          Detial,
          DetialState,
          DetialState,
          DetialState,
          (String, {ExtensionMeta meta})
        > {
  DetialFamily._()
    : super(
        retry: null,
        name: r'detialProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DetialProvider call(String detailUrl, {required ExtensionMeta meta}) =>
      DetialProvider._(argument: (detailUrl, meta: meta), from: this);

  @override
  String toString() => r'detialProvider';
}

abstract class _$Detial extends $Notifier<DetialState> {
  late final _$args = ref.$arg as (String, {ExtensionMeta meta});
  String get detailUrl => _$args.$1;
  ExtensionMeta get meta => _$args.meta;

  DetialState build(String detailUrl, {required ExtensionMeta meta});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DetialState, DetialState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DetialState, DetialState>,
              DetialState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, meta: _$args.meta));
  }
}
