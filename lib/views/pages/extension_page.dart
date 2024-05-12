import 'package:flutter/material.dart';
import 'package:miru_app_new/views/widgets/index.dart';

class ExtensionPage extends StatefulWidget {
  const ExtensionPage({super.key});

  @override
  State<ExtensionPage> createState() => _ExtensionPageState();
}

class _ExtensionPageState extends State<ExtensionPage> {
  bool _isInstalledPage = true;

  @override
  Widget build(BuildContext context) {
    return MiruScaffold(
      appBar: const MiruAppBar(
        title: Text('Extensions'),
      ),
      sidebar: [
        const SideBarListTitle(title: '搜索'),
        const SideBarSearchBar(),
        const SizedBox(height: 10),
        SidebarExpander(
          title: "状态",
          expanded: true,
          children: [
            SideBarListTile(
              title: '已安装',
              selected: _isInstalledPage,
              onPressed: () {
                setState(() {
                  _isInstalledPage = true;
                });
              },
            ),
            const SizedBox(height: 8),
            SideBarListTile(
              title: '未安装',
              selected: !_isInstalledPage,
              onPressed: () {
                setState(() {
                  _isInstalledPage = false;
                });
              },
            ),
          ],
        ),
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
          title: "仓库",
          expanded: true,
          children: [
            SideBarListTile(
              title: '官方',
              selected: true,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 10),
        SidebarExpander(
          title: "语言",
          expanded: false,
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
              crossAxisCount: constraints.maxWidth ~/ 280,
              childAspectRatio: 1.4,
            ),
            mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth ~/ 240,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              return ExtensionGridTile(
                name: 'Extension $index',
                version: '1.0.0',
                author: 'Author $index',
                type: 'Type $index',
                icon: 'https://picsum.photos/100/100?random=$index',
                onInstall: () {},
              );
            },
            itemCount: 20,
          );
        },
      ),
    );
  }
}
