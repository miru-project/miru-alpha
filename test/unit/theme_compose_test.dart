import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

void main() {
  test('zinc base + red primary: greyscale from zinc, primary from red', () {
    final c = ThemeUtils.composeColors('zinc', 'red', true);
    // Light background is subtly tinted towards the zinc border (not pure
    // white) so the base colour is perceptible on surfaces.
    expect(c.background.toARGB32(), 0xFFF2F2F3);
    expect(c.muted.toARGB32(), 0xFFF4F4F5); // zinc muted
    expect(c.border.toARGB32(), 0xFFE4E4E7); // zinc border
    expect(c.primary.toARGB32(), 0xFFC10007); // red primary (light)
    expect(c.primaryForeground.toARGB32(), 0xFFFEF2F2);
  });

  test('primary none inherits the base primary', () {
    final base = ThemeUtils.composeColors('mauve', 'none', true);
    expect(base.primary.toARGB32(), 0xFF1D161E); // mauve own primary
    expect(base.primaryForeground.toARGB32(), 0xFFFAFAFA);
  });

  test('dark stone base + teal primary', () {
    final c = ThemeUtils.composeColors('stone', 'teal', false);
    expect(c.background.toARGB32(), 0xFF0C0A09); // stone dark bg
    expect(c.primary.toARGB32(), 0xFF005F5A); // teal dark primary
  });

  test('all 7 bases and 18 primary options compose without error', () {
    for (final b in baseColorNames) {
      for (final p in primaryColorNames) {
        expect(ThemeUtils.composeColors(b, p, true), isA<FColors>());
        expect(ThemeUtils.composeColors(b, p, false), isA<FColors>());
      }
    }
    expect(baseColorNames.length, 7);
    expect(primaryColorNames.length, 18);
  });

  test('changing the primary re-derives dependent widget styles', () {
    // FThemeData(colors:) re-derives every widget style via `.inherit(colors:)`,
    // so switching the primary must change colour-dependent styles too.
    final zincRed = ThemeUtils.resolveTheme('zinc', 'red').desktop;
    final zincSky = ThemeUtils.resolveTheme('zinc', 'sky').desktop;

    // The FColors themselves differ.
    expect(zincRed.colors.primary, isNot(zincSky.colors.primary));

    // A derived, colour-dependent style differs as well (focused outline uses
    // colors.primary), proving the whole theme graph updates, not just FColors.
    expect(
      zincRed.style.focusedOutlineStyle.color,
      isNot(zincSky.style.focusedOutlineStyle.color),
    );
    expect(zincRed.style.focusedOutlineStyle.color, zincRed.colors.primary);
  });

  test('every base has a distinct, non-white tinted light background', () {
    final backgrounds = <String, int>{};
    for (final b in baseColorNames) {
      final colors = ThemeUtils.composeColors(b, 'none', true);
      backgrounds[b] = colors.background.toARGB32();
    }
    // No base is left as pure white -> the tint is applied.
    for (final entry in backgrounds.entries) {
      expect(
        entry.value,
        isNot(0xFFFFFFFF),
        reason:
            '${entry.key} light background should be tinted, not pure white',
      );
    }
    // All 7 bases produce a unique background so they are distinguishable.
    expect(backgrounds.values.toSet().length, baseColorNames.length);
  });

  test('background tint also distinguishes bases on the card surface', () {
    final zinc = ThemeUtils.composeColors('zinc', 'none', true);
    final mist = ThemeUtils.composeColors('mist', 'none', true);
    expect(zinc.card, isNot(mist.card));
    expect(zinc.background, isNot(mist.background));
  });

  test('changing the base re-derives neutral surface styles', () {
    // Light-mode cards are white for every base, so compare in dark mode where
    // each base has a distinct card surface.
    final zinc = ThemeUtils.resolveDarkTheme('zinc', 'none').desktop;
    final taupe = ThemeUtils.resolveDarkTheme('taupe', 'none').desktop;

    // Different base => different neutral scale (e.g. secondary) and card surface.
    expect(zinc.colors.secondary, isNot(taupe.colors.secondary));
    expect(zinc.cardStyle.decoration.color, zinc.colors.card);
    expect(taupe.cardStyle.decoration.color, taupe.colors.card);
    expect(
      zinc.cardStyle.decoration.color,
      isNot(taupe.cardStyle.decoration.color),
    );
  });

  test(
    'tintStrength 0 leaves light background pure white (forui_cli faithful)',
    () {
      final colors = ThemeUtils.composeColors(
        'zinc',
        'none',
        true,
        tintStrength: 0,
      );
      expect(colors.background.toARGB32(), 0xFFFFFFFF);
      expect(colors.card.toARGB32(), 0xFFFFFFFF);
    },
  );

  test('higher tintStrength produces a stronger per-base background tint', () {
    final weak = ThemeUtils.composeColors(
      'zinc',
      'none',
      true,
      tintStrength: 0.1,
    );
    final strong = ThemeUtils.composeColors(
      'zinc',
      'none',
      true,
      tintStrength: 0.9,
    );
    // Both are non-white, but the stronger tint is further from pure white.
    expect(weak.background.toARGB32(), isNot(0xFFFFFFFF));
    expect(strong.background.toARGB32(), isNot(0xFFFFFFFF));
    // 0.1 -> 0xFCFCFC, 0.9 -> 0xF4F4F5; the red channel differs.
    expect(
      (strong.background.r - 255).abs(),
      greaterThan((weak.background.r - 255).abs()),
    );
  });

  test(
    'tint only affects light surfaces, dark backgrounds stay base-distinct',
    () {
      final light = ThemeUtils.composeColors(
        'taupe',
        'none',
        true,
        tintStrength: 0.5,
      );
      final dark = ThemeUtils.composeColors(
        'taupe',
        'none',
        false,
        tintStrength: 0.5,
      );
      // light is tinted away from pure white; dark is untouched (still opaque).
      expect(light.background.toARGB32(), isNot(0xFFFFFFFF));
      expect(dark.background.a, 1.0);
      expect(dark.background.toARGB32(), 0xFF0C0A09); // taupe dark bg
    },
  );
}
