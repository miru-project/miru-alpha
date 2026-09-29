import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/novel_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_content.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/widget/novel_reading_view.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

const _surface = Size(430, 800);

/// A chapter long enough to page through several times, as the extension would
/// return it: a flat list of strings.
List<String> _chapter({int paragraphs = 40}) => [
  for (var i = 0; i < paragraphs; i++)
    'It was November. Paragraph $i of the chapter goes on at some length, '
        'long enough that a narrow column has to wrap it onto several lines so '
        'the pagination pass has something to measure and pack.',
  '> A letter, for me. That was something of an event.',
];

Widget _app({
  required NovelReaderProvider novelProvider,
  required List<NovelContentBlock> blocks,
  void Function(double)? onTapZone,
}) {
  return FTheme(
    data: ThemeUtils.getThemeData(MiruThemes.zinc.dark),
    child: MediaQuery(
      data: const MediaQueryData(size: _surface),
      child: MaterialApp(
        home: Scaffold(
          body: NovelReadingView(
            blocks: blocks,
            chapterTitle: 'The Thirteenth Tale',
            chapterOrdinal: 1,
            novelProvider: novelProvider,
            onTapZone: onTapZone ?? (_) {},
          ),
        ),
      ),
    ),
  );
}

/// Pumps the canvas in the given reading mode, with the mode and paper seeded as
/// persisted settings — the same path a returning reader takes.
Future<({NovelReaderProvider provider, ProviderContainer container})> _pump(
  WidgetTester tester, {
  NovelReadMode mode = NovelReadMode.webToon,
  NovelTheme theme = NovelTheme.midnight,
  List<String>? content,
}) async {
  MiruSettings.setSettingSync(SettingKey.novelReadingMode, mode.name);
  MiruSettings.setSettingSync(SettingKey.novelTheme, theme.name);

  final source = content ?? _chapter();
  final blocks = parseNovelContent(source);
  final provider = novelReaderProvider(source, null);
  final container = ProviderContainer(
    overrides: [
      provider.overrideWith(() => _FakeNovelReader(source, mode, theme)),
    ],
  );
  addTearDown(container.dispose);
  await tester.binding.setSurfaceSize(_surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _app(novelProvider: provider, blocks: blocks),
    ),
  );
  await tester.pumpAndSettle();
  return (provider: provider, container: container);
}

/// A reader whose only job is to start in a known mode on a known paper.
class _FakeNovelReader extends NovelReader {
  _FakeNovelReader(this._content, this._mode, this._theme);

  final List<String> _content;
  final NovelReadMode _mode;
  final NovelTheme _theme;

  // Calls the real build so the position listeners are attached, then pins the
  // mode and paper. Overriding it outright left the reader with no listeners at
  // all, which is why a swipe moved the page view without the state following.
  @override
  NovelReaderState build(List<String>? content, String? localPath) => super
      .build(content, localPath)
      .copyWith(content: _content, readMode: _mode, theme: _theme);
}

