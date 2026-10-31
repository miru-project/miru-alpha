import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/ui/core/widget/small_badge.dart';
import 'package:miru_alpha/ui/features/detail/widget/detail_tag_chips.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
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

proto.Detail _protoDetail() => proto.Detail()
  ..title = 'One Piece'
  ..detailUrl = _url
  ..package = 'test.pkg';

/// [Detial] serving the fixture without gRPC, counting TMDB detail fetches so
/// a test can prove the chips' source choice (metadata tag first, TMDB only
/// as the fallback the hero keeps).
class _FakeDetial extends Detial {
  _FakeDetial(this.fixture);

  final proto.Detail fixture;
  int tmdbFetches = 0;

  @override
  DetialState build(String detailUrl, {required ExtensionMeta meta}) {
    return DetialState(
      selectedGroup: ValueNotifier<int>(0),
      detailInfo: fixture,
      status: DetialStatus.ready,
    );
  }

  @override
  Future<void> fetchTMDBDetail(String title, String mediaType) async {
    tmdbFetches++;
  }
}

Widget _harness(Widget child) => FTheme(
  data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
  child: MaterialApp(
    supportedLocales: FLocalizations.supportedLocales,
    localizationsDelegates: [
      I18nUtils.flutterI18nDelegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

Future<(_FakeDetial, DetialProvider)> _pump(
  WidgetTester tester,
  Widget Function(DetialProvider detailPr) childBuilder,
) async {
  final detailPr = detialProvider(_url, meta: _meta());
  final fake = _FakeDetial(_protoDetail());
  final container = ProviderContainer(
    overrides: [detailPr.overrideWith(() => fake)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _harness(childBuilder(detailPr)),
    ),
  );
  return (fake, detailPr);
}

Detail _detail({List<String>? tags}) => Detail(
  title: 'One Piece',
  detailUrl: _url,
  package: 'test.pkg',
  tags: tags,
);

void main() {
  setUp(() {
    MiruSettings.seedDefaultsForTest();
  });

  testWidgets('renders the extension detail tags as chips', (tester) async {
    final (fake, detailPr) = await _pump(
      tester,
      (pr) => DetailTagChips(
        detail: _detail(tags: ['Action', 'Adventure']),
        meta: _meta(),
        detailPr: pr,
      ),
    );
    await tester.pump();

    expect(find.text('Action'), findsOneWidget);
    expect(find.text('Adventure'), findsOneWidget);
    // Metadata tags win — no TMDB search is spent on genres never rendered.
    expect(fake.tmdbFetches, 0);
  });

  testWidgets('tapping a chip stars the tag and flips the variant', (
    tester,
  ) async {
    await _pump(
      tester,
      (pr) => DetailTagChips(
        detail: _detail(tags: ['Action']),
        meta: _meta(),
        detailPr: pr,
      ),
    );
    await tester.pump();

    FBadgeVariant chipVariant() => tester
        .widget<FBadge>(
          find.ancestor(of: find.text('Action'), matching: find.byType(FBadge)),
        )
        .variant;
    expect(chipVariant(), FBadgeVariant.outline);

    await tester.tap(find.text('Action'));
    // forui's FTappable arms 100ms press/exit timers on a tap — advance past
    // them or the test ends with a pending timer.
    await tester.pump(const Duration(milliseconds: 150));

    expect(chipVariant(), FBadgeVariant.primary);
    expect(MiruSettings.getFavoriteTags(), contains('Action'));
  });

  testWidgets('falls back to TMDB only when the extension ships no tags', (
    tester,
  ) async {
    final (fake, detailPr) = await _pump(
      tester,
      (pr) => DetailTagChips(detail: _detail(), meta: _meta(), detailPr: pr),
    );
    await tester.pump();

    expect(fake.tmdbFetches, 1);
    // The fake TMDB detail never resolves, so nothing renders yet.
    expect(find.byType(SmallBadge), findsNothing);
  });

  testWidgets('no tags and fallback disabled renders nothing', (tester) async {
    final (fake, detailPr) = await _pump(
      tester,
      (pr) => DetailTagChips(
        detail: _detail(),
        meta: _meta(),
        detailPr: pr,
        tmdbFallback: false,
      ),
    );
    await tester.pump();

    expect(fake.tmdbFetches, 0);
    expect(find.byType(SmallBadge), findsNothing);
  });

  testWidgets('metadataTagsOf trims, dedupes and drops the type label', (
    tester,
  ) async {
    final tags = DetailTagChips.metadataTagsOf(
      _detail(tags: ['Action', ' Action ', 'Action', 'media.video', '']),
      ExtensionType.bangumi,
    );

    expect(tags, ['Action']);
  });
}
