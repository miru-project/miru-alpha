import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/novel_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_content.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/widget/novel_reading_view.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/features/watch/novel_reading_view_test.dart states for
/// the catalog.
///
/// Skipped states — not constructible or not rendered: the safe-area inset
/// variants (they fake the view's padding via FakeViewPadding), the tap-zone
/// report (pointer behaviour — the canvas is tappable here), and the
/// swipe-reports-page case (a gesture). The mode × font-size cross product is
/// represented by the paged 12px use-case; 18px is the paged default. Each
/// paper is its own use-case, mirroring the test's one-test-per-paper loop.

/// The phone canvas the tests measure against, at the catalog's phone frame
/// size.
const Size _novelSurface = Size(412, 915);

/// A chapter long enough to page through several times, as the extension
/// would return it: a flat list of strings.
List<String> _chapter({int paragraphs = 40}) => [
  for (var i = 0; i < paragraphs; i++)
    'It was November. Paragraph $i of the chapter goes on at some length, '
        'long enough that a narrow column has to wrap it onto several lines '
        'so the pagination pass has something to measure and pack.',
  '> A letter, for me. That was something of an event.',
];

/// The test's reader fake: pins the session's mode and paper on top of the
/// real build, so the position listeners stay attached.
class _FakeNovelReader extends NovelReader {
  _FakeNovelReader(this._mode, this._theme);

  final NovelReadMode _mode;
  final NovelTheme _theme;

  @override
  NovelReaderState build() =>
      super.build().copyWith(readMode: _mode, theme: _theme);
}

ProviderContainer _novelHarness({
  NovelReadMode mode = NovelReadMode.webToon,
  NovelTheme theme = NovelTheme.midnight,
  double fontSize = kNovelFontSizeDefault,
}) {
  // The tests re-seed the shipped defaults per case because the settings
  // persist; the catalog pins the typography keys it reads instead.
  MiruSettings.seedDefaults();
  MiruSettings.setSettingSync(SettingKey.novelReadingMode, mode.name);
  MiruSettings.setSettingSync(SettingKey.novelTheme, theme.name);
  MiruSettings.setSettingSync(
    SettingKey.novelFontSize,
    '$kNovelFontSizeDefault',
  );
  final container = ProviderContainer(
    overrides: [
      novelReaderProvider.overrideWith(() => _FakeNovelReader(mode, theme)),
    ],
  );
  if (fontSize != kNovelFontSizeDefault) {
    container.read(novelReaderProvider.notifier).setFontSize(fontSize);
  }
  return container;
}

/// Mounts the canvas at the phone surface, with the [MediaQuery] the tests'
/// harness supplies (the paged modes measure their pages against it).
class _NovelStage extends StatefulWidget {
  const _NovelStage({required this.container, required this.child});

  final ProviderContainer container;
  final Widget child;

  @override
  State<_NovelStage> createState() => _NovelStageState();
}

class _NovelStageState extends State<_NovelStage> {
  @override
  void dispose() {
    widget.container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: widget.container,
      child: MediaQuery(
        data: const MediaQueryData(size: _novelSurface),
        child: ClipRect(child: widget.child),
      ),
    );
  }
}

WidgetbookUseCase _novelUseCase({
  required String name,
  NovelReadMode mode = NovelReadMode.webToon,
  NovelTheme theme = NovelTheme.midnight,
  double fontSize = kNovelFontSizeDefault,
  List<String>? content,
}) {
  return WidgetbookUseCase(
    name: name,
    builder: (context) {
      final container = _novelHarness(
        mode: mode,
        theme: theme,
        fontSize: fontSize,
      );
      return PhoneFrame(
        child: _NovelStage(
          container: container,
          child: NovelReadingView(
            blocks: parseNovelContent(content ?? _chapter()),
            novelProvider: novelReaderProvider,
            onTapZone: (_) {},
          ),
        ),
      );
    },
  );
}

WidgetbookComponent buildNovelReadingViewComponent() {
  return WidgetbookComponent(
    name: 'NovelReadingView',
    useCases: [
      _novelUseCase(name: 'Continuous (webtoon) mode'),
      _novelUseCase(
        name: 'Paged (standard) mode',
        mode: NovelReadMode.standard,
      ),
      _novelUseCase(
        name: 'Double-column mode',
        mode: NovelReadMode.doubleColumn,
      ),
      _novelUseCase(name: 'Paper — charcoal', theme: NovelTheme.charcoal),
      _novelUseCase(name: 'Paper — sepia', theme: NovelTheme.sepia),
      _novelUseCase(name: 'Paper — paper stock', theme: NovelTheme.paper),
      _novelUseCase(
        name: 'Small type (12px, paged)',
        mode: NovelReadMode.standard,
        fontSize: 12,
      ),
      _novelUseCase(
        name: 'Quotation card',
        content: const ['Opening prose.', '> A letter, for me.'],
      ),
    ],
  );
}
