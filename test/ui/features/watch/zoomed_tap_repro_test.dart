import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/manga_reader.dart';

import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// Reproduces the "zoomed tap shows the HUD then instantly hides it" report on
/// the real shell: pinch to zoom, close the tap window, then tap the centre
/// with (and without) the micro-movement a real finger always carries.
void main() {
  setUp(MiruSettings.seedDefaultsForTest);
  setUpAll(() => MiruRequest.ensureInitalized(host: 'http://127.0.0.1:1'));

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

  WatchParams params() => WatchParams(
    meta: meta,
    type: ExtensionType.manga,
    url: 'https://example.com/c1',
    selectedGroupIndex: 0,
    selectedEpisodeIndex: 0,
    name: 'TestManga',
    detailImageUrl: '',
    detailUrl: 'https://example.com/d',
    savePath: null,
    epGroup: [
      ExtensionEpisodeGroup(
        title: 'Volume 1',
        urls: [
          for (var i = 1; i <= 5; i++)
            ExtensionEpisode(
              name: 'Chapter $i',
              url: 'https://example.com/c$i',
            ),
        ],
      ),
    ],
  );

  Future<ProviderContainer> pumpReader(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer(
      overrides: [
        episodeProvider(params()).overrideWith(
          () => _FakeEpisodes(
            EpisodeNotifierState(
              name: 'TestManga',
              epGroup: [
                ExtensionEpisodeGroup(
                  title: 'Volume 1',
                  urls: [
                    for (var i = 1; i <= 5; i++)
                      ExtensionEpisode(
                        name: 'Chapter $i',
                        url: 'https://example.com/c$i',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: FTheme(
          data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
          child: MediaQuery(
            data: const MediaQueryData(size: Size(430, 900)),
            child: MaterialApp(
              home: MiruMangaReader(
                value: ExtensionMangaWatch(
                  urls: ['https://example.com/p1.png'],
                ),
                name: 'TestManga',
                meta: meta,
                url: 'https://example.com/c1',
                epProvider: episodeProvider(params()),
              ),
            ),
          ),
        ),
      ),
    );
    for (var frame = 0; frame < 6; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    return container;
  }

  testWidgets('zoomed centre tap with micro-moves shows the HUD exactly once', (
    tester,
  ) async {
    final container = await pumpReader(tester);
    final provider = mangaReaderProvider;
    var toggles = 0;
    var lastVisible = container.read(provider).hudVisible;
    container.listen(provider, (_, next) {
      if (next.hudVisible != lastVisible) {
        toggles++;
        lastVisible = next.hudVisible;
      }
    });

    // Pinch to 2x.
    final a = await tester.startGesture(const Offset(150, 400), pointer: 1);
    final b = await tester.startGesture(const Offset(250, 400), pointer: 2);
    await tester.pump(const Duration(milliseconds: 16));
    await a.moveTo(const Offset(50, 400));
    await tester.pump(const Duration(milliseconds: 16));
    await a.up();
    await b.up();
    await tester.pump(const Duration(milliseconds: 350));

    expect(container.read(provider).hudVisible, isFalse);
    final before = toggles;

    // Centre tap, with the micro-movement a real finger carries.
    final tap = await tester.startGesture(const Offset(215, 450));
    await tap.moveBy(const Offset(2, 1));
    await tester.pump(const Duration(milliseconds: 30));
    await tap.moveBy(const Offset(-1, 1));
    await tester.pump(const Duration(milliseconds: 30));
    await tap.up();
    // The double-tap window plus slack.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      container.read(provider).hudVisible,
      isTrue,
      reason: 'the tap shows the HUD',
    );
    expect(
      toggles - before,
      1,
      reason: 'the HUD must not bounce: one transition per tap',
    );
  });

  testWidgets('zoomed centre tap without micro-moves shows the HUD once', (
    tester,
  ) async {
    final container = await pumpReader(tester);
    final provider = mangaReaderProvider;
    var toggles = 0;
    var lastVisible = container.read(provider).hudVisible;
    container.listen(provider, (_, next) {
      if (next.hudVisible != lastVisible) {
        toggles++;
        lastVisible = next.hudVisible;
      }
    });

    final a = await tester.startGesture(const Offset(150, 400), pointer: 1);
    final b = await tester.startGesture(const Offset(250, 400), pointer: 2);
    await tester.pump(const Duration(milliseconds: 16));
    await a.moveTo(const Offset(50, 400));
    await tester.pump(const Duration(milliseconds: 16));
    await a.up();
    await b.up();
    await tester.pump(const Duration(milliseconds: 350));

    final before = toggles;
    await tester.tapAt(const Offset(215, 450));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(container.read(provider).hudVisible, isTrue);
    expect(toggles - before, 1);
  });

  testWidgets(
    'zoomed centre tap toggles once, after the disambiguation window',
    (tester) async {
      final container = await pumpReader(tester);
      final provider = mangaReaderProvider;
      var toggles = 0;
      var lastVisible = container.read(provider).hudVisible;
      container.listen(provider, (_, next) {
        if (next.hudVisible != lastVisible) {
          toggles++;
          lastVisible = next.hudVisible;
        }
      });

      final a = await tester.startGesture(const Offset(150, 400), pointer: 1);
      final b = await tester.startGesture(const Offset(250, 400), pointer: 2);
      await tester.pump(const Duration(milliseconds: 16));
      await a.moveTo(const Offset(50, 400));
      await tester.pump(const Duration(milliseconds: 16));
      await a.up();
      await b.up();
      await tester.pump(const Duration(milliseconds: 350));

      final before = toggles;
      await tester.tapAt(const Offset(215, 450));
      // Still inside the disambiguation window: nothing has fired yet — the
      // tap may still become the first half of a double-tap zoom-out.
      await tester.pump(const Duration(milliseconds: 60));
      expect(
        container.read(provider).hudVisible,
        isFalse,
        reason: 'the window is still open',
      );
      expect(toggles - before, 0);

      // The window closes: exactly one toggle, and it sticks.
      await tester.pump(const Duration(milliseconds: 350));
      expect(
        container.read(provider).hudVisible,
        isTrue,
        reason: 'the single tap shows the HUD and it stays',
      );
      expect(toggles - before, 1);
    },
  );
}

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
