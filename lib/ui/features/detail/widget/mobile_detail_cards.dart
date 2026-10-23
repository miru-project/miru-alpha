import 'package:extended_image/extended_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_alpha/ui/core/widget/app_svgs.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/tmdb_model.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_track_page_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:miru_alpha/utils/tracking/tmdb.dart';
import 'package:url_launcher/url_launcher.dart';

/// Which expandable panel under the tracker / cast card row is open.
/// Only one at a time — opening one closes the other, like the reference's
/// two disclosure cards.
enum _OpenPanel { none, trackers, cast }

/// The tracker + cast block of the mobile detail page.
///
/// Two half-width cards sit side by side: the left one summarises the
/// tracking services, the right one the voice cast. Tapping either expands
/// its panel underneath the row; the panels are mutually exclusive.
///
/// The tracker panel is provider-driven: every tracker the backend knows
/// about gets a row, and AniList is always present so an unlinked detail
/// still has somewhere to link from.
class MobileTrackersCastSection extends HookConsumerWidget {
  const MobileTrackersCastSection({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
  });

  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider detailPr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = useState(_OpenPanel.none);
    final detailState = ref.watch(detailPr);
    final trackers =
        detailState.detailInfo?.trackers ?? const <proto.Tracker>[];
    final tmdb = ref.watch(detailPr.select((value) => value.tmdbDetail));
    final casts = tmdb?.casts ?? const <TMDBCast>[];

    final services = _trackerServices(trackers);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TrackerCard(
                services: services,
                onPress: () => open.value = open.value == _OpenPanel.trackers
                    ? _OpenPanel.none
                    : _OpenPanel.trackers,
                expanded: open.value == _OpenPanel.trackers,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CastCard(
                casts: casts,
                onPress: () => open.value = open.value == _OpenPanel.cast
                    ? _OpenPanel.none
                    : _OpenPanel.cast,
                expanded: open.value == _OpenPanel.cast,
              ),
            ),
          ],
        ),
        if (open.value == _OpenPanel.trackers) ...[
          // Reference `gap-3`: 12px between the capsule row and the panel.
          const SizedBox(height: 12),
          _TrackerPanel(
            detail: detail,
            meta: meta,
            detailUrl: detailUrl,
            detailPr: detailPr,
            services: services,
          ),
        ],
        if (open.value == _OpenPanel.cast) ...[
          const SizedBox(height: 12),
          _CastPanel(detailPr: detailPr, mediaTitle: detail.title),
        ],
      ],
    );
  }
}

/// A tracking service the detail page can show: linked when the backend
/// holds a tracker record for it, unlinked otherwise.
class _TrackerService {
  const _TrackerService({
    required this.provider,
    required this.label,
    this.trackerId,
    this.status,
    this.progress = 0,
    this.totalProgress = 0,
    this.score,
  });

  final String provider;
  final String label;
  final String? trackerId;
  final String? status;
  final int progress;
  final int totalProgress;
  final double? score;

  bool get isLinked => trackerId != null && trackerId!.isNotEmpty;
  bool get isAnilist => provider == 'anilist';
}

/// Builds the service list: every provider the backend has a tracker for,
/// plus AniList when it isn't linked yet (so the panel can offer a link).
List<_TrackerService> _trackerServices(List<proto.Tracker> trackers) {
  final services = <_TrackerService>[];
  final seen = <String>{};

  for (final tracker in trackers) {
    final provider = tracker.provider.toLowerCase();
    if (provider.isEmpty || !seen.add(provider)) continue;
    services.add(
      _TrackerService(
        provider: provider,
        label: _providerLabel(provider),
        trackerId: tracker.trackerId,
        status: tracker.status,
        progress: tracker.progress,
        totalProgress: tracker.hasTotalProgress() ? tracker.totalProgress : 0,
        score: tracker.hasScore() ? tracker.score.toDouble() : null,
      ),
    );
  }

  if (!seen.contains('anilist')) {
    services.add(const _TrackerService(provider: 'anilist', label: 'AniList'));
  }

  return services;
}

