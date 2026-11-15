/// Mirrors test/ui/features/detail/detail_tag_chips_test.dart states for the
/// catalog.
///
/// skipped: metadataTagsOf trims/dedupes/drops the type label — a pure
/// function unit test with no widget state to mirror.
///
/// The TMDB-fallback states render from the same `_FakeDetial` the test
/// builds (its `fetchTMDBDetail` is a counted no-op), so nothing needs a
/// real TMDB/gRPC backend. i18n keys render raw here — expected.
library;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/ui/features/detail/widget/detail_tag_chips.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

const _url = 'https://example.com/one-piece';

WidgetbookComponent buildDetailTagChipsComponent() {
  return WidgetbookComponent(
    name: 'DetailTagChips',
    useCases: [
      WidgetbookUseCase(
        name: 'Extension tags — chips from metadata',
        builder: _metadataTags,
      ),
      WidgetbookUseCase(
        name: 'Starred toggle — tap a chip (outline → primary)',
        builder: _starredToggle,
      ),
      WidgetbookUseCase(
        name: 'TMDB fallback pending — no shipped tags, nothing yet',
        builder: _tmdbFallbackPending,
      ),
      WidgetbookUseCase(
        name: 'Fallback disabled — renders nothing',
        builder: _fallbackDisabled,
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

Detail _detail({List<String>? tags}) => Detail(
  title: 'One Piece',
  detailUrl: _url,
  package: 'test.pkg',
  tags: tags,
);

/// The fixture the test's fake serves through `DetialState.detailInfo`.
proto.Detail _protoDetail() => proto.Detail()
  ..title = 'One Piece'
  ..detailUrl = _url
  ..package = 'test.pkg';

/// [Detial] serving the fixture without gRPC, counting TMDB detail fetches
/// so the fallback states can prove the chips' source choice.
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

Widget _chips(
  BuildContext context, {
  List<String>? tags,
  bool tmdbFallback = true,
}) {
  final detailPr = detialProvider(_url, meta: _meta());
  final container = ProviderContainer(
    overrides: [detailPr.overrideWith(() => _FakeDetial(_protoDetail()))],
  );
  return UncontrolledProviderScope(
    container: container,
    child: catalogFrame(
      DetailTagChips(
        detail: _detail(tags: tags),
        meta: _meta(),
        detailPr: detailPr,
        tmdbFallback: tmdbFallback,
      ),
    ),
  );
}

Widget _metadataTags(BuildContext context) =>
    _chips(context, tags: ['Action', 'Adventure']);

Widget _starredToggle(BuildContext context) =>
    _chips(context, tags: ['Action']);

Widget _tmdbFallbackPending(BuildContext context) => _chips(context);

Widget _fallbackDisabled(BuildContext context) =>
    _chips(context, tmdbFallback: false);
