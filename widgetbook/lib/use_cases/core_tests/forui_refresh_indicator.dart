import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/refresh/forui_header.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/core/forui_refresh_indicator_test.dart states for the
/// catalog.
///
/// The layout tests pin the tree staying healthy when EasyRefresh hands the
/// Forui indicator a horizontal axis (a horizontal list's ballistic flip used
/// to trip the infinite-size assertion). Both states here are live: drag the
/// list past its edge to fire the ForuiHeader indicator exactly as the drag
/// in the test does.
///
/// The morph use-case drives the three-state icon transformation from the
/// test's θ-continuity assertions: the loading glyph spins at θ(t), and
/// completing the refresh (success or fail) morphs the check/X in at the
/// spinner's current angle before easing it onto the turn boundary.
WidgetbookComponent buildForuiRefreshIndicatorComponent() {
  return WidgetbookComponent(
    name: 'ForuiHeader (EasyRefresh host)',
    useCases: [
      WidgetbookUseCase(
        name: 'Horizontal list — drag right edge to refresh',
        builder: (context) => catalogFrame(
          _host(
            ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 20,
              itemBuilder: (context, index) =>
                  SizedBox(width: 120, child: Text('item $index')),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Vertical list — drag top edge to refresh',
        builder: (context) => catalogFrame(
          _host(
            ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) =>
                  SizedBox(height: 60, child: Text('item $index')),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Icon morph — pull, then complete success or fail (θ carries)',
        builder: (context) => catalogFrame(const _MorphHost(), padded: false),
      ),
    ],
  );
}

/// EasyRefresh needs bounded constraints; the phone canvas gives the list
/// the same full-surface shape the test's Scaffold body did.
Widget _host(
  Widget list, {
  Future<IndicatorResult> Function()? onRefresh,
  ForuiHeader header = const ForuiHeader(),
}) {
  return PhoneFrame(
    child: EasyRefresh(
      header: header,
      onRefresh:
          onRefresh ??
          () async {
            // Hold the spinner long enough for the pull demo to show the
            // spin → settle morph before the check lands.
            await Future<void>.delayed(const Duration(milliseconds: 1500));
            return IndicatorResult.success;
          },
      child: list,
    ),
  );
}

/// Interactive harness for the header's state transformation: the refresh
/// task suspends until a button completes it, so the θ handover from the
/// spinning glyph into the check (success) or X + message (fail) is
/// observable frame by frame.
class _MorphHost extends StatefulWidget {
  const _MorphHost();

  @override
  State<_MorphHost> createState() => _MorphHostState();
}

class _MorphHostState extends State<_MorphHost> {
  Completer<IndicatorResult>? _pending;
  IndicatorResult? _outcome;

  Future<IndicatorResult> _task() {
    _pending ??= Completer<IndicatorResult>();
    return _pending!.future;
  }

  void _complete(IndicatorResult result) {
    _pending?.complete(result);
    _pending = null;
    setState(() => _outcome = result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: .center,
            spacing: 12,
            children: [
              FButton(
                variant: .outline,
                onPress: _pending == null
                    ? null
                    : () => _complete(IndicatorResult.success),
                child: const Text('Complete: success'),
              ),
              FButton(
                variant: .outline,
                onPress: _pending == null
                    ? null
                    : () => _complete(IndicatorResult.fail),
                child: const Text('Complete: fail'),
              ),
            ],
          ),
        ),
        Text(
          switch (_outcome) {
            IndicatorResult.success => 'Last outcome: check settled upright',
            IndicatorResult.fail => 'Last outcome: X + message settled upright',
            _ =>
              'Pull the list down to start a refresh — θ(t) spins the '
                  'glyph; completing it carries θ into the check/X.',
          },
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        Expanded(
          child: _host(
            ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) =>
                  FTile(title: Text('item $index'), suffix: Text('#$index')),
            ),
            onRefresh: _task,
            header: ForuiHeader(
              errorText: () => 'Extension request failed: HTTP 503',
            ),
          ),
        ),
      ],
    );
  }
}
