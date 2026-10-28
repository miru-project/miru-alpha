/// Systemized parity contract between the detail loading skeleton
/// ([MobileDetailSkeletonPage]) and the fetched-content page
/// ([MobileLoadedPage]).
///
/// Both pages are pumped with the SAME partial info (title, meta, empty
/// cover, one six-episode group) and their geometry is compared — for
/// both phases of the load:
///
///   * tapped-card phase: the skeleton only knows the tapped card;
///   * detail-known phase: the skeleton receives the fetched [Detail],
///     exactly as [MobileLoadedPage] renders it while [Detial] resolves.
///
/// In each comparison:
///
///   * the same sections appear in the same vertical order,
///   * horizontal gutters align within 2 px (the 16 px contract),
///   * each section's top edge aligns within [topTolerance] px,
///   * the cover box matches in position and size.
///
/// If someone edits the loaded page's section stack (or the skeleton)
/// without the other following along, this test fails instead of shipping
/// a jarring swap to the user. A third test pins that [MobileLoadedPage]
/// renders THIS skeleton (and no second, plainer shell) while [Detial]
/// loads.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/ui/core/core/image_widget.dart';
import 'package:miru_alpha/ui/features/detail/mobile_loaded_page.dart';
import 'package:miru_alpha/ui/features/detail/widget/detail_loading_skeleton.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_cards.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_hero.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_silverlist.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

const _url = 'https://example.com/one-piece';
const _title = 'One Piece';

/// Per-section tolerance for how far a section's top edge may sit between
/// skeleton and content. Wording/label differences shift later sections by
/// a line or two; anything beyond the bound is layout drift, not
/// typography.
///
/// Uniform at 48 px because the skeleton mirrors content's own section
/// chrome in both phases — real dot-row, real (inert) accordion tiles,
/// real FTileGroup — so only text reflow may move a top edge.
const _topTolerance = <String, double>{
  'hero': 48,
  'trackers-cast': 48,
  'episodes': 48,
};

/// Gutter / cover alignment — pixel-tight by design (the 16 px contract).
const _edgeTolerance = 2.0;

/// Sections in loaded-page order; the skeleton must mirror this order.
const _order = ['hero', 'trackers-cast', 'episodes'];

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

/// The fetched detail, before parsing: one group of six episodes.
proto.Detail _protoDetail() => proto.Detail()
  ..title = _title
  ..cover = ''
  ..desc = 'A long description that wraps to a few lines on a phone.'
  ..detailUrl = _url
  ..package = 'test.pkg'
  ..episodes = jsonEncode([
    {
      'title': 'Season 1',
      'urls': [
        for (var i = 1; i <= 6; i++)
          {'name': 'Episode $i', 'url': '$_url/ep$i'},
      ],
    },
  ]);

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

/// [Detial] stuck in `loading`, the state [MobileLoadedPage] renders its
/// skeleton in.
class _LoadingDetial extends Detial {
  @override
  DetialState build(String detailUrl, {required ExtensionMeta meta}) {
    return DetialState(
      selectedGroup: ValueNotifier<int>(0),
      status: DetialStatus.loading,
    );
  }
}

/// Empty download state so episode tiles render their not-downloaded
/// branch without subscribing to the download stream.
class _FakeDownloads extends DownloadNotifier {
  @override
  AsyncValue<DownloadState> build() => AsyncData(DownloadState());
}

