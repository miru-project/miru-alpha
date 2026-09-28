import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/manag_image.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_zoom_surface.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/webtoon_zoom_surface.dart';

/// Horizontal share of the viewport treated as a "previous page" tap zone.
const kReaderTapZoneExtent = 0.3;

/// Full-bleed page canvas.
///
/// Renders paged (LTR / RTL) or continuous (webtoon) depending on
/// [MangaReadMode], on a canvas coloured by [MangaCanvasBackground] and dimmed
/// by the device brightness the shell applies via `ScreenBrightness`.
///
/// Owns only page turning. HUD toggling lives in the parent shell so a single
/// handler decides what a centre tap means.
class MiruMangaViewPort extends ConsumerWidget {
  const MiruMangaViewPort({
    required this.data,
    required this.epProvider,
    required this.mangaProvider,
    required this.meta,
    required this.name,
    required this.onTapCenter,
    this.onViewMoved,
    super.key,
  });

  final ExtensionMangaWatch? data;
  final EpisodeNotifierProvider epProvider;
  final MangaReaderProvider mangaProvider;
  final ExtensionMeta meta;
  final String name;

  /// Invoked when the reader taps outside the edge zones.
  final VoidCallback onTapCenter;

  /// Invoked when a magnified pan moves the view. A magnified view pins its
  /// scrollable, so the pan produces no drag notification and the reader needs
  /// this to dismiss its overlay the way an ordinary scroll does.
  final VoidCallback? onViewMoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mangaProvider);
    final reader = ref.read(mangaProvider.notifier);
    final urls = data?.urls ?? const <String>[];
    final gap = state.pageGap.toDouble();

    final pages = switch (state.readMode) {
      MangaReadMode.standard || MangaReadMode.rightToLeft => _PagedPages(
        urls: urls,
        state: state,
        gap: gap,
        reverse: state.readMode == MangaReadMode.rightToLeft,
        pageController: reader.pageController,
        onPageChanged: reader.setPageNumber,
        onStep: reader.stepPage,
        onTapCenter: onTapCenter,
        onViewMoved: onViewMoved,
      ),
      MangaReadMode.webToon => _WebtoonPages(
        urls: urls,
        state: state,
        gap: gap,
        mangaProvider: mangaProvider,
        onViewMoved: onViewMoved,
      ),
    };

    return _Canvas(
      background: canvasColor(state.canvasBackground),
      child: pages,
    );
  }

  /// Resolves a [MangaCanvasBackground] to a concrete paint colour.
  static Color canvasColor(MangaCanvasBackground background) =>
      switch (background) {
        MangaCanvasBackground.black => Colors.black,
        MangaCanvasBackground.darkGray => const Color(0xFF1E1E1E),
        MangaCanvasBackground.light => Colors.white,
      };
}

/// Canvas colour, owned by the viewport.
///
/// It is deliberately **full-bleed**: it pads nothing, so the first and last
/// page reach the screen edges. The page gap is breathing room *between* pages
/// and each mode applies it there instead — padding the canvas left a dead band
/// at the top and bottom of a webtoon that the artwork could never fill.
///
/// There is deliberately **no brightness scrim here**. "Page Brightness" is
/// applied to the device display by the reader shell via `ScreenBrightness`, so
/// painting a second, full-page black overlay on top of the artwork only
/// produced a permanent grey tint over every page.
class _Canvas extends StatelessWidget {
  const _Canvas({required this.background, required this.child});

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: background, child: child);
  }
}

class _PagedPages extends HookConsumerWidget {
  const _PagedPages({
    required this.urls,
    required this.state,
    required this.gap,
    required this.reverse,
    required this.pageController,
    required this.onPageChanged,
    required this.onStep,
    required this.onTapCenter,
    this.onViewMoved,
  });

  final List<String> urls;
  final MangaReaderState state;

  /// Vertical breathing room around the page, kept inside the canvas so the
  /// canvas colour still fills the screen.
  final double gap;

