/// Mirrors test/ui/features/watch/watch_error_layout_matrix_test.dart states
/// for the catalog.
///
/// The test drives a 5-surface layout matrix (320x700, 360x844, 412x915,
/// 1000x520, 915x412) x 3 error/loading states. The catalog keeps the two
/// shape classes that render differently — portrait phone (small-phone cell;
/// the 360x844/412x915 portrait cells duplicate it) and landscape (the two
/// landscape cells render the same fullscreen branch; 1000x520 stands in).
///
/// Skipped states:
/// - skipped: 'Error details dialog open at every phone shape' —
///   interactive: tap 'Error details' on the error use-cases.

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
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_error_state.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_loading_state.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:widgetbook/widgetbook.dart';

const _url = 'https://example.com/daemons';

/// The mirrored-from-tests components of the error layout matrix test.
List<WidgetbookComponent> buildErrorLayoutMatrixComponents() => [
  WidgetbookComponent(
    name: 'Watch layout matrix',
    useCases: [
      WidgetbookUseCase(
        name: 'Loading · small phone 320x700',
        builder: (context) => _MatrixCanvas(
          size: const Size(320, 700),
          child: WatchLoadingState(
            param: _param(),
            epProvider: episodeProvider(_param()),
            onBack: () {},
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Loading · landscape-short 1000x520',
        builder: (context) => _MatrixCanvas(
          size: const Size(1000, 520),
          child: WatchLoadingState(
            param: _param(),
            epProvider: episodeProvider(_param()),
            onBack: () {},
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Mirror error · small phone 320x700',
        builder: (context) => _MatrixCanvas(
          size: const Size(320, 700),
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
      WidgetbookUseCase(
        name: 'Mirror error · landscape-short 1000x520',
        builder: (context) => _MatrixCanvas(
          size: const Size(1000, 520),
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
      WidgetbookUseCase(
        name: 'Long-message error · small phone 320x700',
        builder: (context) => _MatrixCanvas(
          size: const Size(320, 700),
          child: WatchErrorState(
            param: _param(),
            epProvider: episodeProvider(_param()),
            error: Exception(_longErrorMessage()),
            trace: StackTrace.current,
            onBack: () {},
            onRetry: () {},
            onSelectMirror: (_) {},
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Long-message error · landscape-short 1000x520',
        builder: (context) => _MatrixCanvas(
          size: const Size(1000, 520),
          child: WatchErrorState(
            param: _param(),
            epProvider: episodeProvider(_param()),
            error: Exception(_longErrorMessage()),
            trace: StackTrace.current,
            onBack: () {},
            onRetry: () {},
            onSelectMirror: (_) {},
          ),
        ),
      ),
    ],
  ),
];

/// The gRPC/Js failure text the matrix test wraps several phone shapes with.
String _longErrorMessage() =>
    'gRPC Error (code: 2, UNKNOWN): Js exception:stack: Error: '
    'gateway 504: mirror resolve timeout at mirror '
    '(example.watchfail.v2.js:62:9(3)) with a very long '
    'trailing explanation that wraps across several lines';

/// The matrix cell: an explicit surface size (the test's setSurfaceSize).
class _MatrixCanvas extends StatelessWidget {
  const _MatrixCanvas({required this.size, required this.child});

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
          child: ClipRect(
            child: _Scope(
              create: () => ProviderContainer(
                overrides: [
                  downloadProvider.overrideWith(_FakeDownloads.new),
                  historyPageProvider.overrideWith(_FakeHistory.new),
                ],
              ),
              child: child,
            ),
          ),
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
  api: '2',
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
      title: 'Server 1',
      mirrors: [
        pb.ExtensionMirror(name: 'Mirror A', url: '$_url/mirror-a'),
        pb.ExtensionMirror(name: 'Mirror B', url: '$_url/mirror-b'),
      ],
    ),
  ],
  defaultGroup: 'Server 1',
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
