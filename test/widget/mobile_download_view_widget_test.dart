import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/ui/features/download/views/mobile_download_view.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

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

Widget _scaffoldFor(Widget child) => FTheme(
  data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
  child: MediaQuery(
    data: const MediaQueryData(size: Size(400, 800)),
    child: MaterialApp.router(
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (context, state) => child)],
      ),
    ),
  ),
);

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);

  Future<void> pumpView(WidgetTester tester, DownloadState state) async {
    final container = ProviderContainer(
      overrides: [
        downloadProvider.overrideWith(() => _FakeDownloadNotifier(state)),
        applicationControllerProvider.overrideWith(
          () => _FakeApplicationController(_appState()),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Width 400 < the lg breakpoint, so the scaffold renders its mobile layout
    // (the same path that hit the unbounded RenderFlex error).
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _scaffoldFor(const MobileDownloadView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'renders widget with filter pill bar (no TabBarView regression)',
    (tester) async {
      await pumpView(tester, DownloadState());

      expect(find.byType(MobileDownloadView), findsOneWidget);
      // "All" pill icon + the EmptyState icon (empty DownloadState) both use
      // FLucideIcons.download.
      expect(find.byIcon(FLucideIcons.download), findsNWidgets(2));
      expect(find.byIcon(FLucideIcons.clapperboard), findsOneWidget);
      expect(find.byIcon(FLucideIcons.bookOpen), findsOneWidget);
      expect(find.byIcon(FLucideIcons.scrollText), findsOneWidget);
      expect(find.byType(TabBarView), findsNothing);
      expect(find.text('download.all_downloads'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('renders active and completed download lists', (tester) async {
    await pumpView(
      tester,
      DownloadState(
        active: [
          proto.DownloadProgress(
            taskId: 1,
            title: 'Active Task A',
            progress: 10,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
            package: 'test.pkg',
            key: 'ep1',
            mediaType: proto.DownloadMediaType.hls,
          ),
        ],
        history: [
          proto.Download(
            id: 2,
            package: 'test.pkg',
            title: 'Finished Episode B',
            status: proto.DownloadStatus.COMPLETED,
            savePath: '/tmp/example.mp4',
            detailUrl: 'https://example.com/b',
          ),
        ],
      ),
    );

    expect(find.text('Active Task A'), findsOneWidget);
    expect(find.text('Finished Episode B'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
