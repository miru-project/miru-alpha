/// Mirrors test/ui/features/download/desktop_download_page_test.dart states
/// for the catalog.
///
/// Desktop pages render bare — the viewport addon picks the size. Both
/// widgets read `MiruSettings.getSettingSync` (the header's download path,
/// the notifier's max-concurrent), so every builder seeds the settings cache
/// with the shipped defaults — the same call the app's bootstrap makes. i18n
/// keys render raw here (no delegates — expected).
library;

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/ui/features/download/download_page.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent buildDesktopDownloadPageComponent() {
  return WidgetbookComponent(
    name: 'DownloadPageDesktopLayout',
    useCases: [
      WidgetbookUseCase(
        name: 'Pinned header — one active task (downloading)',
        builder: _oneActiveTask,
      ),
      WidgetbookUseCase(
        name: 'Active tasks — downloading, paused, queued (reorderable)',
        builder: _threeActiveTasks,
      ),
      WidgetbookUseCase(
        name: 'Empty — no active tasks (empty history note)',
        builder: _noActiveTasks,
      ),
    ],
  );
}

WidgetbookComponent buildDesktopFinishedDownloadComponent() {
  return WidgetbookComponent(
    name: 'DesktopFinishedDownloadSection',
    useCases: [
      WidgetbookUseCase(
        name: 'History — completed + missing-file entries',
        builder: _historyEntries,
      ),
      WidgetbookUseCase(
        name: 'Empty — no download history',
        builder: _emptyHistory,
      ),
    ],
  );
}

/// A path that does not exist, used to exercise the "hide missing files"
/// logic the same way the test does.
const String _missingPath = '/tmp/miru_test_does_not_exist_xyz/file.mp4';

/// A save path the section only ever displays (no catalog use-case touches
/// the filesystem — the reveal button opens the file manager on tap).
const String _presentPath = '/tmp/miru_demo_downloads/finished-episode-a.mp4';

class _FakeDownloadNotifier extends DownloadNotifier {
  _FakeDownloadNotifier(this._state);
  final DownloadState _state;

  @override
  AsyncValue<DownloadState> build() => AsyncData(_state);
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

ApplicationState _appState() => ApplicationState(
  themeText: 'light',
  baseColor: 'zinc',
  primaryColor: 'zinc',
  themeData: ThemeUtils.getThemeData(MiruThemes.zinc.light),
  themeMode: ThemeMode.light,
  language: 'en',
);

DownloadState _buildState({
  List<proto.DownloadProgress> active = const [],
  List<proto.Download> history = const [],
  bool hasMore = false,
}) => DownloadState(active: active, history: history, hasMore: hasMore);

proto.DownloadProgress _task(
  int id,
  String title,
  int progress,
  proto.DownloadStatus status,
) => proto.DownloadProgress()
  ..taskId = id
  ..title = title
  ..progress = progress
  ..total = 100
  ..status = status;

proto.Download _historyEntry(
  int id,
  String title,
  proto.DownloadStatus status,
  String savePath,
) => proto.Download()
  ..id = id
  ..package = 'test.pkg'
  ..title = title
  ..status = status
  ..savePath = savePath
  ..detailUrl = 'https://example.com/$id';

/// The test's `_scaffoldFor`: a fresh GoRouter carrying the page, under the
/// catalog's own FTheme.
Widget _routed(Widget child) {
  return MaterialApp.router(
    routerConfig: GoRouter(
      routes: [GoRoute(path: '/', builder: (context, state) => child)],
    ),
  );
}

Widget _scoped(BuildContext context, Widget child, DownloadState state) {
  MiruSettings.seedDefaults();
  final container = ProviderContainer(
    overrides: [
      downloadProvider.overrideWith(() => _FakeDownloadNotifier(state)),
      applicationControllerProvider.overrideWith(
        () => _FakeApplicationController(_appState()),
      ),
    ],
  );
  return UncontrolledProviderScope(container: container, child: _routed(child));
}

Widget _oneActiveTask(BuildContext context) {
  return _scoped(
    context,
    const DownloadPageDesktopLayout(),
    _buildState(
      active: [_task(1, 'Episode 1', 50, proto.DownloadStatus.DOWNLOADING)],
    ),
  );
}

Widget _threeActiveTasks(BuildContext context) {
  return _scoped(
    context,
    const DownloadPageDesktopLayout(),
    _buildState(
      active: [
        _task(1, 'A', 10, proto.DownloadStatus.DOWNLOADING),
        _task(2, 'B', 20, proto.DownloadStatus.PAUSED),
        _task(3, 'C', 30, proto.DownloadStatus.QUEUED),
      ],
    ),
  );
}

Widget _noActiveTasks(BuildContext context) {
  return _scoped(context, const DownloadPageDesktopLayout(), _buildState());
}

Widget _historyEntries(BuildContext context) {
  return _scoped(
    context,
    const DesktopFinishedDownloadSection(),
    _buildState(
      history: [
        _historyEntry(
          10,
          'Finished Episode A',
          proto.DownloadStatus.COMPLETED,
          _presentPath,
        ),
        _historyEntry(
          11,
          'Missing Episode B',
          proto.DownloadStatus.FAILED,
          _missingPath,
        ),
      ],
    ),
  );
}

Widget _emptyHistory(BuildContext context) {
  return _scoped(
    context,
    const DesktopFinishedDownloadSection(),
    _buildState(),
  );
}
