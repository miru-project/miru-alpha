import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';

class MobileDetailTabs extends StatelessWidget {
  const MobileDetailTabs({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
  });
  final ExtensionDetail detail;
  final ExtensionMeta meta;
  final String detailUrl;

  static const _tabOptions = ['Description', 'Tracking', 'Cast'];
  @override
  Widget build(BuildContext context) {
    final List<Widget> tabContent = [
      // Description
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              detail.desc ?? 'No Description',
              textAlign: TextAlign.start,
              style: TextStyle(height: 1.4, fontWeight: .w600),
            ),
          ),
        ],
      ),
      // Tracking
      Text('WIP'),
      // Cast
      Text("WIP"),
    ];
    return FTabs(
      children: List.generate(
        _tabOptions.length,
        (index) => FTabEntry(
          label: Text(_tabOptions[index]),
          child: tabContent[index],
        ),
      ),
    );
  }
}
