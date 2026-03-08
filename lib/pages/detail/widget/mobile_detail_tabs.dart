import 'package:flutter/material.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';

class MobileDetailTabs extends StatelessWidget {
  const MobileDetailTabs({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
  });
  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;

  @override
  Widget build(BuildContext context) {
    final List<String> tabTitles = [
      'extension.description'.i18n,
      'tracking'.i18n,
      'cast'.i18n
    ];
    final List<Widget> tabContent = [
      // Description
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              detail.desc ?? 'no_description'.i18n,
              textAlign: TextAlign.start,
              style: TextStyle(height: 1.4, fontWeight: .w600),
            ),
          ),
        ],
      ),
      // Tracking
      Text('wip'.i18n),
      // Cast
      Text('wip'.i18n),
    ];
    return FTabs(
      children: List.generate(
        tabTitles.length,
        (index) => FTabEntry(
          label: Text(tabTitles[index]),
          child: tabContent[index],
        ),
      ),
    );
  }
}
