import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/home/home_view_model.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/features/home/widget/library_bento_cards.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

class _FakeHomeViewModel extends HomeViewModel {
  _FakeHomeViewModel(this._state);

  final HomeViewState _state;

  @override
  HomeViewState build() => _state;
}

class _FakeDownloadNotifier extends DownloadNotifier {
  _FakeDownloadNotifier(this._state);

  final AsyncValue<DownloadState> _state;

  @override
  AsyncValue<DownloadState> build() => _state;
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

proto.DownloadProgress _task(int id, proto.DownloadStatus status) =>
    proto.DownloadProgress(
      taskId: id,
      title: 'Task $id',
      progress: 10,
      total: 100,
      status: status,
      package: 'test.pkg',
      key: 'ep$id',
      mediaType: proto.DownloadMediaType.hls,
    );

Future<void> pumpCards(
  WidgetTester tester, {
  required List<proto.DownloadProgress> active,
}) async {
  final container = ProviderContainer(
    overrides: [
      homeViewModelProvider.overrideWith(
        () => _FakeHomeViewModel(
          HomeViewState(
            favorites: const [],
            history: const [],
            downloads: const [],
            selectedTab: 0,
          ),
        ),
      ),
      downloadProvider.overrideWith(
        () => _FakeDownloadNotifier(
          AsyncValue.data(DownloadState(active: active)),
        ),
      ),
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
                // A scroll view gives the row an unbounded height, matching the
                // real `SliverToBoxAdapter` parent. A plain `Scaffold(body:)`
                // would bound it and hide any height mismatch.
                builder: (context, s) => const Scaffold(
                  body: SingleChildScrollView(child: LibraryBentoCards()),
                ),
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

  testWidgets('download card breaks work down by status', (tester) async {
    await pumpCards(
      tester,
      active: [
        _task(1, proto.DownloadStatus.DOWNLOADING),
        _task(2, proto.DownloadStatus.DOWNLOADING),
        _task(3, proto.DownloadStatus.FAILED),
      ],
    );

    // Two downloading, one failed — the counts the user asked for.
    expect(find.text('2'), findsOneWidget);
    expect(find.text('download.status.downloading'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('download.status.failed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('download card shows no total entry count', (tester) async {
    // The old card read "N active, N total"; a running total of stored entries
    // was dropped on purpose.
    await pumpCards(
      tester,
      active: [_task(1, proto.DownloadStatus.DOWNLOADING)],
    );

    expect(find.textContaining('total'), findsNothing);
    expect(find.textContaining('downloads'), findsNothing);
    expect(find.text('download.status.downloading'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('download card collapses paused work into one row', (
    tester,
  ) async {
    await pumpCards(
      tester,
      active: [
        _task(1, proto.DownloadStatus.PAUSED),
        _task(2, proto.DownloadStatus.QUEUED),
      ],
    );

    expect(find.text('2'), findsOneWidget);
    expect(find.text('download.status.paused'), findsOneWidget);
    expect(find.text('download.status.queued'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('idle download card points at the history instead', (
    tester,
  ) async {
    await pumpCards(tester, active: const []);

    expect(find.text('download.no_active_downloads'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // The download card grows a row per active status while the history card
  // stays one line, so the pair used to render at visibly different heights.
  for (final case_ in [
    ('idle', <proto.DownloadStatus>[]),
    (
      'one status row',
      <proto.DownloadStatus>[proto.DownloadStatus.DOWNLOADING],
    ),
    (
      'all three status rows',
      <proto.DownloadStatus>[
        proto.DownloadStatus.DOWNLOADING,
        proto.DownloadStatus.PAUSED,
        proto.DownloadStatus.FAILED,
      ],
    ),
  ]) {
    testWidgets('bento cards stay equal height with ${case_.$1}', (
      tester,
    ) async {
      await pumpCards(
        tester,
        active: [
          for (final (i, status) in case_.$2.indexed) _task(i + 1, status),
        ],
      );

      // IntrinsicHeight throws if a descendant cannot compute its intrinsic
      // height, so a clean render is part of what this asserts.
      expect(tester.takeException(), isNull);

      final cards = find.byType(MiruCard);
      expect(cards, findsNWidgets(2));

      final history = tester.getSize(cards.at(0));
      final download = tester.getSize(cards.at(1));
      expect(
        download.height,
        history.height,
        reason: 'both bento cards must fill the same height',
      );
      expect(history.width, download.width);
    });
  }
}
