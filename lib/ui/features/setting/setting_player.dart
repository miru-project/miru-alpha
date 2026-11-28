import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/ui/features/setting/widget/subtitle_style_flags_tile.dart';

/// The seek step options, in seconds. 5 is the floor: a smaller step makes a
/// held arrow key crawl, and 120 is already past most viewers' patience.
const List<int> kPlayerSeekSteps = [5, 10, 15, 30, 60, 120];

/// Font sizes the subtitle slider covers, in logical pixels.
const double kSubtitleFontSizeMin = 12;
const double kSubtitleFontSizeMax = 64;

/// The subtitle colour swatches: white, the two extremes a viewer actually
/// picks between, and the theme-friendly greys. A preset row rather than a
/// free colour wheel — the pane ships no new dependency and every choice is
/// guaranteed legible over video.
const Map<String, int> kSubtitleColorChoices = {
  'ffffff': 0xFFFFFFFF,
  '000000': 0xFF000000,
  'ffcc00': 0xFFFFCC00,
  '00e5ff': 0xFF00E5FF,
  'ff4d4d': 0xFFFF4D4D,
  'b0b0b0': 0xFFB0B0B0,
};

/// `none` is the zero alpha colour: it makes mdk switch the background box
/// off (`subtitle.box = -1`), which is the only way to remove it — the swatch
/// row had no way to express "no background" before.
const String kSubtitleColorNone = 'none';
const Map<String, int> kSubtitleBackgroundChoices = {
  kSubtitleColorNone: 0x00000000,
  ...kSubtitleColorChoices,
};

/// Outline (border) width the slider covers, in mdk units.
const double kSubtitleOutlineSizeMax = 6;

/// Subtitle delay range in seconds. Positive shows cues later, negative
/// earlier; 10s each way covers badly-timed sources without letting the slider
/// stack a whole scene of drift.
const double kSubtitleDelayMin = -10;
const double kSubtitleDelayMax = 10;

/// Font families the subtitle picker offers. 'default' leaves mdk's own font
/// selection untouched; the rest are common system families so no asset is
/// bundled and the native renderer resolves them by name.
const List<String> kSubtitleFontChoices = [
  'default',
  'sans-serif',
  'serif',
  'monospace',
];

/// Writes a subtitle style [value] under [key] and, when a live player is
/// passed via [vidPr], re-pushes the style into it so the change is visible at
/// once. Never reads `videoPlayerProvider(null)` — that family key builds a
/// fresh notifier with empty media, whose async `setMedia('')` throws
/// `media open error` (an uncaught PlatformException the try/catch can't see).
void writeSubtitleSetting(
  WidgetRef ref,
  String key,
  String value, {
  VideoPlayerNotifierProvider? vidPr,
}) {
  MiruSettings.setSettingSync(key, value);
  if (vidPr == null) return;
  try {
    ref.read(vidPr.notifier).applySubtitleStyle();
  } catch (_) {
    // Player torn down mid-edit — the persisted value applies on next open.
  }
}

/// The subtitle look controls (size, weight, alignment, colours, opacity,
/// position, font, style flags, outline) as a tile list. The global Player
/// settings pane and the player's own subtitle tab both render these — one
/// definition so the two surfaces cannot disagree.
///
/// [enabled] is false for an ASS track while Customize is off: mdk renders
/// ASS with the file's own style and ignores every one of these properties,
/// so the controls are shown greyed rather than pretending to work.
List<FTileMixin> buildSubtitleStyleTiles(
  WidgetRef ref, {
  bool isMobileLayout = false,
  VideoPlayerNotifierProvider? vidPr,
  bool enabled = true,
}) => [
  ...buildSubtitleTypographyTiles(ref, isMobileLayout: isMobileLayout, vidPr: vidPr, enabled: enabled),
  ...buildSubtitleColorTiles(ref, isMobileLayout: isMobileLayout, vidPr: vidPr, enabled: enabled),
  ...buildSubtitleLayoutTiles(ref, isMobileLayout: isMobileLayout, vidPr: vidPr, enabled: enabled),
];

