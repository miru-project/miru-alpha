// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_controller_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ApplicationController)
final applicationControllerProvider = ApplicationControllerProvider._();

final class ApplicationControllerProvider
    extends $NotifierProvider<ApplicationController, ApplicationState> {
  ApplicationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applicationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applicationControllerHash();

  @$internal
  @override
  ApplicationController create() => ApplicationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApplicationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApplicationState>(value),
    );
  }
}

String _$applicationControllerHash() =>
    r'b1a9b38b3f4c404d7df205b810ebeeb3d34a1c21';

abstract class _$ApplicationController extends $Notifier<ApplicationState> {
  ApplicationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ApplicationState, ApplicationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ApplicationState, ApplicationState>,
              ApplicationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
