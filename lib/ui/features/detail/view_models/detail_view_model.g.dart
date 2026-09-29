// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DetailViewModel)
final detailViewModelProvider = DetailViewModelFamily._();

final class DetailViewModelProvider
    extends $AsyncNotifierProvider<DetailViewModel, DomainDetail?> {
  DetailViewModelProvider._({
    required DetailViewModelFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'detailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detailViewModelHash();

  @override
  String toString() {
    return r'detailViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  DetailViewModel create() => DetailViewModel();

  @override
  bool operator ==(Object other) {
    return other is DetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detailViewModelHash() => r'51a9902b1626bed6c19ed39e2df5d75a1803e641';

final class DetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          DetailViewModel,
          AsyncValue<DomainDetail?>,
          DomainDetail?,
          FutureOr<DomainDetail?>,
          (String, String)
        > {
  DetailViewModelFamily._()
    : super(
        retry: null,
        name: r'detailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DetailViewModelProvider call(String package, String detailUrl) =>
      DetailViewModelProvider._(argument: (package, detailUrl), from: this);

  @override
  String toString() => r'detailViewModelProvider';
}

abstract class _$DetailViewModel extends $AsyncNotifier<DomainDetail?> {
  late final _$args = ref.$arg as (String, String);
  String get package => _$args.$1;
  String get detailUrl => _$args.$2;

  FutureOr<DomainDetail?> build(String package, String detailUrl);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DomainDetail?>, DomainDetail?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DomainDetail?>, DomainDetail?>,
              AsyncValue<DomainDetail?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
