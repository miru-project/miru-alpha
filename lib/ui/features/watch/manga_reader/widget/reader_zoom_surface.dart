import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

/// Live zoom state handed to [ReaderZoomSurface.builder], so the scrollable
/// inside can decide whether it is still allowed to drag.
@immutable
class ReaderZoom {
  const ReaderZoom({
    required this.scale,
    required this.translate,
    required this.scrollingEnabled,
  });

  final double scale;
  final Offset translate;

  /// False while a pinch or a pan owns the gesture, and whenever the view is
  /// zoomed. The framework folds a second pointer's movement into the same drag
  /// as the first, so leaving the scrollable live would move the content twice —
  /// once through the scrollable and once through the transform — and would
  /// leave the recorded reading position describing a page the reader never saw.
  final bool scrollingEnabled;

  /// Applies the paint-only transform to [child].
  ///
  /// Never returns [child] bare: dropping the transforms at scale 1 would insert
  /// widgets into the tree on the first gesture, remounting the scrollable and
  /// throwing away the reading position.
  Widget wrap(Widget child) => Transform.translate(
    offset: translate,
    child: Transform.scale(scale: scale, alignment: .topLeft, child: child),
  );
}

/// Imperative handle on a [ReaderZoomSurface], for the cases where something
/// outside the gesture has to give the view back: turning a page while zoomed,
/// for instance, should not leave the next page magnified.
class ReaderZoomController {
  VoidCallback? _reset;

  /// Whether the view is currently magnified.
  bool get isZoomed => _isZoomed;

  bool _isZoomed = false;

  /// Returns to 1x with no translation, as if the view were never zoomed.
  void reset() => _reset?.call();
}

/// The reader's hybrid zoom: pinch to scale and drag to pan, both applied as a
/// **paint-only** transform, with the inner scrollable keeping its own drag when
/// the view is not zoomed.
///
/// Wrapping a scrollable in an [InteractiveViewer] does not work here: that
/// widget installs pan and scale recognisers into the same gesture arena as the
/// scrollable's own drag, the viewer's pan wins, and the reader silently stops
/// scrolling. `Transform.scale` / `Transform.translate` only affect painting, so
/// at 1x the list or page view still does all the moving.
///
/// The zoom is expressed as a *view origin* — the content point currently shown
/// at the viewport's top-left corner — from which the paint translation is
/// derived. Every gesture moves that origin by
/// `focal_at_start / scale_at_start - focal_now / scale`, which is the same
/// expression for a pinch and for a drag: it leaves the content under the
/// fingers under the fingers, in both axes, whether the fingers are converging,
/// spreading or travelling together. The scrollable's own offset is never
/// touched, so nothing is clamped or jumped out from under the fingers.
///
/// A single finger belongs to the scrollable while the view is at 1x and to the
/// view once it is zoomed, which is what makes a magnified page pannable instead
/// of only scrollable. The vertical half of that pan is handed to the inner
/// scrollable through [onVerticalScroll] — a transform cannot build content, so a
/// pan that only moved the paint would walk the view off the window the list
/// laid out and leave the screen black. The horizontal half stays in the
/// transform, because a list has no sideways scroll.
class ReaderZoomSurface extends StatefulWidget {
  const ReaderZoomSurface({
    super.key,
    required this.builder,
    this.onTap,
    this.onScaleChanged,
    this.minScale = 1,
    this.maxScale = 4,
    this.scrollOffset,
    this.onVerticalScroll,
    this.onViewMoved,
    this.scrollExtent,
    this.contentSize,
    this.controller,
  });

  /// Builds the content to be transformed. [zoom] is rebuilt whenever the zoom
  /// changes; call [ReaderZoom.wrap] on whatever should be magnified and read
  /// [ReaderZoom.scrollingEnabled] to decide the scrollable's physics.
  final Widget Function(BuildContext context, ReaderZoom zoom) builder;

  /// Fired on a tap that was not a drag, so the reader can toggle its HUD.
  final VoidCallback? onTap;

  /// Reports the live scale, for tests and for any dependent UI.
  final ValueChanged<double>? onScaleChanged;

  final double minScale;
  final double maxScale;

