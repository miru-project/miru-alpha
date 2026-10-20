import 'dart:math' as math;
import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

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

/// A custom EasyRefresh header that uses Forui components.
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
  });

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return _ForuiIndicator(state: state);
  }
}

class _ForuiIndicator extends StatefulWidget {
  final IndicatorState state;

  const _ForuiIndicator({required this.state});

  @override
  State<_ForuiIndicator> createState() => _ForuiIndicatorState();
}

class _ForuiIndicatorState extends State<_ForuiIndicator> {
  IndicatorMode get _mode => widget.state.mode;
  double get _offset => widget.state.offset;

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
        return 'Update completed';
      case IndicatorMode.done:
        return 'Ready';
      default:
        return 'Pull to refresh';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final double triggerOffset = widget.state.actualTriggerOffset;
    final double opacity = math.min(_offset / triggerOffset, 1.0);

    // Calculate a scale effect for the progress indicator as you pull
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
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
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

    // Only an actual refresh may animate. An indeterminate spinner in the
    // idle/pull states repaints the entire screen forever, which is a battery
    // cost on phones and makes the widget impossible to settle in tests.
    if (_mode == IndicatorMode.ready || _mode == IndicatorMode.processing) {
      return const SizedBox(
        key: ValueKey('progress'),
        width: 28,
        height: 28,
        child: FCircularProgress(),
      );
    }

    return Transform.rotate(
      key: const ValueKey('arrow'),
      angle: _mode == IndicatorMode.armed ? math.pi : 0,
      child: Icon(
        FLucideIcons.arrowDown,
        size: 28,
        color: theme.colors.mutedForeground,
      ),
    );
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
