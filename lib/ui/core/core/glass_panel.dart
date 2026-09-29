import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.blurSigma = 24,
    this.color = const Color(0x99121212),
    this.borderColor,
    this.borderWidth = 1,
  });

  final Widget child;
  final BorderRadiusGeometry borderRadius;
  final double blurSigma;
  final Color color;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: borderColor ?? theme.colors.border.withAlpha(80),
              width: borderWidth,
            ),
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
