import 'dart:ui';

import 'package:flutter/material.dart';

class MiruAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MiruAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  final Widget title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: const BoxDecoration(
              // color: Colors.white.withAlpha(200),
              ),
          child: AppBar(
            title: title,
            // backgroundColor: Colors.transparent,
            elevation: 0,
            // surfaceTintColor: Colors.transparent,
            actions: actions,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(0, 50);
}
