import 'dart:async';

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
  VoidCallback? _reanchor;

  /// Whether the view is currently magnified.
  bool get isZoomed => _isZoomed;

  bool _isZoomed = false;

  /// Returns to 1x with no translation, as if the view were never zoomed.
  void reset() => _reset?.call();

  /// Re-frames a magnified view after a programmatic jump (scrubber, page
  /// step): the scale and the horizontal pan stay, the vertical translation
  /// resets so the viewport top shows the page the jump landed on — not
  /// stale translated content from before the jump.
  ///
  /// No-op at 1x, so ordinary (unmagnified) jumps are untouched.
  void reanchor() => _reanchor?.call();
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
/// transform, because a list has no sideways scroll — and on release it keeps
/// the drag's velocity on the platform's own deceleration, coasting and
/// settling like the vertical does instead of stopping dead. At the content's
/// horizontal edges the coast is hard-clipped: it loses its velocity at the
/// bound rather than overshooting past it and springing back.
///
/// A double tap toggles the magnification: from the fitted view it animates to
/// [ReaderZoomSurface.doubleTapScale] around the tapped point — whose content
/// stays under the finger — and from any magnified view it animates straight
/// back to 1x. Tap and double tap share the framework's own disambiguation, so
/// a single tap resolves only once the double-tap window has closed (the same
/// bargain every reader offering both makes), while a double tap never leaks
/// the single-tap action.
///
/// **Once the view is magnified the double-tap recogniser is disarmed**: the
/// window made every HUD toggle land ~300 ms after the lift, and the second
/// quick tap of an impatient reader hid what the first had just shown — the
/// "the HUD appears and instantly disappears" report. While zoomed, taps
/// resolve the moment the finger lifts, and un-zooming is the pinch's job
/// (converging fingers clamp at the min scale and hand the drag back).
class ReaderZoomSurface extends StatefulWidget {
  const ReaderZoomSurface({
    super.key,
    required this.builder,
    this.onTapUp,
    this.doubleTapEnabled = true,
    this.doubleTapScale = 2.5,
    this.onScaleChanged,
    this.minScale = 1,
    this.maxScale = 4,
    this.scrollOffset,
    this.onVerticalScroll,
    this.onViewMoved,
    this.scrollExtent,
    this.contentSize,
    this.contentOrigin,
    this.controller,
  });

  /// Builds the content to be transformed. [zoom] is rebuilt whenever the zoom
  /// changes; call [ReaderZoom.wrap] on whatever should be magnified and read
  /// [ReaderZoom.scrollingEnabled] to decide the scrollable's physics.
  final Widget Function(BuildContext context, ReaderZoom zoom) builder;

  /// Fired on a tap that was not a drag, with the tap's position in the
  /// surface's own coordinates, so the reader can apply its tap zones.
  final ValueChanged<Offset>? onTapUp;

  /// Whether a double tap toggles the magnification. False hands every tap to
  /// [onTapUp] the moment the finger lifts — with the recogniser registered,
  /// each tap waits out the double-tap window first, which is why the reader's
  /// HUD toggle felt dead while the overlay was up: a second quick tap then
  /// read as a double tap and zoomed instead of dismissing.
  final bool doubleTapEnabled;

  /// Scale a double tap toggles to, clamped into [minScale]..[maxScale]. A
  /// second double tap always returns to [minScale] with no translation.
  final double doubleTapScale;

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

  /// Content-space offset of the topmost scrollable position — the scroll
  /// offset's lower bound, negative when the inner scrollable is anchored
  /// mid-list (an anchored list measures pixels against its anchor item, so
  /// everything scrolled up into above the anchor lives at negative offsets).
  ///
  /// The zoom's origin math and clamps must honour this range: clamping the
  /// origin at 0 when the reader is inside a prepended chapter snaps the
  /// magnified view back to the anchor — the "zoom above the anchor shows
  /// the wrong area / goes black" bug.
  final double Function()? contentOrigin;

  final ReaderZoomController? controller;

  @override
  State<ReaderZoomSurface> createState() => _ReaderZoomSurfaceState();
}

