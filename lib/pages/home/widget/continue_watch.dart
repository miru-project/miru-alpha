import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/model.dart';
import 'package:miru_app_new/model/user_data.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/provider/history_page_provider.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/widgets/amination/animated_box.dart';

class ContinueWatchingSection extends HookConsumerWidget {
  const ContinueWatchingSection({
    required this.scrollController,
    required this.horizontalTitlePadding,
    super.key,
  });
  final ScrollController scrollController;
  final double horizontalTitlePadding;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canScrollLeft = useState(false);
    final canScrollRight = useState(false);
    final isMobile = DeviceUtil.isMobileLayout(context);
    final history = ref.watch(
      historyPageProvider.select((e) => e.filteredHistory),
    );
    void updateScrollButtons() {
      canScrollLeft.value = scrollController.offset > 0;
      canScrollRight.value =
          scrollController.offset < scrollController.position.maxScrollExtent;
    }

    if (!isMobile) {
      useEffect(() {
        scrollController.addListener(updateScrollButtons);
        return () => scrollController.removeListener(updateScrollButtons);
      }, [scrollController]);
    }

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
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalTitlePadding,
                    ),
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
                          itemCount: history.length > 10 ? 10 : history.length,
                          itemBuilder: (context, index) {
                            final item = history[index];
                            return Padding(
                              padding: index == 0
                                  ? const EdgeInsets.only(left: 16)
                                  : EdgeInsetsGeometry.zero,
                              child: MouseRegion(
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
                                variant: .outline,
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
                                variant: .outline,
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

  // Check the detail saved in db has the same information as the history
  // If not, return (-1, -1)

  (int, int) checkEpisode(
    Detail detail,
    String historyUrl,
    int historyEpId,
    int historyGroupId,
  ) {
    final urlFromDetail =
        detail.episodes?[historyGroupId].urls[historyEpId].url;
    if (urlFromDetail == null) {
      return (-1, -1);
    }
    if (urlFromDetail == historyUrl) {
      return (historyEpId, historyGroupId);
    }
    for (int i = 0; i < detail.episodes!.length; i++) {
      for (int j = 0; j < detail.episodes![i].urls.length; j++) {
        if (detail.episodes![i].urls[j].url == historyUrl) {
          return (j, i);
        }
      }
    }
    return (-1, -1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate progress (mock data - replace with actual progress)
    final progress = (item.progress / item.totalProgress).clamp(0.0, 1.0);

    return AnimatedBox(
      onTap: () async {
        final meta = ref.read(extensionPageProvider).metaData;
        final extMeta = meta.where((e) => e.packageName == item.package).first;
        final detail = await fetchDetailFromDb(item.package, item.detailUrl);
        if (detail == null || !context.mounted) {
          return;
        }
        final (epId, groupId) = checkEpisode(
          detail,
          item.url,
          item.episodeId,
          item.episodeGroupId,
        );
        if (epId == -1 || groupId == -1) {
          return;
        }

        context.push<WatchParams>(
          "/watch",
          extra: WatchParams(
            savePath: null,
            name: item.title,
            detailImageUrl: item.cover ?? '',
            selectedEpisodeIndex: epId,
            selectedGroupIndex: groupId,
            epGroup: detail.episodes,
            detailUrl: item.detailUrl,
            url: item.url,
            meta: extMeta,
            type: extMeta.type,
          ),
        );
      },
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
                          child: const Icon(FIcons.cloudAlert),
                        );
                      }
                      return null;
                    },
                  ),
                ),
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
