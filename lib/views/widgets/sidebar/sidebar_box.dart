import 'package:flutter/material.dart';

class SidebarBox extends StatelessWidget {
  const SidebarBox({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(10),
        border: const Border(
          right: BorderSide(color: Colors.black12, width: 0.5),
        ),
      ),
      child: child,
    );
  }
}
