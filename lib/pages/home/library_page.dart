import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/home/widget/mobile_add_favgroup_dialog.dart';
import 'package:miru_app_new/provider/favorite_page_provider.dart';
import 'package:miru_app_new/provider/history_page_provider.dart';
import 'package:miru_app_new/widgets/core/miru_tabs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/pages/download/download_page.dart';
import 'package:miru_app_new/pages/favorite/favorite_page_layout.dart';
import 'package:miru_app_new/pages/history/history_page.dart';
import 'package:miru_app_new/pages/home/widget/continue_watch.dart';
import 'package:miru_app_new/pages/home/widget/download.dart';
import 'package:miru_app_new/pages/home/widget/favorite.dart';
import 'package:miru_app_new/widgets/core/toast.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'dart:ui';

// shell scaffold for tab navigation in history / home / favorite / download
class MiruMobileShellScaffold extends StatefulHookWidget {
  const MiruMobileShellScaffold({super.key});

  @override
  State<MiruMobileShellScaffold> createState() =>
      _MiruMobileShellScaffoldState();
}

class _MiruMobileShellScaffoldState extends State<MiruMobileShellScaffold>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 4);
    return MiruScaffold(
      mobileHeader: HookBuilder(
        builder: (context) {
          final index = useState(tabController.index);
          useEffect(() {
            tabController.addListener(() {
              if (tabController.indexIsChanging) {
                index.value = tabController.index;
              }
            });
            return null;
          }, []);
          return switch (index.value) {
            0 => SnapSheetHeader(
              title: 'Library',
              suffix: [
                FButton.icon(
                  variant: .ghost,
                  onPress: () {
                    iconsMessageToast(
                      title: 'Web Dav sync (WIP)',
                      icon: FIcons.construction,
                    );
                  },
                  child: Icon(FIcons.cloudSync),
                ),
              ],
            ),
            1 => SnapSheetHeader(title: 'History'),
            2 => SnapSheetHeader(
              title: 'Favorite',
              suffix: [
                FTappable(
                  onPress: () {
                    showFDialog(
                      context: context,
                      routeStyle: .delta(
                        barrierFilter: () =>
                            (animation) => ImageFilter.compose(
                              outer: ImageFilter.blur(
                                sigmaX: animation * 5,
                                sigmaY: animation * 5,
                              ),
                              inner: ColorFilter.mode(
                                context.theme.colors.barrier,
                                .srcOver,
                              ),
                            ),
                      ),
                      builder: (context, style, animation) {
                        return MobileAddFAVDialog(
                          animation: animation,
                          context: context,
                          style: style,
                        );
                      },
                    );
                  },
                  child: Consumer(
                    builder: (context, ref, child) {
                      final favGrp = ref.watch(
                        favoritePageProvider.select(
                          (e) => e.selectedFavoriteGroups,
                        ),
                      );
                      if (favGrp.isEmpty) {
                        return FBadge(child: Text('All'));
                      }
                      return Wrap(
                        spacing: 3,
                        runSpacing: 2,
                        children: favGrp
                            .map((e) => FBadge(child: Text(e.name)))
                            .toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
            3 => SnapSheetHeader(title: 'Download'),
            _ => const SizedBox.shrink(),
          };
        },
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          MobileLibraryPage(),
          HistoryPage(),
          FavoritePage(),
          DownloadPage(),
        ],
      ),
      snapSheet: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Padding(
                padding: .symmetric(horizontal: 5),
                child: MiruTabs(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: tabController,
                  onChanged: (value) {
                    tabController.animateTo(value);
                  },
                  children: [
                    FTabEntry(
                      label: Icon(FIcons.libraryBig),
                      child: Padding(
                        padding: .symmetric(horizontal: 10),
                        child: FTileGroup(
                          label: Text('Tracking'),
                          children: [
                            FTile(
                              prefix: SvgPicture.string(
                                '<svg fill="#000000" viewBox="0 0 24 24" role="img" xmlns="http://www.w3.org/2000/svg"><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g><g id="SVGRepo_iconCarrier"><path d="M6.361 2.943 0 21.056h4.942l1.077-3.133H11.4l1.052 3.133H22.9c.71 0 1.1-.392 1.1-1.101V17.53c0-.71-.39-1.101-1.1-1.101h-6.483V4.045c0-.71-.392-1.102-1.101-1.102h-2.422c-.71 0-1.101.392-1.101 1.102v1.064l-.758-2.166zm2.324 5.948 1.688 5.018H7.144z"></path></g></svg>',
                                colorFilter: .mode(
                                  context.theme.colors.foreground,
                                  .srcIn,
                                ),
                              ),
                              title: Text('Anilist'),
                              suffix: Icon(FIcons.chevronRight),
                              onPress: () {
                                iconsMessageToast(
                                  title: 'WIP',
                                  icon: FIcons.construction,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    FTabEntry(
                      label: Icon(FIcons.history),
                      child: ListView(
                        padding: .all(0),
                        children: [
                          Padding(
                            padding: .symmetric(horizontal: 10),
                            child: HookConsumer(
                              builder: (context, ref, child) {
                                final input = useState('');
                                return FTextField(
                                  control: .managed(
                                    onChange: (value) {
                                      input.value = value.text;
                                      ref
                                          .read(historyPageProvider.notifier)
                                          .filterWithKeyword(input.value);
                                    },
                                  ),
                                  suffixBuilder: (context, style, variants) {
                                    return FButton.icon(
                                      variant: .ghost,
                                      onPress: () {},
                                      child: Icon(FIcons.boxes),
                                    );
                                  },
                                  prefixBuilder: (context, style, states) =>
                                      Padding(
                                        padding: EdgeInsetsGeometry.only(
                                          left: 12,
                                          right: 10,
                                        ),
                                        child: Icon(FIcons.history),
                                      ),
                                  hint: 'Search for Histories...',
                                );
                              },
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              return Padding(
                                padding: .symmetric(horizontal: 10),
                                child: CategoryMultiGroup(
                                  title: 'Type',
                                  initialValue: {'Video', 'Manga', 'Novel'},
                                  items: ['Video', 'Manga', 'Novel'],
                                  onpress: (val) {
                                    final Set<ExtensionType> type = {};
                                    for (var element in val) {
                                      final e = stringToExtensionType(element);
                                      if (e != null) {
                                        type.add(e);
                                      }
                                    }
                                    ref
                                        .read(historyPageProvider.notifier)
                                        .filterWithType(type);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    FTabEntry(
                      label: Icon(FIcons.heart),
                      child: ListView(
                        padding: .all(0),
                        children: [
                          Padding(
                            padding: .symmetric(horizontal: 10),
                            child: HookConsumer(
                              builder: (context, ref, child) {
                                final input = useState('');
                                return FTextField(
                                  control: .managed(
                                    onChange: (value) {
                                      input.value = value.text;
                                      ref
                                          .read(favoritePageProvider.notifier)
                                          .filterWithKeyword(input.value);
                                    },
                                  ),
                                  suffixBuilder: (context, style, variants) {
                                    return FButton.icon(
                                      variant: .ghost,
                                      onPress: () {},
                                      child: Icon(FIcons.boxes),
                                    );
                                  },
                                  prefixBuilder: (context, style, states) =>
                                      Padding(
                                        padding: EdgeInsetsGeometry.only(
                                          left: 12,
                                          right: 10,
                                        ),
                                        child: Icon(FIcons.heart),
                                      ),
                                  hint: 'Search for Favorites...',
                                  // onTapOutside: (event) {
                                  //   FocusScope.of(context).unfocus();
                                  // },
                                );
                              },
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              return Padding(
                                padding: .symmetric(horizontal: 10),
                                child: CategoryMultiGroup(
                                  title: 'Type',
                                  initialValue: {'Video', 'Manga', 'Novel'},
                                  items: ['Video', 'Manga', 'Novel'],
                                  onpress: (val) {
                                    final Set<ExtensionType> type = {};
                                    for (var element in val) {
                                      final e = stringToExtensionType(element);
                                      if (e != null) {
                                        type.add(e);
                                      }
                                    }
                                    ref
                                        .read(favoritePageProvider.notifier)
                                        .filterWithType(type);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    FTabEntry(
                      label: Icon(FIcons.download),
                      child: const Placeholder(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class MobileLibraryPage extends HookConsumerWidget {
  const MobileLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    return CustomScrollView(
      key: const PageStorageKey('LibraryPageScrollMobile'),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
        SliverToBoxAdapter(
          child: ContinueWatchingSection(
            scrollController: scrollController,
            horizontalTitlePadding: 16,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        const DownloadsText(padding: EdgeInsets.symmetric(horizontal: 16)),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        DownloadsList(padding: const EdgeInsets.symmetric(horizontal: 16)),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        const FavoritesHeader(padding: EdgeInsets.symmetric(horizontal: 16)),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        FavoritesGrid(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          crossAxisCount: (MediaQuery.of(context).size.width ~/ 160).clamp(
            2,
            6,
          ),
          childAspectRatio: 0.65,
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 200),
        ), // Bottom padding for mobile
      ],
    );
  }
}

class DesktopLibraryPage extends HookConsumerWidget {
  const DesktopLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    return CustomScrollView(
      key: const PageStorageKey('LibraryPageScrollDesktop'),
      slivers: [
        SliverToBoxAdapter(
          child: SnapSheetHeader(
            padding: EdgeInsets.fromLTRB(40, 40, 40, 20),
            title: 'Your Library',
            description: 'Pick up where you left off or manage your downloads.',
          ),
        ),
        SliverToBoxAdapter(
          child: ContinueWatchingSection(
            horizontalTitlePadding: 40,
            scrollController: scrollController,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        FavoritesGrid(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          crossAxisCount: (MediaQuery.of(context).size.width ~/ 250).clamp(
            2,
            10,
          ),
          childAspectRatio: 0.65,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}
