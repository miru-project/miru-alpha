/// The text style flags (bold / italic / underline / strikeout) as one row of
/// toggle buttons.
///
/// These four properties are a text-formatting toolbar, so they are presented
/// the way every desktop editor presents them: icon toggles that show their own
/// state. Weight used to be a dropdown while the other three were switches —
/// one control type for one concept now, and the whole set fits in 36px.
library;

import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/features/setting/widget/setting_base_tile.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

class SubtitleStyleFlagsTile extends StatefulWidget with FTileMixin {
  const SubtitleStyleFlagsTile({
    super.key,
    required this.onChanged,
    this.enabled = true,
  });

  /// Persists one style property and re-pushes it into the live player. The
  /// value is a string because weight is stored as `'bold'`/`'normal'` while
  /// the other three are booleans.
  final void Function(String key, String value) onChanged;
  final bool enabled;

  @override
  State<SubtitleStyleFlagsTile> createState() => _SubtitleStyleFlagsTileState();
}

class _SubtitleStyleFlagsTileState extends State<SubtitleStyleFlagsTile> {
  /// The settings store is not a listenable, so the tile re-reads these on its
  /// own tap. Without a local rebuild the icon keeps painting the old state and
  /// a second tap writes the same value again — the control looks stuck.
  bool _bold = false;
  bool _italic = false;
  bool _underline = false;
  bool _strikeout = false;

  @override
  void initState() {
    super.initState();
    _read();
  }

  void _read() {
    _bold =
        MiruSettings.getSettingSync<String>(SettingKey.subtitleFontWeight) ==
        'bold';
    _italic = MiruSettings.getSettingSync<bool>(SettingKey.subtitleItalic);
    _underline = MiruSettings.getSettingSync<bool>(SettingKey.subtitleUnderline);
    _strikeout = MiruSettings.getSettingSync<bool>(
      SettingKey.subtitleStrikeout,
    );
  }

  void _toggle(bool current, String key, String on, String off) {
    final next = !current;
    setState(() => _apply(key, next));
    widget.onChanged(key, next ? on : off);
  }

  void _apply(String key, bool next) {
    if (key == SettingKey.subtitleFontWeight) {
      _bold = next;
    } else if (key == SettingKey.subtitleItalic) {
      _italic = next;
    } else if (key == SettingKey.subtitleUnderline) {
      _underline = next;
    } else {
      _strikeout = next;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingBaseTile(
      title: 'settings.player.subtitle_style_flags',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _FlagButton(
            icon: FLucideIcons.bold,
            on: _bold,
            enabled: widget.enabled,
            semanticsLabel: 'settings.player.subtitle_weight.bold'.i18n,
            onToggle: (_) => _toggle(
              _bold,
              SettingKey.subtitleFontWeight,
              'bold',
              'normal',
            ),
          ),
          const SizedBox(width: 6),
          _FlagButton(
            icon: FLucideIcons.italic,
            on: _italic,
            enabled: widget.enabled,
            semanticsLabel: 'settings.player.subtitle_italic.name'.i18n,
            onToggle: (_) => _toggle(_italic, SettingKey.subtitleItalic, 'true', 'false'),
          ),
          const SizedBox(width: 6),
          _FlagButton(
            icon: FLucideIcons.underline,
            on: _underline,
            enabled: widget.enabled,
            semanticsLabel: 'settings.player.subtitle_underline.name'.i18n,
            onToggle: (_) =>
                _toggle(_underline, SettingKey.subtitleUnderline, 'true', 'false'),
          ),
          const SizedBox(width: 6),
          _FlagButton(
            icon: FLucideIcons.strikethrough,
            on: _strikeout,
            enabled: widget.enabled,
            semanticsLabel: 'settings.player.subtitle_strikeout.name'.i18n,
            onToggle: (_) =>
                _toggle(_strikeout, SettingKey.subtitleStrikeout, 'true', 'false'),
          ),
        ],
      ),
    );
  }
}

class _FlagButton extends StatelessWidget {
  const _FlagButton({
    required this.icon,
    required this.on,
    required this.onToggle,
    required this.semanticsLabel,
    required this.enabled,
  });

  final IconData icon;
  final bool on;
  final ValueChanged<bool> onToggle;
  final String semanticsLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Semantics(
      button: true,
      toggled: on,
      label: semanticsLabel,
      child: FTappable(
        onPress: enabled ? () => onToggle(!on) : null,
        child: Container(
          width: 32,
          height: 28,
          decoration: BoxDecoration(
            color: on ? colors.primary : colors.secondary,
            borderRadius: context.theme.style.borderRadius.xs2,
            border: Border.all(color: on ? colors.primary : colors.border),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 14,
              color: on ? colors.primaryForeground : colors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}
