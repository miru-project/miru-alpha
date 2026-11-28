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
    this.valueLabel,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final double value;
  final void Function(double) onChanged;
  final double min;
  final double max;
  final double stepPercentage;
  final bool isMobileLayout;

  /// UI-only: gates the control; the persisted value is left untouched.
  final bool enabled;

  /// Optional readout override (e.g. "46 px"). When null the value is shown
  /// as a percentage of [min]..[max].
  final String? Function(double fraction)? valueLabel;

  @override
  Widget build(BuildContext context) {
    final val = useState(value);
    final percent = ((val.value - min) / (max - min) * 100);
    final readout =
        valueLabel?.call(val.value) ?? '${percent.toStringAsFixed(0)}%';

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
                width: 52,
                child: Text(
                  readout,
                  textAlign: TextAlign.end,
                  style: context.theme.typography.body.sm,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // The track gets its own row, full width. Squeezing label + track +
    // readout onto one line inside a 400px panel leaves ~100px of drag travel,
    // which makes precise adjustment frustrating with a mouse.
    return SettingBaseTile(
      title: title,
      subtitle: subtitle,
      // Track + readout need two lines; a 36px slot clips them.
      controlHeight: 44,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 22, child: _slider(context, val)),
          Text(
            readout,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.theme.typography.body.xs.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(BuildContext context, ValueNotifier<double> val) {
    // FSliderValue asserts max > min; a fraction sitting exactly on `min`
    // (e.g. font at the floor) would throw and abort the rebuild, leaving the
    // old size on screen. Nudge the max edge just above min to keep it valid.
    final maxEdge = val.value <= min ? min + (max - min) * 0.001 : val.value;
    // FSlider lays its track out at a minimum width the parent cannot always
    // honour; inside a narrow docked panel it painted past its own box and
    // collided with the readout. Clip to the slot and size the track from the
    // caller's constraints instead of a hardcoded extent.
    return LayoutBuilder(
      builder: (context, constraints) {
        final track = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 160.0;
        return ClipRect(
          child: FSlider(
            enabled: enabled,
            trackMainAxisExtent: track,
            control: FSliderControl.managedContinuous(
              stepPercentage: stepPercentage,
              initial: FSliderValue(max: maxEdge.clamp(min, max), min: min),
              onChange: (value) {
                val.value = value.max;
                onChanged(value.max);
              },
            ),
          ),
        );
      },
    );
  }
}
