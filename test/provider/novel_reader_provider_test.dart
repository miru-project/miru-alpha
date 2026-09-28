import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderContainer;
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/novel_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_content.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_pagination.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

ProviderContainer _container() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

NovelReader _reader(ProviderContainer container) =>
    container.read(novelReaderProvider(const ['A line.'], null).notifier);

NovelReaderState _state(ProviderContainer container) =>
    container.read(novelReaderProvider(const ['A line.'], null));

/// A layout big enough to page through, so the position fields are meaningful.
NovelLayout _layout({int lines = 40, int pages = 6}) => NovelLayout(
  blockHeights: const [120, 400, 400, 400],
  blockFirstLines: const [0, 1, 12, 24],
  totalLine: lines,
  pages: [
    for (var i = 0; i < pages; i++)
      NovelPage(
        startLine: i * 5 + 1,
        columnBlockIndices: const [
          [0],
        ],
      ),
  ],
);

void main() {
  setUp(MiruSettings.seedDefaultsForTest);

  group('novel reader defaults', () {
    test('opens continuous, on the default paper, with the HUD hidden', () {
      final container = _container();
      final state = _state(container);

      expect(state.readMode, NovelReadMode.webToon);
      expect(state.theme, NovelTheme.midnight);
      expect(state.hudVisible, isFalse);
      expect(state.fontSize, kNovelFontSizeDefault);
      expect(state.lineHeight, kNovelLineHeightDefault);
      expect(state.margin, kNovelMarginDefault);
    });

    test('the seeded defaults survive a read of every novel key', () {
      final container = _container();
      final state = _state(container);

      expect(state.fontFamily, NovelFontFamily.serif);
      expect(state.readMode, NovelReadMode.webToon);
      expect(state.keepScreenOn, isTrue);
      expect(state.tapToTurnPage, isTrue);
      expect(state.volumeKeysTurnPage, isFalse);
      expect(state.bookmarks, isEmpty);
    });
  });

  group('display settings', () {
    test('a changed setting is written through and reloaded', () {
      final container = _container();
      _reader(container)
        ..setFontSize(24)
        ..setLineHeight(2.0)
        ..setMargin(32)
        ..setTheme(NovelTheme.sepia)
        ..setFontFamily(NovelFontFamily.mono)
        ..changeReadMode(NovelReadMode.doubleColumn)
        ..setKeepScreenOn(false);

      expect(
        MiruSettings.getSettingSync<String>(SettingKey.novelFontSize),
        '24.0',
      );
      expect(
        MiruSettings.getSettingSync<String>(SettingKey.novelLineHeight),
        '2.0',
      );
      expect(
        MiruSettings.getSettingSync<String>(SettingKey.novelMargin),
        '32.0',
      );
      expect(
        MiruSettings.getSettingSync<String>(SettingKey.novelTheme),
        'sepia',
      );
      expect(
        MiruSettings.getSettingSync<String>(SettingKey.novelFontFamily),
        'mono',
      );
      expect(
        MiruSettings.getSettingSync<String>(SettingKey.novelKeepScreenOn),
        'false',
      );

      // A fresh reader must come back with the same values.
      final reloaded = _state(_container());
      expect(reloaded.fontSize, 24);
      expect(reloaded.lineHeight, 2.0);
      expect(reloaded.margin, 32);
      expect(reloaded.theme, NovelTheme.sepia);
      expect(reloaded.fontFamily, NovelFontFamily.mono);
      expect(reloaded.readMode, NovelReadMode.doubleColumn);
      expect(reloaded.keepScreenOn, isFalse);
    });

    test('the sliders clamp to their range', () {
      final container = _container();
      final reader = _reader(container);

      reader
        ..setFontSize(999)
        ..setLineHeight(0.1)
        ..setMargin(0);

      expect(_state(container).fontSize, kNovelFontSizeMax);
      expect(_state(container).lineHeight, kNovelLineHeightMin);
      expect(_state(container).margin, kNovelMarginMin);

      reader
        ..setFontSize(1)
        ..setLineHeight(9)
        ..setMargin(999);

      expect(_state(container).fontSize, kNovelFontSizeMin);
      expect(_state(container).lineHeight, kNovelLineHeightMax);
      expect(_state(container).margin, kNovelMarginMax);
    });

    test('line spacing and margins snap to their slider steps', () {
      final container = _container();
      final reader = _reader(container);

      reader
        ..setLineHeight(1.53)
        ..setMargin(21);

      expect(_state(container).lineHeight, 1.5);
      expect(_state(container).margin, 22);
    });

    test('apply defaults restores every display preference', () {
      final container = _container();
      final reader = _reader(container);
      reader
        ..setFontSize(28)
        ..setTheme(NovelTheme.paper)
        ..setVolumeKeysTurnPage(true)
        ..changeReadMode(NovelReadMode.doubleColumn);

      reader.resetDisplaySettings();

      final state = _state(container);
      expect(state.fontSize, kNovelFontSizeDefault);
      expect(state.theme, NovelTheme.midnight);
      expect(state.readMode, NovelReadMode.webToon);
      expect(state.volumeKeysTurnPage, isFalse);
      expect(state.readMode, NovelReadMode.webToon);
    });

    test('an unknown persisted mode falls back instead of throwing', () {
      MiruSettings.setSettingSync(SettingKey.novelReadingMode, 'notAMode');

      expect(_state(_container()).readMode, NovelReadMode.standard);
    });
  });

  group('reading position', () {
    test('the canvas measurement publishes the chapter size', () {
      final container = _container();
      final reader = _reader(container);

      reader.setLayout(_layout(lines: 40, pages: 6));

      final state = _state(container);
      expect(state.totalLine, 40);
      expect(state.totalPage, 6);
    });

    test('history reports pages in a paged mode and lines while scrolling', () {
      final container = _container();
      final reader = _reader(container);
      reader.setLayout(_layout(lines: 40, pages: 6));

      reader.changeReadMode(NovelReadMode.standard);
      reader.setPage(3);
      expect(_state(container).historyProgress, 3);
      expect(_state(container).totalProgress, 6);
      expect(_state(container).progress, closeTo(0.5, 0.001));

      reader.changeReadMode(NovelReadMode.webToon);
      reader.setLine(20);
      expect(_state(container).historyProgress, 20);
      expect(_state(container).totalProgress, 40);
      expect(_state(container).progress, closeTo(0.5, 0.001));
    });

    test('a reflowed chapter re-clamps the position instead of dangling', () {
      final container = _container();
      final reader = _reader(container);
      reader
        ..setLayout(_layout(lines: 40, pages: 6))
        ..setLine(38);

      // The reader changes the font size, so the chapter now has fewer lines
      // than the one it is on.
      reader.setLayout(_layout(lines: 9, pages: 2));

      expect(_state(container).line, 9);
    });

    test('a paged mode turns pages and a continuous one has none', () {
      final container = _container();
      final reader = _reader(container);
      reader.setLayout(_layout(lines: 40, pages: 6));

      reader.changeReadMode(NovelReadMode.standard);
      reader.setPage(3);
      // No canvas is attached, so the page number is what the turn changed.
      reader.jumpToPage(4);
      expect(_state(container).page, 4);

      reader.changeReadMode(NovelReadMode.webToon);
      reader.setLine(20);
      final state = _state(container);
      expect(state.isPaged, isFalse);
      // The published layout still describes the paged chapter until the canvas
      // re-measures, so what the reader reports is driven by the mode, not by
      // which total happens to be non-zero.
      expect(state.totalProgress, 40);
      expect(state.historyProgress, 20);
    });

    test('progress is zero before the canvas has been measured', () {
      final state = _state(_container());

      expect(state.historyProgress, 0);
      expect(state.totalProgress, 0);
      expect(state.progress, 0);
    });
  });

  group('switching modes keeps the place', () {
    test('continuous to paged lands on the page holding that line', () {
      final container = _container();
      final reader = _reader(container);
      reader.setLayout(_layout(lines: 40, pages: 6));
      reader.changeReadMode(NovelReadMode.webToon);
      reader.setLine(16);

      reader.changeReadMode(NovelReadMode.standard);
      // The same chapter, repacked for a different mode.
      reader.setLayout(_layout(lines: 40, pages: 6));

      final state = _state(container);
      expect(state.readMode, NovelReadMode.standard);
      // The page whose start line is at or after 16 — not a stale page 1.
      final expected = _layout(
        lines: 40,
        pages: 6,
      ).pages.indexWhere((page) => page.startLine >= 16);
      expect(state.page, expected < 0 ? 6 : expected + 1);
      expect(state.page, greaterThan(1));
    });

    test('paged back to continuous lands on that line', () {
      final container = _container();
      final reader = _reader(container);
      reader.setLayout(_layout(lines: 40, pages: 6));
      reader.changeReadMode(NovelReadMode.standard);
      reader.setPage(4);

      reader.changeReadMode(NovelReadMode.webToon);
      reader.setLayout(_layout(lines: 40, pages: 0));

      final state = _state(container);
      expect(state.isPaged, isFalse);
      expect(state.page, 0);
      // Page 4 opens on line 16 in the fixture, and the line is kept so a switch
      // back to a paged mode has something to anchor on.
      expect(state.line, 16);
    });
  });

  group('bookmarks', () {
    test('toggling adds then removes only that chapter', () {
      final container = _container();
      final reader = _reader(container);
      reader.toggleBookmark(0, 2);

      expect(reader.isBookmarked(0, 2), isTrue);
      expect(reader.isBookmarked(0, 1), isFalse);

      reader.toggleBookmark(1, 5);
      expect(reader.isBookmarked(0, 2), isTrue);
      expect(reader.isBookmarked(1, 5), isTrue);

      reader.toggleBookmark(0, 2);
      expect(reader.isBookmarked(0, 2), isFalse);
      expect(reader.isBookmarked(1, 5), isTrue);
    });

    test('bookmarks survive a relaunch', () {
      final container = _container();
      _reader(container)
        ..toggleBookmark(0, 1)
        ..toggleBookmark(2, 3);

      final reloaded = _reader(_container());
      expect(reloaded.isBookmarked(0, 1), isTrue);
      expect(reloaded.isBookmarked(2, 3), isTrue);
    });
  });

  group('content', () {
    test('the chapter content is split into blocks on the way in', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final provider = novelReaderProvider(const [
        'It was November.',
        '',
        '> A letter, for me.',
        'https://example.com/plate.jpg',
      ], null);

      final blocks = parseNovelContent(container.read(provider).content);
      expect(blocks, hasLength(3));
      expect(blocks.first, isA<NovelParagraph>());
      expect(blocks[1], isA<NovelQuote>());
      expect(blocks[2], isA<NovelImage>());
    });
  });
}