  /// Current vertical offset of the inner scrollable, if it has one. The paint
  /// translation is derived relative to it, so a programmatic jump moves the
  /// content with the scrollable rather than fighting it.
  final double Function()? scrollOffset;

  /// Where a magnified view's **vertical** movement goes, in content pixels — a
  /// magnified view has to carry the scrollable with it.
  ///
  /// A paint transform cannot build content: the list only lays out the pages
  /// near its own offset, so a pan that only moved the transform would walk the
  /// view off that window and leave the screen black. Handing the vertical to the
  /// scrollable keeps the built window under the view, and keeps the recorded
  /// position honest. The pan divides by the scale on the way in, so the content
  /// still follows the finger 1:1; the [fling] that follows the gesture arrives
  /// in content pixels per second and is expected to carry the same inertia an
  /// ordinary scroll would.
  ///
  /// Null (the default) leaves the vertical in the transform, which is right when
  /// the child is a single box rather than a long list — a paged view, where
  /// there is nothing to scroll and nothing to be inertial about.
  final ValueChanged<double>? onVerticalScroll;

  /// Fired when a gesture moves the view at all — a magnified pan, in either
  /// mode, including a two-finger pan and a flick.
  ///
  /// The reader dismisses its overlay on this, not on a scroll notification: a
  /// magnified view pins its scrollable (`NeverScrollableScrollPhysics`), so the
  /// pan is raw pointer tracking and never produces a drag the notification
  /// stream can see. Without it the HUD stayed up over a page the reader was
  /// actively moving through.
  final VoidCallback? onViewMoved;

  /// Furthest the inner scrollable can scroll, so a fling can come to rest on the
  /// last page instead of being cut off by clamping. Null leaves that to the
  /// scrollable's own bounds.
  final double Function()? scrollExtent;

  /// Size of the content behind the viewport in logical px, used to keep a
  /// panned view inside it; null (the default) means the caller has no bound to
  /// offer and the pan is left free. [paged] hands in the viewport, because a
  /// single page fills it.
  final Size? Function(Size viewport)? contentSize;

  final ReaderZoomController? controller;

  @override
  State<ReaderZoomSurface> createState() => _ReaderZoomSurfaceState();
}

