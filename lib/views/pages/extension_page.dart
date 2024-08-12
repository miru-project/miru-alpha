// import 'dart:ffi';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/index.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:miru_app_new/utils/network/index.dart';
import 'package:moon_design/moon_design.dart';
import '../../model/index.dart';

class ExtensionPage extends StatefulWidget {
  const ExtensionPage({super.key});

  @override
  State<ExtensionPage> createState() => _ExtensionPageState();
}

class _ExtensionPageState extends State<ExtensionPage> {
  final RxBool _isInstalledPage = false.obs;
  final Stream<List<GithubExtension>> _extensionStream =
      GithubNetwork.fetchRepo().asStream();
  final List<GithubExtension> _fetchedRepo = [];
  final RxList<GithubExtension> _extensionList = <GithubExtension>[].obs;
  final RxInt _selectedType = 0.obs;
  static const List<String> _types = ['', 'bangumi', 'comic', 'fikushon'];
  void _filterExtensionListWithName(String query) {
    final filtered = _fetchedRepo.where((element) {
      return element.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
    _extensionList.assignAll(filtered);
  }

  void _filterByInstalled() {
    final filtered = _fetchedRepo.where((element) {
      return ExtensionUtils.runtimes.containsKey(element.package) ==
              _isInstalledPage.value &&
          (_selectedType.value == 0 ||
              element.type.contains(_types[_selectedType.value]));
    }).toList();
    _extensionList.assignAll(filtered);
  }

  _install(String package) async {
    try {
      final url = MiruStorage.getSettingSync(SettingKey.miruRepoUrl, String) +
          "/repo/$package.js";
      await ExtensionUtils.install(url, context);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  _uninstall(String package) async {
    setState(() {});
    try {
      await ExtensionUtils.uninstall(package);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MiruScaffold(
      appBar: const MiruAppBar(
        title: Text('Extensions'),
      ),
      sidebar: [
        const SideBarListTitle(title: '搜索'),
        SideBarSearchBar(
          onChanged: _filterExtensionListWithName,
        ),
        const SizedBox(height: 10),
        Obx(() => SidebarExpander(
              title: "状态",
              expanded: true,
              children: [
                SideBarListTile(
                  title: '已安装',
                  selected: _isInstalledPage.value,
                  onPressed: () {
                    _isInstalledPage.value = true;
                    _filterByInstalled();
                  },
                ),
                const SizedBox(height: 8),
                SideBarListTile(
                  title: '未安装',
                  selected: !_isInstalledPage.value,
                  onPressed: () {
                    _isInstalledPage.value = false;
                    _filterByInstalled();
                  },
                ),
              ],
            )),
        const SizedBox(height: 10),
        Obx(() => SidebarExpander(
              title: "分类",
              expanded: true,
              children: [
                SideBarListTile(
                  title: '全部',
                  selected: _selectedType.value == 0,
                  onPressed: () {
                    _selectedType.value = 0;
                    _filterByInstalled();
                  },
                ),
                const SizedBox(height: 8),
                SideBarListTile(
                  title: '影视',
                  selected: _selectedType.value == 1,
                  onPressed: () {
                    _selectedType.value = 1;
                    _filterByInstalled();
                  },
                ),
                const SizedBox(height: 8),
                SideBarListTile(
                  title: '漫画',
                  selected: _selectedType.value == 2,
                  onPressed: () {
                    _selectedType.value = 2;
                    _filterByInstalled();
                  },
                ),
                const SizedBox(height: 8),
                SideBarListTile(
                  title: '小说',
                  selected: _selectedType.value == 3,
                  onPressed: () {
                    _selectedType.value = 3;
                    _filterByInstalled();
                  },
                ),
              ],
            )),
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
          return StreamBuilder(
              stream: _extensionStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _fetchedRepo.assignAll(snapshot.data!);
                  _filterExtensionListWithName('');
                  // debugPrint(snapshot.data.toString());
                  return PlatformWidget(
                    desktopWidget: Obx(() => MiruGridView(
                          desktopGridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: constraints.maxWidth ~/ 280,
                            childAspectRatio: 1.4,
                          ),
                          mobileGridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: constraints.maxWidth ~/ 240,
                            childAspectRatio: 1.6,
                          ),
                          itemBuilder: (context, index) {
                            return ExtensionGridTile(
                              isInstalled: ExtensionUtils.runtimes
                                  .containsKey(_extensionList[index].package),
                              name: _extensionList[index].name,
                              version: _extensionList[index].version,
                              author: _extensionList[index].author,
                              type: _extensionList[index].type,
                              icon: _extensionList[index].icon,
                              onInstall: () {
                                _install(_extensionList[index].package);
                              },
                              onUninstall: () {
                                _uninstall(_extensionList[index].package);
                              },
                            );
                          },
                          itemCount: _extensionList.length,
                        )),
                    mobileWidget: MiruListView.builder(
                        itemBuilder: (context, index) => Obx(() => MoonMenuItem(
                            onTap: () {},
                            trailing: Row(
                              children: [
                                if (ExtensionUtils.runtimes
                                    .containsKey(_extensionList[index].package))
                                  MoonButton(
                                    onTap: () {
                                      _uninstall(_extensionList[index].package);
                                    },
                                    leading: const Icon(
                                        MoonIcons.generic_delete_24_regular),
                                  )
                                else
                                  MoonButton(
                                    onTap: () {
                                      _install(_extensionList[index].package);
                                    },
                                    leading: const Icon(
                                        MoonIcons.generic_download_24_regular),
                                  )
                              ],
                            ),
                            leading: SizedBox(
                                width: 40,
                                height: 40,
                                child: _extensionList[index].icon == null
                                    ? null
                                    : Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: ExtendedImage.network(
                                          _extensionList[index].icon!,
                                          loadStateChanged:
                                              (ExtendedImageState state) {
                                            if (state.extendedImageLoadState ==
                                                LoadState.failed) {
                                              return const Icon(MoonIcons
                                                  .notifications_error_16_regular); // Fallback widget
                                            }
                                            return null; // Use the default widget
                                          },
                                        ),
                                      )),
                            label: Text(_extensionList[index].name))),
                        itemCount: _extensionList.length),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              });
        },
      ),
    );
  }
}
