import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/miru_core/network/network.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/log.dart';
import 'package:miru_app_new/utils/network/github_network.dart';
import 'package:miru_app_new/views/widgets/homepage/extension/clearable_select.dart';
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

// State model for the page (immutable)
class ExtensionPageState {
  final List<ExtensionRepo> fetchedRepo;
  final List<ExtensionRepo> extensionList;
  final List<String> installedPackages;

  const ExtensionPageState({required this.fetchedRepo, required this.extensionList, required this.installedPackages});

  ExtensionPageState copyWith({List<ExtensionRepo>? fetchedRepo, List<ExtensionRepo>? extensionList, List<String>? installedPackages}) {
    return ExtensionPageState(
      fetchedRepo: fetchedRepo ?? this.fetchedRepo,
      extensionList: extensionList ?? this.extensionList,
      installedPackages: installedPackages ?? this.installedPackages,
    );
  }
}

class ExtensionPageNotifier extends StateNotifier<ExtensionPageState> {
  ExtensionPageNotifier()
    : snappingController = SnappingSheetController(),
      super(ExtensionPageState(fetchedRepo: const [], extensionList: const [], installedPackages: const [])) {
    // initialize installedPackages from ExtensionUtils.runtimes
    state = state.copyWith(installedPackages: ExtensionUtils.runtimes.keys.toList());
  }

  final SnappingSheetController snappingController;

  void setFetchedRepo(List<ExtensionRepo> list) {
    state = state.copyWith(fetchedRepo: list, extensionList: List.from(list));
  }

  void filterByName(String query) {
    if (query.isEmpty) {
      state = state.copyWith(extensionList: List.from(state.fetchedRepo));
      return;
    }
    final filtered = state.fetchedRepo.where((element) => element.name.toLowerCase().contains(query.toLowerCase())).toList();
    state = state.copyWith(extensionList: filtered);
  }

  void filterByInstalledIndex(int val) {
    final filteredExtensions =
        state.fetchedRepo
            .expand((repo) => repo.extensions)
            .where(
              (ext) => (val == 0 && state.installedPackages.contains(ext.package)) || (val == 1 && !state.installedPackages.contains(ext.package)),
            )
            .toList();
    state = state.copyWith(extensionList: [ExtensionRepo(extensions: filteredExtensions, name: 'filtered', url: '')]);
  }

  bool isInstalled(String package) => state.installedPackages.contains(package);

  Future<void> installPackage(String package, String repourl) async {
    try {
      await CoreNetwork.requestFormData("/download/extension", {'repoUrl': repourl, 'package': package});
      logger.info('install package $package from $repourl');
    } catch (e) {
      logger.info(e.toString());
    }
    final newInstalled = List<String>.from(state.installedPackages)..add(package);
    state = state.copyWith(installedPackages: newInstalled);
  }

  Future<void> uninstallPackage(String package) async {
    try {
      // ExtensionUtils.uninstall(package);
    } catch (e) {
      debugPrint(e.toString());
    }
    final newInstalled = List<String>.from(state.installedPackages)..remove(package);
    state = state.copyWith(installedPackages: newInstalled);
  }
}

final extensionPageControllerProvider = StateNotifierProvider<ExtensionPageNotifier, ExtensionPageState>((ref) {
  return ExtensionPageNotifier();
});

const _categories = ['Status', 'Type', 'Repo', 'Language'];

