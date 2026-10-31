import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/ui/core/widget/pulsing_dot.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_tile.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_content_body.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_loading_viewport.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

/// The mobile watch page's loading state (the mock's ">3s extension loading"
/// screen): the loading viewport on top and the page's real content below —
/// header with a "Now Loading · Ep n" status, Up Next, the tabbed episode
/// list with the resolving episode pinned, and a slow-bridge hint that
/// appears once the resolve drags past 3 seconds.
class WatchLoadingState extends HookConsumerWidget {
  const WatchLoadingState({
    super.key,
    required this.param,
    required this.epProvider,
    required this.onBack,
  });

  final WatchParams param;
  final EpisodeNotifierProvider epProvider;
  final VoidCallback onBack;

  /// The hint appears after this many seconds of resolving — the mock's
  /// ">3s" threshold, as a real elapsed timer.
  static const _slowAfter = Duration(seconds: 3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ep = ref.watch(epProvider);
    final episodeNumber = ep.selectedEpisodeIndex + 1;
    final accent = context.theme.colors.primary;

    final elapsed = useState(Duration.zero);
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        elapsed.value = elapsed.value + const Duration(seconds: 1);
      });
      return timer.cancel;
    }, const []);

    // Landscape = the FULLSCREEN player UI (matches the error state): the
    // loading viewport fills the whole screen — no content body below it.
    // LayoutBuilder, not MediaQuery.sizeOf: branch on the REAL constraints
    // so the split holds everywhere the state is hosted (the repo's test
    // harnesses resize via setSurfaceSize, which does not refresh view
    // metrics — a MediaQuery branch would see the default landscape there).
    return LayoutBuilder(
      builder: (context, constraints) {
        final landscape = constraints.maxWidth > constraints.maxHeight;
        if (landscape) {
          return ColoredBox(
            color: context.theme.colors.background,
            child: WatchLoadingViewport(
              title: param.name,
              onBack: onBack,
              extensionName: param.meta.name,
              extensionIcon: param.meta.icon,
            ),
          );
        }

        return ColoredBox(
          color: context.theme.colors.background,
          child: Column(
            children: [
              // 16:9 canvas — in a landscape window (wide + short) the pure
              // width ratio is taller than the window, so cap at 72% of the
              // height (the loaded page's viewport cap).
              SizedBox(
                width: MediaQuery.widthOf(context),
                height: min(
                  MediaQuery.widthOf(context) * 9 / 16,
                  MediaQuery.heightOf(context) * 0.72,
                ),
                child: WatchLoadingViewport(
                  title: param.name,
                  onBack: onBack,
                  extensionName: param.meta.name,
                  extensionIcon: param.meta.icon,
                ),
              ),
              Expanded(
                child: WatchContentBody(
                  param: param,
                  epProvider: epProvider,
                  statusMeta: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'watch.now_loading'.i18n,
                          style: context.theme.typography.body.xs.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '·',
                          style: context.theme.typography.body.xs.copyWith(
                            color: context.theme.colors.mutedForeground
                                .withAlpha(77),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ep $episodeNumber',
                          style: context.theme.typography.body.xs.copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  listActivity: true,
                  activeStatus: EpisodeTileStatus.resolving,
                  listFooter: elapsed.value >= _slowAfter
                      ? _SlowBridgeHint(accent: accent)
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The >3s assistance note under the episode list — the mock's graceful
/// timeout line, worded without promising an automatic fallback the
/// resolver does not have.
class _SlowBridgeHint extends StatelessWidget {
  const _SlowBridgeHint({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PulsingDot(color: accent, size: 5),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'watch.slow_bridge'.i18n,
              textAlign: TextAlign.center,
              style: context.theme.typography.body.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
