// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(videoLoad)
const videoLoadProvider = VideoLoadFamily._();

final class VideoLoadProvider
    extends $FunctionalProvider<AsyncValue<Object>, Object, FutureOr<Object>>
    with $FutureModifier<Object>, $FutureProvider<Object> {
  const VideoLoadProvider._({
    required VideoLoadFamily super.from,
    required (String, String, ExtensionType) super.argument,
  }) : super(
         retry: null,
         name: r'videoLoadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$videoLoadHash();

  @override
  String toString() {
    return r'videoLoadProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Object> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Object> create(Ref ref) {
    final argument = this.argument as (String, String, ExtensionType);
    return videoLoad(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoLoadProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$videoLoadHash() => r'313b20d2538d9936b4835d2571512ad04c748dae';

final class VideoLoadFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Object>,
          (String, String, ExtensionType)
        > {
  const VideoLoadFamily._()
    : super(
        retry: null,
        name: r'videoLoadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VideoLoadProvider call(String url, String pkg, ExtensionType type) =>
      VideoLoadProvider._(argument: (url, pkg, type), from: this);

  @override
  String toString() => r'videoLoadProvider';
}

@ProviderFor(fetchExtensionRepo)
const fetchExtensionRepoProvider = FetchExtensionRepoProvider._();

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
  const FetchExtensionRepoProvider._()
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
const fetchExtensionDetailProvider = FetchExtensionDetailFamily._();

final class FetchExtensionDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExtensionDetail>,
          ExtensionDetail,
          FutureOr<ExtensionDetail>
        >
    with $FutureModifier<ExtensionDetail>, $FutureProvider<ExtensionDetail> {
  const FetchExtensionDetailProvider._({
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
    r'28d77e1f1c617e9f01ac46656430f8869c43e523';

final class FetchExtensionDetailFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<ExtensionDetail>, (String, String)> {
  const FetchExtensionDetailFamily._()
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
const fetchExtensionLatestProvider = FetchExtensionLatestFamily._();

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
  const FetchExtensionLatestProvider._({
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
    r'e7f0f2e557ba88c4d5b5b637830ba43a26a6fdfb';

final class FetchExtensionLatestFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ExtensionListItem>>,
          (String, int)
        > {
  const FetchExtensionLatestFamily._()
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
const fetchExtensionSearchProvider = FetchExtensionSearchFamily._();

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
  const FetchExtensionSearchProvider._({
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
    r'e2c041c7aacedd2f30c1e09106d56f9d463adac6';

final class FetchExtensionSearchFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ExtensionListItem>>,
          (String, String, int, {Map<String, ExtensionFilter>? filter})
        > {
  const FetchExtensionSearchFamily._()
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
const fetchExtensionSearchLatestProvider = FetchExtensionSearchLatestFamily._();

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
  const FetchExtensionSearchLatestProvider._({
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
    r'4ccf6f258ee11592e915fa4cf40d5b4d6425021c';

final class FetchExtensionSearchLatestFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ExtensionListItem>>,
          (String, int, {String? query, Map<String, ExtensionFilter>? filter})
        > {
  const FetchExtensionSearchLatestFamily._()
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

@ProviderFor(mangaLoad)
const mangaLoadProvider = MangaLoadFamily._();

final class MangaLoadProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExtensionMangaWatch>,
          ExtensionMangaWatch,
          FutureOr<ExtensionMangaWatch>
        >
    with
        $FutureModifier<ExtensionMangaWatch>,
        $FutureProvider<ExtensionMangaWatch> {
  const MangaLoadProvider._({
    required MangaLoadFamily super.from,
    required (String, String, ExtensionType) super.argument,
  }) : super(
         retry: null,
         name: r'mangaLoadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mangaLoadHash();

  @override
  String toString() {
    return r'mangaLoadProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ExtensionMangaWatch> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExtensionMangaWatch> create(Ref ref) {
    final argument = this.argument as (String, String, ExtensionType);
    return mangaLoad(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaLoadProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mangaLoadHash() => r'e1fc06f1fd04e6c7cbc3caf43d69f78df34b3bbf';

final class MangaLoadFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ExtensionMangaWatch>,
          (String, String, ExtensionType)
        > {
  const MangaLoadFamily._()
    : super(
        retry: null,
        name: r'mangaLoadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MangaLoadProvider call(String url, String pkg, ExtensionType type) =>
      MangaLoadProvider._(argument: (url, pkg, type), from: this);

  @override
  String toString() => r'mangaLoadProvider';
}

@ProviderFor(fikushonLoad)
const fikushonLoadProvider = FikushonLoadFamily._();

final class FikushonLoadProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExtensionFikushonWatch>,
          ExtensionFikushonWatch,
          FutureOr<ExtensionFikushonWatch>
        >
    with
        $FutureModifier<ExtensionFikushonWatch>,
        $FutureProvider<ExtensionFikushonWatch> {
  const FikushonLoadProvider._({
    required FikushonLoadFamily super.from,
    required (String, String, ExtensionType) super.argument,
  }) : super(
         retry: null,
         name: r'fikushonLoadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fikushonLoadHash();

  @override
  String toString() {
    return r'fikushonLoadProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ExtensionFikushonWatch> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExtensionFikushonWatch> create(Ref ref) {
    final argument = this.argument as (String, String, ExtensionType);
    return fikushonLoad(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is FikushonLoadProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fikushonLoadHash() => r'915bdb903473a61cdad32d68453d23efa3060b6d';

final class FikushonLoadFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ExtensionFikushonWatch>,
          (String, String, ExtensionType)
        > {
  const FikushonLoadFamily._()
    : super(
        retry: null,
        name: r'fikushonLoadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FikushonLoadProvider call(String url, String pkg, ExtensionType type) =>
      FikushonLoadProvider._(argument: (url, pkg, type), from: this);

  @override
  String toString() => r'fikushonLoadProvider';
}
