import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderContainer;
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/src/item_positions_listener.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/src/item_positions_notifier.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/infinite_window.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// Pure window-math tests for the manga reader's infinite scroll.
///
/// The reader runs against a bare container: no widget tree, no network —
/// the adjacent-chapter fetch is stubbed through [debugChapterFetcher] and
/// the scroll position is simulated by poking the positions stream the way
/// the list does.
ProviderContainer _container() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
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

List<ExtensionEpisode> _episodes(int count) => [
  for (var i = 0; i < count; i++)
    ExtensionEpisode(name: 'Chapter ${i + 1}', url: 'chapter-${i + 1}'),
];

List<String> _pages(String chapter, int count) => [
  for (var i = 0; i < count; i++) '$chapter-p$i',
];

void _setPositions(ProviderContainer container, List<ItemPosition> positions) {
  final listener = container
      .read(mangaReaderProvider.notifier)
      .itemPositionsListener;
  (listener as ItemPositionsNotifier).itemPositions.value = positions;
}

ItemPosition _at(int index) =>
    ItemPosition(index: index, itemLeadingEdge: 0, itemTrailingEdge: 1);

/// Opens the reader in webtoon mode with a fetcher that serves
/// `<episode-name>-p<n>` pages on demand.
void _open(
  ProviderContainer container, {
  required List<ExtensionEpisode> episodes,
  required int episodeIndex,
  List<String>? urls,
  int? resumePage,
  Future<List<String>?> Function(String url)? fetcher,
  void Function(int groupIndex, int episodeIndex)? onFlip,
}) {
  // Hold a subscription for the whole test: without one the auto-dispose
  // provider is torn down between `read` calls across an await, wiping the
  // window.
  container.listen(mangaReaderProvider, (_, _) {});
  final notifier = container.read(mangaReaderProvider.notifier);
  notifier.debugChapterFetcher = fetcher == null
      ? (url) async => _pagesForUrl(url)
      : (url) async => fetcher(url);
  notifier.open(
    groupIndex: 0,
    episodeIndex: episodeIndex,
    totalPage: urls?.length ?? 3,
    resumePage: resumePage,
    episodes: episodes,
    urls: urls,
    meta: _meta,
    detailUrl: 'detail',
    onTrackedEpisodeChanged: onFlip,
  );
}

List<String> _pagesForUrl(String url) {
  // Fetched pages mirror test fixture names: chapter-N -> chapter-N-pM.
  final match = RegExp(r'chapter-(\d+)').firstMatch(url);
  final chapter = match == null ? url : 'chapter-${match.group(1)}';
  return _pages(chapter, 2);
}

