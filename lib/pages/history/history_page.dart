import 'dart:async';
import 'dart:ui';
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
import 'package:miru_app_new/widgets/platform_widget.dart';
import 'package:forui/forui.dart';

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
    return PlatformWidget(
      mobileWidget: MiruGridView.mobile(
        mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: DeviceUtil.getWidth(context) ~/ 150,
          childAspectRatio: 0.65,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final item = history[index];
          return MiruMobileTile(
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
                '/search/single/detail',
                extra: DetailParam(meta: ext, url: item.detailUrl),
              );
            },
            onLongPress: () {
              showFSheet(
                context: context,
                style: .delta(
                  barrierFilter: (value) =>
                      ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                ),
                builder: (context) => Consumer(
                  builder: (context, ref, child) => FTileGroup(
                    children: [
                      FTile(
                        prefix: Icon(FIcons.bookX),
                        title: Text('Remove  History'),
                        onPress: () {
                          ref.read(mainProvider.notifier).removeHistory(item);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                side: .btt,
              );
            },
          );
        },
        itemCount: history.length,
      ),
      desktopWidget: CustomScrollView(
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: DeviceUtil.getWidth(context) * .875 ~/ 220,
                childAspectRatio: 0.6,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = history[index];
                return MiruDesktopGridTile(
                  title: item.title,
                  subtitle: item.episodeTitle,
                  imageUrl: item.cover,
                  titleMaxline: 2,
                  onTap: () {
                    final meta = ref.read(extensionPageProvider).metaData;
                    final ExtensionMeta? ext = meta.firstWhereOrNull(
                      (element) => element.packageName == item.package,
                    );
                    if (ext == null) return;
                    context.push(
                      '/search/single/detail',
                      extra: DetailParam(meta: ext, url: item.detailUrl),
                    );
                  },
                );
              }, childCount: history.length),
            ),
          ),
        ],
      ),
    );
  }
}
