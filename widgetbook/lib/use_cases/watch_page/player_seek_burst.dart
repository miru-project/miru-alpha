/// Mirrors test/ui/features/watch/player_seek_burst_test.dart states for the
/// catalog.
///
/// The burst is self-ticking: it fades in, jogs its glyph, and settles (and
/// unmounts) by 700ms — exactly one play per mount, like the gesture
/// overlay's re-keyed burst. Tap the canvas to replay.
///
/// Skipped states:
/// - skipped: 'settles by 700ms' timing assertions — behaviour of the same
///   self-ticking animation the use-cases render.

library;

import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/player_overlay_atoms.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// The mirrored-from-tests components of the seek burst test.
List<WidgetbookComponent> buildPlayerSeekBurstComponents() => [
  WidgetbookComponent(
    name: 'PlayerSeekBurst',
    useCases: [
      WidgetbookUseCase(
        name: 'Forward burst · +10s (tap to replay)',
        builder: (context) => catalogFrame(_BurstHost(forward: true)),
      ),
      WidgetbookUseCase(
        name: 'Rewind burst · -10s (tap to replay)',
        builder: (context) => catalogFrame(_BurstHost(forward: false)),
      ),
    ],
  ),
];

/// Re-keys the burst on tap so the one-shot animation replays — the same
/// re-key the gesture overlay does on every double-tap.
class _BurstHost extends StatefulWidget {
  const _BurstHost({required this.forward});

  final bool forward;

  @override
  State<_BurstHost> createState() => _BurstHostState();
}

class _BurstHostState extends State<_BurstHost> {
  int _stamp = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _stamp++),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayerSeekBurst(key: ValueKey(_stamp), forward: widget.forward),
          const SizedBox(height: 16),
          Text(
            'tap to replay',
            style: context.theme.typography.body.xs.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
