import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/ui/core/core/miru_expandable_tabs.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_tile.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/player_overlay_atoms.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;
import 'package:miru_alpha/utils/core/i18n.dart';

/// The player's settings content: episodes / mirrors (v2 only) / resolution
/// / subtitles as tabs with real selected states. One content model for
/// every mounting surface — the bar itself differs: the portrait watch page
/// opens it in a bottom sheet with the normal labelled [FTabs] bar, while
/// the landscape docked panel keeps the space-saving expandable bar (the
/// sheet ([showPlayerSettingsSheet]), the fullscreen player docks it as a
/// side panel ([SideSettingsMenu]).
///
/// Selection marks read the state that actually exists: episodes from the
/// episode provider, subtitles from `selectedSubtitleIndex`, quality and
/// mirrors by matching the live controller URL. A tab with nothing to show
/// renders a localized empty row, never a blank pane.
///
/// Tab bar = [MiruExpandableTabs] (the mobile download page's bar): the
/// active tab expands to icon + label, the unused ones collapse to a bare
/// icon thumb.
class PlayerSettingsTabs extends HookConsumerWidget {
  const PlayerSettingsTabs({
    super.key,
    required this.vidPr,
    required this.epProvider,
    required this.meta,
    required this.onClose,
    this.initialTab = 0,
    this.showEpisodes = true,
    this.expandable = true,
    this.leading,
  });

  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvider;
  final ExtensionMeta meta;
  final VoidCallback onClose;

  /// The tab the sheet opens on — the viewport's chips deep-link here
  /// (quality chip → Resolution, subtitle pill → Subtitle, mirror chip →
  /// Mirrors).
  final int initialTab;

  /// Portrait watch sheets drop the Episodes tab entirely — the base page
  /// already lists episodes, so keeping it here only duplicated the info.
  /// Landscape side panels keep it.
  final bool showEpisodes;

  /// The docked landscape panel collapses the bar to icons to keep content
  /// space; the portrait sheet mounts the normal [FTabs] bar instead — the
  /// sheet has the room and a collapsing icon bar reads as broken there.
  final bool expandable;

  /// Optional action rendered at the tab bar's leading edge (the docked
  /// panel's close X); the sheet passes nothing.
  final Widget? leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleIndex = ref.watch(
      vidPr.select((s) => s.selectedSubtitleIndex),
    );
    final qualityMap = ref.watch(vidPr.select((s) => s.qualityMap));
    final v2watch = ref.watch(vidPr.select((s) => s.v2watch));
    // The stream the controller is actually playing — the selection mark
    // for quality and mirror tiles (no dedicated state field exists).
    final playingUrl = ref.read(vidPr.notifier).vidController.dataSource;

    final entries = [
      if (showEpisodes)
        (
          icon: FLucideIcons.tv,
          label: 'media.episodes'.i18n,
          child: _EpisodeSection(
            epProvider: epProvider,
            meta: meta,
            onClose: onClose,
          ),
        ),
      if (v2watch != null && v2watch.groups.isNotEmpty)
        (
          icon: FLucideIcons.layers,
          label: 'watch.tab_mirror'.i18n,
          child: _MirrorSection(
            v2watch: v2watch,
            vidPr: vidPr,
            meta: meta,
            playingUrl: playingUrl,
            onClose: onClose,
          ),
        ),
      (
        icon: FLucideIcons.ratio,
        label: 'watch.tab_resolution'.i18n,
        child: _ResolutionSection(
          vidPr: vidPr,
          qualityMap: qualityMap,
          playingUrl: playingUrl,
          onClose: onClose,
        ),
      ),
      (
        icon: FLucideIcons.captions,
        label: 'watch.tab_subtitle'.i18n,
        child: _SubtitleSection(
          vidPr: vidPr,
          selectedIndex: subtitleIndex,
          onClose: onClose,
        ),
      ),
      (
        // Speed lives in the sheet since the header's speed pill retired —
        // one surface owns every playback setting. The tab label is the
        // family's short form ("watch.tab_speed"): the full "Playback
        // speed" string painted past its tab slot on a phone (the sheet
        // review's clipped last-tab finding).
        icon: FLucideIcons.gauge,
        label: 'watch.tab_speed'.i18n,
        child: _SpeedSection(vidPr: vidPr, onClose: onClose),
      ),
    ];

    // Clamp the deep-link index so a stale caller (or a portrait sheet that
    // dropped the Episodes tab) can never hand the bar an out-of-range
    // initial.
    final safeInitial = entries.isEmpty
        ? 0
        : initialTab.clamp(0, entries.length - 1);
    final selectedIndex = useState(safeInitial);

