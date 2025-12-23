import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/detail/widget/mobile_detail_silverlist.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';

class MobileLoadedPage extends HookConsumerWidget {
  const MobileLoadedPage({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
  });
  final ExtensionDetail detail;
  final ExtensionMeta meta;
  final String detailUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    height: 180,
                    child: ImageWidget(
                      imageUrl: detail.cover,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsGeometry.only(top: 10),
                      child: Column(
                        mainAxisAlignment: .spaceBetween,
                        crossAxisAlignment: .start,
                        children: [
                          FLabel(
                            axis: Axis.vertical,
                            description: Text(
                              "${meta.name} * ${meta.type.name}",
                              style: TextStyle(height: 1.3),
                            ),
                            child: Text(
                              detail.title,
                              style: TextStyle(
                                height: 1.2,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                              maxLines: 3,
                            ),
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            children: [
                              FBadge(child: Text('Favgroup 1')),
                              FBadge(
                                style: FBadgeStyle.secondary(),
                                child: Text('Favgroup 2'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        MobileDetailSilverlist(
          detail: detail,
          meta: meta,
          detailUrl: detailUrl,
        ),
        SliverToBoxAdapter(child: SizedBox(height: 300)),
      ],
    );
  }
}
