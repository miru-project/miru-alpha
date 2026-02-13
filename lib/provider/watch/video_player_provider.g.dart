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
      String, {
      List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
      Map<String, String>? headers,
      Size? initialRatio,
      ExtensionBangumiWatchTorrent? torrent,
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
    r'ffebb06e74380af2ca5f500df7ffe7c528675dc1';

final class VideoPlayerNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          VideoPlayerNotifier,
          VideoPlayerTickState,
          VideoPlayerTickState,
          VideoPlayerTickState,
          (
            String, {
            List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
            Map<String, String>? headers,
            Size? initialRatio,
            ExtensionBangumiWatchTorrent? torrent,
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
    String url, {
    List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    Map<String, String>? headers,
    Size? initialRatio,
    ExtensionBangumiWatchTorrent? torrent,
  }) => VideoPlayerNotifierProvider._(
    argument: (
      url,
      subtitlesRaw: subtitlesRaw,
      headers: headers,
      initialRatio: initialRatio,
      torrent: torrent,
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
            String, {
            List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
            Map<String, String>? headers,
            Size? initialRatio,
            ExtensionBangumiWatchTorrent? torrent,
          });
  String get url => _$args.$1;
  List<ExtensionBangumiWatchSubtitle>? get subtitlesRaw => _$args.subtitlesRaw;
  Map<String, String>? get headers => _$args.headers;
  Size? get initialRatio => _$args.initialRatio;
  ExtensionBangumiWatchTorrent? get torrent => _$args.torrent;

  VideoPlayerTickState build(
    String url, {
    List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    Map<String, String>? headers,
    Size? initialRatio,
    ExtensionBangumiWatchTorrent? torrent,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VideoPlayerTickState, VideoPlayerTickState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VideoPlayerTickState, VideoPlayerTickState>,
              VideoPlayerTickState,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(
        _$args.$1,
        subtitlesRaw: _$args.subtitlesRaw,
        headers: _$args.headers,
        initialRatio: _$args.initialRatio,
        torrent: _$args.torrent,
      ),
    );
  }
}
