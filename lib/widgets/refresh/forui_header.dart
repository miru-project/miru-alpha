import 'dart:math' as math;
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

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

    return Container(
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
              axis: Axis.vertical,
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
                  style: theme.typography.sm.copyWith(
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
    );
  }

  Widget _buildIndicatorChild(FThemeData theme) {
    if (_mode == IndicatorMode.processed || _mode == IndicatorMode.done) {
      if (widget.state.result == IndicatorResult.fail) {
        return Icon(
          FIcons.octagonAlert,
          key: const ValueKey('error'),
          color: theme.colors.error,
          size: 28,
        );
      }
      return Icon(
        FIcons.check,
        key: const ValueKey('check'),
        color: theme.colors.primary,
        size: 28,
      );
    }

    return const SizedBox(
      key: ValueKey('progress'),
      width: 28,
      height: 28,
      child: FCircularProgress(),
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

    return (Container(
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
              axis: Axis.vertical,
              label: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildIndicatorChild(theme),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _getText(),
                  key: ValueKey(_mode),
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildIndicatorChild(FThemeData theme) {
    if (_mode == IndicatorMode.processed || _mode == IndicatorMode.done) {
      if (widget.state.result == IndicatorResult.fail) {
        return Icon(
          FIcons.octagonAlert,
          key: const ValueKey('error'),
          color: theme.colors.error,
          size: 28,
        );
      }
      return Icon(
        FIcons.check,
        key: const ValueKey('check'),
        color: theme.colors.primary,
        size: 28,
      );
    }

    return const SizedBox(
      key: ValueKey('progress'),
      width: 24,
      height: 24,
      child: FCircularProgress(),
    );
  }
}
