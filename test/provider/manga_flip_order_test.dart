import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/src/item_positions_listener.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/src/item_positions_notifier.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/infinite_window.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// A chapter flip must publish the new state BEFORE it notifies listeners.
///
/// The history write bakes the episode identity out of the episode notifier's
/// `_capturedState`, which `selectEpisode` refreshes. If the listener fires
/// before `state` has the new chapter, a save armed from the outgoing state
/// writes the new chapter's progress onto the PREVIOUS chapter's history row.
///
/// Field symptom: reading chapter 231 to page 18 and scrolling into 232 saved
/// the progress as chapter 230.
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

  test('a flip publishes the new chapter before listeners fire', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
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

    // Load the neighbours so a flip is possible.
    reader.onWebtoonOverscroll(1);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    reader.onWebtoonOverscroll(1);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final slots = reader.currentSlots();
    debugPrint(
      'ORDR slots=${slots.map((s) => '${s.kind.name}:${s.segmentIndex}.${s.pageIndex}').toList()}',
    );

    // Observe what the provider state says at the moment the listener fires.
    int? trackedAtCallback;
    reader.debugOnTrackedEpisodeChanged = (group, episode) {
      final state = container.read(mangaReaderProvider);
      trackedAtCallback =
          state.segments[state.trackedSegmentIndex].episodeIndex;
    };

    final listener = reader.itemPositionsListener as ItemPositionsNotifier;
    // Cross forward into the next chapter.
    final lastPage = slots.lastIndexWhere((s) => s.kind == SlotKind.page);
    listener.itemPositions.value = [at(lastPage)];
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final tracked = container.read(mangaReaderProvider).trackedSegmentIndex;
    final expected = container
        .read(mangaReaderProvider)
        .segments[tracked]
        .episodeIndex;
    debugPrint(
      'ORDR tracked=$tracked ep=$expected atCallback=$trackedAtCallback',
    );

    expect(
      trackedAtCallback,
      expected,
      reason: 'the callback must observe the NEW chapter, not the old one',
    );
  });
}
