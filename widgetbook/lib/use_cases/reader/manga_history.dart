import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/manga_reader.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/features/watch/manga_history_test.dart states for the
/// catalog.
///
/// The history maths (first/final/single/empty progress counts) and the
/// episode-disposal snapshot test are pure provider assertions with no
/// rendered state — skipped. The widget test pumps the reader shell at
/// 1300×700 and disposes it; the catalog mirrors the shell it pumps. The
/// page-10/10 variant lays out identically one page further — the phone-size
/// 'Last page' use-case under MiruMangaReader shows a filled scrubber.

/// The test's history fake: writes land in a list instead of the backend.
class _HistorySink extends HistoryPageNotifier {
  final writes = <History>[];

  @override
  HistoryPageState build() =>
      HistoryPageState(history: [], filteredHistory: []);

  @override
  Future<void> addHistory(History history) async {
    writes.add(history);
  }
}

/// The test's appearance fake.
class _Application extends ApplicationController {
  @override
  ApplicationState build() => ApplicationState(
    themeText: 'light',
    baseColor: 'zinc',
    primaryColor: 'zinc',
    themeData: ThemeUtils.getThemeData(MiruThemes.zinc.light),
    themeMode: ThemeMode.light,
    language: 'en',
  );
}

final ExtensionMeta _meta = ExtensionMeta(
  name: 'Synthetic manga',
  version: '1',
  author: 'test',
  license: 'MIT',
  lang: 'en',
  packageName: 'test.manga',
  webSite: 'https://example.com',
  tags: [],
  api: 'v2',
  type: ExtensionType.manga,
);

WatchParams _params() => WatchParams(
  meta: _meta,
  type: ExtensionType.manga,
  url: 'chapter-1',
  selectedGroupIndex: 0,
  selectedEpisodeIndex: 0,
  name: 'Synthetic manga',
  detailImageUrl: '',
  detailUrl: 'detail',
  savePath: null,
  epGroup: [
    ExtensionEpisodeGroup(
      title: 'Chapters',
      urls: [
        ExtensionEpisode(name: 'Chapter 1', url: 'chapter-1'),
        ExtensionEpisode(name: 'Chapter 2', url: 'chapter-2'),
      ],
    ),
  ],
);

/// Owns the container and mounts the shell at the test's 1300×700 window,
/// scaled to fit the catalog viewport the way a screenshot of it would.
class _WideStage extends StatefulWidget {
  const _WideStage({required this.container, required this.child});

  final ProviderContainer container;
  final Widget child;

  @override
  State<_WideStage> createState() => _WideStageState();
}

class _WideStageState extends State<_WideStage> {
  @override
  void dispose() {
    widget.container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: widget.container,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1300, 700)),
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 1300,
            height: 700,
            child: ClipRect(child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// Use-cases for the MiruMangaReader component, mirrored from the history
/// test's widget case.
List<WidgetbookUseCase> mangaHistoryUseCases() => [
  WidgetbookUseCase(
    name: 'Wide window (1300×700) — paged shell',
    builder: (context) {
      MiruSettings.seedDefaults();
      final sink = _HistorySink();
      final params = _params();
      final container = ProviderContainer(
        overrides: [
          historyPageProvider.overrideWith(() => sink),
          applicationControllerProvider.overrideWith(_Application.new),
        ],
      );
      // The test's fixture: ten pages with empty URLs, so every page shows
      // the error child — the shell's layout is what the test exercises.
      final data = ExtensionMangaWatch(urls: List.filled(10, ''));
      return catalogFrame(
        _WideStage(
          container: container,
          child: MiruMangaReader(
            value: data,
            name: params.name,
            meta: _meta,
            url: params.url,
            epProvider: episodeProvider(params),
          ),
        ),
      );
    },
  ),
];
