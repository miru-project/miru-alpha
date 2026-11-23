import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/infinite_window.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/scrollable_positioned_list.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// The resume page must reach the list in BOTH cases:
///
///   1. **init state** — a fresh open. `initialScrollIndex` is read in
///      `initState`, so the canvas must mount already carrying the resume slot.
///   2. **normal** — a re-entry into the same episode. `open()`'s dedupe
///      early-return adopts a resume page that has only just arrived from
///      history, but the segments (and therefore the memo key) do not change,
///      so `initialScrollIndex` is never re-read. The provider publishes the
/// slot on `pendingJumpSlot` and the viewport issues a `jumpTo`.
///
/// These tests drive the real provider through the same listener seam the
/// widget uses, so they cover the logic rather than the widget plumbing.
void main() {
  setUp(() {
    MiruSettings.seedDefaultsForTest();
    MiruSettings.setSettingSync(SettingKey.mangaReadingMode, 'webToon');
  });

  final meta = ExtensionMeta(
    name: 'M',
    version: '1',
    author: 't',
    license: 'MIT',
    lang: 'en',
    packageName: 'p',
    webSite: 'https://e.com',
    tags: [],
    api: 'v2',
    type: ExtensionType.manga,
  );

  List<ExtensionEpisode> episodes(int n) => [
    for (var e = 0; e < n; e++)
      ExtensionEpisode(name: 'C$e', url: 'https://e.com/c$e'),
  ];

  /// Opens the reader on [episodeIndex] with [resumePage] and returns the
  /// container plus the notifier.
  (ProviderContainer, MangaReader) openReader({
    required int episodeIndex,
    required int totalPage,
    int? resumePage,
    int episodeCount = 3,
  }) {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(mangaReaderProvider, (_, _) {});
    final reader = container.read(mangaReaderProvider.notifier);
    reader.debugChapterFetcher = (url) async =>
        List.generate(totalPage, (i) => 'p$i');
    reader.open(
      groupIndex: 0,
      episodeIndex: episodeIndex,
      totalPage: totalPage,
      resumePage: resumePage,
      episodes: episodes(episodeCount),
      urls: List.generate(totalPage, (i) => 'p$i'),
      meta: meta,
      detailUrl: 'https://e.com/d',
    );
    return (container, reader);
  }

  group('init state', () {
    test('a fresh open adopts the resume page into state', () {
      final (container, reader) = openReader(
        episodeIndex: 0,
        totalPage: 12,
        resumePage: 5,
      );

      final state = container.read(mangaReaderProvider);
      expect(state.itemPosition, 5, reason: 'state carries the resume page');
      // The flat slot is offset by the leading seriesStart marker, so page N
    // sits at slot N+1.
      expect(
        reader.initialScrollSlot(),
        6,
        reason: 'the slot includes the leading seriesStart marker',
      );
    });

    test('the resume slot accounts for preceding slots', () {
      // A later episode has the earlier chapters' slots before it.
      final (container, reader) = openReader(
        episodeIndex: 1,
        totalPage: 8,
        resumePage: 3,
      );
      final state = container.read(mangaReaderProvider);
      final slots = reader.currentSlots();

      final expected = slots.indexWhere(
        (s) =>
            s.kind == SlotKind.page &&
            s.segmentIndex == state.trackedSegmentIndex &&
            s.pageIndex == 3,
      );
      expect(
        reader.initialScrollSlot(),
        expected,
        reason: 'the slot must include the preceding chapters',
      );
    });

    test('no resume page opens at slot 0', () {
      final (_, reader) = openReader(episodeIndex: 0, totalPage: 12);
      expect(reader.initialScrollSlot(), 0);
    });
  });

  group('normal (re-entry)', () {
    test('adopting a resume page on an open session publishes a jump slot', () {
      final (container, reader) = openReader(episodeIndex: 0, totalPage: 12);

      // A fresh open publishes its start slot: a canvas mounted from an
      // earlier session (the fork does not remount on a same-group episode
      // switch) must be jumped to the new session's first page.
      expect(
        reader.pendingJumpSlot.value,
        1,
        reason: 'page 0 of ep0 sits at flat 1, after the seriesStart marker',
      );
      // Consume it so the adopt below is measured on its own.
      reader.pendingJumpSlot.value = null;

      // Re-open the SAME episode with a resume page, as a re-entry does. The
      // dedupe early-return adopts the page without reinstalling segments.
      reader.open(
        groupIndex: 0,
        episodeIndex: 0,
        totalPage: 12,
        resumePage: 4,
        episodes: episodes(3),
        urls: List.generate(12, (i) => 'p$i'),
        meta: meta,
        detailUrl: 'https://e.com/d',
      );

      expect(container.read(mangaReaderProvider).itemPosition, 4);
      expect(
        reader.pendingJumpSlot.value,
        5,
        reason: 'the adopted page must be published as a flat slot',
      );
    });

    test('a re-open with no resume page publishes nothing', () {
      final (container, reader) = openReader(episodeIndex: 0, totalPage: 12);
      // Consume any pending value from the open above.
      reader.pendingJumpSlot.value = null;

      reader.open(
        groupIndex: 0,
        episodeIndex: 0,
        totalPage: 12,
        episodes: episodes(3),
        urls: List.generate(12, (i) => 'p$i'),
        meta: meta,
        detailUrl: 'https://e.com/d',
      );

      expect(
        reader.pendingJumpSlot.value,
        isNull,
        reason: 'nothing to jump to when there is no resume page',
      );
    });
  });

  testWidgets('the list opens at initialScrollIndex on first mount', (
    tester,
  ) async {
    // Confirms the fork reads `initialScrollIndex` at mount and lands there.
    final heights = <int, double>{for (var i = 0; i < 40; i++) i: 50.0};
    final controller = ItemScrollController();

    Widget build() => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 500,
          child: ScrollablePositionedList.builder(
            itemScrollController: controller,
            itemCount: 40,
            initialScrollIndex: 7,
            itemBuilder: (context, index) => Container(
              key: ValueKey('i-$index'),
              height: heights[index]!,
              color: index.isEven ? Colors.red : Colors.blue,
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(build());
    await tester.pumpAndSettle();

    final vTop = tester.getRect(find.byType(Scrollable).first).top;
    final y =
        tester
            .renderObject<RenderBox>(find.byKey(const ValueKey('i-7')))
            .localToGlobal(Offset.zero)
            .dy -
        vTop;
    expect(y, closeTo(0.0, 0.5), reason: 'the list must open at index 7');
  });

  testWidgets('changing initialScrollIndex after mount does NOT move it', (
    tester,
  ) async {
    // This is the constraint that forces the pendingJumpSlot design: the fork
    // reads `initialScrollIndex` only in initState, so a changed value on an
    // already-mounted list is ignored.
    final heights = <int, double>{for (var i = 0; i < 60; i++) i: 50.0};
    final controller = ItemScrollController();

    Widget build(int initial) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 500,
          child: ScrollablePositionedList.builder(
            itemScrollController: controller,
            itemCount: 60,
            initialScrollIndex: initial,
            itemBuilder: (context, index) => Container(
              key: ValueKey('n-$index'),
              height: heights[index]!,
              color: index.isEven ? Colors.red : Colors.blue,
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(build(5));
    await tester.pumpAndSettle();
    await tester.pumpWidget(build(30));
    await tester.pumpAndSettle();

    final stillThere = find.byKey(const ValueKey('n-5')).evaluate().isNotEmpty;
    expect(
      stillThere,
      isTrue,
      reason: 'a changed initialScrollIndex is ignored after mount',
    );
  });
}
