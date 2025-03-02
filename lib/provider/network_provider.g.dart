// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoLoadHash() => r'7e384ac04433473ea54e7adcad9b7c4a106d44e8';

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
class VideoLoadFamily extends Family<AsyncValue<ExtensionBangumiWatch>> {
  /// See also [videoLoad].
  const VideoLoadFamily();

  /// See also [videoLoad].
  VideoLoadProvider call(
    String url,
    ExtensionApiV1 service,
  ) {
    return VideoLoadProvider(
      url,
      service,
    );
  }

  @override
  VideoLoadProvider getProviderOverride(
    covariant VideoLoadProvider provider,
  ) {
    return call(
      provider.url,
      provider.service,
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
  String? get name => r'videoLoadProvider';
}

/// See also [videoLoad].
class VideoLoadProvider
    extends AutoDisposeFutureProvider<ExtensionBangumiWatch> {
  /// See also [videoLoad].
  VideoLoadProvider(
    String url,
    ExtensionApiV1 service,
  ) : this._internal(
          (ref) => videoLoad(
            ref as VideoLoadRef,
            url,
            service,
          ),
          from: videoLoadProvider,
          name: r'videoLoadProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$videoLoadHash,
          dependencies: VideoLoadFamily._dependencies,
          allTransitiveDependencies: VideoLoadFamily._allTransitiveDependencies,
          url: url,
          service: service,
        );

  VideoLoadProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.url,
    required this.service,
  }) : super.internal();

  final String url;
  final ExtensionApiV1 service;

