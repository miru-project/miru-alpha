// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_player_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VideoPlayerViewModel)
final videoPlayerViewModelProvider = VideoPlayerViewModelFamily._();

final class VideoPlayerViewModelProvider
    extends $NotifierProvider<VideoPlayerViewModel, VideoPlayerViewState> {
  VideoPlayerViewModelProvider._({
    required VideoPlayerViewModelFamily super.from,
    required ({
      String? mediaUrl,
      List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
      Map<String, String>? headers,
      String? localPath,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'videoPlayerViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$videoPlayerViewModelHash();

  @override
  String toString() {
    return r'videoPlayerViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  VideoPlayerViewModel create() => VideoPlayerViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VideoPlayerViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VideoPlayerViewState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VideoPlayerViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$videoPlayerViewModelHash() =>
    r'cfb1040f83a2e55fbd66a5e0ef74718f4162e23f';

final class VideoPlayerViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          VideoPlayerViewModel,
          VideoPlayerViewState,
          VideoPlayerViewState,
          VideoPlayerViewState,
          ({
            String? mediaUrl,
            List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
            Map<String, String>? headers,
            String? localPath,
          })
        > {
  VideoPlayerViewModelFamily._()
    : super(
        retry: null,
        name: r'videoPlayerViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VideoPlayerViewModelProvider call({
    required String? mediaUrl,
    List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    Map<String, String>? headers,
    String? localPath,
  }) => VideoPlayerViewModelProvider._(
    argument: (
      mediaUrl: mediaUrl,
      subtitlesRaw: subtitlesRaw,
      headers: headers,
      localPath: localPath,
    ),
    from: this,
  );

  @override
  String toString() => r'videoPlayerViewModelProvider';
}

abstract class _$VideoPlayerViewModel extends $Notifier<VideoPlayerViewState> {
  late final _$args =
      ref.$arg
          as ({
            String? mediaUrl,
            List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
            Map<String, String>? headers,
            String? localPath,
          });
  String? get mediaUrl => _$args.mediaUrl;
  List<ExtensionBangumiWatchSubtitle>? get subtitlesRaw => _$args.subtitlesRaw;
  Map<String, String>? get headers => _$args.headers;
  String? get localPath => _$args.localPath;

  VideoPlayerViewState build({
    required String? mediaUrl,
    List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    Map<String, String>? headers,
    String? localPath,
  });
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VideoPlayerViewState, VideoPlayerViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VideoPlayerViewState, VideoPlayerViewState>,
              VideoPlayerViewState,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(
        mediaUrl: _$args.mediaUrl,
        subtitlesRaw: _$args.subtitlesRaw,
        headers: _$args.headers,
        localPath: _$args.localPath,
      ),
    );
  }
}
