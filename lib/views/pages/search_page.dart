import 'package:flutter/material.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/views/widgets/homepage/latest.dart';
import 'package:miru_app_new/views/widgets/index.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MiruScaffold(
      appBar: const MiruAppBar(
        title: Text('Search'),
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
        const SizedBox(height: 15),
        SidebarExpander(
          title: '语言',
          expanded: true,
          children: [
            SideBarListTile(
              title: '全部',
              selected: true,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 15),
        SidebarExpander(
          title: '扩展',
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
          final service = ExtensionUtils.runtimes.entries.toList();

          return MiruListView.builder(
            itemBuilder: (context, index) {
              return Latest(
                extensionService: service[index].value,
              );
            },
            itemCount: service.length,
          );
          // return MiruGridView(
          //   desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: constraints.maxWidth ~/ 150,
          //     childAspectRatio: 0.6,
          //   ),
          //   mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: constraints.maxWidth ~/ 110,
          //     childAspectRatio: 0.6,
          //   ),
          //   itemBuilder: (context, index) {
          //     return MiruGridTile(
          //       title: 'Title $index',
          //       subtitle: 'Subtitle $index',
          //       imageUrl: 'https://picsum.photos/200/300?random=$index',
          //       onTap: () {},
          //     );
          //   },
          //   itemCount: 20,
          // );
        },
      ),
    );
  }
}
