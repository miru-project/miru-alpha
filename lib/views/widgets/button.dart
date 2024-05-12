import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.child,
    required this.onPressed,
    this.trailing,
  });
  final Widget child;
  final void Function() onPressed;
  final List<Widget>? trailing;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hover = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hover = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.onPressed();
        },
        onTapDown: (details) {
          setState(() {
            _hover = true;
          });
        },
        onTapUp: (details) {
          setState(() {
            _hover = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _hover ? Colors.black12 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.trailing != null) ...[
                ...widget.trailing!,
                const SizedBox(width: 4),
              ],
              widget.child,
            ],
          ),
        ),
      ),
    );
  }
}
