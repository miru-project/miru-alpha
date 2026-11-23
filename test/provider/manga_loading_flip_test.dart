import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/src/item_positions_listener.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/src/item_positions_notifier.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// A chapter whose pages have not arrived must never become the tracked one.
///
/// Device log of the failure this locks out:
///
///   JUMP commitSegments atHead delta=2 ... segs=[30] -> [29, 30]
///   window_track FLIP seg=0 page=3 tracked=1     <- seg 0 is the LOADING ep29
///   JUMP flip seg=0 page=3 prevEp=30 newEp=29
///   SLV-WIDGET build slots=20 initialScrollSlot=0 itemPosition=0
///   POS flat=5 stable=0                          <- anchor collapsed to 0
///   window_track FLIP seg=1 page=3 tracked=0     <- snaps back
///   JUMP flip seg=1 page=3 prevEp=29 newEp=30 forward=true
///   register history ...                         <- ep29 saved as COMPLETE
///   SLV initState initialScrollIndex=5           <- canvas remounts, offset 0
///
/// The flip into the loading segment zeroed `itemPosition` (no pages to
/// attribute), the flat-index lookup missed and reset the hysteresis anchor to
/// 0, and the flip back fired the forward-completion hook for a chapter the
/// reader never opened — which re-keyed the watch session and remounted the
/// canvas mid-scroll.
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

  ItemPosition at(int index) =>
      ItemPosition(index: index, itemLeadingEdge: 0, itemTrailingEdge: 1);

  void poke(ProviderContainer container, int flat) {
    final listener = container
        .read(mangaReaderProvider.notifier)
        .itemPositionsListener;
    (listener as ItemPositionsNotifier).itemPositions.value = [at(flat)];
  }

  test('a flip into a segment with no pages is refused', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(mangaReaderProvider, (_, _) {});
    final reader = container.read(mangaReaderProvider.notifier);
    reader.debugChapterFetcher = (url) async => const ['p0', 'p1'];
    var completions = 0;
    var trackedChanges = 0;
    reader.open(
      groupIndex: 0,
      episodeIndex: 1,
      totalPage: 3,
      episodes: episodes(4),
      urls: const ['p0', 'p1', 'p2'],
      meta: meta,
      detailUrl: 'https://e.com/d',
      onTrackedEpisodeChanged: (g, e) => trackedChanges++,
      onChapterCompleted: (g, e, t) => completions++,
    );

    // Establish the state the log shows: a loading placeholder prepended
    // ahead of the tracked chapter (segment 0 = loading, segment 1 = open).
    reader.debugEnsureAdjacent(-1);
    final state = container.read(mangaReaderProvider);
    expect(state.segments.map((s) => s.episodeIndex).toList(), <int>[0, 1]);
    expect(state.segments.first.items, isNull, reason: 'ep0 is loading');
    expect(state.trackedSegmentIndex, 1);

    // The stale-index report: attribution lands on segment 0, which has no
    // pages. The flip must be refused — the reader stays on its chapter.
    reader.debugFlipTo(0, 3);

    final after = container.read(mangaReaderProvider);
    expect(
      after.segments[after.trackedSegmentIndex].episodeIndex,
      1,
      reason: 'attribution must stay on the loaded chapter',
    );
    expect(after.itemPosition, 0, reason: 'the page was not zeroed');
    expect(
      completions,
      0,
      reason: 'no forward-completion may fire for an unread chapter',
    );
    expect(
      trackedChanges,
      0,
      reason: 'no selectEpisode — a session reload would remount the canvas',
    );

    // The stream can hammer the loading slot; nothing changes.
    poke(container, 0);
    poke(container, 0);
    expect(container.read(mangaReaderProvider).trackedSegmentIndex, 1);
  });

  test('a real crossing into a loaded chapter still flips', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(mangaReaderProvider, (_, _) {});
    final reader = container.read(mangaReaderProvider.notifier);
    final ep0 = Completer<List<String>?>();
    reader.debugChapterFetcher = (url) => ep0.future;
    reader.open(
      groupIndex: 0,
      episodeIndex: 1,
      totalPage: 2,
      episodes: episodes(4),
      urls: const ['p0', 'p1'],
      meta: meta,
      detailUrl: 'https://e.com/d',
    );
    reader.debugEnsureAdjacent(-1);
    expect(container.read(mangaReaderProvider).segments.first.items, isNull);

    // The pages arrive; the same segment is now legitimately flippable.
    ep0.complete(const ['a0', 'a1']);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final filled = container.read(mangaReaderProvider);
    expect(filled.segments.first.items, isNotNull);
    reader.debugFlipTo(0, 1);

    final after = container.read(mangaReaderProvider);
    expect(
      after.segments[after.trackedSegmentIndex].episodeIndex,
      0,
      reason: 'a loaded chapter is a legitimate flip target',
    );
    expect(after.itemPosition, 1);
  });
}