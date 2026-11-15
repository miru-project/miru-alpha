/// Mirrors test/ui/features/detail/detail_loading_skeleton_test.dart states
/// for the catalog.
///
/// [MobileDetailSkeletonPage] is a plain stateless widget — no providers — so
/// every state renders from the test's own fixture values. The i18n keys the
/// test resolves through its real delegate render as raw keys here (the
/// catalog never loads delegates — expected).
library;

import 'dart:convert';

import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/features/detail/widget/detail_loading_skeleton.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

WidgetbookComponent buildDetailLoadingSkeletonComponent() {
  return WidgetbookComponent(
    name: 'MobileDetailSkeletonPage',
    useCases: [
      WidgetbookUseCase(
        name: 'Tapped card — partial info + section skeletons',
        builder: _tappedCardPhase,
      ),
      WidgetbookUseCase(
        name: 'No tapped item — extension-name fallback',
        builder: _noItemFallback,
      ),
      WidgetbookUseCase(
        name: 'Narrowest phone (320px) — long title ellipsises',
        builder: _narrowPhone,
      ),
      WidgetbookUseCase(
        name: 'Detail-known — fetched data fills the sections',
        builder: _detailKnownPhase,
      ),
    ],
  );
}

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

Widget _tappedCardPhase(BuildContext context) {
  return PhoneFrame(
    child: MobileDetailSkeletonPage(
      meta: _meta('Miru Test'),
      items: [_item('One Piece')],
      index: 0,
    ),
  );
}

Widget _noItemFallback(BuildContext context) {
  return PhoneFrame(
    child: MobileDetailSkeletonPage(
      meta: _meta('Miru Test'),
      items: null,
      index: 0,
    ),
  );
}

/// The 320px surface of the overflow test, framed like [PhoneFrame].
Widget _narrowPhone(BuildContext context) {
  return Center(
    child: SizedBox(
      width: 320,
      height: 740,
      child: ColoredBox(
        color: context.theme.colors.background,
        child: ClipRect(
          child: MobileDetailSkeletonPage(
            meta: _meta('Miru Test'),
            items: [_item('A very long title that should ellipsise cleanly')],
            index: 0,
          ),
        ),
      ),
    ),
  );
}

Widget _detailKnownPhase(BuildContext context) {
  final detail = MiruCoreEndpoint.detailFromProto(_protoDetail());
  return PhoneFrame(
    child: MobileDetailSkeletonPage(meta: _meta('Miru Test'), detail: detail),
  );
}
