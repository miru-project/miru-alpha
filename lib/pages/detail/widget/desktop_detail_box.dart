import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/detail/widget/index.dart';
import 'package:miru_app_new/pages/webview/desktop_webview.dart';
import 'package:miru_app_new/provider/detial_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:miru_app_new/widgets/amination/animated_box.dart';
import 'package:miru_app_new/widgets/animted_icon/heart.dart';

class DetailDesktopBox extends HookConsumerWidget {
  const DetailDesktopBox({
    super.key,
    required this.detail,
    required this.coverUrl,
    required this.meta,
    required this.detailUrl,
    required this.isTablet,
  });
  final ExtensionDetail detail;
  final String coverUrl;
  final ExtensionMeta meta;
  final String detailUrl;
  final bool isTablet;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorite = ref.watch(
      detialProvider.select((value) => value.favorite),
    );
    return AnimatedBox(
      child: FCard.raw(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              fit: BoxFit.fitWidth,
              image: ExtendedNetworkImageProvider(coverUrl),
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
                if (favorite != null) FBadge(child: Text('Favorited')),
                const SizedBox(height: 10),
                if (isTablet)
                  SizedBox(
                    height: 200,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            DetailImageView(detail: detail, coverUrl: coverUrl),
                            const SizedBox(width: 25),
                            SizedBox(
                              width: constraints.maxWidth - 300,
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
                  style: (style) {
                    return FAccordionStyle(
                      titleTextStyle: style.titleTextStyle,
                      childTextStyle: style.childTextStyle,
                      iconStyle: style.iconStyle,
                      focusedOutlineStyle: style.focusedOutlineStyle,
                      dividerStyle: style.dividerStyle.copyWith(
                        color: Colors.transparent,
                      ),
                      tappableStyle: style.tappableStyle,
                    );
                  },
                  children: [
                    FAccordionItem(
                      initiallyExpanded: true,
                      title: Text("Description"),
                      child: Text(
                        detail.desc ?? "Currently no description ... ",
                        style: TextStyle(
                          fontSize: 15,
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    FButton(
                      suffix: Icon(FIcons.play),
                      onPress: () {},
                      child: Text("Play"),
                    ),

                    SizedBox(width: 15),
                    DownloadButton(
                      style: FButtonStyle.secondary(),
                      isIcon: false,
                      detail: detail,
                      meta: meta,
                      detailUrl: detailUrl,
                    ),
                    const SizedBox(width: 15),
                    FButton(
                      style: FButtonStyle.secondary(),
                      suffix: HeartButton(
                        size: 22,
                        activeColor: context.theme.colors.primary,
                        inactiveColor: context.theme.colors.primary,
                        isLiked: favorite != null,
                      ),
                      onPress: () {
                        if (favorite != null) {
                          ref
                              .read(detialProvider.notifier)
                              .removeFavorite(favorite);
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (context) => FavoriteDialog(
                            meta: meta,
                            detailUrl: detailUrl,
                            detail: detail,
                            onSuccess: () async {
                              // Refresh favorite state after dialog closes
                              final favorite =
                                  await DatabaseService.getFavoriteByPackageAndUrl(
                                    meta.packageName,
                                    detailUrl,
                                  );
                              ref
                                  .read(detialProvider.notifier)
                                  .putFavorite(favorite);
                            },
                          ),
                        );
                      },
                      child: Text("Favorite"),
                    ),
                    SizedBox(width: 15),
                    FButton(
                      style: FButtonStyle.outline(),
                      suffix: Icon(FIcons.globe),
                      onPress: () {
                        if (DeviceUtil.isMobile) {
                          context.push(
                            '/mobileWebView',
                            extra: WebviewParam(meta: meta, url: detailUrl),
                          );
                          return;
                        }
                        openWebview(meta, detailUrl);
                      },
                      child: Text("WebView"),
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
