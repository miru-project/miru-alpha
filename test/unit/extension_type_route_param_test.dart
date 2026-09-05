import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/model.dart';

/// Guards the contract behind the library page's TYPE section: the `?type=`
/// query parameter must be a canonical [ExtensionType] wire string, because
/// [stringToExtensionType] deliberately maps anything else to
/// [ExtensionType.all] — which the router then reads as "no filter".
///
/// The bug this replaces i18n display keys (`media.video`) into the route, so
/// tapping Video / Manga / Novel silently showed an unfiltered list.
void main() {
  group('ExtensionType.routeParam', () {
    test('round-trips through stringToExtensionType for every type', () {
      for (final type in ExtensionType.values) {
        expect(
          stringToExtensionType(type.routeParam),
          type,
          reason: '${type.name}.routeParam must parse back to itself',
        );
      }
    });

    test('is the raw enum name, not an i18n key', () {
      expect(ExtensionType.bangumi.routeParam, 'bangumi');
      expect(ExtensionType.manga.routeParam, 'manga');
      expect(ExtensionType.fikushon.routeParam, 'fikushon');
    });
  });

  group('stringToExtensionType', () {
    test('display labels are not valid filter values', () {
      // These are exactly the strings the broken routes used. Each one falls
      // back to `all`, which the router treats as "clear the filter".
      for (final label in ['media.video', 'media.manga', 'media.novel']) {
        expect(stringToExtensionType(label), ExtensionType.all);
      }
    });

    test('unknown values fall back to all rather than throwing', () {
      expect(stringToExtensionType('not-a-type'), ExtensionType.all);
    });
  });
}
