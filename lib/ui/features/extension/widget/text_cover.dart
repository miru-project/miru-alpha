import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:forui/forui.dart';

import 'package:miru_alpha/domain/models/extension.dart';

/// Text-as-image cover for an extension whose icon is missing or failed to
/// load: a flat tonal tile carrying a category glyph with the extension's
/// initials as a corner badge.
///
/// The hue comes from an FNV-1a hash of the seed over a small ramp taken
/// from the store reference's avatar colours (amber, coral, teal, blue,
/// indigo, violet). [String.hashCode] is deliberately avoided - it is not
/// stable across VM runs, so the colour would drift between launches.
/// Fill and letter are re-derived from the theme's brightness instead of
/// reusing the reference's gradient and light-ring effect, so the tile
/// reads as this app's surface in both light and dark.
class TextCover extends StatelessWidget {
  const TextCover({
    super.key,
    required this.seed,
    this.label,
    this.icon,
    this.size = 44,
    this.borderRadius,
  });

  /// Stable identifier the hue is derived from - the extension's name.
  final String seed;

  /// Text to print; defaults to [initialsOf] of [seed].
  final String? label;

  /// Category glyph drawn big in the tile's centre, with [label] reduced to
  /// a corner badge (the reference's `play_circle` + "CR" corner treatment).
  /// When null the tile renders the initials alone.
  final IconData? icon;

  /// Edge length of the square tile.
  final double size;

  /// Clip token, so the tile matches the frame it sits in.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final text = label ?? initialsOf(seed);
    final pair = _tonalPair(context.theme.colors.brightness, _hueOf(seed));
    return Semantics(
      // Decorative: the extension name renders beside the tile.
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: pair.fill,
          borderRadius: borderRadius ?? BorderRadius.circular(10),
        ),
        child: icon == null
            ? Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: size * 0.36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1,
                      color: pair.foreground,
                    ),
                  ),
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: size * 0.44, color: pair.foreground),
                  Positioned(
                    right: size * 0.09,
                    bottom: size * 0.07,
                    child: Text(
                      text,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: size * 0.18,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        color: pair.foreground.withAlpha(205),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Up to three initials. A name with camel-case humps splits into words and
/// takes their first letters (`ExampleSite` -> `ES`, `SampleNovel` -> `SN`);
/// anything else takes its first two characters (`Crunchyroll` -> `CR`,
/// `exampleb.si` -> `EX`). Empty input renders `?`.
String initialsOf(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  final humped = trimmed.replaceAllMapped(
    RegExp(r'([a-z0-9])([A-Z])'),
    (match) => '${match[1]} ${match[2]}',
  );
  if (humped != trimmed) {
    final words = humped
        .split(RegExp(r'[^0-9A-Za-z]+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.length >= 2) {
      return words.take(3).map((word) => word[0].toUpperCase()).join();
    }
  }
  return trimmed.substring(0, math.min(2, trimmed.length)).toUpperCase();
}

/// Hues borrowed from the reference's avatar ramp: amber, coral, teal, blue,
/// indigo, violet.
const List<double> _hues = [24, 8, 174, 217, 238, 262];

/// Category glyph for an extension's [TextCover] tile — the distinct visual
/// the reference pairs with each avatar's initials corner badge. One glyph
/// per manifest type so a source without an icon is still scannable at a
/// glance; unknown/all falls back to the generic package.
IconData extensionTypeIcon(ExtensionType type) => switch (type) {
  ExtensionType.bangumi => FLucideIcons.play,
  ExtensionType.manga => FLucideIcons.bookOpen,
  ExtensionType.fikushon => FLucideIcons.bookMarked,
  ExtensionType.all => FLucideIcons.package,
};

/// FNV-1a over the seed's code units, masked to 32 bits.
double _hueOf(String seed) {
  var hash = 0x811c9dc5;
  for (final unit in seed.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return _hues[hash % _hues.length];
}

/// Flat fill + readable letter for the current brightness: a mid-tone
/// tint with a near-white letter on dark surfaces, a light tint with a
/// deep letter on light ones. Both pairs clear WCAG AA (>= 4.5:1).
({Color fill, Color foreground}) _tonalPair(
  Brightness brightness,
  double hue,
) => switch (brightness) {
  Brightness.dark => (
    fill: HSLColor.fromAHSL(1, hue, 0.52, 0.38).toColor(),
    foreground: HSLColor.fromAHSL(1, hue, 0.65, 0.93).toColor(),
  ),
  Brightness.light => (
    fill: HSLColor.fromAHSL(1, hue, 0.72, 0.90).toColor(),
    foreground: HSLColor.fromAHSL(1, hue, 0.60, 0.28).toColor(),
  ),
};
