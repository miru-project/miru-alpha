import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/src/item_positions_listener.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/src/item_positions_notifier.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/manga_reader.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/infinite_window.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// Complete scroll-load test for the infinite webtoon window: two chained
/// upward loads with a 100 ms neighbour-fetch delay, and assertions on flat
/// index, tracked chapter and slot order at every hop — the regime the
/// "flicker / jump to an incorrect index" report came from.
void main() {
  setUp(() {
    MiruSettings.seedDefaultsForTest();
    MiruSettings.setSettingSync(SettingKey.mangaReadingMode, 'webToon');
  });

  setUpAll(() => MiruRequest.ensureInitalized(host: 'http://127.0.0.1:1'));

  final meta = ExtensionMeta(
    name: 'TestManga',
    version: 'v0.0.1',
    author: 't',
    license: 'MIT',
    lang: 'en',
    packageName: 't.pkg',
    webSite: 'https://example.com',
    tags: [],
    api: 'v2',
    type: ExtensionType.manga,
  );

  List<ExtensionEpisode> episodes() => [
    for (var i = 1; i <= 4; i++)
      ExtensionEpisode(name: 'Chapter $i', url: 'https://example.com/chapter-$i'),
  ];

  ExtensionMangaWatch chapter4() => ExtensionMangaWatch(
    urls: [
      for (var i = 0; i < 2; i++) 'https://example.com/chapter-4-p$i',
    ],
  );

  List<String> pagesFor(String url) {
    final match = RegExp(r'chapter-(\d+)').firstMatch(url);
    if (match == null) return const <String>[];
    return [
      for (var i = 0; i < 2; i++)
        'https://example.com/chapter-${match.group(1)}-p$i',
    ];
  }

  WatchParams makeParams(ExtensionMangaWatch w) => WatchParams(
    meta: meta,
    type: ExtensionType.manga,
    url: w.urls.first,
    selectedGroupIndex: 0,
    selectedEpisodeIndex: 3,
    name: 'TestManga',
    detailImageUrl: '',
    detailUrl: 'https://example.com/d',
    savePath: null,
    epGroup: [
      ExtensionEpisodeGroup(title: 'Volume 1', urls: episodes()),
    ],
  );

  EpisodeNotifierState fakeState() => EpisodeNotifierState(
    name: 'TestManga',
    epGroup: [
      ExtensionEpisodeGroup(title: 'Volume 1', urls: episodes()),
    ],
  );

  Future<void> bootReader(
    WidgetTester tester,
    ProviderContainer c,
    ExtensionMangaWatch w,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: FTheme(
          data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
          child: MaterialApp(
            home: MiruMangaReader(
              value: w,
              name: 'TestManga',
              meta: meta,
              url: w.urls.first,
              detailUrl: 'https://example.com/d',
              epProvider: episodeProvider(makeParams(w)),
            ),
          ),
        ),
      ),
    );
    for (var frame = 0; frame < 3; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  testWidgets(
    'two upward prepends with 100ms fetch behave and keep the flat index',
    (tester) async {
      final w = chapter4();
      final c = ProviderContainer(
        overrides: [
          episodeProvider(
            makeParams(w),
          ).overrideWith(() => _FakeEpisodes(fakeState())),
        ],
      );
      addTearDown(c.dispose);

      final notifier = c.read(mangaReaderProvider.notifier);
      // Every neighbour fetch takes 100 ms — the latency regime the prepend
      // raced the list against before [notifyItemsInsertedBefore].
      notifier.debugChapterFetcher = (url) => Future.delayed(
        const Duration(milliseconds: 100),
        () => pagesFor(url),
      );

      await bootReader(tester, c, w);

      // Boot: ch2 and ch3 are loading slots above the anchor (ch4).
      expect(
        c.read(mangaReaderProvider).segments.map((s) => s.episodeIndex),
        [1, 2, 3],
        reason: 'boot prefetches neighbours as loading slots',
      );
      expect(
        c.read(mangaReaderProvider).segments.last.items,
        isNotNull,
        reason: 'the anchor itself is always loaded',
      );

      // Boot's neighbour fetches resolve 100ms later.
      await tester.pump(const Duration(milliseconds: 120));
      for (var frame = 0; frame < 4; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(
        c.read(mangaReaderProvider).segments.map((s) => s.episodeIndex),
        [1, 2, 3],
      );
      expect(
        c.read(mangaReaderProvider).segments.every((s) => s.items != null),
        isTrue,
      );

      final positions =
          notifier.itemPositionsListener as ItemPositionsNotifier;

      // ── prepend #1: user reaches the first page → ch1 loads ──
      for (var frame = 0; frame < 5; frame++) {
        positions.itemPositions.value = [
          ItemPosition(index: 0, itemLeadingEdge: 0, itemTrailingEdge: 1),
        ];
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(
        c.read(mangaReaderProvider).segments.map((s) => s.episodeIndex),
        [0, 1, 2, 3],
        reason: 'loading slot for ch1 prepended',
      );
      expect(
        c.read(mangaReaderProvider).segments.first.items,
        isNull,
        reason: 'ch1 starts as a loading slot',
      );
      await tester.pump(const Duration(milliseconds: 120));
      for (var frame = 0; frame < 4; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(
        c.read(mangaReaderProvider).segments.map((s) => s.episodeIndex),
        [0, 1, 2, 3],
      );
      expect(
        c.read(mangaReaderProvider).segments.every((s) => s.items != null),
        isTrue,
      );
      expect(c.read(mangaReaderProvider).trackedSegmentIndex, 3);



      final slots = notifier.currentSlots();
      expect(
        slots.map((s) => s.kind),
        [
          SlotKind.seriesStart,
          SlotKind.page,
          SlotKind.page,
          SlotKind.junction,
          SlotKind.page,
          SlotKind.page,
          SlotKind.junction,
          SlotKind.page,
          SlotKind.page,
          SlotKind.junction,
          SlotKind.page,
          SlotKind.page,
          SlotKind.seriesEnd,
        ],
        reason: 'series start at the head, series end at the tail',
      );
      expect(
        slots.indexWhere(
          (s) =>
              s.kind == SlotKind.page &&
              s.segmentIndex == 3 &&
              s.pageIndex == 0,
        ),
        10,
        reason: 'anchor ch4 is at flat index 10 after the two prepends',
      );

      // itemPositionsListener lines up with the new slot order.
      positions.itemPositions.value = [
        ItemPosition(index: 10, itemLeadingEdge: 0, itemTrailingEdge: 1),
      ];
      expect(c.read(mangaReaderProvider).itemPosition, 0);
      expect(c.read(mangaReaderProvider).trackedSegmentIndex, 3);

      // And flips attribute pages to the correct chapter.
      for (var frame = 0; frame < 5; frame++) {
        positions.itemPositions.value = [
          ItemPosition(index: 7, itemLeadingEdge: 0, itemTrailingEdge: 1),
        ];
      }
      expect(c.read(mangaReaderProvider).trackedSegmentIndex, 2);
      expect(c.read(mangaReaderProvider).itemPosition, 0);

      for (var frame = 0; frame < 5; frame++) {
        positions.itemPositions.value = [
          ItemPosition(index: 4, itemLeadingEdge: 0, itemTrailingEdge: 1),
        ];
      }
      expect(c.read(mangaReaderProvider).trackedSegmentIndex, 1);
      expect(c.read(mangaReaderProvider).itemPosition, 0);
    },
  );
}

class _FakeEpisodes extends EpisodeNotifier {
  _FakeEpisodes(this._state);
  final EpisodeNotifierState _state;

  @override
  EpisodeNotifierState build(WatchParams param) => _state;

  @override
  Future<void> Function() prepareHistorySave({
    required int progress,
    required int totalProgress,
  }) => () async {};
}
