/// Mirrors test/ui/features/download/download_view_widget_test.dart states
/// for the catalog.
///
/// skipped: the test's own assertion is only "builds without throwing" for
/// an empty download list — mirrored below as the empty state. The test
/// overrides `downloadViewModelProvider` too; this fake set is kept intact
/// even though the view reads `downloadProvider`, so the fixture matches
/// the test's harness. The empty render needs a `downloadProvider` fake
/// (the real notifier dials gRPC from `build`), which the sibling download
/// tests already model. i18n keys render raw here — expected.
library;

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/domain/models/download.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/ui/features/download/views/download_view.dart';
import 'package:miru_alpha/ui/features/download/view_models/download_view_model.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent buildDownloadViewComponent() {
  return WidgetbookComponent(
    name: 'DesktopDownloadView',
    useCases: [
      WidgetbookUseCase(
        name: 'Empty — no active downloads',
        builder: _emptyView,
      ),
    ],
  );
}

class _FakeDownloadViewModel extends DownloadViewModel {
  _FakeDownloadViewModel(this._downloads);
  final List<DomainDownload> _downloads;

  @override
  Future<List<DomainDownload>> build() => Future.value(_downloads);
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
  themeMode: ThemeMode.system,
  language: 'en',
);

Widget _emptyView(BuildContext context) {
  final container = ProviderContainer(
    overrides: [
      downloadViewModelProvider.overrideWith(
        () => _FakeDownloadViewModel(<DomainDownload>[]),
      ),
      downloadProvider.overrideWith(
        () => _FakeDownloadNotifier(DownloadState()),
      ),
      applicationControllerProvider.overrideWith(
        () => _FakeApplicationController(_appState()),
      ),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DesktopDownloadView(),
          ),
        ],
      ),
    ),
  );
}
