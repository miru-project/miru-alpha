import 'package:flutter/material.dart';

class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.child, required this.maxWidth});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    EdgeInsets widthPadding = EdgeInsets.zero;

    double widthPaddingValue =
        (MediaQuery.of(context).size.width - maxWidth) / 2;
    if (widthPaddingValue > 0) {
      widthPadding = EdgeInsets.only(
        left: widthPaddingValue,
        right: widthPaddingValue,
      );
    } else {
      widthPadding = EdgeInsets.zero;
    }
    return Padding(padding: widthPadding, child: child);
  }
}
