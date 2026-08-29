import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/features/detail/desktop_loaded_page.dart';
import 'package:miru_alpha/ui/features/detail/mobile_loaded_page.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:miru_alpha/ui/features/detail/widget/detail_loading_skeleton.dart';
import './widget/index.dart';
import './detail_refresh.dart';

class DetailLoadingPage extends StatefulHookConsumerWidget {
  const DetailLoadingPage({
    super.key,
    required this.meta,
    required this.detailUrl,
    this.items,
    this.index = 0,
  });
  final ExtensionMeta meta;
  final String detailUrl;

  /// Result list + tapped index when opened from a search/latest grid, used for
  /// desktop "previous / next" page navigation.
  final List<ExtensionListItem>? items;
  final int index;

  /// Convenience redirect from the router's [DetailParam] extra.
  factory DetailLoadingPage.fromParam(DetailParam param, {Key? key}) {
    return DetailLoadingPage(
      key: key,
      meta: param.meta,
      detailUrl: param.url,
      items: param.items,
      index: param.index,
    );
  }

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
                                color: Color.alphaBlend(
                                  context.theme.colors.primary.withAlpha(
                                    128,
                                  ), // Foreground
                                  context.theme.colors.foreground, // Background
                                ),
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
        desktopBody: _DesktopDetailContent(
          detail: detial,
          meta: widget.meta,
          detailPr: detailPr,
          detailUrl: widget.detailUrl,
          items: widget.items,
          index: widget.index,
        ),
        mobileBody: MobileLoadedPage(
          detail: detial,
          detailPr: detailPr,
          meta: widget.meta,
          detailUrl: widget.detailUrl,
        ),
      ),
      error: (err, stack) => _DesktopDetailScaffold(
        meta: widget.meta,
        items: widget.items,
        index: widget.index,
        detailUrl: widget.detailUrl,
        child: ErrorDisplay.grpc(err: err, stack: stack),
      ),
      loading: () => DeviceUtil.device(
        context: context,
        mobile: MiruScaffold.mobile(
          desktopBody: DesktopDetailSkeletonContent(
            meta: widget.meta,
            items: widget.items,
            index: widget.index,
          ),
          mobileBody: MobileDetailSkeletonPage(
            meta: widget.meta,
            items: widget.items,
            index: widget.index,
          ),
        ),
        desktop: _DesktopDetailScaffold(
          meta: widget.meta,
          items: widget.items,
          index: widget.index,
          detailUrl: widget.detailUrl,
          child: DesktopDetailSkeletonContent(
            meta: widget.meta,
            items: widget.items,
            index: widget.index,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop detail: header (Back / Prev / Next / Refresh) + breadcrumb, with
// scaffold loading shown on the present page while the MVVM model re-fetches.
// ---------------------------------------------------------------------------

/// Wraps [child] in a desktop scaffold that always renders the detail header
/// (Back / Prev / Next / Refresh + breadcrumb) so the present page keeps its
/// chrome while loading or showing an error.
class _DesktopDetailScaffold extends StatelessWidget {
  const _DesktopDetailScaffold({
    required this.meta,
    required this.items,
    required this.index,
    required this.detailUrl,
    required this.child,
  });

  final ExtensionMeta meta;
  final List<ExtensionListItem>? items;
  final int index;
  final String detailUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MiruScaffold.desktop(
      body: Column(
        children: [
          _DesktopDetailHeader(
            meta: meta,
            items: items,
            index: index,
            detailUrl: detailUrl,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Desktop detail body: header + the loaded [DesktopLoadedPage].
class _DesktopDetailContent extends StatelessWidget {
  const _DesktopDetailContent({
    required this.detail,
    required this.meta,
    required this.detailPr,
    required this.detailUrl,
    required this.items,
    required this.index,
  });

  final Detail detail;
  final ExtensionMeta meta;
  final DetialProvider detailPr;
  final String detailUrl;
  final List<ExtensionListItem>? items;
  final int index;

  @override
  Widget build(BuildContext context) {
    return MiruScaffold.desktop(
      body: Column(
        children: [
          _DesktopDetailHeader(
            meta: meta,
            items: items,
            index: index,
            detailUrl: detailUrl,
          ),
          Expanded(
            child: DesktopLoadedPage(
              detail: detail,
              meta: meta,
              detailPr: detailPr,
              detailUrl: detailUrl,
            ),
          ),
        ],
      ),
    );
  }
}

/// Desktop detail header placed above the breadcrumb. Provides Back (pop to the
/// search/latest list or home), Previous / Next (walk the result list), and a
/// Refresh that re-runs the [fetchDetailProvider] MVVM model for the present
/// page.
class _DesktopDetailHeader extends ConsumerWidget {
  const _DesktopDetailHeader({
    required this.meta,
    required this.items,
    required this.index,
    required this.detailUrl,
  });

  final ExtensionMeta meta;
  final List<ExtensionListItem>? items;
  final int index;
  final String detailUrl;

  ExtensionListItem? _neighbor(bool next) {
    if (items == null) return null;
    final i = index + (next ? 1 : -1);
    if (i < 0 || i >= items!.length) return null;
    return items![i];
  }

  void _goTo(BuildContext context, ExtensionListItem item) {
    context.pushReplacement(
      '/search/single/detail',
      extra: DetailParam(
        meta: meta,
        url: item.url,
        items: items,
        index: items!.indexOf(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prev = _neighbor(false);
    final next = _neighbor(true);
    final isRefreshing = ref.watch(
      fetchDetailProvider(
        meta.packageName,
        detailUrl,
      ).select((s) => s.isLoading),
    );

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.theme.colors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          FButton.icon(
            variant: .ghost,
            onPress: () => context.pop(),
            child: Icon(FLucideIcons.chevronLeft),
          ),
          FButton.icon(
            variant: .ghost,
            onPress: prev == null ? null : () => _goTo(context, prev),
            child: Icon(FLucideIcons.chevronLeft),
          ),
          FButton.icon(
            variant: .ghost,
            onPress: next == null ? null : () => _goTo(context, next),
            child: Icon(FLucideIcons.chevronRight),
          ),
          FButton.icon(
            variant: .ghost,
            onPress: isRefreshing
                ? null
                : () => forceRefreshDetail(ref, detailUrl, meta),
            child: isRefreshing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: FCircularProgress(),
                  )
                : Icon(FLucideIcons.refreshCw),
          ),
          const SizedBox(width: 8),
          const Expanded(child: _DetailBreadCrumb()),
        ],
      ),
    );
  }
}

/// Minimal breadcrumb kept local to the detail page to avoid an import cycle
/// between the detail page and main_page.
class _DetailBreadCrumb extends HookWidget {
  const _DetailBreadCrumb();

  @override
  Widget build(BuildContext context) {
    final routeInfo = GoRouter.of(context).routeInformationProvider;
    useListenable(routeInfo);

    final currentLocation =
        GoRouter.of(context).routerDelegate.state.fullPath ??
        GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

    final segments = currentLocation
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();

    return FBreadcrumb(
      children: [
        for (final seg in segments)
          FBreadcrumbItem(
            onPress: () {
              if (seg == segments.last) return;
              if (!context.canPop()) return;
              if (seg == 'search' && segments.last == 'detail') {
                context.pop();
                context.pop();
                return;
              }
              if ((seg == 'single' && segments.last == 'detail') ||
                  (seg == 'search' && segments.last == 'single')) {
                context.pop();
                return;
              }
            },
            child: Text(
              seg.i18n,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
      ],
    );
  }
}
