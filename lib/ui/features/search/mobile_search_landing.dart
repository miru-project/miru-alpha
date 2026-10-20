import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/ui/features/search/widget/extension_load_status.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/storage_index.dart';

/// Body of the `/search` tab: the "Extension Sources" heading with its
/// available-count badge, the source cards and the sync footnote, as slivers.
///
/// Slivers rather than a widget wrapping a `ListView` so they share the
/// scaffold's scroll context with the pinned headers — that is what lets the
/// big title collapse while the cards move. The heading and the footnote
/// travel with the list; only the Type / Status / Sort pill row is pinned in
/// [SearchSourceFilterBar] above.
List<Widget> mobileSearchSourceSlivers(BuildContext context, WidgetRef ref) {
  final state = ref.watch(searchPageProvider);
  final notifier = ref.read(searchPageProvider.notifier);
  final sources = _filteredSources(state);

  void togglePin(ExtensionMeta meta) {
    final next = {...state.existedPinnedExtensions};
    final wasPinned = next.remove(meta.packageName);
    if (!wasPinned) next.add(meta.packageName);
    MiruSettings.setSettingSync(SettingKey.pinnedExtension, next.toString());
    notifier.setExistedPinnedExtensions(next);
    // A pinned source is never hidden (the status filter treats the two as
    // disjoint), so pinning one from the hidden view restores it to the list.
    if (!wasPinned && state.hiddenExtensions.contains(meta.packageName)) {
      final hidden = {...state.hiddenExtensions}..remove(meta.packageName);
      MiruSettings.setSettingSync(
        SettingKey.hiddenExtension,
        hidden.toString(),
      );
      notifier.setHiddenExtensions(hidden);
    }
  }

  void toggleHidden(ExtensionMeta meta) {
    final next = {...state.hiddenExtensions};
    if (!next.remove(meta.packageName)) next.add(meta.packageName);
    MiruSettings.setSettingSync(SettingKey.hiddenExtension, next.toString());
    notifier.setHiddenExtensions(next);
  }

  return [
    const SliverToBoxAdapter(child: SizedBox(height: 20)),
    // The list's own heading: label plus the visible-source count badge. It
    // scrolls with the cards — only the pill bar above is pinned.
    SliverToBoxAdapter(
      child: SearchSectionHeader(
        title: 'search.extension_sources'.i18n,
        trailing: FBadge(
          variant: .secondary,
          child: Text(
            'search.sources_available'.i18n.fill({
              'count': '${state.visibleMetaData.length}',
            }),
          ),
        ),
      ),
    ),
    const SliverToBoxAdapter(child: SizedBox(height: 4)),
    if (sources.isEmpty)
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text(
            'extension.no_extensions_installed'.i18n,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ),
      )
    else
      SliverList.builder(
        itemCount: sources.length,
        itemBuilder: (context, index) {
          final meta = sources[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: kSearchCardGap),
            child: _SourceCard(
              meta: meta,
              pinned: state.existedPinnedExtensions.contains(meta.packageName),
              hidden: state.hiddenExtensions.contains(meta.packageName),
              onPinTap: () => togglePin(meta),
              onToggleHidden: () => toggleHidden(meta),
              onOpen: () => context.push(
                '/search/single',
                extra: SearchPageParam(meta: meta),
              ),
              onSettings: () => context.push<ExtensionSettingParam>(
                '/extensionSettings',
                extra: ExtensionSettingParam(
                  pkg: meta.packageName,
                  name: meta.name,
                ),
              ),
              onShowError: () => showExtensionError(context, meta),
            ),
          );
        },
      ),
    // Mock's status footnote: quiet when everything is healthy, a named
    // failure list otherwise. Counts the whole visible pool — the list above
    // may be narrowed by the pills, but sync health is page-wide.
    if (state.visibleMetaData.isNotEmpty)
      SliverToBoxAdapter(
        child: _SyncedFootnote(sources: state.visibleMetaData),
      ),
    const SliverToBoxAdapter(child: SizedBox(height: 32)),
  ];
}

/// The installed sources after the tab's type / status filters and order.
List<ExtensionMeta> _filteredSources(SearchPageState state) {
  var list = state.filteredMetaData;
  final type = state.sourceType;
  if (type != null) {
    list = list.where((e) => e.type == type).toList();
  }
  switch (state.sourceStatus) {
    case SearchSourceStatus.all:
      list = list
          .where((e) => !state.hiddenExtensions.contains(e.packageName))
          .toList();
    case SearchSourceStatus.pinned:
      // Pinned and hidden are disjoint by construction (pinning a hidden
      // source restores it), so no second filter is needed here.
      list = list
          .where((e) => state.existedPinnedExtensions.contains(e.packageName))
          .toList();
    case SearchSourceStatus.unpinned:
      list = list
          .where((e) => !state.existedPinnedExtensions.contains(e.packageName))
          .where((e) => !state.hiddenExtensions.contains(e.packageName))
          .toList();
    case SearchSourceStatus.hidden:
      // The management view: every hidden source, so the eye button can bring
      // it back without hunting for it in the main list.
      list = list
          .where((e) => state.hiddenExtensions.contains(e.packageName))
          .toList();
  }
  final sorted = [...list];
  switch (state.sourceSort) {
    case SearchSourceSort.pinned:
      sorted.sort((a, b) {
        final rank = _pinnedRank(state, a).compareTo(_pinnedRank(state, b));
        return rank != 0 ? rank : a.name.compareTo(b.name);
      });
    case SearchSourceSort.name:
      sorted.sort((a, b) => a.name.compareTo(b.name));
    case SearchSourceSort.version:
      sorted.sort((a, b) => b.version.compareTo(a.version));
  }
  return sorted;
}