/// App-equivalent MaterialApp: real i18n delegate + the app's root navigator
/// key, so `.i18n` resolves to translated (short) strings instead of raw
/// keys, which are long enough to overflow rows the app never overflows.
Widget _harness(Widget child) => FTheme(
  data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
  child: MaterialApp(
    navigatorKey: RouterUtil.rootNavigatorKey,
    supportedLocales: FLocalizations.supportedLocales,
    localizationsDelegates: [
      I18nUtils.flutterI18nDelegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: Scaffold(body: child),
  ),
);

/// Top-edge rect of each section; keys on the skeleton side, widget types
/// on the loaded side.
Map<String, Rect> _measure(WidgetTester tester, {required bool skeleton}) {
  Finder pick(String key, Type type) =>
      skeleton ? find.byKey(Key(key)) : find.byType(type);
  // MobileDetailSilverlist is a sliver — getRect needs a RenderBox, so the
  // loaded side measures the column it lays out inside the same 16 px
  // gutters (its outer padding contributes +20 vertical, within tolerance).
  final episodes = skeleton
      ? tester.getRect(find.byKey(const Key('skeleton-episodes')))
      : tester.getRect(
          find
              .descendant(
                of: find.byType(MobileDetailSilverlist),
                matching: find.byType(Column),
              )
              .first,
        );
  return {
    'hero': tester.getRect(pick('skeleton-hero', MobileDetailHero)),
    'trackers-cast': tester.getRect(
      pick('skeleton-trackers-cast', MobileTrackersCastSection),
    ),
    'episodes': episodes,
  };
}

/// The cover box: the skeleton's keyed ClipRRect vs the loaded hero's
/// [ImageWidget], which fills the same 112×160 container.
Rect _coverRect(WidgetTester tester, {required bool skeleton}) => skeleton
    ? tester.getRect(find.byKey(const Key('skeleton-cover')))
    : tester.getRect(
        find
            .descendant(
              of: find.byType(MobileDetailHero),
              matching: find.byType(ImageWidget),
            )
            .first,
      );

/// Pumps the skeleton (phase chosen by [withDetail]) and the fetched
/// content from the same fixture, then enforces the parity contract.
Future<void> _verifyParity(
  WidgetTester tester, {
  required bool withDetail,
}) async {
  final meta = _meta();
  final fixture = _protoDetail();
  final detail = MiruCoreEndpoint.detailFromProto(fixture);

  // A: the skeleton. Tapped-card phase: only the card's partial info.
  // Detail-known phase: the fetched detail too, exactly what
  // MobileLoadedPage feeds its skeleton while Detial resolves.
  await tester.pumpWidget(
    _harness(
      withDetail
          ? MobileDetailSkeletonPage(meta: meta, detail: detail)
          : MobileDetailSkeletonPage(
              meta: meta,
              items: [ExtensionListItem()..title = _title],
              index: 0,
            ),
    ),
  );
  // Fixed frames: DetailSkeleton animates forever (no pumpAndSettle).
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);
  final skeleton = _measure(tester, skeleton: true);
  final skeletonCover = _coverRect(tester, skeleton: true);

  // B: the fetched content, from the same partial info.
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
        MobileLoadedPage(
          detail: detail,
          meta: meta,
          detailUrl: _url,
          detailPr: detailPr,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);
  final loaded = _measure(tester, skeleton: false);
  final loadedCover = _coverRect(tester, skeleton: false);

  // 1. Same sections, same vertical order, on both pages.
  for (final rects in [skeleton, loaded]) {
    for (var i = 1; i < _order.length; i++) {
      final prev = rects[_order[i - 1]]!;
      final cur = rects[_order[i]]!;
      expect(
        cur.top,
        greaterThan(prev.top),
        reason: 'section order broken: ${_order[i - 1]} → ${_order[i]}',
      );
    }
  }

  // 2. Gutter and top-edge parity per section.
  for (final name in _order) {
    final s = skeleton[name]!;
    final l = loaded[name]!;
    expect(
      (s.left - l.left).abs(),
      lessThanOrEqualTo(_edgeTolerance),
      reason: 'gutter drifted for "$name": skeleton=$s loaded=$l',
    );
    expect(
      (s.top - l.top).abs(),
      lessThanOrEqualTo(_topTolerance[name]!),
      reason: 'top drifted for "$name": skeleton=$s loaded=$l',
    );
  }

  // 3. The pinned 16 px gutter, absolute.
  expect(skeleton['hero']!.left, closeTo(16, _edgeTolerance));
  expect(loaded['hero']!.left, closeTo(16, _edgeTolerance));

  // 4. Cover box: same box, same place, same size.
  for (final (label, a, b) in [
    ('left', skeletonCover.left, loadedCover.left),
    ('top', skeletonCover.top, loadedCover.top),
    ('width', skeletonCover.width, loadedCover.width),
    ('height', skeletonCover.height, loadedCover.height),
  ]) {
    expect(
      (a - b).abs(),
      lessThanOrEqualTo(_edgeTolerance),
      reason:
          'cover $label drifted: skeleton=$skeletonCover '
          'loaded=$loadedCover',
    );
  }
}

void main() {
  // I18nUtils.flutterI18nDelegate reads the language setting at first use.
  setUpAll(MiruSettings.seedDefaultsForTest);

  for (final surface in const [Size(360, 844), Size(412, 896)]) {
    final width = surface.width.toInt();

    testWidgets(
      'skeleton and fetched content keep the same layout at ${width}px '
      '(tapped-card phase)',
      (tester) async {
        await tester.binding.setSurfaceSize(surface);
        addTearDown(() async => tester.binding.setSurfaceSize(null));
        await _verifyParity(tester, withDetail: false);
      },
    );

    testWidgets(
      'skeleton and fetched content keep the same layout at ${width}px '
      '(detail-known phase)',
      (tester) async {
        await tester.binding.setSurfaceSize(surface);
        addTearDown(() async => tester.binding.setSurfaceSize(null));
        await _verifyParity(tester, withDetail: true);
      },
    );
  }

  testWidgets('MobileLoadedPage renders this skeleton while Detial loads '
      '(no second shell)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 844));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    final meta = _meta();
    final fixture = _protoDetail();
    final detail = MiruCoreEndpoint.detailFromProto(fixture);
    final detailPr = detialProvider(_url, meta: meta);
    final container = ProviderContainer(
      overrides: [
        detailPr.overrideWith(() => _LoadingDetial()),
        downloadProvider.overrideWith(() => _FakeDownloads()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _harness(
          MobileLoadedPage(
            detail: detail,
            meta: meta,
            detailUrl: _url,
            detailPr: detailPr,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MobileDetailSkeletonPage), findsOneWidget);
    expect(find.byType(MobileDetailHero), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
