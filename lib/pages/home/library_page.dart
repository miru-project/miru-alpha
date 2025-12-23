import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/pages/home/home_page.dart';
import 'package:miru_app_new/pages/home/widget/continue_watch.dart';
import 'package:miru_app_new/pages/home/widget/download_item.dart';
import 'package:miru_app_new/pages/home/widget/favorite_card.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:miru_app_new/model/index.dart';

class LibraryPage extends HookConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(mainPageProvider).history;
    final scrollController = useScrollController();

    return MiruScaffold(
      mobileHeader: const _Header(padding: EdgeInsets.fromLTRB(16, 0, 16, 0)),
      mobileBody: _MobileLibraryPage(
        history: history,
        scrollController: scrollController,
      ),
      desktopBody: _DesktopLibraryPage(
        history: history,
        scrollController: scrollController,
      ),
    );
  }
}

class _MobileLibraryPage extends StatelessWidget {
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
        const _DownloadsSection(padding: EdgeInsets.symmetric(horizontal: 16)),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        _DownloadsList(
          history: history,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        const _FavoritesHeader(padding: EdgeInsets.symmetric(horizontal: 16)),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        _FavoritesGrid(
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
        const _DownloadsSection(padding: EdgeInsets.symmetric(horizontal: 40)),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        _DownloadsList(
          history: history,
          padding: const EdgeInsets.symmetric(horizontal: 40),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
        const _FavoritesHeader(padding: EdgeInsets.symmetric(horizontal: 40)),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        _FavoritesGrid(
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

class _Header extends StatelessWidget {
  const _Header({required this.padding});
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SnapSheetHeader(
      padding: padding,
      title: 'Your Library',
      description: 'Pick up where you left off or manage your downloads.',
    );
  }
}

class _DownloadsSection extends StatelessWidget {
  const _DownloadsSection({required this.padding});
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Downloads',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Text(
                  '5.2 GB Free',
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
                const SizedBox(width: 8),
                Icon(FIcons.download, color: Colors.grey[400], size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadsList extends StatelessWidget {
  const _DownloadsList({required this.history, required this.padding});
  final List<History> history;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= history.length) return null;
          final item = history[index];
          return DownloadItem(
            key: ValueKey(item.url),
            item: item,
            index: index,
          );
        }, childCount: history.length > 4 ? 4 : history.length),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader({required this.padding});
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Favorites',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            FButton(
              onPress: () {},
              style: FButtonStyle.outline(),
              child: const Text('View All'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesGrid extends StatelessWidget {
  const _FavoritesGrid({
    required this.history,
    required this.padding,
    required this.crossAxisCount,
    required this.childAspectRatio,
  });

  final List<History> history;
  final EdgeInsetsGeometry padding;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= history.length) return null;
          final item = history[index];
          return FavoriteCard(
            key: ValueKey(item.url),
            item: item,
            aspectRatio: childAspectRatio,
          );
        }, childCount: history.length > 4 ? 4 : history.length),
      ),
    );
  }
}
