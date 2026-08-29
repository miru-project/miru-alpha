import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

// Re-export DetailSkeleton (now defined in skeleton.dart) so existing importers
// that pulled it in via detail_section.dart keep working.
export 'skeleton.dart';

/// Builder signature for the skeleton placeholder shown while [Detial] is
/// loading. Using a typedef (instead of the engine's [WidgetBuilder]) keeps
/// the call site terse: `skeletonBuilder: (ctx) => DetailSkeleton(...)`.
typedef SkeletonBuilder = Widget Function(BuildContext);

/// Subscribes to [DetialState] and renders one of three sub-states:
///   * `loading` → askeleton sized to [skeletonBuilder]
///   * `error`   → a tile that shows the message and a Retry button
///   * `ready`   → the [content] builder, receiving the current value
///
/// Each detail widget uses its own copy, so the data fetch is observed
/// independently per section. Retry calls [Detial.retry] on the provider,
/// which re-fetches the detail; a monotonic [DetialState.retryToken] is
/// bumped so any sub-state watching it also rebuilds.
class DetailSection<T> extends ConsumerWidget {
  const DetailSection({
    super.key,
    required this.detailPr,
    required this.content,
    required this.skeletonBuilder,
    this.selector,
  });

  final DetialProvider detailPr;
  final Widget Function(BuildContext, T) content;
  final SkeletonBuilder skeletonBuilder;
  final T Function(DetialState)? selector;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(detailPr);
    switch (s.status) {
      case DetialStatus.loading:
        return skeletonBuilder(context);
      case DetialStatus.error:
        return _RetryTile(
          message: s.lastError,
          onRetry: () => ref.read(detailPr.notifier).retry(),
        );
      case DetialStatus.ready:
        final value = selector?.call(s) ?? s as T;
        return content(context, value);
    }
  }
}

/// Tappable error tile: shows the localized reason and exposes a Retry
/// button. Used by [DetailSection] when [DetialState.status] is
/// [DetialStatus.error].
class _RetryTile extends StatelessWidget {
  const _RetryTile({required this.message, required this.onRetry});
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final msg = message;
    return FTappable(
      onPress: onRetry,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: double.infinity),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.theme.colors.muted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                FLucideIcons.circleAlert,
                color: context.theme.colors.destructive,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'detail.load_failed'.i18n,
                      style: context.theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.theme.colors.destructive,
                      ),
                    ),
                    if (msg != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        msg,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.theme.typography.body.sm.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(FLucideIcons.refreshCw, color: context.theme.colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
