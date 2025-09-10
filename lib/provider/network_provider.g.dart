// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoLoadHash() => r'313b20d2538d9936b4835d2571512ad04c748dae';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [videoLoad].
@ProviderFor(videoLoad)
const videoLoadProvider = VideoLoadFamily();

/// See also [videoLoad].
class VideoLoadFamily extends Family<AsyncValue<Object>> {
  /// See also [videoLoad].
  const VideoLoadFamily();

  /// See also [videoLoad].
  VideoLoadProvider call(String url, String pkg, ExtensionType type) {
    return VideoLoadProvider(url, pkg, type);
  }

  @override
  VideoLoadProvider getProviderOverride(covariant VideoLoadProvider provider) {
    return call(provider.url, provider.pkg, provider.type);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'videoLoadProvider';
}

/// See also [videoLoad].
class VideoLoadProvider extends AutoDisposeFutureProvider<Object> {
  /// See also [videoLoad].
  VideoLoadProvider(String url, String pkg, ExtensionType type)
    : this._internal(
        (ref) => videoLoad(ref as VideoLoadRef, url, pkg, type),
        from: videoLoadProvider,
        name: r'videoLoadProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$videoLoadHash,
        dependencies: VideoLoadFamily._dependencies,
        allTransitiveDependencies: VideoLoadFamily._allTransitiveDependencies,
        url: url,
        pkg: pkg,
        type: type,
      );

  VideoLoadProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.url,
    required this.pkg,
    required this.type,
  }) : super.internal();

  final String url;
  final String pkg;
  final ExtensionType type;

  @override
  Override overrideWith(
    FutureOr<Object> Function(VideoLoadRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VideoLoadProvider._internal(
        (ref) => create(ref as VideoLoadRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        url: url,
        pkg: pkg,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Object> createElement() {
    return _VideoLoadProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoLoadProvider &&
        other.url == url &&
        other.pkg == pkg &&
        other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);
    hash = _SystemHash.combine(hash, pkg.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoLoadRef on AutoDisposeFutureProviderRef<Object> {
  /// The parameter `url` of this provider.
  String get url;

  /// The parameter `pkg` of this provider.
  String get pkg;

  /// The parameter `type` of this provider.
  ExtensionType get type;
}

class _VideoLoadProviderElement extends AutoDisposeFutureProviderElement<Object>
    with VideoLoadRef {
  _VideoLoadProviderElement(super.provider);

  @override
  String get url => (origin as VideoLoadProvider).url;
  @override
  String get pkg => (origin as VideoLoadProvider).pkg;
  @override
  ExtensionType get type => (origin as VideoLoadProvider).type;
}

String _$fetchExtensionRepoHash() =>
    r'e1c3954fff31bd40d183be48b9627acd38de1ecc';

/// See also [fetchExtensionRepo].
@ProviderFor(fetchExtensionRepo)
final fetchExtensionRepoProvider =
    AutoDisposeFutureProvider<List<ExtensionRepo>>.internal(
      fetchExtensionRepo,
      name: r'fetchExtensionRepoProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$fetchExtensionRepoHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FetchExtensionRepoRef =
    AutoDisposeFutureProviderRef<List<ExtensionRepo>>;
String _$fetchExtensionDetailHash() =>
    r'28d77e1f1c617e9f01ac46656430f8869c43e523';

/// See also [fetchExtensionDetail].
@ProviderFor(fetchExtensionDetail)
const fetchExtensionDetailProvider = FetchExtensionDetailFamily();

/// See also [fetchExtensionDetail].
class FetchExtensionDetailFamily extends Family<AsyncValue<ExtensionDetail>> {
  /// See also [fetchExtensionDetail].
  const FetchExtensionDetailFamily();

  /// See also [fetchExtensionDetail].
  FetchExtensionDetailProvider call(String pkg, String url) {
    return FetchExtensionDetailProvider(pkg, url);
  }

  @override
  FetchExtensionDetailProvider getProviderOverride(
    covariant FetchExtensionDetailProvider provider,
  ) {
    return call(provider.pkg, provider.url);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fetchExtensionDetailProvider';
}

/// See also [fetchExtensionDetail].
class FetchExtensionDetailProvider
    extends AutoDisposeFutureProvider<ExtensionDetail> {
  /// See also [fetchExtensionDetail].
  FetchExtensionDetailProvider(String pkg, String url)
    : this._internal(
        (ref) => fetchExtensionDetail(ref as FetchExtensionDetailRef, pkg, url),
        from: fetchExtensionDetailProvider,
        name: r'fetchExtensionDetailProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$fetchExtensionDetailHash,
        dependencies: FetchExtensionDetailFamily._dependencies,
        allTransitiveDependencies:
            FetchExtensionDetailFamily._allTransitiveDependencies,
        pkg: pkg,
        url: url,
      );

  FetchExtensionDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pkg,
    required this.url,
  }) : super.internal();

  final String pkg;
  final String url;

  @override
  Override overrideWith(
    FutureOr<ExtensionDetail> Function(FetchExtensionDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchExtensionDetailProvider._internal(
        (ref) => create(ref as FetchExtensionDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pkg: pkg,
        url: url,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ExtensionDetail> createElement() {
    return _FetchExtensionDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchExtensionDetailProvider &&
        other.pkg == pkg &&
        other.url == url;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pkg.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchExtensionDetailRef on AutoDisposeFutureProviderRef<ExtensionDetail> {
  /// The parameter `pkg` of this provider.
  String get pkg;

  /// The parameter `url` of this provider.
  String get url;
}

class _FetchExtensionDetailProviderElement
    extends AutoDisposeFutureProviderElement<ExtensionDetail>
    with FetchExtensionDetailRef {
  _FetchExtensionDetailProviderElement(super.provider);

  @override
  String get pkg => (origin as FetchExtensionDetailProvider).pkg;
  @override
  String get url => (origin as FetchExtensionDetailProvider).url;
}

String _$fetchExtensionLatestHash() =>
    r'e7f0f2e557ba88c4d5b5b637830ba43a26a6fdfb';

/// See also [fetchExtensionLatest].
@ProviderFor(fetchExtensionLatest)
const fetchExtensionLatestProvider = FetchExtensionLatestFamily();

/// See also [fetchExtensionLatest].
class FetchExtensionLatestFamily
    extends Family<AsyncValue<List<ExtensionListItem>>> {
  /// See also [fetchExtensionLatest].
  const FetchExtensionLatestFamily();

  /// See also [fetchExtensionLatest].
  FetchExtensionLatestProvider call(String pkg, int page) {
    return FetchExtensionLatestProvider(pkg, page);
  }

  @override
  FetchExtensionLatestProvider getProviderOverride(
    covariant FetchExtensionLatestProvider provider,
  ) {
    return call(provider.pkg, provider.page);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fetchExtensionLatestProvider';
}

/// See also [fetchExtensionLatest].
class FetchExtensionLatestProvider
    extends AutoDisposeFutureProvider<List<ExtensionListItem>> {
  /// See also [fetchExtensionLatest].
  FetchExtensionLatestProvider(String pkg, int page)
    : this._internal(
        (ref) =>
            fetchExtensionLatest(ref as FetchExtensionLatestRef, pkg, page),
        from: fetchExtensionLatestProvider,
        name: r'fetchExtensionLatestProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$fetchExtensionLatestHash,
        dependencies: FetchExtensionLatestFamily._dependencies,
        allTransitiveDependencies:
            FetchExtensionLatestFamily._allTransitiveDependencies,
        pkg: pkg,
        page: page,
      );

  FetchExtensionLatestProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pkg,
    required this.page,
  }) : super.internal();

  final String pkg;
  final int page;

  @override
  Override overrideWith(
    FutureOr<List<ExtensionListItem>> Function(FetchExtensionLatestRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchExtensionLatestProvider._internal(
        (ref) => create(ref as FetchExtensionLatestRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pkg: pkg,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ExtensionListItem>> createElement() {
    return _FetchExtensionLatestProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchExtensionLatestProvider &&
        other.pkg == pkg &&
        other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pkg.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchExtensionLatestRef
    on AutoDisposeFutureProviderRef<List<ExtensionListItem>> {
  /// The parameter `pkg` of this provider.
  String get pkg;

  /// The parameter `page` of this provider.
  int get page;
}

class _FetchExtensionLatestProviderElement
    extends AutoDisposeFutureProviderElement<List<ExtensionListItem>>
    with FetchExtensionLatestRef {
  _FetchExtensionLatestProviderElement(super.provider);

  @override
  String get pkg => (origin as FetchExtensionLatestProvider).pkg;
  @override
  int get page => (origin as FetchExtensionLatestProvider).page;
}

String _$fetchExtensionSearchHash() =>
    r'b2fd204c1ee2d381805b1ddb168f0a4aca3647c0';

/// See also [fetchExtensionSearch].
@ProviderFor(fetchExtensionSearch)
const fetchExtensionSearchProvider = FetchExtensionSearchFamily();

/// See also [fetchExtensionSearch].
class FetchExtensionSearchFamily
    extends Family<AsyncValue<List<ExtensionListItem>>> {
  /// See also [fetchExtensionSearch].
  const FetchExtensionSearchFamily();

  /// See also [fetchExtensionSearch].
  FetchExtensionSearchProvider call(
    String package,
    String query,
    int page, {
    Map<String, List<String>>? filter,
  }) {
    return FetchExtensionSearchProvider(package, query, page, filter: filter);
  }

  @override
  FetchExtensionSearchProvider getProviderOverride(
    covariant FetchExtensionSearchProvider provider,
  ) {
    return call(
      provider.package,
      provider.query,
      provider.page,
      filter: provider.filter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fetchExtensionSearchProvider';
}

/// See also [fetchExtensionSearch].
class FetchExtensionSearchProvider
    extends AutoDisposeFutureProvider<List<ExtensionListItem>> {
  /// See also [fetchExtensionSearch].
  FetchExtensionSearchProvider(
    String package,
    String query,
    int page, {
    Map<String, List<String>>? filter,
  }) : this._internal(
         (ref) => fetchExtensionSearch(
           ref as FetchExtensionSearchRef,
           package,
           query,
           page,
           filter: filter,
         ),
         from: fetchExtensionSearchProvider,
         name: r'fetchExtensionSearchProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$fetchExtensionSearchHash,
         dependencies: FetchExtensionSearchFamily._dependencies,
         allTransitiveDependencies:
             FetchExtensionSearchFamily._allTransitiveDependencies,
         package: package,
         query: query,
         page: page,
         filter: filter,
       );

  FetchExtensionSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.package,
    required this.query,
    required this.page,
    required this.filter,
  }) : super.internal();

  final String package;
  final String query;
  final int page;
  final Map<String, List<String>>? filter;

  @override
  Override overrideWith(
    FutureOr<List<ExtensionListItem>> Function(FetchExtensionSearchRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchExtensionSearchProvider._internal(
        (ref) => create(ref as FetchExtensionSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        package: package,
        query: query,
        page: page,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ExtensionListItem>> createElement() {
    return _FetchExtensionSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchExtensionSearchProvider &&
        other.package == package &&
        other.query == query &&
        other.page == page &&
        other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, package.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchExtensionSearchRef
    on AutoDisposeFutureProviderRef<List<ExtensionListItem>> {
  /// The parameter `package` of this provider.
  String get package;

  /// The parameter `query` of this provider.
  String get query;

  /// The parameter `page` of this provider.
  int get page;

  /// The parameter `filter` of this provider.
  Map<String, List<String>>? get filter;
}

class _FetchExtensionSearchProviderElement
    extends AutoDisposeFutureProviderElement<List<ExtensionListItem>>
    with FetchExtensionSearchRef {
  _FetchExtensionSearchProviderElement(super.provider);

  @override
  String get package => (origin as FetchExtensionSearchProvider).package;
  @override
  String get query => (origin as FetchExtensionSearchProvider).query;
  @override
  int get page => (origin as FetchExtensionSearchProvider).page;
  @override
  Map<String, List<String>>? get filter =>
      (origin as FetchExtensionSearchProvider).filter;
}

String _$mangaLoadHash() => r'e1fc06f1fd04e6c7cbc3caf43d69f78df34b3bbf';

/// See also [mangaLoad].
@ProviderFor(mangaLoad)
const mangaLoadProvider = MangaLoadFamily();

/// See also [mangaLoad].
class MangaLoadFamily extends Family<AsyncValue<ExtensionMangaWatch>> {
  /// See also [mangaLoad].
  const MangaLoadFamily();

  /// See also [mangaLoad].
  MangaLoadProvider call(String url, String pkg, ExtensionType type) {
    return MangaLoadProvider(url, pkg, type);
  }

  @override
  MangaLoadProvider getProviderOverride(covariant MangaLoadProvider provider) {
    return call(provider.url, provider.pkg, provider.type);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mangaLoadProvider';
}

/// See also [mangaLoad].
class MangaLoadProvider extends AutoDisposeFutureProvider<ExtensionMangaWatch> {
  /// See also [mangaLoad].
  MangaLoadProvider(String url, String pkg, ExtensionType type)
    : this._internal(
        (ref) => mangaLoad(ref as MangaLoadRef, url, pkg, type),
        from: mangaLoadProvider,
        name: r'mangaLoadProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$mangaLoadHash,
        dependencies: MangaLoadFamily._dependencies,
        allTransitiveDependencies: MangaLoadFamily._allTransitiveDependencies,
        url: url,
        pkg: pkg,
        type: type,
      );

  MangaLoadProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.url,
    required this.pkg,
    required this.type,
  }) : super.internal();

  final String url;
  final String pkg;
  final ExtensionType type;

  @override
  Override overrideWith(
    FutureOr<ExtensionMangaWatch> Function(MangaLoadRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MangaLoadProvider._internal(
        (ref) => create(ref as MangaLoadRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        url: url,
        pkg: pkg,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ExtensionMangaWatch> createElement() {
    return _MangaLoadProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaLoadProvider &&
        other.url == url &&
        other.pkg == pkg &&
        other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);
    hash = _SystemHash.combine(hash, pkg.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MangaLoadRef on AutoDisposeFutureProviderRef<ExtensionMangaWatch> {
  /// The parameter `url` of this provider.
  String get url;

  /// The parameter `pkg` of this provider.
  String get pkg;

  /// The parameter `type` of this provider.
  ExtensionType get type;
}

class _MangaLoadProviderElement
    extends AutoDisposeFutureProviderElement<ExtensionMangaWatch>
    with MangaLoadRef {
  _MangaLoadProviderElement(super.provider);

  @override
  String get url => (origin as MangaLoadProvider).url;
  @override
  String get pkg => (origin as MangaLoadProvider).pkg;
  @override
  ExtensionType get type => (origin as MangaLoadProvider).type;
}

String _$fikushonLoadHash() => r'915bdb903473a61cdad32d68453d23efa3060b6d';

/// See also [fikushonLoad].
@ProviderFor(fikushonLoad)
const fikushonLoadProvider = FikushonLoadFamily();

/// See also [fikushonLoad].
class FikushonLoadFamily extends Family<AsyncValue<ExtensionFikushonWatch>> {
  /// See also [fikushonLoad].
  const FikushonLoadFamily();

  /// See also [fikushonLoad].
  FikushonLoadProvider call(String url, String pkg, ExtensionType type) {
    return FikushonLoadProvider(url, pkg, type);
  }

  @override
  FikushonLoadProvider getProviderOverride(
    covariant FikushonLoadProvider provider,
  ) {
    return call(provider.url, provider.pkg, provider.type);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fikushonLoadProvider';
}

/// See also [fikushonLoad].
class FikushonLoadProvider
    extends AutoDisposeFutureProvider<ExtensionFikushonWatch> {
  /// See also [fikushonLoad].
  FikushonLoadProvider(String url, String pkg, ExtensionType type)
    : this._internal(
        (ref) => fikushonLoad(ref as FikushonLoadRef, url, pkg, type),
        from: fikushonLoadProvider,
        name: r'fikushonLoadProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$fikushonLoadHash,
        dependencies: FikushonLoadFamily._dependencies,
        allTransitiveDependencies:
            FikushonLoadFamily._allTransitiveDependencies,
        url: url,
        pkg: pkg,
        type: type,
      );

  FikushonLoadProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.url,
    required this.pkg,
    required this.type,
  }) : super.internal();

  final String url;
  final String pkg;
  final ExtensionType type;

  @override
  Override overrideWith(
    FutureOr<ExtensionFikushonWatch> Function(FikushonLoadRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FikushonLoadProvider._internal(
        (ref) => create(ref as FikushonLoadRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        url: url,
        pkg: pkg,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ExtensionFikushonWatch> createElement() {
    return _FikushonLoadProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FikushonLoadProvider &&
        other.url == url &&
        other.pkg == pkg &&
        other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);
    hash = _SystemHash.combine(hash, pkg.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FikushonLoadRef on AutoDisposeFutureProviderRef<ExtensionFikushonWatch> {
  /// The parameter `url` of this provider.
  String get url;

  /// The parameter `pkg` of this provider.
  String get pkg;

  /// The parameter `type` of this provider.
  ExtensionType get type;
}

class _FikushonLoadProviderElement
    extends AutoDisposeFutureProviderElement<ExtensionFikushonWatch>
    with FikushonLoadRef {
  _FikushonLoadProviderElement(super.provider);

  @override
  String get url => (origin as FikushonLoadProvider).url;
  @override
  String get pkg => (origin as FikushonLoadProvider).pkg;
  @override
  ExtensionType get type => (origin as FikushonLoadProvider).type;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
