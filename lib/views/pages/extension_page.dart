// import 'dart:ffi';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/index.dart';
import 'package:miru_app_new/views/widgets/index.dart';

import 'package:moon_design/moon_design.dart';
import '../../model/index.dart';

class ExtensionPage extends HookConsumerWidget {
  const ExtensionPage({super.key});
  static const List<String> _types = ['', 'bangumi', 'manga', 'fikushon'];
  static const _categories = ['狀態', '分類', '倉庫', '語言'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final extensionStream = useStream(GithubNetwork.fetchRepo().asStream());
    final fetchedRepo = ValueNotifier(<GithubExtension>[]);
    final extensionList = ValueNotifier(<GithubExtension>[]);

    void filterExtensionListWithName(String query) {
      final filtered = fetchedRepo.value.where((element) {
        return element.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
      extensionList.value = filtered;
    }

    Future<void> install(String package) async {
      try {
        final url = MiruStorage.getSettingSync(SettingKey.miruRepoUrl, String) +
            "/repo/$package.js";
        await ExtensionUtils.install(url, context);
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    Future<void> uninstall(String package) async {
      try {
        await ExtensionUtils.uninstall(package);
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    final snapShot = ref.watch(fetchExtensionRepoProvider);
    final controller = useTabController(initialLength: _categories.length);
    return MiruScaffold(
      sidebar: MediaQuery.of(context).size.width < 800
          //mobile
          ? <Widget>[
              const SideBarListTitle(title: '擴展'),
              SideBarSearchBar(
                onChanged: filterExtensionListWithName,
              ),
              const SizedBox(height: 10),
              MoonTabBar(
                tabController: controller,
                tabs: List.generate(
                  _categories.length,
                  (index) => MoonTab(
                    label: Text(_categories[index]),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                  height: 300,
                  child: TabBarView(
                    controller: controller,
                    children: [
                      CategoryGroup(
                        items: const ['已安裝', '未安裝'],
                        onpress: (val) {
                          final filtered = fetchedRepo.value.where((element) {
                            return ExtensionUtils.runtimes
                                    .containsKey(element.package) &&
                                val == 0;
                          }).toList();
                          extensionList.value = filtered;
                          if (filtered.isNotEmpty) {
                            return;
                          }
                          extensionList.value =
                              fetchedRepo.value.where((element) {
                            return !ExtensionUtils.runtimes
                                    .containsKey(element.package) &&
                                val == 1;
                          }).toList();
                        },
                      ),
                      CategoryGroup(
                          items: const ['全部', '影視', '漫畫', '小說'],
                          onpress: (val) {
                            final filtered = fetchedRepo.value.where((element) {
                              return val == 0 ||
                                  element.type.contains(_types[val]);
                            }).toList();
                            extensionList.value = filtered;
                          }),
                      CategoryGroup(items: const ['全部'], onpress: (val) {}),
                      CategoryGroup(items: const ['全部'], onpress: (val) {})
                    ],
                  )),
            ]
          : <Widget>[
              const SideBarListTitle(title: '擴展'),
              SideBarSearchBar(
                onChanged: filterExtensionListWithName,
              ),
              const SizedBox(height: 10),
              SidebarExpander(
                title: "状态",
                child: CategoryGroup(
                  needSpacer: false,
                  items: const ['已安裝', '未安裝'],
                  onpress: (val) {
                    final filtered = fetchedRepo.value.where((element) {
                      return ExtensionUtils.runtimes
                              .containsKey(element.package) &&
                          val == 0;
                    }).toList();
                    extensionList.value = filtered;
                    if (filtered.isNotEmpty) {
                      return;
                    }
                    extensionList.value = fetchedRepo.value.where((element) {
                      return !ExtensionUtils.runtimes
                              .containsKey(element.package) &&
                          val == 1;
                    }).toList();
                  },
                ),
              ),
              SidebarExpander(
                  title: '分類',
                  child: CategoryGroup(
                      needSpacer: false,
                      items: const ['全部', '影視', '漫畫', '小說'],
                      onpress: (val) {
                        final filtered = fetchedRepo.value.where((element) {
                          return val == 0 || element.type.contains(_types[val]);
                        }).toList();
                        extensionList.value = filtered;
                      })),
              SidebarExpander(
                  title: '倉庫',
                  child: CategoryGroup(items: const ['全部'], onpress: (val) {})),
              SidebarExpander(
                  title: '語言',
                  child: CategoryGroup(items: const ['全部'], onpress: (val) {})),
              // SidebarExpander(
              //   title: "状态",
              //   expanded: true,
              //   children: [
              //     SideBarListTile(
              //       title: '已安装',
              //       selected: isInstalledPage.value,
              //       onPressed: () {
              //         isInstalledPage.value = true;
              //         filterByInstalled();
              //       },
              //     ),
              //     const SizedBox(height: 8),
              //     SideBarListTile(
              //       title: '未安装',
              //       selected: !isInstalledPage.value,
              //       onPressed: () {
              //         isInstalledPage.value = false;
              //         filterByInstalled();
              //       },
              //     ),
              //   ],
              // ),
              const SizedBox(height: 10),
              // SidebarExpander(
              //   title: "分类",
              //   expanded: true,
              //   children: [
              //     SideBarListTile(
              //       title: '全部',
              //       selected: selectedType.value == 0,
              //       onPressed: () {
              //         selectedType.value = 0;
              //         filterByInstalled();
              //       },
              //     ),
              //     const SizedBox(height: 8),
              //     SideBarListTile(
              //       title: '影视',
              //       selected: selectedType.value == 1,
              //       onPressed: () {
              //         selectedType.value = 1;
              //         filterByInstalled();
              //       },
              //     ),
              //     const SizedBox(height: 8),
              //     SideBarListTile(
              //       title: '漫画',
              //       selected: selectedType.value == 2,
              //       onPressed: () {
              //         selectedType.value = 2;
              //         filterByInstalled();
              //       },
              //     ),
              //     const SizedBox(height: 8),
              //     SideBarListTile(
              //       title: '小说',
              //       selected: selectedType.value == 3,
              //       onPressed: () {
              //         selectedType.value = 3;
              //         filterByInstalled();
              //       },
              //     ),
              //   ],
              // ),
              const SizedBox(height: 10),
              // SidebarExpander(
              //   title: "仓库",
              //   expanded: true,
              //   children: [
              //     SideBarListTile(
              //       title: '官方',
              //       selected: true,
              //       onPressed: () {},
              //     ),
              //   ],
              // ),
              const SizedBox(height: 10),
              // SidebarExpander(
              //   title: "语言",
              //   expanded: false,
              //   children: [
              //     SideBarListTile(
              //       title: '全部',
              //       selected: true,
              //       onPressed: () {},
              //     ),
              //   ],
              // ),
            ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          return snapShot.when(
            data: (fetchedValue) {
              fetchedRepo.value = fetchedValue;
              extensionList.value = fetchedValue;
              return ValueListenableBuilder(
                  valueListenable: extensionList,
                  builder: (context, value, child) {
                    return PlatformWidget(
                      desktopWidget: MiruGridView(
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
                          final data = value[index];
                          return ExtensionGridTile(
                            isInstalled: ExtensionUtils.runtimes
                                .containsKey(data.package),
                            name: data.name,
                            version: data.version,
                            author: data.author,
                            type: data.type,
                            icon: data.icon,
                            onInstall: () {
                              install(data.package);
                            },
                            onUninstall: () {
                              uninstall(data.package);
                            },
                          );
                        },
                        itemCount: extensionList.value.length,
                      ),
                      mobileWidget: MiruListView.builder(
                        itemBuilder: (context, index) {
                          final data = value[index];
                          return MoonMenuItem(
                            onTap: () {},
                            trailing: Row(
                              children: [
                                if (ExtensionUtils.runtimes
                                    .containsKey(data.package))
                                  MoonButton(
                                    onTap: () {
                                      uninstall(data.package);
                                    },
                                    leading: const Icon(
                                        MoonIcons.generic_delete_24_regular),
                                  )
                                else
                                  MoonButton(
                                    onTap: () {
                                      install(data.package);
                                    },
                                    leading: const Icon(
                                        MoonIcons.generic_download_24_regular),
                                  )
                              ],
                            ),
                            leading: SizedBox(
                              width: 40,
                              height: 40,
                              child: data.icon == null
                                  ? null
                                  : Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ExtendedImage.network(
                                        data.icon!,
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
                                    ),
                            ),
                            label: Text(data.name),
                          );
                        },
                        itemCount: extensionList.value.length,
                      ),
                    );
                  });
            },
            error: (err, stack) => Center(
              child: Column(children: [
                Text(err.toString()),
                MoonButton(
                  label: const Text('Reload'),
                  onTap: () {
                    ref.invalidate(fetchExtensionRepoProvider);
                    ref.read(fetchExtensionRepoProvider);
                  },
                )
              ]),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

class _ExtensionContent extends StatefulHookConsumerWidget {
  final List<GithubExtension> extensionList;
  const _ExtensionContent({required this.extensionList});
  @override
  _ExtensionContentState createState() => _ExtensionContentState();
}

class _ExtensionContentState extends ConsumerState<_ExtensionContent> {
  @override
  Widget build(conetext) {
    return MiruListView.builder(
      itemBuilder: (context, index) {
        final data = widget.extensionList[index];
        return MoonMenuItem(
          onTap: () {},
          trailing: Row(
            children: [
              if (ExtensionUtils.runtimes.containsKey(data.package))
                MoonButton(
                  onTap: () {
                    // uninstall(data.package);
                  },
                  leading: const Icon(MoonIcons.generic_delete_24_regular),
                )
              else
                MoonButton(
                  onTap: () {
                    // install(data.package);
                  },
                  leading: const Icon(MoonIcons.generic_download_24_regular),
                )
            ],
          ),
          leading: SizedBox(
            width: 40,
            height: 40,
            child: data.icon == null
                ? null
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ExtendedImage.network(
                      data.icon!,
                      loadStateChanged: (ExtendedImageState state) {
                        if (state.extendedImageLoadState == LoadState.failed) {
                          return const Icon(MoonIcons
                              .notifications_error_16_regular); // Fallback widget
                        }
                        return null; // Use the default widget
                      },
                    ),
                  ),
          ),
          label: Text(data.name),
        );
      },
      itemCount: widget.extensionList.length,
    );
  }
}
