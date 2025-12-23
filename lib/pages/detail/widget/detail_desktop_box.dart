import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';

import 'package:miru_app_new/utils/store/database_service.dart';

import 'package:miru_app_new/widgets/amination/animated_box.dart';
import 'package:miru_app_new/pages/detail/widget/favorite_dialog.dart';

class DetailDesktopBox extends HookWidget {
  const DetailDesktopBox({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
  });
  final ExtensionDetail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  @override
  Widget build(BuildContext context) {
    return AnimatedBox(
      child: FCard.raw(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              fit: BoxFit.fitWidth,
              image: ExtendedNetworkImageProvider(detail.cover ?? ''),
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
                FutureBuilder(
                  future: DatabaseService.isFavorite(
                    package: meta.packageName,
                    url: detailUrl,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.data == true) {
                      return FBadge(child: Text('Favorited'));
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 10),
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
                    Row(
                      children: [
                        FButton(
                          suffix: Icon(FIcons.play),
                          onPress: () {},
                          child: Text("Play"),
                        ),
                        SizedBox(width: 15),
                        FButton(
                          style: FButtonStyle.outline(),
                          suffix: Icon(FIcons.globe),
                          onPress: () {},
                          child: Text("WebView"),
                        ),
                      ],
                    ),
                    FButton(
                      style: FButtonStyle.secondary(),
                      suffix: Icon(FIcons.globe),
                      onPress: () {},
                      child: Text("WebView"),
                    ),
                    const SizedBox(width: 15),
                    FButton(
                      style: FButtonStyle.secondary(),
                      suffix: Icon(FIcons.heart),
                      onPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => FavoriteDialog(
                            meta: meta,
                            detailUrl: detailUrl,
                            detail: detail,
                            onSuccess: () {
                              // Trigger rebuild to update "Favorited" badge
                              (context as Element).markNeedsBuild();
                            },
                          ),
                        );
                      },
                      child: Text("Favorite"),
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
