import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/ui/features/download/widget/mobile_finish_download.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// Records pagination calls so the scroll trigger can be asserted without a
/// live gRPC backend.
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

proto.Download _completed(int id) => proto.Download(
  id: id,
  package: 'test.pkg',
  title: 'Episode $id',
  status: proto.DownloadStatus.COMPLETED,
  savePath: '/tmp/episode-$id.mp4',
  detailUrl: 'https://example.com/$id',
);

DownloadState _stateWithHistory({required int count, required bool hasMore}) {
  return DownloadState(
    history: [for (var i = 1; i <= count; i++) _completed(i)],
    hasMore: hasMore,
  );
}

Future<void> _pumpHistoryPage(
  WidgetTester tester, {
  required _RecordingDownloadNotifier notifier,
}) async {
  final container = ProviderContainer(
    overrides: [
      downloadProvider.overrideWith(() => notifier),
      applicationControllerProvider.overrideWith(
        () => _FakeApplicationController(_appState()),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.binding.setSurfaceSize(const Size(400, 800));
  addTearDown(() async => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: FTheme(
        data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
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
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);

  testWidgets('renders history rows', (tester) async {
    final state = _stateWithHistory(count: 3, hasMore: false);
    await _pumpHistoryPage(tester, notifier: _RecordingDownloadNotifier(state));

    expect(find.text('Episode 1'), findsOneWidget);
    expect(find.text('Episode 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the end-of-list note when there is nothing left', (
    tester,
  ) async {
    final state = _stateWithHistory(count: 3, hasMore: false);
    await _pumpHistoryPage(tester, notifier: _RecordingDownloadNotifier(state));

    expect(find.text('download.end_of_list'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('requests the next page when scrolled to the bottom', (
    tester,
  ) async {
    final notifier = _RecordingDownloadNotifier(
      _stateWithHistory(count: 30, hasMore: true),
    );
    await _pumpHistoryPage(tester, notifier: notifier);

    expect(notifier.loadMoreCalls, 0);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(notifier.loadMoreCalls, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('history list is scrollable, not clipped by a snap sheet', (
    tester,
  ) async {
    // The page used to render its body inside MiruScaffold's snap sheet, which
    // has no scroll view — rows past the first screen were unreachable.
    final state = _stateWithHistory(count: 30, hasMore: true);
    await _pumpHistoryPage(tester, notifier: _RecordingDownloadNotifier(state));

    expect(find.byType(CustomScrollView), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders only finished downloads, not work in flight', (
    tester,
  ) async {
    // The download screen owns in-flight work; this page is the completed
    // archive, so an in-progress row must not leak in here.
    final state = DownloadState(
      history: [
        _completed(1),
        proto.Download(
          id: 2,
          package: 'test.pkg',
          title: 'Still Downloading',
          status: proto.DownloadStatus.DOWNLOADING,
          savePath: '/tmp/partial.mp4',
          detailUrl: 'https://example.com/2',
        ),
        proto.Download(
          id: 3,
          package: 'test.pkg',
          title: 'Gave Up',
          status: proto.DownloadStatus.FAILED,
          savePath: '/tmp/failed.mp4',
          detailUrl: 'https://example.com/3',
        ),
      ],
      hasMore: false,
    );
    await _pumpHistoryPage(tester, notifier: _RecordingDownloadNotifier(state));

    expect(find.text('Episode 1'), findsOneWidget);
    expect(find.text('Still Downloading'), findsNothing);
    expect(find.text('Gave Up'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('delete asks for confirmation and keeps the entry on cancel', (
    tester,
  ) async {
    final state = _stateWithHistory(count: 1, hasMore: false);
    await _pumpHistoryPage(tester, notifier: _RecordingDownloadNotifier(state));

    await tester.tap(find.byIcon(FLucideIcons.trash2).first);
    await tester.pump();

    expect(find.text('download.delete_title'), findsOneWidget);
    expect(find.text('download.remove_record_option'), findsOneWidget);

    await tester.tap(find.text('common.cancel').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('download.delete_title'), findsNothing);
    expect(find.text('Episode 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
