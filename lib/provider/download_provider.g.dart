// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DownloadNotifier)
final downloadProvider = DownloadNotifierProvider._();

final class DownloadNotifierProvider
    extends $NotifierProvider<DownloadNotifier, AsyncValue<DownloadState>> {
  DownloadNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadNotifierHash();

  @$internal
  @override
  DownloadNotifier create() => DownloadNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<DownloadState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<DownloadState>>(value),
    );
  }
}

String _$downloadNotifierHash() => r'3937938915e1269c54e3e1dcbcb3580468a9ee7d';

abstract class _$DownloadNotifier extends $Notifier<AsyncValue<DownloadState>> {
  AsyncValue<DownloadState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<DownloadState>, AsyncValue<DownloadState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DownloadState>, AsyncValue<DownloadState>>,
              AsyncValue<DownloadState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