/// Display name of a tracking provider.
String _providerLabel(String provider) => switch (provider) {
  'anilist' => 'AniList',
  'mal' || 'myanimelist' => 'MyAnimeList',
  'kitsu' => 'Kitsu',
  'bangumi' => 'Bangumi',
  'tmdb' => 'TMDB',
  _ => provider,
};

/// Short letter chip for a provider without a logo asset.
String _providerInitials(String provider) {
  if (provider.length <= 3) return provider.toUpperCase();
  return provider.substring(0, 3).toUpperCase();
}

/// Collapsed tracker capsule — the reference's single-line button: accent
/// sync icon, "Tracking" label, and a ratio pill ("2/3" emerald when
/// linked, "Not synced" outline otherwise) with the chevron. No subtitle
/// line, so the row stays at the reference's 44px.
class _TrackerCard extends StatelessWidget {
  const _TrackerCard({
    required this.services,
    required this.onPress,
    required this.expanded,
  });

  final List<_TrackerService> services;
  final VoidCallback onPress;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final linked = services.where((s) => s.isLinked).length;
    final total = services.length;

    return MiruCard(
      child: FTile(
        onPress: onPress,
        // Reference capsule geometry: 12px vertical keeps a lone text
        // line at 44px total.
        style: .delta(
          contentStyle: .delta(
            suffixedPadding: EdgeInsetsGeometryDelta.value(
              const EdgeInsets.fromLTRB(12, 12, 10, 12),
            ),
            unsuffixedPadding: EdgeInsetsGeometryDelta.value(
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        prefix: Icon(
          FLucideIcons.refreshCw,
          size: 18,
          color: const Color(0xFF02A9FF),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'tracking.name'.i18n,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.theme.typography.body.xs.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (linked > 0)
              FBadge(
                variant: .secondary,
                style: .delta(
                  decoration: .boxDelta(
                    color: const Color(0x99022C22),
                    border: Border.all(color: const Color(0x4D10B981)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  labelTextStyle: TextStyleDelta.delta(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF34D399),
                  ),
                  padding: EdgeInsetsGeometryDelta.value(
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  ),
                ),
                child: Text('$linked/$total'),
              )
            else
              FBadge(
                variant: .outline,
                style: .delta(
                  padding: EdgeInsetsGeometryDelta.value(
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  ),
                ),
                // Icon in place of the "Not synced" text; the label
                // survives as the semantic description.
                child: Icon(
                  FLucideIcons.cloudOff,
                  size: 12,
                  color: colors.mutedForeground,
                  semanticLabel: 'tracking.not_synced'.i18n,
                ),
              ),
          ],
        ),
        suffix: AnimatedRotation(
          turns: expanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            FLucideIcons.chevronDown,
            size: 16,
            color: colors.mutedForeground,
          ),
        ),
      ),
    );
  }
}

/// One provider mark: the AniList logo, or a lettered chip.
class _ProviderMark extends StatelessWidget {
  const _ProviderMark({required this.service});

