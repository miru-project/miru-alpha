/// Mirrors test/ui/features/extension/extension_text_cover_test.dart states
/// for the catalog.
///
/// skipped: the dark/light legibility pair and "tint follows brightness" —
/// the catalog's ThemeAddon is the only theme authority (the brief forbids
/// wrapping in FTheme), so both brightnesses are one theme switch away in
/// the catalog UI; the same tiles render the tested pairs. The initials
/// unit test mirrors visually through the seed row.
///
/// The seed-derived hue is FNV-1a (deterministic across runs), so the same
/// seed keeps its colour and different sources differ — visible directly in
/// the tiles below.
library;

import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/features/extension/widget/text_cover.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

WidgetbookComponent buildTextCoverComponent() {
  return WidgetbookComponent(
    name: 'TextCover',
    useCases: [
      WidgetbookUseCase(
        name: 'Initials — camelCase, flat, single letter, empty',
        builder: _initials,
      ),
      WidgetbookUseCase(
        name: 'Seed stability — same seed keeps its colour (label override)',
        builder: _seedStability,
      ),
      WidgetbookUseCase(
        name: 'Distinct hues per source',
        builder: _distinctHues,
      ),
    ],
  );
}

/// The initials cases of the test's `initialsOf` group: `ExampleSite` → ES,
/// `Crunchyroll` → CR, `exampleb.si` → EX, `M` → M, empty → `?`.
Widget _initials(BuildContext context) {
  return catalogFrame(
    Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final seed in const [
          'ExampleSite',
          'SampleNovel',
          'Crunchyroll',
          'exampleb.si',
          'M',
          '',
        ])
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextCover(seed: seed),
              const SizedBox(height: 4),
              Text(
                seed.isEmpty ? '(empty)' : seed,
                style: context.theme.typography.body.xs,
              ),
            ],
          ),
      ],
    ),
  );
}

/// The label-override rebuild of the test: the same seed with a different
/// label keeps the first tile's fill hue.
Widget _seedStability(BuildContext context) {
  return catalogFrame(
    Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextCover(seed: 'ExampleC'),
            SizedBox(height: 4),
            Text('ExampleC'),
          ],
        ),
        SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextCover(seed: 'ExampleC', label: 'Updated'),
            SizedBox(height: 4),
            Text('ExampleC · label "Updated"'),
          ],
        ),
      ],
    ),
  );
}

/// Different sources get visibly different colours (the test's amber vs
/// ExampleSite assertion, plus the rest of the ramp).
Widget _distinctHues(BuildContext context) {
  return catalogFrame(
    Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final seed in const [
          'Crunchyroll',
          'ExampleSite',
          'ExampleC',
          'SampleNovel',
          'exampleb.si',
        ])
          TextCover(seed: seed, size: 64),
      ],
    ),
  );
}
