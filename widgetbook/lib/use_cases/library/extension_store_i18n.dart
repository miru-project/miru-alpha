/// Mirrors test/ui/features/extension/extension_store_i18n_test.dart states
/// for the catalog.
///
/// skipped: the language-switch states (`可用`, `全部`, the Chinese status
/// sheet) — they need the shipped `I18nUtils.flutterI18nDelegate` and the
/// app's asset catalogs, which the catalog deliberately never loads (the
/// brief renders i18n as raw keys). The store screen itself is the same
/// widget the header file mirrors; the use-case below shows that state the
/// way the catalog can render it, with the shipped-label assertions
/// remaining the test's job.
library;

import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import 'extension_store_header.dart';

/// The i18n canary's states, as the catalog can render them.
List<WidgetbookUseCase> extensionStoreI18nUseCases() {
  return [
    WidgetbookUseCase(
      name: 'i18n canary — store strip (raw keys without delegates)',
      builder: _rawKeyStore,
    ),
  ];
}

Widget _rawKeyStore(BuildContext context) => buildSeededStore(context);
