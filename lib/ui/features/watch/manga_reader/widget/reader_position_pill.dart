import 'dart:async';
import 'dart:math' as math;

import 'package:forui/forui.dart';

import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// Snap targets for the draggable progress pill.
///
/// `line` is the screen's vertical center line — the pill can rest anywhere
/// along the segment bounded by the top and bottom safe-area paddings (plus
/// edge extras). The two bottom anchors pin the pill flush to the physical
/// bottom edge with no inset at all. The top corners were removed: flush with
/// the screen top the pill clipped into the punch-hole / status area and read
/// as broken.
enum ReaderPillAnchor { line, bottomLeft, bottomRight }

/// Minimum touch target for the pill region (Material + iOS guidance).
const double _pillTouchTarget = 48.0;

/// Side-to-side breathing room against the screen edge.
const double _pillEdgeInset = 12.0;

/// Extra bottom padding above the system navigation area so the pill never
/// sits where a nav gesture might land.
const double _pillBottomExtra = 16.0;

/// Extra top padding below the status bar so the pill clears the punch-hole
/// while it is draggable there.
const double _pillTopExtra = 8.0;

/// How long the snap animation lasts; `Curves.easeOutCubic` mirrors the rest
/// of the reader's transition easing.
const Duration _pillSnapDuration = Duration(milliseconds: 320);

/// Resting corner radius (pill look) and the flush rectangle radius the four
/// corners ease toward as the pill approaches them.
const double _pillRadius = 16.0;

/// Touch/drag hit height while resting at a bottom corner: the bottom
/// safe-area (system navigation) inset plus 44 dp, floored at the standard
/// 48 dp touch target.
const double _cornerHitExtra = 44.0;

/// Draggable version of the reader's minimal progress pill.
///
/// The pill is positioned in pixels inside the reader's full-bleed `Stack`
/// and driven by a single position state: `_dragPos` while the finger is
/// down, an `AnimationController` ease (`Curves.easeOutCubic`) from the
/// release point to the snap target on release, and the persisted rest
/// position otherwise. No `AnimatedAlign` + `Transform` pair — that
/// combination teleported the pill back to the old anchor for one frame.
///
/// Snap resolution is proximity based: the two bottom corner rest positions
/// versus the closest point on the vertical center line (y clamped into the
/// safe-area segment). Nearest candidate wins.
///
/// While dragging or settling, the border radius eases from the pill value
/// toward the flush rectangle corner value, but only when the nearest snap
/// candidate is a corner — the morph never fires on the line.
///
/// HUD-hidden state is the only drag target; while the HUD is open this
/// widget lays the pill down decoratively and takes nothing.
class ReaderPositionPill extends StatefulWidget {
  const ReaderPositionPill({
    super.key,
    required this.childBuilder,
    required this.isolated,
  });

  /// [borderRadius] is the live proximity radius, [compact] is true while the
  /// pill is docked at a side (the card drops the chapter title and the
  /// percentage), and [showGrip] is true while the tap affordance is up.
  final Widget Function(double borderRadius, bool compact, bool showGrip)
  childBuilder;

  /// When true, the pill renders decoratively (no gesture arena entry).
  final bool isolated;

  /// Touch/drag hit height while resting at a bottom corner: the bottom
  /// safe-area (system navigation) inset plus 44 dp, floored at the
  /// standard 48 dp touch target.
  static double cornerHitHeight(double bottomInset) =>
      math.max(_pillTouchTarget, bottomInset + _cornerHitExtra);

  @override
  State<ReaderPositionPill> createState() => _ReaderPositionPillState();
}

