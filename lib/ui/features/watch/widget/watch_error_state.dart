import 'dart:math';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_tile.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_content_body.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_error_kind.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_error_viewport.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

/// The mobile watch page's error state (the mock's "playback interrupted"
/// screen): the error viewport on top and the page's real content below —
/// header with a "Episode n · Stream unavailable" status, the diagnostics
/// accordion, and the tabbed episode list with the failed episode's Retry.
class WatchErrorState extends ConsumerWidget {
  const WatchErrorState({
    super.key,
    required this.param,
    required this.epProvider,
    required this.error,
    required this.trace,
    required this.onBack,
    required this.onRetry,
    required this.onSelectMirror,
  });

  final WatchParams param;
  final EpisodeNotifierProvider epProvider;
  final Object error;
  final StackTrace trace;
  final VoidCallback onBack;
  final VoidCallback onRetry;
  final ValueChanged<String> onSelectMirror;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ep = ref.watch(epProvider);
    final episodeNumber = ep.selectedEpisodeIndex + 1;
    final errorColor = context.theme.colors.error;

    // Taxonomy: mirror failures keep the fallback mirror list; every other
    // extension-bridge failure is an extension error carrying the stack
    // trace. Video-request errors (fvp 403/5xx) surface on the loaded
    // viewport's own card instead — they happen after this state resolves.
    final info = classifyWatchError(error, trace);
    final mirrors = info.mirrors;
    // Landscape = the FULLSCREEN player UI (the loaded watch behaves the
    // same way): the error viewport fills the whole screen — no title /
    // up-next / episode-list body below it. LayoutBuilder, not
    // MediaQuery.sizeOf: branch on the REAL constraints (the test harness
    // resizes via setSurfaceSize, which does not refresh view metrics).
    return LayoutBuilder(
      builder: (context, constraints) {
        final landscape = constraints.maxWidth > constraints.maxHeight;

        final viewport = WatchErrorViewport(
          title: param.name,
          onBack: onBack,
          onRetry: onRetry,
          mirrors: mirrors,
          onSelectMirror: onSelectMirror,
          categoryLabel: info.categoryLabel,
          detailText: info.detail,
        );

        return ColoredBox(
          color: context.theme.colors.background,
          child: landscape
              ? viewport
              : Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.widthOf(context),
                      height: min(
                        MediaQuery.widthOf(context) * 9 / 16,
                        MediaQuery.heightOf(context) * 0.72,
                      ),
                      child: viewport,
                    ),
                    Expanded(
                      child: WatchContentBody(
                        param: param,
                        epProvider: epProvider,
                        statusMeta: Row(
                          children: [
                            Icon(
                              FLucideIcons.wifiOff,
                              size: 13,
                              color: errorColor,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'Episode $episodeNumber · '
                                '${'watch.stream_unavailable'.i18n}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.theme.typography.body.xs
                                    .copyWith(color: errorColor.withAlpha(230)),
                              ),
                            ),
                          ],
                        ),
                        activeStatus: EpisodeTileStatus.failed,
                        activeStatusDetail: info.message,
                        onActiveRetry: onRetry,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