class _ReaderZoomSurfaceState extends State<ReaderZoomSurface>
    with TickerProviderStateMixin {
  /// Live pointers, oldest first. Only the first two take part in a gesture.
  final Map<int, Offset> _pointers = {};

  final Map<int, Offset> _downAt = {};

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

  /// The horizontal half of the same coast: a flick sideways leaves the
  /// transform with the drag's velocity, decelerating on the platform's own
  /// curve exactly like the vertical does, instead of stopping dead the
  /// moment the finger does.
  late final AnimationController _hFling = AnimationController.unbounded(
    vsync: this,
  )..addListener(_stepHFling);

  /// Content-space view-origin x the horizontal coast was last applied at.
  double _hFlingPosition = 0;

  /// Far edge the running horizontal coast is clipped to, the same value the
  /// simulation was given. The step clamps to it: the coast loses its velocity
  /// at the bound instead of overshooting into the black beyond the content
  /// and springing back.
  double _hFlingTrailingExtent = 0;

  /// Pan velocity for the current gesture, tracked exactly the way the
  /// framework tracks a drag — so a flick carries the momentum an ordinary
  /// scroll of the same speed would.
  VelocityTracker? _panVelocity;

  /// Drives the animated half of the double-tap zoom, so the view glides
  /// between the fitted and the magnified state instead of jumping.
  late final AnimationController _zoomAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..addListener(_stepZoomAnim);

  /// Endpoints of the running zoom animation, captured when it starts so a
  /// touch that interrupts it continues from wherever it had reached.
  double _zoomFromScale = 1;
  Offset _zoomFromTranslate = Offset.zero;
  double _zoomToScale = 1;
  Offset _zoomToTranslate = Offset.zero;

  /// Where a confirmed double tap wants its zoom, captured on the second
  /// tap's down and spent by its up; a cancelled second tap clears it.
  Offset? _doubleTapFocal;

  double get _minScale => widget.minScale;

  /// True from a gesture's second finger down until the last finger lifts: a
  /// pinched gesture's finger lifts must never read as taps (the raw
  /// instant-tap path in [_onPointerUp]) nor seed the double-tap recogniser.
  bool _gesturePinched = false;

  /// A zoomed tap fires once the double-tap window closes, so a double tap
  /// (which un-zooms) never triggers the HUD. A second tap's down or a new
  /// gesture cancels the pending fire.
  Timer? _pendingTapFire;
  Offset? _pendingTapAt;

  /// Set by the double-tap recogniser's down (which dispatches before this
  /// Listener's) and consumed by [_onPointerDown]: the gesture is a double
  /// tap's second tap, so its lift must not schedule a HUD fire either.
  bool _pendingSecondTap = false;
  bool _gestureIsDoubleTap = false;

  void _cancelPendingTapFire() {
    _pendingTapFire?.cancel();
    _pendingTapFire = null;
  }

  bool get _zoomed => _scale > _minScale;

  @override
  void initState() {
    super.initState();
    widget.controller?._reset = _reset;
    widget.controller?._reanchor = _reanchor;
  }

  @override
  void didUpdateWidget(ReaderZoomSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._reset = null;
      oldWidget.controller?._reanchor = null;
      widget.controller?._reset = _reset;
      widget.controller?._reanchor = _reanchor;
    }
  }

  void _reset() {
    _stopZoomAnim();
    if (!mounted) return;
    if (!_zoomed && _translate == Offset.zero) return;
    setState(() {
      _scale = widget.minScale;
      _translate = Offset.zero;
    });
    widget.onScaleChanged?.call(_scale);
  }

  /// Re-frames a magnified view after a programmatic jump: the scale and the
  /// horizontal pan stay, the vertical translation resets so the viewport top
  /// shows the page the jump landed on. At 1x this is a no-op — the paint is
  /// already the list's own offset.
  void _reanchor() {
    if (!mounted || !_zoomed) return;
    _stopFling();
    _stopZoomAnim();
    setState(() {
      _translate = Offset(_translate.dx, 0);
    });
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
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            // While magnified the raw pointer path detects taps instantly
            // (_onPointerUp): the tap recogniser here would hold the arena
            // for the double-tap window, delaying every HUD toggle by 300 ms
            // and letting the next contact dismiss what the tap had shown.
            // The build-time gate alone is stale (a build before the pinch
            // leaves the recogniser armed), so the callback re-checks: while
            // magnified the raw pointer path owns the tap and fires it once.
            onTapUp: widget.onTapUp == null
                ? null
                : (details) {
                    if (_zoomed) return;
                    widget.onTapUp!(details.localPosition);
                  },
            // The focal is captured on the second tap's down but the zoom only
            // starts on its up: the recognizer's callbacks are dispatched
            // before this Listener's own, so a zoom started on the down would
            // be killed by _onPointerDown's animation stop the same instant.
            // While the view is magnified the double-tap recogniser stays
            // armed EVEN when the shell flips [doubleTapEnabled] off for its
            // HUD toggle: the flip landing mid-double-tap disarmed the
            // recogniser, so the zoom-out never fired and the two taps
            // resolved as show-HUD + hide-HUD (the "double click does not
            // zoom out / layout appears then disappears" report). The cost is
            // that a magnified single tap resolves once the window closes
            // (~300 ms after the lift) — the standard double-tap bargain.
            onDoubleTapDown: (widget.doubleTapEnabled || _zoomed)
                ? (details) {
                    _stopFling();
                    _doubleTapFocal = details.localPosition;
                    _pendingSecondTap = true;
                  }
                : null,
            onDoubleTapCancel: (widget.doubleTapEnabled || _zoomed)
                ? () => _doubleTapFocal = null
                : null,
            onDoubleTap: (widget.doubleTapEnabled || _zoomed)
                ? () {
                    final focal = _doubleTapFocal;
                    _doubleTapFocal = null;
                    if (focal != null) _handleDoubleTap(focal);
                  }
                : null,
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
  ///
  /// The vertical origin range starts at [ReaderZoomSurface.contentOrigin]
  /// (negative inside a prepended chapter of an anchored list), not at 0 —
  /// clamping there snapped the magnified view back to the anchor item.
  Offset _clampOrigin(Offset origin, double scale) {
    final content = widget.contentSize?.call(_viewport);
    if (content == null) return origin;
    final minY = widget.contentOrigin?.call() ?? 0.0;
    double axis(
      double value,
      double extent,
      double viewportExtent,
      double min,
    ) {
      final max = (min + extent - viewportExtent / scale).clamp(
        min,
        double.infinity,
      );
      return value.clamp(min, max);
    }

    return Offset(
      axis(origin.dx, content.width, _viewport.width, 0.0),
      axis(origin.dy, content.height, _viewport.height, minY),
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
    if (_pointers.isNotEmpty) _gesturePinched = true;
    // A second tap makes the previous one a double-tap: its pending HUD fire
    // must never happen (the un-zoom double-tap triggered the HUD report),
    // and this second tap's own lift must not schedule a new one either.
    _cancelPendingTapFire();
    _gestureIsDoubleTap = _pendingSecondTap;
    _pendingSecondTap = false;
    _pointers[event.pointer] = event.localPosition;
    _downAt[event.pointer] = event.localPosition;
    // A touch means the reader is driving now. Any coast still running has to
    // stop: it would otherwise fight the pan for every move, and — because the
    // fling controller is still animating — the *next* flick would find it busy
    // and be given no inertia of its own. That is what made a scroll after a
    // coast stop dead where the first one sailed. The zoom animation is
    // interrupted the same way: the gesture re-bases from wherever the view
    // had reached.
    _stopFling();
    _stopZoomAnim();
    _rebase();
    // The second finger pins the scrollable, so the physics have to change
    // before the gesture can move anything.
    if (mounted) setState(() {});
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.localPosition;

    // A single finger belongs to the scrollable until the view is zoomed; after
    // that the gesture pans the view.
    final pinching = _pointers.length >= 2;
    if (!pinching && !_zoomed) return;

    // The flick's release velocity includes the approach, but sub-slop drift
    // is a tap, not a pan: it must not move the view or dismiss the HUD.
    if (!pinching) _trackPanVelocity(event);
    final downAt = _downAt[event.pointer];
    if (!pinching &&
        downAt != null &&
        (event.localPosition - downAt).distance < kTouchSlop) {
      return;
    }

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
        // The vertical splits between the inner scrollable and the paint: the
        // scrollable can only express the UNZOOMED range [0, maxScrollExtent],
        // so freezing the translation here made everything above/below a
        // zoomed window unreachable — zoom the lower half of a strip and the
        // top of the content could never be scrolled to. The scrollable moves
        // as far as it can toward the clamped target origin, and the paint
        // translation absorbs whatever it could not express.
        final clamped = _clampOrigin(origin, scale);
        final delta = clamped.dy - _panAnchor.dy;
        // The scrollable only expresses its real range — clamp the move to
        // it and let the paint translation absorb the rest. Feeding jumpTo
        // an out-of-range target forced the position past its floor, where
        // the list cannot render the content above its start: panning up
        // from a zoomed window was bounded at the zoom position. The floor
        // is [contentOrigin], negative above the anchor — without it a
        // magnified pan could never travel up into a prepended chapter.
        final maxScroll = widget.scrollExtent?.call() ?? 0;
        final minScroll = widget.contentOrigin?.call() ?? 0.0;
        final current = _offset;
        final scrollableDelta =
            ((current + delta).clamp(minScroll, maxScroll)) - current;
        if (scrollableDelta != 0) scroll(scrollableDelta);
        _panAnchor = clamped;
        _translate = Offset(
          -scale * clamped.dx,
          scale * (_offset - clamped.dy),
        );
        _trackPanVelocity(event);
        widget.onViewMoved?.call();
        return;
      }
      _translate = _translationFor(scale, origin);
      // The paged path pans in the transform alone; its release velocity is
      // tracked the same way the scrollable path's is, so a sideways flick
      // coasts here too. During a pinch the pointer speed is the fingers',
      // not the view's — it must not become a fling.
      if (!pinching) _trackPanVelocity(event);
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
    final start = _downAt.remove(event.pointer);
    final wasZoomed = _zoomed;
    // A sub-slop lift while magnified IS a tap: fire it instantly (the tap
    // recogniser is disarmed while zoomed) and discard the micro-drift
    // velocity so no coast starts — the coast's synthetic scroll dismissed
    // the HUD the tap had just shown.
    final travel = start == null
        ? null
        : (event.localPosition - start).distance;
    final wasPinch = _gesturePinched;
    if (_pointers.isEmpty) _gesturePinched = false;
    if (_zoomed &&
        !wasPinch &&
        !_gestureIsDoubleTap &&
        travel != null &&
        travel < kTouchSlop) {
      // Fire after the double-tap window: a second tap cancels this, so a
      // double tap (zoom or un-zoom) never triggers the HUD, while a single
      // tap still toggles it. The dismissal race that made this window feel
      // broken (the HUD appearing then instantly hiding) is fixed separately:
      // sub-slop drift neither pans nor starts a coast.
      _pendingTapAt = event.localPosition;
      _cancelPendingTapFire();
      _pendingTapFire = Timer(kDoubleTapTimeout, () {
        final at = _pendingTapAt;
        _pendingTapFire = null;
        if (at != null) widget.onTapUp?.call(at);
      });
      _panVelocity = null;
    }
    // Whatever is left on screen is what the reader keeps looking at, so the
    // gesture re-baselines and the scrollable is handed back on the next build.
    _rebase();
    // A pointer up can land after the canvas was torn down (a chapter flip
    // unmounts it mid-gesture): the ticker teardown is async relative to the
    // widget, so guard the setState rather than crashing on a defunct State.
    if (mounted) setState(() {});
    // The last finger leaving a magnified pan is a flick: let it coast.
    if (_pointers.isEmpty && wasZoomed) _startFling();
  }

  /// Continues a magnified pan with the platform's own friction, so a flick
  /// through a zoomed strip settles like an ordinary scroll instead of stopping
  /// dead the moment the finger does — on both axes: the vertical hands its
  /// coast to the inner scrollable, the horizontal keeps it in the transform.
  void _startFling() {
    final velocity = _panVelocity?.getVelocity().pixelsPerSecond;
    _panVelocity = null;
    if (velocity == null) return;
    _startVerticalFling(velocity.dy);
    _startHorizontalFling(velocity.dx);
  }

  void _startVerticalFling(double pointerDy) {
    final scroll = widget.onVerticalScroll;
    if (scroll == null || _fling.isAnimating) return;
    // A finger travelling up (negative dy) scrolls forward, which is a positive
    // content velocity — the opposite sign to the pointer's own.
    final velocity = -pointerDy / _scale;
    // Below this it is a drag, not a flick.
    if (velocity.abs() < 120) return;
    _flingPosition = _offset;
    _fling.value = _flingPosition;
    // The platform's own deceleration, so a flick through a zoomed strip coasts
    // exactly as long as an ordinary scroll would.
    final minScroll = widget.contentOrigin?.call() ?? 0.0;
    _fling.animateWith(
      BouncingScrollSimulation(
        spring: SpringDescription.withDampingRatio(
          mass: 0.5,
          stiffness: 100,
          ratio: 1.1,
        ),
        position: _flingPosition,
        velocity: velocity,
        leadingExtent: minScroll,
        trailingExtent: widget.scrollExtent?.call() ?? double.infinity,
        tolerance: Tolerance.defaultTolerance,
      ),
    );
  }

  void _startHorizontalFling(double pointerDx) {
    if (_hFling.isAnimating) return;
    // Same sign convention as the vertical: the view origin moves against the
    // finger, so the content keeps travelling the way the drag was heading.
    final velocity = -pointerDx / _scale;
    if (velocity.abs() < 120) return;
    final content = widget.contentSize?.call(_viewport);
    _hFlingPosition = _viewOrigin.dx;
    _hFlingTrailingExtent = content == null
        ? double.infinity
        : (content.width - _viewport.width / _scale).clamp(
            0.0,
            double.infinity,
          );
    _hFling.value = _hFlingPosition;
    _hFling.animateWith(
      BouncingScrollSimulation(
        spring: SpringDescription.withDampingRatio(
          mass: 0.5,
          stiffness: 100,
          ratio: 1.1,
        ),
        position: _hFlingPosition,
        velocity: velocity,
        leadingExtent: 0,
        // Hard-clipped in _stepHFling at this edge: the coast stops dead at
        // the bound rather than overshooting and springing back.
        trailingExtent: _hFlingTrailingExtent,
        tolerance: Tolerance.defaultTolerance,
      ),
    );
  }

  void _stopFling() {
    if (_fling.isAnimating) _fling.stop();
    if (_hFling.isAnimating) _hFling.stop();
    _panVelocity = null;
  }

  void _stepFling() {
    // A tick can land after dispose (ticker teardown is async relative to
    // the widget): never setState on a defunct state.
    if (!mounted) return;
    final next = _fling.value;
    final delta = next - _flingPosition;
    _flingPosition = next;
    if (delta != 0) widget.onVerticalScroll?.call(delta);
  }

  void _stepHFling() {
    if (!mounted) return;
    var next = _hFling.value;
    // Hard clip: outside the content the coast loses its velocity — the view
    // freezes at the bound instead of painting the black beyond it and
    // springing back. Leading edge and far edge, symmetrically.
    final clipped = next.clamp(0.0, _hFlingTrailingExtent);
    if (clipped != next) {
      _hFling.stop();
      next = clipped;
    }
    if (next == _hFlingPosition) return;
    _hFlingPosition = next;
    setState(() {
      _translate = Offset(-_scale * next, _translate.dy);
    });
  }

  /// The double-tap toggle: a magnified view is given back whole, and a fitted
  /// one is magnified around the tapped point, whose content stays under the
  /// finger while the view grows.
  void _handleDoubleTap(Offset focal) {
    _stopFling();
    _stopZoomAnim();
    if (_zoomed) {
      _animateZoom(_minScale, Offset.zero);
      return;
    }
    final target = widget.doubleTapScale.clamp(_minScale, widget.maxScale);
    // Painted position = content * scale + translate, so rebuilding the
    // translation for [target] from the content currently under the tap keeps
    // that content painting under it. The y origin is expressed against the
    // scrollable's offset, exactly like the gesture-derived one.
    final content = (focal - _translate) / _scale;
    final origin = Offset(
      content.dx - focal.dx / target,
      _offset + content.dy - focal.dy / target,
    );
    _animateZoom(target, _translationFor(target, origin));
  }

  void _animateZoom(double scale, Offset translate) {
    _zoomFromScale = _scale;
    _zoomFromTranslate = _translate;
    _zoomToScale = scale;
    _zoomToTranslate = translate;
    _zoomAnim.forward(from: 0);
  }

  void _stepZoomAnim() {
    // The animation's last tick can land after dispose — never setState on
    // a defunct state.
    if (!mounted) return;
    final t = Curves.easeOutCubic.transform(_zoomAnim.value);
    final nextScale = _zoomFromScale + (_zoomToScale - _zoomFromScale) * t;
    final nextTranslate = Offset.lerp(_zoomFromTranslate, _zoomToTranslate, t)!;
    if (nextScale == _scale && nextTranslate == _translate) return;
    setState(() {
      _scale = nextScale;
      _translate = nextTranslate;
    });
    widget.onScaleChanged?.call(_scale);
  }

  void _stopZoomAnim() {
    if (_zoomAnim.isAnimating) _zoomAnim.stop();
  }

  @override
  void dispose() {
    _cancelPendingTapFire();
    _stopFling();
    _stopZoomAnim();
    _fling.dispose();
    _hFling.dispose();
    _zoomAnim.dispose();
    widget.controller?._reset = null;
    widget.controller?._reanchor = null;
    super.dispose();
  }
}
