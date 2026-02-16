import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/pages/detail/desktop_loaded_page.dart';
import 'package:miru_app_new/pages/detail/mobile_loaded_page.dart';
import 'package:miru_app_new/provider/detial_provider.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/widgets/animted_icon/heart.dart';

import 'package:miru_app_new/widgets/error.dart';
import 'package:miru_app_new/widgets/index.dart';
import './widget/index.dart';

class DetailLoadingPage extends StatefulHookConsumerWidget {
  const DetailLoadingPage({
    super.key,
    required this.meta,
    required this.detailUrl,
  });
  final ExtensionMeta meta;
  final String detailUrl;

  @override
  createState() => _DetailLoadPageState();
}

class _DetailLoadPageState extends ConsumerState<DetailLoadingPage> {
  @override
  Widget build(BuildContext context) {
    final detailPr = detialProvider(widget.detailUrl, meta: widget.meta);
    final detial = ref.watch(
      fetchDetailProvider(widget.meta.packageName, widget.detailUrl),
    );
    final favorite = ref.watch(detailPr.select((value) => value.favorite));
    return detial.when(
      data: (detial) => MiruScaffold(
        snapSheet: [
          MobileDetailTabs(
            detail: detial,
            meta: widget.meta,
            detailUrl: widget.detailUrl,
          ),
        ],
        mobileHeader: Padding(
          padding: EdgeInsetsGeometry.only(right: 10, left: 5, bottom: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0, top: 4),
                  child: Icon(
                    FIcons.chevronLeft,
                    size: 28,
                    color: context.theme.colors.primary,
                  ),
                ),
              ),
              Spacer(),
              FButton.icon(
                variant: .ghost,
                onPress: () {
                  context.push(
                    '/mobileWebView',
                    extra: WebviewParam(
                      meta: widget.meta,
                      url: widget.detailUrl,
                    ),
                  );
                },
                child: Icon(
                  FIcons.globe,
                  size: 28,
                  color: context.theme.colors.primary,
                ),
              ),
              FButton.icon(
                variant: .ghost,
                onPress: () {
                  if (favorite != null) {
                    ref.read(detailPr.notifier).removeFavorite(favorite);
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (context) => FavoriteDialog(
                      meta: widget.meta,
                      detailUrl: widget.detailUrl,
                      detail: detial,
                      onSuccess: (fav, groups) {
                        ref.read(detailPr.notifier).putFavorite(fav);
                        ref.read(detailPr.notifier).putFavoriteGroup(groups);
                      },
                    ),
                  );
                },
                child: HeartButton(
                  size: 28,
                  activeColor: context.theme.colors.primary,
                  inactiveColor: context.theme.colors.primary,
                  isLiked: favorite != null,
                ),
              ),
            ],
          ),
        ),
        desktopBody: DesktopLoadedPage(
          detail: detial,
          meta: widget.meta,
          detailPr: detailPr,
          detailUrl: widget.detailUrl,
        ),
        mobileBody: MobileLoadedPage(
          detail: detial,
          detailPr: detailPr,
          meta: widget.meta,
          detailUrl: widget.detailUrl,
        ),
      ),
      error: (err, stack) => ErrorDisplay.grpc(err: err, stack: stack),
      loading: () => Center(child: FCircularProgress()),
    );
  }
}
