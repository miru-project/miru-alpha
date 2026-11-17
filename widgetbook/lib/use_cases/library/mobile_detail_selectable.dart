/// Mirrors test/ui/features/detail/mobile_detail_selectable_test.dart
/// states for the catalog.
///
/// The selectable title/description are the hero's existing visual states
/// (already mirrored on the MobileDetailHero component in
/// mobile_detail_cards.dart — SelectionArea is invisible chrome), so the
/// new surface here is the episode list's native [FSelect] group picker:
/// the catalog user opens it by tapping the field, exactly like the test
/// taps it; the picked group swaps the list (behavior-only in the test).
/// i18n keys render raw here (no delegates — expected).
library;

import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_silverlist.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:widgetbook/widgetbook.dart';

const _url = 'https://example.com/one-piece';

List<WidgetbookComponent> buildMobileDetailSelectableComponents() {
  return [
    WidgetbookComponent(
      name: 'MobileDetailSilverlist',
      useCases: [
        WidgetbookUseCase(
          name: 'Group select — native FSelect (tap to open)',
          builder: _groupSelect,
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

/// Two episode groups so the picker has something to switch to.
proto.Detail _protoDetail() => proto.Detail()
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
  ]);

class _FakeDownloads extends DownloadNotifier {
  @override
  AsyncValue<DownloadState> build() => AsyncData(DownloadState());
}

/// [Detial] that serves the fixture immediately, so the list renders its
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

Widget _groupSelect(BuildContext context) {
  MiruSettings.seedDefaults();
  final meta = _meta();
  final fixture = _protoDetail();
  final detailPr = detialProvider(_url, meta: meta);
  final container = ProviderContainer(
    overrides: [
      detailPr.overrideWith(() => _FakeDetial(fixture)),
      downloadProvider.overrideWith(_FakeDownloads.new),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
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
}
