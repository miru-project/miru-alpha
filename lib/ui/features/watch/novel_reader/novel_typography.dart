import 'package:flutter/widgets.dart';
import 'package:miru_alpha/model/model.dart';

/// The paper and ink a chapter is printed on.
///
/// Taken from the reader's paper palette. The floating HUD keeps the app's own
/// chrome, because in the reference design the settings sheet and the control
/// capsule stay zinc-dark whichever paper is selected — only the page behind
/// them changes.
@immutable
class NovelPaper {
  const NovelPaper({
    required this.background,
    required this.foreground,
    required this.muted,
    required this.quoteSurface,
    required this.quoteBorder,
    required this.border,
  });

  /// Page fill.
  final Color background;

  /// Body prose.
  final Color foreground;

  /// Chapter metadata, the ornament rule and any de-emphasised line.
  final Color muted;

  /// Fill of an inset quotation card.
  final Color quoteSurface;

  /// Hairline around an inset quotation card.
  final Color quoteBorder;

  /// Hairline rules and the card edge of an embedded image.
  final Color border;

  /// The paper for [theme].
  static NovelPaper of(NovelTheme theme) => switch (theme) {
    NovelTheme.midnight => const NovelPaper(
      background: Color(0xFF09090B),
      foreground: Color(0xFFE4E4E7),
      muted: Color(0xFFA1A1AA),
      quoteSurface: Color(0x6618181B),
      quoteBorder: Color(0x1AFFFFFF),
      border: Color(0x14FFFFFF),
    ),
    NovelTheme.charcoal => const NovelPaper(
      background: Color(0xFF18181B),
      foreground: Color(0xFFD4D4D8),
      muted: Color(0xFF8A8A93),
      quoteSurface: Color(0x66F4F4F5),
      quoteBorder: Color(0x1FFFFFFF),
      border: Color(0x14FFFFFF),
    ),
    NovelTheme.sepia => const NovelPaper(
      background: Color(0xFF2B221B),
      foreground: Color(0xFFE7D9C5),
      muted: Color(0xFFA89277),
      quoteSurface: Color(0x66F5E6D0),
      quoteBorder: Color(0x1FF5E6D0),
      border: Color(0x1FF5E6D0),
    ),
    NovelTheme.paper => const NovelPaper(
      background: Color(0xFFF4EFE6),
      foreground: Color(0xFF3A322A),
      muted: Color(0xFF8A7A66),
      quoteSurface: Color(0x66E8DFCD),
      quoteBorder: Color(0x333A322A),
      border: Color(0x1F3A322A),
    ),
  };
}

/// Font stacks for the reading typefaces.
///
/// The app bundles no font files, so each entry is a *stack* the platform
/// resolves from left to right and the generic family at the end is the
/// backstop. That is why the settings sheet previews the stack's first name
/// rather than promising a face that may not exist on the device.
const Map<NovelFontFamily, List<String>> novelFontFamilyFallback = {
  NovelFontFamily.serif: [
    'Georgia',
    'Times New Roman',
    'Noto Serif',
    'Liberation Serif',
    'serif',
  ],
  NovelFontFamily.sans: ['Inter', 'Roboto', 'Noto Sans', 'Arial', 'sans-serif'],
  NovelFontFamily.mono: [
    'JetBrains Mono',
    'Roboto Mono',
    'Menlo',
    'Consolas',
    'monospace',
  ],
};

/// The heading shown on the font-family button in the settings sheet.
const Map<NovelFontFamily, String> novelFontFamilyName = {
  NovelFontFamily.serif: 'Merriweather',
  NovelFontFamily.sans: 'Inter',
  NovelFontFamily.mono: 'JetBrains Mono',
};

/// Typography of a chapter: the face, the size and the leading.
///
/// Every style the canvas draws is derived from these three values, so the
/// settings sheet's three sliders change the whole page coherently — and the
/// pagination pass measures with the same values it renders with, which is what
/// keeps a page break from landing in the wrong place.
@immutable
class NovelTypography {
  const NovelTypography({
    required this.family,
    required this.fontSize,
    required this.lineHeight,
  });

  final NovelFontFamily family;
  final double fontSize;

  /// Leading as a multiple of [fontSize].
  final double lineHeight;

