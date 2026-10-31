import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/utils/core/episode_label.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/core/miru_directory.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/ui/core/widget/pulsing_dot.dart';
import 'package:path/path.dart' as p;

/// Transient playback state a watch page can pin onto one episode row.
enum EpisodeTileStatus {
  /// The row whose stream is being resolved right now (watch request in
  /// flight): accent row, pulsing "Loading" pill in place of the download
  /// action.
  resolving,

  /// The row whose resolution failed: error-tinted row, "Failed" badge and
  /// a retry control in place of the download action.
  failed,
}

class MobileDetailTile extends ConsumerWidget {
  const MobileDetailTile({
    super.key,
    required this.item,
    required this.idx,
    required this.position,
    required this.selectedGpIndex,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
    required this.history,
    required this.isDownloaded,
    this.onPress,
    this.selected = false,
    this.status,
    this.statusDetail,
    this.onRetry,
  });

  final ExtensionEpisode item;
  final int idx;

  /// 1-based ordinal of [item] within its group, independent of the visual
  /// (possibly reversed) tile order — used for the number badge.
  final int position;
  final int selectedGpIndex;
  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider? detailPr;
  final History? history;
  final bool isDownloaded;

  /// Overrides the default "push a new /watch route" tap behaviour — the
  /// watch page passes [EpisodeNotifier.selectEpisode] so the row switches
  /// the already-mounted player instead of stacking another route.
  final VoidCallback? onPress;

  /// Marks the currently playing episode: native selected tile styling, a
  /// primary-tinted ordinal and a "Now" badge in place of the download
  /// action. (One playing indicator — the animated equalizer was removed as
  /// a third repeat of the same fact.)
  final bool selected;

  /// Transient playback state pinned onto one row by the watch page's
  /// loading / error shells: the episode being resolved while the watch
  /// request is in flight, or the one whose resolution failed. `null` (the
  /// default) renders the plain list row.
  final EpisodeTileStatus? status;

  /// One-line reason shown under a [EpisodeTileStatus.failed] row
  /// (e.g. the watch error's own message).
  final String? statusDetail;

  /// Retry action for a [EpisodeTileStatus.failed] row — the page's watch
  /// invalidation. The retry control only renders when both are set.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key =
        "${meta.packageName}_${detail.episodes?[selectedGpIndex].title}_${item.name}";
    final isLoading = ref.watch(
      downloadProvider.select(
        (s) => s.value?.preparingKeys.contains(key) ?? false,
      ),
    );
    final downloadProgress = ref.watch(
      downloadProvider.select((s) {
        final active = s.value?.active ?? [];
        return active.firstWhereOrNull((e) => e.key == key);
      }),
    );

    final h = history;
    final finished =
        h != null && h.totalProgress > 0 && h.progress >= h.totalProgress;
    final frac = h != null && h.totalProgress > 0
        ? (h.progress / h.totalProgress).clamp(0.0, 1.0)
        : 0.0;

    final resolving = status == EpisodeTileStatus.resolving;
    final failed = status == EpisodeTileStatus.failed;
    final accent = context.theme.colors.primary;
    final errorColor = context.theme.colors.error;

