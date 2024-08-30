// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoLoadHash() => r'2f620cace94a9192b653aebcc527cc5dd33fb754';

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
    r'605ba07f48d523f12b0d711c146f4f5b0f792e06';

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

typedef FetchExtensionRepoRef
    = AutoDisposeFutureProviderRef<List<GithubExtension>>;
String _$fetchExtensionDetailHash() =>
    r'e1b51696b69103a5e3b975a06c1d185623fa36d8';

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
    r'c4afbfedcbbc4092a7844664ddce80e8fec70272';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
