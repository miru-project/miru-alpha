import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/history/views/history_view.dart';
import 'package:miru_alpha/ui/features/history/view_models/history_view_model.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/domain/models/history.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:forui/forui.dart';

class _FakeHistoryViewModel extends HistoryViewModel {
  _FakeHistoryViewModel(this._items);
  final List<DomainHistoryItem> _items;

  @override
  Future<List<DomainHistoryItem>> build() => Future.value(_items);
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

void main() {
  testWidgets('HistoryView renders correctly', (WidgetTester tester) async {
    final historyItems = [
      DomainHistoryItem(
        id: '1',
        title: 'Test Title',
        package: 'test.package',
        progress: 0.5,
        cover: '',
        detailUrl: '',
        episodeIndex: 0,
        watchedDuration: 0,
        totalDuration: 0,
        watchedAt: DateTime.now(),
      ),
    ];

    final appState = ApplicationState(
      themeText: 'light',
      accentColor: AccentColors.zinc,
      themeData: ThemeUtils.getThemeData(FThemes.zinc.light),
      themeMode: ThemeMode.system,
      language: 'en',
    );

    final container = ProviderContainer(
      overrides: [
        historyViewModelProvider.overrideWith(() => _FakeHistoryViewModel(historyItems)),
        applicationControllerProvider.overrideWith(() => _FakeApplicationController(appState)),
      ],
    );

    addTearDown(container.dispose);

    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: FTheme(
          data: ThemeUtils.getThemeData(FThemes.zinc.light),
          child: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: MaterialApp.router(
              routerConfig: GoRouter(
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) => const HistoryView(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // HistoryView should build without throwing.
    expect(find.byType(HistoryView), findsOneWidget);
  });
}
