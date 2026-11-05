// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VideoPlayerNotifier)
final videoPlayerProvider = VideoPlayerNotifierFamily._();

final class VideoPlayerNotifierProvider
    extends $NotifierProvider<VideoPlayerNotifier, VideoPlayerTickState> {
  VideoPlayerNotifierProvider._({
    required VideoPlayerNotifierFamily super.from,
    required (
      String?, {
      Map<String, String>? headers,
      Size? initialRatio,
      ExtensionBangumiWatchTorrent? torrent,
      String? localPath,
      Map<String, String> qualityMap,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'videoPlayerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$videoPlayerNotifierHash();

  @override
  String toString() {
    return r'videoPlayerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  VideoPlayerNotifier create() => VideoPlayerNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VideoPlayerTickState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VideoPlayerTickState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VideoPlayerNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$videoPlayerNotifierHash() =>
    r'b5e4ced89f66f44ea351456f0709208cef4deebf';

final class VideoPlayerNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          VideoPlayerNotifier,
          VideoPlayerTickState,
          VideoPlayerTickState,
          VideoPlayerTickState,
          (
            String?, {
            Map<String, String>? headers,
            Size? initialRatio,
            ExtensionBangumiWatchTorrent? torrent,
            String? localPath,
            Map<String, String> qualityMap,
          })
        > {
  VideoPlayerNotifierFamily._()
    : super(
        retry: null,
        name: r'videoPlayerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VideoPlayerNotifierProvider call(
    String? mediaUrl, {
    Map<String, String>? headers,
    Size? initialRatio,
    ExtensionBangumiWatchTorrent? torrent,
    String? localPath,
    Map<String, String> qualityMap = const {},
  }) => VideoPlayerNotifierProvider._(
    argument: (
      mediaUrl,
      headers: headers,
      initialRatio: initialRatio,
      torrent: torrent,
      localPath: localPath,
      qualityMap: qualityMap,
    ),
    from: this,
  );

  @override
  String toString() => r'videoPlayerProvider';
}

abstract class _$VideoPlayerNotifier extends $Notifier<VideoPlayerTickState> {
  late final _$args =
      ref.$arg
          as (
            String?, {
            Map<String, String>? headers,
            Size? initialRatio,
            ExtensionBangumiWatchTorrent? torrent,
            String? localPath,
            Map<String, String> qualityMap,
          });
  String? get mediaUrl => _$args.$1;
  Map<String, String>? get headers => _$args.headers;
  Size? get initialRatio => _$args.initialRatio;
  ExtensionBangumiWatchTorrent? get torrent => _$args.torrent;
  String? get localPath => _$args.localPath;
  Map<String, String> get qualityMap => _$args.qualityMap;

  VideoPlayerTickState build(
    String? mediaUrl, {
    Map<String, String>? headers,
    Size? initialRatio,
    ExtensionBangumiWatchTorrent? torrent,
    String? localPath,
    Map<String, String> qualityMap = const {},
  });
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VideoPlayerTickState, VideoPlayerTickState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VideoPlayerTickState, VideoPlayerTickState>,
              VideoPlayerTickState,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(
        _$args.$1,
        headers: _$args.headers,
        initialRatio: _$args.initialRatio,
        torrent: _$args.torrent,
        localPath: _$args.localPath,
        qualityMap: _$args.qualityMap,
      ),
    );
  }
}
