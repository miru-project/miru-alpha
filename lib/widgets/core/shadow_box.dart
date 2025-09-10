import 'package:flutter/material.dart';

class ShadowBox extends StatelessWidget {
  const ShadowBox({
    required this.child,
    this.left,
    this.bottom,
    this.right,
    this.height,
    this.width,
    this.top,
    this.shadowAlpha = 100,
    super.key,
  }) : aspectRatio = null;

  const ShadowBox.ratio({
    required this.child,
    required this.aspectRatio,
    this.left,
    this.bottom,
    this.right,
    this.top,
    this.shadowAlpha = 100,
    super.key,
  }) : height = null,
       width = null;

  final Widget child;
  final double? left;
  final double? right;
  final double? bottom;
  final double? top;
  final double? height;
  final double? width;
  final double? aspectRatio;
  final int shadowAlpha;
  // final Widget Function(Widget) func ;

  Widget buildBox(Widget child) => Positioned(
    left: left,
    right: right,
    bottom: bottom,
    top: top,
    width: width,
    height: height,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (aspectRatio != null)
          Positioned(
            left: left,
            right: right,
            bottom: bottom,
            top: top,
            child: AspectRatio(
              aspectRatio: aspectRatio!,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(shadowAlpha),
                    ],
                  ),
                ),
              ),
            ),
          )
        else if (height != null || width != null)
          Positioned(
            left: left,
            right: right,
            bottom: bottom,
            top: top,
            width: width,
            height: height,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha(100)],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