    // The portrait sheet's normal tab bar — the icon-labelled bar the sheet
    // had before the space-saving docked variant: every item stays visible,
    // selection managed by FTabs itself (deep-linked via `initial`).
    if (!expandable) {
      return FTabs(
        // Lifted control: parent-owned index survives the rebuilds the tap's
        // setState triggers (a fresh `.managed(initial:)` each build would
        // reset the selection back to the deep-linked pane).
        control: .lifted(
          index: selectedIndex.value,
          onChange: (i) => selectedIndex.value = i,
        ),
        // The panes are scrollables — they need the sheet's bounded height,
        // not FTabs' hug-content sizing.
        expands: true,
        children: [
          for (final entry in entries)
            FTabEntry(label: Icon(entry.icon), child: entry.child),
        ],
      );
    }

    return Column(
      // NOT stretched: the bar hug-fits its thumbs and centers in the
      // remaining width — no empty slab wings in the ~300px panel. The
      // panes still fill the width via the Expanded stack below.
      children: [
        Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            Expanded(
              child: Center(
                // Tuned down from the download page's defaults so up to five tabs
                // fit the ~300px panel on one row, with the tight inter-thumb
                // rhythm a segmented control normally has (thumb 30 = 18px icon + 6
                // side padding, gap 2 → 14px icon-to-icon; 5 tabs: 4*30 + 128 +
                // 4*2 = 252).
                child: MiruExpandableTabs(
                  selectedIndex: selectedIndex.value,
                  onIndexChanged: (i) => selectedIndex.value = i,
                  collapsedWidth: 30,
                  expandedWidth: 128,
                  gap: 2,
                  children: [
                    for (final entry in entries)
                      MiruExpandableTabEntry(
                        icon: Icon(entry.icon),
                        label: Text(entry.label),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          // IndexedStack keeps each pane's scroll position alive across tab
          // switches (what FTabs' kept-alive children did).
          child: IndexedStack(
            index: selectedIndex.value,
            children: [for (final entry in entries) entry.child],
          ),
        ),
      ],
    );
  }
}

/// One labelled group of option tiles — the section shape every tab reuses
/// (the old accordion-in-tabs nesting is gone: a group is a label + tiles).
/// The tiles share the title's 14px inset: a full-bleed [FTileGroup] under
/// an inset title read as two misaligned layers in the sheet.
class _OptionGroup extends StatelessWidget {
  const _OptionGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: Text(
            title,
            style: context.theme.typography.body.xs2.copyWith(
              fontWeight: FontWeight.w600,
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ),
        for (final child in children)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: child,
          ),
      ],
    );
  }
}

/// The localized empty row a tab shows when its data is absent.
class _EmptyOptionList extends StatelessWidget {
  const _EmptyOptionList(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
      child: Text(
        message,
        style: context.theme.typography.body.xs.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
    );
  }
}

/// Playback-speed tiles — the header's old speed pill retired into the
/// sheet so one surface owns every playback setting.
class _SpeedSection extends ConsumerWidget {
  const _SpeedSection({required this.vidPr, required this.onClose});

  final VideoPlayerNotifierProvider vidPr;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(vidPr.notifier);
    final current = ref.watch(vidPr.select((s) => s.speed));
    final speeds = notifier.speedList;

    String label(double s) => '${s % 1 == 0 ? s.toStringAsFixed(1) : s}x';

