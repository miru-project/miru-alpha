// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_tool_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DevTool)
final devToolProvider = DevToolProvider._();

final class DevToolProvider extends $NotifierProvider<DevTool, DevToolState> {
  DevToolProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'devToolProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$devToolHash();

  @$internal
  @override
  DevTool create() => DevTool();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DevToolState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DevToolState>(value),
    );
  }
}

String _$devToolHash() => r'35ede84ac1dd8897d81b35263b90e0148669b3c8';

abstract class _$DevTool extends $Notifier<DevToolState> {
  DevToolState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DevToolState, DevToolState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DevToolState, DevToolState>,
              DevToolState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
