import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/widgets/core/miru_tabs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/pages/download/download_page.dart';
import 'package:miru_app_new/pages/favorite/favorite_page_layout.dart';
import 'package:miru_app_new/pages/history/history_page.dart';
import 'package:miru_app_new/pages/home/widget/continue_watch.dart';
import 'package:miru_app_new/pages/home/widget/download.dart';
import 'package:miru_app_new/pages/home/widget/favorite.dart';
import 'package:miru_app_new/provider/watch/main_provider.dart';
import 'package:miru_app_new/widgets/index.dart';

// shell scaffold for tab navigation in history / home / favorite / download
class MiruMobileShellScaffold extends HookWidget {
  const MiruMobileShellScaffold({super.key});
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
            0 => SnapSheetHeader(title: 'Library'),
            1 => SnapSheetHeader(title: 'History'),
            2 => SnapSheetHeader(title: 'Favorite'),
            3 => SnapSheetHeader(title: 'Download'),
            _ => const SizedBox.shrink(),
          };
        },
      ),
      body: TabBarView(
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
              child: MiruTabs(
                controller: tabController,
                onChanged: (value) {
                  tabController.animateTo(value);
                },
                children: [
                  FTabEntry(
                    label: Icon(FIcons.libraryBig),
                    child: const Placeholder(),
                  ),
                  FTabEntry(
                    label: Icon(FIcons.history),
                    child: const Placeholder(),
                  ),
                  FTabEntry(
                    label: Icon(FIcons.heart),
                    child: const Placeholder(),
                  ),
                  FTabEntry(
                    label: Icon(FIcons.download),
                    child: const Placeholder(),
                  ),
                ],
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
    final history = ref.watch(mainProvider).history;
    return CustomScrollView(
      key: const PageStorageKey('LibraryPageScrollMobile'),
      slivers: [
        // const _Header(padding: EdgeInsets.fromLTRB(16, 20, 16, 10)),
        SliverToBoxAdapter(
          child: ContinueWatchingSection(
            history: history,
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
    final history = ref.watch(mainProvider.select((e) => e.history));
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
            history: history,
            scrollController: scrollController,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
        // const DownloadsText(padding: EdgeInsets.symmetric(horizontal: 40)),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        // DownloadsList(padding: const EdgeInsets.symmetric(horizontal: 40)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
        // const FavoritesHeader(padding: EdgeInsets.symmetric(horizontal: 40)),
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
