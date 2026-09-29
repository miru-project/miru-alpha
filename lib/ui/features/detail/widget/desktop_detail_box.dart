import 'package:extended_image/extended_image.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/features/detail/widget/index.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/ui/core/amination/animated_box.dart';
import 'package:miru_alpha/ui/core/animted_icon/heart.dart';

/// Header card on the detail page. The whole content area is wrapped in a
/// [DetailSection] so the entire card flips between a skeleton, an inline
/// retry tile, and real content together — instead of the prior layout
/// which froze the cover and only ever showed a spinner for the rest.
class DetailDesktopBox extends HookConsumerWidget {
  const DetailDesktopBox({
    super.key,
    required this.detail,
    required this.coverUrl,
    required this.meta,
    required this.detailUrl,
    required this.isTablet,
    required this.detailPr,
  });
  final Detail detail;
  final String coverUrl;
  final ExtensionMeta meta;
  final String detailUrl;
  final bool isTablet;
  final DetialProvider detailPr;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorite = ref.watch(detailPr.select((value) => value.favorite));
    return AnimatedBox(
      child: DetailSection<String>(
        detailPr: detailPr,
        selector: (s) => s.detailInfo?.title ?? '',
        skeletonBuilder: (_) => _CoverShell(isTablet: isTablet),
        content: (_, title) => _Loaded(
          title: title,
          detail: detail,
          coverUrl: coverUrl,
          isTablet: isTablet,
          meta: meta,
          detailUrl: detailUrl,
          detailPr: detailPr,
          favorite: favorite,
        ),
      ),
    );
  }
}

/// Skeleton used while [Detial] is loading. Mirrors the loaded layout's
/// shape (cover + title + body rows) so the swap to real content doesn't
/// cause a big reflow.
class _CoverShell extends StatelessWidget {
  const _CoverShell({required this.isTablet});
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return MiruCard(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const DetailSkeleton(width: 120, height: 180),
            ),
            const SizedBox(width: 25),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  DetailSkeleton(width: 280, height: 28),
                  SizedBox(height: 12),
                  DetailSkeleton(width: 200, height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Actual desktop content. Always rendered under a [DetailSection] (which
/// already gated the loading and error cases), so the methods below can
/// assume a valid [detail] title.
class _Loaded extends HookConsumerWidget {
  const _Loaded({
    required this.title,
    required this.detail,
    required this.coverUrl,
    required this.isTablet,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
    required this.favorite,
  });

  final String title;
  final Detail detail;
  final String coverUrl;
  final bool isTablet;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider detailPr;
  final Favorite? favorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MiruCard(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            fit: BoxFit.fitWidth,
            image: ExtendedNetworkImageProvider(
              MiruRequest.proxyUrl(coverUrl).toString(),
            ),
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(200), // optional dark overlay
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (favorite != null && favorite!.title.isNotEmpty)
                FBadge(child: Text('media.favorited'.i18n)),
              const SizedBox(height: 10),
              if (isTablet)
                SizedBox(
                  height: 200,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Use Flexible/Expanded to prevent overflow
                      return Row(
                        children: [
                          DetailImageView(detail: detail, coverUrl: coverUrl),
                          const SizedBox(width: 25),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              else
                Text(
                  title,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 25),
              FAccordion(
                style: FAccordionStyleDelta.delta(
                  dividerStyle: FDividerStyleDelta.delta(
                    color: const Color(0x00000000),
                  ),
                ),
                children: [
                  FAccordionItem(
                    initiallyExpanded: true,
                    title: Text("media.episode.description".i18n),
                    child: DetailSection<String?>(
                      detailPr: detailPr,
                      selector: (s) => s.detailInfo?.desc,
                      skeletonBuilder: (_) => const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailSkeleton(height: 14),
                          SizedBox(height: 8),
                          DetailSkeleton(height: 14, width: 280),
                          SizedBox(height: 6),
                          DetailSkeleton(height: 14, width: 220),
                        ],
                      ),
                      content: (context, desc) {
                        // `Detail.desc` can be null, so coalesce to the
                        // localized "no description" placeholder.
                        final raw = desc;
                        final hasDesc = raw != null && raw.isNotEmpty;
                        final text = hasDesc
                            ? raw
                            : "media.no_description".i18n;
                        return Text(
                          text,
                          style: TextStyle(
                            fontSize: 15,
                            color: context.theme.colors.mutedForeground,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Use Wrap for responsive layout that wraps on small screens
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FButton(
                    suffix: Icon(FLucideIcons.play),
                    onPress: () {},
                    child: Text("media.video_player.play".i18n),
                  ),

                  DownloadButton(
                    varient: FButtonVariant.secondary,
                    isIcon: false,
                    detail: detail,
                    meta: meta,
                    detailUrl: detailUrl,
                  ),

                  FButton(
                    variant: FButtonVariant.secondary,
                    suffix: HeartButton(
                      size: 15,
                      activeColor: context.theme.colors.primary,
                      inactiveColor: context.theme.colors.primary,
                      isLiked: favorite != null,
                    ),
                    onPress: () {
                      final fav = favorite;
                      if (fav != null) {
                        ref.read(detailPr.notifier).removeFavorite(fav);
                        return;
                      }
                      showDialog(
                        context: context,
                        builder: (context) => FavoriteDialog(
                          meta: meta,
                          detailUrl: detailUrl,
                          detail: detail,
                          detailPr: detailPr,
                        ),
                      );
                    },
                    child: Text("favorite.title".i18n),
                  ),

                  FButton(
                    variant: FButtonVariant.outline,
                    suffix: Icon(FLucideIcons.globe),
                    onPress: () {
                      context.push(
                        '/mobileWebView',
                        extra: WebviewParam(meta: meta, url: detailUrl),
                      );
                    },
                    child: Text("common.webview".i18n),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
