import 'dart:async';

import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/chapter_drawer.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_settings_sheet.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/features/watch/manga_reader_sheets_test.dart states for
/// the catalog.
///
/// Both sheets open on mount through the production `showFSheet` path (the
/// tests tap a launcher button that calls the same functions), and a button
/// reopens them after dismissal. Skipped states — reached by interacting
/// inside the sheet, exactly as the test's gestures do: the sort toggle's
/// ascending order, the filter field, and the volume menu of the drawer; and
/// behaviours: the grabber closing the sheet, the reset-to-defaults action,
/// and the brightness slider's stored-value drag (the defaults and manual
/// use-cases render the same controls at their endpoints).
///
/// The tests re-seed the shipped reader defaults per case because the
/// settings persist; the catalog pins the same defaults through the public
/// settings API so each use-case renders deterministically.

/// The sheets test's episode fake. It does not override the history save —
/// the sheets never save history.
class _FakeEpisodes extends EpisodeNotifier {
  _FakeEpisodes(this._state);

  final EpisodeNotifierState _state;

  @override
  EpisodeNotifierState build(WatchParams param) => _state;
}

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

/// Pins the reader's persisted display preferences to their shipped defaults,
/// the way the tests re-seed them for every case.
void _pinReaderDefaults() {
  void pin(String key, Object value) =>
      MiruSettings.setSettingSync(key, '$value');
  pin(SettingKey.mangaReadingMode, 'standard');
  pin(SettingKey.mangaFitMode, 'fitWidth');
  pin(SettingKey.mangaCanvasBackground, 'black');
  pin(SettingKey.mangaBrightnessMode, 'auto');
  pin(SettingKey.mangaBrightness, '100');
  pin(SettingKey.mangaPageGap, '0');
  pin(SettingKey.mangaInvertColors, 'false');
  pin(SettingKey.mangaKeepScreenOn, 'true');
  pin(SettingKey.mangaTapToTurnPage, 'true');
}

({ProviderContainer container, WatchParams params}) _sheetHarness(
  List<ExtensionEpisodeGroup> groups,
) {
  MiruSettings.seedDefaults();
  _pinReaderDefaults();
  final params = _params(groups);
  final container = ProviderContainer(
    overrides: [
      episodeProvider(params).overrideWith(
        () => _FakeEpisodes(
          EpisodeNotifierState(name: 'TestManga', epGroup: groups),
        ),
      ),
    ],
  );
  container
      .read(mangaReaderProvider.notifier)
      .open(groupIndex: 0, episodeIndex: 0, totalPage: 10);
  return (container: container, params: params);
}

/// Opens the sheet on mount through the same `showFSheet` path the HUD uses,
/// and keeps the reader session the tests' launcher watched alive.
class _SheetLauncher extends ConsumerStatefulWidget {
  const _SheetLauncher({required this.open});

  final Future<void> Function(BuildContext context) open;

  @override
  ConsumerState<_SheetLauncher> createState() => _SheetLauncherState();
}

class _SheetLauncherState extends ConsumerState<_SheetLauncher> {
  @override
  void initState() {
    super.initState();
    // The tests open the sheet by tapping a launcher button; the catalog
    // opens it on the first frame so the use-case renders the open state
    // directly.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(widget.open(context));
    });
  }

  void _reopen() => unawaited(widget.open(context));

  @override
  Widget build(BuildContext context) {
    // The tests' launcher watches the reader state to size the drawer's
    // reading progress; the same watch keeps the session alive here.
    ref.watch(mangaReaderProvider);
    return FButton(onPress: _reopen, child: const Text('Reopen sheet'));
  }
}

/// Owns the container for one sheet use-case and frames the launcher.
class _SheetStage extends StatefulWidget {
  const _SheetStage({required this.container, required this.open});

  final ProviderContainer container;
  final Future<void> Function(BuildContext context) open;

  @override
  State<_SheetStage> createState() => _SheetStageState();
}

class _SheetStageState extends State<_SheetStage> {
  @override
  void dispose() {
    widget.container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: widget.container,
      child: catalogFrame(_SheetLauncher(open: widget.open)),
    );
  }
}

WidgetbookComponent buildReaderSettingsSheetComponent() {
  return WidgetbookComponent(
    name: 'ReaderSettingsSheet',
    useCases: [
      WidgetbookUseCase(
        name: 'Open — shipped defaults',
        builder: (context) {
          final harness = _sheetHarness([_group(4)]);
          return _SheetStage(
            container: harness.container,
            open: (context) => showReaderSettingsSheet(
              context,
              mangaProvider: mangaReaderProvider,
            ),
          );
        },
      ),
      WidgetbookUseCase(
        name: 'Open — manual brightness selected',
        builder: (context) {
          final harness = _sheetHarness([_group(4)]);
          // The test taps the manual segment inside the open sheet; the
          // settled state is seeded here, on the same provider the sheet
          // reads.
          harness.container
              .read(mangaReaderProvider.notifier)
              .setBrightnessMode(MangaBrightnessMode.manual);
          return _SheetStage(
            container: harness.container,
            open: (context) => showReaderSettingsSheet(
              context,
              mangaProvider: mangaReaderProvider,
            ),
          );
        },
      ),
    ],
  );
}

WidgetbookComponent buildChapterDrawerComponent() {
  return WidgetbookComponent(
    name: 'ChapterDrawer',
    useCases: [
      WidgetbookUseCase(
        name: 'Open — newest first, Reading badge',
        builder: (context) {
          final groups = [_group(4), _group(3, title: 'Volume 2')];
          final harness = _sheetHarness(groups);
          return _SheetStage(
            container: harness.container,
            open: (context) => showChapterDrawer(
              context,
              epProvider: episodeProvider(harness.params),
              openPosition: harness.container.read(mangaReaderProvider).page,
              openTotal: harness.container.read(mangaReaderProvider).totalPage,
            ),
          );
        },
      ),
      WidgetbookUseCase(
        name: 'Empty chapter list',
        builder: (context) {
          final harness = _sheetHarness(const []);
          harness.container
              .read(mangaReaderProvider.notifier)
              .open(groupIndex: 0, episodeIndex: 0, totalPage: 0);
          return _SheetStage(
            container: harness.container,
            open: (context) => showChapterDrawer(
              context,
              epProvider: episodeProvider(harness.params),
              openPosition: harness.container.read(mangaReaderProvider).page,
              openTotal: harness.container.read(mangaReaderProvider).totalPage,
            ),
          );
        },
      ),
    ],
  );
}
