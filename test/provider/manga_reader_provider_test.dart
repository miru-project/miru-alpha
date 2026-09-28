import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderContainer;
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// Synthetic `example.com` pages — no real site is contacted.
ExtensionMangaWatch _watch(int pages) => ExtensionMangaWatch(
  urls: [for (var i = 1; i <= pages; i++) 'https://example.com/p$i.png'],
);

ProviderContainer _container() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUp(MiruSettings.seedDefaultsForTest);

  group('MangaReaderState', () {
    test('page, historyProgress and progress agree', () {
      const first = MangaReaderState(totalPage: 10);
      expect(first.page, 1);
      expect(first.historyProgress, 1);
      expect(first.progress, closeTo(0.1, 1e-9));

      const last = MangaReaderState(totalPage: 10, itemPosition: 9);
      expect(last.page, 10);
      expect(last.progress, closeTo(1, 1e-9));

      const empty = MangaReaderState();
      expect(empty.page, 0);
      expect(empty.progress, 0);
    });

    test('copyWith keeps every unspecified field', () {
      const state = MangaReaderState(
        totalPage: 4,
        itemPosition: 2,
        brightness: 40,
        pageGap: 3,
        invertColors: true,
        keepScreenOn: false,
        tapToTurnPage: false,
        fitMode: MangaFitMode.original,
        canvasBackground: MangaCanvasBackground.light,
        hudVisible: false,
      );
      final copy = state.copyWith(itemPosition: 3);
      expect(copy.itemPosition, 3);
      expect(copy.brightness, 40);
      expect(copy.pageGap, 3);
      expect(copy.invertColors, isTrue);
      expect(copy.keepScreenOn, isFalse);
      expect(copy.tapToTurnPage, isFalse);
      expect(copy.fitMode, MangaFitMode.original);
      expect(copy.canvasBackground, MangaCanvasBackground.light);
      expect(copy.hudVisible, isFalse);
    });
  });

  group('MangaReader', () {
    test('brightness defaults to 100 so no scrim is painted over the page', () {
      final container = _container();
      final state = container.read(mangaReaderProvider(0, 8, _watch(8)));
      expect(state.brightness, 100);
      expect(state.brightness, kMangaBrightnessDefault);
    });

    test('build reads persisted settings and chapter size', () {
      MiruSettings.setSettingSync(SettingKey.mangaBrightness, '40');
      MiruSettings.setSettingSync(SettingKey.mangaFitMode, 'original');
      MiruSettings.setSettingSync(SettingKey.mangaTapToTurnPage, 'false');

      final container = _container();
      final state = container.read(mangaReaderProvider(0, 8, _watch(8)));
      expect(state.totalPage, 8);
      expect(state.content, hasLength(8));
      expect(state.brightness, 40);
      expect(state.fitMode, MangaFitMode.original);
      expect(state.tapToTurnPage, isFalse);
      // The reader rests on the page alone; the centre tap summons the HUD.
      expect(state.hudVisible, isFalse);
    });

    test('setters clamp and persist', () {
      final container = _container();
      final provider = mangaReaderProvider(0, 8, _watch(8));
      final reader = container.read(provider.notifier);

      reader.setBrightness(5);
      expect(container.read(provider).brightness, kMangaBrightnessMin);
      expect(
        MiruSettings.getSettingSync<int>(SettingKey.mangaBrightness),
        kMangaBrightnessMin,
      );

      reader.setBrightness(500);
      expect(container.read(provider).brightness, kMangaBrightnessMax);

      reader.setPageGap(-4);
      expect(container.read(provider).pageGap, kMangaPageGapMin);
      reader.setPageGap(999);
      expect(container.read(provider).pageGap, kMangaPageGapMax);
      expect(
        MiruSettings.getSettingSync<int>(SettingKey.mangaPageGap),
        kMangaPageGapMax,
      );
    });

    test('display settings persist through MiruSettings', () {
      final container = _container();
      final provider = mangaReaderProvider(0, 8, _watch(8));
      final reader = container.read(provider.notifier);

      reader.setFitMode(MangaFitMode.fitHeight);
      reader.setCanvasBackground(MangaCanvasBackground.darkGray);
      reader.setInvertColors(true);
      reader.setKeepScreenOn(false);
      reader.setTapToTurnPage(false);
      reader.changeReadMode(MangaReadMode.webToon);

      expect(
        MiruSettings.getSettingSync<MangaFitMode>(SettingKey.mangaFitMode),
        MangaFitMode.fitHeight,
      );
      expect(
        MiruSettings.getSettingSync<MangaCanvasBackground>(
          SettingKey.mangaCanvasBackground,
        ),
        MangaCanvasBackground.darkGray,
      );
      expect(
        MiruSettings.getSettingSync<bool>(SettingKey.mangaInvertColors),
        isTrue,
      );
      expect(
        MiruSettings.getSettingSync<bool>(SettingKey.mangaKeepScreenOn),
        isFalse,
      );
      expect(
        MiruSettings.getSettingSync<bool>(SettingKey.mangaTapToTurnPage),
        isFalse,
      );
      expect(
        MiruSettings.getSettingSync<MangaReadMode>(SettingKey.mangaReadingMode),
        MangaReadMode.webToon,
      );
    });

    test('resetDisplaySettings restores every shipped default', () {
      final container = _container();
      final provider = mangaReaderProvider(0, 8, _watch(8));
      final reader = container.read(provider.notifier);

      reader
        ..setFitMode(MangaFitMode.original)
        ..setCanvasBackground(MangaCanvasBackground.light)
        ..setBrightness(30)
        ..setPageGap(2)
        ..setInvertColors(true)
        ..setKeepScreenOn(false)
        ..setTapToTurnPage(false)
        ..changeReadMode(MangaReadMode.webToon)
        ..resetDisplaySettings();

      final state = container.read(provider);
      expect(state.readMode, MangaReadMode.standard);
      expect(state.fitMode, MangaFitMode.fitWidth);
      expect(state.canvasBackground, MangaCanvasBackground.black);
      expect(state.brightness, kMangaBrightnessDefault);
      expect(state.pageGap, kMangaPageGapDefault);
      expect(state.invertColors, isFalse);
      expect(state.keepScreenOn, isTrue);
      expect(state.tapToTurnPage, isTrue);
    });

    test('HUD starts hidden, toggles, and is not persisted', () {
      final container = _container();
      final provider = mangaReaderProvider(0, 8, _watch(8));
      final reader = container.read(provider.notifier);

      expect(container.read(provider).hudVisible, isFalse);
      reader.toggleHud();
      expect(container.read(provider).hudVisible, isTrue);
      reader.toggleHud();
      expect(container.read(provider).hudVisible, isFalse);
      // Chapter position is untouched by a HUD toggle.
      expect(container.read(provider).itemPosition, 0);
    });

    test('setPageNumber clamps to the chapter and jumpTo moves it', () {
      final container = _container();
      final provider = mangaReaderProvider(0, 5, _watch(5));
      final reader = container.read(provider.notifier);

      reader.setPageNumber(99);
      expect(container.read(provider).itemPosition, 4);
      reader.setPageNumber(-3);
      expect(container.read(provider).itemPosition, 0);

      reader.jumpTo(2);
      expect(container.read(provider).itemPosition, 2);
      expect(container.read(provider).page, 3);
    });

    test('stepPage saturates at both ends', () {
      final container = _container();
      final provider = mangaReaderProvider(0, 3, _watch(3));
      final reader = container.read(provider.notifier);

      reader.stepPage(-1);
      expect(container.read(provider).itemPosition, 0);
      reader.stepPage(1);
      reader.stepPage(1);
      reader.stepPage(1);
      expect(container.read(provider).itemPosition, 2);
      reader.stepPage(5);
      expect(container.read(provider).itemPosition, 2);
    });

    test('an empty chapter never records a page', () {
      final container = _container();
      final provider = mangaReaderProvider(0, 0, null);
      final reader = container.read(provider.notifier);
      expect(container.read(provider).totalPage, 0);

      reader.setPageNumber(3);
      reader.jumpTo(1);
      expect(container.read(provider).itemPosition, 0);
      expect(container.read(provider).historyProgress, 0);
    });
  });
}
