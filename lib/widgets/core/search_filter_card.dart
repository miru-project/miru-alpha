import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/widgets/amination/animated_box.dart';
import 'package:miru_app_new/widgets/core/blur.dart';

class SearchFilterCard extends StatelessWidget {
  final Widget child;
  const SearchFilterCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedBox.nopadding(
      child: Blur(
        child: FCard(
          style: .delta(
            decoration: .delta(
              color: context.theme.colors.background.withAlpha(200),
            ),
          ),
          //  FCardStyle.inherit(
          //   colors: context.theme.colors.copyWith(
          //     background: context.theme.colors.background.withAlpha(200),
          //   ),
          //   typography: overrideTheme.typography,
          //   style: context.theme.style,
          // ).call,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: child,
          ),
        ),
      ),
    );
  }
}