class _ExtensionPageState extends ConsumerState<ExtensionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final extState = ref.watch(extensionPageControllerProvider);
    final extNotifier = ref.read(extensionPageControllerProvider.notifier);
    final metaDataNotifier = ref.read(metaDataNotifierProvider.notifier);
    final snapShot = ref.watch(fetchExtensionRepoProvider);
    final scrollController = useScrollController();
    final controller = useTabController(initialLength: _categories.length);

    useEffect(() {
      ref.listen<AsyncValue<List<ExtensionRepo>>>(fetchExtensionRepoProvider, (previous, next) {
        next.whenData((list) {
          ref.read(extensionPageControllerProvider.notifier).setFetchedRepo(list);
        });
      });
      return null;
    }, const []);

    void filterExtensionListWithName(String query) => extNotifier.filterByName(query);

    return MiruScaffold(
      scrollController: scrollController,
      snappingSheetController: extNotifier.snappingController,
      mobileHeader: const SideBarListTitle(title: 'Extension'),
      sidebar:
          DeviceUtil.isMobileLayout(context)
              ? <Widget>[
                SideBarSearchBar(onChanged: filterExtensionListWithName),
                const SizedBox(height: 10),
                Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (_) {
                    debugPrint(extNotifier.snappingController.currentPosition.toString());
                    if (extNotifier.snappingController.currentPosition < 200) {
                      extNotifier.snappingController.setSnappingSheetPosition(400);
                    }
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
                      CategoryGroup(items: const ['Installed', 'Not installed'], onpress: (val) => extNotifier.filterByInstalledIndex(val)),
                      CategoryGroup(items: const ['ALL', 'Video', 'Manga', 'Novel'], onpress: (val) {}),
                      CategoryGroup(items: const ['ALL'], onpress: (val) {}),
                      CategoryGroup(items: const ['ALL'], onpress: (val) {}),
                    ],
                  ),
                ),
              ]
              : <Widget>[],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final selectedInstall = useState('Yes');
          return snapShot.when(
            data: (fetchedValue) {
              logger.info(constraints.maxWidth);
              final extensions = extState.extensionList.isNotEmpty ? extState.extensionList[0].extensions : <GithubExtension>[];
              return PlatformWidget(
                desktopWidget: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: MiruGridView(
                              paddingHeightOffest: 60,
                              // Use MaxCrossAxisExtent + mainAxisExtent so each tile has a fixed pixel size
                              desktopGridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400, // tile max width in pixels
                                mainAxisExtent: 210, // fixed tile height in pixels
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              mobileGridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                mainAxisExtent: 150,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemBuilder: (context, index) {
                                final data = extensions[index];
                                return _ExtensionTile(data: data);
                              },
                              itemCount: extensions.length,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 110,
                        child: Blur(
                          child: FCard(
                            style:
                                FCardStyle.inherit(
                                  colors: context.theme.colors.copyWith(background: context.theme.colors.background.withAlpha(200)),
                                  typography: overrideTheme.typography,
                                  style: context.theme.style,
                                ).call,
                            child: Padding(
                              padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Row(
                                        children: [
                                          ClearableSelect(hintText: 'ALL', title: "Type", items: ['Video', 'Manga', 'Novel']),
                                          ClearableSelect(
                                            initialValue: 'Yes',
                                            hintText: 'ALL',
                                            title: "Installed",
                                            items: ['Yes', 'No'],
                                            onChange: (val) {},
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 10),
                                      Padding(
                                        padding: EdgeInsetsGeometry.only(top: 18),
                                        child: FButton.icon(onPress: () {}, child: Icon(FIcons.search)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      final data = extensions[index];
                      return _ExtensionTile(data: data);
                    },
                    itemCount: extensions.length,
                  ),
                ),
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

class _ExtensionTile extends HookConsumerWidget {
  final GithubExtension data;
  const _ExtensionTile({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(extensionPageControllerProvider);
    final notifier = ref.read(extensionPageControllerProvider.notifier);
    final isInstalled = state.installedPackages.contains(data.package);

    return PlatformWidget(
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
                  await notifier.installPackage(data.package, "");
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
                        return const Icon(MoonIcons.notifications_error_16_regular);
                      }
                      return null;
                    },
                  ),
        ),
        label: Text(data.name),
      ),
      desktopWidget: ExtensionGridTile(
        isInstalled: isInstalled,
        name: data.name,
        version: data.version,
        author: data.author,
        type: data.type,
        icon: data.icon,
        onInstall: () async {
          await notifier.installPackage(data.package, '');
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
