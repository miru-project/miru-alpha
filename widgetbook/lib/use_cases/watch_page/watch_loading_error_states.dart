/// Mirrors test/ui/features/watch/watch_loading_error_states_test.dart states
/// for the catalog.
///
/// Skipped states (behaviour / interaction audits with no distinct visuals):
/// - skipped: 'slow-bridge hint appears after 3 seconds' — folded into the
///   portrait loading use-case: the hint appears live after 3s on canvas.
/// - skipped: 'disabled viewport shells are not tappable controls' — same
///   render as the portrait loading use-case; interaction assertion only.
/// - skipped: 'error details dialog shows the dump and copy' — interactive:
///   tap the card's 'Error details' ghost button in the catalog.
/// - skipped: 'Retry Connection uses the smaller size' — same render as the
///   extension-failure use-case; size assertion only.
/// - skipped: 'watch error taxonomy' group — pure unit tests, no widgets.
/// - skipped: 'retry re-requests the same url and clears the error' —
///   behaviour; the Retry button is live in the catalog use-case.

library;

import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb;
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_tile.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_error_state.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_header_section.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_loading_state.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_video_viewport.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

const _url = 'https://example.com/daemons';

/// The mirrored-from-tests components of the loading / error states test.
List<WidgetbookComponent> buildLoadingErrorStateComponents() => [
  WidgetbookComponent(
    name: 'WatchLoadingState',
    useCases: [
      WidgetbookUseCase(
        name: 'Portrait · resolving Ep 1 (slow hint after 3s)',
        builder: (context) => PhoneFrame(
          child: _Scope(
            create: () => ProviderContainer(
              overrides: [
                downloadProvider.overrideWith(_FakeDownloads.new),
                historyPageProvider.overrideWith(_FakeHistory.new),
              ],
            ),
            child: WatchLoadingState(
              param: _param(),
              epProvider: episodeProvider(_param()),
              onBack: () {},
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Landscape-short 1000x520 · fullscreen loading viewport',
        builder: (context) => _Canvas(
          size: const Size(1000, 520),
          child: _Scope(
            create: () => ProviderContainer(
              overrides: [
                downloadProvider.overrideWith(_FakeDownloads.new),
                historyPageProvider.overrideWith(_FakeHistory.new),
              ],
            ),
            child: WatchLoadingState(
              param: _param(),
              epProvider: episodeProvider(_param()),
              onBack: () {},
            ),
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'WatchErrorState',
    useCases: [
      WidgetbookUseCase(
        name: 'Portrait · extension failure (no mirrors)',
        builder: (context) => PhoneFrame(
          child: _Scope(
            create: () => ProviderContainer(
              overrides: [
                downloadProvider.overrideWith(_FakeDownloads.new),
                historyPageProvider.overrideWith(_FakeHistory.new),
              ],
            ),
            child: WatchErrorState(
              param: _param(),
              epProvider: episodeProvider(_param()),
              error: Exception('HLS decrypt timeout after 8.2s'),
              trace: StackTrace.current,
              onBack: () {},
              onRetry: () {},
              onSelectMirror: (_) {},
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Portrait · mirror failure (Switch Mirror)',
        builder: (context) => PhoneFrame(
          child: _Scope(
            create: () => ProviderContainer(
              overrides: [
                downloadProvider.overrideWith(_FakeDownloads.new),
                historyPageProvider.overrideWith(_FakeHistory.new),
              ],
            ),
            child: WatchErrorState(
              param: _param(),
              epProvider: episodeProvider(_param()),
              error: WatchMirrorException(_v2watch(), Exception('gateway 504')),
              trace: StackTrace.current,
              onBack: () {},
              onRetry: () {},
              onSelectMirror: (_) {},
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Landscape-short 1000x520 · mirror failure fullscreen',
        builder: (context) => _Canvas(
          size: const Size(1000, 520),
          child: _Scope(
            create: () => ProviderContainer(
              overrides: [
                downloadProvider.overrideWith(_FakeDownloads.new),
                historyPageProvider.overrideWith(_FakeHistory.new),
              ],
            ),
            child: WatchErrorState(
              param: _param(),
              epProvider: episodeProvider(_param()),
              error: WatchMirrorException(_v2watch(), Exception('gateway')),
              trace: StackTrace.current,
              onBack: () {},
              onRetry: () {},
              onSelectMirror: (_) {},
            ),
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'WatchVideoViewport',
    useCases: [
      // Mounting the overlay queries the volume plugin post-frame; on the
      // catalog desktop shell that answer is absent (same as the test env).
      WidgetbookUseCase(
        name: 'Video-request error card (403) · portrait',
        builder: (context) {
          final vidPr = videoPlayerProvider(_url);
          return PhoneFrame(
            child: _Scope(
              create: () => ProviderContainer(
                overrides: [vidPr.overrideWith(_FakeErrorVideoPlayer.new)],
              ),
              child: WatchVideoViewport(
                vidPr: vidPr,
                epProvider: episodeProvider(_param()),
                meta: _meta(),
                title: 'Daemons',
                episodeName: 'Ep 1',
                videoType: 'HLS',
                fullscreen: false,
                onToggleFullscreen: () {},
                onClose: () {},
              ),
            ),
          );
        },
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'MobileDetailTile',
    useCases: [
      WidgetbookUseCase(
        name: 'Resolving row · Loading pill, no download',
        builder: (context) => catalogFrame(
          _Scope(
            create: () => ProviderContainer(
              overrides: [downloadProvider.overrideWith(_FakeDownloads.new)],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: MobileDetailTile(
                item: _episodes(5).first.urls[0],
                idx: 0,
                position: 1,
                selectedGpIndex: 0,
                detail: _detail(),
                meta: _meta(),
                detailUrl: _url,
                detailPr: null,
                history: null,
                isDownloaded: false,
                status: EpisodeTileStatus.resolving,
              ),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Failed row · Failed badge + Retry',
        builder: (context) => catalogFrame(
          _Scope(
            create: () => ProviderContainer(
              overrides: [downloadProvider.overrideWith(_FakeDownloads.new)],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: MobileDetailTile(
                item: _episodes(5).first.urls[0],
                idx: 0,
                position: 1,
                selectedGpIndex: 0,
                detail: _detail(),
                meta: _meta(),
                detailUrl: _url,
                detailPr: null,
                history: null,
                isDownloaded: false,
                status: EpisodeTileStatus.failed,
                statusDetail: 'Exception: gateway 504',
                onRetry: () {},
              ),
            ),
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'WatchHeaderSection',
    useCases: [
      WidgetbookUseCase(
        name: 'statusMeta override · custom status line',
        builder: (context) {
          final param = _param();
          return catalogFrame(
            _Scope(
              create: () => ProviderContainer(
                overrides: [
                  downloadProvider.overrideWith(_FakeDownloads.new),
                  favoritePageProvider.overrideWith(_FakeFavorites.new),
                ],
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: WatchHeaderSection(
                  showTitle: param.name,
                  groupTitle: 'Season 1',
                  episodeIndex: 0,
                  episodeName: 'Episode 1',
                  detail: Detail(
                    title: param.name,
                    detailUrl: param.detailUrl,
                    package: param.meta.packageName,
                  ),
                  meta: param.meta,
                  detailUrl: param.detailUrl,
                  epProvider: episodeProvider(param),
                  favorited: false,
                  statusMeta: const Text('Custom status line'),
                ),
              ),
            ),
          );
        },
      ),
    ],
  ),
];

Detail _detail() => Detail(
  title: 'Daemons',
  detailUrl: _url,
  package: 'test.pkg',
  episodes: _episodes(5),
);

/// A phone-sized canvas with an explicit size — the landscape stand-in for
/// [PhoneFrame] (mirrors the tests' setSurfaceSize shapes).
class _Canvas extends StatelessWidget {
  const _Canvas({required this.size, required this.child});

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: ColoredBox(
          color: context.theme.colors.background,
          child: ClipRect(child: child),
        ),
      ),
    );
  }
}

/// Holds one [ProviderContainer] for the use-case's lifetime.
class _Scope extends StatefulWidget {
  const _Scope({required this.create, required this.child});

  /// Builds the use-case's [ProviderContainer] (with its overrides) once.
  final ProviderContainer Function() create;
  final Widget child;

  @override
  State<_Scope> createState() => _ScopeState();
}

class _ScopeState extends State<_Scope> {
  late final ProviderContainer _container = widget.create();

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      UncontrolledProviderScope(container: _container, child: widget.child);
}

ExtensionMeta _meta() => ExtensionMeta(
  name: 'ExampleA',
  version: '2.0.0',
  author: 't',
  license: 'MIT',
  lang: 'en',
  packageName: 'test.pkg',
  webSite: 'https://example.com',
  description: 'test provider',
  tags: const [],
  api: 'v2',
  type: ExtensionType.bangumi,
);

List<ExtensionEpisodeGroup> _episodes(int count) => [
  ExtensionEpisodeGroup(
    title: 'Season 1',
    urls: [
      for (var i = 1; i <= count; i++)
        ExtensionEpisode(name: 'Episode $i', url: '$_url/ep$i'),
    ],
  ),
];

WatchParams _param() => WatchParams(
  meta: _meta(),
  type: ExtensionType.bangumi,
  url: '$_url/ep1',
  selectedGroupIndex: 0,
  selectedEpisodeIndex: 0,
  name: 'Daemons of the Shadow Realm',
  detailImageUrl: '',
  detailUrl: _url,
  savePath: null,
  epGroup: _episodes(5),
);

pb.ExtensionWatch _v2watch() => pb.ExtensionWatch(
  groups: [
    pb.ExtensionMirrorGroup(
      title: 'Vidsrc',
      mirrors: [
        pb.ExtensionMirror(name: 'Mirror A', url: '$_url/mirror-a'),
        pb.ExtensionMirror(name: 'Mirror B', url: '$_url/mirror-b'),
      ],
    ),
  ],
  defaultGroup: 'Vidsrc',
  defaultIndex: 0,
);

/// [DownloadNotifier] without the database/gRPC init.
class _FakeDownloads extends DownloadNotifier {
  @override
  AsyncValue<DownloadState> build() =>
      AsyncData(DownloadState(history: const [], active: const []));
}

/// [HistoryPageNotifier] without the database.
class _FakeHistory extends HistoryPageNotifier {
  @override
  HistoryPageState build() =>
      HistoryPageState(history: const [], filteredHistory: const []);
}

/// [FavoritePageNotifier] with in-memory add/remove.
class _FakeFavorites extends FavoritePageNotifier {
  @override
  FavoritePageState build() => FavoritePageState(
    favorites: const [],
    favoriteGroups: [],
    filteredFavorites: [],
    selectedFavoriteGroups: [],
  );

  @override
  void addFavorite(Favorite favorite) =>
      state = state.copyWith(favorites: [favorite, ...state.favorites]);

  @override
  void deleteFavorite(Favorite favorite) => state = state.copyWith(
    favorites: state.favorites.where((f) => f.id != favorite.id).toList(),
  );
}

/// [VideoPlayerNotifier] whose state carries a video-request error (the fvp
/// 403 path) — [changeVideoQuality] records the re-request and clears the
/// error, standing in for a successful re-open.
class _FakeErrorVideoPlayer extends VideoPlayerNotifier {
  @override
  VideoPlayerTickState build(
    String? mediaUrl, {
    List<pb.ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    Map<String, String>? headers,
    Size? initialRatio,
    ExtensionBangumiWatchTorrent? torrent,
    String? localPath,
    pb.ExtensionWatch? v2watch,
    Map<String, String> qualityMap = const {},
  }) {
    vidController = VideoPlayerController.networkUrl(Uri.parse(_url));
    // Duration ZERO: the gesture overlay's fvp brightness effect fires
    // whenever duration > 0 and demands MdkVideoPlayerPlatform.
    return VideoPlayerTickState(
      v2watch: pb.ExtensionWatch(
        groups: [
          pb.ExtensionMirrorGroup(
            title: 'S1',
            mirrors: [
              pb.ExtensionMirror(name: 'Mirror A', url: '$_url/mirror-a'),
            ],
          ),
        ],
      ),
      playerError: 'Video muzzle: open failed: 403 Forbidden',
    );
  }

  @override
  Future<void> changeVideoQuality(String url) async =>
      state = state.copyWith(clearPlayerError: true);
}