/// Delay — the one style property that applies to EVERY subtitle type,
/// including unconverted ASS, so it is not gated by [enabled].
List<FTileMixin> buildSubtitleTimingTiles(
  WidgetRef ref, {
  bool isMobileLayout = false,
  VideoPlayerNotifierProvider? vidPr,
}) {
  final delay = MiruSettings.getSetting<double>(SettingKey.subtitleDelay) ?? 0.0;
  return [
    SettingsSliderTile(
      isMobileLayout: isMobileLayout,
      title: 'settings.player.subtitle_delay.name',
      subtitle: 'settings.player.subtitle_delay.information',
      value: (delay - kSubtitleDelayMin) / (kSubtitleDelayMax - kSubtitleDelayMin),
      min: 0,
      max: 1,
      stepPercentage: 1 / (kSubtitleDelayMax - kSubtitleDelayMin),
      valueLabel: (fraction) {
        final seconds =
            kSubtitleDelayMin +
            fraction * (kSubtitleDelayMax - kSubtitleDelayMin);
        return '${seconds.toStringAsFixed(1)} s';
      },
      onChanged: (value) => writeSubtitleSetting(
        ref,
        SettingKey.subtitleDelay,
        (kSubtitleDelayMin + value * (kSubtitleDelayMax - kSubtitleDelayMin))
            .toStringAsFixed(1),
        vidPr: vidPr,
      ),
    ),
  ];
}

/// Font, weight, family and the three style flags.
List<FTileMixin> buildSubtitleTypographyTiles(
  WidgetRef ref, {
  bool isMobileLayout = false,
  VideoPlayerNotifierProvider? vidPr,
  bool enabled = true,
}) {
  final fontSize = MiruSettings.getSettingSync<double>(
    SettingKey.subtitleFontSize,
  );
  final fontFamily = MiruSettings.getSettingSync<String>(
    SettingKey.subtitleFontFamily,
  );

  return [
    SettingsSliderTile(
      isMobileLayout: isMobileLayout,
      enabled: enabled,
      title: 'settings.player.subtitle_size.name',
      subtitle: 'settings.player.subtitle_size.information',
      value:
          (fontSize - kSubtitleFontSizeMin) /
          (kSubtitleFontSizeMax - kSubtitleFontSizeMin),
      min: 0,
      max: 1,
      stepPercentage: 1 / (kSubtitleFontSizeMax - kSubtitleFontSizeMin),
      valueLabel: (fraction) =>
          '${(kSubtitleFontSizeMin + fraction * (kSubtitleFontSizeMax - kSubtitleFontSizeMin)).toStringAsFixed(0)} px',
      onChanged: (value) => writeSubtitleSetting(
        ref,
        SettingKey.subtitleFontSize,
        (kSubtitleFontSizeMin +
                value * (kSubtitleFontSizeMax - kSubtitleFontSizeMin))
            .toStringAsFixed(1),
        vidPr: vidPr,
      ),
    ),
    SettingsRadiosTile(
      isMobileLayout: isMobileLayout,
      enabled: enabled,
      title: 'settings.player.subtitle_font.name',
      subtitle: 'settings.player.subtitle_font.information',
      value: fontFamily.isEmpty ? 'default' : fontFamily,
      radios: kSubtitleFontChoices,
      onChanged: (value) => writeSubtitleSetting(
        ref,
        SettingKey.subtitleFontFamily,
        value == 'default' ? '' : value,
        vidPr: vidPr,
      ),
    ),
    SubtitleStyleFlagsTile(
      enabled: enabled,
      onChanged: (key, value) =>
          writeSubtitleSetting(ref, key, value, vidPr: vidPr),
    ),
  ];
}

