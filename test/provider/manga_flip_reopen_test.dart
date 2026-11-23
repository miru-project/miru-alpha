import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// A chain flip must not re-open the session.
///
/// Reproduced from device logs. Crossing a junction upward:
///
///   POS flat=3 stable=5 dir=reverse
///   JUMP commitSegments atHead delta=2 tracked=1 segs=[12,13] -> [11,12,13]
///   window_track FLIP seg=1 page=1 tracked=2
///   POS flat=5 stable=0 offset=-617.1        <- canvas remounted, offset reset
///   window_track FLIP seg=2 page=1 tracked=1 <- flips back
///   JUMP open group=0 ep=13 segments=[]      <- session wiped
///
/// `_flipTrackedChapter` fires `onTrackedEpisodeChanged`, the episode provider
/// moves `selectedEpisodeIndex` to the new chapter, the shell rebuilds with a
/// NEW `episodeIndex`, and its open effect re-runs. By then the provider has
/// already moved too, so both guards must hold for the new chapter:
///
///   - `tracksEpisode(new)` reads `state.segments`
///   - `isOpenFor(group, new)` reads `_openKey`
///
/// If either is false the effect calls `open()`, which wipes the session,
/// remounts the canvas at slot 0 and throws the reader back.
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

  Future<ProviderContainer> openAt({
    int episode = 2,
    List<String> pages = const ['p0', 'p1'],
  }) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(mangaReaderProvider, (_, _) {});
    final reader = container.read(mangaReaderProvider.notifier);
    reader.debugChapterFetcher = (url) async => pages;
    reader.open(
      groupIndex: 0,
      episodeIndex: episode,
      totalPage: pages.length,
      episodes: [
        for (var e = 0; e < 4; e++)
          ExtensionEpisode(name: 'C$e', url: 'https://e.com/c$e'),
      ],
      urls: pages,
      meta: meta,
      detailUrl: 'https://e.com/d',
    );
    await Future<void>.delayed(Duration.zero);
    return container;
  }

  test('upward prepend then flip keeps the new chapter recognisable', () async {
    final container = await openAt();
    final reader = container.read(mangaReaderProvider.notifier);

    expect(reader.isOpenFor(0, 2), isTrue, reason: 'episode 2 is open');

    // Upward: chapter 1 is prepended ahead of 2.
    await reader.debugEnsureAdjacent(-1);
    var state = container.read(mangaReaderProvider);
    expect(
      state.segments.map((s) => s.episodeIndex).toList(),
      containsAllInOrder(<int>[1, 2]),
      reason: 'episode 1 landed ahead of episode 2',
    );

    // The position report lands in the prepended chapter -> flip to seg 0.
    reader.debugFlipTo(0, 0);
    state = container.read(mangaReaderProvider);

    final trackedEpisode =
        state.segments[state.trackedSegmentIndex].episodeIndex;
    debugPrint(
      'OPEN after flip tracked=$trackedEpisode '
      'isOpenFor(new)=${reader.isOpenFor(0, trackedEpisode)} '
      'tracksEpisode(new)=${reader.tracksEpisode(trackedEpisode)}',
    );

    expect(trackedEpisode, 1);
    expect(
      reader.tracksEpisode(trackedEpisode),
      isTrue,
      reason: 'segments know the tracked chapter',
    );
    expect(
      reader.isOpenFor(0, trackedEpisode),
      isTrue,
      reason:
          '_openKey must describe the new chapter too, or the shell re-opens',
    );
  });

  test('isOpenFor rejects a chapter that is not open', () async {
    final container = await openAt(episode: 0, pages: const ['p0']);
    final reader = container.read(mangaReaderProvider.notifier);

    expect(reader.isOpenFor(0, 0), isTrue);
    expect(reader.isOpenFor(0, 3), isFalse);
    expect(reader.isOpenFor(1, 0), isFalse);
  });
}
