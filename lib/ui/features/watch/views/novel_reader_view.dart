import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/widget/novel_side_sheet.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/novel_reader_provider.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/ui/core/index.dart';

class NovelReaderView extends HookConsumerWidget {
  const NovelReaderView.local({
    super.key,
    required this.name,
    required this.meta,
    required this.epProvider,
    required this.detailImageUrl,
    required this.localPath,
  }) : value = null;
  const NovelReaderView({
    super.key,
    required this.value,
    required this.name,
    required this.meta,
    required this.epProvider,
    required this.detailImageUrl,
  }) : localPath = null;

  final ExtensionFikushonWatch? value;
  final String name;
  final ExtensionMeta meta;
  final EpisodeNotifierProvider epProvider;
  final String detailImageUrl;
  final String? localPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final novelProvider = novelReaderProvider(value?.content, localPath);
    return MiruScaffold.mobile(
      sliverHeaders: [
        StaticSliverHeaderDelegate(
          maxExtent: 50,
          child: SnapSheetNested.back(title: name),
        ),
      ],
      snapSheet: [
        NovelSideSheet(epProvider: epProvider, novelProvider: novelProvider),
      ],
      mobileBody: DeviceUtil.deviceWidget(
        context: context,
        mobile: _NovelReadView(
          data: value,
          meta: meta,
          imgUrl: detailImageUrl,
          epProvider: epProvider,
          novelProvider: novelProvider,
        ),
        desktop: Row(
          children: [
            Expanded(
              child: _NovelReadView(
                data: value,
                meta: meta,
                imgUrl: detailImageUrl,
                epProvider: epProvider,
                novelProvider: novelProvider,
              ),
            ),
            FDivider(axis: Axis.vertical),
            SizedBox(
              width: 400,
              child: NovelSideSheet(
                epProvider: epProvider,
                novelProvider: novelProvider,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NovelReadView extends HookConsumerWidget {
  const _NovelReadView({
    required this.data,
    required this.meta,
    required this.imgUrl,
    required this.epProvider,
    required this.novelProvider,
  });
  final ExtensionFikushonWatch? data;
  final ExtensionMeta meta;
  final String imgUrl;
  final EpisodeNotifierProvider epProvider;
  final NovelReaderProvider novelProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
