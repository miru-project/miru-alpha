// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HistoryPageNotifier)
final historyPageProvider = HistoryPageNotifierProvider._();

final class HistoryPageNotifierProvider
    extends $NotifierProvider<HistoryPageNotifier, HistoryPageState> {
  HistoryPageNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyPageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyPageNotifierHash();

  @$internal
  @override
  HistoryPageNotifier create() => HistoryPageNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryPageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryPageState>(value),
    );
  }
}

String _$historyPageNotifierHash() =>
    r'132f6263150ceb06367c232119c805abea3c161d';

abstract class _$HistoryPageNotifier extends $Notifier<HistoryPageState> {
  HistoryPageState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HistoryPageState, HistoryPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HistoryPageState, HistoryPageState>,
              HistoryPageState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
