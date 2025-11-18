import 'package:flutter/material.dart';
import 'package:forui/theme.dart';

class SlideRightPageTransitionsBuilder extends PageTransitionsBuilder {
  const SlideRightPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const Offset begin = Offset(1.0, 0.0);
    const Offset end = Offset.zero;
    final Animatable<Offset> tween = Tween<Offset>(
      begin: begin,
      end: end,
    ).chain(CurveTween(curve: Curves.ease));

    return SlideTransition(
      position: animation.drive(tween),
      child: Container(color: context.theme.colors.background, child: child),
    );
  }
}