void main() {
  setUp(() {
    MiruSettings.seedDefaultsForTest();
    MiruSettings.setSettingSync(SettingKey.mangaReadingMode, 'webToon');
  });

  group('slot math', () {
    test('single loaded anchor yields pages only (no junctions)', () {
      final container = _container();
      _open(
        container,
        episodes: _episodes(3),
        episodeIndex: 0,
        urls: _pages('chapter-1', 3),
      );
      final slots = container.read(mangaReaderProvider.notifier).currentSlots();
      expect(slots.map((s) => s.kind).toList(), [
        SlotKind.seriesStart,
        SlotKind.page,
        SlotKind.page,
        SlotKind.page,
      ]);
    });

    test('junction lands between the two loaded chapters', () {
      final slots = buildSlots(
        [
          ChapterSegment<String>(
            episodeIndex: 0,
            name: 'A',
            url: 'a',
            items: const ['a0', 'a1'],
          ),
          ChapterSegment<String>(
            episodeIndex: 1,
            name: 'B',
            url: 'b',
            items: const ['b0'],
          ),
        ],
        atSeriesStart: true,
        atSeriesEnd: true,
      );
      expect(slots.map((s) => s.kind).toList(), [
        SlotKind.seriesStart,
        SlotKind.page,
        SlotKind.page,
        SlotKind.junction,
        SlotKind.page,
        SlotKind.seriesEnd,
      ]);
    });

    test('loading segment contributes one placeholder slot', () {
      final slots = buildSlots(
        [
          ChapterSegment<String>(
            episodeIndex: 1,
            name: 'B',
            url: 'b',
            items: const ['b0'],
          ),
          ChapterSegment<String>(
            episodeIndex: 2,
            name: 'C',
            url: 'c',
            items: null,
            loading: true,
          ),
        ],
        atSeriesStart: false,
        atSeriesEnd: false,
      );
      expect(slots.map((s) => s.kind).toList(), [
        SlotKind.page,
        SlotKind.junction,
        SlotKind.loading,
      ]);
    });

    test('failed segment contributes one error slot', () {
      final slots = buildSlots(
        [
          ChapterSegment<String>(
            episodeIndex: 1,
            name: 'B',
            url: 'b',
            items: const ['b0'],
          ),
          ChapterSegment<String>(
            episodeIndex: 2,
            name: 'C',
            url: 'c',
            items: null,
            failed: true,
          ),
        ],
        atSeriesStart: false,
        atSeriesEnd: false,
      );
      expect(slots.last.kind, SlotKind.error);
    });
  });

  group('infinite window', () {
    test('opening seeds the anchor chapter with real pages', () {
      final container = _container();
      _open(
        container,
        episodes: _episodes(3),
        episodeIndex: 1,
        urls: _pages('chapter-2', 4),
      );
      final state = container.read(mangaReaderProvider);
      expect(state.segments, hasLength(1));
      expect(state.segments.single.episodeIndex, 1);
      expect(state.totalPage, 4);
      expect(state.itemPosition, 0);
      expect(state.trackedSegmentIndex, 0);
    });

    test('scrolling to the bottom fetches the next chapter and appends it', () async {
      final container = _container();
      _open(
        container,
        episodes: _episodes(3),
        episodeIndex: 0,
        urls: _pages('chapter-1', 2),
      );
      // Only the anchor exists at open; nothing loads until the viewport
      // nears an edge.
      expect(
        container
            .read(mangaReaderProvider)
            .segments
            .map((s) => s.episodeIndex)
            .toList(),
        [0],
      );
      // Position the viewport on the last anchor page — the prefetch trigger
      // for the next window entry.
      _setPositions(container, [_at(1)]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(
        container
            .read(mangaReaderProvider)
            .segments
            .map((s) => s.episodeIndex)
            .toList(),
        [0, 1],
      );
      // The junction tile sits at flat 2 — scroll into it and the next chapter
      // triggers eagerly.
      _setPositions(container, [_at(2)]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      final state = container.read(mangaReaderProvider);
      expect(state.segments.map((s) => s.episodeIndex).toList(), [0, 1, 2]);
      expect(state.segments[1].items, isNotNull);
      expect(state.segments[1].loading, isFalse);
      expect(state.segments[2].items, isNotNull);
      expect(state.segments[2].loading, isFalse);
    });

    test('scrolling near the top prepends the previous chapter', () async {
      final container = _container();
      _open(
        container,
        episodes: _episodes(3),
        episodeIndex: 1,
        urls: _pages('chapter-2', 2),
      );
      _setPositions(container, [_at(1)]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      final state = container.read(mangaReaderProvider);
      // Near the top loads A; the same prefetch loads C at the other edge —
      // both neighbors are legitimate prefetches of a small window.
      expect(state.segments.map((s) => s.episodeIndex).toList(), [0, 1, 2]);
      // The anchor moved one slot into the list; the tracked index follows.
      expect(state.trackedSegmentIndex, 1);
      expect(state.totalPage, 2);
    });

    test(
      'crossing the junction flips attribution to the next chapter',
      () async {
        final flips = <int>[];
        final container = _container();
        _open(
          container,
          episodes: _episodes(3),
          episodeIndex: 0,
          urls: _pages('chapter-1', 2),
          onFlip: (groupIndex, episodeIndex) => flips.add(episodeIndex),
        );
        _setPositions(container, [_at(2)]);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        // Slots now: [seriesStart=0, a0=1, a1=2, junction=3, b0=4, b1=5]
        _setPositions(container, [_at(4)]);
        final state = container.read(mangaReaderProvider);
        expect(state.trackedSegmentIndex, 1);
        expect(state.totalPage, 2);
        expect(state.itemPosition, 0);
        expect(flips, [1]);
        // The shell consumes the flip exactly once.
        expect(
          container.read(mangaReaderProvider.notifier).consumeChapterFlip(),
          isTrue,
        );
        expect(
          container.read(mangaReaderProvider.notifier).consumeChapterFlip(),
          isFalse,
        );
      },
    );

    test(
      'flipping upward into the previous chapter attributes pages to it',
      () async {
        final flips = <int>[];
        final container = _container();
        _open(
          container,
          episodes: _episodes(3),
          episodeIndex: 1,
          urls: _pages('chapter-2', 2),
          onFlip: (groupIndex, episodeIndex) => flips.add(episodeIndex),
        );
        _setPositions(container, [_at(1)]);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        // Slots now: [seriesStart=0, a0=1, a1=2, junction=3, b0=4, b1=5]
        for (var frame = 0; frame < 4; frame++) {
          _setPositions(container, [_at(1)]);
          await Future<void>.delayed(Duration.zero);
        }
        final state = container.read(mangaReaderProvider);
        expect(state.trackedSegmentIndex, 0);
        expect(state.totalPage, 2);
        expect(state.itemPosition, 0);
        expect(flips, [0]);
      },
    );

    test('failed fetch lands an error slot and retry refetches', () async {
      var failNext = true;
      final container = _container();
      _open(
        container,
        episodes: _episodes(2),
        episodeIndex: 0,
        urls: _pages('chapter-1', 2),
        fetcher: (url) => failNext
            ? Future<List<String>?>.value(null)
            : Future<List<String>?>.value(_pages('chapter-2', 2)),
      );
      _setPositions(container, [_at(2)]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      var state = container.read(mangaReaderProvider);
      expect(state.segments[1].failed, isTrue);

      failNext = false;
      await container.read(mangaReaderProvider.notifier).retrySegment(1);
      state = container.read(mangaReaderProvider);
      expect(state.segments[1].failed, isFalse);
      expect(state.segments[1].items, _pages('chapter-2', 2));
    });

    test('pages remain in order across a prepend + flip sequence', () async {
      final flips = <int>[];
      final container = _container();
      _open(
        container,
        episodes: _episodes(3),
        episodeIndex: 1,
        urls: _pages('chapter-2', 2),
        onFlip: (groupIndex, episodeIndex) => flips.add(episodeIndex),
      );
      // Scroll to the bottom of B -> C loads.
      _setPositions(container, [_at(2)]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      // Slots now: [b0=0, b1=1, junction=2, c0=3, c1=4]
      // Scroll up to top: A loads before B.
      _setPositions(container, [_at(0)]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      var state = container.read(mangaReaderProvider);
      expect(state.segments.map((s) => s.episodeIndex).toList(), [0, 1, 2]);
      // Both neighbors prefetch when the window is a single chapter.
      // Slots now: [seriesStart=0, a0=1, a1=2, junction=3, b0=4, b1=5, junction=6, c0=7, c1=8]
      // Walk every page slot in order and collect attribution flips.
      final attrs = <String>[];
      for (final flat in [1, 2, 4, 5, 7, 8]) {
        // Backwards flips are held until the same index persists across frames.
        for (var frame = 0; frame < 5; frame++) {
          _setPositions(container, [_at(flat)]);
          state = container.read(mangaReaderProvider);
        }
        attrs.add('ch${state.trackedSegmentIndex}:p${state.itemPosition}');
      }
      expect(attrs, [
        'ch0:p0',
        'ch0:p1',
        'ch1:p0',
        'ch1:p1',
        'ch2:p0',
        'ch2:p1',
      ]);
      // Crossing each boundary forward fires the flip exactly once.
      expect(flips, [0, 1, 2]);
    });
  });
}
