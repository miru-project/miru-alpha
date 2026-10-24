import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_cards.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_hero.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

const _url = 'https://example.com/one-piece';

ExtensionMeta _meta() => ExtensionMeta(
  name: 'Miruro',
  version: '2.0.0',
  author: 't',
  license: 'MIT',
  lang: 'en',
  packageName: 'test.pkg',
  webSite: 'https://example.com',
  description: 'test provider',
  tags: const [],
  api: 'v2',
  type: ExtensionType.bangumi,
);

proto.Detail _protoDetail({List<proto.Tracker>? trackers, int totalEps = 6}) =>
    proto.Detail()
      ..title = 'One Piece'
      ..cover = ''
      ..desc = 'A long description that wraps to a few lines on a phone.'
      ..detailUrl = _url
      ..package = 'test.pkg'
      ..episodes = jsonEncode([
        {
          'title': 'Season 1',
          'urls': [
            for (var i = 1; i <= totalEps; i++)
              {'name': 'Episode $i', 'url': '$_url/ep$i'},
          ],
        },
      ])
      ..trackers.addAll(trackers ?? const []);

/// [Detial] that serves the fixture immediately, so the loaded page renders
/// its `ready` state without touching gRPC, history, or favorites.
class _FakeDetial extends Detial {
  _FakeDetial(this.fixture);

  final proto.Detail fixture;

  @override
  DetialState build(String detailUrl, {required ExtensionMeta meta}) {
    return DetialState(
      selectedGroup: ValueNotifier<int>(0),
      detailInfo: fixture,
      status: DetialStatus.ready,
    );
  }
}

class _FakeDownloads extends DownloadNotifier {
  @override
  AsyncValue<DownloadState> build() => AsyncData(DownloadState());
}

