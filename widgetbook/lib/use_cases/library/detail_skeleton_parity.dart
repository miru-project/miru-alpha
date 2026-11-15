/// Mirrors test/ui/features/detail/detail_skeleton_parity_test.dart states
/// for the catalog.
///
/// Both parity phases pump [MobileLoadedPage] with the SAME partial info the
/// test builds: one "Season 1" group of six episodes, empty cover, and a
/// [Detial] fake that serves the fixture immediately (`ready`) or stays in
/// `loading` — the state where the loaded page renders its skeleton instead
/// of a second, plainer shell. The i18n keys render raw here (no delegates
/// in the catalog — expected).
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
import 'package:miru_alpha/ui/features/detail/mobile_loaded_page.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

const _url = 'https://example.com/one-piece';

WidgetbookComponent buildDetailSkeletonParityComponent() {
  return WidgetbookComponent(
    name: 'MobileLoadedPage',
    useCases: [
      WidgetbookUseCase(
        name: 'Ready — fetched content (parity fixture)',
        builder: _readyContent,
      ),
      WidgetbookUseCase(
        name: 'Loading — Detial resolving (the skeleton shows)',
        builder: _loadingSkeleton,
      ),
    ],
  );
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

/// The fetched detail, before parsing: one group of six episodes.
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

/// Empty download state so episode tiles render their not-downloaded branch
/// without subscribing to the download stream.
class _FakeDownloads extends DownloadNotifier {
  @override
  AsyncValue<DownloadState> build() => AsyncData(DownloadState());
}

/// One meta / detailPr pair shared by the override and the page — riverpod
/// family equality keys on these instances, exactly like the test's own
/// `_verifyParity` builds them.
(ProviderContainer, DetialProvider) _scoped(Detial fake) {
  final meta = _meta();
  final detailPr = detialProvider(_url, meta: meta);
  final container = ProviderContainer(
    overrides: [
      detailPr.overrideWith(() => fake),
      downloadProvider.overrideWith(_FakeDownloads.new),
    ],
  );
  return (container, detailPr);
}

Widget _page(BuildContext context, {required bool ready}) {
  final fixture = _protoDetail();
  final detail = MiruCoreEndpoint.detailFromProto(fixture);
  final (container, detailPr) = _scoped(
    ready ? _FakeDetial(fixture) : _LoadingDetial(),
  );
  return UncontrolledProviderScope(
    container: container,
    child: PhoneFrame(
      child: MobileLoadedPage(
        detail: detail,
        meta: _meta(),
        detailUrl: _url,
        detailPr: detailPr,
      ),
    ),
  );
}

Widget _readyContent(BuildContext context) => _page(context, ready: true);

Widget _loadingSkeleton(BuildContext context) => _page(context, ready: false);
