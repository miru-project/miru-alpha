/// Mirrors test/ui/features/download/download_history_page_test.dart states
/// for the catalog.
///
/// [MobileFinishedDownloadSection] renders only `completed` rows — the
/// in-flight and failed fixtures of the test are mirrored by their absence
/// in the "finished only" use-case. The delete-confirmation flow is a
/// dialog: tap the trash icon in the catalog to reach it. i18n keys render
/// raw here (no delegates — expected).
library;

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/ui/features/download/widget/mobile_finish_download.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

WidgetbookComponent buildDownloadHistoryPageComponent() {
  return WidgetbookComponent(
    name: 'MobileFinishedDownloadSection',
    useCases: [
      WidgetbookUseCase(
        name: 'History rows — end-of-list note (3 completed)',
        builder: _rowsEndOfList,
      ),
      WidgetbookUseCase(
        name: 'Finished only — in-flight/failed filtered out',
        builder: _finishedOnly,
      ),
      WidgetbookUseCase(
        name: 'Paginated — 30 rows, scrolling loads more',
        builder: _paginatedList,
      ),
      WidgetbookUseCase(
        name: 'Delete confirmation — tap the trash icon',
        builder: _deleteConfirm,
      ),
    ],
  );
}

/// Records pagination calls so the scroll trigger works without a live
/// gRPC backend.
class _RecordingDownloadNotifier extends DownloadNotifier {
  _RecordingDownloadNotifier(this._state);

  final DownloadState _state;

  int loadMoreCalls = 0;

  @override
  AsyncValue<DownloadState> build() => AsyncData(_state);

  @override
  Future<void> loadMoreHistory() async {
    loadMoreCalls++;
  }
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

proto.Download _completed(int id) => proto.Download()
  ..id = id
  ..package = 'test.pkg'
  ..title = 'Episode $id'
  ..status = proto.DownloadStatus.COMPLETED
  ..savePath = '/tmp/episode-$id.mp4'
  ..detailUrl = 'https://example.com/$id';

proto.Download _other(int id, String title, proto.DownloadStatus status) =>
    proto.Download()
      ..id = id
      ..package = 'test.pkg'
      ..title = title
      ..status = status
      ..savePath = '/tmp/$id.mp4'
      ..detailUrl = 'https://example.com/$id';

DownloadState _stateWithHistory({required int count, required bool hasMore}) {
  return DownloadState(
    history: [for (var i = 1; i <= count; i++) _completed(i)],
    hasMore: hasMore,
  );
}

Widget _page(BuildContext context, DownloadState state) {
  MiruSettings.seedDefaults();
  final container = ProviderContainer(
    overrides: [
      downloadProvider.overrideWith(() => _RecordingDownloadNotifier(state)),
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
              builder: (context, s) => const MobileFinishedDownloadSection(),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _rowsEndOfList(BuildContext context) =>
    _page(context, _stateWithHistory(count: 3, hasMore: false));

Widget _finishedOnly(BuildContext context) {
  return _page(
    context,
    DownloadState(
      history: [
        _completed(1),
        _other(2, 'Still Downloading', proto.DownloadStatus.DOWNLOADING),
        _other(3, 'Gave Up', proto.DownloadStatus.FAILED),
      ],
      hasMore: false,
    ),
  );
}

Widget _paginatedList(BuildContext context) =>
    _page(context, _stateWithHistory(count: 30, hasMore: true));

Widget _deleteConfirm(BuildContext context) =>
    _page(context, _stateWithHistory(count: 1, hasMore: false));
