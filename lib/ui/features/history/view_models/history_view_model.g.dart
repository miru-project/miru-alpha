// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HistoryViewModel)
final historyViewModelProvider = HistoryViewModelProvider._();

final class HistoryViewModelProvider
    extends $AsyncNotifierProvider<HistoryViewModel, List<DomainHistoryItem>> {
  HistoryViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyViewModelHash();

  @$internal
  @override
  HistoryViewModel create() => HistoryViewModel();
}

String _$historyViewModelHash() => r'cbdad2b7bc6ed5aca05aafda63f9a6c85bd93fdd';

abstract class _$HistoryViewModel
    extends $AsyncNotifier<List<DomainHistoryItem>> {
  FutureOr<List<DomainHistoryItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<DomainHistoryItem>>,
              List<DomainHistoryItem>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<DomainHistoryItem>>,
                List<DomainHistoryItem>
              >,
              AsyncValue<List<DomainHistoryItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
