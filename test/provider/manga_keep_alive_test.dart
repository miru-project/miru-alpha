import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// The reader notifier must survive a moment with no listeners.
///
/// The reader subtree is only built inside `watchSessionProvider`'s `AsyncData`
/// branch, so every chapter transition — which re-keys the watch session and
/// passes through `AsyncLoading` — leaves `mangaReaderProvider` with no
/// listeners for a frame. While it was auto-dispose, that frame destroyed the
/// notifier: `_openKey` reset to null, `segments` emptied, and the shell's next
/// `open()` correctly saw a brand-new session and threw the reader back to slot
/// 0.
///
/// Device log of the failure:
///
///   JUMP flip seg=1 page=3 prevSeg=0 prevEp=5 newEp=6 forward=true
///   PROVIDER dispose #1
///   PROVIDER create #1
///   SHELL effect group=0 ep=6 total=18 tracked=0 segs=[] openKey=null
///   SLV initState initialScrollIndex=0        <- back to the top
///
/// No guard inside `open()` can fix this, because by then the session really is
/// gone. The fix is structural: keep the provider alive.
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

  void openAt(ProviderContainer container, MangaReader reader, int episode) {
    reader.debugChapterFetcher = (url) async => const ['p0', 'p1'];
    reader.open(
      groupIndex: 0,
      episodeIndex: episode,
      totalPage: 2,
      episodes: episodes(8),
      urls: const ['p0', 'p1'],
      meta: meta,
      detailUrl: 'https://e.com/d',
    );
  }

  test('a session survives the provider losing all listeners', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final reader = container.read(mangaReaderProvider.notifier);
    final subscription = container.listen(mangaReaderProvider, (_, _) {});
    openAt(container, reader, 6);

    expect(
      container.read(mangaReaderProvider).segments.map((s) => s.episodeIndex),
      <int>[6],
      reason: 'the chapter is loaded',
    );

    // Drop the last listener, as the reader subtree does while the watch
    // session is loading. An auto-dispose provider is destroyed here.
    subscription.close();
    await Future<void>.delayed(Duration.zero);

    // The session is still there afterwards: nothing re-created the notifier,
    // so the window the reader scrolled to was never thrown away.
    final after = container.read(mangaReaderProvider);
    expect(after.segments.map((s) => s.episodeIndex), <int>[
      6,
    ], reason: 'the window survived the listener gap');
    expect(after.totalPage, 2);
    expect(after.itemPosition, 0);
  });

  test('re-opening after a listener gap is a no-op, not a reset', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final reader = container.read(mangaReaderProvider.notifier);
    container.listen(mangaReaderProvider, (_, _) {});
    openAt(container, reader, 6);

    // The shell re-runs its open effect after the transition, exactly as the
    // log shows. Re-opening the same chapter must not wipe the window.
    openAt(container, reader, 6);

    final state = container.read(mangaReaderProvider);
    expect(state.segments.map((s) => s.episodeIndex), <int>[6]);
    expect(state.itemPosition, 0, reason: 'the position was not thrown away');
  });

  test('endSession wipes the window so a re-entry reloads fresh', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(mangaReaderProvider, (_, _) {});
    final reader = container.read(mangaReaderProvider.notifier);
    openAt(container, reader, 6);
    expect(
      container.read(mangaReaderProvider).segments.map((s) => s.episodeIndex),
      <int>[6],
    );

    // Leaving the watch route ends the session.
    reader.endSession();

    final wiped = container.read(mangaReaderProvider);
    expect(wiped.segments, isEmpty, reason: 'the window is gone');
    expect(wiped.totalPage, 0);
    expect(wiped.itemPosition, 0);
    expect(reader.debugOpenKey, isNull, reason: 'the session identity is gone');
    expect(reader.pendingJumpSlot.value, isNull);

    // Re-entry on a different chapter takes the fresh path: a single-chapter
    // anchor for the entered episode, not a reuse of the old window.
    openAt(container, reader, 3);
    final state = container.read(mangaReaderProvider);
    expect(state.segments.map((s) => s.episodeIndex), <int>[3]);
    expect(state.trackedSegmentIndex, 0);
    expect(state.totalPage, 2);
  });

  test('the provider is not auto-dispose', () {
    // Guards the fix structurally: an auto-dispose provider is torn down the
    // moment the reader subtree stops listening, which is what caused the
    // mid-scroll reset. `isAutoDispose` is a Riverpod 3 provider field.
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(mangaReaderProvider, (_, _) {});
    expect(
      mangaReaderProvider.isAutoDispose,
      isFalse,
      reason: 'the reader notifier must outlive its listeners',
    );
  });
}
