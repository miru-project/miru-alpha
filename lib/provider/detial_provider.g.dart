// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detial_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Detial)
final detialProvider = DetialProvider._();

final class DetialProvider extends $NotifierProvider<Detial, DetialState> {
  DetialProvider._()
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

String _$detialHash() => r'c67e402a3fb944b6efbcc6deabccbf887dd45abb';

abstract class _$Detial extends $Notifier<DetialState> {
  DetialState build();
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
    element.handleCreate(ref, build);
  }
}
