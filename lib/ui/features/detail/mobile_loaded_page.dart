import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/features/detail/widget/detail_loading_skeleton.dart';
import 'package:miru_alpha/ui/features/detail/widget/index.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/miru_core/network.dart';

/// Mobile detail body. The whole content area is wrapped in a [DetailSection]
/// so it flips between a skeleton, an inline retry tile, and real content
/// together — instead of the prior layout which froze the cover and only ever
/// showed a spinner for the rest.
///
/// Content order follows the reference design: hero (cover, title + meta +
/// genre tag chips, Play/Download, description) → tracking accordion →
/// cast accordion → episode list.
///
/// The loading state reuses the route phase's [MobileDetailSkeletonPage],
/// fed with the already-fetched [detail], so the whole load shows one
/// skeleton that only gets richer instead of swapping to a second, plainer
/// shell.
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
    return EasyRefresh(
      header: const ForuiHeader(),
      triggerAxis: Axis.vertical,
      onRefresh: () async => ref.read(detailPr.notifier).retry(),
      scrollController: scrollController,
      child: DetailSection<Detail>(
        detailPr: detailPr,
        selector: (s) => s.detailInfo != null
            ? MiruCoreEndpoint.detailFromProto(s.detailInfo!)
            : detail,
        skeletonBuilder: (_) => MobileDetailSkeletonPage(
          meta: meta,
          detail: detail,
          controller: scrollController,
        ),
        content: (_, d) => CustomScrollView(
          controller: scrollController,
          scrollCacheExtent: .viewport(10),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    MobileDetailHero(
                      detail: d,
                      meta: meta,
                      detailUrl: detailUrl,
                      detailPr: detailPr,
                    ),
                    const SizedBox(height: 16),
                    MobileTrackersCastSection(
                      detail: d,
                      meta: meta,
                      detailUrl: detailUrl,
                      detailPr: detailPr,
                    ),
                  ],
                ),
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
