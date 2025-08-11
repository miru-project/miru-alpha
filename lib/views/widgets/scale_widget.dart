import 'package:flutter/material.dart';

class ScaleWidget extends StatefulWidget {
  const ScaleWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ScaleWidget> createState() => _ScaleWidgetState();
}

class _ScaleWidgetState extends State<ScaleWidget> {
  bool _tapDown = false;

  void _onTapDown(_) {
    setState(() {
      _tapDown = true;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _tapDown = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Transform.scale(
          scale: _tapDown ? 0.95 : 1,
        ).transform,
        child: widget.child,
      ),
    );
  }
}
