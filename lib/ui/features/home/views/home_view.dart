import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/home/home_view_model.dart';
import 'package:miru_alpha/ui/core/scaffold/miru_scaffold.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/ui/features/home/widget/continue_watch.dart';
import 'package:miru_alpha/ui/features/home/widget/favorite.dart';
import 'package:miru_alpha/ui/features/home/widget/library_bento_cards.dart';
import 'package:miru_alpha/ui/features/home/widget/library_categories.dart';
import 'package:miru_alpha/ui/features/home/widget/library_quick_actions.dart';
import 'package:miru_alpha/ui/features/home/widget/library_search_bar.dart';
import 'package:miru_alpha/ui/features/download/download.dart';
import 'package:miru_alpha/ui/features/favorite/favorite.dart';
import 'package:miru_alpha/ui/features/history/history.dart';
import 'package:miru_alpha/ui/core/scaffold/custom_silver_header.dart';
import 'package:miru_alpha/ui/core/scaffold/snapsheet_header.dart';
import 'package:miru_alpha/utils/hook/sheet_controller.dart';
import 'package:window_manager/window_manager.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key, this.navigationShell});

  final StatefulNavigationShell? navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DeviceUtil.deviceWidget(
      mobile: HomeViewMobile(navigationShell: navigationShell),
      desktop: const HomeViewDesktop(),
      context: context,
    );
  }
}

// Mobile implementation with tabbed shell
class HomeViewMobile extends HookConsumerWidget {
  const HomeViewMobile({super.key, this.navigationShell});

  final StatefulNavigationShell? navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheetController = useSheetController();
    final tabController = useTabController(
      initialLength: 4,
      vsync: useSingleTickerProvider(),
    );
    final selectedTab = ref.watch(selectedHomeTabProvider);

    useEffect(() {
      tabController.addListener(() {
        if (tabController.indexIsChanging) {
          ref
              .read(selectedHomeTabProvider.notifier)
              .setIndex(tabController.index);
        }
      });
      return null;
    }, [tabController]);

    return MiruScaffold.mobile(
      sheetController: sheetController,
      snapSheet: const [],
      sliverHeaders: [
        StaticSliverHeaderDelegate(
          maxExtent: 120,
          child: HookBuilder(
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SnapSheetHeader(
                    title: 'common.library'.i18n,
                    suffix: [
                      FButton.icon(
                        variant: FButtonVariant.ghost,
                        onPress: () {
                          iconsMessageToast(
                            title: 'common.web_dav_sync_wip'.i18n,
                            icon: FLucideIcons.construction,
                          );
                        },
                        child: const Icon(FLucideIcons.cloudSync),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LibrarySearchBar(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
      body: IndexedStack(
        index: selectedTab,
        children: const [
          MobileLibraryPage(),
          HistoryView(),
          FavoriteView(),
          DownloadView(),
        ],
      ),
    );
  }
}

// Desktop implementation - sidebar is provided by MainPage wrapper
class HomeViewDesktop extends ConsumerWidget {
  const HomeViewDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(
      applicationControllerProvider.select((s) => s.themeData),
    );

    return FTheme(
      data: themeData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DragWindows(),
          const FDivider(
            style: FDividerStyleDelta.delta(
              padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
            ),
          ),
          Expanded(child: DesktopLibraryPage()),
        ],
      ),
    );
  }
}

class DragWindows extends StatelessWidget {
  const DragWindows({super.key});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const BreadCrumb(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200, maxHeight: 35),
            child: const WindowCaption(
              brightness: Brightness.dark,
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

class BreadCrumb extends HookWidget {
  const BreadCrumb({super.key});

  @override
  Widget build(BuildContext context) {
    final routeInfoProvider = GoRouter.of(context).routeInformationProvider;
    useListenable(routeInfoProvider);

    final currentLocation =
        GoRouter.of(context).routerDelegate.state.fullPath ??
        GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

    final segments = currentLocation
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();

    return FBreadcrumb(
      children: [
        for (final seg in segments)
          FBreadcrumbItem(
            onPress: () {
              if (seg == segments.last) return;
              if (!GoRouter.of(context).canPop()) return;
              if (seg == 'search' && segments.last == 'detail') {
                GoRouter.of(context).pop();
                GoRouter.of(context).pop();
                return;
              }
              if ((seg == 'single' && segments.last == 'detail') ||
                  (seg == 'search' && segments.last == 'single')) {
                GoRouter.of(context).pop();
                return;
              }
            },
            child: Text(seg.i18n),
          ),
      ],
    );
  }
}

// Mobile library page (reused from legacy)
class MobileLibraryPage extends HookConsumerWidget {
  const MobileLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    return CustomScrollView(
      key: const PageStorageKey('LibraryPageScrollMobile'),
      slivers: [
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

// Desktop library page (reused from legacy)
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
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 20),
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