/// Colour and surface rows: text colour, background + opacity, outline.
List<FTileMixin> buildSubtitleColorTiles(
  WidgetRef ref, {
  bool isMobileLayout = false,
  VideoPlayerNotifierProvider? vidPr,
  bool enabled = true,
}) {
  final fontColor = MiruSettings.getSettingSync<String>(
    SettingKey.subtitleFontColor,
  );
  final background = MiruSettings.getSettingSync<String>(
    SettingKey.subtitleBackgroundColor,
  );
  final opacity = MiruSettings.getSettingSync<double>(
    SettingKey.subtitleBackgroundOpacity,
  );
  final outlineSize = MiruSettings.getSettingSync<double>(
    SettingKey.subtitleOutlineSize,
  );
  final outlineColor = MiruSettings.getSettingSync<String>(
    SettingKey.subtitleOutlineColor,
  );
  return [
    SubtitleColorTile(
      isMobileLayout: isMobileLayout,
      enabled: enabled,
      title: 'settings.player.subtitle_color.name',
      subtitle: 'settings.player.subtitle_color.information',
      value: fontColor,
      onChanged: (value) => writeSubtitleSetting(
        ref,
        SettingKey.subtitleFontColor,
        '${kSubtitleColorChoices[value] ?? 0xFFFFFFFF}',
        vidPr: vidPr,
      ),
    ),
    SubtitleColorTile(
      isMobileLayout: isMobileLayout,
      enabled: enabled,
      title: 'settings.player.subtitle_background.name',
      subtitle: 'settings.player.subtitle_background.information',
      value: background,
      choices: kSubtitleBackgroundChoices,
      onChanged: (value) => writeSubtitleSetting(
        ref,
        SettingKey.subtitleBackgroundColor,
        '${kSubtitleBackgroundChoices[value] ?? 0xFF000000}',
        vidPr: vidPr,
      ),
    ),
    SettingsSliderTile(
      isMobileLayout: isMobileLayout,
      enabled: enabled,
      title: 'settings.player.subtitle_opacity.name',
      subtitle: 'settings.player.subtitle_opacity.information',
      value: opacity,
      min: 0,
      max: 1,
      stepPercentage: 0.05,
      onChanged: (value) => writeSubtitleSetting(
        ref,
        SettingKey.subtitleBackgroundOpacity,
        value.toStringAsFixed(2),
        vidPr: vidPr,
      ),
    ),
    SettingsSliderTile(
      isMobileLayout: isMobileLayout,
      enabled: enabled,
      title: 'settings.player.subtitle_outline_size.name',
      subtitle: 'settings.player.subtitle_outline_size.information',
      value: outlineSize / kSubtitleOutlineSizeMax,
      min: 0,
      max: 1,
      stepPercentage: 1 / kSubtitleOutlineSizeMax,
      onChanged: (value) => writeSubtitleSetting(
        ref,
        SettingKey.subtitleOutlineSize,
        (value * kSubtitleOutlineSizeMax).toStringAsFixed(1),
        vidPr: vidPr,
      ),
    ),
    SubtitleColorTile(
      isMobileLayout: isMobileLayout,
      enabled: enabled,
      title: 'settings.player.subtitle_outline_color.name',
      subtitle: 'settings.player.subtitle_outline_color.information',
      value: outlineColor,
      onChanged: (value) => writeSubtitleSetting(
        ref,
        SettingKey.subtitleOutlineColor,
        '${kSubtitleColorChoices[value] ?? 0xFF000000}',
        vidPr: vidPr,
      ),
    ),
  ];
}

/// Where the cue sits: horizontal alignment and vertical position.
List<FTileMixin> buildSubtitleLayoutTiles(
  WidgetRef ref, {
  bool isMobileLayout = false,
  VideoPlayerNotifierProvider? vidPr,
  bool enabled = true,
}) {
  final align = MiruSettings.getSettingSync<int>(SettingKey.subtitleTextAlign);
  final verticalAlign = MiruSettings.getSettingSync<String>(
    SettingKey.subtitleVerticalAlign,
  );
  return [
    SettingsRadiosTile.detailed(
      isMobileLayout: isMobileLayout,
      enabled: enabled,
      title: 'settings.player.subtitle_align.name',
      subtitle: 'settings.player.subtitle_align.information',
      value: '$align',
      entry: const [
        RadioTileEntry(
          value: '0',
          title: 'settings.player.subtitle_align.left',
        ),
        RadioTileEntry(
          value: '1',
          title: 'settings.player.subtitle_align.center',
        ),
        RadioTileEntry(
          value: '2',
          title: 'settings.player.subtitle_align.right',
        ),
      ],
      onChanged: (value) => writeSubtitleSetting(
        ref,
        SettingKey.subtitleTextAlign,
        value,
        vidPr: vidPr,
      ),
    ),
    SettingsRadiosTile(
      isMobileLayout: isMobileLayout,
      enabled: enabled,
      title: 'settings.player.subtitle_vertical.name',
      subtitle: 'settings.player.subtitle_vertical.information',
      value: verticalAlign,
      radios: const ['top', 'center', 'bottom'],
      onChanged: (value) => writeSubtitleSetting(
        ref,
        SettingKey.subtitleVerticalAlign,
        value,
        vidPr: vidPr,
      ),
    ),
  ];
}

