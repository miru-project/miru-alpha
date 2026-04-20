import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:miru_alpha/pages/setting/widget/setting_base_tile.dart';

class SettingPressTile extends StatelessWidget with FTileMixin {
  const SettingPressTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPress,
    this.prefix,
    this.isMobileLayout = false,
  });
  final String title;
  final String subtitle;
  final VoidCallback onPress;
  final Widget? prefix;
  final bool isMobileLayout;
  @override
  Widget build(BuildContext context) => isMobileLayout
      ? _tile(context)
      : FTappable(onPress: onPress, child: _tile(context));

  Widget _tile(BuildContext context) {
    return SettingBaseTile(
      isMobileLayout: isMobileLayout,
      title: title.i18n,
      subtitle: subtitle.i18n,
      prefix: prefix,
      onTap: onPress,
      child: const SizedBox.shrink(),
    );
  }
}
