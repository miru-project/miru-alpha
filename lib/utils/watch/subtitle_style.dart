import 'package:flutter/widgets.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// The mdk property names this style writes. Source: mdk-sdk Player-APIs,
/// "subtitle properties" — these apply to text subtitles (srt/subrip/text);
/// ASS/SSA carry their own style and ignore them.
abstract class SubtitleProperty {
  static const font = 'subtitle.font';
  static const fontSize = 'subtitle.font.size';
  static const bold = 'subtitle.font.bold';
  static const italic = 'subtitle.font.italic';
  static const underline = 'subtitle.font.underline';
  static const strikeout = 'subtitle.font.strikeout';
  static const color = 'subtitle.color';
  static const colorOutline = 'subtitle.color.outline';
  static const colorBackground = 'subtitle.color.background';
  static const border = 'subtitle.border';
  static const alignmentX = 'subtitle.alignment.x';
  static const alignmentY = 'subtitle.alignment.y';
  static const marginY = 'subtitle.margin.y';
  static const box = 'subtitle.box';
  static const scale = 'subtitle.scale';
  static const delay = 'subtitle.delay';
}

/// The user's subtitle look, resolved from the persisted settings.
///
/// Immutable and dependency-free so the software overlay and the native mdk
/// path read the same values — the two renderers can never disagree about size
/// or colour.
@immutable
class SubtitleStyle {
  const SubtitleStyle({
    required this.fontSize,
    required this.bold,
    required this.italic,
    required this.underline,
    required this.strikeout,
    required this.fontFamily,
    required this.fontColor,
    required this.outlineColor,
    required this.outlineSize,
    required this.backgroundColor,
    required this.backgroundOpacity,
    required this.textAlign,
    required this.verticalAlign,
    required this.delay,
  });

  final double fontSize;
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikeout;
  final String fontFamily;
  final Color fontColor;
  final Color outlineColor;
  final double outlineSize;
  final Color backgroundColor;

  /// 0..1; mdk's box alpha is derived from it.
  final double backgroundOpacity;

  /// 0 left, 1 center, 2 right (the persisted `TextAlign` index).
  final int textAlign;

  /// 'top', 'center' or 'bottom' — where the cue sits vertically.
  final String verticalAlign;

  /// Seconds shifted against the video; positive shows cues later. mdk lists
  /// it under the general subtitle properties, not the text-only group, so it
  /// applies to ASS/SSA cues too.
  final double delay;

  static SubtitleStyle current() {
    Color colorOf(String raw, Color fallback) {
      final value = int.tryParse(raw);
      return value == null ? fallback : Color(value);
    }

    return SubtitleStyle(
      fontSize: MiruSettings.getSettingSync<double>(
        SettingKey.subtitleFontSize,
      ),
      bold:
          MiruSettings.getSettingSync<String>(SettingKey.subtitleFontWeight) ==
          'bold',
      italic: MiruSettings.getSettingSync<bool>(SettingKey.subtitleItalic),
      underline: MiruSettings.getSettingSync<bool>(
        SettingKey.subtitleUnderline,
      ),
      strikeout: MiruSettings.getSettingSync<bool>(
        SettingKey.subtitleStrikeout,
      ),
      fontFamily: MiruSettings.getSettingSync<String>(
        SettingKey.subtitleFontFamily,
      ),
      fontColor: colorOf(
        MiruSettings.getSettingSync<String>(SettingKey.subtitleFontColor),
        const Color(0xFFFFFFFF),
      ),
      outlineColor: colorOf(
        MiruSettings.getSettingSync<String>(SettingKey.subtitleOutlineColor),
        const Color(0xFF000000),
      ),
      outlineSize: MiruSettings.getSettingSync<double>(
        SettingKey.subtitleOutlineSize,
      ),
      backgroundColor: colorOf(
        MiruSettings.getSettingSync<String>(SettingKey.subtitleBackgroundColor),
        const Color(0xFF000000),
      ),
      backgroundOpacity: MiruSettings.getSettingSync<double>(
        SettingKey.subtitleBackgroundOpacity,
      ),
      textAlign: MiruSettings.getSettingSync<int>(SettingKey.subtitleTextAlign),
      verticalAlign: MiruSettings.getSettingSync<String>(
        SettingKey.subtitleVerticalAlign,
      ),
      // A key added to a live process predates the cache, so it can be absent
      // even though a default exists — read it null-safely.
      delay: MiruSettings.getSetting<double>(SettingKey.subtitleDelay) ?? 0.0,
    );
  }

  /// mdk's vertical alignment: -1 top, 0 center, 1 bottom.
  int get mdkAlignmentY => switch (verticalAlign) {
    'top' => -1,
    'center' => 0,
    _ => 1,
  };

  /// The mdk property/value pairs for this style.
  Map<String, String> toMdkProperties() {
    // A zero-alpha colour IS the "none" choice: it must win over the opacity
    // slider, which would otherwise paint its own alpha onto the black RGB and
    // bring the box back as a grey slab.
    final boxAlpha = backgroundColor.a == 0
        ? 0
        : (backgroundOpacity * 255).round();
    final background = backgroundColor.withValues(alpha: boxAlpha / 255);
    return {
      SubtitleProperty.font: fontFamily,
      SubtitleProperty.fontSize: fontSize.toStringAsFixed(1),
      SubtitleProperty.bold: bold ? '1' : '0',
      SubtitleProperty.italic: italic ? '1' : '0',
      SubtitleProperty.underline: underline ? '1' : '0',
      SubtitleProperty.strikeout: strikeout ? '1' : '0',
      SubtitleProperty.color: _rgba(fontColor),
      SubtitleProperty.colorOutline: _rgba(outlineColor),
      SubtitleProperty.colorBackground: _rgba(background),
      SubtitleProperty.border: outlineSize.toStringAsFixed(1),
      SubtitleProperty.alignmentX: '${textAlign - 1}',
      SubtitleProperty.alignmentY: '$mdkAlignmentY',
      SubtitleProperty.marginY: (fontSize * 0.5).round().toString(),
      SubtitleProperty.box: boxAlpha > 0 ? '1' : '-1',
      // subtitle.scale is the only style property mdk honours for ASS/SSA
      // (Player.h: "style properties for all subtitle types(text, ass/ssa …)").
      // Text tracks use subtitle.font.size above; this gives the size slider a
      // uniform scale on ASS too. 22 is mdk's default text size.
      SubtitleProperty.scale: (fontSize / 22).toStringAsFixed(3),
      SubtitleProperty.delay: delay.toStringAsFixed(2),
    };
  }

  /// mdk wants `0x` + 8 hex digits in **RGBA** byte order (its default outline
  /// is `0x000000ff` = opaque black). Flutter's `toARGB32` is ARGB, so the
  /// bytes must be reordered — emitting ARGB makes libass read the wrong
  /// colour (e.g. yellow `0xffffcc00` instead of `0xffcc00ff`).
  static String _rgba(Color color) {
    final argb = color.toARGB32();
    final a = (argb >> 24) & 0xFF;
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    final rgba = (r << 24) | (g << 16) | (b << 8) | a;
    return '0x${rgba.toRadixString(16).padLeft(8, '0')}';
  }

}
