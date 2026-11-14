import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Structured stand-in for media artwork that has no URL or failed to load:
/// a lit gradient tile with a faint media-type glyph (and an optional
/// "no preview" hint) instead of a raw broken-image icon or a black box
/// that bleeds into the canvas (Refactoring UI: never ship an empty box for
/// a failed image).
class HomeCoverFallback extends StatelessWidget {
  const HomeCoverFallback({
    super.key,
    this.icon = FLucideIcons.image,
    this.showLabel = false,
  });

  final IconData icon;

  /// Shows the "no cover" caption under the glyph — on cards big enough to
  /// carry it (continue cards); the 44px feed covers skip it.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _decoration(context),
      child: Center(
        child: _StaticGlyph(icon: icon, showLabel: showLabel),
      ),
    );
  }

  BoxDecoration _decoration(BuildContext context) {
    final colors = context.theme.colors;
    return BoxDecoration(
      // Background→muted ramp is the widest token contrast available in the
      // dark theme (audit: card→muted still read flat at tile size).
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colors.background, colors.muted],
      ),
      border: Border.all(color: colors.border),
    );
  }
}

/// The standby glyph + optional caption, intentionally static: an ambient
/// infinite pulse would keep every `pumpAndSettle` in the widget tests from
/// settling, and the structured glyph + caption already read as a standby.
class _StaticGlyph extends StatelessWidget {
  const _StaticGlyph({required this.icon, required this.showLabel});

  final IconData icon;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return showLabel
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 44,
                color: colors.mutedForeground.withAlpha(115),
              ),
              const SizedBox(height: 8),
              Text(
                'home.no_cover_preview'.i18n,
                style: context.theme.typography.body.xs2.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ],
          )
        : Icon(icon, size: 28, color: colors.mutedForeground.withAlpha(115));
  }
}
