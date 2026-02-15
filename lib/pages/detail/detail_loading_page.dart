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
  void initState() {
    Future.microtask(() async {
      final historyList = await DatabaseService.getHistoryByPackageAndDetailUrl(
        widget.meta.packageName,
        widget.detailUrl,
      );
      ref.read(detialProvider.notifier).putHistoryList(historyList);

      final favorite = await DatabaseService.getFavoriteByPackageAndUrl(
        widget.meta.packageName,
        widget.detailUrl,
      );
      ref.read(detialProvider.notifier).putFavorite(favorite);
    });
    Future.microtask(
      () => ref
          .read(detialProvider.notifier)
          .initDetail(widget.meta.packageName, widget.detailUrl),
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
                    ref.read(detialProvider.notifier).removeFavorite(favorite);
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (context) => FavoriteDialog(
                      meta: widget.meta,
                      detailUrl: widget.detailUrl,
                      detail: detial,
                      onSuccess: () async {
                        // Refresh favorite state after dialog closes
                        final favorite =
                            await DatabaseService.getFavoriteByPackageAndUrl(
                              widget.meta.packageName,
                              widget.detailUrl,
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
          detailUrl: widget.detailUrl,
        ),
        mobileBody: MobileLoadedPage(
          detail: detial,
          meta: widget.meta,
          detailUrl: widget.detailUrl,
        ),
      ),
      error: (err, stack) => ErrorDisplay.grpc(err: err, stack: stack),
      loading: () => Center(child: FCircularProgress()),
    );
  }
}
