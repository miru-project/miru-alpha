import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/src/item_positions_listener.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/src/item_positions_notifier.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// A resume page may only be adopted while the reader still sits where the
/// session started.
///
/// Device log of the failure:
///
///   JUMP flip seg=2 page=0 prevEp=27 newEp=28    <- reader crosses BACK into
///                                                   ep28 at its FIRST page
///   SHELL effect ep=28 total=18 resume=18        <- history: last read p18
///   JUMP open ep=28 resume=18 currentKey=0:28:18 <- dedupe re-adopts!
///   SLV jumpTo index=56 (manga_viewport:297)     <- pendingJumpSlot fired
///   POS flat=56 offset=0.0 delta=8426.1          <- teleported to the END
///
/// The reader crossed into ep28 at page 0 and was thrown to page 17; the
/// forward scrolling at that end then cascaded appends of chapters 29-33.
/// The position was the reader's — live attribution from the flip — so the
/// disagreeing history page was stale, not a missed adopt.
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

  void openAt(
    MangaReader reader, {
    required int episode,
    required int totalPage,
    int? resume,
  }) {
    final pages = List.generate(totalPage, (i) => 'p$i');
    reader.debugChapterFetcher = (url) async => pages;
    reader.open(
      groupIndex: 0,
      episodeIndex: episode,
      totalPage: totalPage,
      resumePage: resume,
      episodes: episodes(5),
      urls: pages,
      meta: meta,
      detailUrl: 'https://e.com/d',
    );
  }

  test(
    'a flip makes the live position win over a disagreeing resume',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(mangaReaderProvider, (_, _) {});
      final reader = container.read(mangaReaderProvider.notifier);
      openAt(reader, episode: 1, totalPage: 2);
      expect(container.read(mangaReaderProvider).itemPosition, 0);

      // The reader crosses into the previous chapter and back, landing at its
      // first page (the device sequence). The fetch must complete first: a flip
      // into a still-loading chapter is refused by design.
      await reader.debugEnsureAdjacent(-1);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(mangaReaderProvider).segments.first.items,
        isNotNull,
        reason: 'the previous chapter finished loading',
      );
      reader.debugFlipTo(0, 0);
      expect(
        container.read(mangaReaderProvider).segments[0].episodeIndex,
        0,
        reason: 'the flip landed on the previous chapter',
      );

      // The shell's open effect re-runs for the flipped chapter, carrying its
      // stale history page. The reader is live — no adopt, no jump.
      openAt(reader, episode: 0, totalPage: 2, resume: 17);

      final state = container.read(mangaReaderProvider);
      expect(
        state.itemPosition,
        0,
        reason: 'the reader stays on the page it crossed into',
      );
      // The fresh-open publish from openAt(episode:0) is still pending (its
      // start slot 0); the stale resume must not have overwritten it.
      expect(
        reader.pendingJumpSlot.value,
        0,
        reason: 'the stale resume must not publish a jump',
      );
    },
  );

  test(
    'a late-arriving resume is still adopted while the reader is parked',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(mangaReaderProvider, (_, _) {});
      final reader = container.read(mangaReaderProvider.notifier);
      openAt(reader, episode: 1, totalPage: 3);

      // No movement since open: the session sits exactly where it started.
      openAt(reader, episode: 1, totalPage: 3, resume: 2);

      final state = container.read(mangaReaderProvider);
      expect(state.itemPosition, 2, reason: 'the late resume page is adopted');
      expect(
        reader.pendingJumpSlot.value,
        2,
        reason: 'the adopted page is published for the canvas',
      );
    },
  );

  test('a reader that has scrolled is not yanked by a stale resume', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(mangaReaderProvider, (_, _) {});
    final reader = container.read(mangaReaderProvider.notifier);
    openAt(reader, episode: 1, totalPage: 3);

    // The reader scrolled to page 1 (live attribution away from the start).
    poke(container, 1);
    expect(container.read(mangaReaderProvider).itemPosition, 1);

    openAt(reader, episode: 1, totalPage: 3, resume: 2);

    final state = container.read(mangaReaderProvider);
    expect(
      state.itemPosition,
      1,
      reason: 'the position is the reader\'s, not history\'s',
    );
    // A fresh open publishes its start slot (0) so a mounted canvas
    // re-anchors; it is not a stale-resume jump.
    expect(reader.pendingJumpSlot.value, 0);
  });
}
