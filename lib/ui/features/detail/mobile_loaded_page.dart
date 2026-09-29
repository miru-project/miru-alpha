import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_image/extended_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/features/detail/widget/index.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/miru_core/network.dart';

/// Mobile detail body. The whole content area is wrapped in a [DetailSection]
/// so it flips between askeleton, an inline retry tile, and real content
/// together — instead of the prior layout which froze the cover and only ever
/// showed a spinner for the rest.
class MobileLoadedPage extends HookConsumerWidget {
  const MobileLoadedPage({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
  });
  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider detailPr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final favGrp = ref.watch(detailPr.select((value) => value.favoriateGroup));
    return EasyRefresh(
      header: const ForuiHeader(),
      onRefresh: () async => ref.read(detailPr.notifier).retry(),
      scrollController: scrollController,
      child: DetailSection<Detail>(
        detailPr: detailPr,
        selector: (s) => s.detailInfo != null
            ? MiruCoreEndpoint.detailFromProto(s.detailInfo!)
            : detail,
        skeletonBuilder: (_) => CustomScrollView(
          controller: scrollController,
          slivers: const [
            SliverToBoxAdapter(child: _MobileShell()),
            SliverToBoxAdapter(child: SizedBox(height: 300)),
          ],
        ),
        content: (_, d) => CustomScrollView(
          controller: scrollController,
          scrollCacheExtent: .viewport(10),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 130,
                        height: 180,
                        child: DetailImageView(
                          detail: d,
                          coverUrl: d.cover ?? '',
                          child: ImageWidget(
                            imageUrl: d.cover ?? '',
                            fit: BoxFit.cover,
                            errChild: MiruCard(
                              child: Center(
                                child: Icon(FLucideIcons.cloudAlert),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FLabel(
                                layout: FLabelLayout.vertical,
                                description: Row(
                                  children: [
                                    Icon(switch (meta.type) {
                                      ExtensionType.manga => FLucideIcons.book,
                                      ExtensionType.bangumi =>
                                        FLucideIcons.film,
                                      ExtensionType.fikushon =>
                                        FLucideIcons.bookText,
                                      ExtensionType.all => FLucideIcons.rows3,
                                    }),
                                    const Text(' • '),
                                    FTappable(
                                      onPress: () {},
                                      child: Row(
                                        children: [
                                          if (meta.icon != null)
                                            ExtendedImage.network(
                                              MiruRequest.proxyUrl(
                                                meta.icon!,
                                              ).toString(),
                                              width: 20,
                                              height: 20,
                                            ),
                                          const SizedBox(width: 4),
                                          Text(meta.name),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                child: FTappable(
                                  onPress: () {},
                                  child: Text(
                                    d.title,
                                    style: const TextStyle(
                                      height: 1.2,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                    maxLines: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (favGrp != null)
                                Wrap(
                                  spacing: 10,
                                  children: favGrp
                                      .map(
                                        (e) => FTappable(
                                          onPress: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  FavoriteDialog(
                                                    meta: meta,
                                                    detailUrl: detailUrl,
                                                    detail: d,
                                                    detailPr: detailPr,
                                                  ),
                                            );
                                          },
                                          child: FBadge(child: Text(e.name)),
                                        ),
                                      )
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            MobileDetailSilverlist(
              detail: d,
              meta: meta,
              detailUrl: detailUrl,
              detailPr: detailPr,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 300)),
          ],
        ),
      ),
    );
  }
}

/// Skeleton shown in place of the whole mobile detail body while [Detial] is
/// loading. Mirrors the cover + title + body rows so the swap to real content
/// doesn't reflow heavily.
class _MobileShell extends StatelessWidget {
  const _MobileShell();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: DetailSkeleton(width: 130, height: 180),
              ),
              SizedBox(width: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailSkeleton(width: 220, height: 22),
                    SizedBox(height: 8),
                    DetailSkeleton(width: 180, height: 16),
                    SizedBox(height: 8),
                    DetailSkeleton(width: 140, height: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailSkeleton(width: 120, height: 18),
              SizedBox(height: 10),
              DetailSkeleton(width: double.infinity, height: 14),
              SizedBox(height: 6),
              DetailSkeleton(width: 220, height: 14),
              SizedBox(height: 6),
              DetailSkeleton(width: 180, height: 14),
            ],
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailSkeleton(width: 100, height: 18),
              SizedBox(height: 10),
              DetailSkeleton(width: 160, height: 38, borderRadius: 8),
              SizedBox(height: 8),
              DetailSkeleton(width: 140, height: 38, borderRadius: 8),
            ],
          ),
        ),
      ],
    );
  }
}
