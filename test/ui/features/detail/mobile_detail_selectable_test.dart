/// The mobile detail's copy-out surfaces: the hero title and description
/// render inside [SelectionArea] (long-press selects), and the episode
/// group picker is the native forui [FSelect] whose pick swaps the list.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/detail_page_provider.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_hero.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_silverlist.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

const _url = 'https://example.com/one-piece';

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

/// Two episode groups so the picker has something to switch to.
proto.Detail _protoDetail({List<proto.Tracker>? trackers}) => proto.Detail()
  ..title = 'One Piece'
  ..cover = ''
  ..desc = 'A long description that wraps to a few lines on a phone.'
  ..detailUrl = _url
  ..package = 'test.pkg'
  ..episodes = jsonEncode([
    {
      'title': 'Season 1',
      'urls': [
        for (var i = 1; i <= 3; i++)
          {'name': 'S1 Episode $i', 'url': '$_url/s1e$i'},
      ],
    },
    {
      'title': 'Season 2',
      'urls': [
        for (var i = 1; i <= 3; i++)
          {'name': 'S2 Episode $i', 'url': '$_url/s2e$i'},
      ],
    },
  ])
  ..trackers.addAll(trackers ?? const []);

/// [Detial] that serves the fixture immediately, so the list renders its
/// ready state without touching gRPC, history, or favorites.
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

/// Empty download state so episode tiles render their not-downloaded
/// branch without subscribing to the download stream.
class _FakeDownloads extends DownloadNotifier {
  @override
  AsyncValue<DownloadState> build() => AsyncData(DownloadState());
}

/// App-equivalent MaterialApp: real i18n delegate + the app's root
/// navigator key (the parity test's harness), so `.i18n` resolves instead
/// of rendering raw keys wide enough to overflow rows the app never does.
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

