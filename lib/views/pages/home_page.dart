import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app_new/views/pages/detail_page.dart';
import 'package:miru_app_new/views/widgets/index.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MiruScaffold(
      appBar: const MiruAppBar(
        title: Text('Home'),
      ),
      sidebar: [
        const SideBarListTitle(title: '搜索'),
        const SideBarSearchBar(),
        const SizedBox(height: 10),
        SidebarExpander(
          title: "分类",
          expanded: true,
          children: [
            SideBarListTile(
              title: '全部',
              selected: true,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            SideBarListTile(
              title: '影视',
              selected: false,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            SideBarListTile(
              title: '漫画',
              selected: false,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            SideBarListTile(
              title: '小说',
              selected: false,
              onPressed: () {},
            ),
          ],
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
          children: [
            SideBarListTile(
              title: '全部',
              selected: true,
              onPressed: () {},
            ),
          ],
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
              return MiruGridTile(
                title: 'Title $index',
                subtitle: 'Subtitle $index',
                imageUrl: 'https://picsum.photos/200/300?random=$index',
                onTap: () {
                  Get.to(() => const DetailPage(), id: 1, popGesture: false);
                },
              );
            },
            itemCount: 20,
          );
        },
      ),
    );
  }
}
