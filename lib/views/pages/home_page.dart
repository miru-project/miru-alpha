import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:miru_app_new/utils/database_service.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';

class HistoryPage extends HookConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDot = useState(0);
    final history = DatabaseService.db.historys
        .where()
        .sortByDateDesc()
        .limit(40)
        .findAllSync();
    return (CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Title',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              )),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: OverflowBox(
              maxWidth: MediaQuery.of(context).size.width,
              child: MoonCarousel(
                gap: 32,
                itemCount: history.length,
                itemExtent: MediaQuery.of(context).size.width - 32,
                physics: const PageScrollPhysics(),
                onIndexChanged: (int index) => selectedDot.value = index,
                itemBuilder: (BuildContext context, int itemIndex, int _) {
                  final item = history[itemIndex];
                  return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: context
                              .moonTheme?.textInputTheme.colors.textColor
                              .withAlpha(20),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ExtendedImage.network(
                            item.cover ?? '',
                          ),
                        ),
                        const SizedBox(width: 10),
                        DefaultTextStyle(
                            style: TextStyle(
                              color:
                                  context.moonTheme?.chipTheme.colors.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            child: SizedBox(
                                width: DeviceUtil.getWidth(context) - 200,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      item.title,
                                      maxLines: 2,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(item.episodeTitle,
                                        style: const TextStyle(fontSize: 15)),
                                    const SizedBox(height: 10),
                                    Text(
                                      item.date.toUtc().toString(),
                                    ),
                                  ],
                                )))
                      ]));
                },
              ),
            ),
          ),
        ),

        SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            sliver: SliverToBoxAdapter(
              child: MoonDotIndicator(
                selectedDot: selectedDot.value,
                dotCount: 5,
              ),
            )),
        // LayoutBuilder(
        //   builder: (context, constraints) => MiruGridView.silver(
        //       mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //         crossAxisCount: constraints.maxWidth ~/ 110,
        //         childAspectRatio: 0.6,
        //       ),
        //       desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //         crossAxisCount: constraints.maxWidth ~/ 110,
        //         childAspectRatio: 0.6,
        //       ),
        //       itemBuilder: (context, index) {
        //         final item = history[index];
        //         return MiruGridTile(
        //           title: item.title,
        //           subtitle: item.date.toString(),
        //           imageUrl: item.cover,
        //           onTap: () {
        //             // Handle item tap
        //           },
        //         );
        //       },
        //       itemCount: history.length),
        // ),
        SliverPadding(
          padding: const EdgeInsets.all(15.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: DeviceUtil.getWidth(context) ~/ 110,
              childAspectRatio: 0.6,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = history[index];
                return MiruGridTile(
                  title: item.title,
                  subtitle: item.date.toString(),
                  imageUrl: item.cover,
                  onTap: () {
                    // Handle item tap
                  },
                );
              },
              childCount: history.length,
            ),
          ),
        ),
      ],
    ));
  }
}

class HomePage extends HookWidget {
  const HomePage({super.key});
  static const _categories = ['歷史', '分類', '收藏夹'];
  @override
  Widget build(BuildContext context) {
    final controler = useTabController(initialLength: _categories.length);
    return MiruScaffold(
      // appBar: const MiruAppBar(
      //   // title: Text('Home'),
      // ),
      sidebar: (MediaQuery.of(context).size.width < 800)
          //mobile
          ? [
              const SideBarListTitle(title: '主页'),
              const SideBarSearchBar(),
              const SizedBox(height: 10),
              MoonTabBar(
                tabController: controler,
                tabs: List.generate(
                  _categories.length,
                  (index) => MoonTab(
                    label: Text(_categories[index]),
                  ),
                ),
              ),
              // const SizedBox(height: 10),
              SizedBox(
                  height: 300,
                  child: TabBarView(controller: controler, children: [
                    CategoryGroup(items: const ['全部'], onpress: (val) {}),
                    CategoryGroup(
                        items: const ['全部', '影視', '漫畫', '小說'],
                        onpress: (val) {}),
                    CategoryGroup(items: const ['全部'], onpress: (val) {}),
                  ])),
            ]
          : <Widget>[
              const SideBarListTitle(title: '主页'),
              const SideBarSearchBar(),
              const SizedBox(height: 10),
              SidebarExpander(
                title: "歷史",
                expanded: true,
                child: CategoryGroup(
                    needSpacer: false, items: const ['全部'], onpress: (val) {}),
              ),
              SidebarExpander(
                title: "分类",
                expanded: true,
                child: CategoryGroup(
                    needSpacer: false,
                    items: const ['全部', '影視', '漫畫', '小說'],
                    onpress: (val) {}),
              ),
              const SizedBox(height: 10),
              SidebarExpander(
                title: '收藏夹',
                actions: [
                  Button(
                    onPressed: () {},
                    child: const Icon(
                      Icons.add,
                      size: 15,
                    ),
                  ),
                ],
                expanded: true,
                child: CategoryGroup(
                    needSpacer: false, items: const ['全部'], onpress: (val) {}),
              ),
            ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          return TabBarView(controller: controler, children: <Widget>[
            const HistoryPage(),
            // MiruGridView(
            //   desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: constraints.maxWidth ~/ 150,
            //     childAspectRatio: 0.6,
            //   ),
            //   mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: constraints.maxWidth ~/ 110,
            //     childAspectRatio: 0.6,
            //   ),
            //   itemBuilder: (context, index) {
            //     return Container();
            //     // return MiruGridTile(
            //     //   title: 'Title $index',
            //     //   subtitle: 'Subtitle $index',
            //     //   imageUrl: 'https://picsum.photos/200/300?random=$index',
            //     //   onTap: () {
            //     //     Get.to(() => const DetailPage(), id: 1, popGesture: false);
            //     //   },
            //     // );
            //   },
            //   itemCount: 20,
            // ),
            Container(),
            Container()
          ]);
        },
      ),
    );
  }
}