class SettingPlayer extends HookConsumerWidget {
  const SettingPlayer({super.key, this.isMobileLayout = false});

  final bool isMobileLayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = MiruSettings.getSettingSync<int>(SettingKey.playerSeekStep);

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'settings.player.name',
          children: [
            SettingsRadiosTile(
              isMobileLayout: isMobileLayout,
              title: 'settings.player.seek_step.name',
              subtitle: 'settings.player.seek_step.information',
              value: '$step',
              radios: [for (final s in kPlayerSeekSteps) '$s'],
              onChanged: (value) =>
                  MiruSettings.setSettingSync(SettingKey.playerSeekStep, value),
            ),
            SettingsToggleTile(
              isMobileLayout: isMobileLayout,
              title: 'settings.player.seek_feedback.name',
              subtitle: 'settings.player.seek_feedback.information',
              value: MiruSettings.getSettingSync<bool>(
                SettingKey.playerSeekFeedback,
              ),
              onChanged: (value) => MiruSettings.setSettingSync(
                SettingKey.playerSeekFeedback,
                value.toString(),
              ),
            ),
          ],
        ),
        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'settings.player.subtitle.name',
          children: buildSubtitleStyleTiles(
            ref,
            isMobileLayout: isMobileLayout,
          ),
        ),
      ],
    );
  }
}

/// A preset-swatch colour row: the selected swatch carries a ring, the label
/// names the choice. Both layouts render the same row (mobile wraps).
class SubtitleColorTile extends HookWidget with FTileMixin {
  const SubtitleColorTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isMobileLayout = false,
    this.enabled = true,
    this.choices = kSubtitleColorChoices,
  });

  final String title;
  final String subtitle;
  final String value;
  final ValueChanged<String> onChanged;
  final bool isMobileLayout;

  /// The swatches this row offers; the background row adds [kSubtitleColorNone].
  final Map<String, int> choices;

  /// UI-only: gates the swatches; the persisted value is left untouched.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // `value` is the persisted ARGB int-string; the swatches key on the hex
    // string. Track the selected hex key, seeded from the stored int.
    String initialKey = '';
    for (final e in choices.entries) {
      if ('${e.value}' == value) {
        initialKey = e.key;
        break;
      }
    }
    final selected = useState(initialKey);
    final swatches = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in choices.entries) ...[
          _Swatch(
            color: Color(entry.value),
            selected: selected.value == entry.key,
            enabled: enabled,
            isNone: entry.key == kSubtitleColorNone,
            onPress: () {
              selected.value = entry.key;
              onChanged(entry.key);
            },
          ),
          const SizedBox(width: 6),
        ],
      ],
    );

    if (isMobileLayout) {
      return FTile(
        title: Text(title.i18n),
        subtitle: Text(subtitle.i18n),
        details: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: swatches,
          ),
        ),
      );
    }
    return SettingBaseTile(
      title: title,
      subtitle: subtitle,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: swatches,
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onPress,
    this.enabled = true,
    this.isNone = false,
  });

  final Color color;
  final bool selected;
  final VoidCallback onPress;
  final bool enabled;

  /// The transparent "no colour" entry: drawn as an empty circle with a cross
  /// so it reads as absence rather than as a black swatch.
  final bool isNone;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final markColor = isNone
        ? colors.foreground
        : (color.computeLuminance() > 0.6
              ? const Color(0xFF000000)
              : const Color(0xFFFFFFFF));
    return FTappable(
      onPress: enabled ? onPress : null,
      semanticsLabel: isNone
          ? 'settings.player.subtitle_color.none'
          : 'settings.player.subtitle_color.${color.toARGB32()}',
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Icon(
          isNone && !selected ? FLucideIcons.x : FLucideIcons.check,
          size: 14,
          // The check only marks the current choice; the cross is the swatch's
          // own identity and stays visible when unselected.
          color: selected || isNone ? markColor : const Color(0x00000000),
        ),
      ),
    );
  }
}
