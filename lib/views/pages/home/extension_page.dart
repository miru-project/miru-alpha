import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/theme/select_group_style.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/index.dart';
import 'package:miru_app_new/utils/network/github_network.dart';
import 'package:miru_app_new/views/widgets/index.dart';

import 'package:moon_design/moon_design.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';
import '../../../model/index.dart';

class ExtensionPage extends StatefulHookConsumerWidget {
  const ExtensionPage({super.key});
  @override
  createState() => _ExtensionPageState();
}

final overrideTheme = FThemes.zinc.dark;

class _ExtensionPageState extends ConsumerState<ExtensionPage> {
  // const ExtensionPage({super.key});
  static const List<String> _types = ['', 'bangumi', 'manga', 'fikushon'];
  static const _categories = ['Status', 'Type', 'Repo', 'Language'];
  late final SnappingSheetController snappingController;

  @override
  void initState() {
    snappingController = SnappingSheetController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final extensionStream = useStream(GithubNetwork.fetchRepo().asStream());
    final fetchedRepo = ValueNotifier(<ExtensionRepo>[]);
    final extensionList = ValueNotifier(<ExtensionRepo>[]);
    final scrollController = useScrollController();
    void filterExtensionListWithName(String query) {
      final filtered =
          fetchedRepo.value.where((element) {
            return element.name.toLowerCase().contains(query.toLowerCase());
          }).toList();
      extensionList.value = filtered;
    }

    final snapShot = ref.watch(fetchExtensionRepoProvider);
    final controller = useTabController(initialLength: _categories.length);

    return MiruScaffold(
      scrollController: scrollController,
      snappingSheetController: snappingController,
      mobileHeader: const SideBarListTitle(title: 'Extension'),
      sidebar:
          DeviceUtil.isMobileLayout(context)
              //mobile
              ? <Widget>[
                SideBarSearchBar(onChanged: filterExtensionListWithName),
                const SizedBox(height: 10),
                Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (_) {
                    // scrollController.jumpTo(100);
                    debugPrint(snappingController.currentPosition.toString());
                    if (snappingController.currentPosition < 200) {
                      snappingController.setSnappingSheetPosition(400);
                    }

                    // snappingController.snapToPosition(
                    //   const SnappingPosition.factor(positionFactor: 1),
                    // );
                  },
                  child: MoonTabBar(
                    tabController: controller,
                    tabs: List.generate(_categories.length, (index) => MoonTab(label: Text(_categories[index]))),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    controller: controller,
                    children: [
                      CategoryGroup(
                        items: const ['Installed', 'Not installed'],
                        onpress: (val) {
                          final filtered =
                              fetchedRepo.value.where((element) {
                                return ExtensionUtils.runtimes.containsKey("element.package") && val == 0;
                              }).toList();
                          extensionList.value = filtered;
                          if (filtered.isNotEmpty) {
                            return;
                          }
                          extensionList.value =
                              fetchedRepo.value.where((element) {
                                return !ExtensionUtils.runtimes.containsKey("element.package") && val == 1;
                              }).toList();
                        },
                      ),
                      CategoryGroup(
                        items: const ['ALL', 'Video', 'Manga', 'Novel'],
                        onpress: (val) {},
                        //  {
                        //   final filtered =
                        //       fetchedRepo.value.where((element) {
                        //         return val == 0 || element.type.contains(_types[val]);
                        //       }).toList();
                        //   extensionList.value = filtered;
                        // },
                      ),
                      CategoryGroup(items: const ['ALL'], onpress: (val) {}),
                      CategoryGroup(items: const ['ALL'], onpress: (val) {}),
                    ],
                  ),
                ),
              ]
              //desktop
              : <Widget>[
                const SideBarListTitle(title: 'Extension'),
                SideBarSearchBar(onChanged: filterExtensionListWithName),
                const SizedBox(height: 10),
                SidebarExpander(
                  title: 'Status',
                  child: CategoryGroup(
                    needSpacer: false,
                    items: const ['Installed', 'Not installed'],
                    onpress: (val) {
                      final filtered =
                          fetchedRepo.value.where((element) {
                            return ExtensionUtils.runtimes.containsKey("element.package") && val == 0;
                          }).toList();
                      extensionList.value = filtered;
                      if (filtered.isNotEmpty) {
                        return;
                      }
                      extensionList.value =
                          fetchedRepo.value.where((element) {
                            return !ExtensionUtils.runtimes.containsKey("element.package") && val == 1;
                          }).toList();
                    },
                  ),
                ),
                SidebarExpander(
                  title: 'Type',
                  child: CategoryGroup(
                    needSpacer: false,
                    items: const ['ALL', 'Video', 'Manga', 'Novel'],
                    onpress: (val) {},
                    // {
                    //   final filtered =
                    //       fetchedRepo.value.where((element) {
                    //         return val == 0 || element.type.contains(_types[val]);
                    //       }).toList();
                    //   extensionList.value = filtered;
                    // },
                  ),
                ),
                SidebarExpander(title: 'Repo', child: CategoryGroup(needSpacer: false, items: const ['ALL'], onpress: (val) {})),
                SidebarExpander(title: 'Language', child: CategoryGroup(needSpacer: false, items: const ['ALL'], onpress: (val) {})),
              ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          return snapShot.when(
            data: (fetchedValue) {
              fetchedRepo.value = fetchedValue;
              extensionList.value = fetchedValue;
              return ValueListenableBuilder(
                valueListenable: extensionList,
                builder: (context, val, child) {
                  final value = val[0].extensions;
                  return PlatformWidget(
                    desktopWidget: Column(
                      children: [
                        Row(
                          children: [
                            ClearableSelectPage(hintText: 'ALL', title: "Type", items: ['Video', 'Manga', 'Novel']),
                            ClearableSelectPage(hintText: 'ALL', title: "Installed", items: ['Yes', 'No']),

                            // ConstrainedBox(
                            //   constraints: const BoxConstraints(maxWidth: 200, maxHeight: 65),
                            //   child: FTheme(
                            //     data: overrideTheme,
                            //     child: FSelectGroup<CheckBoxInstalled>(
                            //       style:
                            //           selectGroupStyle(
                            //             colors: FThemes.zinc.dark.colors,
                            //             typography: context.theme.typography,
                            //             style: context.theme.style,
                            //           ).call,
                            //       controller: FSelectGroupController(),
                            //       label: const Text('Installation'),
                            //       children: [
                            //         FCheckbox.grouped(value: CheckBoxInstalled.installed, label: const Text('Installed')),
                            //         FCheckbox.grouped(value: CheckBoxInstalled.notInstalled, label: const Text('Not Installed')),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        Expanded(
                          child: MiruGridView(
                            desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: constraints.maxWidth ~/ 280,
                              childAspectRatio: 1.4,
                            ),
                            mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: constraints.maxWidth ~/ 240,
                              childAspectRatio: 1.6,
                            ),
                            itemBuilder: (context, index) {
                              final data = value[index];
                              return _ExtensionTile(data: data);
                            },
                            itemCount: extensionList.value.length,
                          ),
                        ),
                      ],
                    ),
                    mobileWidget: EasyRefresh(
                      scrollController: scrollController,
                      onRefresh: () {
                        ref.invalidate(fetchExtensionRepoProvider);
                        ref.read(fetchExtensionRepoProvider);
                      },
                      child: MiruListView.builder(
                        controller: scrollController,
                        itemBuilder: (context, index) {
                          final data = value[index];
                          return _ExtensionTile(data: data);
                        },
                        itemCount: extensionList.value.length,
                      ),
                    ),
                  );
                },
              );
            },
            error:
                (err, stack) => Center(
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 30, vertical: 20),
                    child: Column(
                      children: [
                        FAccordion(
                          children: [
                            FAccordionItem(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Error: $err"),
                                  Padding(
                                    padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                                    child: FTooltip(
                                      hoverEnterDuration: Duration(milliseconds: 300),
                                      hover: true,
                                      tipBuilder: (context, controller) => const Text('Reload'),
                                      child: FButton.icon(
                                        style: FButtonStyle.outline(),
                                        onPress: () {
                                          ref.invalidate(fetchExtensionRepoProvider);
                                          ref.read(fetchExtensionRepoProvider);
                                        },
                                        child: const Icon(FIcons.refreshCcw),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              child: Text(stack.toString()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            loading: () => const Center(child: FProgress.circularIcon()),
          );
        },
      ),
    );
  }
}

class _ExtensionTile extends HookWidget {
  final GithubExtension data;
  // final bool isInstalled;
  const _ExtensionTile({required this.data});
  Future<void> install(String package, BuildContext context) async {
    try {
      final url = MiruStorage.getSettingSync(SettingKey.miruRepoUrl, String) + "/repo/$package.js";
      // await ExtensionUtils.install(url, context);
      // CoreNetwork.requestJSON(path)
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> uninstall(String package) async {
    try {
      // await ExtensionUtils.uninstall(package);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final installed = useState(ExtensionUtils.runtimes.containsKey(data.package));
    return PlatformWidget(
      mobileWidget: MoonMenuItem(
        onTap: () {},
        trailing: Row(
          children: [
            if (ExtensionUtils.runtimes.containsKey(data.package) || installed.value)
              MoonButton(
                onTap: () async {
                  await uninstall(data.package);
                  installed.value = false;
                },
                leading: const Icon(MoonIcons.generic_delete_24_regular),
              )
            else
              MoonButton(
                onTap: () async {
                  await install(data.package, context);
                  installed.value = true;
                },
                leading: const Icon(MoonIcons.generic_download_24_regular),
              ),
          ],
        ),
        leading: SizedBox(
          width: 40,
          height: 40,
          child:
              data.icon == null
                  ? null
                  : ExtendedImage.network(
                    borderRadius: BorderRadius.circular(10),
                    shape: BoxShape.rectangle,
                    cache: true,
                    data.icon!,
                    loadStateChanged: (ExtendedImageState state) {
                      if (state.extendedImageLoadState == LoadState.failed) {
                        return const Icon(MoonIcons.notifications_error_16_regular); // Fallback widget
                      }
                      return null; // Use the default widget
                    },
                  ),
        ),
        label: Text(data.name),
      ),
      desktopWidget: ExtensionGridTile(
        isInstalled: installed.value,
        name: data.name,
        version: data.version,
        author: data.author,
        type: data.type,
        icon: data.icon,
        onInstall: () async {
          install(data.package, context);
          installed.value = true;
        },
        onUninstall: () async {
          await uninstall(data.package);
          installed.value = false;
        },
      ),
    );
  }
}

class ClearableSelectPage extends StatelessWidget {
  const ClearableSelectPage({super.key, required this.title, required this.items, this.hintText});
  final String title;
  final String? hintText;
  final List<String> items;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsetsGeometry.only(left: 5), child: Text(title, style: TextStyle(fontSize: 13))),
          const SizedBox(height: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200, maxHeight: 50),
            child: FSelect<String>(
              style: FSelectStyle.inherit(colors: context.theme.colors, typography: overrideTheme.typography, style: context.theme.style).call,
              hint: hintText,
              format: (s) => s,
              clearable: true,
              children: [for (final item in items) FSelectItem(item, item)],
            ),
          ),
        ],
      ),
    );
  }
}

enum CheckBoxInstalled { installed, notInstalled }

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
                ),
            ],
          ),
          leading: SizedBox(
            width: 40,
            height: 40,
            child:
                data.icon == null
                    ? null
                    : Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                      child: ExtendedImage.network(
                        data.icon!,
                        loadStateChanged: (ExtendedImageState state) {
                          if (state.extendedImageLoadState == LoadState.failed) {
                            return const Icon(MoonIcons.notifications_error_16_regular); // Fallback widget
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
