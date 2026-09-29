import 'dart:ui';

import 'package:material_ui/material_ui.dart';

class Blur extends StatelessWidget {
  const Blur({
    super.key,
    this.blurDensity = 10,
    this.borderRadius = BorderRadius.zero,
    required this.child,
  });
  final Widget child;
  final BorderRadiusGeometry borderRadius;
  final double blurDensity;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurDensity, sigmaY: blurDensity),
        child: child,
      ),
    );
  }
}