void main() {
  setUp(MiruSettings.seedDefaultsForTest);

  testWidgets('the continuous mode lays the chapter out without overflowing', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('The Thirteenth Tale'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the paged mode measures a chapter into several pages', (
    tester,
  ) async {
    final pumped = await _pump(tester, mode: NovelReadMode.standard);
    final state = pumped.container.read(pumped.provider);

    expect(state.totalLine, greaterThan(0));
    expect(state.totalPage, greaterThan(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('swiping a page reports the page it landed on', (tester) async {
    // The paged canvas reports its position through the page controller, and the
    // reader had no listener on it: a swipe changed the page on screen while the
    // scrubber, the status pill and the saved history stayed on the old number.
    final pumped = await _pump(tester, mode: NovelReadMode.standard);
    final provider = pumped.provider;
    final before = pumped.container.read(provider).page;

    await tester.fling(
      find.byType(NovelReadingView),
      const Offset(-600, 0),
      2000,
    );
    await tester.pumpAndSettle();
    final notifier = pumped.container.read(provider.notifier);
    // ignore: avoid_print
    print(
      'DBG state.page=${pumped.container.read(provider).page} total=${pumped.container.read(provider).totalPage} ctrl=${notifier.pageController.hasClients ? notifier.pageController.page : 'no clients'} isPaged=${pumped.container.read(provider).isPaged}',
    );

    final after = pumped.container.read(provider).page;
    expect(after, greaterThan(before));
    expect(after, greaterThan(1));
  });

  testWidgets('the double-column mode lays out without overflowing', (
    tester,
  ) async {
    final pumped = await _pump(tester, mode: NovelReadMode.doubleColumn);
    final state = pumped.container.read(pumped.provider);

    expect(state.totalPage, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  // One test per paper rather than a loop inside one test: re-pumping a whole
  // tree in place leaves the previous one's timers pending, which the test
  // harness reports as a failure.
  testWidgets('the page padding is the safe area and nothing more', (
    tester,
  ) async {
    // The chrome floats over the prose, so revealing it must not move the text:
    // the page's padding is whatever the mode's safe area says and is never
    // widened to make room for a bar that happens to be on screen. That is why
    // the canvas does not take a `hudVisible` at all — it cannot reflow on it.
    const statusBarPixels = 132.0;
    final statusBar = statusBarPixels / tester.view.devicePixelRatio;
    final source = _chapter();
    final provider = novelReaderProvider(source, null);
    final container = ProviderContainer(
      overrides: [
        provider.overrideWith(
          () => _FakeNovelReader(
            source,
            NovelReadMode.standard,
            NovelTheme.midnight,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.binding.setSurfaceSize(_surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.padding = const FakeViewPadding(
      top: statusBarPixels,
      bottom: 72,
    );
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: FTheme(
          data: ThemeUtils.getThemeData(MiruThemes.zinc.dark),
          child: MaterialApp(
            home: NovelReadingView(
              blocks: parseNovelContent(source),
              chapterTitle: 'The Thirteenth Tale',
              chapterOrdinal: 1,
              novelProvider: provider,
              onTapZone: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // A page is a sheet, so the status bar's 44pt is held back and the header
    // starts its own spacing from there. No chrome allowance on top of it.
    final canvas = tester.getRect(find.byType(NovelReadingView));
    final top = tester.getRect(find.text('The Thirteenth Tale')).top;
    expect(top - canvas.top, closeTo(60.6 + statusBar, 2));
    expect(tester.takeException(), isNull);
  });

  // One test per mode rather than a loop inside one test: swapping the tree
  // between modes disposes an auto-dispose provider each time, and riverpod
  // schedules that dispose rather than running it inline, which the test harness
  // reports as a pending timer.
  for (final mode in kNovelReadModeOrder) {
    testWidgets(
      '${mode.name} ${mode == NovelReadMode.webToon ? "ignores" : "insets"} the safe area',
      (tester) async {
        // A continuous scroll is full-bleed, like the manga webtoon canvas:
        // insetting it left a strip of bare paper along the top and bottom. A
        // paged mode is a sheet of paper, so it sits inside the safe area or the
        // status bar and the gesture bar sit on top of the sheet's edges.
        //
        // 132 physical pixels at the test's 3x ratio is 44 logical, a plausible
        // status bar; 72 is a gesture bar.
        const statusBarPixels = 132.0;
        final statusBar = statusBarPixels / tester.view.devicePixelRatio;
        final source = _chapter();
        final provider = novelReaderProvider(source, null);
        final container = ProviderContainer(
          overrides: [
            provider.overrideWith(
              () => _FakeNovelReader(source, mode, NovelTheme.midnight),
            ),
          ],
        );
        addTearDown(container.dispose);
        await tester.binding.setSurfaceSize(_surface);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        // The inset comes from the *view* and there is deliberately no `Scaffold`:
        // MaterialApp rebuilds MediaQuery from the view, and a Scaffold consumes
        // the safe area before its body ever sees it.
        tester.view.padding = const FakeViewPadding(
          top: statusBarPixels,
          bottom: 72,
        );
        addTearDown(tester.view.resetPadding);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: FTheme(
              data: ThemeUtils.getThemeData(MiruThemes.zinc.dark),
              child: MaterialApp(
                home: NovelReadingView(
                  blocks: parseNovelContent(source),
                  chapterTitle: 'The Thirteenth Tale',
                  chapterOrdinal: 1,
                  novelProvider: provider,
                  onTapZone: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final canvas = tester.getRect(find.byType(NovelReadingView));
        final held =
            tester.getRect(find.text('The Thirteenth Tale')).top - canvas.top;
        if (mode == NovelReadMode.webToon) {
          // Only the chapter header's own spacing, no safe area held back.
          expect(held, closeTo(60.6, 2));
        } else {
          expect(held, closeTo(60.6 + statusBar, 2));
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final fontSize in [18.0, 12.0]) {
    for (final mode in kNovelReadModeOrder) {
      testWidgets('${mode.name} at ${fontSize.round()}px lays a page out', (
        tester,
      ) async {
        final source = _chapter();
        final provider = novelReaderProvider(source, null);
        final container = ProviderContainer(
          overrides: [
            provider.overrideWith(
              () => _FakeNovelReader(source, mode, NovelTheme.midnight),
            ),
          ],
        );
        addTearDown(container.dispose);
        await tester.binding.setSurfaceSize(_surface);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        container.read(provider.notifier).setFontSize(fontSize);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: _app(
              novelProvider: provider,
              blocks: parseNovelContent(source),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        // The measure is the surface less the default 20pt margin on each side,
        // and nothing on the page may reach past it.
        final measure = _surface.width - 40;
        for (final widget in tester.widgetList<Column>(find.byType(Column))) {
          expect(
            tester.getSize(find.byWidget(widget)).width,
            lessThanOrEqualTo(measure + 1),
            reason: 'nothing exceeds the prose measure',
          );
        }
      });
    }
  }

  for (final theme in NovelTheme.values) {
    testWidgets('the $theme paper lays the chapter out', (tester) async {
      await _pump(tester, theme: theme);

      expect(find.text('The Thirteenth Tale'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a quotation is drawn as its own card', (tester) async {
    await _pump(
      tester,
      content: const ['Opening prose.', '> A letter, for me.'],
    );

    expect(find.text('A letter, for me.'), findsOneWidget);
    expect(find.text('Opening prose.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a tap reports where on the canvas it landed', (tester) async {
    final zones = <double>[];
    final source = _chapter();
    final container = ProviderContainer(
      overrides: [
        novelReaderProvider(source, null).overrideWith(
          () => _FakeNovelReader(
            source,
            NovelReadMode.webToon,
            NovelTheme.midnight,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.binding.setSurfaceSize(_surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _app(
          novelProvider: novelReaderProvider(source, null),
          blocks: parseNovelContent(source),
          onTapZone: zones.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(20, 400));
    await tester.pumpAndSettle();
    expect(zones, isNotEmpty);
    // 20 / 430 lands well inside the leading edge zone.
    expect(zones.first, lessThan(kNovelTapZoneExtent));
  });
}