  @override
  Override overrideWith(
    FutureOr<ExtensionBangumiWatch> Function(VideoLoadRef provider) create,
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
        service: service,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ExtensionBangumiWatch> createElement() {
    return _VideoLoadProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoLoadProvider &&
        other.url == url &&
        other.service == service;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);
    hash = _SystemHash.combine(hash, service.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoLoadRef on AutoDisposeFutureProviderRef<ExtensionBangumiWatch> {
  /// The parameter `url` of this provider.
  String get url;

  /// The parameter `service` of this provider.
  ExtensionApiV1 get service;
}

class _VideoLoadProviderElement
    extends AutoDisposeFutureProviderElement<ExtensionBangumiWatch>
    with VideoLoadRef {
  _VideoLoadProviderElement(super.provider);

  @override
  String get url => (origin as VideoLoadProvider).url;
  @override
  ExtensionApiV1 get service => (origin as VideoLoadProvider).service;
}

String _$fetchExtensionRepoHash() =>
    r'8c31498b560f369a262a6646c77bfc623d47e7d5';

/// See also [fetchExtensionRepo].
@ProviderFor(fetchExtensionRepo)
final fetchExtensionRepoProvider =
    AutoDisposeFutureProvider<List<GithubExtension>>.internal(
  fetchExtensionRepo,
  name: r'fetchExtensionRepoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fetchExtensionRepoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FetchExtensionRepoRef
    = AutoDisposeFutureProviderRef<List<GithubExtension>>;
String _$fetchExtensionDetailHash() =>
    r'46dbbf8553da0bcc1e84b346f3472a80df609ff7';

/// See also [fetchExtensionDetail].
@ProviderFor(fetchExtensionDetail)
const fetchExtensionDetailProvider = FetchExtensionDetailFamily();

/// See also [fetchExtensionDetail].
class FetchExtensionDetailFamily extends Family<AsyncValue<ExtensionDetail>> {
  /// See also [fetchExtensionDetail].
  const FetchExtensionDetailFamily();

  /// See also [fetchExtensionDetail].
  FetchExtensionDetailProvider call(
    ExtensionApiV1 extensionService,
    String url,
  ) {
    return FetchExtensionDetailProvider(
      extensionService,
      url,
    );
  }

  @override
  FetchExtensionDetailProvider getProviderOverride(
    covariant FetchExtensionDetailProvider provider,
  ) {
    return call(
      provider.extensionService,
      provider.url,
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
  String? get name => r'fetchExtensionDetailProvider';
}

/// See also [fetchExtensionDetail].
class FetchExtensionDetailProvider
    extends AutoDisposeFutureProvider<ExtensionDetail> {
  /// See also [fetchExtensionDetail].
  FetchExtensionDetailProvider(
    ExtensionApiV1 extensionService,
    String url,
  ) : this._internal(
          (ref) => fetchExtensionDetail(
            ref as FetchExtensionDetailRef,
            extensionService,
            url,
          ),
          from: fetchExtensionDetailProvider,
          name: r'fetchExtensionDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchExtensionDetailHash,
          dependencies: FetchExtensionDetailFamily._dependencies,
          allTransitiveDependencies:
              FetchExtensionDetailFamily._allTransitiveDependencies,
          extensionService: extensionService,
          url: url,
        );

  FetchExtensionDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.extensionService,
    required this.url,
  }) : super.internal();

  final ExtensionApiV1 extensionService;
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
        extensionService: extensionService,
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
        other.extensionService == extensionService &&
        other.url == url;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, extensionService.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchExtensionDetailRef on AutoDisposeFutureProviderRef<ExtensionDetail> {
  /// The parameter `extensionService` of this provider.
  ExtensionApiV1 get extensionService;

  /// The parameter `url` of this provider.
  String get url;
}

class _FetchExtensionDetailProviderElement
    extends AutoDisposeFutureProviderElement<ExtensionDetail>
    with FetchExtensionDetailRef {
  _FetchExtensionDetailProviderElement(super.provider);

  @override
  ExtensionApiV1 get extensionService =>
      (origin as FetchExtensionDetailProvider).extensionService;
  @override
  String get url => (origin as FetchExtensionDetailProvider).url;
}

String _$fetchExtensionLatestHash() =>
    r'688262122f7a4404c57729eb70f47ec7900387ba';

/// See also [fetchExtensionLatest].
@ProviderFor(fetchExtensionLatest)
const fetchExtensionLatestProvider = FetchExtensionLatestFamily();

/// See also [fetchExtensionLatest].
class FetchExtensionLatestFamily
    extends Family<AsyncValue<List<ExtensionListItem>>> {
  /// See also [fetchExtensionLatest].
  const FetchExtensionLatestFamily();

  /// See also [fetchExtensionLatest].
  FetchExtensionLatestProvider call(
    ExtensionApiV1 extensionService,
    int page,
  ) {
    return FetchExtensionLatestProvider(
      extensionService,
      page,
    );
  }

  @override
  FetchExtensionLatestProvider getProviderOverride(
    covariant FetchExtensionLatestProvider provider,
  ) {
    return call(
      provider.extensionService,
      provider.page,
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
  String? get name => r'fetchExtensionLatestProvider';
}

/// See also [fetchExtensionLatest].
class FetchExtensionLatestProvider
    extends AutoDisposeFutureProvider<List<ExtensionListItem>> {
  /// See also [fetchExtensionLatest].
  FetchExtensionLatestProvider(
    ExtensionApiV1 extensionService,
    int page,
  ) : this._internal(
          (ref) => fetchExtensionLatest(
            ref as FetchExtensionLatestRef,
            extensionService,
            page,
          ),
          from: fetchExtensionLatestProvider,
          name: r'fetchExtensionLatestProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchExtensionLatestHash,
          dependencies: FetchExtensionLatestFamily._dependencies,
          allTransitiveDependencies:
              FetchExtensionLatestFamily._allTransitiveDependencies,
          extensionService: extensionService,
          page: page,
        );

  FetchExtensionLatestProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.extensionService,
    required this.page,
  }) : super.internal();

  final ExtensionApiV1 extensionService;
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
        extensionService: extensionService,
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
        other.extensionService == extensionService &&
        other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, extensionService.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchExtensionLatestRef
    on AutoDisposeFutureProviderRef<List<ExtensionListItem>> {
  /// The parameter `extensionService` of this provider.
  ExtensionApiV1 get extensionService;

  /// The parameter `page` of this provider.
  int get page;
}

class _FetchExtensionLatestProviderElement
    extends AutoDisposeFutureProviderElement<List<ExtensionListItem>>
    with FetchExtensionLatestRef {
  _FetchExtensionLatestProviderElement(super.provider);

  @override
  ExtensionApiV1 get extensionService =>
      (origin as FetchExtensionLatestProvider).extensionService;
  @override
  int get page => (origin as FetchExtensionLatestProvider).page;
}

String _$fetchExtensionSearchHash() =>
    r'e34f2739043e3a7f966951cd9ad403a60cdf1e64';

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
    ExtensionApiV1 extensionService,
    String query,
    int page, {
    Map<String, List<String>>? filter,
  }) {
    return FetchExtensionSearchProvider(
      extensionService,
      query,
      page,
      filter: filter,
    );
  }

  @override
  FetchExtensionSearchProvider getProviderOverride(
    covariant FetchExtensionSearchProvider provider,
  ) {
    return call(
      provider.extensionService,
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
    ExtensionApiV1 extensionService,
    String query,
    int page, {
    Map<String, List<String>>? filter,
  }) : this._internal(
          (ref) => fetchExtensionSearch(
            ref as FetchExtensionSearchRef,
            extensionService,
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
          extensionService: extensionService,
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
    required this.extensionService,
    required this.query,
    required this.page,
    required this.filter,
  }) : super.internal();

  final ExtensionApiV1 extensionService;
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
        extensionService: extensionService,
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
        other.extensionService == extensionService &&
        other.query == query &&
        other.page == page &&
        other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, extensionService.hashCode);
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
  /// The parameter `extensionService` of this provider.
  ExtensionApiV1 get extensionService;

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
  ExtensionApiV1 get extensionService =>
      (origin as FetchExtensionSearchProvider).extensionService;
  @override
  String get query => (origin as FetchExtensionSearchProvider).query;
  @override
  int get page => (origin as FetchExtensionSearchProvider).page;
  @override
  Map<String, List<String>>? get filter =>
      (origin as FetchExtensionSearchProvider).filter;
}

String _$mangaLoadHash() => r'922b86688b8803eaa40283f850e7c6a43c55daa1';

/// See also [mangaLoad].
@ProviderFor(mangaLoad)
const mangaLoadProvider = MangaLoadFamily();

/// See also [mangaLoad].
class MangaLoadFamily extends Family<AsyncValue<ExtensionMangaWatch>> {
  /// See also [mangaLoad].
  const MangaLoadFamily();

  /// See also [mangaLoad].
  MangaLoadProvider call(
    String url,
    ExtensionApiV1 service,
  ) {
    return MangaLoadProvider(
      url,
      service,
    );
  }

  @override
  MangaLoadProvider getProviderOverride(
    covariant MangaLoadProvider provider,
  ) {
    return call(
      provider.url,
      provider.service,
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
  String? get name => r'mangaLoadProvider';
}

/// See also [mangaLoad].
class MangaLoadProvider extends AutoDisposeFutureProvider<ExtensionMangaWatch> {
  /// See also [mangaLoad].
  MangaLoadProvider(
    String url,
    ExtensionApiV1 service,
  ) : this._internal(
          (ref) => mangaLoad(
            ref as MangaLoadRef,
            url,
            service,
          ),
          from: mangaLoadProvider,
          name: r'mangaLoadProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaLoadHash,
          dependencies: MangaLoadFamily._dependencies,
          allTransitiveDependencies: MangaLoadFamily._allTransitiveDependencies,
          url: url,
          service: service,
        );

  MangaLoadProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.url,
    required this.service,
  }) : super.internal();

  final String url;
  final ExtensionApiV1 service;

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
        service: service,
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
        other.service == service;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);
    hash = _SystemHash.combine(hash, service.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MangaLoadRef on AutoDisposeFutureProviderRef<ExtensionMangaWatch> {
  /// The parameter `url` of this provider.
  String get url;

  /// The parameter `service` of this provider.
  ExtensionApiV1 get service;
}

class _MangaLoadProviderElement
    extends AutoDisposeFutureProviderElement<ExtensionMangaWatch>
    with MangaLoadRef {
  _MangaLoadProviderElement(super.provider);

  @override
  String get url => (origin as MangaLoadProvider).url;
  @override
  ExtensionApiV1 get service => (origin as MangaLoadProvider).service;
}

String _$fikushonLoadHash() => r'90bf0411a89ff487ee83934123a1735ba4967dfb';

/// See also [fikushonLoad].
@ProviderFor(fikushonLoad)
const fikushonLoadProvider = FikushonLoadFamily();

/// See also [fikushonLoad].
class FikushonLoadFamily extends Family<AsyncValue<ExtensionFikushonWatch>> {
  /// See also [fikushonLoad].
  const FikushonLoadFamily();

  /// See also [fikushonLoad].
  FikushonLoadProvider call(
    String url,
    ExtensionApiV1 service,
  ) {
    return FikushonLoadProvider(
      url,
      service,
    );
  }

  @override
  FikushonLoadProvider getProviderOverride(
    covariant FikushonLoadProvider provider,
  ) {
    return call(
      provider.url,
      provider.service,
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
  String? get name => r'fikushonLoadProvider';
}

/// See also [fikushonLoad].
class FikushonLoadProvider
    extends AutoDisposeFutureProvider<ExtensionFikushonWatch> {
  /// See also [fikushonLoad].
  FikushonLoadProvider(
    String url,
    ExtensionApiV1 service,
  ) : this._internal(
          (ref) => fikushonLoad(
            ref as FikushonLoadRef,
            url,
            service,
          ),
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
          service: service,
        );

  FikushonLoadProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.url,
    required this.service,
  }) : super.internal();

  final String url;
  final ExtensionApiV1 service;

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
        service: service,
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
        other.service == service;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);
    hash = _SystemHash.combine(hash, service.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FikushonLoadRef on AutoDisposeFutureProviderRef<ExtensionFikushonWatch> {
  /// The parameter `url` of this provider.
  String get url;

  /// The parameter `service` of this provider.
  ExtensionApiV1 get service;
}

class _FikushonLoadProviderElement
    extends AutoDisposeFutureProviderElement<ExtensionFikushonWatch>
    with FikushonLoadRef {
  _FikushonLoadProviderElement(super.provider);

  @override
  String get url => (origin as FikushonLoadProvider).url;
  @override
  ExtensionApiV1 get service => (origin as FikushonLoadProvider).service;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
