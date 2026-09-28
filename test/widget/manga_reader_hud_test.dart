import 'dart:math' as math;

import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/manga_reader.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/manag_image.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/manga_viewport.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_bottom_bar.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_button.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_segmented.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_status_pill.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_top_bar.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/webtoon_zoom_surface.dart';

import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEpisodes extends EpisodeNotifier {
  _FakeEpisodes(this._state);
  final EpisodeNotifierState _state;

  @override
  EpisodeNotifierState build(WatchParams param) => _state;

  @override
  Future<void> Function() prepareHistorySave({
    required int progress,
    required int totalProgress,
  }) => () async {};
}

final _meta = ExtensionMeta(
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

/// Twelve synthetic `example.com` pages — no real site is contacted.
ExtensionMangaWatch _watch({int pages = 12}) => ExtensionMangaWatch(
  urls: [for (var i = 1; i <= pages; i++) 'https://example.com/p$i.png'],
);

EpisodeNotifierState _epState({int episodes = 5}) => EpisodeNotifierState(
  name: 'TestManga',
  epGroup: [
    ExtensionEpisodeGroup(
      title: 'Volume 1',
      urls: [
        for (var i = 1; i <= episodes; i++)
          ExtensionEpisode(name: 'Chapter $i', url: 'https://example.com/c$i'),
      ],
    ),
  ],
);

WatchParams _params() => WatchParams(
  meta: _meta,
  type: ExtensionType.manga,
  url: 'https://example.com/c1',
  selectedGroupIndex: 0,
  selectedEpisodeIndex: 0,
  name: 'TestManga',
  detailImageUrl: '',
  detailUrl: 'https://example.com/d',
  savePath: null,
  epGroup: _epState().epGroup,
);

/// The page canvas keeps an image loading (and therefore animating) forever in
/// tests, so the reader is advanced with a fixed number of frames instead of
/// [WidgetTester.pumpAndSettle].
Future<void> _pumpReader(WidgetTester tester) async {
  for (var frame = 0; frame < 6; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Advances past the reader's 100ms page transition so no timer outlives the
/// test's widget tree.
Future<void> _settleTransition(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
}

ProviderContainer _container({EpisodeNotifierState? epState}) {
  final container = ProviderContainer(
    overrides: [
      episodeProvider(
        _params(),
      ).overrideWith(() => _FakeEpisodes(epState ?? _epState())),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Widget _wrap(ProviderContainer container, Widget child, {Size? size}) {
  final surface = size ?? const Size(430, 900);
  return UncontrolledProviderScope(
    container: container,
    child: FTheme(
      data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
      child: MediaQuery(
        data: MediaQueryData(size: surface),
        child: MaterialApp(home: child),
      ),
    ),
  );
}

/// Opacity of the HUD layer — the [AnimatedOpacity] that wraps [ReaderTopBar].
double _hudOpacity(WidgetTester tester) {
  return tester
      .widget<AnimatedOpacity>(
        find.ancestor(
          of: find.byType(ReaderTopBar),
          matching: find.byType(AnimatedOpacity),
        ),
      )
      .opacity;
}

/// The 0..1 fraction the HUD's page scrubber is currently displaying.
///
/// FORUI declares `value` on the private lifted-control classes, so the
/// property is only reachable dynamically. That is exactly the thing under test:
/// a *managed* control only reads its `initial` value once, so the scrubber
/// would stay at the page the panel was first built with.
double _scrubberFraction(WidgetTester tester) {
  final control = tester.widget<FSlider>(find.byType(FSlider)).control;
  return (control as dynamic).value.max as double;
}

/// Vertical slide a layer is offset by while hidden, as a fraction of its own
/// height: negative for the top bar, positive for the control panel.
double _hiddenSlide(WidgetTester tester, Finder bar) {
  return tester
      .widget<AnimatedSlide>(
        find.ancestor(of: bar, matching: find.byType(AnimatedSlide)),
      )
      .offset
      .dy;
}

void main() {
  setUp(MiruSettings.seedDefaultsForTest);
  // ImageWidget routes every URL through MiruRequest's proxy prefix; point it
  // at a non-routable placeholder so no request is ever attempted.
  setUpAll(() => MiruRequest.ensureInitalized(host: 'http://127.0.0.1:1'));

  testWidgets('reader shell shows both HUD halves over the canvas', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    // Resting state: the page alone, with the status pill instead of the HUD.
    expect(_hudOpacity(tester), 0);
    expect(find.byType(ReaderStatusPill), findsOneWidget);
    expect(find.text('1 / 12'), findsOneWidget);
    expect(find.text('8%'), findsOneWidget);

    // A centre tap animates the overlay in.
    container.read(mangaReaderProvider(0, 5, _watch()).notifier).toggleHud();
    await _pumpReader(tester);

    expect(_hudOpacity(tester), 1);
    expect(find.byType(ReaderTopBar), findsOneWidget);
    expect(find.byType(ReaderBottomBar), findsOneWidget);
  });

  testWidgets('hiding the HUD swaps the panel for the status pill', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    final reader = container.read(mangaReaderProvider(0, 5, _watch()).notifier);
    reader.setHudVisible(true);
    await _pumpReader(tester);
    expect(_hudOpacity(tester), 1);

    reader.setHudVisible(false);
    await _pumpReader(tester);

    // The pill is shown the whole time; only the HUD fades, and the faded HUD
    // stays mounted but inert so the transition can animate.
    expect(find.text('1 / 12'), findsOneWidget);
    expect(find.text('8%'), findsOneWidget);
    expect(find.byType(ReaderTopBar), findsOneWidget);
    expect(_hudOpacity(tester), 0);
  });

  testWidgets('the status pill is content-sized, not stretched by its surface', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    // The pill is positioned with left/right 0, so anything in its chain that
    // passes those constraints through (a clip, a blur) hands the badge a tight
    // full-width constraint and the pill spans the screen.
    final canvas = tester.getRect(find.byType(MiruMangaViewPort));
    // The pill's own box is the full width (it is positioned left/right 0); what
    // has to be content-sized is the frosted surface inside it.
    final surface = tester.getRect(
      find.descendant(
        of: find.byType(ReaderStatusPill),
        matching: find.byType(FBadge),
      ),
    );
    expect(surface.width, lessThanOrEqualTo(canvas.width - 32));
    // ...and it stays centred rather than pinned to the leading edge.
    expect(surface.center.dx, closeTo(canvas.center.dx, 1));
  });

  testWidgets('the page scrubber follows the page it is reporting', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    final reader = container.read(mangaReaderProvider(0, 5, _watch()).notifier)
      ..setHudVisible(true);
    await _pumpReader(tester);
    expect(_scrubberFraction(tester), 0);

    // Twelve pages, so the last one is fraction 1 and the middle is not.
    reader.setPageNumber(11);
    await _pumpReader(tester);
    expect(_scrubberFraction(tester), closeTo(1, 0.01));
    expect(find.text('12 / 12'), findsOneWidget);

    reader.setPageNumber(5);
    await _pumpReader(tester);
    expect(_scrubberFraction(tester), closeTo(5 / 11, 0.01));
    expect(find.text('6 / 12'), findsOneWidget);
  });

  testWidgets('the scrubber badge only shows while it is being dragged', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    container
        .read(mangaReaderProvider(0, 5, _watch()).notifier)
        .setHudVisible(true);
    await _pumpReader(tester);

    // At rest the numbers at either end of the track say enough.
    expect(find.textContaining('reader.manga.page'), findsNothing);

    // `tapAndSlideThumb` only slides from the thumb, which at page one sits on
    // the left edge of the track.
    final track = tester.getRect(find.byType(FSlider));
    final gesture = await tester.startGesture(
      Offset(track.left, track.center.dy),
    );
    // Two moves: the first resolves the drag gesture, the second carries the
    // change the scrubber reacts to.
    await gesture.moveBy(const Offset(20, 0));
    await gesture.moveBy(const Offset(60, 0));
    await _pumpReader(tester);
    expect(find.textContaining('reader.manga.page'), findsOneWidget);

    await gesture.up();
    await _pumpReader(tester);
    // The badge fades out rather than vanishing, so the switcher keeps it
    // mounted for its duration; past that it is gone.
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('reader.manga.page'), findsNothing);
  });

  testWidgets('the scrubber announces a page number, not a percentage', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    final reader = container.read(mangaReaderProvider(0, 5, _watch()).notifier)
      ..setHudVisible(true);
    await _pumpReader(tester);

    // FORUI's default announces the raw fraction as a percentage, which for a
    // page scrubber is meaningless. The slider's own node is the one flagged
    // `slider: true` inside it, so collect what the tree says rather than
    // guessing which node the finder lands on.
    List<String> announced(WidgetTester tester) {
      final values = <String>[];
      final nodes = find.descendant(
        of: find.byType(FSlider),
        matching: find.byType(Semantics),
      );
      for (var i = 0; i < nodes.evaluate().length; i++) {
        final value = tester.getSemantics(nodes.at(i)).value;
        if (value.isNotEmpty) values.add(value);
      }
      return values;
    }

    expect(announced(tester), isNotEmpty);
    expect(announced(tester).join(), isNot(contains('%')));
    expect(announced(tester), contains('1'));

    reader.setPageNumber(6);
    await _pumpReader(tester);
    expect(announced(tester), contains('7'));
  });

  testWidgets('each HUD half slides in from its own edge', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    // Hidden: the top bar waits above the screen, the control panel below it, so
    // each arrives from the edge it belongs to instead of both rising.
    expect(_hiddenSlide(tester, find.byType(ReaderTopBar)), lessThan(0));
    expect(_hiddenSlide(tester, find.byType(ReaderBottomBar)), greaterThan(0));

    container
        .read(mangaReaderProvider(0, 5, _watch()).notifier)
        .setHudVisible(true);
    await _pumpReader(tester);

    expect(_hiddenSlide(tester, find.byType(ReaderTopBar)), 0);
    expect(_hiddenSlide(tester, find.byType(ReaderBottomBar)), 0);
  });

  testWidgets('bottom bar pages between chapters and reports the last one', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    container
        .read(mangaReaderProvider(0, 5, _watch()).notifier)
        .setHudVisible(true);
    await _pumpReader(tester);

    // Both HUD halves name the chapter, so scope the assertion to the panel.
    Finder panelChapter(String name) => find.descendant(
      of: find.byType(ReaderBottomBar),
      matching: find.text(name),
    );

    expect(panelChapter('Chapter 1'), findsOneWidget);
    await tester.tap(find.text('reader.manga.next'));
    await _pumpReader(tester);
    expect(panelChapter('Chapter 2'), findsOneWidget);
    // The header subtitle follows the selection too.
    expect(
      find.descendant(
        of: find.byType(ReaderTopBar),
        matching: find.text('Chapter 2'),
      ),
      findsOneWidget,
    );
    await _settleTransition(tester);
  });

  testWidgets(
    'a centre tap toggles the HUD regardless of the tap-zone switch',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _container();
      await tester.pumpWidget(
        _wrap(
          container,
          MiruMangaReader(
            value: _watch(),
            name: 'TestManga',
            meta: _meta,
            url: 'https://example.com/c1',
            epProvider: episodeProvider(_params()),
          ),
        ),
      );
      await _pumpReader(tester);

      // Turn edge paging off: the edges must stop working, but the centre must
      // not, or the overlay could never be summoned again.
      final reader = container.read(
        mangaReaderProvider(0, 5, _watch()).notifier,
      );
      reader.setTapToTurnPage(false);
      await _pumpReader(tester);

      final centre = tester.getCenter(find.byType(MiruMangaViewPort));
      await tester.tapAt(centre);
      await _pumpReader(tester);
      expect(
        container.read(mangaReaderProvider(0, 5, _watch())).hudVisible,
        isTrue,
      );

      await tester.tapAt(centre);
      await _pumpReader(tester);
      expect(
        container.read(mangaReaderProvider(0, 5, _watch())).hudVisible,
        isFalse,
      );
    },
  );

  testWidgets('edge taps page the chapter and never move the page', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    final provider = mangaReaderProvider(0, 5, _watch());
    final viewport = find.byType(MiruMangaViewPort);
    final box = tester.getRect(viewport);

    // Right edge advances the page, left edge goes back.
    // Set explicitly: reader settings persist, so an earlier test that turned
    // tap zones off would otherwise leak into this one.
    container.read(provider.notifier).setTapToTurnPage(true);
    await _pumpReader(tester);

    await tester.tapAt(Offset(box.right - 8, box.center.dy));
    await _pumpReader(tester);
    expect(container.read(provider).itemPosition, 1);
    expect(container.read(provider).hudVisible, isFalse);

    await tester.tapAt(Offset(box.left + 8, box.center.dy));
    await _pumpReader(tester);
    expect(container.read(provider).itemPosition, 0);
    expect(container.read(provider).hudVisible, isFalse);
  });

  testWidgets('scrolling the pages dismisses the overlay', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    final provider = mangaReaderProvider(0, 5, _watch());
    final reader = container.read(provider.notifier);
    reader
      ..setHudVisible(true)
      ..changeReadMode(MangaReadMode.webToon);
    await _pumpReader(tester);
    expect(container.read(provider).hudVisible, isTrue);

    // Reading is an implicit dismissal: the moment the pages move, the overlay
    // is in the way.
    await tester.drag(find.byType(MiruMangaViewPort), const Offset(0, -200));
    await _pumpReader(tester);
    expect(container.read(provider).hudVisible, isFalse);

    // ... and it does not come back on its own.
    await tester.drag(find.byType(MiruMangaViewPort), const Offset(0, -200));
    await _pumpReader(tester);
    expect(container.read(provider).hudVisible, isFalse);
  });

  testWidgets('panning a zoomed page dismisses the overlay', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    final provider = mangaReaderProvider(0, 5, _watch());
    container.read(provider.notifier)
      ..setHudVisible(true)
      ..changeReadMode(MangaReadMode.webToon);
    await _pumpReader(tester);
    expect(container.read(provider).hudVisible, isTrue);

    // Magnify first: a magnified view pins its scrollable, so the pan is raw
    // pointer tracking and never reaches the drag notification the un-zoomed
    // dismissal listens for.
    final zoomA = await tester.startGesture(const Offset(150, 400), pointer: 1);
    final zoomB = await tester.startGesture(const Offset(250, 400), pointer: 2);
    await _pumpReader(tester);
    await zoomA.moveTo(const Offset(50, 400));
    await _pumpReader(tester);
    await zoomA.up();
    await zoomB.up();
    await _pumpReader(tester);

    container.read(provider.notifier).setHudVisible(true);
    await _pumpReader(tester);
    expect(container.read(provider).hudVisible, isTrue);

    final pan = await tester.startGesture(const Offset(200, 400));
    await pan.moveBy(const Offset(0, -20));
    await pan.moveBy(const Offset(30, -60));
    await _pumpReader(tester);
    expect(
      container.read(provider).hudVisible,
      isFalse,
      reason: 'moving through a zoomed page must dismiss the overlay',
    );
    await pan.up();
    await _pumpReader(tester);
  });

  testWidgets('a paged swipe pages without dismissing the overlay', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    final provider = mangaReaderProvider(0, 5, _watch());
    container.read(provider.notifier).setHudVisible(true);
    await _pumpReader(tester);

    // A horizontal drag is page navigation, and the HUD is the reader's tool
    // for that, so it must survive the swipe. Two moves: the first resolves the
    // gesture, the second carries the page change.
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MiruMangaViewPort)),
    );
    await gesture.moveBy(const Offset(-120, 0));
    await gesture.moveBy(const Offset(-260, 0));
    await gesture.up();
    await _pumpReader(tester);
    await _settleTransition(tester);

    expect(container.read(provider).itemPosition, 1);
    expect(container.read(provider).hudVisible, isTrue);
  });

  testWidgets('the brightness button toggles auto and opens no menu', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    final provider = mangaReaderProvider(0, 5, _watch());
    container.read(provider.notifier)
      ..setHudVisible(true)
      ..setBrightnessMode(MangaBrightnessMode.manual);
    await _pumpReader(tester);

    // The strip is intrinsic-width, so the button belongs on the trailing edge.
    final panel = tester.getRect(find.byType(ReaderBottomBar));
    // Row 1's Prev / selector / Next are `ReaderButton`s too, and the brightness
    // action is the last one in the panel.
    final actions = find.descendant(
      of: find.byType(ReaderBottomBar),
      matching: find.byType(ReaderButton),
    );
    final button = tester.getRect(actions.last);
    expect(button.right, closeTo(panel.right - 16, 0.5));

    // ...and the mode strip gets all the space the button does not need, so its
    // labels are never squeezed. A `Spacer` would be a second flex child and
    // would take half the row, ellipsising the labels to "L …". (In the test the
    // labels are raw i18n keys, so they ellipsise either way; what is asserted
    // is that none of the row is wasted between the two children.)
    final strip = tester.getRect(
      find.descendant(
        of: find.byType(ReaderBottomBar),
        matching: find.byType(ReaderSegmented<MangaReadMode>),
      ),
    );
    expect(strip.right, closeTo(button.left, 0.5));

    await tester.tapAt(button.center);
    await _pumpReader(tester);

    expect(container.read(provider).brightnessMode, MangaBrightnessMode.auto);
    // A toggle, not a menu: the settings sheet is the top bar's job.
    expect(find.text('reader.manga.settings'), findsNothing);
    expect(
      MiruSettings.getSettingSync<MangaBrightnessMode>(
        SettingKey.mangaBrightnessMode,
      ),
      MangaBrightnessMode.auto,
    );

    await tester.tapAt(button.center);
    await _pumpReader(tester);
    expect(container.read(provider).brightnessMode, MangaBrightnessMode.manual);
    // FORUI's tappable runs a press animation on a timer.
    await _settleTransition(tester);
  });

  testWidgets('the webtoon is full-bleed and gaps the pages instead', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    container
        .read(mangaReaderProvider(0, 5, _watch()).notifier)
        .changeReadMode(MangaReadMode.webToon);
    await _pumpReader(tester);

    // No padding around the list: the first page starts on the screen edge and
    // the last one runs to the bottom edge. Padding the list is what left a
    // blank band the artwork could never cover.
    final canvas = tester.getRect(find.byType(MiruMangaViewPort));
    final list = tester.getRect(find.byType(WebtoonZoomSurface));
    expect(list.top, closeTo(canvas.top, 0.5));
    expect(list.bottom, closeTo(canvas.bottom, 0.5));
    expect(list.left, closeTo(canvas.left, 0.5));
    expect(list.right, closeTo(canvas.right, 0.5));

    // The gap is now *between* pages: each page but the last carries a
    // trailing pad, instead of the whole list being inset.
    final gap = container.read(mangaReaderProvider(0, 5, _watch())).pageGap;
    expect(
      tester
          .widget<Padding>(
            find
                .descendant(
                  of: find.byType(WebtoonZoomSurface),
                  matching: find.byType(Padding),
                )
                .first,
          )
          .padding,
      EdgeInsets.only(bottom: gap.toDouble()),
    );
  });

  testWidgets('a paged page magnifies, pans, and still turns at 1x', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    final provider = mangaReaderProvider(0, 5, _watch());
    final canvas = find.byType(MiruMangaViewPort);
    // The page itself brings identity transforms along, so the zoom is the
    // largest scale anywhere under the canvas.
    double scaleOf() => find
        .descendant(of: canvas, matching: find.byType(Transform))
        .evaluate()
        .map(
          (element) =>
              (element.widget as Transform).transform.getMaxScaleOnAxis(),
        )
        .reduce(math.max);

    expect(scaleOf(), closeTo(1, 0.01));

    // Pinch on the page itself.
    final a = await tester.startGesture(const Offset(150, 400), pointer: 1);
    final b = await tester.startGesture(const Offset(250, 400), pointer: 2);
    await tester.pump();
    await a.moveTo(const Offset(50, 400));
    await tester.pump();
    await a.up();
    await b.up();
    await _pumpReader(tester);

    expect(scaleOf(), closeTo(2, 0.01));

    // Panning moves the magnified page, and the swipe no longer turns the page.
    final page = tester.getRect(canvas);
    final gesture = await tester.startGesture(Offset(page.right - 40, 400));
    await gesture.moveBy(const Offset(-40, 0));
    await gesture.moveBy(const Offset(-120, 0));
    await _pumpReader(tester);
    expect(container.read(provider).itemPosition, 0);
    await gesture.up();
    await _pumpReader(tester);

    // Turning the page gives the magnification back, so the next page is not a
    // cropped fragment.
    await tester.tapAt(Offset(page.right - 8, 400));
    await _pumpReader(tester);
    await _settleTransition(tester);

    expect(container.read(provider).itemPosition, 1);
    expect(scaleOf(), closeTo(1, 0.01));
  });

  testWidgets('a page that has not loaded is a slot, not a screenful', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    container
        .read(mangaReaderProvider(0, 5, _watch()).notifier)
        .changeReadMode(MangaReadMode.webToon);
    await _pumpReader(tester);

    // The images never load in a test, so every page is still its placeholder.
    // In a webtoon the item's height *is* the page's height, so a placeholder
    // that reserves the whole screen punches a screenful of black into the
    // strip: a black void under the last loaded page, magnified into an
    // obvious block at the page boundary once the reader zooms in.
    final page = tester.getSize(find.byType(MangaImage).first);
    expect(
      page.height,
      lessThan(900),
      reason: 'a loading page must not reserve a whole viewport',
    );
    // ...and nothing may reserve more than the canvas is tall.
    expect(page.height, lessThanOrEqualTo(900));
  });

  testWidgets('the page is never covered by a black scrim', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    await tester.pumpWidget(
      _wrap(
        container,
        MiruMangaReader(
          value: _watch(),
          name: 'TestManga',
          meta: _meta,
          url: 'https://example.com/c1',
          epProvider: episodeProvider(_params()),
        ),
      ),
    );
    await _pumpReader(tester);

    // Brightness drives the device display, not an overlay. A default reader
    // must not paint a black veil on top of the artwork at any value.
    final provider = mangaReaderProvider(0, 5, _watch());
    for (final value in [100, 85, 20]) {
      container.read(provider.notifier).setBrightness(value);
      await _pumpReader(tester);

      final scrims = tester
          .widgetList<ColoredBox>(find.byType(ColoredBox))
          .where((box) => (box.color.a * 255).round() < 255 && box.color.a > 0);
      expect(
        scrims,
        isEmpty,
        reason: 'brightness $value must not add a translucent black layer',
      );
    }
  });
}