    return FTile(
      // Compact rows: the default 14.5px content padding stacked on the
      // 44px touch-floor of the suffix download button made every tile
      // ~73px tall. 8px vertical keeps the list dense while the full-row
      // tap target and the 44px button stay intact.
      selected: selected,
      style: .delta(
        // Selected row highlight (audit round 3 minor 1; round 5 medium 2):
        // the mock's playing card — emerald accents on a raised fill.
        // Emitted UNCONDITIONALLY (no `.match({.selected}, …)`) on purpose:
        // Forui 0.27.6's FItem never adds `selected` to its style variants
        // (formVariants = platform + disabled only), so variant-matched
        // selected decorations — forui's own included — never paint.
        contentDecoration: .delta([
          // .base(...) applies to the base decoration unconditionally — no
          // `.match({.selected})`, which never paints (Forui 0.27.6's FItem
          // omits `selected` from its style variants; see the note above).
          // The condition lives in this build: the delta is only emitted
          // for the active row.
          if (selected)
            .base(
              DecorationDelta.boxDelta(
                // Follows the user's selected theme accent (not a hardcoded
                // green): the selection highlight tracks whatever primary
                // the theme picker is set to.
                color: accent.withAlpha(26),
                border: Border.all(color: accent.withAlpha(128)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          // The loading shell's resolving row: the same raised treatment as
          // the selected row, keyed to the accent the theme carries.
          if (resolving)
            .base(
              DecorationDelta.boxDelta(
                color: accent.withAlpha(20),
                border: Border.all(color: accent.withAlpha(115)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          // The error shell's failed row: the mock's error-container wash
          // with a hairline error border.
          if (failed)
            .base(
              DecorationDelta.boxDelta(
                color: errorColor.withAlpha(18),
                border: Border.all(color: errorColor.withAlpha(90)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        ]),
        contentStyle: .delta(
          suffixedPadding: EdgeInsetsGeometryDelta.value(
            const EdgeInsets.fromLTRB(15, 8, 13, 8),
          ),
          titleSpacing: 2,
        ),
      ),
      prefix: SizedBox(
        width: 24,
        // Plain bold ordinal on every row ("01 | Asa and Yuru"); inactive
        // rows recede with muted ink. The playing indicators (EQ bars +
        // NOW badge) live together at the row's right end — splitting them
        // across the card made the eye jump twice (review round 6, minor 1).
        child: Text(
          position.toString().padLeft(2, '0'),
          textAlign: TextAlign.center,
          style: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w700,
            color: failed
                ? errorColor
                : selected || resolving
                ? accent
                : context.theme.colors.mutedForeground,
          ),
        ),
      ),
      suffix: resolving
          ? _ResolvingPill(accent: accent)
          : failed
          ? _RetryButton(onRetry: onRetry, color: errorColor)
          : selected
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _EqBars(),
                const SizedBox(width: 6),
                FBadge(
                  variant: .primary,
                  style: .delta(
                    padding: EdgeInsetsGeometryDelta.value(
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    ),
                  ),
                  child: Text(
                    'watch.now'.i18n,
                    style: context.theme.typography.body.xs2.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: context.theme.colors.primaryForeground,
                    ),
                  ),
                ),
              ],
            )
          : FTappableGroup.isolate(
              child: FButton.icon(
                variant: .ghost,
                // Fully watched: a check replaces the download affordance —
                // the mock's watched rows carry an emerald check_circle
                // instead of an arrow.
                onPress: (isLoading || isDownloaded || finished)
                    ? null
                    : () => _startDownload(context, ref, key),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: FCircularProgress(),
                      )
                    : isDownloaded || finished
                    ? Icon(
                        FLucideIcons.circleCheck,
                        color: context.theme.colors.primary,
                      )
                    : Icon(FLucideIcons.arrowDownToLine),
              ),
            ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              // The prefix box already carries the number, so the raw
              // "Episode N - " prefix is stripped ("01 | Asa and Yuru").
              // A name that is itself a bare backend number ("0") renders
              // as a human "Episode N" instead of "01 | 0". Fully watched
              // episodes grey out; unplayed ones dim slightly so the
              // active row dominates (review round 5 medium 2).
              isBareEpisodeName(item.name)
                  ? 'media.episode_number'.fill({'n': '$position'})
                  : stripEpisodePrefix(item.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: selected || resolving
                  ? context.theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w700,
                    )
                  : failed
                  ? context.theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    )
                  : finished
                  ? context.theme.typography.body.sm.copyWith(
                      color: context.theme.colors.mutedForeground,
                    )
                  : context.theme.typography.body.sm.copyWith(
                      color: context.theme.colors.foreground.withAlpha(216),
                    ),
            ),
          ),
          if (failed) ...[
            const SizedBox(width: 6),
            FBadge(
              variant: .destructive,
              style: .delta(
                padding: EdgeInsetsGeometryDelta.value(
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
                labelTextStyle: TextStyleDelta.delta(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FLucideIcons.triangleAlert, size: 9),
                  const SizedBox(width: 3),
                  Text('watch.episode_failed'.i18n),
                ],
              ),
            ),
          ],
        ],
      ),
      onPress:
          onPress ??
          () {
            final donwloadList = detailPr == null
                ? const <proto.Download>[]
                : ref.watch(detailPr!.select((value) => value.downloadList));
            final savePath = donwloadList
                .firstWhereOrNull(
                  (element) =>
                      element.key ==
                      "${detail.title}-${detail.episodes?[selectedGpIndex].title}-${item.name}",
                )
                ?.savePath;
            context.push<WatchParams>(
              "/watch",
              extra: WatchParams(
                detailPr: detailPr,
                name: detail.title,
                savePath: savePath,
                detailImageUrl: detail.cover ?? '',
                selectedEpisodeIndex: idx,
                selectedGroupIndex: selectedGpIndex,
                epGroup: detail.episodes,
                detailUrl: detailUrl,
                url: item.url,
                meta: meta,
                type: meta.type,
              ),
            );
          },
      subtitle: resolving
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PulsingDot(color: accent, size: 5),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'watch.resolving_stream'.i18n,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.xs.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : failed && statusDetail != null
          ? Text(
              statusDetail!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.theme.typography.body.xs.copyWith(
                color: errorColor.withAlpha(204),
              ),
            )
          : (h == null && item.update.isEmpty && downloadProgress == null)
          ? SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (h != null && h.totalProgress > 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: SizedBox(
                      height: 4,
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.theme.colors.muted,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: finished ? 1.0 : frac,
                          child: ColoredBox(
                            // Micro-state fill: full accent once the episode
                            // is fully watched, softened accent while still
                            // in progress (theme-driven, not hardcoded).
                            color: finished
                                ? context.theme.colors.primary
                                : context.theme.colors.primary.withAlpha(179),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                // Separator only BETWEEN visible parts — the old
                // per-part trailing dot left an orphan "• " after the
                // progress when date/download were absent (audit round 3,
                // minor 2). Inactive rows mute the line so the active
                // row's white text dominates the list (review round 4:
                // "inactive items recede").
                Text(
                  [
                    if (item.update.isNotEmpty)
                      _dateFormatter(DateTime.tryParse(item.update)),
                    if (h != null) _progressIndicator(h),
                    if (downloadProgress != null)
                      "${downloadProgress.status.name} - ${(downloadProgress.progress / (downloadProgress.total == 0 ? 1 : downloadProgress.total) * 100).toStringAsFixed(1)}%",
                  ].join(' • '),
                  style: selected
                      ? null
                      : context.theme.typography.body.xs.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                ),
              ],
            ),
    );
  }

