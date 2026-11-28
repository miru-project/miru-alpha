import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class SettingBaseTile extends StatelessWidget with FTileMixin {
  const SettingBaseTile({
    super.key,
    this.subtitle,
    required this.title,
    required this.child,
    this.isMobileLayout = false,
    this.prefix,
    this.onTap,
    this.controlHeight = 36,
  });
  final String title;
  final String? subtitle;
  final Widget child;
  final bool isMobileLayout;
  final Widget? prefix;
  final VoidCallback? onTap;

  /// The control slot's height. Sliders need a taller slot than a switch or a
  /// dropdown because they carry their own readout line.
  final double controlHeight;

  /// Below this width the description leaves the row and becomes a tooltip.
  /// Label + description + control stacked three deep costs ~70px per setting;
  /// in a tall narrow panel that buries everything below the first screenful.
  /// The label and control stay on ONE line at every width — the old fixed
  /// 300px control slot is what used to starve the label onto the control.
  static const double _hideDescriptionBelow = 560;

  static const double _controlMaxWidth = 300;
  static const double _controlShare = 0.45;

  @override
  Widget build(BuildContext context) {
    var name = '$title.name'.i18n;
    var information = '$title.information'.i18n;

    // Check if the keys actually returned translated values
    final hasProperI18n = name != '$title.name';
    final titleText = hasProperI18n ? name : title.i18n;
    final subtitleText = hasProperI18n && information != '$title.information'
        ? information
        : subtitle?.i18n;

    if (isMobileLayout) {
      return FTile(
        onPress: onTap,
        prefix: prefix,
        title: Text(titleText),
        subtitle: subtitleText == null ? null : Text(subtitleText),
        details: child,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final compact = width.isFinite && width < _hideDescriptionBelow;
          final controlWidth = width.isFinite
              ? (width * _controlShare).clamp(0.0, _controlMaxWidth)
              : _controlMaxWidth;

          final label = FLabel(
            layout: .vertical,
            description: compact || subtitleText == null
                ? null
                : Text(
                    subtitleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            child: Text(
              titleText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          );

          final labelled = compact && subtitleText != null
              ? Tooltip(message: subtitleText, child: label)
              : label;

          return Row(
            children: [
              if (prefix != null) ...[prefix!, const SizedBox(width: 10)],
              Expanded(child: labelled),
              const SizedBox(width: 12),
              SizedBox(
                width: controlWidth,
                height: controlHeight,
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }
}