ProviderContainer _overrides(WidgetTester tester, proto.Detail fixture) {
  final meta = _meta();
  final detailPr = detialProvider(_url, meta: meta);
  final container = ProviderContainer(
    overrides: [
      detailPr.overrideWith(() => _FakeDetial(fixture)),
      downloadProvider.overrideWith(() => _FakeDownloads()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<ProviderContainer> _pumpHero(WidgetTester tester) async {
  final meta = _meta();
  final fixture = _protoDetail();
  final container = _overrides(tester, fixture);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _harness(
        SingleChildScrollView(
          child: MobileDetailHero(
            detail: MiruCoreEndpoint.detailFromProto(fixture),
            meta: meta,
            detailUrl: _url,
            detailPr: detialProvider(_url, meta: meta),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return container;
}

Future<ProviderContainer> _pumpSilverlist(WidgetTester tester) async {
  final meta = _meta();
  final fixture = _protoDetail();
  final container = _overrides(tester, fixture);
  final detailPr = detialProvider(_url, meta: meta);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _harness(
        CustomScrollView(
          slivers: [
            MobileDetailSilverlist(
              detail: MiruCoreEndpoint.detailFromProto(fixture),
              meta: meta,
              detailUrl: _url,
              detailPr: detailPr,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 300)),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  return container;
}

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);
  setUp(() async {
    MiruSettings.setSettingSync(SettingKey.language, 'en');
  });

  group('MobileDetailHero selectable text', () {
    testWidgets('title renders inside a SelectionArea', (tester) async {
      await _pumpHero(tester);

      final selectable = find.ancestor(
        of: find.text('One Piece'),
        matching: find.byType(SelectionArea),
      );
      expect(selectable, findsWidgets);
      // The mobile pill toolbar is forced by the android Material platform
      // above each region — the adaptive builder reads
      // `Theme.of(context).platform` from the captured theme.
      final theme = tester.widget<Theme>(
        find
            .ancestor(
              of: find.byType(SelectionArea),
              matching: find.byType(Theme),
            )
            .first,
      );
      expect(theme.data.platform, TargetPlatform.android);
      // The chrome follows the CURRENT forui palette, not MaterialApp's
      // default: toolbar card = colors.card, pill labels = colors.foreground,
      // handles/highlight = colors.primary at forui's own 40% selection wash.
      final forui = ThemeUtils.getThemeData(MiruThemes.zinc.light);
      expect(theme.data.colorScheme.brightness, forui.colors.brightness);
      expect(theme.data.colorScheme.surface, forui.colors.card);
      expect(theme.data.colorScheme.onSurface, forui.colors.foreground);
      expect(theme.data.colorScheme.primary, forui.colors.primary);
      expect(
        theme.data.textSelectionTheme.selectionColor,
        forui.colors.primary.withValues(alpha: 0.4),
      );
      expect(
        theme.data.textSelectionTheme.selectionHandleColor,
        forui.colors.primary,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('description renders inside a SelectionArea', (tester) async {
      await _pumpHero(tester);

      final selectable = find.ancestor(
        of: find.textContaining('A long description'),
        matching: find.byType(SelectionArea),
      );
      expect(selectable, findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('long-press selection shows the mobile copy/share toolbar', (
      tester,
    ) async {
      await _pumpHero(tester);

      // The test host runs as android (touch): a long-press is the native
      // selection gesture, so this drives the real path a phone takes.
      await tester.longPress(find.text('One Piece'));
      await tester.pumpAndSettle();

      // The word is selected and the pill toolbar mounts with the mobile
      // action set: Copy, the injected Share, then Select all.
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.textContaining('Select'), findsOneWidget);
      // The mounted toolbar PAINTS with the forui palette (its Material
      // surface reads colorScheme.surface = colors.card), not the default
      // white Material card the unthemed MaterialApp would give.
      final toolbarMaterial = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(TextSelectionToolbar),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(
        toolbarMaterial.color,
        ThemeUtils.getThemeData(MiruThemes.zinc.light).colors.card,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('right-click on the desktop-host frame shows the same pills', (
      tester,
    ) async {
      // The phone frame runs on a Linux desktop host: the selection region
      // keeps the mouse gesture set (right-click toggles the toolbar) while
      // the toolbar itself stays the mobile pill bar.
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await _pumpHero(tester);

      // Select a word with a touch long-press (tests synthesize touch
      // pointers regardless of the platform override), then toggle the
      // toolbar off and back on the way the host's right-click does.
      await tester.longPress(find.text('One Piece'));
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsOneWidget);

      await tester.tap(find.text('One Piece'), buttons: kSecondaryMouseButton);
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsNothing, reason: 'right-click toggles');

      await tester.tap(find.text('One Piece'), buttons: kSecondaryMouseButton);
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('MobileDetailSilverlist group select', () {
    testWidgets('shows the current group and swaps on pick', (tester) async {
      final container = await _pumpSilverlist(tester);

      // Closed field renders the active group's title exactly once.
      expect(find.text('Season 1'), findsOneWidget);
      expect(find.text('Season 2'), findsNothing);

      // Open the native select; the popover lists the other group.
      // FSelect.rich instantiates the private _BasicSelect subclass, so
      // byType would miss it — match the public supertype instead.
      await tester.tap(
        find.byWidgetPredicate((widget) => widget is FSelect<int>),
      );
      await tester.pumpAndSettle();
      expect(find.text('Season 2'), findsOneWidget);

      // Picking it drives the real control → setEpGroup path.
      await tester.tap(find.text('Season 2'));
      await tester.pumpAndSettle();

      expect(
        container.read(detailPageProviderProvider).epGroupIdx,
        1,
        reason: 'the FSelect onChange must drive setEpGroup',
      );
      // The field now shows the picked group and the list followed.
      expect(find.text('Season 2'), findsOneWidget);
      expect(find.text('S2 Episode 1'), findsOneWidget);
      expect(find.text('S1 Episode 1'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