  Future<void> _startDownload(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) async {
    final notifier = ref.read(downloadProvider.notifier);
    notifier.startPreparing(key);
    try {
      var watchResult = await MiruCoreEndpoint.watch(
        item.url,
        meta.packageName,
        meta,
      );

      // Handle mirrors for V2 flow
      if (meta.api == "2" && watchResult is pb_extension.ExtensionWatch) {
        if (watchResult.groups.isNotEmpty) {
          final group = watchResult.groups.firstWhere(
            (e) =>
                watchResult.hasDefaultGroup() &&
                e.title == watchResult.defaultGroup,
            orElse: () => watchResult.groups.first,
          );
          if (group.mirrors.isNotEmpty) {
            final index = watchResult.hasDefaultIndex()
                ? watchResult.defaultIndex
                : 0;
            final mirror = (index >= 0 && index < group.mirrors.length)
                ? group.mirrors[index]
                : group.mirrors.first;

            watchResult = await MiruCoreEndpoint.mirror(
              meta.packageName,
              mirror.url,
            );
          }
        }
      }

      String videoUrl = "";
      Map<String, String> videoHeaders = {};
      String videoType = "";

      if (watchResult is pb_extension.ExtensionBangumiWatch) {
        videoUrl = watchResult.url;
        videoHeaders = watchResult.headers;
        videoType = watchResult.type;
      }
      if (!context.mounted) return;
      if (videoUrl.isEmpty) {
        showSimpleToast('media.failed_to_fetch_video_url'.i18n);
        return;
      }

      final tempDir = await MiruDirectory.getTempDownloadDirectory();
      final title =
          "${detail.title}-${detail.episodes?[selectedGpIndex].title}-${item.name}";
      final res = await MiruGrpcClient.downloadClient.download(
        proto.DownloadRequest(
          url: videoUrl,
          downloadPath: p.join(tempDir, title),
          mediaType: downloadMediaTypeFromString(videoType),
          category: meta.type.category,
          package: meta.packageName,
          detailUrl: detailUrl,
          title: title,
          key: key,
          watchUrl: item.url,
        )..headers.addAll(videoHeaders),
      );

      if (res.variantSummary.isNotEmpty) {
        if (!context.mounted) return;
        showFDialog(
          context: context,
          builder: (context, _, animation) => MiruDialog(
            animation: animation,
            title: Text('media.select_resolution'.i18n),
            body: SizedBox(
              width: 300,
              // height: 300,
              child: FTileGroup.builder(
                count: res.variantSummary.length,
                tileBuilder: (context, index) {
                  final variant = res.variantSummary[index];
                  return FTile(
                    title: Text(variant.resolution),
                    subtitle: Text(variant.codec),
                    onPress: () async {
                      Navigator.of(context).pop();
                      final vRes = await MiruGrpcClient.downloadClient.download(
                        proto.DownloadRequest(
                          url: variant.url,
                          downloadPath: p.join(tempDir, title),
                          mediaType: downloadMediaTypeFromString(videoType),
                          category: meta.type.category,
                          package: meta.packageName,
                          detailUrl: detailUrl,
                          title: title,
                          key: key,
                          watchUrl: item.url,
                        )..headers.addAll(videoHeaders),
                      );
                      if (!context.mounted) return;
                      if (vRes.variantSummary.isEmpty) {
                        showSimpleToast('media.download_started'.i18n);
                      }
                    },
                  );
                },
              ),
            ),
            actions: [
              FButton(
                variant: .outline,
                onPress: () => Navigator.of(context).pop(),
                child: Text('common.cancel'.i18n),
              ),
            ],
          ),
        );
        return;
      }

      showSimpleToast('media.download_started'.i18n);
    } catch (e) {
      logger.severe('Failed to start download: $e');
      showSimpleToast('${'media.failed_to_start_download'.i18n}: $e');
    } finally {
      notifier.finishPreparing(key);
    }
  }

