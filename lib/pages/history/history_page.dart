import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/provider/watch/main_provider.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/widgets/grid_view/index.dart';
import 'package:go_router/go_router.dart';

class HistoryPage extends StatefulHookConsumerWidget {
  const HistoryPage({super.key});
  @override
  createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  get wantKeepAlive => true;

  int historyLen = 0;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final history = await DatabaseService.getHistoriesByType();
      ref.read(mainProvider.notifier).updateHistory(history);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final history = ref.watch(mainProvider).history;
    historyLen = history.length;
    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverToBoxAdapter(
            child: Text(
              "History",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(15.0),
          sliver: SliverGrid(
            gridDelegate: DeviceUtil.device(
              mobile: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: DeviceUtil.getWidth(context) ~/ 110,
                childAspectRatio: 0.6,
              ),
              desktop: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: DeviceUtil.getWidth(context) * .875 ~/ 180,
                childAspectRatio: 0.65,
              ),
              context: context,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = history[index];
              return MiruDesktopGridTile(
                title: item.title,
                subtitle: item.episodeTitle,
                imageUrl: item.cover,
                onTap: () {
                  final meta = ref.read(extensionPageProvider).metaData;
                  final ExtensionMeta? ext = meta.firstWhereOrNull(
                    (element) => element.packageName == item.package,
                  );
                  if (ext == null) return;
                  context.push(
                    '/search/detail',
                    extra: DetailParam(meta: ext, url: item.detailUrl),
                  );
                },
              );
            }, childCount: history.length),
          ),
        ),
      ],
    );
  }
}