    return ListView(
      // Scrollable like the other panes: eight speed rows stacked in a plain
      // Column overflow their bounded tab body on shorter surfaces.
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        _OptionGroup(
          title: 'watch.speed'.i18n,
          children: [
            FTileGroup.builder(
              count: speeds.length,
              tileBuilder: (context, i) => FTile(
                selected: speeds[i] == current,
                title: Text(label(speeds[i])),
                onPress: () {
                  notifier.setSpeed(speeds[i]);
                  onClose();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EpisodeSection extends HookConsumerWidget {
  const _EpisodeSection({
    required this.epProvider,
    required this.meta,
    required this.onClose,
  });

  final EpisodeNotifierProvider epProvider;
  final ExtensionMeta meta;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ep = ref.watch(epProvider);
    final notifier = ref.read(epProvider.notifier);

    if (ep.epGroup.isEmpty) {
      return _EmptyOptionList('media.no_episodes'.i18n);
    }

    final safeGroup = ep.selectedGroupIndex.clamp(0, ep.epGroup.length - 1);
    // Which group's episode list is displayed: starts on the playing group,
    // a group tap re-points it WITHOUT loading or closing; syncs back to
    // the playing group whenever playback crosses groups.
    final displayGroup = useState(safeGroup);
    useEffect(() {
      displayGroup.value = ep.selectedGroupIndex;
      return null;
    }, [ep.selectedGroupIndex]);
    final listed = ep.epGroup[displayGroup.value];

    // Landscape has NO episode list under the fullscreen canvas — group
    // AND individual episode selection both live here, with the SAME rich
    // rows as the portrait watch list (MobileDetailTile: ordinals, watch
    // progress, download state, selection decoration, NOW badge).
    final detail = Detail(
      title: ep.name,
      episodes: ep.epGroup,
      detailUrl: '',
      package: meta.packageName,
    );
    final histories = ref
        .watch(historyPageProvider)
        .history
        .where((h) => h.package == meta.packageName)
        .toList();
    // Same completed-download lookup the detail list uses, so a "Saved"
    // mark never disagrees between the two surfaces.
    final downloadedUrls = ref.watch(
      downloadProvider.select(
        (s) => (s.value?.history ?? const [])
            .where((d) => d.status == proto.DownloadStatus.COMPLETED)
            .map((d) => d.url)
            .toList(),
      ),
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        _OptionGroup(
          title: 'watch.source'.i18n,
          children: [
            FTileGroup.builder(
              count: ep.epGroup.length,
              tileBuilder: (context, g) => FTile(
                selected: g == displayGroup.value,
                // Same selected-card treatment as the episode rows below
                // (Forui 0.27.6's FItem never paints `selected` variants —
                // the delta is emitted unconditionally, the condition lives
                // in this build).
                style: .delta(
                  contentDecoration: .delta([
                    if (g == displayGroup.value)
                      .base(
                        DecorationDelta.boxDelta(
                          color: context.theme.colors.primary.withAlpha(26),
                          border: Border.all(
                            color: context.theme.colors.primary.withAlpha(128),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                  ]),
                ),
                title: Text(
                  ep.epGroup[g].title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                suffix: Text(
                  'media.episodes_count'.i18n.fill({
                    'count': '${ep.epGroup[g].urls.length}',
                  }),
                  maxLines: 1,
                  style: context.theme.typography.body.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
                onPress: () => displayGroup.value = g,
              ),
            ),
          ],
        ),
        _OptionGroup(
          title: 'media.episodes'.i18n,
          children: [
            FTileGroup.builder(
              count: listed.urls.length,
              tileBuilder: (context, i) {
                final item = listed.urls[i];
                final active =
                    displayGroup.value == ep.selectedGroupIndex &&
                    i == ep.selectedEpisodeIndex;
                return MobileDetailTile(
                  key: ValueKey('panel-ep-${displayGroup.value}-$i'),
                  item: item,
                  idx: i,
                  position: i + 1,
                  selectedGpIndex: displayGroup.value,
                  detail: detail,
                  meta: meta,
                  detailUrl: '',
                  detailPr: null,
                  history: histories.firstWhereOrNull((h) => h.url == item.url),
                  isDownloaded: downloadedUrls.any(
                    (urls) => urls.contains(item.url),
                  ),
                  selected: active,
                  onPress: () {
                    notifier.selectEpisode(displayGroup.value, i);
                    onClose();
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _MirrorSection extends ConsumerWidget {
  const _MirrorSection({
    required this.v2watch,
    required this.vidPr,
    required this.meta,
    required this.playingUrl,
    required this.onClose,
  });

  final pb_extension.ExtensionWatch v2watch;
  final VideoPlayerNotifierProvider vidPr;
  final ExtensionMeta meta;
  final String playingUrl;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(vidPr.notifier);

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: v2watch.groups.length,
      itemBuilder: (context, groupIndex) {
        final group = v2watch.groups[groupIndex];
        return _OptionGroup(
          title: group.title,
          children: [
            FTileGroup.builder(
              count: group.mirrors.length,
              tileBuilder: (context, i) => FTile(
                selected: group.mirrors[i].url == playingUrl,
                title: Text(
                  group.mirrors[i].name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onPress: () {
                  notifier.switchMirror(meta.packageName, group.mirrors[i]);
                  onClose();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResolutionSection extends ConsumerWidget {
  const _ResolutionSection({
    required this.vidPr,
    required this.qualityMap,
    required this.playingUrl,
    required this.onClose,
  });

  final VideoPlayerNotifierProvider vidPr;
  final Map<String, String> qualityMap;
  final String playingUrl;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (qualityMap.isEmpty) {
      return _EmptyOptionList('watch.no_quality_options'.i18n);
    }
    final notifier = ref.read(vidPr.notifier);

    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        _OptionGroup(
          title: 'watch.tab_resolution'.i18n,
          children: [
            FTileGroup.builder(
              count: qualityMap.length,
              tileBuilder: (context, i) {
                final label = qualityMap.keys.elementAt(i);
                return FTile(
                  selected: qualityMap[label] == playingUrl,
                  title: Text(label),
                  onPress: () {
                    notifier.changeVideoQuality(qualityMap[label]!);
                    onClose();
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _SubtitleSection extends ConsumerWidget {
  const _SubtitleSection({
    required this.vidPr,
    required this.selectedIndex,
    required this.onClose,
  });

  final VideoPlayerNotifierProvider vidPr;
  final int selectedIndex;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitles = ref.watch(vidPr.select((s) => s.subtitlesRaw));
    if (subtitles.isEmpty) {
      return _EmptyOptionList('watch.no_subtitles'.i18n);
    }
    final notifier = ref.read(vidPr.notifier);

    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        _OptionGroup(
          title: 'watch.tab_subtitle'.i18n,
          children: [
            FTileGroup.builder(
              count: subtitles.length,
              tileBuilder: (context, i) => FTile(
                selected: i == selectedIndex,
                title: Text(
                  subtitles[i].title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(subtitles[i].language),
                onPress: () {
                  notifier.setSubSelectedIndex(i);
                  onClose();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Opens the settings content as a bottom sheet — the portrait watch
/// page's viewport chips mount it here instead of the in-viewport side
/// panel, which had to cram four tabs into the ~230px 16:9 box.
Future<void> showPlayerSettingsSheet(
  BuildContext context, {
  required VideoPlayerNotifierProvider vidPr,
  required EpisodeNotifierProvider epProvider,
  required ExtensionMeta meta,
  int initialTab = 0,
  bool showEpisodes = false,
}) {
  return showFSheet<void>(
    context: context,
    side: .btt,
    // Frosted-glass backdrop: the page behind blurs out instead of a flat
    // dark tint, so the translucent surface reads as depth, not a hole.
    style: FModalSheetStyleDelta.delta(
      barrierFilter: (context, animation) =>
          ImageFilter.blur(sigmaX: 10.0 * animation, sigmaY: 10.0 * animation),
    ),
    builder: (sheetContext) => SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.heightOf(context) * 0.62,
        // Translucent surface with rounded top corners — the whole sheet is
        // one clipped layer, so the full-bleed tab bar cannot paint past
        // the radius.
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: ColoredBox(
            color: sheetContext.theme.colors.background.withAlpha(216),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    decoration: BoxDecoration(
                      color: sheetContext.theme.colors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Sheet title — names the surface, same header treatment as
                // the cast sheet (body.lg + w600 over the handle).
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    'watch.playback_settings'.i18n,
                    style: sheetContext.theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: PlayerSettingsTabs(
                    vidPr: vidPr,
                    epProvider: epProvider,
                    meta: meta,
                    initialTab: initialTab,
                    showEpisodes: showEpisodes,
                    // The sheet has the room — normal labelled tab bar, not
                    // the docked panel's space-saving collapsing one.
                    expandable: false,
                    onClose: () => Navigator.of(sheetContext).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// The fullscreen player's docked panel: the same tabbed content as the
/// portrait sheet, slid in from the right edge of the video surface.
class SideSettingsMenu extends ConsumerWidget {
  const SideSettingsMenu({
    super.key,
    required this.vidPr,
    required this.epProvdier,
    required this.width,
    required this.meta,
  });

  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvdier;
  final double width;
  final ExtensionMeta meta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The chip deep-link: the panel stays mounted while hidden, so the tabs
    // are keyed on the requested pane — a new key re-selects it on open.
    final settingsTab = ref.watch(vidPr.select((s) => s.settingsTab));
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: context.theme.colors.background.withAlpha(240),
        border: Border(
          left: BorderSide(color: context.theme.colors.border, width: 1),
        ),
      ),
      child: PlayerSettingsTabs(
        key: ValueKey('side-settings-$settingsTab'),
        vidPr: vidPr,
        epProvider: epProvdier,
        meta: meta,
        initialTab: settingsTab,
        onClose: ref.read(vidPr.notifier).toggleSettings,
        // Close affordance riding the tab bar's leading edge: without it
        // the panel is a dead end until an episode is picked (the portrait
        // sheet keeps no X — it drags/backs away).
        leading: PlayerCircleButton(
          small: true,
          onPress: ref.read(vidPr.notifier).toggleSettings,
          semanticLabel: 'common.close'.i18n,
          icon: const Icon(FLucideIcons.x, size: 16),
        ),
      ),
    );
  }
}
