import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Caps the cross-axis the indicator is laid out with.
///
/// EasyRefresh parks the indicator in its Stack behind a `Positioned` that
/// only pins one edge per axis, so as soon as the attached scrollable reports
/// a non-vertical axis (a nested horizontal rail inside the page inherits
/// EasyRefresh's physics and flips it) the width constraint becomes
/// unbounded. The `Container(alignment: ...)` below is then an `Align` fed
/// unbounded width, which sizes itself to infinity, throws the "was given an
/// infinite size during layout" assert, and leaks the layout debug flag that
/// surfaces as the `!_debugDoingThisLayout` failure in the console. Capping
/// the width at the window size costs nothing on the normal vertical path,
/// where the incoming constraint is already tighter.
Widget _capCrossAxis(BuildContext context, Widget child) {
  return ConstrainedBox(
    constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
    child: child,
  );
}

/// One continuous rotation angle θ across every indicator state.
enum _ThetaPhase {
  /// θ parked. Also the rest state after a completed revolution.
  idle,

  /// θ tweening [from] → [to] (the armed flip and its unwind).
  toAngle,

  /// θ(t) = θ0 + ω·t — the loading rotation.
  spinning,

  /// θ tweening to the next full-turn boundary — the state transition
  /// carries θ into the result glyph instead of snapping to zero.
  settling,
}

/// A custom EasyRefresh header that uses Forui components.
///
/// The three visible states share one rotation angle θ:
///   * pull / armed — the arrow sits at θ (armed = π);
///   * loading — a Lucide glyph spinning at θ(t) = θ0 + ω·t, seeded from
///     wherever the pull left the arrow;
///   * success / error — the check (or X with the error message) starts at
///     the spinner's current θ and eases to the next full-turn boundary, so
///     the revolution completes across the transition.
class ForuiHeader extends Header {
  const ForuiHeader({
    super.triggerOffset = 80,
    super.clamping = true,
    super.position,
    super.processedDuration = const Duration(milliseconds: 200),
    super.spring,
    super.springRebound = false,
    super.safeArea,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    super.triggerWhenRelease,
    super.maxOverOffset,
    this.errorText,
  });

  /// Resolves the message shown under the fail X. Evaluated when the
  /// indicator builds in the fail state, so it can read fresh state
  /// (e.g. the provider's `lastError`). Falls back to `common.error`.
  final String? Function()? errorText;

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return _ForuiIndicator(state: state, errorText: errorText);
  }
}

class _ForuiIndicator extends StatefulWidget {
  final IndicatorState state;
  final String? Function()? errorText;

  const _ForuiIndicator({required this.state, this.errorText});

  @override
  State<_ForuiIndicator> createState() => _ForuiIndicatorState();
}

