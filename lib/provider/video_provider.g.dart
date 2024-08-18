// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_provider.dart';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
