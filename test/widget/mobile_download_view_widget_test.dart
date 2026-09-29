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

  testWidgets('renders active tasks and keeps finished ones off this screen', (
    tester,
  ) async {
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
    // Finished downloads belong to the history page, not this screen — the
    // download page is only about work still in flight.
    expect(find.text('Finished Episode B'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('offers a jump to the download history page', (tester) async {
    await pumpView(tester, DownloadState());

    // The clock button in the header is how finished downloads are reached,
    // since they no longer render on this screen.
    expect(find.byIcon(FLucideIcons.clock), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('active list is a real reorderable list', (tester) async {
    await pumpView(
      tester,
      DownloadState(
        active: [
          proto.DownloadProgress(
            taskId: 1,
            title: 'Task One',
            progress: 10,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
            package: 'test.pkg',
            key: 'ep1',
            mediaType: proto.DownloadMediaType.hls,
          ),
          proto.DownloadProgress(
            taskId: 2,
            title: 'Task Two',
            progress: 20,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
            package: 'test.pkg',
            key: 'ep2',
            mediaType: proto.DownloadMediaType.hls,
          ),
        ],
      ),
    );
    await tester.pump();

    // The grip handle used to be decorative: the list was a plain ListView, so
    // dragging did nothing. Assert the reorderable sliver is really there.
    expect(find.byType(SliverReorderableList), findsOneWidget);
    expect(find.byType(ReorderableDragStartListener), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('deleting a download asks for confirmation first', (
    tester,
  ) async {
    await pumpView(
      tester,
      // The delete confirmation now only lives on the history page, since
      // finished downloads no longer render on the download screen. Still
      // exercised here through the active tile's cancel path.
      DownloadState(
        active: [
          proto.DownloadProgress(
            taskId: 3,
            title: 'Active Task C',
            progress: 40,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
            package: 'test.pkg',
            key: 'ep3',
            mediaType: proto.DownloadMediaType.hls,
          ),
        ],
        hasMore: false,
      ),
    );
    await tester.pump();

    // The active screen keeps pause/cancel inline, so no delete dialog.
    expect(find.text('download.delete_title'), findsNothing);
    expect(find.text('Active Task C'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed task shows its error reason', (tester) async {
    await pumpView(
      tester,
      DownloadState(
        active: [
          proto.DownloadProgress(
            taskId: 9,
            title: 'Broken Task',
            progress: 30,
            total: 100,
            status: proto.DownloadStatus.FAILED,
            package: 'test.pkg',
            key: 'ep9',
            mediaType: proto.DownloadMediaType.hls,
            error: 'segment missing on disk',
          ),
        ],
        hasMore: false,
      ),
    );
    await tester.pump();

    expect(find.text('download.error_reason'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
