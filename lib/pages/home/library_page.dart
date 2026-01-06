import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/pages/download_page.dart';
import 'package:miru_app_new/pages/favorite/favorite_page_desktop_layout.dart';
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
    final controller = useTabController(initialLength: 4);
    final tabcontoller = useFTabController(length: 4);
    final index = useState(0);
    return MiruScaffold(
      mobileHeader: switch (index.value) {
        0 => SnapSheetHeader(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
          title: 'Your Library',
          description: 'Pick up where you left off or manage your downloads.',
        ),
        1 => SnapSheetHeader(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
          title: 'History',
        ),
        2 => SnapSheetHeader(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
          title: 'Favorite',
        ),
        3 => SnapSheetHeader(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
          title: 'Download',
        ),
        _ => const SizedBox.shrink(),
      },
      body: TabBarView(
        controller: controller,
        children: [
          MobileLibraryPage(),
          HistoryPage(),
          FavoritePage(),
          DownloadPage(),
        ],
      ),
      snapSheet: [
        FTabs(
          control: .managed(
            controller: tabcontoller,
            onChange: (value) {
              controller.animateTo(value);
              index.value = value;
            },
          ),
          children: [
            FTabEntry(label: Icon(FIcons.libraryBig), child: Placeholder()),
            FTabEntry(label: Icon(FIcons.history), child: Placeholder()),
            FTabEntry(label: Icon(FIcons.heart), child: Placeholder()),
            FTabEntry(label: Icon(FIcons.download), child: Placeholder()),
          ],
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
