/// Mirrors test/ui/features/detail/mobile_detail_cards_test.dart states for
/// the catalog.
///
/// The tracker/cast panels and the score sheet are internal state — the
/// catalog user opens them by tapping the summary cards, exactly like the
/// test taps its FTile. Each use-case below mounts the fixture the test
/// builds for that assertion; the name names the state to tap into. i18n
/// keys render raw here (no delegates — expected).
library;

import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_cards.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_hero.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:widgetbook/widgetbook.dart';

const _url = 'https://example.com/one-piece';

List<WidgetbookComponent> buildMobileDetailCardComponents() {
  return [
    WidgetbookComponent(
      name: 'MobileTrackersCastSection',
      useCases: [
        WidgetbookUseCase(
          name: 'Collapsed — both summary cards (tap to expand)',
          builder: _collapsedCards,
        ),
        WidgetbookUseCase(
          name: 'Connected row — linked AniList record (tap Tracking)',
          builder: _connectedTracker,
        ),
        WidgetbookUseCase(
          name: 'Login row — unlinked, no account (tap Tracking)',
          builder: _loginTracker,
        ),
        WidgetbookUseCase(
          name: 'Link row — signed in, no record yet (tap Tracking)',
          builder: _linkTracker,
        ),
        WidgetbookUseCase(
          name: 'Cast panel — no cast found (tap Cast)',
          builder: _castPanel,
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'MobileDetailHero',
      useCases: [
        WidgetbookUseCase(
          name: 'Play CTA — no history ("Play Ep. 1")',
          builder: _playCta,
        ),
        WidgetbookUseCase(
          name: 'Resume CTA — partially watched ("9m remaining")',
          builder: _resumeCta,
        ),
      ],
    ),
  ];
}

ExtensionMeta _meta() => ExtensionMeta(
  name: 'ExampleA',
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

proto.Detail _protoDetail({List<proto.Tracker>? trackers}) => proto.Detail()
  ..title = 'One Piece'
  ..cover = ''
  ..desc = 'A long description that wraps to a few lines on a phone.'
  ..detailUrl = _url
  ..package = 'test.pkg'
  ..episodes = _episodesJson()
  ..trackers.addAll(trackers ?? const []);

String _episodesJson() => jsonEncode([
  {
    'title': 'Season 1',
    'urls': [
      for (var i = 1; i <= 6; i++) {'name': 'Episode $i', 'url': '$_url/ep$i'},
    ],
  },
]);

/// An AniList tracker record: CURRENT, progress 3/6, score 8.
proto.Tracker _anilist() => proto.Tracker()
  ..trackerId = '21'
  ..provider = 'anilist'
  ..status = 'CURRENT'
  ..progress = 3
  ..totalProgress = 6
  ..score = 8;

/// Signed-in AniList account so the unlinked row offers `Link`.
class _FakeAccount extends AnilistAccount {
  _FakeAccount(this.user);

  final AnilistUser user;

  @override
  Future<AnilistUser?> build() async => user;
}

class _FakeDownloads extends DownloadNotifier {
  @override
  AsyncValue<DownloadState> build() => AsyncData(DownloadState());
}

/// The app-equivalent page scaffold of the test's `_pumpSection`: the same
/// SingleChildScrollView inside a Scaffold, under the catalog's own FTheme.
Widget _pageScaffold(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

/// Pumps the section with an optional tracker list and an optional signed-in
/// AniList account, mirroring the test's `_pumpSection` overrides.
Widget _section(
  BuildContext context, {
  List<proto.Tracker>? trackers,
  AnilistUser? account,
}) {
  MiruSettings.seedDefaults();
  final meta = _meta();
  final fixture = _protoDetail(trackers: trackers);
  final detail = MiruCoreEndpoint.detailFromProto(fixture);
  final detailPr = detialProvider(_url, meta: meta);
  final container = ProviderContainer(
    overrides: [
      detailPr.overrideWith(() => _FakeDetial(fixture)),
      downloadProvider.overrideWith(_FakeDownloads.new),
      if (account != null)
        anilistAccountProvider.overrideWith(() => _FakeAccount(account)),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: _pageScaffold(
      MobileTrackersCastSection(
        detail: detail,
        meta: meta,
        detailUrl: _url,
        detailPr: detailPr,
      ),
    ),
  );
}

Widget _collapsedCards(BuildContext context) => _section(context);

Widget _connectedTracker(BuildContext context) =>
    _section(context, trackers: [_anilist()]);

Widget _loginTracker(BuildContext context) => _section(context);

Widget _linkTracker(BuildContext context) {
  return _section(
    context,
    account: AnilistUser(
      name: 'Tester',
      id: 1,
      avatar: AnilistAvatar(),
      statistics: AnilistStatistics(
        anime: AnilistMediaStatistics(),
        manga: AnilistMediaStatistics(),
      ),
    ),
  );
}

Widget _castPanel(BuildContext context) => _section(context);

Widget _hero(BuildContext context, {required List<History> history}) {
  MiruSettings.seedDefaults();
  final meta = _meta();
  final fixture = _protoDetail();
  final detail = MiruCoreEndpoint.detailFromProto(fixture);
  final detailPr = detialProvider(_url, meta: meta);
  final container = ProviderContainer(
    overrides: [
      detailPr.overrideWith(() => _FakeDetialWithHistory(fixture, history)),
      downloadProvider.overrideWith(_FakeDownloads.new),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: _pageScaffold(
      MobileDetailHero(
        detail: detail,
        meta: meta,
        detailUrl: _url,
        detailPr: detailPr,
      ),
    ),
  );
}

Widget _playCta(BuildContext context) => _hero(context, history: const []);

/// A partially watched first episode: 90s watched of 600s → 9m remaining.
Widget _resumeCta(BuildContext context) {
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
  return _hero(context, history: [history]);
}

/// [Detial] that serves the fixture immediately, so the section renders its
/// `ready` state without touching gRPC, history, or favorites.
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

/// [Detial] that also seeds the history list (the resume CTA reads it).
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