class _ForuiIndicatorState extends State<_ForuiIndicator>
    with SingleTickerProviderStateMixin {
  /// One revolution per period while loading.
  static const _spinPeriod = Duration(milliseconds: 900);

  /// The settle tween when handing θ to the result glyph.
  static const _settleDuration = Duration(milliseconds: 400);

  /// The armed flip (0 → π) and its unwind.
  static const _flipDuration = Duration(milliseconds: 200);

  static final double _twoPi = math.pi * 2;

  late final Ticker _ticker = createTicker(_onTick);

  /// The rotation angle, radians, continuous across state changes.
  double _theta = 0;
  _ThetaPhase _phase = _ThetaPhase.idle;
  double _from = 0;
  double _to = 0;
  Duration _tweenDuration = _settleDuration;
  Curve _tweenCurve = Curves.easeOutCubic;

  /// θ at the moment the spin phase began. Each phase change restarts
  /// the ticker, so the ticker's `elapsed` always measures from the
  /// phase change itself — never from per-tick deltas, and never
  /// swallowing a clock jump that lands between frames.
  double _spinTheta0 = 0;

  IndicatorMode get _mode => widget.state.mode;
  double get _offset => widget.state.offset;

  bool get _isSettlingResult =>
      (_mode == IndicatorMode.processed || _mode == IndicatorMode.done);

  bool get _isFail =>
      _isSettlingResult && widget.state.result == IndicatorResult.fail;

  @override
  void initState() {
    super.initState();
    _syncMode();
  }

  @override
  void didUpdateWidget(covariant _ForuiIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.mode != widget.state.mode ||
        oldWidget.state.result != widget.state.result) {
      _syncMode();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// Starts a new phase with a fresh ticker epoch, so the next tick's
  /// `elapsed` measures from the phase change itself. Mid-frame calls
  /// anchor the epoch to the current frame's timestamp; a cold start
  /// anchors on its first tick.
  void _beginPhase(_ThetaPhase phase) {
    _phase = phase;
    if (_ticker.isActive) _ticker.stop();
    _ticker.start();
  }

  /// Routes a mode change into the θ phase machine.
  void _syncMode() {
    switch (_mode) {
      case IndicatorMode.ready || IndicatorMode.processing:
        if (_phase == _ThetaPhase.spinning) return;
        // Spin from wherever the pull left θ: armed hands over π.
        _spinTheta0 = _theta;
        _beginPhase(_ThetaPhase.spinning);
      case IndicatorMode.processed || IndicatorMode.done:
        _settle();
      case IndicatorMode.armed:
        _animateTo(math.pi, _flipDuration, Curves.easeOut);
      case IndicatorMode.drag:
        // Released below the trigger — unwind the armed flip.
        _animateTo(0, _flipDuration, Curves.easeOut);
      default:
        // Cycle finished: a settled revolution already ends on a 2π
        // boundary, so snapping to 0 is visually identical.
        _ticker.stop();
        _phase = _ThetaPhase.idle;
        _theta = 0;
    }
  }

  void _animateTo(double target, Duration duration, Curve curve) {
    if ((target - _theta).abs() < 0.001) {
      _theta = target;
      _phase = _ThetaPhase.idle;
      return;
    }
    _from = _theta;
    _to = target;
    _tweenDuration = duration;
    _tweenCurve = curve;
    _beginPhase(_ThetaPhase.toAngle);
  }

  /// Hands θ to the result glyph: ease to the next full-turn boundary so
  /// the in-flight revolution completes across the transition.
  void _settle() {
    if (_phase == _ThetaPhase.settling) return;
    _from = _theta;
    _to = (_theta / _twoPi).ceilToDouble() * _twoPi;
    _tweenDuration = _settleDuration;
    _tweenCurve = Curves.easeOutCubic;
    _beginPhase(_ThetaPhase.settling);
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    switch (_phase) {
      case _ThetaPhase.spinning:
        _theta =
            _spinTheta0 +
            elapsed.inMicroseconds / _spinPeriod.inMicroseconds * _twoPi;
        setState(() {});
      case _ThetaPhase.toAngle || _ThetaPhase.settling:
        final t = (elapsed.inMicroseconds / _tweenDuration.inMicroseconds)
            .clamp(0.0, 1.0);
        _theta = _from + (_to - _from) * _tweenCurve.transform(t);
        setState(() {});
        if (t >= 1.0) _phase = _ThetaPhase.idle;
      case _ThetaPhase.idle:
        break;
    }
    if (_phase == _ThetaPhase.idle && _ticker.isActive) _ticker.stop();
  }

  String _getText() {
    switch (_mode) {
      case IndicatorMode.drag:
        return 'Pull to refresh';
      case IndicatorMode.armed:
        return 'Release to refresh';
      case IndicatorMode.ready:
      case IndicatorMode.processing:
        return 'Refreshing...';
      case IndicatorMode.processed:
      case IndicatorMode.done:
        if (_isFail) return widget.errorText?.call() ?? 'common.error'.i18n;
        return 'Update completed';
      default:
        return 'Pull to refresh';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final double triggerOffset = widget.state.actualTriggerOffset;
    final double opacity = math.min(_offset / triggerOffset, 1.0);

    final double scale = _mode == IndicatorMode.drag
        ? math.min(_offset / triggerOffset, 1.0)
        : 1.0;

    return _capCrossAxis(
      context,
      Container(
        alignment: Alignment.center,
        height: _offset,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            minHeight: 0.0,
            maxHeight: double.infinity,
            maxWidth: MediaQuery.of(context).size.width,
            child: Opacity(
              opacity: opacity,
              child: FLabel(
                layout: .vertical,
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: const Offset(0.0, 0.2),
                            end: Offset.zero,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _getText(),
                    key: ValueKey(_mode),
                    maxLines: _isFail ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.typography.body.sm.copyWith(
                      color: _isFail
                          ? theme.colors.error
                          : theme.colors.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Transform.scale(
                    scale: scale,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildIndicatorChild(theme),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The glyph for the current mode, rotated by the shared θ. The
  /// AnimatedSwitcher cross-fades between glyphs while θ carries over, so
  /// state transitions never reset the rotation.
  Widget _buildIndicatorChild(FThemeData theme) {
    switch (_mode) {
      case IndicatorMode.ready || IndicatorMode.processing:
        return Transform.rotate(
          key: const ValueKey('spin'),
          angle: _theta,
          child: Icon(
            FLucideIcons.loaderCircle,
            key: const ValueKey('spinner'),
            color: theme.colors.primary,
            size: 28,
          ),
        );
      case IndicatorMode.processed || IndicatorMode.done:
        if (_isFail) {
          return Transform.rotate(
            key: const ValueKey('fail'),
            angle: _theta,
            child: Icon(FLucideIcons.x, color: theme.colors.error, size: 28),
          );
        }
        return Transform.rotate(
          key: const ValueKey('success'),
          angle: _theta,
          child: Icon(
            FLucideIcons.check,
            color: theme.colors.primary,
            size: 28,
          ),
        );
      default:
        return Transform.rotate(
          key: const ValueKey('arrow'),
          angle: _theta,
          child: Icon(
            FLucideIcons.arrowDown,
            size: 28,
            color: theme.colors.mutedForeground,
          ),
        );
    }
  }
}

/// A custom EasyRefresh footer that uses Forui components.
class ForuiFooter extends Footer {
  const ForuiFooter({
    super.triggerOffset = 60,
    super.clamping = true,
    super.position,
    super.processedDuration = const Duration(milliseconds: 200),
    super.spring,
    super.springRebound = false,
    super.safeArea,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    super.triggerWhenRelease,
    super.maxOverOffset,
  });

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return _ForuiFooterIndicator(state: state);
  }
}

class _ForuiFooterIndicator extends StatefulWidget {
  final IndicatorState state;

  const _ForuiFooterIndicator({required this.state});

  @override
  State<_ForuiFooterIndicator> createState() => _ForuiFooterIndicatorState();
}

class _ForuiFooterIndicatorState extends State<_ForuiFooterIndicator> {
  IndicatorMode get _mode => widget.state.mode;
  double get _offset => widget.state.offset;

  String _getText() {
    switch (_mode) {
      case IndicatorMode.drag:
        return 'Pull to load more';
      case IndicatorMode.armed:
        return 'Release to load more';
      case IndicatorMode.ready:
      case IndicatorMode.processing:
        return 'Loading...';
      case IndicatorMode.processed:
        return 'Loading completed';
      case IndicatorMode.done:
        return 'Ready';
      default:
        return 'Pull to load more';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final double triggerOffset = widget.state.actualTriggerOffset;
    final double opacity = math.min(_offset / triggerOffset, 1.0);

    return _capCrossAxis(
      context,
      Container(
        alignment: Alignment.center,
        height: _offset,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            minHeight: 0.0,
            maxHeight: double.infinity,
            maxWidth: MediaQuery.of(context).size.width,
            child: Opacity(
              opacity: opacity,
              child: FLabel(
                layout: .vertical,
                label: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildIndicatorChild(theme),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _getText(),
                    key: ValueKey(_mode),
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorChild(FThemeData theme) {
    if (_mode == IndicatorMode.processed || _mode == IndicatorMode.done) {
      if (widget.state.result == IndicatorResult.fail) {
        return Icon(
          FLucideIcons.octagonAlert,
          key: const ValueKey('error'),
          color: theme.colors.error,
          size: 28,
        );
      }
      return Icon(
        FLucideIcons.check,
        key: const ValueKey('check'),
        color: theme.colors.primary,
        size: 28,
      );
    }

    // See the header: the spinner is reserved for the loading states so an
    // idle list is not repainting forever.
    if (_mode == IndicatorMode.ready || _mode == IndicatorMode.processing) {
      return const SizedBox(
        key: ValueKey('progress'),
        width: 24,
        height: 24,
        child: FCircularProgress(),
      );
    }

    return Transform.rotate(
      key: const ValueKey('arrow'),
      angle: _mode == IndicatorMode.armed ? math.pi : 0,
      child: Icon(
        FLucideIcons.arrowUp,
        size: 24,
        color: theme.colors.mutedForeground,
      ),
    );
  }
}
