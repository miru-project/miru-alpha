import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/watch_result.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/provider/watch/chapter_watch_cache.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/src/item_positions_listener.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/src/item_positions_notifier.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// Provider-level tests for the chapter cache through the manga window and
/// the watch session — the regression guard for the "whole app is blocked by
/// loading when the infinite scroll flips the tracked chapter" bug.
///
/// The window resolves adjacent chapters through the shared LRU, and the
/// watch session consumes the same LRU for reloads. If an infinite-scroll
/// flip ever re-resolves a chapter through the network, these tests fail.
void main() {
  final meta = ExtensionMeta(
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

  List<ExtensionEpisode> episodes() => [
    for (var i = 1; i <= 3; i++)
      ExtensionEpisode(name: 'Chapter $i', url: 'chapter-$i'),
  ];

  List<String> pagesOf(String chapter, int count) => [
    for (var i = 0; i < count; i++) '$chapter-p$i',
  ];

  WatchResult makeResult(String url) {
    final chapter = RegExp(r'chapter-(\d+)').firstMatch(url)?.group(0) ?? url;
    final watch = pb_extension.ExtensionMangaWatch()
      ..urls.addAll(pagesOf(chapter, 2));
    return WatchResult(data: watch);
  }

  ItemPosition at(int index) =>
      ItemPosition(index: index, itemLeadingEdge: 0, itemTrailingEdge: 1);

  void setPositions(ProviderContainer container, List<ItemPosition> positions) {
    final listener = container
        .read(mangaReaderProvider.notifier)
        .itemPositionsListener;
    (listener as ItemPositionsNotifier).itemPositions.value = positions;
  }

  late int resolveCalls;
  late List<String> resolvedUrls;
  late Future<WatchResult> Function({
    required String watchUrl,
    required String detailUrl,
    required ExtensionMeta meta,
    String? mirrorUrl,
  })
  previousResolver;

  setUp(() {
    MiruSettings.seedDefaultsForTest();
    MiruSettings.setSettingSync(SettingKey.mangaReadingMode, 'webToon');
    WatchChapterCache.clear();
    resolveCalls = 0;
    resolvedUrls = [];
    previousResolver = WatchChapterCache.resolver;
    WatchChapterCache.resolver =
        ({
          required watchUrl,
          required detailUrl,
          required meta,
          mirrorUrl,
        }) async {
          resolveCalls++;
          resolvedUrls.add(watchUrl);
          return makeResult(watchUrl);
        };
  });

  tearDown(() {
    WatchChapterCache.clear();
    WatchChapterCache.resolver = previousResolver;
  });

  ProviderContainer container() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('anchor open warms both neighbours through the shared cache', () async {
    final c = container();
    c.listen(mangaReaderProvider, (_, _) {});
    // The shell resolves the anchor watch before opening the reader — the
    // production flow that populates the shared cache.
    await WatchChapterCache.resolve(
      watchUrl: 'chapter-2',
      detailUrl: 'detail',
      meta: meta,
    );
    expect(resolveCalls, 1);
    final notifier = c.read(mangaReaderProvider.notifier);
    notifier.open(
      groupIndex: 0,
      episodeIndex: 1,
      totalPage: 2,
      episodes: episodes(),
      urls: pagesOf('chapter-2', 2),
      meta: meta,
      detailUrl: 'detail',
      chapterName: 'Chapter 2',
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(resolveCalls, 3, reason: 'both neighbours are warmed on open');

    // The shell reloads the watch for the anchor URL when the episode
    // opens; the cache holds it, so no network call happens again.
    final cached = WatchChapterCache.peek('chapter-2');
    expect(cached, isNotNull);
    await c
        .read(watchSessionProvider.notifier)
        .load(watchUrl: 'chapter-2', detailUrl: 'detail', meta: meta);
    expect(resolveCalls, 3);
    expect(
      identical(
        (c.read(watchSessionProvider) as AsyncData<WatchResult>).value,
        cached,
      ),
      isTrue,
      reason: 'the watch session must hand back the exact cached result',
    );
  });

  test(
    'infinite-scroll flip is answered from the cache, not the network',
    () async {
      final c = container();
      c.listen(mangaReaderProvider, (_, _) {});
      await WatchChapterCache.resolve(
        watchUrl: 'chapter-1',
        detailUrl: 'detail',
        meta: meta,
      );
      final notifier = c.read(mangaReaderProvider.notifier);
      notifier.open(
        groupIndex: 0,
        episodeIndex: 0,
        totalPage: 2,
        episodes: episodes(),
        urls: pagesOf('chapter-1', 2),
        meta: meta,
        detailUrl: 'detail',
        chapterName: 'Chapter 1',
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      setPositions(c, [at(2)]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      setPositions(c, [at(4)]);

      // One resolve per unique chapter, none repeated for chapter-2.
      expect(c.read(mangaReaderProvider).trackedSegmentIndex, 1);
      expect(
        resolvedUrls.where((u) => u == 'chapter-2').length,
        1,
        reason: 'chapter-2 is resolved once: by the anchor prefetch',
      );

      // What the shell does on every episode switch: reload watch for the
      // selected episode's URL. Chapter-2 is already in the cache from the
      // prefetch — zero extra network calls and the exact cached result.
      final cached = WatchChapterCache.peek('chapter-2');
      expect(cached, isNotNull);
      await c
          .read(watchSessionProvider.notifier)
          .load(watchUrl: 'chapter-2', detailUrl: 'detail', meta: meta);
      expect(
        resolvedUrls.where((u) => u == 'chapter-2').length,
        1,
        reason: 'flip must not re-resolve the chapter',
      );
      expect(
        identical(
          (c.read(watchSessionProvider) as AsyncData<WatchResult>).value,
          cached,
        ),
        isTrue,
      );
    },
  );

  test(
    'flipping to an unprefetched neighbour still resolves, one call',
    () async {
      final c = container();
      c.listen(mangaReaderProvider, (_, _) {});
      // Nothing was prefetched for chapter-3 — the load falls back to the
      // network path exactly once and lands as data.
      await c
          .read(watchSessionProvider.notifier)
          .load(watchUrl: 'chapter-3', detailUrl: 'detail', meta: meta);
      expect(resolveCalls, 1);
      expect(c.read(watchSessionProvider), isA<AsyncData<WatchResult>>());
    },
  );

  test('mirror change forces a re-resolve even for a cached chapter', () async {
    final c = container();
    c.listen(watchSessionProvider, (_, _) {});
    await c
        .read(watchSessionProvider.notifier)
        .load(watchUrl: 'chapter-3', detailUrl: 'detail', meta: meta);
    await c
        .read(watchSessionProvider.notifier)
        .load(
          watchUrl: 'chapter-3',
          detailUrl: 'detail',
          meta: meta,
          mirrorUrl: 'mirror-a',
        );
    expect(resolveCalls, 2);
  });
}
