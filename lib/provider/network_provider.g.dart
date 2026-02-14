// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(watch)
final watchProvider = WatchFamily._();

final class WatchProvider
    extends $FunctionalProvider<AsyncValue<Object>, Object, FutureOr<Object>>
    with $FutureModifier<Object>, $FutureProvider<Object> {
  WatchProvider._({
    required WatchFamily super.from,
    required (String, String, String, ExtensionType) super.argument,
  }) : super(
         retry: null,
         name: r'watchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchHash();

  @override
  String toString() {
    return r'watchProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Object> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Object> create(Ref ref) {
    final argument = this.argument as (String, String, String, ExtensionType);
    return watch(ref, argument.$1, argument.$2, argument.$3, argument.$4);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchHash() => r'eb74354da537b97dcca5c995438199ab8d370e11';

final class WatchFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Object>,
          (String, String, String, ExtensionType)
        > {
  WatchFamily._()
    : super(
        retry: null,
        name: r'watchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchProvider call(
    String watchUrl,
    String detailUrl,
    String pkg,
    ExtensionType type,
  ) => WatchProvider._(argument: (watchUrl, detailUrl, pkg, type), from: this);

  @override
  String toString() => r'watchProvider';
}

@ProviderFor(fetchExtensionRepo)
final fetchExtensionRepoProvider = FetchExtensionRepoProvider._();

final class FetchExtensionRepoProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExtensionRepo>>,
          List<ExtensionRepo>,
          FutureOr<List<ExtensionRepo>>
        >
    with
        $FutureModifier<List<ExtensionRepo>>,
        $FutureProvider<List<ExtensionRepo>> {
  FetchExtensionRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fetchExtensionRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fetchExtensionRepoHash();

  @$internal
  @override
  $FutureProviderElement<List<ExtensionRepo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExtensionRepo>> create(Ref ref) {
    return fetchExtensionRepo(ref);
  }
}

String _$fetchExtensionRepoHash() =>
    r'e1c3954fff31bd40d183be48b9627acd38de1ecc';

@ProviderFor(fetchExtensionDetail)
final fetchExtensionDetailProvider = FetchExtensionDetailFamily._();

final class FetchExtensionDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExtensionDetail>,
          ExtensionDetail,
          FutureOr<ExtensionDetail>
        >
    with $FutureModifier<ExtensionDetail>, $FutureProvider<ExtensionDetail> {
  FetchExtensionDetailProvider._({
    required FetchExtensionDetailFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'fetchExtensionDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fetchExtensionDetailHash();

  @override
  String toString() {
    return r'fetchExtensionDetailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ExtensionDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExtensionDetail> create(Ref ref) {
    final argument = this.argument as (String, String);
    return fetchExtensionDetail(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchExtensionDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchExtensionDetailHash() =>
    r'e22aa8d5a0f262643785e6cdbeaae6832990a0ea';

final class FetchExtensionDetailFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<ExtensionDetail>, (String, String)> {
  FetchExtensionDetailFamily._()
    : super(
        retry: null,
        name: r'fetchExtensionDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FetchExtensionDetailProvider call(String pkg, String url) =>
      FetchExtensionDetailProvider._(argument: (pkg, url), from: this);

  @override
  String toString() => r'fetchExtensionDetailProvider';
}

@ProviderFor(fetchExtensionLatest)
final fetchExtensionLatestProvider = FetchExtensionLatestFamily._();

final class FetchExtensionLatestProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExtensionListItem>>,
          List<ExtensionListItem>,
          FutureOr<List<ExtensionListItem>>
        >
    with
        $FutureModifier<List<ExtensionListItem>>,
        $FutureProvider<List<ExtensionListItem>> {
  FetchExtensionLatestProvider._({
    required FetchExtensionLatestFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: null,
         name: r'fetchExtensionLatestProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fetchExtensionLatestHash();

  @override
  String toString() {
    return r'fetchExtensionLatestProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<ExtensionListItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExtensionListItem>> create(Ref ref) {
    final argument = this.argument as (String, int);
    return fetchExtensionLatest(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchExtensionLatestProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchExtensionLatestHash() =>
    r'654f6b598a8ea3b55ef7be39388f15376eee73ca';

final class FetchExtensionLatestFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ExtensionListItem>>,
          (String, int)
        > {
  FetchExtensionLatestFamily._()
    : super(
        retry: null,
        name: r'fetchExtensionLatestProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FetchExtensionLatestProvider call(String pkg, int page) =>
      FetchExtensionLatestProvider._(argument: (pkg, page), from: this);

  @override
  String toString() => r'fetchExtensionLatestProvider';
}

@ProviderFor(fetchExtensionSearch)
final fetchExtensionSearchProvider = FetchExtensionSearchFamily._();

final class FetchExtensionSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExtensionListItem>>,
          List<ExtensionListItem>,
          FutureOr<List<ExtensionListItem>>
        >
    with
        $FutureModifier<List<ExtensionListItem>>,
        $FutureProvider<List<ExtensionListItem>> {
  FetchExtensionSearchProvider._({
    required FetchExtensionSearchFamily super.from,
    required (String, String, int, {Map<String, ExtensionFilter>? filter})
    super.argument,
  }) : super(
         retry: null,
         name: r'fetchExtensionSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fetchExtensionSearchHash();

  @override
  String toString() {
    return r'fetchExtensionSearchProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<ExtensionListItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExtensionListItem>> create(Ref ref) {
    final argument =
        this.argument
            as (String, String, int, {Map<String, ExtensionFilter>? filter});
    return fetchExtensionSearch(
      ref,
      argument.$1,
      argument.$2,
      argument.$3,
      filter: argument.filter,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FetchExtensionSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchExtensionSearchHash() =>
    r'4cd9a7561506a1fb7197a0d87fe070bc525d5121';

final class FetchExtensionSearchFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ExtensionListItem>>,
          (String, String, int, {Map<String, ExtensionFilter>? filter})
        > {
  FetchExtensionSearchFamily._()
    : super(
        retry: null,
        name: r'fetchExtensionSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FetchExtensionSearchProvider call(
    String package,
    String query,
    int page, {
    Map<String, ExtensionFilter>? filter,
  }) => FetchExtensionSearchProvider._(
    argument: (package, query, page, filter: filter),
    from: this,
  );

  @override
  String toString() => r'fetchExtensionSearchProvider';
}

@ProviderFor(fetchExtensionSearchLatest)
final fetchExtensionSearchLatestProvider = FetchExtensionSearchLatestFamily._();

final class FetchExtensionSearchLatestProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExtensionListItem>>,
          List<ExtensionListItem>,
          FutureOr<List<ExtensionListItem>>
        >
    with
        $FutureModifier<List<ExtensionListItem>>,
        $FutureProvider<List<ExtensionListItem>> {
  FetchExtensionSearchLatestProvider._({
    required FetchExtensionSearchLatestFamily super.from,
    required (
      String,
      int, {
      String? query,
      Map<String, ExtensionFilter>? filter,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'fetchExtensionSearchLatestProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fetchExtensionSearchLatestHash();

  @override
  String toString() {
    return r'fetchExtensionSearchLatestProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<ExtensionListItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExtensionListItem>> create(Ref ref) {
    final argument =
        this.argument
            as (
              String,
              int, {
              String? query,
              Map<String, ExtensionFilter>? filter,
            });
    return fetchExtensionSearchLatest(
      ref,
      argument.$1,
      argument.$2,
      query: argument.query,
      filter: argument.filter,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FetchExtensionSearchLatestProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchExtensionSearchLatestHash() =>
    r'7aef9218fcb0de6b34be9356c306bb368374604c';

final class FetchExtensionSearchLatestFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ExtensionListItem>>,
          (String, int, {String? query, Map<String, ExtensionFilter>? filter})
        > {
  FetchExtensionSearchLatestFamily._()
    : super(
        retry: null,
        name: r'fetchExtensionSearchLatestProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FetchExtensionSearchLatestProvider call(
    String package,
    int page, {
    String? query,
    Map<String, ExtensionFilter>? filter,
  }) => FetchExtensionSearchLatestProvider._(
    argument: (package, page, query: query, filter: filter),
    from: this,
  );

  @override
  String toString() => r'fetchExtensionSearchLatestProvider';
}
