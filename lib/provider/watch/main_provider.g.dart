// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MainNotifier)
const mainProvider = MainNotifierProvider._();

final class MainNotifierProvider
    extends $NotifierProvider<MainNotifier, MainPageState> {
  const MainNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mainProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mainNotifierHash();

  @$internal
  @override
  MainNotifier create() => MainNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MainPageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MainPageState>(value),
    );
  }
}

String _$mainNotifierHash() => r'dca4a50e77c5b74ffdabd3fdb5b610d6da4fa5f4';

abstract class _$MainNotifier extends $Notifier<MainPageState> {
  MainPageState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MainPageState, MainPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MainPageState, MainPageState>,
              MainPageState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
