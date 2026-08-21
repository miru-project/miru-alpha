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
      child: MiruCard(
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
            padding: EdgeInsetsGeometry.symmetric(horizontal: 25, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (favorite != null)
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
                                detail.title,
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
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                    child: Text(
                      detail.title,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                const SizedBox(height: 25),
                FAccordion(
                  style: .delta(
                    dividerStyle: .delta(color: Colors.transparent),
                  ),
                  children: [
                    FAccordionItem(
                      initiallyExpanded: true,
                      title: Text("media.episode.description".i18n),
                      child: Text(
                        detail.desc ?? "media.no_description".i18n,
                        style: TextStyle(
                          fontSize: 15,
                          color: context.theme.colors.mutedForeground,
                        ),
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
                      varient: .secondary,
                      isIcon: false,
                      detail: detail,
                      meta: meta,
                      detailUrl: detailUrl,
                    ),

                    FButton(
                      variant: .secondary,
                      suffix: HeartButton(
                        size: 15,
                        activeColor: context.theme.colors.primary,
                        inactiveColor: context.theme.colors.primary,
                        isLiked: favorite != null,
                      ),
                      onPress: () {
                        if (favorite != null) {
                          ref.read(detailPr.notifier).removeFavorite(favorite);
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
                      variant: .outline,
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
      ),
    );
  }
}