Widget _harness(Widget child) => FTheme(
  data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
  child: MaterialApp(
    navigatorKey: RouterUtil.rootNavigatorKey,
    supportedLocales: FLocalizations.supportedLocales,
    localizationsDelegates: [
      I18nUtils.flutterI18nDelegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

/// Pumps [MobileTrackersCastSection] with an optional tracker list.
Future<ProviderContainer> _pumpSection(
  WidgetTester tester, {
  List<proto.Tracker>? trackers,
}) async {
  final meta = _meta();
  final fixture = _protoDetail(trackers: trackers);
  final detail = MiruCoreEndpoint.detailFromProto(fixture);
  final detailPr = detialProvider(_url, meta: meta);
  final container = ProviderContainer(
    overrides: [
      detailPr.overrideWith(() => _FakeDetial(fixture)),
      downloadProvider.overrideWith(() => _FakeDownloads()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _harness(
        MobileTrackersCastSection(
          detail: detail,
          meta: meta,
          detailUrl: _url,
          detailPr: detailPr,
        ),
      ),
    ),
  );
  await tester.pump();
  return container;
}

/// An AniList tracker record for [id].
proto.Tracker _anilist({
  String id = '21',
  String status = 'CURRENT',
  int progress = 3,
  int total = 6,
  int score = 8,
}) => proto.Tracker()
  ..trackerId = id
  ..provider = 'anilist'
  ..status = status
  ..progress = progress
  ..totalProgress = total
  ..score = score;

/// Taps the tracker card by finding its FTile and tapping its center.
Future<void> _tapTrackerCard(WidgetTester tester) async {
  final tile = find.ancestor(
    of: find.text('Tracking'),
    matching: find.byType(FTile),
  );
  await tester.tap(tile, warnIfMissed: false);
}

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);
  setUp(() async {
    // I18nUtils.flutterI18nDelegate reads the language setting at first use.
    MiruSettings.setSettingSync(SettingKey.language, 'en');
  });

  group('MobileTrackersCastSection', () {
    testWidgets('shows both summary cards side by side when collapsed', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      await _pumpSection(tester);

      // Both cards render their labels; neither panel is expanded yet.
      expect(find.text('Tracking'), findsOneWidget);
      expect(find.text('Cast'), findsOneWidget);
      // The unlinked pill is an icon; the "Not synced" wording survives
      // as its semantic label.
      final cloudOff = tester.widget<Icon>(find.byIcon(FLucideIcons.cloudOff));
      expect(cloudOff.semanticLabel, 'Not synced');
      // No service rows / cast rows until a card is tapped.
      expect(find.text('AniList'), findsNothing);
      expect(find.text('Sync All'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('expands the tracker panel on tap and lists the service', (
      tester,
    ) async {
      await _pumpSection(tester, trackers: [_anilist()]);

      await _tapTrackerCard(tester);
      await tester.pumpAndSettle();

      expect(find.text('AniList'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
      // Live progress/score line from the tracker record.
      expect(find.textContaining('Progress: 3/6'), findsOneWidget);
      expect(find.textContaining('Score: 8/10'), findsOneWidget);
      // Quick status pills.
      expect(find.text('Watching'), findsOneWidget);
      expect(find.text('Planning'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      // Unlinked providers are not duplicated: only AniList exists.
      expect(find.text('Not linked'), findsNothing);
      // The auto-sync footer is present.
      expect(find.text('Auto-sync when episode ends'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('offers a link row when AniList is not linked', (tester) async {
      await _pumpSection(tester);

      await _tapTrackerCard(tester);
      await tester.pumpAndSettle();

      expect(find.text('Not linked'), findsOneWidget);
      expect(find.text('Link'), findsOneWidget);
      expect(find.text('Connected'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tracker and cast panels are mutually exclusive', (
      tester,
    ) async {
      await _pumpSection(tester, trackers: [_anilist()]);

      await _tapTrackerCard(tester);
      await tester.pumpAndSettle();
      expect(find.text('Tracking Services'), findsOneWidget);

      await tester.tap(find.text('Cast').last);
      await tester.pumpAndSettle();
      // Opening cast closed the tracker panel.
      expect(find.text('Tracking Services'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('collapses the panel when its card is tapped again', (
      tester,
    ) async {
      await _pumpSection(tester, trackers: [_anilist()]);

      await _tapTrackerCard(tester);
      await tester.pumpAndSettle();
      expect(find.text('Tracking Services'), findsOneWidget);

      await _tapTrackerCard(tester);
      await tester.pumpAndSettle();
      expect(find.text('Tracking Services'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('MobileDetailHero resume CTA', () {
    testWidgets('falls back to a plain play label with no history', (
      tester,
    ) async {
      final meta = _meta();
      final fixture = _protoDetail();
      final detail = MiruCoreEndpoint.detailFromProto(fixture);
      final detailPr = detialProvider(_url, meta: meta);
      final container = ProviderContainer(
        overrides: [
          detailPr.overrideWith(() => _FakeDetial(fixture)),
          downloadProvider.overrideWith(() => _FakeDownloads()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _harness(
            MobileDetailHero(
              detail: detail,
              meta: meta,
              detailUrl: _url,
              detailPr: detailPr,
            ),
          ),
        ),
      );
      await tester.pump();

      // No history: "Play Ep. 1" over the episode name, no remaining chip.
      expect(find.text('Play Ep. 1'), findsOneWidget);
      expect(find.text('Episode 1'), findsOneWidget);
      expect(find.textContaining('remaining'), findsNothing);
      // Content is start-aligned, not centered: the title begins left of the
      // button's midpoint (icon + padding), per the mock.
      final buttonRect = tester.getRect(find.byType(FButton));
      final titleLeft = tester.getTopLeft(find.text('Play Ep. 1')).dx;
      expect(titleLeft, lessThan(buttonRect.center.dx));
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the resume label and remaining time with history', (
      tester,
    ) async {
      final meta = _meta();
      final fixture = _protoDetail();
      final detail = MiruCoreEndpoint.detailFromProto(fixture);
      final detailPr = detialProvider(_url, meta: meta);

      // A partially watched first episode with 90s watched of 600s.
      final history = History(
        title: 'One Piece',
        package: 'test.pkg',
        type: ExtensionType.bangumi.name,
        episodeGroupId: 0,
        episodeId: 0,
        progress: 90,
        cover: '',
        totalProgress: 600,
        episodeTitle: 'Episode 1',
        url: '$_url/ep1',
        detailUrl: _url,
        date: DateTime(2026),
      );

      final container = ProviderContainer(
        overrides: [
          detailPr.overrideWith(
            () => _FakeDetialWithHistory(fixture, [history]),
          ),
          downloadProvider.overrideWith(() => _FakeDownloads()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _harness(
            MobileDetailHero(
              detail: detail,
              meta: meta,
              detailUrl: _url,
              detailPr: detailPr,
            ),
          ),
        ),
      );
      await tester.pump();

      // (600 - 90) / 60 = 8.5 -> ceil -> 9 minutes remaining.
      expect(find.text('Resume Ep. 1'), findsOneWidget);
      expect(find.text('Episode 1'), findsOneWidget);
      expect(find.text('9m remaining'), findsOneWidget);
      // The remaining-time chip sits at the button's right edge.
      final buttonRight = tester.getRect(find.byType(FButton)).right;
      final chipRight = tester.getTopRight(find.text('9m remaining')).dx;
      expect(buttonRight - chipRight, lessThan(24));
      expect(tester.takeException(), isNull);
    });
  });
}

/// [Detial] that also seeds the history list.
class _FakeDetialWithHistory extends Detial {
  _FakeDetialWithHistory(this.fixture, this.history);

  final proto.Detail fixture;
  final List<History> history;

  @override
  DetialState build(String detailUrl, {required ExtensionMeta meta}) {
    return DetialState(
      selectedGroup: ValueNotifier<int>(0),
      detailInfo: fixture,
      status: DetialStatus.ready,
      historyList: history,
    );
  }
}