class _ReaderZoomSurfaceState extends State<ReaderZoomSurface>
    with SingleTickerProviderStateMixin {
  /// Live pointers, oldest first. Only the first two take part in a gesture.
  final Map<int, Offset> _pointers = {};

  double _scale = 1;

  /// Paint translation, frozen once the fingers lift so the zoomed view stays
  /// where the gesture left it.
  Offset _translate = Offset.zero;

  /// Gesture baseline, captured whenever the pointer set changes.
  double _startDistance = 0;
  double _startScale = 1;
  Offset _startFocal = Offset.zero;
  Offset _startViewOrigin = Offset.zero;

  /// View origin the last pan move was measured against. The pan is handed to the
  /// scrollable as a *relative* jump, so each move has to carry only what changed
  /// since the previous one.
  Offset _panAnchor = Offset.zero;

  /// Last known viewport, so the clamp does not have to reach for a context
  /// while a finger is down.
  Size _viewport = Size.zero;

  /// Drives the momentum a magnified pan keeps after the fingers lift, so a
  /// flick through a zoomed strip coasts and settles like any other scroll
  /// instead of stopping dead under the finger.
  late final AnimationController _fling = AnimationController.unbounded(
    vsync: this,
  )..addListener(_stepFling);

  /// Position the last fling tick was applied at.
  double _flingPosition = 0;

  /// Pan velocity for the current gesture, tracked exactly the way the
  /// framework tracks a drag — so a flick carries the momentum an ordinary
  /// scroll of the same speed would.
  VelocityTracker? _panVelocity;

  double get _minScale => widget.minScale;

  bool get _zoomed => _scale > _minScale;

  @override
  void initState() {
    super.initState();
    widget.controller?._reset = _reset;
  }

  @override
  void didUpdateWidget(ReaderZoomSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._reset = null;
      widget.controller?._reset = _reset;
    }
  }

  void _reset() {
    if (!_zoomed && _translate == Offset.zero) return;
    setState(() {
      _scale = widget.minScale;
      _translate = Offset.zero;
    });
    widget.onScaleChanged?.call(_scale);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      // The pan is bounded by the surface's *own* box, not the screen: the
      // reader's canvas is inset by the page gap, and a test may mount it
      // smaller than the window.
      builder: (context, constraints) {
        final biggest = constraints.biggest;
        _viewport = biggest.isFinite ? biggest : MediaQuery.sizeOf(context);
        widget.controller?._isZoomed = _zoomed;
        final zoom = ReaderZoom(
          scale: _scale,
          translate: _translate,
          scrollingEnabled: !_zoomed && _pointers.length < 2,
        );
        return Listener(
          // Never consumes: the scrollable's drag recognisers must keep winning
          // the arena, and this only observes the raw pointers.
          behavior: HitTestBehavior.translucent,
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerUp,
          child: _TapWrapper(
            onTap: widget.onTap,
            child: widget.builder(context, zoom),
          ),
        );
      },
    );
  }

  /// Midpoint of the pointers taking part in the gesture: the single finger
  /// itself when there is one, the average of the first two when there are more.
  Offset get _focal {
    if (_pointers.isEmpty) return Offset.zero;
    final first = _pointers.values.elementAt(0);
    if (_pointers.length < 2) return first;
    final second = _pointers.values.elementAt(1);
    return Offset((first.dx + second.dx) / 2, (first.dy + second.dy) / 2);
  }

  double get _focalDistance {
    if (_pointers.length < 2) return 0;
    return (_pointers.values.elementAt(1) - _pointers.values.elementAt(0))
        .distance;
  }

  double get _offset => widget.scrollOffset?.call() ?? 0;

  /// Content point currently shown at the viewport's top-left corner, i.e. the
  /// state the transform is derived from rather than stored.
  Offset get _viewOrigin =>
      Offset(-_translate.dx / _scale, _offset - _translate.dy / _scale);

  /// The view origin this gesture is asking for: the content under the fingers
  /// stays under them, whether the fingers are converging, spreading or simply
  /// travelling together.
  Offset get _gestureOrigin =>
      _startViewOrigin + _startFocal / _startScale - _focal / _scale;

  /// Translation for a view whose top-left content point is [origin].
  Offset _translationFor(double scale, Offset origin) {
    // Nothing to pan at rest, so a gesture that has not magnified anything must
    // not shift the page.
    if ((scale - _minScale).abs() < 0.001) return Offset.zero;
    final clamped = _clampOrigin(origin, scale);
    return Offset(-scale * clamped.dx, scale * (_offset - clamped.dy));
  }

  /// Keeps the magnified window inside the content, so a page can never be
  /// dragged out of sight and leave the reader staring at a blank canvas.
  Offset _clampOrigin(Offset origin, double scale) {
    final content = widget.contentSize?.call(_viewport);
    if (content == null) return origin;
    double axis(double value, double extent, double viewportExtent) =>
        value.clamp(
          0.0,
          (extent - viewportExtent / scale).clamp(0.0, double.infinity),
        );
    return Offset(
      axis(origin.dx, content.width, _viewport.width),
      axis(origin.dy, content.height, _viewport.height),
    );
  }

  /// Captures the baseline for the pointers that are down now. Called on every
  /// down and up so a gesture that starts with one finger and grows into a pinch
  /// — or loses a finger — continues from exactly where the view already is.
  void _rebase() {
    _startScale = _scale;
    _startFocal = _focal;
    _startDistance = _focalDistance;
    _startViewOrigin = _viewOrigin;
    _panAnchor = _startViewOrigin;
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.localPosition;
    // A touch means the reader is driving now. Any coast still running has to
    // stop: it would otherwise fight the pan for every move, and — because the
    // fling controller is still animating — the *next* flick would find it busy
    // and be given no inertia at all. That is what made a second scroll in a
    // row stop dead where the first one coasted.
    // A touch means the reader is driving now. Any coast still running has to
    // stop: it would otherwise fight the pan for every move, and — because the
    // fling controller is still animating — the *next* flick would find it busy
    // and be given no inertia of its own. That is what made a scroll after a
    // coast stop dead where the first one sailed.
    _stopFling();
    _rebase();
    // The second finger pins the scrollable, so the physics have to change
    // before the gesture can move anything.
    setState(() {});
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.localPosition;

    // A single finger belongs to the scrollable until the view is zoomed; after
    // that the gesture pans the view.
    final pinching = _pointers.length >= 2;
    if (!pinching && !_zoomed) return;

    var scale = _scale;
    if (pinching) {
      final distance = _focalDistance;
      if (_startDistance <= 0 || distance <= 0) return;
      scale = (_startScale * distance / _startDistance).clamp(
        _minScale,
        widget.maxScale,
      );
      if ((scale - _scale).abs() > 0.0001) widget.onScaleChanged?.call(scale);
    }

    setState(() {
      _scale = scale;
      final origin = _gestureOrigin;
      final scroll = widget.onVerticalScroll;
      if (!pinching && scroll != null) {
        // The vertical goes to the inner scrollable so the content it has built
        // follows the view; the horizontal stays in the transform, because a
        // list has no sideways scroll. The vertical translation then stays where
        // the pinch left it and the view origin follows the new offset.
        final delta = origin.dy - _panAnchor.dy;
        scroll(delta);
        _panAnchor = origin;
        final dx = _clampOrigin(Offset(origin.dx, 0), scale).dx;
        _translate = Offset(-scale * dx, _translate.dy);
        _trackPanVelocity(event);
        widget.onViewMoved?.call();
        return;
      }
      _translate = _translationFor(scale, origin);
      widget.onViewMoved?.call();
    });
  }

  void _trackPanVelocity(PointerEvent event) {
    (_panVelocity ??= VelocityTracker.withKind(
      event.kind,
    )).addPosition(event.timeStamp, event.localPosition);
  }

  void _onPointerUp(PointerEvent event) {
    _pointers.remove(event.pointer);
    final wasZoomed = _zoomed;
    // Whatever is left on screen is what the reader keeps looking at, so the
    // gesture re-baselines and the scrollable is handed back on the next build.
    _rebase();
    setState(() {});
    // The last finger leaving a magnified pan is a flick: let it coast.
    if (_pointers.isEmpty && wasZoomed) _startFling();
  }

  /// Continues a magnified pan with the platform's own friction, so a flick
  /// through a zoomed strip settles like an ordinary scroll instead of stopping
  /// dead the moment the finger does.
  void _startFling() {
    final scroll = widget.onVerticalScroll;
    // A finger travelling up (negative dy) scrolls forward, which is a positive
    // content velocity — the opposite sign to the pointer's own.
    final velocity = _panVelocity == null
        ? null
        : -_panVelocity!.getVelocity().pixelsPerSecond.dy / _scale;
    _panVelocity = null;
    if (scroll == null || velocity == null || _fling.isAnimating) return;
    // Divided by the scale above: a 2000 px/s flick of a page magnified 3x is
    // ~660 px/s of content. Below this it is a drag, not a flick.
    if (velocity.abs() < 120) return;
    _flingPosition = _offset;
    _fling.value = _flingPosition;
    // The platform's own deceleration, so a flick through a zoomed strip coasts
    // exactly as long as an ordinary scroll would.
    _fling.animateWith(
      BouncingScrollSimulation(
        spring: SpringDescription.withDampingRatio(
          mass: 0.5,
          stiffness: 100,
          ratio: 1.1,
        ),
        position: _flingPosition,
        velocity: velocity,
        leadingExtent: 0,
        trailingExtent: widget.scrollExtent?.call() ?? double.infinity,
        tolerance: Tolerance.defaultTolerance,
      ),
    );
  }

  void _stopFling() {
    if (_fling.isAnimating) _fling.stop();
    _panVelocity = null;
  }

  void _stepFling() {
    final next = _fling.value;
    final delta = next - _flingPosition;
    _flingPosition = next;
    if (delta != 0) widget.onVerticalScroll?.call(delta);
  }

  @override
  void dispose() {
    _fling.dispose();
    widget.controller?._reset = null;
    super.dispose();
  }
}

/// A tap (rather than a drag) on the page.
class _TapWrapper extends StatelessWidget {
  const _TapWrapper({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: (_) => onTap!(),
      child: child,
    );
  }
}