int _pinnedRank(SearchPageState state, ExtensionMeta meta) =>
    state.existedPinnedExtensions.contains(meta.packageName) ? 0 : 1;

/// One configured source: identity, version line, pin / visibility and
/// settings actions.
class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.meta,
    required this.pinned,
    required this.hidden,
    required this.onPinTap,
    required this.onToggleHidden,
    required this.onOpen,
    required this.onSettings,
    required this.onShowError,
  });

  final ExtensionMeta meta;
  final bool pinned;

  /// Whether the user hid this source (only ever true inside the `hidden`
  /// status view — hidden sources leave every other list).
  final bool hidden;
  final VoidCallback onPinTap;
  final VoidCallback onToggleHidden;
  final VoidCallback onOpen;
  final VoidCallback onSettings;
  final VoidCallback onShowError;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final loadState = extensionLoadState(meta);
    final broken = loadState?.failed ?? false;
    return FTappable(
      // A failed extension has nothing to search, so the tile is inert:
      // only the error affordance is interactive.
      onPress: broken ? null : onOpen,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: meta.icon == null || meta.icon!.isEmpty
                  ? Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        meta.name.isEmpty ? '?' : meta.name[0].toUpperCase(),
                        style: context.theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ImageWidget(
                        imageUrl: meta.icon,
                        width: 40,
                        height: 40,
                      ),
                    ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: Text(
                          meta.name,
                          style: context.theme.typography.body.sm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Natural width: the badge must never ellipsise, so only
                      // the name is allowed to shrink.
                      FBadge(
                        variant: .secondary,
                        child: Text(
                          searchExtensionTypeLabel(meta.type),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (meta.nsfw) ...[
                        const SizedBox(width: 4),
                        FBadge(
                          variant: .destructive,
                          child: Text('extension.nsfw'.i18n),
                        ),
                      ],
                    ],
                  ),
                  if (extensionLoadState(meta) case final state?) ...[
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          if (state.failed) ...[
                            // The red word own the reading order, then the
                            // backend's own message.
                            TextSpan(
                              text: 'extension.failed'.i18n,
                              style: context.theme.typography.body.xs.copyWith(
                                color: colors.destructive,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: '  '),
                          ],
                          TextSpan(
                            text: state.label,
                            style: context.theme.typography.body.xs.copyWith(
                              color: state.failed
                                  ? colors.destructive
                                  : colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (meta.version.isNotEmpty)
                        searchVersionLabel(meta.version),
                      if (meta.description?.isNotEmpty ?? false)
                        meta.description!,
                    ].join(' • '),
                    style: context.theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Broken cards keep the error affordance (nothing else works on
            // them) and gain whatever declutters them: the eye to hide a dead
            // source, the unpin to drop it from the pinned scope. No pin, no
            // settings — a source that cannot load has nothing to configure
            // into working. Pinned sources are protected from the eye.
            if (broken)
              FButton.icon(
                variant: .ghost,
                onPress: onShowError,
                child: Icon(
                  FLucideIcons.circleAlert,
                  size: 17,
                  color: colors.destructive,
                ),
              )
            else if (!pinned)
              FButton.icon(
                variant: .ghost,
                onPress: onPinTap,
                child: Icon(
                  FLucideIcons.pin,
                  size: 17,
                  color: colors.mutedForeground,
                ),
              ),
            if (!pinned)
              FButton.icon(
                variant: .ghost,
                onPress: onToggleHidden,
                child: Icon(
                  hidden ? FLucideIcons.eye : FLucideIcons.eyeOff,
                  size: 17,
                  color: hidden ? colors.foreground : colors.mutedForeground,
                ),
              )
            else
              FButton.icon(
                variant: .ghost,
                onPress: onPinTap,
                child: Icon(
                  FLucideIcons.pinOff,
                  size: 17,
                  color: colors.foreground,
                ),
              ),
            if (!broken)
              FButton.icon(
                variant: .ghost,
                onPress: onSettings,
                child: Icon(FLucideIcons.settings, size: 17),
              ),
          ],
        ),
      ),
    );
  }
}

/// The mock's page-bottom status line: a quiet "all synced" when every
/// source is healthy, the failing names (red) when any load failed.
///
/// Pure — the load states are read per build from [extensionLoadState]; the
/// widget rebuilds with the page when metadata or load state changes.
class _SyncedFootnote extends StatelessWidget {
  const _SyncedFootnote({required this.sources});

  final List<ExtensionMeta> sources;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final failed = [
      for (final e in sources)
        if (extensionLoadState(e)?.failed ?? false) e.name,
    ];
    final style = context.theme.typography.body.xs.copyWith(
      color: failed.isEmpty ? colors.mutedForeground : colors.destructive,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                failed.isEmpty
                    ? FLucideIcons.circleCheck
                    : FLucideIcons.circleAlert,
                size: 15,
                color: style.color,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  failed.isEmpty
                      ? 'search.all_synced'.i18n.fill({
                          'count': '${sources.length}',
                        })
                      : 'search.failed_sources'.i18n.fill({
                          'names': failed.join(', '),
                        }),
                  style: style,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
