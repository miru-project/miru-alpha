// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dlna_cast_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the DLNA device search, the connected renderer's transport, and
/// the TWO-WAY sync between the app player (via [DlnaPlayerSurface]) and the
/// renderer.
///
/// One scan at a time: [startScan] opens the SSDP socket, [stopScan] closes
/// it. The devices stream re-emits the whole map on every discovery, so the
/// state rebuilds the sorted list each tick.
///
/// Keep-alive: the discovered devices and the connected renderer survive the
/// cast sheet closing — reopening the sheet shows the previous list and
/// session instead of rescanning from zero.

@ProviderFor(DlnaCast)
final dlnaCastProvider = DlnaCastProvider._();

/// Drives the DLNA device search, the connected renderer's transport, and
/// the TWO-WAY sync between the app player (via [DlnaPlayerSurface]) and the
/// renderer.
///
/// One scan at a time: [startScan] opens the SSDP socket, [stopScan] closes
/// it. The devices stream re-emits the whole map on every discovery, so the
/// state rebuilds the sorted list each tick.
///
/// Keep-alive: the discovered devices and the connected renderer survive the
/// cast sheet closing — reopening the sheet shows the previous list and
/// session instead of rescanning from zero.
final class DlnaCastProvider
    extends $NotifierProvider<DlnaCast, DlnaCastState> {
  /// Drives the DLNA device search, the connected renderer's transport, and
  /// the TWO-WAY sync between the app player (via [DlnaPlayerSurface]) and the
  /// renderer.
  ///
  /// One scan at a time: [startScan] opens the SSDP socket, [stopScan] closes
  /// it. The devices stream re-emits the whole map on every discovery, so the
  /// state rebuilds the sorted list each tick.
  ///
  /// Keep-alive: the discovered devices and the connected renderer survive the
  /// cast sheet closing — reopening the sheet shows the previous list and
  /// session instead of rescanning from zero.
  DlnaCastProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dlnaCastProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dlnaCastHash();

  @$internal
  @override
  DlnaCast create() => DlnaCast();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DlnaCastState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DlnaCastState>(value),
    );
  }
}

String _$dlnaCastHash() => r'e3ecb6ab54247c39310601fe733666f37d79937e';

/// Drives the DLNA device search, the connected renderer's transport, and
/// the TWO-WAY sync between the app player (via [DlnaPlayerSurface]) and the
/// renderer.
///
/// One scan at a time: [startScan] opens the SSDP socket, [stopScan] closes
/// it. The devices stream re-emits the whole map on every discovery, so the
/// state rebuilds the sorted list each tick.
///
/// Keep-alive: the discovered devices and the connected renderer survive the
/// cast sheet closing — reopening the sheet shows the previous list and
/// session instead of rescanning from zero.

abstract class _$DlnaCast extends $Notifier<DlnaCastState> {
  DlnaCastState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DlnaCastState, DlnaCastState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DlnaCastState, DlnaCastState>,
              DlnaCastState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
