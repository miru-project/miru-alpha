import 'package:flutter_test/flutter_test.dart';

import 'package:forui/forui.dart';


import 'package:miru_alpha/model/extension_meta_data.dart';

import 'package:miru_alpha/model/model.dart';

import 'package:miru_alpha/ui/features/search/widget/desktop_search_list_tile.dart';

import 'package:miru_alpha/ui/features/search/widget/extension_load_status.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

import 'package:miru_alpha/utils/theme/theme.dart';

import 'package:miru_alpha/utils/theme/miru_themes.dart';

import 'package:material_ui/material_ui.dart';

ExtensionMeta _meta(
  String pkg,
  String name, {
  String? error,
  String api = 'v2',
  bool nsfw = false,
}) => ExtensionMeta(
  name: name,

  version: '2.0.0',

  author: 't',

  license: 'MIT',

  lang: 'en',

  packageName: pkg,

  webSite: 'https://example.com',

  tags: const [],

  api: api,

  type: ExtensionType.bangumi,

  error: error,

  nsfw: nsfw,
);

Future<void> _pump(WidgetTester tester, ExtensionMeta ext) async {
  await tester.binding.setSurfaceSize(const Size(800, 400));

  addTearDown(() async => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    FTheme(
      data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
      child: MaterialApp(
        home: Scaffold(
          body: Center(child: DesktopSearchListTile(ext: ext)),
        ),
      ),
    ),
  );

  await tester.pump();
}

/// The backend load error renders unwrapped inside a single-line detail; a
/// long one overflows instead of wrapping.
void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);

  testWidgets('a bad extension shows its error on its own wrapping line', (
    tester,
  ) async {
    const longError =
        'package name does not match the file name\r\n'
        ' file name: not_the_package_name.js\r\n'
        ' package name: some-package';

    await _pump(tester, _meta('bad.pkg', 'Broken', error: longError));

    // The name row still holds only the name (and the nsfw badge, absent
    // here) — the error text left the title row.
    expect(find.text('Broken'), findsOneWidget);

    // The error lives on its own line as a Text.rich: the i18n key renders raw
    // under test (the asset bundle is not loaded), so match on the message.
    final plain = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((r) => r.text.toPlainText())
        .firstWhere((t) => t.contains('package name does not match'));

    expect(plain, contains('extension.failed'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('an extension not yet loaded shows the not_loaded line', (
    tester,
  ) async {
    await _pump(tester, _meta('empty.pkg', 'Empty', api: ''));

    expect(find.text('extension.not_loaded'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('a healthy extension shows neither line', (tester) async {
    await _pump(tester, _meta('ok.pkg', 'Fine'));

    expect(find.textContaining('does not match'), findsNothing);

    expect(find.text('extension.not_loaded'), findsNothing);

    expect(tester.takeException(), isNull);
  });

  test('extensionLoadState derives failed vs not-loaded from one meta', () {
    final failed = extensionLoadState(_meta('a', 'A', error: 'boom'));

    expect(failed, isNotNull);

    expect(failed!.failed, isTrue);

    expect(failed.label, 'boom');

    final notLoaded = extensionLoadState(_meta('b', 'B', api: ''));

    expect(notLoaded!.failed, isFalse);

    expect(extensionLoadState(_meta('c', 'C')), isNull);
  });
}
