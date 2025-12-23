import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/home/home_page.dart';
import 'package:miru_app_new/widgets/amination/animated_box.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';
import 'package:miru_app_new/widgets/index.dart';

class LibraryPage extends HookConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(mainPageProvider).history;
    final scrollController = useScrollController();
    final gridCrossAxisCount = (MediaQuery.of(context).size.width ~/ 250);
    final aspectRatio = 0.65;
    return MiruScaffold(
      body: CustomScrollView(
        key: const PageStorageKey('LibraryPageScroll'),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 40, 40, 20),
              child: FLabel(
                axis: Axis.vertical,
                description: Text(
                  'Pick up where you left off or manage your downloads.',
                ),
                child: const Text(
                  'Your Library',
                  style: TextStyle(fontWeight: .bold, fontSize: 30),
                ),
              ),
            ),
          ),

          // Continue Watching Section
          SliverToBoxAdapter(
            child: _ContinueWatchingSection(
              history: history,
              scrollController: scrollController,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          // Downloads Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
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
                      Icon(
                        Icons.cloud_download,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Downloads List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index >= history.length) return null;
                final item = history[index];
                return _DownloadItem(
                  key: ValueKey(item.url),
                  item: item,
                  index: index,
                );
              }, childCount: history.length > 4 ? 4 : history.length),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          // Your Favorites Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Favorites',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  FButton(
                    onPress: () {},
                    style: FButtonStyle.outline(),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Favorites Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCrossAxisCount,
                childAspectRatio: aspectRatio,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index >= history.length) return null;
                final item = history[index];

                // return Container(color: Colors.red);
                return _FavoriteCard(
                  key: ValueKey(item.url),
                  item: item,
                  aspectRatio: aspectRatio,
                );
              }, childCount: history.length > 4 ? 4 : history.length),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _ContinueWatchingSection extends HookConsumerWidget {
  const _ContinueWatchingSection({
    required this.history,
    required this.scrollController,
  });

  final List<History> history;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canScrollLeft = useState(false);
    final canScrollRight = useState(true);

    void updateScrollButtons() {
      canScrollLeft.value = scrollController.offset > 0;
      canScrollRight.value =
          scrollController.offset < scrollController.position.maxScrollExtent;
    }

    useEffect(() {
      scrollController.addListener(updateScrollButtons);
      return () => scrollController.removeListener(updateScrollButtons);
    }, [scrollController]);

    final ishover = useState(false);
    bool insideHover = false;
    bool outsideHover = false;
    return GestureDetector(
      onTapDown: (details) {
        if (!ishover.value) return;
        context.go('/home/history');
      },
      child: MouseRegion(
        onHover: (event) {
          outsideHover = true;
          ishover.value = !insideHover && outsideHover;
        },
        onExit: (event) {
          outsideHover = false;
          ishover.value = !insideHover && outsideHover;
        },
        child: ValueListenableBuilder(
          valueListenable: ishover,
          builder: (context, value, child) => Container(
            decoration: BoxDecoration(
              color: value ? context.theme.colors.muted : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Continue Watching',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 220,
                    child: Stack(
                      children: [
                        ListView.builder(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          itemCount: history.length > 10 ? 10 : history.length,
                          itemBuilder: (context, index) {
                            final item = history[index];
                            return MouseRegion(
                              onHover: (_) {
                                insideHover = true;
                                ishover.value = !insideHover && outsideHover;
                              },
                              onExit: (_) {
                                insideHover = false;
                                ishover.value = !insideHover && outsideHover;
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: _ContinueWatchingCard(
                                  key: ValueKey(item.url),
                                  item: item,
                                ),
                              ),
                            );
                          },
                        ),

                        // Left Arrow
                        if (canScrollLeft.value)
                          Positioned(
                            left: 8,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: FButton.icon(
                                onPress: () {
                                  scrollController.animateTo(
                                    scrollController.offset - 300,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                style: FButtonStyle.outline(),
                                child: const Icon(FIcons.chevronLeft),
                              ),
                            ),
                          ),

                        // Right Arrow
                        if (canScrollRight.value)
                          Positioned(
                            right: 8,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: FButton.icon(
                                onPress: () {
                                  scrollController.animateTo(
                                    scrollController.offset + 300,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                style: FButtonStyle.outline(),
                                child: const Icon(FIcons.chevronRight),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueWatchingCard extends ConsumerWidget {
  const _ContinueWatchingCard({super.key, required this.item});

  final History item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate progress (mock data - replace with actual progress)
    final progress = (item.progress / item.totalProgress).clamp(0.0, 1.0);

    return AnimatedBox(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        child: SizedBox(
          width: 320,
          height: 450,
          child: FCard.raw(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ExtendedImage.network(
                    item.cover ?? '',
                    borderRadius: BorderRadius.circular(10),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadStateChanged: (state) {
                      if (state.extendedImageLoadState == LoadState.failed) {
                        return Container(
                          height: 140,
                          color: Colors.grey[800],
                          child: const Icon(
                            FIcons.cloudAlert,
                            color: Colors.white,
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                // const SizedBox(height: 16),
                SizedBox(
                  height: 4,
                  child: FDeterminateProgress(value: progress),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: FLabel(
                    axis: .vertical,
                    description: Text(
                      item.episodeTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13),
                    ),
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteCard extends ConsumerWidget {
  const _FavoriteCard({
    super.key,
    required this.item,
    required this.aspectRatio,
  });

  final History item;
  final double aspectRatio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBox(
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .max,

        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FCard.raw(
                child: ImageWidget(
                  width: 210,
                  height: 280,
                  fit: BoxFit.cover,
                  imageUrl: item.cover ?? '',
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            item.episodeTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DownloadItem extends ConsumerWidget {
  const _DownloadItem({super.key, required this.item, required this.index});

  final History item;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock download progress
    final progress = index == 3 ? 0.6 : 1.0;
    final isDownloading = index == 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ExtendedImage.network(
                  item.cover ?? '',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  loadStateChanged: (state) {
                    if (state.extendedImageLoadState == LoadState.failed) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(1.2 + index * 0.3).toStringAsFixed(1)} GB • ${item.episodeTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    if (isDownloading) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: FDeterminateProgress(value: progress),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Action button
              FButton.icon(
                onPress: () {},
                style: FButtonStyle.outline(),
                child: Icon(
                  isDownloading ? Icons.pause : Icons.check,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
