import 'package:flutter/material.dart';

class OutlineText extends StatelessWidget {
  const OutlineText({
    super.key,
    required this.text,
    required this.color,
    required this.fontSize,
    required this.fontWeight,
    required this.strokeWidth,
    required this.outlineColor,
  });

  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final double strokeWidth;
  final Color outlineColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              foreground: Paint()
                ..color = outlineColor
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth,
              fontWeight: fontWeight,
            ),
          ),
        ),
        Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              foreground: Paint()..color = color,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ],
    );
  }
}
