// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detial_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Detial)
const detialProvider = DetialProvider._();

final class DetialProvider extends $NotifierProvider<Detial, DetialState> {
  const DetialProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'detialProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$detialHash();

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
}

String _$detialHash() => r'0ea849cbc34dc31b7429f3e4c39d12672c26e49f';

abstract class _$Detial extends $Notifier<DetialState> {
  DetialState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DetialState, DetialState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DetialState, DetialState>,
              DetialState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
