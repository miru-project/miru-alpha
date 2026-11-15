/// Mirrors test/ui/features/download/mobile_download_view_widget_test.dart
/// states for the catalog.
///
/// The delete-confirmation state of the test asserts a NEGATIVE (no dialog
/// on the active screen) — visually the same one-active-task fixture as the
/// "active task" use-case, so it is folded into that fixture. i18n keys
/// render raw here (no delegates — expected); the view reads the download
/// path setting at build, so builders seed the shipped defaults.
library;

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/ui/features/download/views/mobile_download_view.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

WidgetbookComponent buildMobileDownloadViewComponent() {
  return WidgetbookComponent(
    name: 'MobileDownloadView',
    useCases: [
      WidgetbookUseCase(
        name: 'Empty — filter pills + empty state',
        builder: _emptyView,
      ),
      WidgetbookUseCase(
        name: 'Active task — finished stays on the history page',
        builder: _oneActiveTask,
      ),
      WidgetbookUseCase(
        name: 'Two active tasks — reorderable list',
        builder: _twoActiveTasks,
      ),
      WidgetbookUseCase(
        name: 'Failed task — error reason',
        builder: _failedTask,
      ),
    ],
  );
}

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

proto.DownloadProgress _task(
  int id,
  String title,
  int progress,
  proto.DownloadStatus status, {
  String error = '',
}) => proto.DownloadProgress()
  ..taskId = id
  ..title = title
  ..progress = progress
  ..total = 100
  ..status = status
  ..package = 'test.pkg'
  ..key = 'ep$id'
  ..mediaType = proto.DownloadMediaType.hls
  ..error = error;

/// Width 400 < the lg breakpoint, so the scaffold renders its mobile
/// layout — [PhoneFrame] pins that width the same way the test's
/// `setSurfaceSize(400, 800)` does.
Widget _view(BuildContext context, DownloadState state) {
  MiruSettings.seedDefaults();
  final container = ProviderContainer(
    overrides: [
      downloadProvider.overrideWith(() => _FakeDownloadNotifier(state)),
      applicationControllerProvider.overrideWith(
        () => _FakeApplicationController(_appState()),
      ),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: PhoneFrame(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const MobileDownloadView(),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _emptyView(BuildContext context) => _view(context, DownloadState());

Widget _oneActiveTask(BuildContext context) {
  return _view(
    context,
    DownloadState(
      active: [_task(1, 'Active Task A', 10, proto.DownloadStatus.DOWNLOADING)],
      history: [
        proto.Download()
          ..id = 2
          ..package = 'test.pkg'
          ..title = 'Finished Episode B'
          ..status = proto.DownloadStatus.COMPLETED
          ..savePath = '/tmp/example.mp4'
          ..detailUrl = 'https://example.com/b',
      ],
    ),
  );
}

Widget _twoActiveTasks(BuildContext context) {
  return _view(
    context,
    DownloadState(
      active: [
        _task(1, 'Task One', 10, proto.DownloadStatus.DOWNLOADING),
        _task(2, 'Task Two', 20, proto.DownloadStatus.DOWNLOADING),
      ],
    ),
  );
}

Widget _failedTask(BuildContext context) {
  return _view(
    context,
    DownloadState(
      active: [
        _task(
          9,
          'Broken Task',
          30,
          proto.DownloadStatus.FAILED,
          error: 'segment missing on disk',
        ),
      ],
      hasMore: false,
    ),
  );
}
