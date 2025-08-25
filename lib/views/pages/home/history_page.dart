import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/objectbox.g.dart';
import 'package:miru_app_new/utils/database_service.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/watch/watch_entry.dart';
import 'package:miru_app_new/views/pages/home/home_page.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final history =
          DatabaseService.historys
              .query()
              .order(History_.date, flags: Order.descending)
              .build()
              .find();
      ref.read(mainPageProvider.notifier).updateHistory(history);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final selectedDot = useState(0);
    final width = DeviceUtil.getWidth(context);
    final history = ref.watch(mainPageProvider).history;
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: DeviceUtil.device(
              mobile: 200,
              desktop: 300,
              context: context,
            ),
            child: OverflowBox(
              maxWidth: DeviceUtil.device(
                mobile: width,
                desktop: width * .9,
                context: context,
              ),
              child: MoonCarousel(
                loop: true,
                autoPlay: true,
                autoPlayDelay: const Duration(seconds: 5),
                gap: 12,
                itemCount: 10,
                itemExtent: DeviceUtil.device(
                  mobile: width - 32,
                  desktop: width * .4,
                  context: context,
                ),
                onIndexChanged: (int index) => selectedDot.value = index,
                itemBuilder: (BuildContext context, int itemIndex, int _) {
                  if (history.length <= itemIndex) {
                    return const Center(
                      child: Text(
                        'No history',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: "HarmonyOS_Sans",
                        ),
                      ),
                    );
                  }
                  final item = history[itemIndex];
                  return HomePageCarousel(item: item);
                },
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          sliver: SliverToBoxAdapter(
            child: MoonDotIndicator(
              selectedDot: selectedDot.value,
              dotCount: 10,
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
              return MiruGridTile(
                title: item.title,
                subtitle: item.episodeTitle,
                imageUrl: item.cover,
                onTap: () {
                  final extensionIsExist = ExtensionUtils.runtimes.containsKey(
                    item.package,
                  );
                  if (extensionIsExist) {
                    context.push(
                      '/search/detail',
                      extra: DetailParam(
                        service: ExtensionUtils.runtimes[item.package]!,
                        url: item.url,
                      ),
                    );
                  }
                },
              );
            }, childCount: history.length),
          ),
        ),
      ],
    );
  }
}
