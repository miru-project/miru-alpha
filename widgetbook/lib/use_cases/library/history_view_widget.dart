/// Mirrors test/ui/features/history/history_view_widget_test.dart states
/// for the catalog.
///
/// skipped: the tap-resolves-missing-extension assertion — a runtime
/// behaviour (the watch session's toast) the catalog shows live when the
/// tile in the "extension gone" use-case is tapped; there is no separate
/// visual state to mount. Long-press opens the actions sheet (watch /
/// detail / delete) interactively. i18n keys render raw here — expected.
library;

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/ui/features/history/views/history_view.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

WidgetbookComponent buildHistoryViewComponent() {
  return WidgetbookComponent(
    name: 'HistoryView',
    useCases: [
      WidgetbookUseCase(name: 'Empty — no history', builder: _emptyView),
      WidgetbookUseCase(
        name: 'Grid — one history row (50% progress)',
        builder: _oneHistoryRow,
      ),
      WidgetbookUseCase(
        name: 'Extension gone — raw-key subtitle (tap/long-press safe)',
        builder: _extensionGone,
      ),
    ],
  );
}

class _FakeHistoryPageNotifier extends HistoryPageNotifier {
  _FakeHistoryPageNotifier(this._state);
  final HistoryPageState _state;

  @override
  HistoryPageState build() => _state;
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

class _FakeExtensionPageNotifier extends ExtensionPageNotifier {
  _FakeExtensionPageNotifier(this._state);
  final ExtensionPageModel _state;

  @override
  ExtensionPageModel build() => _state;
}

ApplicationState _appState() => ApplicationState(
  themeText: 'light',
  baseColor: 'zinc',
  primaryColor: 'zinc',
  themeData: ThemeUtils.getThemeData(MiruThemes.zinc.light),
  themeMode: ThemeMode.system,
  language: 'en',
);

History _history(int id, String title) => History(
  package: 'missing.pkg',
  url: 'https://episode/$id',
  detailUrl: 'https://detail/$id',
  type: 'bangumi',
  episodeGroupId: 0,
  episodeId: 0,
  title: title,
  episodeTitle: 'EP $id',
  progress: 50,
  totalProgress: 100,
  date: DateTime(2026, 1, 1),
);

/// The test's `pumpHistory` wiring: empty extension list (a history row
/// that outlived its extension), the app controller, and the `/watch` +
/// `/search/single/detail` escape routes the tap/long-press paths use.
Widget _historyView(BuildContext context, List<History> items) {
  MiruSettings.seedDefaults();
  final container = ProviderContainer(
    overrides: [
      historyPageProvider.overrideWith(
        () => _FakeHistoryPageNotifier(
          HistoryPageState(history: items, filteredHistory: items),
        ),
      ),
      extensionPageProvider.overrideWith(
        () => _FakeExtensionPageNotifier(
          ExtensionPageModel(
            fetchedRepo: const [],
            extensionList: const [],
            installedPackages: const [],
            metaData: const [],
            sourceIndex: 0,
          ),
        ),
      ),
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
              builder: (context, state) => const HistoryView(),
            ),
            GoRoute(
              path: '/watch',
              builder: (context, state) => const SizedBox(),
            ),
            GoRoute(
              path: '/search/single/detail',
              builder: (context, state) => const SizedBox(),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _emptyView(BuildContext context) => _historyView(context, const []);

Widget _oneHistoryRow(BuildContext context) {
  final histories = [
    History(
      package: 'test.package',
      url: 'https://example.com/1',
      detailUrl: 'https://example.com/1',
      type: 'manga',
      episodeGroupId: 0,
      episodeId: 0,
      title: 'Test History',
      episodeTitle: 'Ep 1',
      progress: 5,
      totalProgress: 10,
      date: DateTime.now(),
    ),
  ];
  return _historyView(context, histories);
}

Widget _extensionGone(BuildContext context) =>
    _historyView(context, [_history(1, 'Episode One')]);
