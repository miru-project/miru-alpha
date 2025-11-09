import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/widgets/card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/widgets/grid_view/index.dart';
import 'home_page.dart';
import 'package:go_router/go_router.dart';

class HistoryPage extends StatefulHookConsumerWidget {
  const HistoryPage({super.key});
  @override
  createState() => _HistoryPageState();
}

class CarsouelScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
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
      final history = await DatabaseService.getHistorysByType();
      ref.read(mainPageProvider.notifier).updateHistory(history);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = useCarouselController();
    // final selectedDot = useState(0);
    int index = 0;
    useEffect(() {
      Timer.periodic(const Duration(seconds: 5), (timer) {
        if (historyLen == 0) return;
        controller.animateToItem(index);
        index++;
      });
      return null;
    }, [controller]);
    final width = DeviceUtil.getWidth(context);
    final history = ref.watch(mainPageProvider).history;
    historyLen = history.length;
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: DeviceUtil.device(
              mobile: 250,
              desktop: 300,
              context: context,
            ),
            width: 1000,
            child: ScrollConfiguration(
              behavior: CarsouelScrollBehavior(),
              child: CarouselView(
                itemSnapping: true,
                controller: controller,
                scrollDirection: Axis.horizontal,
                onTap: (value) {
                  final item = history[value];
                  final meta = ref.read(extensionPageProvider).metaData;
                  final ExtensionMeta? ext = meta.firstWhereOrNull(
                    (element) => element.packageName == item.package,
                  );
                  if (ext == null) return;
                  context.push(
                    '/search/single/detail',
                    extra: DetailParam(meta: ext, url: item.url),
                  );
                },
                itemExtent: DeviceUtil.device(
                  mobile: width - 32,
                  desktop: width * .4,
                  context: context,
                ),
                shrinkExtent: 200.0,
                children: List.generate(
                  history.length > 10 ? 10 : history.length,
                  (itemIndex) {
                    if (history.length <= itemIndex) {
                      return FCard.raw(
                        child: Center(
                          child: Text(
                            'No history',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              // fontFamily: "HarmonyOS_Sans",
                            ),
                          ),
                        ),
                      );
                    }
                    final item = history[itemIndex];
                    return SizedBox(
                      width: 100,
                      child: HomePageCarousel(item: item),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        // SliverPadding(
        //   padding: const EdgeInsets.symmetric(vertical: 10),
        //   sliver: SliverToBoxAdapter(
        //     child: MoonDotIndicator(
        //       selectedDot: selectedDot.value,
        //       dotCount: 10,
        //     ),
        //   ),
        // ),
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
                  final extensionIsExist = ExtensionUtils.runtimes.containsKey(
                    item.package,
                  );
                  if (extensionIsExist) {
                    context.push(
                      '/search/detail',
                      extra: DetailParam(
                        meta: ExtensionUtils.runtimes[item.package]!,
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
