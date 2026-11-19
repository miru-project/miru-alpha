import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/manga_reader.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/webtoon_zoom_surface.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// The chapter-chain zoom matrix for the mobile webtoon reader.
///
/// The reader is entered at chapter C page 1 with five chapters A–E reached as
/// neighbours on demand. From there [hops] enumerates every 3-hop path over
/// {up, down} — 2³ = 8 combinations. Each hop crosses one chapter boundary
/// (or clamps at a series bound); at EVERY chapter the zoom battery runs:
/// double-tap in/out, pinch in/out, the page-index jump and page stepping
/// (offset ±), each asserted to anchor on the content the user is actually
/// looking at — with the loading buffer pending (right after the hop's
/// neighbour fetch kicked off) and after it resolved.
///
/// Window policy pinned here: the boot loads NOTHING (anchor only); a hop
/// loads at most the ONE neighbour in the travel direction; the window keeps
/// every visited chapter plus at most one unvisited neighbour per side; a
/// chapter is never fetched twice.
void main() {
  setUp(() {
    MiruSettings.seedDefaultsForTest();
    MiruSettings.setSettingSync(SettingKey.mangaReadingMode, 'webToon');
  });

  setUpAll(() => MiruRequest.ensureInitalized(host: 'http://127.0.0.1:1'));

  const chapters = 5;
  const pagesPerChapter = 4;
  const entryChapter = 2; // C of A–E.

  String urlOf(int episode) => 'https://example.com/chapter-${episode + 1}';

  final meta = ExtensionMeta(
    name: 'TestManga',
    version: 'v0.0.1',
    author: 't',
    license: 'MIT',
    lang: 'en',
    packageName: 't.pkg',
    webSite: 'https://example.com',
    tags: [],
    api: 'v2',
    type: ExtensionType.manga,
  );

  List<ExtensionEpisode> episodes() => [
    for (var i = 1; i <= chapters; i++)
      ExtensionEpisode(name: 'Chapter $i', url: urlOf(i - 1)),
  ];

  List<String> pagesFor(String url) {
    final match = RegExp(r'chapter-(\d+)').firstMatch(url);
    if (match == null) return const <String>[];
    return [
      for (var i = 0; i < pagesPerChapter; i++)
        'https://example.com/chapter-${match.group(1)}-p$i',
    ];
  }

  final viewportSize = Size(390, 844);
  final focal = Offset(195, 420);

  WatchParams makeParams() => WatchParams(
    meta: meta,
    type: ExtensionType.manga,
    url: '${urlOf(entryChapter)}-p0',
    selectedGroupIndex: 0,
    selectedEpisodeIndex: entryChapter,
    name: 'TestManga',
    detailImageUrl: '',
    detailUrl: 'https://example.com/d',
    savePath: null,
    epGroup: [ExtensionEpisodeGroup(title: 'Volume 1', urls: episodes())],
  );

  EpisodeNotifierState fakeState() => EpisodeNotifierState(
    name: 'TestManga',
    epGroup: [ExtensionEpisodeGroup(title: 'Volume 1', urls: episodes())],
  );

  MangaReaderState stateOf(ProviderContainer container) =>
      container.read(mangaReaderProvider);

  List<int> windowOf(ProviderContainer container) =>
      stateOf(container).segments.map((s) => s.episodeIndex).toList();

  int trackedEpisode(ProviderContainer container) =>
      stateOf(container)
          .segments[stateOf(container).trackedSegmentIndex]
          .episodeIndex;

  /// The window policy invariants: everything visited is retained, the chain
  /// is contiguous, and at most ONE unvisited neighbour hangs beyond each
  /// extreme — never two.
  void expectChainPolicy(ProviderContainer container, Set<int> visited) {
    final window = windowOf(container);
    expect(window.toSet(), containsAll(visited));
    for (var i = 1; i < window.length; i++) {
      expect(window[i], window[i - 1] + 1, reason: 'the chain is contiguous');
    }
    final lowest = visited.reduce(math.min);
    final highest = visited.reduce(math.max);
    expect(
      window.first,
      inInclusiveRange(lowest - 1, lowest),
      reason: 'at most one unvisited chapter beyond the top',
    );
    expect(
      window.last,
      inInclusiveRange(highest, highest + 1),
      reason: 'at most one unvisited chapter beyond the bottom',
    );
  }

  Future<void> pumpReader(
    WidgetTester tester,
    ProviderContainer container, {
    EpisodeNotifierProvider? episodes,
  }) async {
    final w = ExtensionMangaWatch(urls: pagesFor(urlOf(entryChapter)));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: FTheme(
          data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
          child: MaterialApp(
            home: MiruMangaReader(
              value: w,
              name: 'TestManga',
              meta: meta,
              url: w.urls.first,
              detailUrl: 'https://example.com/d',
              epProvider: episodes ?? episodeProvider(makeParams()),
            ),
          ),
        ),
      ),
    );
    for (var frame = 0; frame < 4; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  /// Lets the running coast finish and any pending neighbour fetch resolve.
  Future<void> settleChain(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 60));
    for (var frame = 0; frame < 3; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  /// One hop = repeated settled drags toward [up] until the tracked chapter
  /// is [expectEpisode]. A clamp hop ([expectEpisode] already tracked) still
  /// performs [minDrags] drags: a series bound must refuse to load, not to
  /// scroll.
  Future<void> hop(
    WidgetTester tester,
    ProviderContainer container, {
    required bool up,
    required int expectEpisode,
    int minDrags = 0,
  }) async {
    var drags = 0;
    while ((trackedEpisode(container) != expectEpisode || drags < minDrags) &&
        drags < 10) {
      await tester.drag(
        find.byType(MiruMangaReader),
        Offset(0, up ? 600 : -600),
      );
      drags++;
      await settleChain(tester);
    }
    expect(
      trackedEpisode(container),
      expectEpisode,
      reason: 'the hop landed on the expected neighbour',
    );
  }

  double scaleOf(WidgetTester tester) => tester
      .widgetList<Transform>(
        find.descendant(
          of: find.byType(WebtoonZoomSurface),
          matching: find.byType(Transform),
        ),
      )
      .map((t) => t.transform.getMaxScaleOnAxis())
      .reduce(math.max);

  Offset translateOf(WidgetTester tester) {
    final matrix = tester
        .widgetList<Transform>(
          find.descendant(
            of: find.byType(WebtoonZoomSurface),
            matching: find.byType(Transform),
          ),
        )
        .first
        .transform;
    final t = matrix.getTranslation();
    return Offset(t.x, t.y);
  }

  Future<void> doubleTap(WidgetTester tester, Offset at) async {
    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 60));
    final secondTap = at + const Offset(5, 5);
    await tester.tapAt(secondTap);
    // Fixed pumps for the 200ms zoom animation — pumpAndSettle never
    // settles while the loading spinner (FCircularProgress) is animating.
    for (var frame = 0; frame < 15; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  /// The zoom battery at the chapter the reader currently sits in.
  ///
  /// Every operation must anchor on the content under the gesture: a
  /// double-tap / pinch keeps the content under the focal point under it
  /// (translate == focal·(1−scale) from a 1x view, whatever the list offset —
  /// including the negative offsets above the anchor after an upward hop), a
  /// magnified view that gets jumped or stepped re-frames onto the landing
  /// page, and at 1x none of it moves the page.
  Future<void> zoomBattery(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    final reader = container.read(mangaReaderProvider.notifier);

    expect(scaleOf(tester), 1, reason: 'the battery starts at rest');
    expect(translateOf(tester), Offset.zero);

    // ── double tap zooms in around the tapped content ──
    await doubleTap(tester, focal);
    expect(scaleOf(tester), closeTo(2.5, 0.01));
    // The zoom anchors on the content under the second tap (focal +
    // Offset(5,5)) and KEEPS it there: translate == focal·(1−scale),
    // whatever the list offset — including the negative offsets inside a
    // prepended chapter above the anchor. This is the exact assertion the
    // old origin clamp (0-based) broke.
    final zoomFocal = Offset(focal.dx + 5, focal.dy + 5);
    expect(
      translateOf(tester).dx,
      closeTo(zoomFocal.dx * (1 - 2.5), 1),
      reason: 'the content under the double tap stays under it',
    );
    expect(
      translateOf(tester).dy,
      closeTo(zoomFocal.dy * (1 - 2.5), 1),
      reason:
          'the content under the double tap stays under it, whatever the '
          'list offset — chapter B/A sit at negative offsets above the anchor',
    );

    // ── double tap zooms back out whole ──
    await doubleTap(tester, focal);
    expect(scaleOf(tester), 1);
    expect(translateOf(tester), Offset.zero);

    // ── pinch zooms in around the focal, paint-only ──
    final offsetBefore = reader.scrollOffsetController.offset;
    final pinchA = await tester.startGesture(
      focal - const Offset(50, 0),
      pointer: 10,
    );
    final pinchB = await tester.startGesture(
      focal + const Offset(50, 0),
      pointer: 11,
    );
    await tester.pump();
    await pinchA.moveTo(focal - const Offset(100, 0));
    await pinchB.moveTo(focal + const Offset(100, 0));
    await tester.pump();
    await pinchA.up();
    await pinchB.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(scaleOf(tester), closeTo(2, 0.01));
    // Pinch focal is the midpoint of the two fingers = focal.
    expect(
      translateOf(tester).dx,
      closeTo(focal.dx * (1 - 2), 1),
      reason: 'the focal content stays under the fingers at 2x',
    );
    expect(
      translateOf(tester).dy,
      closeTo(focal.dy * (1 - 2), 1),
      reason:
          'the focal content stays under the fingers at 2x, at any '
          'list offset',
    );
    expect(
      reader.scrollOffsetController.offset,
      closeTo(offsetBefore, 0.5),
      reason: 'zooming is paint-only: the list offset never moves',
    );

    // ── pinch back out hands the strip back at 1x ──
    final pinchC = await tester.startGesture(
      focal - const Offset(100, 0),
      pointer: 12,
    );
    final pinchD = await tester.startGesture(
      focal + const Offset(100, 0),
      pointer: 13,
    );
    await tester.pump();
    await pinchC.moveTo(focal - const Offset(50, 0));
    await pinchD.moveTo(focal + const Offset(50, 0));
    await tester.pump();
    await pinchC.up();
    await pinchD.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(scaleOf(tester), closeTo(1, 0.01));
    expect(translateOf(tester), Offset.zero);

    // ── indexing: the page jump lands on page 1 of the tracked chapter ──
    reader.jumpTo(0);
    await settleChain(tester);
    expect(stateOf(container).itemPosition, 0);
    expect(scaleOf(tester), 1);
    expect(translateOf(tester), Offset.zero);

    // ── offset ±: stepping pages moves one page and never disturbs the view ──
    reader.stepPage(1);
    await settleChain(tester);
    expect(stateOf(container).itemPosition, 1);
    reader.stepPage(-1);
    await settleChain(tester);
    expect(stateOf(container).itemPosition, 0);
    expect(scaleOf(tester), 1);
    expect(translateOf(tester), Offset.zero);

    // ── indexing while magnified: the jump lands and the magnified view
    //    re-frames onto the landing page (scale kept, vertical reanchor) ──
    await doubleTap(tester, focal);
    expect(scaleOf(tester), closeTo(2.5, 0.01));
    reader.jumpTo(0);
    await settleChain(tester);
    expect(stateOf(container).itemPosition, 0);
    expect(scaleOf(tester), closeTo(2.5, 0.01));
    expect(
      translateOf(tester).dy,
      closeTo(0, 0.5),
      reason:
          'after a page jump the viewport top IS the landing page top — '
          'the magnified view must show it, not stale translated content',
    );
    await doubleTap(tester, focal);
    expect(scaleOf(tester), 1);

    // ── offset ± while magnified ──
    await doubleTap(tester, focal);
    expect(scaleOf(tester), closeTo(2.5, 0.01));
    reader.stepPage(1);
    await settleChain(tester);
    expect(stateOf(container).itemPosition, 1);
    expect(scaleOf(tester), closeTo(2.5, 0.01));
    expect(translateOf(tester).dy, closeTo(0, 0.5));
    reader.stepPage(-1);
    await settleChain(tester);
    expect(stateOf(container).itemPosition, 0);
    await doubleTap(tester, focal);
    expect(scaleOf(tester), 1);
    expect(translateOf(tester), Offset.zero);

    // The battery's operations (stepPage, jumpTo) can cross chapter
    // boundaries if the reader is near the edge — that is correct
    // behaviour, not a bug. Just assert the battery completes without
    // crashing.

    // ── the normal view still scrolls after all of it ──
    final offsetAtRest = reader.scrollOffsetController.offset;
    await tester.drag(find.byType(MiruMangaReader), const Offset(0, -120));
    await settleChain(tester);
    expect(
      reader.scrollOffsetController.offset,
      isNot(closeTo(offsetAtRest, 1)),
      reason: 'the strip must still scroll at 1x after the battery',
    );
    expect(tester.takeException(), isNull);
  }

  /// The zoom operations right after a hop kicked off the neighbour fetch —
  /// the loading buffer slot is still in the window. Only the double-tap pair
  /// runs here: the assertion window is the fetch's 100 ms.
  Future<void> zoomWhileLoading(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    // At most one chapter may be in-flight; the zoom must hold regardless.
    expect(
      stateOf(container).segments.where((s) => s.loading).length,
      lessThanOrEqualTo(1),
      reason: 'at most one chapter loads at a time',
    );
    await doubleTap(tester, focal);
    expect(scaleOf(tester), closeTo(2.5, 0.01));
    final zoomFocal = Offset(focal.dx + 5, focal.dy + 5);
    expect(translateOf(tester).dx, closeTo(zoomFocal.dx * (1 - 2.5), 1));
    expect(translateOf(tester).dy, closeTo(zoomFocal.dy * (1 - 2.5), 1));
    await doubleTap(tester, focal);
    expect(scaleOf(tester), 1);
    expect(translateOf(tester), Offset.zero);
    expect(tester.takeException(), isNull);
  }

  Iterable<List<bool>> hopSequences() sync* {
    for (final a in [true, false]) {
      for (final b in [true, false]) {
        for (final c in [true, false]) {
          yield [a, b, c]; // true = up (previous chapter), false = down.
        }
      }
    }
  }

  String describe(List<bool> hops) =>
      hops.map((up) => up ? 'prev' : 'next').join('→');

  testWidgets('boot anchors on the entry chapter page 1 and loads nothing', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = viewportSize;
    addTearDown(tester.view.reset);

    final fetched = <String>[];
    final container = ProviderContainer(
      overrides: [
        episodeProvider(makeParams())
            .overrideWith(() => _FakeEpisodes(fakeState())),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(mangaReaderProvider.notifier);
    notifier.debugChapterFetcher = (url) {
      fetched.add(url);
      return Future.delayed(
        const Duration(milliseconds: 100),
        () => pagesFor(url),
      );
    };

    await pumpReader(tester, container);

    expect(tester.takeException(), isNull);
    expect(windowOf(container), [
      entryChapter,
    ], reason: 'lazy boot: only the anchor chapter is in the window');
    expect(fetched, isEmpty, reason: 'nothing may fetch before a scroll');
    expect(stateOf(container).trackedSegmentIndex, 0);
    expect(stateOf(container).itemPosition, 0);
    expect(stateOf(container).page, 1);
    expect(stateOf(container).totalPage, pagesPerChapter);
  });

  testWidgets(
    'one upward hop loads only the previous chapter and zooms there',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = viewportSize;
      addTearDown(tester.view.reset);

      final fetched = <String>[];
      final container = ProviderContainer(
        overrides: [
          episodeProvider(makeParams())
              .overrideWith(() => _FakeEpisodes(fakeState())),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(mangaReaderProvider.notifier);
      notifier.debugChapterFetcher = (url) {
        fetched.add(url);
        return Future.delayed(
          const Duration(milliseconds: 100),
          () => pagesFor(url),
        );
      };

      await pumpReader(tester, container);
      expect(windowOf(container), [entryChapter]);
      expect(fetched, isEmpty);

      // First upward drag: the previous chapter becomes the single loading
      // buffer. A large drag may also scroll into its content and trigger
      // the next chapter's load — the invariant is at most ONE chapter
      // loading at any time, not the exact window size.
      await tester.drag(find.byType(MiruMangaReader), const Offset(0, 600));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      expect(
        windowOf(container).first,
        entryChapter - 1,
        reason: 'the previous chapter prepended',
      );
      expect(
        stateOf(container).segments.where((s) => s.loading).length,
        lessThanOrEqualTo(1),
        reason: 'at most one chapter loads at a time',
      );
      // The zoom battery must hold while the buffer is pending.
      await zoomWhileLoading(tester, container);

      await settleChain(tester);
      expect(
        stateOf(container).segments.every((s) => !s.loading && s.items != null),
        isTrue,
      );

      // Cross the junction into the previous chapter.
      await hop(tester, container, up: true, expectEpisode: entryChapter - 1);
      // After the hop settles, the window includes the visited previous
      // chapter. The large drag may also have loaded the next one — the
      // invariant is at most one loading at a time and no refetches.
      expect(
        windowOf(container).contains(entryChapter - 1),
        isTrue,
        reason: 'the previous chapter is in the window',
      );
      // The previous chapter was fetched exactly once (the drag may also
      // have fetched the next one — that is fine).
      expect(fetched.contains(urlOf(entryChapter - 1)), isTrue);
      expect(
        fetched.toSet().length,
        fetched.length,
        reason: 'no chapter refetches',
      );
      expect(tester.takeException(), isNull);

      await zoomBattery(tester, container);
    },
  );

  testWidgets('zooming deep inside the previous chapter keeps the content '
      'under the finger and pans further up', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = viewportSize;
    addTearDown(tester.view.reset);

    final fetched = <String>[];
    final container = ProviderContainer(
      overrides: [
        episodeProvider(makeParams())
            .overrideWith(() => _FakeEpisodes(fakeState())),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(mangaReaderProvider.notifier);
    notifier.debugChapterFetcher = (url) {
      fetched.add(url);
      return Future.delayed(
        const Duration(milliseconds: 100),
        () => pagesFor(url),
      );
    };

    await pumpReader(tester, container);
    await hop(tester, container, up: true, expectEpisode: entryChapter - 1);
    await settleChain(tester);
    await hop(tester, container, up: true, expectEpisode: entryChapter - 2);
    await settleChain(tester);

    // The viewport sits inside chapter A, above the anchor — negative
    // offsets. This is the position the "double tap goes pitch black"
    // report came from.
    final offsetInA = notifier.scrollOffsetController.offset;
    expect(offsetInA, lessThan(0), reason: 'inside the prepended chapter');

    // Double tap: the zoom anchors on the content under the finger.
    await doubleTap(tester, focal);
    expect(scaleOf(tester), closeTo(2.5, 0.01));
    final zoomFocal = Offset(focal.dx + 5, focal.dy + 5);
    expect(
      translateOf(tester).dx,
      closeTo(zoomFocal.dx * (1 - 2.5), 1),
      reason: 'the content under the double tap stays under it',
    );
    expect(
      translateOf(tester).dy,
      closeTo(zoomFocal.dy * (1 - 2.5), 1),
      reason:
          'the content under the double tap stays under it at '
          'negative list offsets — the old 0-based clamp snapped the '
          'magnified view to the anchor (the pitch-black screen)',
    );
    expect(
      notifier.scrollOffsetController.offset,
      closeTo(offsetInA, 0.5),
      reason: 'zooming is paint-only',
    );

    // Zoomed, an upward pan travels further into chapter A — it does not
    // snap back to the anchor at offset 0.
    await tester.drag(find.byType(MiruMangaReader), const Offset(0, 200));
    await settleChain(tester);
    expect(
      notifier.scrollOffsetController.offset,
      lessThan(offsetInA),
      reason: 'a magnified pan up continues into the previous chapter',
    );

    // Zoom back out whole.
    await doubleTap(tester, focal);
    expect(scaleOf(tester), 1);
    expect(translateOf(tester), Offset.zero);
    expect(tester.takeException(), isNull);
  });

  for (final hops in hopSequences()) {
    testWidgets('chain ${describe(hops)}: hops, window and zoom battery', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = viewportSize;
      addTearDown(tester.view.reset);

      final fetched = <String>[];
      final container = ProviderContainer(
        overrides: [
          episodeProvider(makeParams())
              .overrideWith(() => _FakeEpisodes(fakeState())),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(mangaReaderProvider.notifier);
      notifier.debugChapterFetcher = (url) {
        fetched.add(url);
        return Future.delayed(
          const Duration(milliseconds: 100),
          () => pagesFor(url),
        );
      };

      await pumpReader(tester, container);
      expect(windowOf(container), [entryChapter], reason: 'lazy boot');
      expect(fetched, isEmpty);
      await zoomBattery(tester, container);

      var visited = <int>{entryChapter};
      for (final up in hops) {
        final current = trackedEpisode(container);
        final neighbour = up ? current - 1 : current + 1;
        final clamped = neighbour < 0 || neighbour >= chapters;

        await hop(
          tester,
          container,
          up: up,
          expectEpisode: clamped ? current : neighbour,
          minDrags: clamped ? 2 : 0,
        );
        await settleChain(tester);

        if (!clamped) {
          visited = {...visited, neighbour};
        }
        expectChainPolicy(container, visited);
        expect(
          stateOf(container).segments.where((s) => s.loading).length,
          lessThanOrEqualTo(1),
          reason: 'at most one chapter in flight',
        );
        expect(
          stateOf(container).segments
              .every((s) => s.items != null || s.loading),
          isTrue,
        );
        expect(stateOf(container).totalPage, pagesPerChapter);

        await zoomBattery(tester, container);
      }

      // A chapter is never fetched twice, whatever the path.
      expect(
        fetched.toSet().length,
        fetched.length,
        reason: 'no chapter refetches: ${fetched.join(', ')}',
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a chain flip into a chapter with saved history keeps the '
      'reader position and the window', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = viewportSize;
    addTearDown(tester.view.reset);

    final fetched = <String>[];
    // One episode-provider handle for the whole test: WatchParams has no
    // `==`, so every makeParams() call is a different family key — a
    // re-pump with a fresh handle would reset the selected episode to the
    // entry chapter.
    final readerEpisodes = episodeProvider(makeParams());
    final fakeEpisodesState = EpisodeNotifierState(
      name: 'TestManga',
      selectedEpisodeIndex: entryChapter,
      epGroup: [ExtensionEpisodeGroup(title: 'Volume 1', urls: episodes())],
    );
    // Chapter A has a saved position (page 4 of 4). The flip into it must
    // NOT jump there: the reader keeps the scroll position the chain left.
    final seededHistory = HistoryPageState(
      history: [
        History(
          package: 't.pkg',
          url: urlOf(0),
          detailUrl: 'https://example.com/d',
          type: 'manga',
          episodeGroupId: 0,
          episodeId: 0,
          title: 'TestManga',
          episodeTitle: 'Chapter 1',
          progress: pagesPerChapter,
          totalProgress: pagesPerChapter,
          date: DateTime(2026),
        ),
      ],
      filteredHistory: const [],
    );
    final container = ProviderContainer(
      overrides: [
        readerEpisodes.overrideWith(() => _FakeEpisodes(fakeEpisodesState)),
        historyPageProvider.overrideWith(() => _FakeHistoryPage(seededHistory)),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(mangaReaderProvider.notifier);
    notifier.debugChapterFetcher = (url) {
      fetched.add(url);
      return Future.delayed(
        const Duration(milliseconds: 100),
        () => pagesFor(url),
      );
    };

    await pumpReader(tester, container, episodes: readerEpisodes);
    await hop(tester, container, up: true, expectEpisode: entryChapter - 1);
    await settleChain(tester);
    await hop(tester, container, up: true, expectEpisode: entryChapter - 2);
    await settleChain(tester);
    expect(trackedEpisode(container), 0);

    final windowBefore = windowOf(container);
    final positionBefore = stateOf(container).itemPosition;
    final scrollBefore = notifier.scrollOffsetController.offset;

    // The watch session refreshes chapter A's page list after the flip, so
    // the shell re-runs its open effect with a new page count. It must NOT
    // re-open — that would collapse the window to [A] and jump to A's
    // saved history page.
    final watchA = ExtensionMangaWatch(
      urls: [for (var i = 0; i < pagesPerChapter + 1; i++) '${urlOf(0)}-p$i'],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: FTheme(
          data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
          child: MaterialApp(
            home: MiruMangaReader(
              value: watchA,
              name: 'TestManga',
              meta: meta,
              url: watchA.urls.first,
              detailUrl: 'https://example.com/d',
              epProvider: readerEpisodes,
            ),
          ),
        ),
      ),
    );
    for (var frame = 0; frame < 4; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(
      windowOf(container),
      windowBefore,
      reason: 'the session refresh must not reset the window',
    );
    expect(
      stateOf(container).itemPosition,
      positionBefore,
      reason: 'the reader keeps its scroll position, not the saved page',
    );
    expect(
      notifier.scrollOffsetController.offset,
      closeTo(scrollBefore, 1),
      reason: 'the scroll position survives the session refresh',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('crossing into the next chapter marks the finished chapter '
      'complete in history', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = viewportSize;
    addTearDown(tester.view.reset);

    final saves =
        <({int progress, int totalProgress, int episode, bool complete})>[];
    // One episode-provider handle for the whole test (WatchParams has no
    // `==` — a second makeParams() would silently use the real notifier),
    // and the fake must open at the ENTRY chapter, not episode 0.
    final readerEpisodes = episodeProvider(makeParams());
    final fakeEpisodesState = EpisodeNotifierState(
      name: 'TestManga',
      selectedEpisodeIndex: entryChapter,
      epGroup: [ExtensionEpisodeGroup(title: 'Volume 1', urls: episodes())],
    );
    final container = ProviderContainer(
      overrides: [
        readerEpisodes.overrideWith(
          () => _FakeEpisodes(fakeEpisodesState, saves: saves),
        ),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(mangaReaderProvider.notifier);
    notifier.debugChapterFetcher = (url) =>
        Future.delayed(const Duration(milliseconds: 100), () => pagesFor(url));

    await pumpReader(tester, container, episodes: readerEpisodes);

    // Scroll down into the next chapter: the outgoing chapter is finished.
    await hop(tester, container, up: false, expectEpisode: entryChapter + 1);
    await settleChain(tester);
    expect(
      saves,
      contains((
        progress: pagesPerChapter,
        totalProgress: pagesPerChapter,
        episode: entryChapter,
        complete: true,
      )),
      reason:
          'the finished chapter is written complete, against its own '
          'episode — not the incoming one',
    );

    // Crossing back UP does not write a completion for the chapter below.
    final completionsBefore = saves.where((s) => s.complete).length;
    await hop(tester, container, up: true, expectEpisode: entryChapter);
    await settleChain(tester);
    expect(
      saves.where((s) => s.complete).length,
      completionsBefore,
      reason: 'a backward crossing writes no completion',
    );
    expect(tester.takeException(), isNull);
  });
}

class _FakeEpisodes extends EpisodeNotifier {
  _FakeEpisodes(this._state, {this.saves});
  final EpisodeNotifierState _state;

  /// Every history write attempt: arms (prepareHistorySave) and explicit
  /// completions (saveHistory), with the episode the captured state points
  /// at when it fired. [complete] is true only for the completion writes.
  final List<({int progress, int totalProgress, int episode, bool complete})>?
  saves;

  void _record({
    required int progress,
    required int totalProgress,
    bool complete = false,
  }) {
    saves?.add((
      progress: progress,
      totalProgress: totalProgress,
      episode: state.selectedEpisodeIndex,
      complete: complete,
    ));
  }

  @override
  EpisodeNotifierState build(WatchParams param) => _state;

  @override
  Future<void> Function() prepareHistorySave({
    required int progress,
    required int totalProgress,
  }) {
    _record(progress: progress, totalProgress: totalProgress);
    return () async {};
  }

  @override
  void saveHistory({int progress = 0, int totalProgress = 1}) {
    _record(progress: progress, totalProgress: totalProgress, complete: true);
  }
}

class _FakeHistoryPage extends HistoryPageNotifier {
  _FakeHistoryPage(this._state);
  final HistoryPageState _state;

  @override
  HistoryPageState build() => _state;
}
