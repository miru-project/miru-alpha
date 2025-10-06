// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extension_page_notifier_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExtensionPageNotifier)
const extensionPageProvider = ExtensionPageNotifierProvider._();

final class ExtensionPageNotifierProvider
    extends $NotifierProvider<ExtensionPageNotifier, ExtensionPageModel> {
  const ExtensionPageNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'extensionPageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$extensionPageNotifierHash();

  @$internal
  @override
  ExtensionPageNotifier create() => ExtensionPageNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExtensionPageModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExtensionPageModel>(value),
    );
  }
}

String _$extensionPageNotifierHash() =>
    r'2b20412e534d355851b7ae020abd58a0de4b7c34';

abstract class _$ExtensionPageNotifier extends $Notifier<ExtensionPageModel> {
  ExtensionPageModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ExtensionPageModel, ExtensionPageModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExtensionPageModel, ExtensionPageModel>,
              ExtensionPageModel,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
