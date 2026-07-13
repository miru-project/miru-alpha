import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/ui/features/detail/desktop_loaded_page.dart';
import 'package:miru_alpha/ui/features/detail/mobile_loaded_page.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
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
  /// Mirrors the detail page's scroll offset. The body (`MobileLoadedPage`)
  /// scrolls inside its own [CustomScrollView], so the outer sliver header
  /// never receives a changing `shrinkOffset`. We feed the real scroll offset
  /// here (via [MiruScaffold.onScrollChange]) and drive the header from it
  /// instead, so the header's title animation (and any logging) updates on
  /// scroll.
  final ValueNotifier<double> _scrollNotifier = ValueNotifier(0.0);

  @override
  void dispose() {
    _scrollNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailPr = detialProvider(widget.detailUrl, meta: widget.meta);
    final detial = ref.watch(
      fetchDetailProvider(widget.meta.packageName, widget.detailUrl),
    );
    final favorite = ref.watch(detailPr.select((value) => value.favorite));
    return detial.when(
      data: (detial) => MiruScaffold.mobile(
        onScrollChange: (offset, progress) => _scrollNotifier.value = offset,
        snappingOffsets: const [
          AbsoluteSheetOffset(150),
          ProportionalToViewportSheetOffset(0.5),
          ProportionalToViewportSheetOffset(1.0),
        ],
        snapSheet: [
          MobileDetailTabs(
            detail: detial,
            meta: widget.meta,
            detailUrl: widget.detailUrl,
            detailPr: detailPr,
          ),
        ],
        sliverHeaders: [
          CustomSliverHeaderDelegate(
            maxExtent: 50,
            minExtent: 50,
            scrollPosition: _scrollNotifier,
            builder: (context, offset, progress) {
              final titleVisible = offset > 285;
              return Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 12.0,
                        top: 4,
                        left: 10,
                      ),
                      child: Icon(
                        FLucideIcons.chevronLeft,
                        size: 28,
                        color: context.theme.colors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: titleVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      child: AnimatedSlide(
                        offset: titleVisible
                            ? Offset.zero
                            : const Offset(0, -0.3),
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              detial.title,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: context.theme.colors.primary,
                              ),
                              // Let the title fill the full width of the Expanded
                              // and wrap onto multiple lines instead of being
                              // clamped to a single ellipsized line.
                              softWrap: true,
                            ),
                            Text(
                              widget.meta.name,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: context.theme.colors.mutedForeground,
                              ),
                              // Let the title fill the full width of the Expanded
                              // and wrap onto multiple lines instead of being
                              // clamped to a single ellipsized line.
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                      FLucideIcons.globe,
                      size: 24,
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
                          detailPr: detailPr,
                        ),
                      );
                    },
                    child: HeartButton(
                      size: 24,
                      activeColor: context.theme.colors.primary,
                      inactiveColor: context.theme.colors.primary,
                      isLiked: favorite != null,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
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
