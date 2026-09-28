// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extension_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExtensionViewModel)
final extensionViewModelProvider = ExtensionViewModelProvider._();

final class ExtensionViewModelProvider
    extends $NotifierProvider<ExtensionViewModel, DomainExtensionViewState> {
  ExtensionViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'extensionViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$extensionViewModelHash();

  @$internal
  @override
  ExtensionViewModel create() => ExtensionViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DomainExtensionViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DomainExtensionViewState>(value),
    );
  }
}

String _$extensionViewModelHash() =>
    r'3668a0d9c56b1cf7d57cac7b54d32e78ccfb18f4';

abstract class _$ExtensionViewModel
    extends $Notifier<DomainExtensionViewState> {
  DomainExtensionViewState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<DomainExtensionViewState, DomainExtensionViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DomainExtensionViewState, DomainExtensionViewState>,
              DomainExtensionViewState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
