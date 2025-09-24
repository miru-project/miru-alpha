// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_controller_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MainController)
const mainControllerProvider = MainControllerProvider._();

final class MainControllerProvider
    extends $NotifierProvider<MainController, MainState> {
  const MainControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mainControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mainControllerHash();

  @$internal
  @override
  MainController create() => MainController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MainState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MainState>(value),
    );
  }
}

String _$mainControllerHash() => r'56b7cde4a0a962fb50fbaa8e411abbc7ad5431ef';

abstract class _$MainController extends $Notifier<MainState> {
  MainState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MainState, MainState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MainState, MainState>,
              MainState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
