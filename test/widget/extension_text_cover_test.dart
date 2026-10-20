import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:miru_alpha/ui/features/extension/widget/text_cover.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// The store reference gives imageless extensions a coloured initials tile.
/// The cover must stay deterministic across launches (no `String.hashCode`),
/// keep the letter legible on the tile in BOTH theme brightnesses, and give
/// different sources visibly different colours.
void main() {
  Widget wrap(Widget child, {required MiruPlatformTheme theme}) => FTheme(
    data: ThemeUtils.getThemeData(theme),
    child: MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );

  ({Color fill, Color foreground}) colorsOf(WidgetTester tester) {
    final cover = find.byType(TextCover);
    final container = tester.widget<Container>(
      find.descendant(of: cover, matching: find.byType(Container)).first,
    );
    final text = tester.widget<Text>(
      find.descendant(of: cover, matching: find.byType(Text)),
    );
    final decoration = container.decoration! as BoxDecoration;
    return (fill: decoration.color!, foreground: text.style!.color!);
  }

  double contrastOf(Color a, Color b) {
    final high = max(a.computeLuminance(), b.computeLuminance());
    final low = min(a.computeLuminance(), b.computeLuminance());
    return (high + 0.05) / (low + 0.05);
  }

  group('initialsOf', () {
    test('splits camel-case words into letters', () {
      expect(initialsOf('MangaDex'), 'MD');
      expect(initialsOf('NovelUpdates'), 'NU');
    });

    test('takes the first two characters otherwise', () {
      expect(initialsOf('Crunchyroll'), 'CR');
      expect(initialsOf('nyaa.si'), 'NY');
      expect(initialsOf('M'), 'M');
    });

    test('renders a placeholder for empty input', () {
      expect(initialsOf(''), '?');
      expect(initialsOf('   '), '?');
    });
  });

  testWidgets('dark theme: initials render on a legible tinted cover', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const TextCover(seed: 'Crunchyroll'), theme: MiruThemes.zinc.dark),
    );

    expect(find.text('CR'), findsOneWidget);
    final pair = colorsOf(tester);
    expect(contrastOf(pair.fill, pair.foreground), greaterThanOrEqualTo(4.5));
  });

  testWidgets('light theme: same seed, still legible', (tester) async {
    await tester.pumpWidget(
      wrap(const TextCover(seed: 'Crunchyroll'), theme: MiruThemes.zinc.light),
    );

    expect(find.text('CR'), findsOneWidget);
    final pair = colorsOf(tester);
    expect(contrastOf(pair.fill, pair.foreground), greaterThanOrEqualTo(4.5));
  });

  testWidgets('the tint follows the theme brightness', (tester) async {
    await tester.pumpWidget(
      wrap(const TextCover(seed: 'Crunchyroll'), theme: MiruThemes.zinc.dark),
    );
    final dark = colorsOf(tester);

    await tester.pumpWidget(
      wrap(const TextCover(seed: 'Crunchyroll'), theme: MiruThemes.zinc.light),
    );
    // FTheme cross-fades the palette; one frame still shows the old tint.
    await tester.pump(const Duration(milliseconds: 400));
    final light = colorsOf(tester);

    expect(
      light.fill.computeLuminance(),
      greaterThan(dark.fill.computeLuminance()),
    );
    expect(dark.fill, isNot(light.fill));
  });

  testWidgets('the same seed keeps its colour across rebuilds', (tester) async {
    await tester.pumpWidget(
      wrap(const TextCover(seed: 'Rawkuma'), theme: MiruThemes.zinc.dark),
    );
    final first = colorsOf(tester);

    await tester.pumpWidget(
      wrap(
        const TextCover(seed: 'Rawkuma', label: 'Updated'),
        theme: MiruThemes.zinc.dark,
      ),
    );

    expect(colorsOf(tester).fill, first.fill);
  });

  testWidgets('different sources get different colours', (tester) async {
    await tester.pumpWidget(
      wrap(const TextCover(seed: 'Crunchyroll'), theme: MiruThemes.zinc.dark),
    );
    final amber = colorsOf(tester).fill;

    await tester.pumpWidget(
      wrap(const TextCover(seed: 'MangaDex'), theme: MiruThemes.zinc.dark),
    );

    expect(colorsOf(tester).fill, isNot(amber));
  });
}