class _ReaderPositionPillState extends State<ReaderPositionPill>
    with SingleTickerProviderStateMixin {
  late ReaderPillAnchor _anchor;

  /// Rest position along `line`: 0 = top end of the segment, 1 = bottom end.
  double _lineFraction = 1.0;

  Offset? _dragPos;
  Offset? _settleFrom;
  late final AnimationController _settleController;

  /// Tap affordance: a knob on the card plus an outline over the real drag
  /// area, so the pill's grab region is visible rather than implied.
  bool _hintVisible = false;
  Timer? _hintTimer;

  /// Press-and-hold at a corner: the card expands to the full readout until
  /// the press ends. A quick tap never sets it (long-press only), so a tap
  /// keeps the compact size and only flashes the notch.
  bool _pressed = false;

  /// Last pointer position seen during a drag. Deltas are measured against
  /// this rather than `DragUpdateDetails.delta`, because adding a tap
  /// recogniser to the same detector makes Flutter swallow the delta of the
  /// event that wins the arena — a fast flick would lose its first chunk and
  /// the pill would lag behind the finger.
  Offset? _lastPointer;

  /// Pointer-down position for the current drag. A drag that wins the arena
  /// late (the tap recogniser holds it until the first move) reports its
  /// start position after the finger has already travelled, so that travel is
  /// recovered from this and applied at drag start.
  Offset? _panDownPos;

  Size _pillSize = const Size(200, 48);
  final GlobalKey _pillKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _settleController = AnimationController(
      vsync: this,
      duration: _pillSnapDuration,
    );
    _settleController.addListener(() => setState(() {}));
    _settleController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _settleFrom != null) {
        // Resting geometry takes over exactly; the tween is discarded.
        setState(() => _settleFrom = null);
      }
    });
    final persisted = _readPersisted();
    _anchor = persisted.$1;
    _lineFraction = persisted.$2;
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _settleController.dispose();
    super.dispose();
  }

  void _flashHint() {
    _hintTimer?.cancel();
    setState(() => _hintVisible = true);
    _hintTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _hintVisible = false);
    });
  }

  (ReaderPillAnchor, double) _readPersisted() {
    try {
      final raw = MiruSettings.getSettingSync<String>(
        SettingKey.readerPillAnchor,
      );
      // Legacy names: the old bottom-center slot maps onto the line's bottom
      // end; the removed top corners map onto the line too — they no longer
      // exist as rests (they clipped into the screen top on device).
      if (raw == 'bottomCenter' || raw == 'topLeft' || raw == 'topRight') {
        return (ReaderPillAnchor.line, 1.0);
      }
      final anchor = ReaderPillAnchor.values.firstWhere(
        (a) => a.name == raw,
        orElse: () => ReaderPillAnchor.line,
      );
      if (anchor == ReaderPillAnchor.line) {
        final frac = double.tryParse(
          MiruSettings.getSettingSync<String>(SettingKey.readerPillLineY),
        );
        return (ReaderPillAnchor.line, (frac ?? 1.0).clamp(0.0, 1.0));
      }
      return (anchor, _lineFraction);
    } catch (_) {
      return (ReaderPillAnchor.line, 1.0);
    }
  }

  void _writePersisted(ReaderPillAnchor a, double lineFraction) {
    try {
      MiruSettings.setSettingSync(SettingKey.readerPillAnchor, a.name);
      if (a == ReaderPillAnchor.line) {
        MiruSettings.setSettingSync(
          SettingKey.readerPillLineY,
          lineFraction.clamp(0.0, 1.0).toStringAsFixed(4),
        );
      }
    } catch (_) {
      // Persistence is best-effort; the in-memory value is already updated.
    }
  }

  void _measure() {
    final ctx = _pillKey.currentContext;
    if (ctx == null) return;
    final size = ctx.size;
    if (size != null && size != _pillSize) {
      setState(() => _pillSize = size);
    }
  }

  EdgeInsets _restingPadding(EdgeInsets media) => EdgeInsets.only(
    left: media.left + _pillEdgeInset,
    right: media.right + _pillEdgeInset,
    top: media.top + _pillTopExtra,
    bottom: media.bottom + _pillBottomExtra,
  );

  double _lineBottom(EdgeInsets padding, double viewportHeight) =>
      viewportHeight - padding.bottom - _pillSize.height;

  Offset _linePos(double fraction, Size viewport, EdgeInsets padding) {
    final top = padding.top;
    final bottom = _lineBottom(padding, viewport.height);
    final y = top + fraction.clamp(0.0, 1.0) * (bottom - top);
    return Offset((viewport.width - _pillSize.width) / 2, y);
  }

  double _lineFractionFor(
    Offset pos,
    EdgeInsets padding,
    double viewportHeight,
  ) {
    final top = padding.top;
    final bottom = _lineBottom(padding, viewportHeight);
    if (bottom <= top) return 1.0;
    return ((pos.dy - top) / (bottom - top)).clamp(0.0, 1.0);
  }

  Offset _cornerPos(ReaderPillAnchor a, Size viewport, EdgeInsets padding) {
    // Physical corners — no safe-area inset on purpose.
    const left = 0.0;
    final right = viewport.width - _pillSize.width;
    final bottom = viewport.height - _pillSize.height;
    return switch (a) {
      ReaderPillAnchor.bottomLeft => Offset(left, bottom),
      ReaderPillAnchor.bottomRight => Offset(right, bottom),
      ReaderPillAnchor.line => _linePos(_lineFraction, viewport, padding),
    };
  }

  Offset _restPos(Size viewport, EdgeInsets padding) => switch (_anchor) {
    ReaderPillAnchor.line => _linePos(_lineFraction, viewport, padding),
    _ => _cornerPos(_anchor, viewport, padding),
  };

  /// Drag clamps to the physical screen so the corners are reachable;
  /// the safe-area segment bounds only the line rest.
  Offset _clampToSegment(Offset pos, Size viewport, EdgeInsets padding) {
    final right = viewport.width - _pillSize.width;
    final bottom = viewport.height - _pillSize.height;
    const left = 0.0;
    const top = 0.0;
    return Offset(
      pos.dx.clamp(left, math.max(left, right)),
      pos.dy.clamp(top, math.max(top, bottom)),
    );
  }

  /// The snap candidate nearest to [pos]: the two bottom corners (flush to
  /// the physical edges) versus the closest point on the vertical center line
  /// (y clamped into the safe-area segment).
  (ReaderPillAnchor, Offset, double lineFraction) _nearestCandidate(
    Offset pos,
    Size viewport,
    EdgeInsets padding,
  ) {
    final half = Offset(_pillSize.width / 2, _pillSize.height / 2);
    final centre = pos + half;

    final lineFrac = _lineFractionFor(pos, padding, viewport.height);
    var best = ReaderPillAnchor.line;
    var bestPos = _linePos(lineFrac, viewport, padding);
    var bestDistance = (bestPos + half - centre).distance;
    for (final a in const [
      ReaderPillAnchor.bottomLeft,
      ReaderPillAnchor.bottomRight,
    ]) {
      final candidate = _cornerPos(a, viewport, padding);
      final d = (candidate + half - centre).distance;
      if (d < bestDistance) {
        bestDistance = d;
        best = a;
        bestPos = candidate;
      }
    }
    return (best, bestPos, lineFrac);
  }

  Offset _currentPos(Size viewport, EdgeInsets padding) {
    if (_dragPos != null) return _dragPos!;
    final from = _settleFrom;
    if (from != null) {
      final target = _restPos(viewport, padding);
      final t = Curves.easeOutCubic.transform(_settleController.value);
      return Offset.lerp(from, target, t)!;
    }
    return _restPos(viewport, padding);
  }

  /// Corner radius for the current motion state.
  ///
  /// A continuous falloff with the distance to the NEAREST corner rest
  /// position — no "which candidate wins" branch, because that branch is what
  /// made the morph a step function (the radius jumped from 16 to whatever the
  /// corner distance gave the instant the corner became the closest slot).
  /// The ramp spans exactly the horizontal gap between the vertical center
  /// line and a corner column, so the line's own rest positions land at
  /// radius 16 with zero slope rather than mid-morph.
  double _cornerEase(Size viewport, EdgeInsets media) {
    if (_dragPos == null && _settleFrom == null) {
      return _anchor == ReaderPillAnchor.line ? 0.0 : 1.0;
    }
    final padding = _restingPadding(media);
    final pos = _currentPos(viewport, padding);
    final d = _nearestCornerDistance(pos, viewport, padding);
    final ramp = math.max(1.0, (viewport.width - _pillSize.width) / 2);
    final t = (1 - d / ramp).clamp(0.0, 1.0);
    // Smootherstep: zero slope at both ends, so the morph neither starts nor
    // lands abruptly however fast the finger moves.
    return t * t * t * (t * (t * 6 - 15) + 10);
  }

  /// Radius for the current motion state — 16 on the line, 0 at a corner.
  double _cornerRadius(Size viewport, EdgeInsets media) =>
      _pillRadius * (1 - _cornerEase(viewport, media));

  /// The card's animated bottom padding: the bottom safe-area inset is added
  /// at a corner, so the card grows to (original height + inset) while the
  /// text keeps its distance from the card's top edge.
  /// Anything that means the reader is interacting with the pill: a held
  /// press, an active drag, or the settle animation still running.
  bool get _interacting => _pressed || _dragPos != null || _settleFrom != null;

  /// Compact (page/total only) while docked at a side and idle. The full
  /// readout returns while pressing, dragging, or settling — so a drag out of
  /// a corner expands, and the shrink happens only once the pill has arrived
  /// back at the corner.
  bool _cornerCompact(Size viewport, EdgeInsets media) =>
      _anchor != ReaderPillAnchor.line && !_interacting;

  double _nearestCornerDistance(Offset pos, Size viewport, EdgeInsets padding) {
    var best = double.infinity;
    for (final a in const [
      ReaderPillAnchor.bottomLeft,
      ReaderPillAnchor.bottomRight,
    ]) {
      final d = (_cornerPos(a, viewport, padding) - pos).distance;
      if (d < best) best = d;
    }
    return best;
  }

  /// The visual pill stays content-sized — its own intrinsic height.
  /// The real drag region in screen coordinates: left, top, width, height,
  /// and whether it is the taller corner variant. The tap affordance draws
  /// its outline from these same numbers, so what the user is shown is
  /// exactly what the gesture detector owns.
  (double, double, double, double, bool) _hitBox(Offset pos, EdgeInsets media) {
    final boxWidth = math.max(_pillTouchTarget, _pillSize.width);
    final atCorner = _anchor != ReaderPillAnchor.line;
    final boxHeight = atCorner
        ? ReaderPositionPill.cornerHitHeight(media.bottom)
        : _pillTouchTarget;
    final top = atCorner
        ? pos.dy + _pillSize.height - boxHeight
        : pos.dy - (boxHeight - _pillSize.height) / 2;
    return (
      pos.dx - (boxWidth - _pillSize.width) / 2,
      top,
      boxWidth,
      boxHeight,
      atCorner,
    );
  }

  /// The affordance outline drawn over the real drag region while
  /// [_hintVisible] is true: a soft wash plus a hairline so the grab area is
  /// visible without hiding the artwork under it.
  Widget _hintOverlay(Offset pos, EdgeInsets media) {
    final (left, top, width, height, _) = _hitBox(pos, media);
    final tint = context.theme.colors.primary;
    return Positioned(
      left: left + 2,
      top: top + 2,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _hintVisible ? 1 : 0,
          duration: const Duration(milliseconds: 160),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: tint.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: SizedBox(width: width - 4, height: height - 4),
          ),
        ),
      ),
    );
  }

  /// No IntrinsicWidth/IntrinsicHeight here: the card is content-sized
  /// (`mainAxisSize: .min` + `AnimatedSize`) and the intrinsic pass would
  /// return the child's full width instantly, which is exactly what stops
  /// `AnimatedSize` from animating.
  Widget _pillBody(double radius, bool compact) => KeyedSubtree(
    key: _pillKey,
    child: widget.childBuilder(radius, compact, _hintVisible),
  );

  /// The gesture box keeps the 48 dp touch target around the content-sized
  /// pill. At the bottom corners it grows to the bottom safe-area inset plus
  /// 44 dp (anchored at the pill's flush bottom edge, extending upward);
  /// elsewhere it stays 48 dp centred on the visual pill.
  /// The gesture area is its own layer, NOT a box around the card: a
  /// fixed-size wrapper constrains the card, so when the grip appears the pill
  /// cannot widen and the chapter text ellipsizes instead. The card is
  /// hit-transparent (decorations and text never absorb), so a press on it
  /// falls through to this layer.
  Widget _gestureLayer(
    Offset pos,
    Size viewport,
    EdgeInsets padding,
    EdgeInsets media,
  ) {
    final (left, top, width, height, _) = _hitBox(pos, media);
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _flashHint,
        onLongPress: _onLongPressStart,
        // Both release hooks clear the press: onLongPressUp alone is not
        // guaranteed to fire once the recognizer has already won the arena,
        // and a stuck press leaves the card expanded for good.
        onLongPressUp: _onLongPressEnd,
        onLongPressEnd: (_) => _onLongPressEnd(),
        onPanDown: _onPanDown,
        onPanStart: _onPanStart,
        onPanUpdate: (details) => _onPanUpdate(details, viewport, padding),
        onPanEnd: (_) => _onPanEnd(viewport, padding),
        onPanCancel: () => _onPanCancel(viewport, padding),
        child: SizedBox(width: width, height: height),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final media = MediaQuery.paddingOf(context);
    final padding = _restingPadding(media);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    final radius = _cornerRadius(viewport, media);
    final compact = _cornerCompact(viewport, media);
    final pill = _pillBody(radius, compact);
    final pos = _currentPos(viewport, padding);

    // [Positioned] must be a DIRECT child of the [Stack]; wrapping it in
    // IgnorePointer makes it apply StackParentData to the IgnorePointer's
    // render object and throws "Incorrect use of ParentDataWidget" — which
    // every HUD-visible frame hit. The inert wrapper goes inside instead.
    // At rest on the center line the card is centred by ALIGNMENT, not by a
    // cached width: the expand/shrink animation means the measured width lags
    // the rendered one by a frame, which read as a few dp off-centre.
    final atLineRest =
        _anchor == ReaderPillAnchor.line &&
        _dragPos == null &&
        _settleFrom == null;
    // IgnorePointer goes INSIDE the Positioned: a Positioned wrapped in
    // IgnorePointer is not a direct Stack child and throws
    // "Incorrect use of ParentDataWidget" on every frame.
    final restPositioned = atLineRest
        ? Positioned(
            left: 0,
            right: 0,
            top: pos.dy,
            child: Align(
              alignment: Alignment.center,
              child: IgnorePointer(child: pill),
            ),
          )
        : Positioned(
            left: pos.dx,
            top: pos.dy,
            child: IgnorePointer(child: pill),
          );

    if (widget.isolated) {
      return Stack(children: [restPositioned]);
    }
    return Stack(
      children: [
        // The gesture layer sits UNDER the card, and the card is
        // pointer-transparent: the frosted surface would otherwise absorb the
        // press, and a layer above the card would hide the pill's text from
        // the semantics tree.
        _gestureLayer(pos, viewport, padding, media),
        restPositioned,
        _hintOverlay(pos, media),
      ],
    );
  }

  void _onPanCancel(Size viewport, EdgeInsets padding) {
    _lastPointer = null;
    _panDownPos = null;
    _pressed = false;
    if (_dragPos != null) _onPanEnd(viewport, padding);
  }

  void _onPanDown(DragDownDetails details) {
    _panDownPos = details.globalPosition;
  }

  void _onLongPressStart() => setState(() => _pressed = true);

  void _onLongPressEnd() {
    if (_pressed) setState(() => _pressed = false);
  }

  void _onPanStart(DragStartDetails details) {
    // A drag supersedes a held press; without this the long-press-up can be
    // swallowed when the pan wins the arena and the card would stay expanded.
    _pressed = false;
    final viewport = MediaQuery.sizeOf(context);
    final padding = _restingPadding(MediaQuery.paddingOf(context));
    final start = details.globalPosition;
    final skip = _panDownPos == null ? Offset.zero : start - _panDownPos!;
    _lastPointer = start;
    _settleController.stop();
    _settleFrom = null;
    setState(
      () => _dragPos = _clampToSegment(
        _currentPos(viewport, padding) + skip,
        viewport,
        padding,
      ),
    );
  }

  void _onPanUpdate(
    DragUpdateDetails details,
    Size viewport,
    EdgeInsets padding,
  ) {
    final pointer = details.globalPosition;
    final last = _lastPointer ?? pointer;
    _lastPointer = pointer;
    final delta = pointer - last;
    if (delta == Offset.zero) return;
    setState(
      () => _dragPos = _clampToSegment(_dragPos! + delta, viewport, padding),
    );
  }

  void _onPanEnd(Size viewport, EdgeInsets padding) {
    _lastPointer = null;
    _panDownPos = null;
    // A tap cancels the pan recogniser (the tap wins the arena); that is not
    // a release of a drag, and running a settle here would read as
    // "interacting" and keep the card expanded after every tap.
    if (_dragPos == null && _settleFrom == null) return;
    final curr = _dragPos ?? _currentPos(viewport, padding);
    final (anchor, _, lineFraction) = _nearestCandidate(
      curr,
      viewport,
      padding,
    );
    setState(() {
      _dragPos = null;
      _anchor = anchor;
      if (anchor == ReaderPillAnchor.line) _lineFraction = lineFraction;
      _settleFrom = curr;
    });
    _settleController.forward(from: 0);
    _writePersisted(anchor, lineFraction);
  }
}
