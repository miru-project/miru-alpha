import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/manga_reader.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

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

class _Detail extends Detial {
  @override
  DetialState build(String detailUrl, {required ExtensionMeta meta}) {
    final group = ValueNotifier(0);
    ref.onDispose(group.dispose);
    return DetialState(selectedGroup: group);
  }
}

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

final _meta = ExtensionMeta(
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

WatchParams _params({DetialProvider? detail}) => WatchParams(
  meta: _meta,
  type: ExtensionType.manga,
  url: 'chapter-1',
  selectedGroupIndex: 0,
  selectedEpisodeIndex: 0,
  name: 'Synthetic manga',
  detailImageUrl: '',
  detailUrl: 'detail',
  savePath: null,
  detailPr: detail,
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

void main() {
  setUp(MiruSettings.seedDefaultsForTest);

  test('history counts first, final, single and empty pages', () {
    expect(const MangaReaderState(totalPage: 10).historyProgress, 1);
    expect(
      const MangaReaderState(totalPage: 10, itemPosition: 9).historyProgress,
      10,
    );
    expect(const MangaReaderState(totalPage: 1).historyProgress, 1);
    expect(const MangaReaderState().historyProgress, 0);
  });

  test(
    'snapshot survives episode disposal, saves once and replaces detail',
    () async {
      final sink = _HistorySink();
      final detail = detialProvider('detail', meta: _meta);
      final container = ProviderContainer(
        overrides: [
          historyPageProvider.overrideWith(() => sink),
          detail.overrideWith(_Detail.new),
        ],
      );
      addTearDown(container.dispose);
      final detailSubscription = container.listen(detail, (_, _) {});
      addTearDown(detailSubscription.close);
      final provider = episodeProvider(_params(detail: detail));
      final subscription = container.listen(provider, (_, _) {});
      final episodes = container.read(provider.notifier);
      await episodes.prepareHistorySave(progress: 2, totalProgress: 10)();
      final save = episodes.prepareHistorySave(progress: 10, totalProgress: 10);
      episodes.selectEpisode(0, 1);
      subscription.close();
      container.invalidate(provider);
      await save();
      await save();

      expect(sink.writes, hasLength(2));
      expect(sink.writes.last.url, 'chapter-1');
      expect(sink.writes.last.progress, 10);
      final history = container.read(detail).historyList;
      expect(history, hasLength(1));
      expect(history.single.progress / history.single.totalProgress, 1);
    },
  );

  for (final page in [0, 9]) {
    testWidgets('reader disposal saves page ${page + 1}/10 exactly once', (
      tester,
    ) async {
      final sink = _HistorySink();
      final params = _params();
      final data = ExtensionMangaWatch(urls: List.filled(10, ''));
      final container = ProviderContainer(
        overrides: [
          historyPageProvider.overrideWith(() => sink),
          applicationControllerProvider.overrideWith(_Application.new),
        ],
      );
      addTearDown(container.dispose);
      await tester.binding.setSurfaceSize(const Size(1300, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: FTheme(
            data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
            child: MaterialApp(
              home: MiruMangaReader(
                value: data,
                name: params.name,
                meta: _meta,
                url: params.url,
                epProvider: episodeProvider(params),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (page != 0) {
        container
            .read(mangaReaderProvider(0, 2, data).notifier)
            .setPageNumber(page);
        await tester.pump();
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(sink.writes, hasLength(1));
      expect(sink.writes.single.progress, page + 1);
      expect(sink.writes.single.totalProgress, 10);
    });
  }

  test('new manga session never inherits another reader progress', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final first = mangaReaderProvider(
      0,
      2,
      ExtensionMangaWatch(urls: List.filled(10, '')),
    );
    final second = mangaReaderProvider(
      1,
      2,
      ExtensionMangaWatch(urls: List.filled(3, '')),
    );
    final firstSubscription = container.listen(first, (_, _) {});
    final secondSubscription = container.listen(second, (_, _) {});
    addTearDown(firstSubscription.close);
    addTearDown(secondSubscription.close);
    container.read(first.notifier).setPageNumber(9);
    expect(container.read(first).historyProgress, 10);
    expect(container.read(second).historyProgress, 1);
    expect(container.read(second).totalPage, 3);
  });
}