  final bool reverse;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onStep;
  final VoidCallback onTapCenter;
  final VoidCallback? onViewMoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The page turn resets the magnification, so the surface needs a handle on
    // the zoom; there is nothing else stateful here to justify a State class.
    final pageZoom = useMemoized(ReaderZoomController.new, const []);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: gap),
      child: ReaderZoomSurface(
        controller: pageZoom,
        // A page fills the viewport, so that is also the content a magnified
        // page is panned around: the reader can reach the edges of the page and
        // no further, never the neighbouring one.
        contentSize: (viewport) => viewport,
        onViewMoved: onViewMoved,
        builder: (context, zoom) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          // Always installed: the centre tap is how the HUD is dismissed and
          // summoned, so it must work even when edge paging is switched off.
          onTapUp: (details) => _onTap(context, details.localPosition, onStep),
          child: PageView.builder(
            reverse: reverse,
            controller: pageController,
            // Swiping pages is a one-finger gesture, so it belongs to the page
            // view until the reader zooms in; from then on the same drag pans
            // the magnified page instead of turning it.
            physics: zoom.scrollingEnabled
                ? null
                : const NeverScrollableScrollPhysics(),
            itemCount: urls.length,
            itemBuilder: (context, index) => zoom.wrap(
              MangaImage(
                imageUrl: urls[index],
                fit: switch (state.fitMode) {
                  MangaFitMode.fitWidth => .fitWidth,
                  MangaFitMode.fitHeight => .fitHeight,
                  MangaFitMode.original => .none,
                },
                invertColors: state.invertColors,
              ),
            ),
            onPageChanged: (index) {
              onPageChanged(index);
              // A new page starts unzoomed: leaving the magnification behind
              // would mean stepping into a cropped fragment of it.
              pageZoom.reset();
            },
          ),
        ),
      ),
    );
  }

  /// Edge zones page, the middle toggles the HUD. The centre tap is
  /// unconditional; only the edges obey [MangaReaderState.tapToTurnPage], so
  /// switching edge paging off still leaves a way to bring the overlay back.
  void _onTap(BuildContext context, Offset position, ValueChanged<int> onStep) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= 0) return;
    final fromStart = position.dx / width;
    if (!state.tapToTurnPage) {
      onTapCenter();
      return;
    }
    if (fromStart < kReaderTapZoneExtent) {
      onStep(-1);
    } else if (fromStart > 1 - kReaderTapZoneExtent) {
      onStep(1);
    } else {
      onTapCenter();
    }
  }
}

class _WebtoonPages extends ConsumerWidget {
  const _WebtoonPages({
    required this.urls,
    required this.state,
    required this.gap,
    required this.mangaProvider,
    this.onViewMoved,
  });

  final List<String> urls;
  final MangaReaderState state;
  final double gap;
  final MangaReaderProvider mangaProvider;
  final VoidCallback? onViewMoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reader = ref.read(mangaProvider.notifier);
    // Zoom is a paint-only transform over the list rather than an
    // InteractiveViewer wrapper: the viewer's pan/scale recognisers would win
    // the gesture arena against the list's own drag and stop the webtoon
    // scrolling. A centre tap still summons/dismisses the HUD.
    return WebtoonZoomSurface(
      itemPositionsListener: reader.itemPositionsListener,
      scrollOffsetController: reader.scrollOffsetController,
      scrollOffsetListener: reader.scrollOffsetListener,
      itemScrollController: reader.itemScrollController,
      onTap: reader.toggleHud,
      onViewMoved: onViewMoved,
      itemCount: urls.length,
      // The gap belongs *between* pages, not around the list: a trailing pad on
      // every page but the last separates them while letting the first page
      // start at the top edge and the last one run to the bottom edge. Padding
      // the list itself left a blank band the artwork never covered.
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: index == urls.length - 1 ? 0 : gap),
        child: MangaImage(
          imageUrl: urls[index],
          fit: .fitWidth,
          invertColors: state.invertColors,
        ),
      ),
    );
  }
}