  final _TrackerService service;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.border),
      ),
      child: service.isAnilist
          ? anilistLogo(size: 13, color: colors.foreground)
          : Text(
              _providerInitials(service.provider),
              style: context.theme.typography.body.xs2.copyWith(
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

/// Collapsed cast capsule — the reference's single-line button: group
/// icon, "Cast" label, and the member count as plain text, with the
/// chevron. The lead-actor subtitle line is gone (an empty cast simply
/// omits the count instead of showing a placeholder row), so the row
/// stays at the reference's 44px.
class _CastCard extends StatelessWidget {
  const _CastCard({
    required this.casts,
    required this.onPress,
    required this.expanded,
  });

  final List<TMDBCast> casts;
  final VoidCallback onPress;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return MiruCard(
      child: FTile(
        onPress: onPress,
        // Same capsule geometry as [_TrackerCard].
        style: .delta(
          contentStyle: .delta(
            suffixedPadding: EdgeInsetsGeometryDelta.value(
              const EdgeInsets.fromLTRB(12, 12, 10, 12),
            ),
            unsuffixedPadding: EdgeInsetsGeometryDelta.value(
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        prefix: Icon(
          FLucideIcons.users,
          size: 18,
          color: colors.mutedForeground,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'media.cast'.i18n,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.theme.typography.body.xs.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ),
            if (casts.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                '${casts.length}',
                style: context.theme.typography.body.xs2.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ],
        ),
        suffix: AnimatedRotation(
          turns: expanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            FLucideIcons.chevronDown,
            size: 16,
            color: colors.mutedForeground,
          ),
        ),
      ),
    );
  }
}

/// Expanded tracker panel: the service list with their live state, the
/// quick status pills, the score control, and the auto-sync footer.
class _TrackerPanel extends HookConsumerWidget {
  const _TrackerPanel({
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
    required this.services,
  });

  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider detailPr;
  final List<_TrackerService> services;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final anilist = services.where((s) => s.isAnilist).firstOrNull;
    final linked = services.where((s) => s.isLinked).length;
    final trackId = int.tryParse(anilist?.trackerId ?? '');
    final st = trackId != null
        ? ref.watch(anilistTrackPageProvider(trackId))
        : null;
    final isAnime = meta.type == ExtensionType.bangumi;
    final syncing = useState(false);

    Future<void> syncAll() async {
      if (syncing.value) return;
      syncing.value = true;
      try {
        if (trackId != null) {
          await ref.read(anilistTrackPageProvider(trackId).notifier).refresh();
        }
        await ref
            .read(detailPr.notifier)
            .fetchDetailInfo(meta.packageName, detailUrl);
      } catch (e) {
        logger.warning('Tracker sync failed: $e');
      } finally {
        syncing.value = false;
      }
    }

    return MiruCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // panel header — reference row: sync icon, title, "N Active"
          // pill, and a small labeled Sync All button.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Icon(FLucideIcons.refreshCw, size: 15, color: colors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'tracking.services'.i18n,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.xs.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (linked > 0) ...[
                  FBadge(
                    variant: .secondary,
                    style: .delta(
                      labelTextStyle: TextStyleDelta.delta(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      padding: EdgeInsetsGeometryDelta.value(
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      ),
                    ),
                    child: Text(
                      'tracking.active_count'.fill({'count': '$linked'}),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                FButton(
                  variant: .outline,
                  mainAxisSize: .min,
                  style: .delta(
                    contentStyle: .delta(
                      constraints: const BoxConstraints(minHeight: 28),
                      padding: EdgeInsetsGeometryDelta.value(
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      ),
                    ),
                  ),
                  onPress: syncing.value ? null : syncAll,
                  prefix: syncing.value
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: FCircularProgress(),
                        )
                      : Icon(FLucideIcons.refreshCw, size: 13),
                  child: Text(
                    'tracking.sync_all'.i18n,
                    style: context.theme.typography.body.xs2.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _divider(context),
          // Service rows — capped and scrollable so a long tracker list
          // cannot push the episode list below the fold; the header and
          // the auto-sync footer stay pinned outside the scroll area.
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final service in services)
                    _ServiceRow(
                      service: service,
                      st: service.isAnilist ? st : null,
                      isAnime: isAnime,
                      detail: detail,
                      meta: meta,
                      detailUrl: detailUrl,
                      detailPr: detailPr,
                    ),
                ],
              ),
            ),
          ),
          _divider(context),
          // auto-sync footer
          const _AutoSyncFooter(),
        ],
      ),
    );
  }
}

/// One tracking service inside the panel: identity, live state, quick
/// status pills, and the score control.
class _ServiceRow extends ConsumerWidget {
  const _ServiceRow({
    required this.service,
    required this.st,
    required this.isAnime,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
  });

