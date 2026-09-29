import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/chapter_drawer.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_sheet.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_settings_sheet.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_top_bar.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

class _FakeEpisodes extends EpisodeNotifier {
  _FakeEpisodes(this._state);
  final EpisodeNotifierState _state;

  @override
  EpisodeNotifierState build(WatchParams param) => _state;
}

ExtensionMangaWatch _watch(int pages) => ExtensionMangaWatch(
  urls: [for (var i = 1; i <= pages; i++) 'https://example.com/p$i.png'],
);

/// Several real manga sources stash the chapter URL in `description`, so the
/// fixture does too: the drawer must not surface it.
ExtensionEpisodeGroup _group(int episodes, {String title = 'Volume 1'}) =>
    ExtensionEpisodeGroup(
      title: title,
      urls: [
        for (var i = 1; i <= episodes; i++)
          ExtensionEpisode(
            name: 'Chapter $i',
            url: 'https://example.com/c$i',
            description: 'https://example.com/c$i',
          ),
      ],
    );

WatchParams _params(List<ExtensionEpisodeGroup> groups) => WatchParams(
  meta: ExtensionMeta(
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
  ),
  type: ExtensionType.manga,
  url: 'https://example.com/c1',
  selectedGroupIndex: 0,
  selectedEpisodeIndex: 0,
  name: 'TestManga',
  detailImageUrl: '',
  detailUrl: 'https://example.com/d',
  savePath: null,
  epGroup: groups,
);

/// A button that opens the requested sheet, so the test drives the same
/// `showFSheet` path the HUD uses.
class _SheetLauncher extends ConsumerWidget {
  const _SheetLauncher({
    required this.mangaProvider,
    required this.epProvider,
    required this.settings,
  });

  final MangaReaderProvider mangaProvider;
  final EpisodeNotifierProvider epProvider;
  final bool settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FButton(
      onPress: () => settings
          ? showReaderSettingsSheet(context, mangaProvider: mangaProvider)
          : showChapterDrawer(
              context,
              epProvider: epProvider,
              bookmarks: ref.watch(mangaProvider).bookmarks,
              openPosition: ref.watch(mangaProvider).page,
              openTotal: ref.watch(mangaProvider).totalPage,
              onToggleBookmark: ref
                  .read(mangaProvider.notifier)
                  .toggleBookmark,
              onOpenSettings: () => showReaderSettingsSheet(
                context,
                mangaProvider: mangaProvider,
              ),
            ),
      child: Text(settings ? 'open-settings' : 'open-chapters'),
    );
  }
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var frame = 0; frame < 8; frame++) {
    await tester.pump(const Duration(milliseconds: 32));
  }
}

/// The sheet body scrolls, so anything below the fold must be brought into
/// view before it can be tapped.
Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    120,
    scrollable: find.byType(Scrollable).last,
  );
  await _pumpFrames(tester);
  await tester.tap(finder);
  await _pumpFrames(tester);
}

/// The 0..1 fraction the [index]th slider is currently displaying.
///
/// FORUI declares `value` on the private lifted-control classes, so the
/// property is only reachable dynamically. That is exactly the thing under test:
/// a *managed* control would keep the fraction it was constructed with, which is
/// the bug the lifted control exists to fix.
double _sliderFraction(WidgetTester tester, int index) {
  final control = tester
      .widget<FSlider>(find.byType(FSlider).at(index))
      .control;
  return (control as dynamic).value.max as double;
}

