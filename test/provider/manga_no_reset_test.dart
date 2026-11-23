import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// Re-opening a chapter the window already holds must not reset the session.
///
/// Device log, the flicker after a chapter transition:
///
///   window_track FLIP seg=1 page=3 tracked=0     <- reader moved to ep 17
///   JUMP open group=0 ep=17 currentKey=null segments=[]
///   SLV initState initialScrollIndex=0           <- canvas remounted
///   POS flat=0 stable=0 offset=0.0               <- back to the top
///
/// `_openKey` is the wrong thing to guard on: it names the chapter the reader
/// OPENED on, so after a chain flip it describes the outgoing chapter and the
/// re-open slips past. The window's own segments are the truth about what is
/// mounted — if they already hold the chapter, a reset discards the position
/// the reader is looking at.
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

  Future<ProviderContainer> openAt(int episode) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(mangaReaderProvider, (_, _) {});
    final reader = container.read(mangaReaderProvider.notifier);
    reader.debugChapterFetcher = (url) async => const ['p0', 'p1'];
    reader.open(
      groupIndex: 0,
      episodeIndex: episode,
      totalPage: 2,
      episodes: [
        for (var e = 0; e < 6; e++)
          ExtensionEpisode(name: 'C$e', url: 'https://e.com/c$e'),
      ],
      urls: const ['p0', 'p1'],
      meta: meta,
      detailUrl: 'https://e.com/d',
    );
    await Future<void>.delayed(Duration.zero);
    return container;
  }

  test('re-opening a chapter already in the window keeps the segments', () async {
    final container = await openAt(2);
    final reader = container.read(mangaReaderProvider.notifier);

    // Pull episode 1 in ahead of 2, as an upward crossing does.
    await reader.debugEnsureAdjacent(-1);
    final before = container.read(mangaReaderProvider);
    expect(
      before.segments.map((s) => s.episodeIndex).toList(),
      containsAllInOrder(<int>[1, 2]),
    );

    // The reader flips into the prepended chapter.
    reader.debugFlipTo(0, 0);
    final afterFlip = container.read(mangaReaderProvider);
    final tracked =
        afterFlip.segments[afterFlip.trackedSegmentIndex].episodeIndex;

    // The shell now re-runs its open effect for the tracked chapter. Both
    // chapters it might name are already mounted, so neither may reset.
    for (final ep in <int>[tracked, 1, 2]) {
      reader.open(
        groupIndex: 0,
        episodeIndex: ep,
        totalPage: 18,
        episodes: [
          for (var e = 0; e < 6; e++)
            ExtensionEpisode(name: 'C$e', url: 'https://e.com/c$e'),
        ],
        urls: const ['p0', 'p1'],
        meta: meta,
        detailUrl: 'https://e.com/d',
      );
      final state = container.read(mangaReaderProvider);
      expect(
        state.segments.map((s) => s.episodeIndex).toList(),
        containsAllInOrder(<int>[1, 2]),
        reason: 're-opening ep $ep must not wipe the window',
      );
      expect(
        state.trackedSegmentIndex,
        afterFlip.trackedSegmentIndex,
        reason: 're-opening ep $ep must not move the attribution anchor',
      );
    }
  });

  test('opening a chapter outside the window still resets', () async {
    final container = await openAt(2);
    final reader = container.read(mangaReaderProvider.notifier);

    reader.open(
      groupIndex: 0,
      episodeIndex: 4,
      totalPage: 2,
      episodes: [
        for (var e = 0; e < 6; e++)
          ExtensionEpisode(name: 'C$e', url: 'https://e.com/c$e'),
      ],
      urls: const ['p0', 'p1'],
      meta: meta,
      detailUrl: 'https://e.com/d',
    );

    final state = container.read(mangaReaderProvider);
    expect(
      state.segments.map((s) => s.episodeIndex).toList(),
      <int>[4],
      reason: 'a genuinely different chapter starts a fresh session',
    );
  });
}