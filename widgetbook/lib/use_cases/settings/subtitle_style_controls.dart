/// The subtitle settings surface, mounted the way the catalog's app-page
/// reviews mount everything else: the REAL page from `lib/` over seeded
/// provider fakes, never a fixture-built stand-in (user directive: the
/// catalog calls the page the app ships, it does not migrate the app into the
/// catalog).
///
/// Two stories: the Settings → Player pane, and the player's own subtitle
/// tab with its track list plus the Appearance & Styling drill-down. Both are
/// the shipping widgets; nothing here re-implements a row.
library;

import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb;
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';
import 'package:miru_alpha/ui/features/setting/setting_player.dart';
import 'package:miru_alpha/ui/features/setting/widget/setting_scaffold.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/side_settings_menu.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';

const _url = 'https://example.com/daemons';

ExtensionMeta _meta() => ExtensionMeta(
  name: 'ExampleA',
  version: '2.0.0',
  author: 'test',
  license: 'MIT',
  lang: 'en',
  packageName: 'test.pkg',
  webSite: 'https://example.com',
  description: 'test provider',
  tags: const [],
  api: 'v2',
  type: ExtensionType.bangumi,
);

WatchParams _param() => WatchParams(
  meta: _meta(),
  type: ExtensionType.bangumi,
  url: '$_url/ep1',
  selectedGroupIndex: 0,
  selectedEpisodeIndex: 0,
  name: 'Daemons of the Shadow Realm',
  detailImageUrl: '',
  detailUrl: _url,
  savePath: null,
  epGroup: [
    ExtensionEpisodeGroup(
      title: 'Season 1',
      urls: [ExtensionEpisode(name: 'Episode 1', url: '$_url/ep1')],
    ),
  ],
);

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._seed);

  final ApplicationState _seed;

  @override
  ApplicationState build() => _seed;
}

/// Serves the subtitle state the panel reads; the controller is built and
/// never initialized, so no platform channel is touched.
class _FakeVideoPlayer extends VideoPlayerNotifier {
  _FakeVideoPlayer(this.kind);

  final SubtitleTrackKind kind;

  @override
  VideoPlayerTickState build(
    String? mediaUrl, {
    List<pb.ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    Map<String, String>? headers,
    Size? initialRatio,
    ExtensionBangumiWatchTorrent? torrent,
    String? localPath,
    pb.ExtensionWatch? v2watch,
    Map<String, String> qualityMap = const {},
  }) {
    vidController = VideoPlayerController.networkUrl(Uri.parse(_url));
    return VideoPlayerTickState(
      duration: const Duration(minutes: 24),
      settingsTab: 2,
      subtitleTrackKind: kind,
      subtitlesRaw: [
        pb.ExtensionBangumiWatchSubtitle(
          title: 'English',
          language: 'en',
          url: '$_url/sub.ass',
        ),
        pb.ExtensionBangumiWatchSubtitle(
          title: 'Indonesian',
          language: 'id',
          url: '$_url/sub2.vtt',
        ),
      ],
    );
  }
}

ProviderContainer _container(SubtitleTrackKind kind) => ProviderContainer(
  overrides: [
    applicationControllerProvider.overrideWith(
      () => _FakeApplicationController(
        ApplicationState(
          themeText: 'dark',
          baseColor: 'zinc',
          primaryColor: 'zinc',
          themeData: ThemeUtils.getThemeData(MiruThemes.zinc.dark),
          themeMode: ThemeMode.dark,
          language: 'en',
        ),
      ),
    ),
    videoPlayerProvider(
      _url,
    ).overrideWith(() => _FakeVideoPlayer(kind)),
  ],
);

/// The same frame the app-page stories use: seeded settings, the desktop
/// theme and a router whose unknown paths render inert placeholders.
///
/// [canvas] pins the story to the surface's own footprint instead of letting
/// it stretch over the whole 1600×900 viewport: a settings menu is judged at
/// menu width, and a panel floating in an empty desktop reads as stretched
/// gutters rather than density. The rest of the canvas stays neutral.
Widget _frame(
  ProviderContainer container,
  Widget child, {
  Size? canvas,
}) {
  MiruSettings.seedDefaults();
  // Pin only the WIDTH. The catalog's workbench area is shorter than the app
  // window, so a fixed height here overflows the story slot and paints
  // Flutter's yellow overflow banner across the panel. Taking the height the
  // canvas actually offers keeps the in-app width honest without inventing a
  // size the harness cannot honour.
  final bounded = canvas == null
      ? child
      : Center(
          child: LayoutBuilder(
            builder: (context, constraints) => DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: MiruThemes.zinc.dark.desktop.colors.border,
                ),
              ),
              child: SizedBox(
                width: canvas.width.clamp(0.0, constraints.maxWidth),
                height: constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : canvas.height,
                child: child,
              ),
            ),
          ),
        );
  return UncontrolledProviderScope(
    container: container,
    child: FTheme(
      data: MiruThemes.zinc.dark.desktop,
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            // A bare GoRoute child has NO Material ancestor: every Text under
            // it renders with Flutter's yellow double "missing Material"
            // underline. Scaffold supplies the Material + background the real
            // page sits on inside the app.
            GoRoute(
              path: '/',
              builder: (_, _) => Scaffold(
                backgroundColor: const Color(0xFF0B0B0C),
                body: bounded,
              ),
            ),
            for (final path in const ['/search', '/extension', '/settings/x'])
              GoRoute(
                path: path,
                builder: (_, _) => Scaffold(body: Center(child: Text(path))),
              ),
          ],
        ),
      ),
    ),
  );
}

/// The player's docked settings panel at its real width — no full-bleed
/// video surface behind it, because this story judges the panel itself.
/// The player's docked settings panel at its shipping width. The app pins it
/// to 400px on desktop (media width x 0.3 on mobile) in `video_player.dart`;
/// the story uses the desktop figure because this is the desktop surface.
Widget _dock() => SideSettingsMenu(
  vidPr: videoPlayerProvider(_url),
  epProvdier: episodeProvider(_param()),
  width: _dockWidth,
  meta: _meta(),
);

const double _dockWidth = 400;

List<WidgetbookComponent> buildSubtitleSettingsComponents() => [
  WidgetbookComponent(
    name: 'Subtitle settings · desktop (app)',
    useCases: [
      WidgetbookUseCase(
        name: 'Settings → Player (global pane)',
        builder: (context) => _frame(
          _container(SubtitleTrackKind.text),
          // In-app geometry: the desktop settings page is a 200px section
          // sidebar beside the content pane inside the app window, so the
          // story shows the content pane at the width it is given there.
          const SettingScaffold(
            title: 'settings.player.name',
            child: SettingPlayer(),
          ),
          canvas: const Size(880, 800),
        ),
      ),
      WidgetbookUseCase(
        name: 'Player → Subtitle tab · ASS track',
        builder: (context) => _frame(
          _container(SubtitleTrackKind.ass),
          _dock(),
          canvas: const Size(400, 800),
        ),
      ),
      WidgetbookUseCase(
        name: 'Player → Subtitle tab · text track',
        builder: (context) => _frame(
          _container(SubtitleTrackKind.text),
          _dock(),
          canvas: const Size(400, 800),
        ),
      ),
    ],
  ),
];
