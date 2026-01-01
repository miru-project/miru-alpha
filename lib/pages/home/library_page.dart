import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/pages/home/widget/continue_watch.dart';
import 'package:miru_app_new/pages/home/widget/download.dart';
import 'package:miru_app_new/pages/home/widget/favorite.dart';
import 'package:miru_app_new/provider/watch/main_provider.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:miru_app_new/model/index.dart';

class LibraryPage extends HookConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(mainProvider).history;
    final scrollController = useScrollController();

    return MiruScaffold(
      mobileHeader: SnapSheetHeader(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
        title: 'Your Library',
        description: 'Pick up where you left off or manage your downloads.',
      ),
      mobileBody: _MobileLibraryPage(
        history: history,
        scrollController: scrollController,
      ),
      desktopBody: _DesktopLibraryPage(
        history: history,
        scrollController: scrollController,
      ),
      snapSheet: [
        FTabs(
          children: [
            FTabEntry(label: Text('Library'), child: Placeholder()),
            FTabEntry(label: Text('History'), child: Placeholder()),
            FTabEntry(label: Text('Favorite'), child: Placeholder()),
          ],
        ),
      ],
    );
  }
}

class _MobileLibraryPage extends HookWidget {
  const _MobileLibraryPage({
    required this.history,
    required this.scrollController,
  });

  final List<History> history;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
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
          history: history,
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

class _DesktopLibraryPage extends StatelessWidget {
  const _DesktopLibraryPage({
    required this.history,
    required this.scrollController,
  });

  final List<History> history;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
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
        const DownloadsText(padding: EdgeInsets.symmetric(horizontal: 40)),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        DownloadsList(padding: const EdgeInsets.symmetric(horizontal: 40)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
        const FavoritesHeader(padding: EdgeInsets.symmetric(horizontal: 40)),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        FavoritesGrid(
          history: history,
          padding: const EdgeInsets.symmetric(horizontal: 40),
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
