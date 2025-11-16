import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/widgets/index.dart';

class SettingScaffold extends StatelessWidget {
  const SettingScaffold({super.key, required this.child, required this.title});
  final Widget child;
  final String title;
  @override
  Widget build(BuildContext context) {
    return MiruScaffold(
      resizeToAvoidBottomInset: false,
      mobileHeader: SnapSheetNested(
        title: title,
        prefix: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0, top: 4),
              child: Icon(
                FIcons.chevronLeft,
                size: 28,
                color: context.theme.colors.primary,
              ),
            ),
          ),
        ],
      ),

      snapSheet: [],
      body: child,
    );
  }
}
