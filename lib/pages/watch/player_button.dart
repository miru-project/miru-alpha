import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class PlayerButton extends StatelessWidget {
  const PlayerButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size,
  });
  final VoidCallback onPressed;
  final IconData icon;
  final double? size;
  @override
  Widget build(BuildContext context) {
    return FButton.icon(
      style: FButtonStyle.ghost(),
      onPress: onPressed,
      child: Icon(icon, size: size),
    );
  }
}