  final _TrackerService service;
  final AnilistTrackPageState? st;
  final bool isAnime;
  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider detailPr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final notifier = st == null
        ? null
        : ref.read(anilistTrackPageProvider(_mediaId).notifier);
    // The live AniList state only wins once it has actually loaded: its
    // initial value is all zeros, which would blank out the record the
    // backend already holds for this detail.
    final live = st?.isLoading == false ? st : null;
    final progress = live?.progress ?? service.progress;
    final total = live?.totalProgress ?? service.totalProgress;
    final score = live?.score ?? service.score;
    final anilistAccount = ref.watch(anilistAccountProvider);
    final isAnilistLoggedIn = anilistAccount.value != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProviderMark(service: service),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            service.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.theme.typography.body.xs.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (service.isLinked)
                          FBadge(
                            variant: .secondary,
                            style: .delta(
                              padding: EdgeInsetsGeometryDelta.value(
                                const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              'tracking.connected'.i18n,
                              style: context.theme.typography.body.xs2.copyWith(
                                fontSize: 9,
                                color: const Color(0xFF34D399),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          FBadge(
                            variant: .outline,
                            style: .delta(
                              padding: EdgeInsetsGeometryDelta.value(
                                const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              'tracking.not_linked'.i18n,
                              style: context.theme.typography.body.xs2.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Progress: $progress${total > 0 ? '/$total' : ''}'
                      '  •  '
                      'Score: ${score != null && score > 0 ? '${_scoreText(score)}/10' : '—'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.typography.body.xs2.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              if (service.isLinked)
                // Small icon-only button: FButton.icon reads
                // iconContentStyle — a contentStyle delta would never
                // apply and the button would stay at the 44px touch size.
                FButton.icon(
                  variant: .ghost,
                  size: .xs,
                  style: .delta(
                    iconContentStyle: .delta(
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      padding: EdgeInsetsGeometryDelta.value(
                        const EdgeInsets.all(6),
                      ),
                    ),
                  ),
                  onPress: () => _openProvider(context),
                  child: Icon(
                    FLucideIcons.externalLink,
                    size: 15,
                    color: colors.mutedForeground,
                  ),
                )
              else if (service.isAnilist && !isAnilistLoggedIn)
                FButton(
                  variant: .outline,
                  mainAxisSize: .min,
                  style: .delta(
                    contentStyle: .delta(
                      constraints: const BoxConstraints(minHeight: 28),
                      padding: EdgeInsetsGeometryDelta.value(
                        const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  onPress: () => _loginAnilist(ref, context),
                  prefix: Icon(FLucideIcons.logIn, size: 12),
                  child: Text(
                    'tracking.login'.i18n,
                    style: context.theme.typography.body.xs2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                FButton(
                  variant: .outline,
                  mainAxisSize: .min,
                  style: .delta(
                    contentStyle: .delta(
                      constraints: const BoxConstraints(minHeight: 28),
                      padding: EdgeInsetsGeometryDelta.value(
                        const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  onPress: () => _link(context),
                  prefix: Icon(FLucideIcons.link2, size: 12),
                  child: Text(
                    'tracking.link'.i18n,
                    style: context.theme.typography.body.xs2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (service.isLinked && notifier != null) ...[
            const SizedBox(height: 6),
            // quick status pills + score
            Row(
              children: [
                for (final status in const [
                  AnilistMediaListStatus.current,
                  AnilistMediaListStatus.planning,
                  AnilistMediaListStatus.completed,
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _StatusPill(
                      label: AniListProvider.mediaListStatusToTranslate(
                        status,
                        isAnime ? AnilistType.anime : AnilistType.manga,
                      ),
                      selected: st?.status == status,
                      onPress: () => _setStatus(context, notifier, status),
                    ),
                  ),
                const Spacer(),
                _ScoreButton(
                  score: score ?? 0,
                  onPress: () => _editScore(context, ref, notifier),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  int get _mediaId => int.tryParse(service.trackerId ?? '') ?? 0;

  Future<void> _setStatus(
    BuildContext context,
    AnilistTrackPage notifier,
    AnilistMediaListStatus status,
  ) async {
    notifier.setStatus(status);
    final ok = await notifier.saveProgress(
      detailUrl: detailUrl,
      package: meta.packageName,
      title: detail.title,
    );
    if (!ok) {
      showSimpleToast('tracking.anilist.progress_save_failed'.i18n);
    }
  }

  Future<void> _editScore(
    BuildContext context,
    WidgetRef ref,
    AnilistTrackPage notifier,
  ) async {
    final result = await showFSheet<double>(
      context: context,
      side: .btt,
      builder: (context) => _ScoreSheet(
        initial: st?.score ?? service.score ?? 0,
        themeData: ref.read(applicationControllerProvider).themeData,
      ),
    );
    if (result == null) return;
    notifier.setScore(result);
    final ok = await notifier.saveProgress(
      detailUrl: detailUrl,
      package: meta.packageName,
      title: detail.title,
    );
    if (!ok) {
      showSimpleToast('tracking.anilist.progress_save_failed'.i18n);
    }
  }

  void _link(BuildContext context) {
    context.push(
      '/anilistSearch',
      extra: AnilistSearchParam(
        title: detail.title,
        type: meta.type,
        detailUrl: detailUrl,
        package: meta.packageName,
        detailPr: detailPr,
      ),
    );
  }

  void _loginAnilist(WidgetRef ref, BuildContext context) {
    ref.read(anilistAccountProvider.notifier).login();
  }

  /// Opens the media's page on the provider site.
  Future<void> _openProvider(BuildContext context) async {
    if (!service.isAnilist) return;
    final id = _mediaId;
    if (id == 0) return;
    final kind = meta.type == ExtensionType.manga ? 'manga' : 'anime';
    final url = Uri.parse('https://anilist.co/$kind/$id');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      showSimpleToast('common.error'.i18n);
    }
  }
}

/// Score text: whole numbers without a trailing ".0".
String _scoreText(double score) =>
    score % 1 == 0 ? '${score.toInt()}' : '$score';

/// Small selectable status chip.
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.selected,
    required this.onPress,
  });

  final String label;
  final bool selected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: selected ? .primary : .outline,
      mainAxisSize: .min,
      style: .delta(
        contentStyle: .delta(
          textStyle: .delta([
            .base(.delta(fontSize: context.theme.typography.body.xs2.fontSize)),
          ]),
          constraints: const BoxConstraints(minHeight: 24),
          padding: EdgeInsetsGeometryDelta.value(
            const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ),
      onPress: onPress,
      child: Text(label),
    );
  }
}

/// Score button: the current score with a star, opening the score editor.
class _ScoreButton extends StatelessWidget {
  const _ScoreButton({required this.score, required this.onPress});

  final double score;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: .outline,
      mainAxisSize: .min,
      style: .delta(
        contentStyle: .delta(
          constraints: const BoxConstraints(minHeight: 24),
          padding: EdgeInsetsGeometryDelta.value(
            const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ),
      onPress: onPress,
      prefix: Icon(
        score > 0 ? FLucideIcons.star : FLucideIcons.star,
        size: 12,
        color: score > 0
            ? const Color(0xFFFBBF24)
            : context.theme.colors.mutedForeground,
      ),
      child: Text(
        score > 0 ? _scoreText(score) : 'Rate',
        style: context.theme.typography.body.xs2.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Score editor sheet: a 0–10 stepper in half points.
class _ScoreSheet extends StatefulWidget {
  const _ScoreSheet({required this.initial, required this.themeData});

  final double initial;
  final FThemeData themeData;

  @override
  State<_ScoreSheet> createState() => _ScoreSheetState();
}

class _ScoreSheetState extends State<_ScoreSheet> {
  late double _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return FTheme(
      data: widget.themeData,
      child: FScaffold(
        header: FHeader(title: Text('tracking.anilist.score'.i18n)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _scoreText(_value),
                style: context.theme.typography.body.xl.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FButton.icon(
                    variant: .outline,
                    onPress: () =>
                        setState(() => _value = (_value - 0.5).clamp(0, 10)),
                    child: const Icon(FLucideIcons.minus, size: 16),
                  ),
                  const SizedBox(width: 20),
                  FButton.icon(
                    variant: .outline,
                    onPress: () =>
                        setState(() => _value = (_value + 0.5).clamp(0, 10)),
                    child: const Icon(FLucideIcons.plus, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FButton(
                onPress: () => Navigator.of(context).pop(_value),
                child: Text('common.save'.i18n),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The auto-sync footer: a switch gating the automatic tracker update the
/// player performs when an episode finishes.
class _AutoSyncFooter extends StatefulWidget {
  const _AutoSyncFooter();

  @override
  State<_AutoSyncFooter> createState() => _AutoSyncFooterState();
}

class _AutoSyncFooterState extends State<_AutoSyncFooter> {
  late bool _enabled = MiruSettings.getSettingSync<bool>(
    SettingKey.autoTracking,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          Icon(
            FLucideIcons.slidersHorizontal,
            size: 14,
            color: colors.mutedForeground,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'tracking.auto_sync'.i18n,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.theme.typography.body.xs.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: FSwitch(
              value: _enabled,
              onChange: (value) {
                setState(() => _enabled = value);
                MiruSettings.setSettingSync(
                  SettingKey.autoTracking,
                  value ? 'true' : 'false',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Expanded cast panel: the voice cast list with avatar, role and the
/// character each actor plays.
class _CastPanel extends HookConsumerWidget {
  const _CastPanel({required this.detailPr, required this.mediaTitle});

  final DetialProvider detailPr;
  final String mediaTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final tmdb = ref.watch(detailPr.select((value) => value.tmdbDetail));
    final casts = tmdb?.casts ?? const <TMDBCast>[];
    final isLoading = useState(false);
    final hasAttempted = useState(false);

    useEffect(() {
      if (casts.isEmpty && !hasAttempted.value) {
        isLoading.value = true;
        hasAttempted.value = true;
        Future.microtask(() async {
          final extensionType = ref.read(detailPr.notifier).meta.type;
          final mediaType = extensionType == ExtensionType.bangumi
              ? "tv"
              : "movie";
          await ref
              .read(detailPr.notifier)
              .fetchTMDBDetail(mediaTitle, mediaType);
          if (context.mounted) {
            isLoading.value = false;
          }
        });
      }
      return null;
    }, const []);

    if (isLoading.value) {
      return const MiruCard(
        child: SizedBox(
          height: 120,
          child: Center(child: FCircularProgress.loader()),
        ),
      );
    }

    if (casts.isEmpty) {
      return MiruCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'media.no_cast_found'.i18n,
              style: context.theme.typography.body.xs.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ),
        ),
      );
    }

    return MiruCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'media.cast_panel_title'.i18n,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.xs.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'media.cast_members'.fill({'count': '${casts.length}'}),
                  style: context.theme.typography.body.xs2.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          _divider(context),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 256),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: casts.length,
              separatorBuilder: (context, index) => _divider(context),
              itemBuilder: (context, index) =>
                  _CastRow(cast: casts[index], rank: index),
            ),
          ),
        ],
      ),
    );
  }
}

/// One cast member row: avatar, name, character, and a role badge derived
/// from the billing order TMDB returns.
class _CastRow extends StatelessWidget {
  const _CastRow({required this.cast, required this.rank});

  final TMDBCast cast;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final isMain = rank < 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (cast.profilePath != null && cast.profilePath!.isNotEmpty)
            FAvatar(
              size: 36,
              image: ExtendedNetworkImageProvider(
                MiruRequest.proxyUrl(
                  TMDBProvider.getImageUrl(cast.profilePath!),
                ).toString(),
              ),
            )
          else
            FAvatar.raw(
              size: 36,
              child: Text(
                _initials(cast.name),
                style: context.theme.typography.body.xs2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cast.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.typography.body.xs.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'as ${cast.character}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.typography.body.xs2.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          FBadge(
            variant: .secondary,
            style: .delta(
              padding: EdgeInsetsGeometryDelta.value(
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
            ),
            child: Text(
              isMain
                  ? 'media.cast_role_main'.i18n
                  : 'media.cast_role_supporting'.i18n,
              style: context.theme.typography.body.xs2.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Up to two initials of the actor's name.
  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

/// One-pixel card-internal divider.
Widget _divider(BuildContext context) => SizedBox(
  height: 1,
  width: double.infinity,
  child: DecoratedBox(
    decoration: BoxDecoration(color: context.theme.colors.border),
  ),
);
