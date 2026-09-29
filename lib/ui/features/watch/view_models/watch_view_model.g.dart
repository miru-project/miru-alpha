// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WatchViewModel)
final watchViewModelProvider = WatchViewModelFamily._();

final class WatchViewModelProvider
    extends $AsyncNotifierProvider<WatchViewModel, DomainWatchResult?> {
  WatchViewModelProvider._({
    required WatchViewModelFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'watchViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchViewModelHash();

  @override
  String toString() {
    return r'watchViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  WatchViewModel create() => WatchViewModel();

  @override
  bool operator ==(Object other) {
    return other is WatchViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchViewModelHash() => r'27449650b833874ebc44aaff07c7cc0d10765898';

final class WatchViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          WatchViewModel,
          AsyncValue<DomainWatchResult?>,
          DomainWatchResult?,
          FutureOr<DomainWatchResult?>,
          (String, String)
        > {
  WatchViewModelFamily._()
    : super(
        retry: null,
        name: r'watchViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchViewModelProvider call(String package, String detailUrl) =>
      WatchViewModelProvider._(argument: (package, detailUrl), from: this);

  @override
  String toString() => r'watchViewModelProvider';
}

abstract class _$WatchViewModel extends $AsyncNotifier<DomainWatchResult?> {
  late final _$args = ref.$arg as (String, String);
  String get package => _$args.$1;
  String get detailUrl => _$args.$2;

  FutureOr<DomainWatchResult?> build(String package, String detailUrl);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<DomainWatchResult?>, DomainWatchResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DomainWatchResult?>, DomainWatchResult?>,
              AsyncValue<DomainWatchResult?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
