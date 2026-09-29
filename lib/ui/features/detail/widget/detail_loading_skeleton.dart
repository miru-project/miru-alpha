import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/core/scroll_view/miru_list_view.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/http/request.dart';

import 'skeleton.dart';

/// Desktop skeleton content shown while detail data is loading.
/// Shows partial info (title/img/extension) from MiruCard (/search/single)
/// plus skeleton episodes, then refreshes to full value.
class DesktopDetailSkeletonContent extends StatelessWidget {
  const DesktopDetailSkeletonContent({
    super.key,
    required this.meta,
    required this.items,
    required this.index,
  });
  final ExtensionMeta meta;
  final List<ExtensionListItem>? items;
  final int index;

  String get _title {
    final it = items;
    if (it != null && index >= 0 && index < it.length) {
      return it[index].title.isNotEmpty ? it[index].title : meta.name;
    }
    return meta.name;
  }

  String get _coverUrl {
    final it = items;
    if (it != null && index >= 0 && index < it.length) {
      return it[index].cover;
    }
    return meta.icon ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth < 1100;
        return MiruListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      MiruCard(
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Partial info from MiruCard: cover image (if available)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _coverUrl.isNotEmpty
                                    ? Image.network(
                                        MiruRequest.proxyUrl(
                                          _coverUrl,
                                        ).toString(),
                                        width: 120,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, _, _) =>
                                            const DetailSkeleton(
                                              width: 120,
                                              height: 180,
                                            ),
                                      )
                                    : const DetailSkeleton(
                                        width: 120,
                                        height: 180,
                                      ),
                              ),
                              const SizedBox(width: 25),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title from MiruCard (/search/single)
                                    Text(
                                      _title,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    // Extension name
                                    Text(
                                      meta.name,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: context
                                            .theme
                                            .colors
                                            .mutedForeground,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Episode section skeleton — matches EpisodeList shape
                      MiruCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'media.episodes'.i18n,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Group selector skeleton
                                  Container(
                                    width: 180,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: context.theme.colors.muted,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Episode buttons skeleton (rounded, wrap)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (int i = 0; i < 6; i++)
                                    Container(
                                      width: 100,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: context.theme.colors.muted,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isTablet) ...[
                  const Spacer(),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        const DetailSkeleton(width: 200, height: 280),
                        const SizedBox(height: 30),
                        const DetailSkeleton(width: 200, height: 120),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }
}

/// Mobile skeleton page shown while detail data is loading.
/// Keeps mobile visible in loading state for validation, using partial info
/// (title/img/extension) from MiruCard in /search/single.
class MobileDetailSkeletonPage extends StatelessWidget {
  const MobileDetailSkeletonPage({
    super.key,
    required this.meta,
    required this.items,
    required this.index,
  });
  final ExtensionMeta meta;
  final List<ExtensionListItem>? items;
  final int index;

  String get _title {
    final it = items;
    if (it != null && index >= 0 && index < it.length) {
      return it[index].title.isNotEmpty ? it[index].title : meta.name;
    }
    return meta.name;
  }

  String get _coverUrl {
    final it = items;
    if (it != null && index >= 0 && index < it.length) {
      return it[index].cover;
    }
    return meta.icon ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Partial info header from MiruCard (/search/single)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _coverUrl.isNotEmpty
                          ? Image.network(
                              MiruRequest.proxyUrl(_coverUrl).toString(),
                              width: 130,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, _, _) => const SizedBox(
                                width: 130,
                                height: 180,
                                child: DetailSkeleton(),
                              ),
                            )
                          : const SizedBox(
                              width: 130,
                              height: 180,
                              child: DetailSkeleton(width: 130, height: 180),
                            ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title,
                            maxLines: 2,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            meta.name,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.theme.colors.mutedForeground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: MobileDetailSkeleton()),
        const SliverToBoxAdapter(child: SizedBox(height: 300)),
      ],
    );
  }
}

/// Mobile detail body skeleton — only episodes/body are skeleton;
/// cover and title are shown as real partial info from MiruCard above.
class MobileDetailSkeleton extends StatelessWidget {
  const MobileDetailSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Episode/body skeleton only — cover and title are shown as real
        // partial info above this in MobileDetailSkeletonPage header.
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Episode section skeleton (matches MobileDetailSilverlist)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.theme.colors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 150,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.theme.colors.muted,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Episode group dropdown + reverse (matches MobileDetailSilverlist label)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.theme.colors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.theme.colors.muted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Episode buttons skeleton
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < 5; i++)
                    Container(
                      width: 110,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.theme.colors.muted,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Tracking / additional info skeleton
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DetailSkeleton(width: 120, height: 18),
              const SizedBox(height: 10),
              const DetailSkeleton(width: double.infinity, height: 14),
              const SizedBox(height: 6),
              const DetailSkeleton(width: 220, height: 14),
              const SizedBox(height: 6),
              const DetailSkeleton(width: 180, height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