  static String _dateFormatter(DateTime? date) {
    if (date == null) return "";
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return "time.just_now".i18n;
        }
        return "time.minutes_ago".fill({"minutes": diff.inMinutes.toString()});
      }
      return "time.hours_ago".fill({"hours": diff.inHours.toString()});
    }
    if (diff.inDays == 1) {
      return "time.yesterday".i18n;
    }
    if (diff.inDays < 7) {
      return "time.days_ago".fill({"days": diff.inDays.toString()});
    }
    if (diff.inDays < 30) {
      return "time.weeks_ago".fill({"weeks": (diff.inDays ~/ 7).toString()});
    }
    if (diff.inDays < 365) {
      return "time.months_ago".fill({"months": (diff.inDays ~/ 30).toString()});
    }
    return "time.years_ago".fill({"years": (diff.inDays ~/ 365).toString()});
  }

  static String _progressIndicator(History h) {
    final type =
        ExtensionType.values.firstWhereOrNull(
          (e) => e.name == h.type || e.toString() == h.type,
        ) ??
        ExtensionType.all;
    switch (type) {
      case ExtensionType.manga:
        return "${h.progress} ${"common.page".i18n} / ${h.totalProgress} ${"common.page".i18n}";
      case ExtensionType.bangumi:
        final dur = Duration(seconds: h.progress);
        final totalDur = Duration(seconds: h.totalProgress);
        return "${_formatDuration(dur)} / ${_formatDuration(totalDur)}";
      case ExtensionType.fikushon:
        return "${h.progress}/${h.totalProgress}";
      default:
        return "";
    }
  }

  static String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

/// The loading shell's trailing pill on the resolving row: pulsing dot +
/// "Loading" on an accent badge. Non-interactive — the row itself is the
/// tap target while the watch request resolves.
class _ResolvingPill extends StatelessWidget {
  const _ResolvingPill({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return FBadge(
      variant: .primary,
      style: .delta(
        decoration: DecorationDelta.shapeDelta(color: accent.withAlpha(38)),
        labelTextStyle: TextStyleDelta.delta(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        padding: EdgeInsetsGeometryDelta.value(
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PulsingDot(color: accent, size: 5),
          const SizedBox(width: 5),
          Text('watch.loading_badge'.i18n),
        ],
      ),
    );
  }
}

/// The error shell's trailing retry control on the failed row — the mock's
/// outline "Retry" button keyed to the error color.
class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onRetry, required this.color});

  final VoidCallback? onRetry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FTappableGroup.isolate(
      child: FButton(
        variant: .outline,
        size: .xs,
        mainAxisSize: .min,
        onPress: onRetry,
        style: .delta(
          contentStyle: .delta(
            // 36px floor: the family floor of this list's controls. The
            // suffix slot narrows with the row (long titles + the Failed
            // badge on 320-wide phones) — a 40px floor overflowed it.
            constraints: const BoxConstraints(minHeight: 36),
          ),
        ),
        // No prefix icon: the tile's suffix slot narrows with the row
        // (long titles + the Failed badge) and the icon+text pair
        // overflowed it by 10px on 320-wide phones.
        child: Text(
          'search.retry'.i18n,
          style: context.theme.typography.body.xs.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// The mock's "Playing" equalizer: three emerald bars bouncing on offset
/// phases — the active row's prefix, replacing the plain ordinal.
class _EqBars extends StatefulWidget {
  const _EqBars();

  @override
  State<_EqBars> createState() => _EqBarsState();
}

class _EqBarsState extends State<_EqBars> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.colors.primary;
    Widget bar(int index, double phase, double min, double max) {
      final t = Curves.easeInOut.transform(((_controller.value + phase) % 1.0));
      final height = min + (max - min) * (t < 0.5 ? t * 2 : 2 - t * 2);
      return Container(
        width: 2.5,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    return SizedBox(
      width: 20,
      height: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            bar(0, 0.00, 4, 15),
            bar(1, 0.35, 4, 15),
            bar(2, 0.65, 4, 15),
          ],
        ),
      ),
    );
  }
}
