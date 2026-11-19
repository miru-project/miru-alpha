import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/watch_result.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/provider/watch/chapter_watch_cache.dart';

/// Tests for [WatchChapterCache] — the shared LRU the watch session and the
/// reader windows use so a tracked-chapter flip never re-resolves a chapter.
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

  WatchResult makeResult(String url) {
    final watch = pb_extension.ExtensionBangumiWatch()
      ..type = 'hls'
      ..url = url;
    return WatchResult(data: watch);
  }

  setUp(() {
    WatchChapterCache.clear();
    WatchChapterCache.resolver = ({
      required watchUrl,
      required detailUrl,
      required meta,
      mirrorUrl,
    }) async => makeResult(watchUrl);
  });

  tearDown(WatchChapterCache.clear);

  test(
    'resolving the same url twice hits the cache, one network call',
    () async {
      var calls = 0;
      WatchChapterCache.resolver =
          ({
            required watchUrl,
            required detailUrl,
            required meta,
            mirrorUrl,
          }) async {
            calls++;
            return makeResult(watchUrl);
          };
      final first = await WatchChapterCache.resolve(
        watchUrl: 'chapter-1',
        detailUrl: 'detail',
        meta: meta,
      );
      final second = await WatchChapterCache.resolve(
        watchUrl: 'chapter-1',
        detailUrl: 'detail',
        meta: meta,
      );
      expect(calls, 1);
      expect(identical(first, second), isTrue);
    },
  );

  test('mirror url participates in the key', () async {
    var calls = 0;
    WatchChapterCache.resolver =
        ({
          required watchUrl,
          required detailUrl,
          required meta,
          mirrorUrl,
        }) async {
          calls++;
          return makeResult('$watchUrl|${mirrorUrl ?? ''}');
        };
    await WatchChapterCache.resolve(
      watchUrl: 'chapter-1',
      detailUrl: 'detail',
      meta: meta,
    );
    await WatchChapterCache.resolve(
      watchUrl: 'chapter-1',
      detailUrl: 'detail',
      meta: meta,
      mirrorUrl: 'mirror-a',
    );
    await WatchChapterCache.resolve(
      watchUrl: 'chapter-1',
      detailUrl: 'detail',
      meta: meta,
      mirrorUrl: 'mirror-b',
    );
    expect(calls, 3);
  });

  test('overflowing the cap evicts the least recently used entry', () async {
    for (var i = 0; i < WatchChapterCache.maxEntries; i++) {
      await WatchChapterCache.resolve(
        watchUrl: 'chapter-$i',
        detailUrl: 'detail',
        meta: meta,
      );
    }
    // chapter-0 is now the oldest; touch it so it is fresh.
    await WatchChapterCache.resolve(
      watchUrl: 'chapter-0',
      detailUrl: 'detail',
      meta: meta,
    );
    await WatchChapterCache.resolve(
      watchUrl: 'chapter-6',
      detailUrl: 'detail',
      meta: meta,
    );
    expect(
      WatchChapterCache.peek('chapter-1', mirrorUrl: null),
      isNull,
      reason: 'chapter-1 became the oldest and must be evicted',
    );
    expect(
      WatchChapterCache.peek('chapter-0', mirrorUrl: null),
      isNotNull,
      reason: 'chapter-0 was touched before the overflow, must survive',
    );
  });

  test('session load reuses the cached chapter instead of reloading', () async {
    var calls = 0;
    WatchChapterCache.resolver =
        ({
          required watchUrl,
          required detailUrl,
          required meta,
          mirrorUrl,
        }) async {
          calls++;
          return makeResult(watchUrl);
        };
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final states = <Object>[];
    container.listen(watchSessionProvider, (_, next) => states.add(next));
    // The infinite window resolving the anchor's sibling fills the cache
    // through the shared helper, exactly like the reader does.
    await WatchChapterCache.resolve(
      watchUrl: 'chapter-2',
      detailUrl: 'detail',
      meta: meta,
    );
    await container
        .read(watchSessionProvider.notifier)
        .load(watchUrl: 'chapter-2', detailUrl: 'detail', meta: meta);
    expect(calls, 1, reason: 'session consumed the window-resolved chapter');
    expect(states.whereType<AsyncLoading>(), isEmpty);
    expect(container.read(watchSessionProvider), isA<AsyncData<WatchResult>>());
  });
}
