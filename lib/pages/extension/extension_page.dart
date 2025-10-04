import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:miru_app_new/widgets/core/search_filter_card.dart';
import 'package:miru_app_new/widgets/core/toast.dart';
import 'package:miru_app_new/widgets/gridView/index.dart';
import 'package:miru_app_new/widgets/extension/clearable_select.dart';
import 'package:miru_app_new/widgets/index.dart';

import 'package:moon_design/moon_design.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';
import '../../model/index.dart';

final SnappingSheetController _snappingController = SnappingSheetController();

class ExtensionPage extends StatefulHookConsumerWidget {
  const ExtensionPage({super.key});
  @override
  createState() => _ExtensionPageState();
}

class CatEntry {
  final String title;
  final List<String> items;
  final void Function(String) onpress;
  const CatEntry({
    required this.title,
    required this.items,
    required this.onpress,
  });
}

class _MobileExtensionModal extends ConsumerWidget {
  const _MobileExtensionModal();
  static const categories = ['Status', 'Type', 'Repo'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extNotifier = ref.read(extensionPageProvider.notifier);
    final catentry = <String, CatEntry>{
      'Status': CatEntry(
        title: 'Status',
        items: ['ALL', 'Installed', 'Not installed'],
        onpress: (val) {
          logger.info(val);
          extNotifier.filterByInstalled(val);
        },
      ),
      'Type': CatEntry(
        title: 'Type',
        items: ['ALL', 'Video', 'Manga', 'Novel'],
        onpress: (val) {
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
      'Repo': CatEntry(title: 'Repository', items: ['WIP'], onpress: (val) {}),
    };
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        logger.info(_snappingController.currentPosition.toString());
        if (_snappingController.currentPosition < 200) {
          _snappingController.setSnappingSheetPosition(400);
        }
      },
      child: FTabs(
        children: List.generate(categories.length, (index) {
          final entry = categories[index];
          return FTabEntry(
            label: Text(entry),
            child: CategoryGroup(
              items: catentry[entry]?.items ?? [],
              onpress: catentry[entry]?.onpress ?? (String val) {},
            ),
          );
        }),
      ),
    );
  }
}

class _ExtensionPageState extends ConsumerState<ExtensionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedInstall = useState('Yes');
    final extState = ref.watch(extensionPageProvider.select((r) => r.loading));
    final extNotifier = ref.read(extensionPageProvider.notifier);

    final scrollController = useScrollController();
    final textController = useTextEditingController();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        extNotifier.loadRepos();
      });
      return null;
    }, const []);

    return MiruScaffold(
      scrollController: scrollController,
      snappingSheetController: _snappingController,
      mobileHeader: SnapSheetHeader(
        title: 'Extension',
        trailings: [
          FButton.icon(
            style: FButtonStyle.ghost(),
            onPress: () {},
            child: Icon(FIcons.earth),
          ),
        ],
      ),
      snapSheet: DeviceUtil.isMobileLayout(context)
          ? <Widget>[
              FTextField(
                onChange: (value) {
                  extNotifier.filterByName(value);
                },
                hint: "Search by Name or Tags ...",
                prefixBuilder: (context, style, states) => Padding(
                  padding: EdgeInsetsGeometry.only(left: 12, right: 10),
                  child: Icon(FIcons.search),
                ),
              ),
              SizedBox(height: 10),
              _MobileExtensionModal(),
            ]
          : <Widget>[],
      body: Consumer(
        builder: (context, ref, child) {
          final extensionList = ref.watch(
            extensionPageProvider.select((s) => s.extensionList),
          );
          return LayoutBuilder(
            builder: (context, constraints) {
              if (extState) {
                return const Center(child: FProgress.circularIcon());
              }

              // Build flat list preserving repo url and name for each extension
              final extensionsWithRepo = <Map<String, dynamic>>[];
              for (final repoItem in extensionList) {
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
                                return _ExtensionTile(
                                  data: data,
                                  repoUrl: repoUrl,
                                );
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
                                                tipBuilder:
                                                    (context, controller) {
                                                      return const Text(
                                                        'Reload Repositories',
                                                      );
                                                    },
                                                child: FButton.icon(
                                                  onPress: () async {
                                                    await extNotifier
                                                        .reloadRepos();
                                                  },
                                                  child: const Icon(
                                                    Icons.refresh,
                                                  ),
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
                                            style: FTextFieldStyle.inherit(
                                              colors: context.theme.colors,
                                              typography:
                                                  overrideTheme.typography,
                                              style: overrideTheme.style,
                                            ).call,
                                            label: Text(
                                              'Search extensions ',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            suffixBuilder:
                                                (context, style, states) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                      right: 2,
                                                    ),
                                                    child: FButton.icon(
                                                      style:
                                                          FButtonStyle.ghost(),
                                                      onPress: () {},
                                                      child: Icon(FIcons.x),
                                                    ),
                                                  );
                                                },
                                            prefixBuilder:
                                                (context, style, states) {
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
                  // MiruListView.builder(
                  //   controller: scrollController,
                  //   itemBuilder: (context, index) {
                  //     final pair = extensionsWithRepo[index];
                  //     final data = pair['ext'] as GithubExtension;
                  //     final repoUrl = pair['repoUrl'] as String;
                  //     return _ExtensionTile(data: data, repoUrl: repoUrl);
                  //   },
                  //   itemCount: extensionsWithRepo.length,
                  // ),
                ),
              );
            },
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
    final state = ref.watch(extensionPageProvider);
    final notifier = ref.read(extensionPageProvider.notifier);
    final isInstalled = state.installedPackages.contains(data.package);

    return DeviceUtil.deviceWidget(
      // Mobile widget
      context: context,
      mobile: ExtensionListTile(
        isNSFW: data.isNsfw,
        isInstalled: isInstalled,
        name: data.name,
        version: data.version,
        author: data.author,
        type: data.type,
        icon: data.icon,
        onInstall: () async {
          await notifier.installPackage(data.package, repoUrl);
          iconsMessageToast("Installed ${data.name}", FIcons.blocks);
        },
        onUninstall: () async {
          await notifier.uninstallPackage(data.package);
          iconsMessageToast("Uninstalled ${data.name}", FIcons.blocks);
        },
      ),
      desktop: ExtensionGridTile(
        isNSFW: data.isNsfw,
        isInstalled: isInstalled,
        name: data.name,
        version: data.version,
        author: data.author,
        type: data.type,
        icon: data.icon,
        onInstall: () async {
          await notifier.installPackage(data.package, repoUrl);
          iconsMessageToast("Installed ${data.name}", FIcons.blocks);
        },
        onUninstall: () async {
          await notifier.uninstallPackage(data.package);
          iconsMessageToast("Uninstalled ${data.name}", FIcons.blocks);
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
