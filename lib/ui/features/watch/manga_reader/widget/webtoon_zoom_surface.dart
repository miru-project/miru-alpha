import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/scrollable_positioned_list.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_zoom_surface.dart';

/// Webtoon canvas: a [ScrollablePositionedList] under [ReaderZoomSurface]'s
/// paint-only transform, so the chapter keeps its own scrolling at 1x and gains
/// pinch-zoom and panning above it.
///
/// The scrollable is pinned while the view is zoomed (the transform pans then)
/// and while two fingers are down (the transform owns the pinch), which is what
/// keeps a one-finger drag from moving the content twice. [ItemPositionsListener]
/// and [ScrollOffsetListener] keep reporting the position throughout, so it can
/// be recorded and restored.
class WebtoonZoomSurface extends StatelessWidget {
  const WebtoonZoomSurface({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemPositionsListener,
    required this.scrollOffsetController,
    required this.scrollOffsetListener,
    required this.itemScrollController,
    this.initialScrollIndex = 0,
    this.onTap,
    this.doubleTapEnabled = true,
    this.minScale = 1,
    this.maxScale = 4,
    this.onScaleChanged,
    this.onViewMoved,
    this.controller,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ItemPositionsListener itemPositionsListener;
  final ScrollOffsetController scrollOffsetController;
  final ScrollOffsetListener scrollOffsetListener;
  final ItemScrollController itemScrollController;

  /// Slot the list opens at, so the first layout already lands on the resumed
  /// page instead of laying out from the top and jumping a frame later.
  ///
  /// Resuming must NOT go through a post-frame `jumpTo`: the canvas lays out at
  /// slot 0 first, paints that frame, and only then jumps — the reader sees the
  /// chapter's first page flash before the page they left. Seeding the list's
  /// own initial index makes the very first layout land on the resume slot.
  final int initialScrollIndex;

  /// Fired on a tap (no drag), so the reader can toggle its HUD.
  final VoidCallback? onTap;

  /// Whether a double tap toggles the magnification (see
  /// [ReaderZoomSurface.doubleTapEnabled]). The reader disables it while its
  /// overlay is up so taps resolve instantly instead of arming the zoom.
  final bool doubleTapEnabled;

  final double minScale;
  final double maxScale;

  /// Reports the live scale, for tests and for any dependent UI.
  final ValueChanged<double>? onScaleChanged;

  /// Fired when a magnified pan moves the view, so the reader can dismiss its
  /// overlay the way it does for an ordinary scroll.
  final VoidCallback? onViewMoved;

  /// Handle for giving the view back to the reader, e.g. after a jump.
  final ReaderZoomController? controller;

  @override
  Widget build(BuildContext context) {
    return ReaderZoomSurface(
      onTapUp: onTap == null
          ? null
          : (position) {
              onTap!();
            },
      doubleTapEnabled: doubleTapEnabled,
      onScaleChanged: onScaleChanged,
      onViewMoved: onViewMoved,
      minScale: minScale,
      maxScale: maxScale,
      controller: controller,
      scrollOffset: () => scrollOffsetController.offset,
      // A magnified view carries the list with it, so a pan walks through the
      // chapter instead of painting content the list never built.
      onVerticalScroll: (delta) =>
          scrollOffsetController.jumpScroll(offset: delta),
      scrollExtent: () => scrollOffsetController.maxScrollExtent,
      // The list's own extent is the content: wide as the viewport, and as
      // tall as everything that can be scrolled to — measured from the
      // scrollable's minimum (negative above the anchor item), not from 0.
      // Without the lower bound a magnified view inside a prepended chapter
      // could never reach the content above the anchor.
      contentOrigin: () => scrollOffsetController.minScrollExtent,
      contentSize: (viewport) => Size(
        viewport.width,
        viewport.height +
            scrollOffsetController.maxScrollExtent -
            scrollOffsetController.minScrollExtent,
      ),
      builder: (context, zoom) => zoom.wrap(
        ScrollablePositionedList.builder(
          itemPositionsListener: itemPositionsListener,
          scrollOffsetController: scrollOffsetController,
          scrollOffsetListener: scrollOffsetListener,
          itemScrollController: itemScrollController,
          // Only the first value matters: the fork reads this in initState and
          // ignores later changes, so it must not be a value that moves as the
          // reader scrolls. The caller captures the resume slot once.
          initialScrollIndex: initialScrollIndex,
          physics: zoom.scrollingEnabled
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        ),
      ),
    );
  }
}
