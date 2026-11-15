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
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';
import 'manga_history.dart';

/// Mirrors test/ui/features/watch/manga_reader_hud_test.dart states for the
/// catalog.
///
/// Skipped states — gesture/animation behaviour the tests drive, not rendered
/// states: centre-tap and edge-tap paging, HUD dismissal on scroll or on a
/// magnified pan, the scrubber drag / jump settling / semantics announcement,
/// the chapter Next tap (the bottom bar is interactive here), the magnified
/// page (the ReaderZoomSurface use-case carries the representative zoomed
/// state), and the brightness values (applied to the device display, never
/// painted — the no-black-scrim contract). The HUD-slide and cross-fade
/// animations play between the resting and HUD-visible use-cases.
///
/// The tests re-seed the shipped reader defaults per case because the
/// settings persist; the catalog pins the same defaults through the public
/// settings API so each use-case renders deterministically.

/// The phone surface the HUD tests pump (430×900), at the catalog's phone
/// frame canvas.
const Size _readerSurface = Size(412, 915);

final ExtensionMeta _meta = ExtensionMeta(
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

/// The test's episode fake: a fixed state and a history save that never
/// touches the backend.
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

/// The tests point the image proxy at a port nothing listens on, so a page
/// keeps loading (and showing its placeholder) forever inside the test's
/// FakeAsync zone. The catalog runs a real event loop, where a closed port
/// fails instantly and would swap the placeholder for the error child — so
/// the mirror points at a non-routable black hole instead: the request never
/// completes and the loading state the tests pump stays on screen. No request
/// reaches a real site either way.
void _ensureProxyFixture() {
  try {
    MiruRequest.proxyUrl('https://example.com/p1.png');
  } on Error {
    MiruRequest.ensureInitalized(host: 'http://10.255.255.1:9');
  }
}

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

/// Mounts a reader shell in a stage whose [MediaQuery] mirrors the tests'
/// `MediaQueryData(size:)` wrap, and runs [script] once the shell's own
/// episode-open microtask has landed.
class _ReaderStage extends StatefulWidget {
  const _ReaderStage({
    required this.container,
    required this.child,
    this.script,
  });

  final ProviderContainer container;
  final Widget child;

  /// Reader-state mutations applied after mount, the way the tests drive the
  /// provider from the widget tree.
  final void Function(ProviderContainer container)? script;

  @override
  State<_ReaderStage> createState() => _ReaderStageState();
}

class _ReaderStageState extends State<_ReaderStage> {
  @override
  void initState() {
    super.initState();
    // The shell opens its episode in a microtask after the first frame; an
    // event-loop turn later that open has landed and the script can build on
    // it, exactly as the tests' pumps do.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future(() {
        if (!mounted) return;
        widget.script?.call(widget.container);
      });
    });
  }

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
        data: const MediaQueryData(size: _readerSurface),
        child: ClipRect(child: widget.child),
      ),
    );
  }
}

WidgetbookUseCase _readerUseCase({
  required String name,
  void Function(ProviderContainer container)? script,
}) {
  return WidgetbookUseCase(
    name: name,
    builder: (context) {
      _ensureProxyFixture();
      _pinReaderDefaults();
      final params = _params();
      final container = ProviderContainer(
        overrides: [
          episodeProvider(params).overrideWith(() => _FakeEpisodes(_epState())),
        ],
      );
      return PhoneFrame(
        child: _ReaderStage(
          container: container,
          script: script,
          child: MiruMangaReader(
            value: _watch(),
            name: 'TestManga',
            meta: _meta,
            url: 'https://example.com/c1',
            epProvider: episodeProvider(params),
          ),
        ),
      );
    },
  );
}

/// The manga reader shell: the HUD test's states plus the wide-window shell
/// the history test pumps (see [mangaHistoryUseCases]).
WidgetbookComponent buildMangaReaderComponent() {
  return WidgetbookComponent(
    name: 'MiruMangaReader',
    useCases: [
      _readerUseCase(name: 'Resting — status pill only'),
      _readerUseCase(
        name: 'HUD visible (tap to reveal)',
        script: (container) =>
            container.read(mangaReaderProvider.notifier).setHudVisible(true),
      ),
      _readerUseCase(
        name: 'Last page — 12 / 12',
        script: (container) {
          final reader = container.read(mangaReaderProvider.notifier)
            ..setHudVisible(true);
          reader.setPageNumber(11);
        },
      ),
      _readerUseCase(
        name: 'Manual brightness mode',
        script: (container) {
          final reader = container.read(mangaReaderProvider.notifier)
            ..setHudVisible(true);
          reader.setBrightnessMode(MangaBrightnessMode.manual);
        },
      ),
      _readerUseCase(
        name: 'Webtoon strip',
        script: (container) => container
            .read(mangaReaderProvider.notifier)
            .changeReadMode(MangaReadMode.webToon),
      ),
      _readerUseCase(
        name: 'Webtoon strip — HUD visible',
        script: (container) {
          final reader = container.read(mangaReaderProvider.notifier)
            ..changeReadMode(MangaReadMode.webToon);
          reader.setHudVisible(true);
        },
      ),
      ...mangaHistoryUseCases(),
    ],
  );
}
