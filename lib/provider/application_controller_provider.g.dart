// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_controller_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ApplicationController)
const applicationControllerProvider = ApplicationControllerProvider._();

final class ApplicationControllerProvider
    extends $NotifierProvider<ApplicationController, ApplicationState> {
  const ApplicationControllerProvider._()
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
    r'79aeb1c48ece02f51522c076b7a983ac288bc162';

abstract class _$ApplicationController extends $Notifier<ApplicationState> {
  ApplicationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ApplicationState, ApplicationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ApplicationState, ApplicationState>,
              ApplicationState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