  /// Distance between two baselines, in logical px. This is the unit the
  /// reader's "line N of M" readout counts.
  double get lineExtent => fontSize * lineHeight;

  TextStyle _style({
    double? size,
    double? height,
    Color? color,
    FontWeight? weight,
    FontStyle? style,
  }) {
    final resolvedSize = size ?? fontSize;
    return TextStyle(
      fontFamilyFallback: novelFontFamilyFallback[family],
      fontSize: resolvedSize,
      // Null keeps the font's own leading, which is what a heading wants; body
      // text and quotes get [lineHeight] so the sliders drive the prose.
      height: height ?? (size == null ? lineHeight : null),
      color: color,
      fontWeight: weight,
      fontStyle: style,
      // Justified prose looks wrong with the default ligature-free rendering on
      // a narrow column, and small-caps numerals in chapter metadata read as
      // noise at these sizes.
      fontFeatures: const [FontFeature.enable('liga')],
    );
  }

  /// Running prose.
  TextStyle body({required Color color}) => _style(color: color);

  /// The chapter title under the "Chapter One" eyebrow.
  TextStyle chapterTitle({required Color color}) =>
      _style(size: fontSize * 1.85, height: 1.25, color: color, weight: .w500);

  /// The "Chapter One" eyebrow above the title.
  TextStyle eyebrow({required Color color}) => _style(
    size: fontSize * 0.62,
    height: 1.2,
    color: color,
    weight: .w500,
  );

  /// The ❦ ornament between the title and the prose.
  TextStyle ornament({required Color color}) =>
      _style(size: fontSize * 0.78, color: color, style: FontStyle.italic);

  /// The oversized initial that opens a chapter.
  ///
  /// The leading is well under 1 so the cap sits on the first line's baseline
  /// instead of pushing the paragraph down; a body-sized leading would open a
  /// hole under it.
  TextStyle dropCap({required Color color}) => _style(
    size: fontSize * 2.75,
    height: 0.82,
    color: color,
    weight: .w600,
  );

  /// Prose inside an inset quotation card: italic, a touch smaller, and
  /// un-justified so the ragged right edge of a quoted block stays visible.
  TextStyle quote({required Color color}) => _style(
    size: fontSize * 0.92,
    color: color,
    style: FontStyle.italic,
  );

  /// The attribution line closing an inset quotation card.
  TextStyle attribution({required Color color}) => _style(
    size: fontSize * 0.66,
    height: 1.3,
    color: color,
    weight: .w500,
    style: FontStyle.normal,
  );

  /// A short line set apart from the prose, such as "This is what I read:".
  TextStyle aside({required Color color}) => _style(
    size: fontSize * 0.88,
    color: color,
    style: FontStyle.italic,
  );
}

/// Vertical rhythm between blocks, in logical px, at the reference's scale.
///
/// Scaled by the font size so a larger font opens the page up instead of
/// cramming the same gaps between taller paragraphs. The pagination pass adds
/// exactly these to the measured block heights, so the packed pages and the
/// rendered pages agree.
abstract final class NovelSpacing {
  /// Between two prose paragraphs.
  static double paragraphGap(double fontSize) => fontSize * 1.1;

  /// Above the chapter header block.
  static double chapterHeaderTop(double fontSize) => fontSize * 2.2;

  /// Below the chapter header block.
  static double chapterHeaderBottom(double fontSize) => fontSize * 2.4;

  /// Around an inset quotation card, which is set further in than prose.
  static double quoteMargin(double fontSize) => fontSize * 1.4;

  /// Inside an inset quotation card.
  static double quotePadding(double fontSize) => fontSize * 1.5;

  /// Height reserved for an embedded image.
  static double imageHeight(double fontSize) => fontSize * 12;

  /// Gutter between the two columns of [NovelReadMode.doubleColumn].
  static const double columnGap = 24;

  /// Hairline drawn around an inset quotation card and an embedded image.
  ///
  /// A `Border.all` adds its width to the box it draws, so the pagination pass
  /// counts this too. Leaving it out of the measurement under-reports every card
  /// by two pixels, which is a page overflow by exactly that much.
  static const double cardBorderWidth = 1;
}
