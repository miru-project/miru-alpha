import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/features/setting/widget/setting_base_tile.dart';

/// A settings tile that lets the user pick a value along a continuous range via
/// a [FSlider]. Renders two distinct, intentionally-designed layouts:
///
/// * **Desktop** — reuses [SettingBaseTile] so the title/subtitle sit on the
///   left and the slider + percentage readout sit on the right, vertically
///   centered and aligned with every other desktop settings control.
/// * **Mobile** — a standard [FTile] with the slider laid out beneath the
///   title in `details`.
class SettingsSliderTile extends HookWidget with FTileMixin {
  const SettingsSliderTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.stepPercentage = 0.01,
    this.isMobileLayout = false,
  });

  final String title;
  final String? subtitle;
  final double value;
  final void Function(double) onChanged;
  final double min;
  final double max;
  final double stepPercentage;
  final bool isMobileLayout;

  @override
  Widget build(BuildContext context) {
    final val = useState(value);
    final percent = ((val.value - min) / (max - min) * 100);

    if (isMobileLayout) {
      return FTile(
        title: Text(title.i18n),
        subtitle: subtitle == null ? null : Text(subtitle!.i18n),
        details: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _slider(context, val)),
              const SizedBox(width: 12),
              SizedBox(
                width: 44,
                child: Text(
                  '${percent.toStringAsFixed(0)}%',
                  textAlign: TextAlign.end,
                  style: context.theme.typography.body.sm,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SettingBaseTile(
      title: title,
      subtitle: subtitle,
      child: SizedBox(
        width: 300,
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _slider(context, val)),
            SizedBox(
              width: 44,
              child: Text(
                '${percent.toStringAsFixed(0)}%',
                textAlign: TextAlign.end,
                style: context.theme.typography.body.sm,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider(BuildContext context, ValueNotifier<double> val) {
    return FSlider(
      // Give the track a stable, comfortable height so it sits centered in the
      // 40px-tall control row instead of collapsing on desktop.
      trackMainAxisExtent: 240,
      control: FSliderControl.managedContinuous(
        stepPercentage: stepPercentage,
        initial: FSliderValue(max: val.value, min: min),
        onChange: (value) {
          val.value = value.max;
          onChanged(value.max);
        },
      ),
    );
  }
}
