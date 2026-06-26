import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/pages/home/widget/mobile_add_favgroup_dialog.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/utils/hook/sheet_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/pages/download/download_page.dart';
import 'package:miru_alpha/pages/favorite/favorite_page_layout.dart';
import 'package:miru_alpha/pages/history/history_page.dart';
import 'package:miru_alpha/pages/home/widget/continue_watch.dart';
import 'package:miru_alpha/pages/home/widget/favorite.dart';
import 'package:miru_alpha/pages/home/widget/library_bento_cards.dart';
import 'package:miru_alpha/pages/home/widget/library_categories.dart';
import 'package:miru_alpha/pages/home/widget/library_quick_actions.dart';
import 'package:miru_alpha/pages/home/widget/library_search_bar.dart';
import 'package:miru_alpha/widgets/core/toast.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:miru_alpha/widgets/dialog/dialog.dart';

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
    final sheetController = useSheetController();
    final tabController = useTabController(
      initialLength: 4,
      vsync: useSingleTickerProvider(),
    );
    return MiruScaffold.mobile(
      sheetController: sheetController,
      // Empty snapSheet list triggers non-snapSheet mode in MiruScaffold
      snapSheet: const [],
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
              title: 'common.library'.i18n,
              suffix: [
                FButton.icon(
                  variant: .ghost,
                  onPress: () {
                    iconsMessageToast(
                      title: 'common.web_dav_sync_wip'.i18n,
                      icon: FLucideIcons.construction,
                    );
                  },
                  child: Icon(FLucideIcons.cloudSync),
                ),
              ],
            ),
            1 => SnapSheetHeader(title: 'common.history'.i18n),
            2 => SnapSheetHeader(
              title: 'common.favorite.name'.i18n,
              suffix: [
                FTappable(
                  onPress: () {
                    showMiruDialog(
                      context: context,
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
                        return FBadge(child: Text('common.all'.i18n));
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
            3 => SnapSheetHeader(
              title: 'download.name'.i18n,
              suffix: [
                FButton.icon(
                  variant: .ghost,
                  onPress: () {
                    context.push('/home/download/history');
                  },
                  child: Icon(FLucideIcons.folderClock),
                ),
              ],
            ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
      body: IndexedStack(
        index: tabController.index,
        children: [
          MobileLibraryPage(),
          HistoryPage(),
          FavoritePage(),
          DownloadPage(),
        ],
      ),
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
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Search bar
        SliverToBoxAdapter(child: LibrarySearchBar()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        // Continue Watching
        SliverToBoxAdapter(
          child: ContinueWatchingSection(
            scrollController: scrollController,
            horizontalTitlePadding: 16,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        // Bento cards (Favorites + Downloads)
        const SliverToBoxAdapter(child: LibraryBentoCards()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        // Categories
        const SliverToBoxAdapter(child: LibraryCategoryList()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        // Quick Actions
        const SliverToBoxAdapter(child: LibraryQuickActions()),
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
            title: 'common.your_library'.i18n,
            description: 'common.library_description'.i18n,
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
