import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/pages/detail/desktop_loaded_page.dart';
import 'package:miru_app_new/pages/detail/mobile_loaded_page.dart';
import 'package:miru_app_new/provider/detial_provider.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:miru_app_new/widgets/animted_icon/heart.dart';

import 'package:miru_app_new/widgets/error.dart';
import 'package:miru_app_new/widgets/index.dart';
import './widget/index.dart';

class DetailLoadingPage extends StatefulHookConsumerWidget {
  const DetailLoadingPage({super.key, required this.meta, required this.url});
  final ExtensionMeta meta;
  final String url;

  @override
  createState() => _DetailLoadPageState();
}

class _DetailLoadPageState extends ConsumerState<DetailLoadingPage> {
  @override
  void initState() {
    Future.microtask(() async {
      final history = await DatabaseService.getHistoryByPackageAndUrl(
        widget.meta.packageName,
        widget.url,
      );
      ref.read(detialProvider.notifier).putHistory(history);

      // Fetch favorite state
      final favorite = await DatabaseService.getFavoriteByPackageAndUrl(
        widget.meta.packageName,
        widget.url,
      );
      ref.read(detialProvider.notifier).putFavorite(favorite);
    });
    // Trigger detail fetch via DetialProvider so UI doesn't depend directly on the fetch provider
    Future.microtask(
      () => ref
          .read(detialProvider.notifier)
          .initDetail(widget.meta.packageName, widget.url),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final detial =
        ref.watch(detialProvider).detailState ?? const AsyncValue.loading();
    final favorite = ref.watch(
      detialProvider.select((value) => value.favorite),
    );
    return detial.when(
      data: (detial) => MiruScaffold(
        snapSheet: [
          MobileDetailTabs(
            detail: detial,
            meta: widget.meta,
            detailUrl: widget.url,
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
              // FSelectMenuTile(title: Text(detail.episodes.toString()), menu: []),
              Spacer(),
              FButton.icon(
                style: FButtonStyle.ghost(),
                onPress: () {
                  context.push(
                    '/mobileWebView',
                    extra: WebviewParam(meta: widget.meta, url: widget.url),
                  );
                },
                child: Icon(
                  FIcons.globe,
                  size: 28,
                  color: context.theme.colors.primary,
                ),
              ),
              FButton.icon(
                style: FButtonStyle.ghost(),
                onPress: () {
                  if (favorite != null) {
                    ref.read(detialProvider.notifier).removeFavorite(favorite);
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (context) => FavoriteDialog(
                      meta: widget.meta,
                      detailUrl: widget.url,
                      detail: detial,
                      onSuccess: () async {
                        // Refresh favorite state after dialog closes
                        final favorite =
                            await DatabaseService.getFavoriteByPackageAndUrl(
                              widget.meta.packageName,
                              widget.url,
                            );
                        ref.read(detialProvider.notifier).putFavorite(favorite);
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
          detailUrl: widget.url,
        ),
        mobileBody: MobileLoadedPage(
          detail: detial,
          meta: widget.meta,
          detailUrl: widget.url,
        ),
      ),
      error: (err, stack) => ErrorDisplay.grpc(err: err, stack: stack),
      loading: () => Center(child: FCircularProgress()),
    );
  }
}
