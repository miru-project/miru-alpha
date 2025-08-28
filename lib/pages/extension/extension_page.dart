import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/extension_page_provider.dart';
// removed direct network providers; notifier will fetch repos
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
// notifier handles network calls; removed direct network import
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:miru_app_new/widgets/core/search_filter_card.dart';
import 'package:miru_app_new/widgets/gridView/index.dart';
import 'package:miru_app_new/widgets/homepage/extension/clearable_select.dart';
import 'package:miru_app_new/widgets/index.dart';

import 'package:moon_design/moon_design.dart';
import '../../model/index.dart';

class ExtensionPage extends StatefulHookConsumerWidget {
  const ExtensionPage({super.key});
  @override
  createState() => _ExtensionPageState();
}

const _categories = ['Status', 'Type', 'Repo', 'Language'];

class _ExtensionPageState extends ConsumerState<ExtensionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedInstall = useState('Yes');
    final extState = ref.watch(extensionPageControllerProvider);
    final extNotifier = ref.read(extensionPageControllerProvider.notifier);

    final scrollController = useScrollController();
    final controller = useTabController(initialLength: _categories.length);
    final textController = useTextEditingController();
    useEffect(() {
      // load repos once after first frame to avoid modifying providers during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        extNotifier.loadRepos();
      });
      return null;
    }, const []);

    void filterExtensionListWithName(String query) =>
        extNotifier.filterByName(query);

    return MiruScaffold(
      scrollController: scrollController,
      snappingSheetController: extNotifier.snappingController,
      mobileHeader: const SideBarListTitle(title: 'Extension'),
      sidebar:
          DeviceUtil.isMobileLayout(context)
              ? <Widget>[
                // SideBarSearchBar(onChanged: filterExtensionListWithName),
                // const SizedBox(height: 10),
                Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (_) {
                    debugPrint(
                      extNotifier.snappingController.currentPosition.toString(),
                    );
                    if (extNotifier.snappingController.currentPosition < 200) {
                      extNotifier.snappingController.setSnappingSheetPosition(
                        400,
                      );
                    }
                  },
                  child: MoonTabBar(
                    tabController: controller,
                    tabs: List.generate(
                      _categories.length,
                      (index) => MoonTab(label: Text(_categories[index])),
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
                        items: const ['Installed', 'Not installed'],
                        onpress:
                            (val) => extNotifier.filterByInstalledIndex(val),
                      ),
                      CategoryGroup(
                        items: const ['ALL', 'Video', 'Manga', 'Novel'],
                        onpress: (val) {},
                      ),
                      CategoryGroup(items: const ['ALL'], onpress: (val) {}),
                      CategoryGroup(items: const ['ALL'], onpress: (val) {}),
                    ],
                  ),
                ),
              ]
              : <Widget>[],
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (extState.loading) {
            return const Center(child: FProgress.circularIcon());
          }

          // Build flat list preserving repo url and name for each extension
          final extensionsWithRepo = <Map<String, dynamic>>[];
          for (final repoItem in extState.extensionList) {
            for (final e in repoItem.extensions) {
              extensionsWithRepo.add({
                'ext': e,
                'repoUrl': repoItem.url,
                'repoName': repoItem.name,
              });
            }
          }

          return PlatformWidget(
            desktopWidget: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: MiruGridView(
                          paddingHeightOffest: 60,
                          desktopGridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                mainAxisExtent: 210,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          mobileGridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                mainAxisExtent: 150,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemBuilder: (context, index) {
                            final pair = extensionsWithRepo[index];
                            final data = pair['ext'] as GithubExtension;
                            final repoUrl = pair['repoUrl'] as String;
                            return _ExtensionTile(data: data, repoUrl: repoUrl);
                          },
                          itemCount: extensionsWithRepo.length,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 110,
                    width: constraints.maxWidth - 30,
                    child: SearchFilterCard(
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    ClearableSelect(
                                      hintText: 'ALL',
                                      title: "Type",
                                      items: ['Video', 'Manga', 'Novel'],
                                      onChange: (val) {
                                        switch (val) {
                                          case 'Video':
                                            val = 'bangumi';
                                            break;
                                          case 'Manga':
                                            val = 'manga';
                                            break;
                                          case 'Novel':
                                            val = 'fikushon';
                                            break;
                                          default:
                                            val = 'ALL';
                                        }
                                        extNotifier.filterByMediaType(val);
                                      },
                                    ),
                                    ClearableSelect(
                                      initialValue: 'Yes',
                                      hintText: 'ALL',
                                      title: "Installed",
                                      items: ['Yes', 'No'],
                                      onChange: (val) {
                                        selectedInstall.value = val ?? '';
                                      },
                                    ),
                                    Row(
                                      children: [
                                        ClearableSelect(
                                          hintText: 'ALL',
                                          title: "Repository",
                                          items: extNotifier.repoNames(),
                                          onChange: (val) {
                                            extNotifier.selectRepoByName(
                                              val ?? '',
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 20,
                                          ),
                                          child: FTooltip(
                                            tipBuilder: (context, controller) {
                                              return const Text(
                                                'Reload Repositories',
                                              );
                                            },
                                            child: FButton.icon(
                                              onPress: () async {
                                                await extNotifier.reloadRepos();
                                              },
                                              child: const Icon(Icons.refresh),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 280,
                                      height: 63,
                                      child: FTextField(
                                        style:
                                            FTextFieldStyle.inherit(
                                              colors: context.theme.colors,
                                              typography:
                                                  overrideTheme.typography,
                                              style: overrideTheme.style,
                                            ).call,
                                        label: Text(
                                          'Search extensions ',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        suffixBuilder: (
                                          context,
                                          style,
                                          states,
                                        ) {
                                          return Padding(
                                            padding: EdgeInsets.only(right: 2),
                                            child: FButton.icon(
                                              style: FButtonStyle.ghost(),
                                              onPress: () {},
                                              child: Icon(FIcons.x),
                                            ),
                                          );
                                        },
                                        prefixBuilder: (
                                          context,
                                          style,
                                          states,
                                        ) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              left: 10,
                                              right: 5,
                                            ),
                                            child: Icon(
                                              FIcons.search,
                                              size: 16,
                                            ),
                                          );
                                        },
                                        hint: "Search by Name or Tags ...",
                                        controller: textController,
                                        onChange: (val) {
                                          extNotifier.filterByName(val);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            mobileWidget: EasyRefresh(
              scrollController: scrollController,
              onRefresh: () async {
                await extNotifier.reloadRepos();
              },
              child: MiruListView.builder(
                controller: scrollController,
                itemBuilder: (context, index) {
                  final pair = extensionsWithRepo[index];
                  final data = pair['ext'] as GithubExtension;
                  final repoUrl = pair['repoUrl'] as String;
                  return _ExtensionTile(data: data, repoUrl: repoUrl);
                },
                itemCount: extensionsWithRepo.length,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExtensionTile extends HookConsumerWidget {
  final GithubExtension data;
  final String repoUrl;
  const _ExtensionTile({required this.data, required this.repoUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(extensionPageControllerProvider);
    final notifier = ref.read(extensionPageControllerProvider.notifier);
    final isInstalled = state.installedPackages.contains(data.package);

    return PlatformWidget(
      // Mobile widget
      mobileWidget: MoonMenuItem(
        onTap: () {},
        trailing: Row(
          children: [
            if (isInstalled)
              MoonButton(
                onTap: () async {
                  await notifier.uninstallPackage(data.package);
                },
                leading: const Icon(MoonIcons.generic_delete_24_regular),
              )
            else
              MoonButton(
                onTap: () async {
                  await notifier.installPackage(data.package, repoUrl);
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
                        return const Icon(
                          MoonIcons.notifications_error_16_regular,
                        );
                      }
                      return null;
                    },
                  ),
        ),
        label: Text(data.name),
      ),
      desktopWidget: ExtensionGridTile(
        isNSFW: data.isNsfw,
        isInstalled: isInstalled,
        name: data.name,
        version: data.version,
        author: data.author,
        type: data.type,
        icon: data.icon,
        onInstall: () async {
          await notifier.installPackage(data.package, repoUrl);
        },
        onUninstall: () async {
          await notifier.uninstallPackage(data.package);
        },
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ExtendedImage.network(
                        data.icon!,
                        loadStateChanged: (ExtendedImageState state) {
                          if (state.extendedImageLoadState ==
                              LoadState.failed) {
                            return const Icon(
                              MoonIcons.notifications_error_16_regular,
                            ); // Fallback widget
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
