import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/src/item_positions_listener.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/src/item_positions_notifier.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// Attribution must not follow a backward blip.
///
/// The positions stream re-reports slots the reader already scrolled past when
/// an image above the viewport re-lays out the list. The hysteresis guard holds
/// the *position*, but the page number was still written from the stale slot —
/// the "indicator snaps back when I scroll up" report.
///
/// These tests drive the provider through its real `itemPositionsListener`, the
/// same stream the widget's list feeds.
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

  ItemPosition at(int index) =>
      ItemPosition(index: index, itemLeadingEdge: 0, itemTrailingEdge: 1);

  /// Opens a three-chapter window and returns the container.
  ProviderContainer openWindow() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Hold a subscription: the auto-dispose provider is torn down between
    // reads otherwise, wiping the window.
    container.listen(mangaReaderProvider, (_, _) {});
    final reader = container.read(mangaReaderProvider.notifier);
    reader.debugChapterFetcher = (url) async => const ['p0', 'p1'];
    reader.open(
      groupIndex: 0,
      episodeIndex: 0,
      totalPage: 2,
      episodes: [
        for (var e = 0; e < 3; e++)
          ExtensionEpisode(name: 'C$e', url: 'https://e.com/c$e'),
      ],
      urls: const ['p0', 'p1'],
      meta: meta,
      detailUrl: 'https://e.com/d',
    );
    return container;
  }

  void poke(ProviderContainer container, int flat) {
    final listener = container
        .read(mangaReaderProvider.notifier)
        .itemPositionsListener;
    (listener as ItemPositionsNotifier).itemPositions.value = [at(flat)];
  }

  test('a backward blip is suppressed until it persists', () {
    final container = openWindow();
    // With one chapter the flat list is [seriesStart, p0, p1, seriesEnd].
    final reader = container.read(mangaReaderProvider.notifier);
    debugPrint(
      'SLOTS ${reader.currentSlots().map((s) => s.kind.name).toList()} '
      'tracked=${container.read(mangaReaderProvider).trackedSegmentIndex}',
    );

    // Establish forward attribution first: page 1.
    poke(container, 2);
    expect(container.read(mangaReaderProvider).itemPosition, 1);

    // Three backward reports (one short of the 4-frame hysteresis): the page
    // number must not move.
    for (var frame = 0; frame < 3; frame++) {
      poke(container, 1);
    }
    expect(
      container.read(mangaReaderProvider).itemPosition,
      1,
      reason: 'a backward blip inside the hysteresis window must not attribute',
    );

    // The fourth consecutive report crosses the threshold.
    poke(container, 1);
    expect(
      container.read(mangaReaderProvider).itemPosition,
      0,
      reason: 'a persisted backward move is attributed after the hysteresis',
    );
  });

  test('a forward report is attributed immediately', () {
    final container = openWindow();

    poke(container, 1);
    expect(
      container.read(mangaReaderProvider).itemPosition,
      0,
      reason: 'forward attribution is never gated',
    );
  });
}
