import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});
  static const _categories = ['分類', '收藏夹'];
  @override
  Widget build(BuildContext context) {
    final controler = useTabController(initialLength: _categories.length);
    return MiruScaffold(
      // appBar: const MiruAppBar(
      //   // title: Text('Home'),
      // ),
      sidebar: (MediaQuery.of(context).size.width < 800)
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
                    CategoryGroup(
                        items: const ['全部', '影視', '漫畫', '小說'],
                        onpress: (val) {}),
                    CategoryGroup(items: const ['全部'], onpress: (val) {}),
                  ])),
            ]
          : [
              const SideBarListTitle(title: '主页'),
              const SideBarSearchBar(),
              const SizedBox(height: 10),
              SidebarExpander(
                title: "分类",
                expanded: true,
                child: CategoryGroup(
                    items: const ['全部', '影視', '漫畫', '小說'], onpress: (val) {}),
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
                child: CategoryGroup(items: const ['全部'], onpress: (val) {}),
              ),
            ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          return MiruGridView(
            desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth ~/ 150,
              childAspectRatio: 0.6,
            ),
            mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth ~/ 110,
              childAspectRatio: 0.6,
            ),
            itemBuilder: (context, index) {
              return Container();
              // return MiruGridTile(
              //   title: 'Title $index',
              //   subtitle: 'Subtitle $index',
              //   imageUrl: 'https://picsum.photos/200/300?random=$index',
              //   onTap: () {
              //     Get.to(() => const DetailPage(), id: 1, popGesture: false);
              //   },
              // );
            },
            itemCount: 20,
          );
        },
      ),
    );
  }
}
