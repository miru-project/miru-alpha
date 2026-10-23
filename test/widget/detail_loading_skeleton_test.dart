import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/ui/features/detail/widget/detail_loading_skeleton.dart';
import 'package:miru_alpha/ui/features/detail/widget/skeleton.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

ExtensionMeta _meta(String name) => ExtensionMeta(
  name: name,
  version: '2.0.0',
  author: 't',
  license: 'MIT',
  lang: 'en',
  packageName: 'test.pkg',
  webSite: 'https://example.com',
  description: '$name provider',
  tags: const [],
  api: 'v2',
  type: ExtensionType.bangumi,
);

ExtensionListItem _item(String title) => ExtensionListItem()..title = title;

/// The fetched detail: one "Season 1" group of six episodes.
proto.Detail _protoDetail() => proto.Detail()
  ..title = 'One Piece'
  ..cover = ''
  ..desc = 'A long description that wraps to a few lines on a phone.'
  ..detailUrl = 'https://example.com/one-piece'
  ..package = 'test.pkg'
  ..episodes = jsonEncode([
    {
      'title': 'Season 1',
      'urls': [
        for (var i = 1; i <= 6; i++)
          {'name': 'Episode $i', 'url': 'https://example.com/ep$i'},
      ],
    },
  ]);

/// App-equivalent MaterialApp: real i18n delegate so `.i18n`/`.fill`
/// resolve to translated (short) strings instead of raw keys.
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

// The skeleton animates forever, so pumpAndSettle never terminates: pump a
// fixed number of frames instead. Two pumps also let the async i18n
// delegate finish loading its language bundle.
Future<void> _pumpSkeleton(
  WidgetTester tester,
  Widget page, [
  Size surface = const Size(360, 740),
]) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() async => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_harness(page));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  // I18nUtils.flutterI18nDelegate reads the language setting at first use.
  setUpAll(MiruSettings.seedDefaultsForTest);

  testWidgets('renders the partial title and skeletons every detail section', (
    tester,
  ) async {
    await _pumpSkeleton(
      tester,
      MobileDetailSkeletonPage(
        meta: _meta('Miru Test'),
        items: [_item('One Piece')],
        index: 0,
      ),
    );

    // Partial info the tapped card already knows: the title, plus the
    // extension name inside the hero's dot-row.
    expect(find.text('One Piece'), findsOneWidget);
    expect(find.text('Miru Test'), findsOneWidget);
    // Cover, Play/Download CTAs, description lines and every episode row
    // still skeleton out; tracking/cast headers now reuse content's real
    // FTile chrome instead of gray boxes.
    expect(find.byType(DetailSkeleton).evaluate().length, greaterThan(10));
    expect(tester.takeException(), isNull);
  });

  testWidgets('falls back to the extension name when no tapped item exists', (
    tester,
  ) async {
    await _pumpSkeleton(
      tester,
      MobileDetailSkeletonPage(meta: _meta('Miru Test'), items: null, index: 0),
    );

    // Title line and dot-row name line both fall back to meta.name.
    expect(find.text('Miru Test'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits the narrowest phone (320px) without overflowing', (
    tester,
  ) async {
    await _pumpSkeleton(
      tester,
      MobileDetailSkeletonPage(
        meta: _meta('Miru Test'),
        items: [_item('A very long title that should ellipsise cleanly')],
        index: 0,
      ),
      const Size(320, 740),
    );

    expect(find.textContaining('A very long title'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the fetched data at the detail-known phase', (
    tester,
  ) async {
    final detail = MiruCoreEndpoint.detailFromProto(_protoDetail());
    await _pumpSkeleton(
      tester,
      MobileDetailSkeletonPage(meta: _meta('Miru Test'), detail: detail),
    );

    // Real description, episode group title, positions, names and count.
    expect(
      find.text('A long description that wraps to a few lines on a phone.'),
      findsOneWidget,
    );
    expect(find.text('One Piece'), findsOneWidget);
    expect(find.text('Season 1'), findsOneWidget);
    expect(find.text('Episode 1'), findsOneWidget);
    // Heading + plain-text count, the mock's split ("Episodes (18)").
    expect(find.text('Episodes'), findsOneWidget);
    expect(find.text('(6)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