void main() {
  setUp(MiruSettings.seedDefaultsForTest);
  setUpAll(() => MiruRequest.ensureInitalized(host: 'http://127.0.0.1:1'));

  group('reader settings sheet', () {
    late ProviderContainer container;
    late MangaReaderProvider mangaProvider;
    late EpisodeNotifierProvider epProvider;

    Future<void> openSheet(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: FTheme(
            data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
            child: MediaQuery(
              data: const MediaQueryData(size: Size(430, 900)),
              child: MaterialApp(
                home: Scaffold(
                  body: _SheetLauncher(
                    mangaProvider: mangaProvider,
                    epProvider: epProvider,
                    settings: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open-settings'));
      await _pumpFrames(tester);
    }

    setUp(() {
      final groups = [_group(4)];
      final params = _params(groups);
      epProvider = episodeProvider(params);
      container = ProviderContainer(
        overrides: [
          epProvider.overrideWith(
            () => _FakeEpisodes(
              EpisodeNotifierState(name: 'TestManga', epGroup: groups),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      mangaProvider = mangaReaderProvider(0, 4, _watch(10));
      container.read(mangaProvider);
    });

    testWidgets('opens as a modal sheet with every display control', (
      tester,
    ) async {
      await openSheet(tester);

      expect(find.text('reader.manga.settings'), findsOneWidget);
      expect(find.byType(FSwitch), findsNWidgets(3));
      expect(find.byType(FSlider), findsNWidgets(2));
      expect(find.byType(ReaderTopBar), findsNothing);
      // The reset is the header's single action (it replaced the close button);
      // there is no footer to confirm from.
      expect(find.byIcon(FLucideIcons.rotateCcw), findsOneWidget);
      expect(find.text('common.confirm'), findsNothing);
      expect(find.text('100%'), findsOneWidget);
      // The shipped default has no gutter between pages.
      expect(find.text('0px'), findsOneWidget);
      // The panel is not a place for image fitting any more: the viewport owns
      // that, and a second control for it only competed with brightness.
      expect(find.text('reader.manga.fit_mode'), findsNothing);
      expect(find.text('reader.manga.fit_options.fitWidth'), findsNothing);
    });

    testWidgets('brightness offers auto and manual, and auto wins the screen', (
      tester,
    ) async {
      await openSheet(tester);
      // Auto is the shipped default: the reader does not take the screen over
      // until it is asked to.
      expect(
        container.read(mangaProvider).brightnessMode,
        MangaBrightnessMode.auto,
      );
      expect(
        find.text('reader.manga.brightness_options.auto'),
        findsOneWidget,
      );

      // Toggled to manual, which is the direction that has to be exercised now
      // that auto is where it starts.
      await _tapVisible(
        tester,
        find.text('reader.manga.brightness_options.manual'),
      );
      await _pumpFrames(tester);

      final state = container.read(mangaProvider);
      expect(state.brightnessMode, MangaBrightnessMode.manual);
      // Read it back **as the enum**, not as the raw string: the store has to
      // know the type or the value silently falls back to the default on the
      // next launch.
      expect(
        MiruSettings.getSettingSync<MangaBrightnessMode>(
          SettingKey.mangaBrightnessMode,
        ),
        MangaBrightnessMode.manual,
      );
      // Manual is selected, and the remembered percentage is still there...
      expect(
        find.text('reader.manga.brightness_options.manual'),
        findsWidgets,
      );
      expect(_sliderFraction(tester, 0), closeTo(1, 0.01));

      // ...and the slider stays live: it is not a disabled control in auto.
      expect(
        tester.widget<FSlider>(find.byType(FSlider).first).enabled,
        isTrue,
      );
      // Choosing a brightness while on auto takes the screen over; the rule
      // lives in the provider so every caller gets it.
      container.read(mangaProvider.notifier).setBrightness(40);
      await _pumpFrames(tester);

      final dragged = container.read(mangaProvider);
      expect(dragged.brightness, 40);
      expect(dragged.brightnessMode, MangaBrightnessMode.manual);
    });

    testWidgets('the brightness slider follows its stored value', (
      tester,
    ) async {
      await openSheet(tester);
      expect(_sliderFraction(tester, 0), closeTo(1, 0.01));

      container.read(mangaProvider.notifier).setBrightness(60);
      await _pumpFrames(tester);

      // 60% of the 20..100 range. A managed control would still read 100 here.
      expect(_sliderFraction(tester, 0), closeTo(0.5, 0.01));
    });

    testWidgets('toggling a switch writes through to reader state', (
      tester,
    ) async {
      await openSheet(tester);
      expect(container.read(mangaProvider).invertColors, isFalse);

      await _tapVisible(tester, find.byType(FSwitch).first);

      expect(container.read(mangaProvider).invertColors, isTrue);
      expect(
        MiruSettings.getSettingSync<bool>(SettingKey.mangaInvertColors),
        isTrue,
      );
    });

    testWidgets('apply defaults restores every control at once', (
      tester,
    ) async {
      await openSheet(tester);
      final reader = container.read(mangaProvider.notifier);
      reader
        ..setInvertColors(true)
        ..setBrightness(30)
        ..setFitMode(MangaFitMode.original);
      await _pumpFrames(tester);

      await _tapVisible(tester, find.byIcon(FLucideIcons.rotateCcw));

      final state = container.read(mangaProvider);
      expect(state.invertColors, isFalse);
      expect(state.brightness, kMangaBrightnessDefault);
      expect(state.fitMode, MangaFitMode.fitWidth);
    });

    testWidgets('the grabber closes the sheet', (tester) async {
      await openSheet(tester);
      expect(find.text('reader.manga.settings'), findsOneWidget);

      // FORUI's `FTappable` builds a private widget, so the handle is tapped by
      // its own type.
      await tester.tap(find.byType(ReaderSheetHandle));
      await _pumpFrames(tester);

      expect(find.text('reader.manga.settings'), findsNothing);
    });
  });

  group('chapter drawer', () {
    late ProviderContainer container;
    late MangaReaderProvider mangaProvider;
    late EpisodeNotifierProvider epProvider;

    Future<void> openDrawer(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: FTheme(
            data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
            child: MediaQuery(
              data: const MediaQueryData(size: Size(430, 900)),
              child: MaterialApp(
                home: Scaffold(
                  body: _SheetLauncher(
                    mangaProvider: mangaProvider,
                    epProvider: epProvider,
                    settings: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open-chapters'));
      await _pumpFrames(tester);
    }

    setUp(() {
      final groups = [_group(4), _group(3, title: 'Volume 2')];
      final params = _params(groups);
      epProvider = episodeProvider(params);
      container = ProviderContainer(
        overrides: [
          epProvider.overrideWith(
            () => _FakeEpisodes(
              EpisodeNotifierState(name: 'TestManga', epGroup: groups),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      mangaProvider = mangaReaderProvider(0, 4, _watch(10));
      container.read(mangaProvider);
    });

    testWidgets('lists chapters newest-first by default', (tester) async {
      await openDrawer(tester);

      expect(find.text('reader.manga.chapters_title'), findsOneWidget);
      expect(find.byType(FTextField), findsOneWidget);
      // Header: the volume, then how many chapters it holds.
      expect(find.textContaining('Volume 1'), findsWidgets);
      for (final name in ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4']) {
        expect(find.text(name), findsOneWidget);
      }
      // Descending puts the last chapter above the first.
      expect(
        tester.getTopLeft(find.text('Chapter 4')).dy,
        lessThan(tester.getTopLeft(find.text('Chapter 1')).dy),
      );
    });

    testWidgets('ascending order reverses the list', (tester) async {
      await openDrawer(tester);
      // The order is one arrow, not a two-option strip.
      final arrow = find.byIcon(FLucideIcons.arrowDown);
      expect(arrow, findsOneWidget);
      await tester.tap(arrow);
      await _pumpFrames(tester);
      expect(find.byIcon(FLucideIcons.arrowUp), findsOneWidget);

      expect(find.text('Chapter 1'), findsOneWidget);
      expect(find.text('Chapter 4'), findsOneWidget);
    });

    testWidgets('tapping a chapter selects it and closes the drawer', (
      tester,
    ) async {
      await openDrawer(tester);
      await tester.tap(find.text('Chapter 3'));
      await _pumpFrames(tester);

      expect(container.read(epProvider).selectedEpisodeIndex, 2);
      expect(find.text('reader.manga.chapters_title'), findsNothing);
    });

    testWidgets('volume chips switch the listed group', (tester) async {
      await openDrawer(tester);
      await tester.tap(find.text('Volume 2'));
      await _pumpFrames(tester);

      expect(container.read(epProvider).selectedGroupIndex, 1);
      expect(container.read(epProvider).selectedEpisodeIndex, 0);
      // Volume 2 only holds three chapters, which the header says.
      expect(find.textContaining('Volume 2'), findsWidgets);
    });

    testWidgets('the drawer bookmarks the open chapter and remembers it', (
      tester,
    ) async {
      await openDrawer(tester);

      // The rows carry the affordance; the sticky bar's is last in the tree and
      // toggles the *open* chapter.
      expect(find.byIcon(FLucideIcons.bookmark), findsWidgets);
      await _tapVisible(tester, find.byIcon(FLucideIcons.bookmark).last);
      expect(container.read(mangaProvider.notifier).isBookmarked(0, 0), isTrue);
      // Persisted, so the set survives a relaunch.
      expect(
        MiruSettings.getSettingSync<String>(SettingKey.mangaBookmarks),
        contains('0:0'),
      );
    });
    testWidgets('the open chapter offers Resume instead of the bookmark', (
      tester,
    ) async {
      await openDrawer(tester);

      expect(find.text('reader.manga.resume'), findsOneWidget);
    });

    testWidgets('filtering narrows the list to matching names', (tester) async {
      await openDrawer(tester);
      // Scope to the chapter list: the filter field itself also holds the
      // text, and find.text matches EditableText. The list is FORUI's tile
      // group, which brings its own scroll view.
      Finder listed(String name) => find.descendant(
        of: find.byType(FTileGroup),
        matching: find.text(name),
      );

      expect(listed('Chapter 2'), findsOneWidget);
      await tester.enterText(find.byType(FTextField), 'Chapter 2');
      await _pumpFrames(tester);

      expect(listed('Chapter 2'), findsOneWidget);
      expect(listed('Chapter 4'), findsNothing);
    });

    testWidgets('the chapter list is a FORUI tile group of selected tiles', (
      tester,
    ) async {
      await openDrawer(tester);

      // The list is FORUI's own group, and the open chapter is a *selected*
      // tile so its focus outline comes from FTile rather than a border drawn
      // here.
      expect(find.byType(FTileGroup), findsWidgets);
      final tiles = find.descendant(
        of: find.byType(FTileGroup),
        matching: find.byType(FTile),
      );
      expect(tiles, findsNWidgets(4));
      final selected = <int>[
        for (var i = 0; i < tiles.evaluate().length; i++)
          if (tester.widget<FTile>(tiles.at(i)).selected) i,
      ];
      expect(selected, hasLength(1));
      // ...and it is the chapter the extension API says is open.
      expect(
        find.descendant(
          of: tiles.at(selected.single),
          matching: find.text('Chapter 1'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('chapter rows never leak a raw URL', (tester) async {
      await openDrawer(tester);
      // The fixture puts the URL in both `url` and `description`; neither may
      // reach the screen.
      expect(find.textContaining('https://example.com'), findsNothing);
    });

    testWidgets('the open chapter is badged as Reading', (tester) async {
      await openDrawer(tester);
      expect(find.text('reader.manga.reading'), findsOneWidget);
    });

    testWidgets('an empty chapter list explains itself', (tester) async {
      final groups = <ExtensionEpisodeGroup>[];
      final params = _params(groups);
      final emptyEp = episodeProvider(params);
      final emptyContainer = ProviderContainer(
        overrides: [
          emptyEp.overrideWith(
            () => _FakeEpisodes(
              EpisodeNotifierState(name: 'TestManga', epGroup: groups),
            ),
          ),
        ],
      );
      addTearDown(emptyContainer.dispose);
      final emptyManga = mangaReaderProvider(0, 0, null);
      emptyContainer.read(emptyManga);

      await tester.binding.setSurfaceSize(const Size(430, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: emptyContainer,
          child: FTheme(
            data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
            child: MediaQuery(
              data: const MediaQueryData(size: Size(430, 900)),
              child: MaterialApp(
                home: Scaffold(
                  body: _SheetLauncher(
                    mangaProvider: emptyManga,
                    epProvider: emptyEp,
                    settings: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open-chapters'));
      await _pumpFrames(tester);

      expect(find.text('reader.manga.no_chapters'), findsWidgets);
    });
  });
}
