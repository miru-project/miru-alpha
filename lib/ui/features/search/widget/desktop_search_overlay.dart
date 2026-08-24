import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:miru_alpha/provider/search/current_single_extension.dart';
import 'package:miru_alpha/ui/core/core/blur.dart';
import 'package:miru_alpha/ui/core/core/glass_panel.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/features/search/extension_filter_view.dart';
import 'package:miru_alpha/ui/features/search/widget/global_search_bar.dart';
// ExtensionFilterBody is defined alongside SearchFilterDialog.
import 'package:miru_alpha/ui/features/search/widget/search_filter_dialog.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Desktop top-bar search trigger. Sits in the window header row and opens the
/// [SearchOverlayPopup] on press.
///
/// When the active route is `/search/single`, it shows the extension name
/// instead of the generic "search globally" hint, mirroring the single
/// extension context of the page beneath it.
class SearchTrigger extends HookConsumerWidget {
  const SearchTrigger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final singleMeta = ref.watch(currentSingleExtensionProvider);
    final hint = singleMeta?.name ?? 'common.search_globally'.i18n;
    return FTappable(
      behavior: HitTestBehavior.translucent,
      onPress: () {
        ref.read(searchPageProvider.notifier).setOpen(true);
      },
      child: Blur(
        borderRadius: context.theme.style.borderRadius.md,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: context.theme.colors.background.withAlpha(200),
            borderRadius: context.theme.style.borderRadius.md,
          ),
          child: MiruCard(
            child: Padding(
              padding: .symmetric(horizontal: 20, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FLucideIcons.search,
                    size: 18,
                    color: context.theme.colors.mutedForeground,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hint,
                      style: context.theme.typography.body.sm.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                      overflow: TextOverflow.ellipsis,
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
}

/// Full-bleed blurred + dimmed backdrop shown behind the search popup.
/// Tapping it closes the popup.
class SearchBackdrop extends StatelessWidget {
  const SearchBackdrop({super.key, this.onTap});
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Blur(
      blurDensity: 12,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(color: context.theme.colors.background.withAlpha(160)),
      ),
    );
  }
}

/// The centered, glass-panel search dialog with filter tabs, search input,
/// recent searches, frequent extensions, and info footer.
class SearchOverlayPopup extends HookConsumerWidget {
  const SearchOverlayPopup({super.key});

  void _submit(BuildContext context, WidgetRef ref, String value) {
    final keyword = value.trim();
    if (keyword.isEmpty) return;
    ref.read(searchPageProvider.notifier)
      ..addHistory(keyword)
      ..setOpen(false);
    context.push('/search', extra: keyword);
  }

  /// Submit handler for single-extension mode: updates the active
  /// `/search/single` page's query instead of navigating to the global search.
  void _submitSingle(
    BuildContext context,
    WidgetRef ref,
    String value,
    ExtensionMeta meta,
  ) {
    final keyword = value.trim();
    if (keyword.isEmpty) return;
    ref.read(searchPageProvider.notifier).addHistory(keyword);
    ref.read(searchPageSingleProviderProvider.notifier).setQuery(keyword);
    ref.read(searchPageProvider.notifier).setOpen(false);
  }

  void _onExtensionChipTap(
    BuildContext context,
    WidgetRef ref,
    String pkgName,
  ) {
    ref.read(searchPageProvider.notifier)
      ..addHistory('pkg:$pkgName ')
      ..setOpen(false);
    context.push('/search', extra: 'pkg:$pkgName ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageProvider);
    final singleMeta = ref.watch(currentSingleExtensionProvider);
    final singleState = singleMeta == null
        ? null
        : ref.watch(searchPageSingleProviderProvider);
    // Owned here so the Escape handler below can implement two-stage Esc:
    // first press clears the query, second (when already empty) closes.
    final searchController = useTextEditingController(
      text: singleState?.query ?? state.query,
    );

    // Two-stage Escape. Handled via a keyboard listener instead of a `Focus`
    // widget because the explicit `Focus` + the focusable `FButton`s inside
    // the panel trigger a Flutter semantics assertion
    // (`!semantics.parentDataDirty`) in the current SDK's semantics pass.
    //
    // Stage 1: text in the field → clear it and keep the popup open.
    // Stage 2: field already empty → close the popup. This is the single owner
    // of Esc handling for the whole overlay; `HardwareKeyboard` broadcasts to
    // every handler, so splitting stages across widgets cannot work reliably.
    useEffect(() {
      bool handler(KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          if (searchController.text.isNotEmpty) {
            searchController.clear();
          } else {
            ref.read(searchPageProvider.notifier).setOpen(false);
          }
          return true;
        }
        return false;
      }

      HardwareKeyboard.instance.addHandler(handler);
      return () => HardwareKeyboard.instance.removeHandler(handler);
    }, const []);

    return Stack(
      children: [
        Positioned.fill(
          child: SearchBackdrop(
            onTap: () {
              ref.read(searchPageProvider.notifier).setOpen(false);
            },
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 760,
              minWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: GlassPanel(
              borderRadius: BorderRadius.circular(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                      maxHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        // Shared search bar. In single-extension mode it shows
                        // the extension name + filter controls; otherwise the
                        // global type tabs + pinned toggle.
                        GlobalSearchBar(
                          autofocus: true,
                          controller: searchController,
                          query: singleState?.query ?? state.query,
                          onQuerySubmitted: (value) => singleMeta == null
                              ? _submit(context, ref, value)
                              : _submitSingle(context, ref, value, singleMeta),
                          selectedType: state.selectedType,
                          onSelectedTypeChanged: (type) => ref
                              .read(searchPageProvider.notifier)
                              .setSelectedType(type),
                          pinnedScope: state.pinnedScope,
                          onPinnedScopeChanged: (value) => ref
                              .read(searchPageProvider.notifier)
                              .setPinnedScope(value),
                          extensionContext: singleMeta,
                          onRefresh: singleMeta == null
                              ? null
                              : () => ref.invalidate(
                                  fetchExtensionSearchLatestProvider.call(
                                    singleMeta.packageName,
                                    1,
                                    query: singleState!.query,
                                    filter: singleState.appliedFilter,
                                  ),
                                ),
                        ),
                        // Input → content separator, matching the reference's
                        // subtle `border-surface-container-high` line.
                        Container(
                          height: 1,
                          color: context.theme.colors.border,
                        ),
                        // Content sections - scrollable when needed.
                        //
                        // NOTE: The section list (recent searches, frequent
                        // extensions, active-filter summary, extension filter
                        // body) uses Forui `FButton`s and a `GridView`. On the
                        // current Flutter SDK these render objects trigger a
                        // framework semantics assertion
                        // (`!childSemantics.renderObject._needsLayout`) during
                        // the semantics pass. Wrapping them in
                        // `ExcludeSemantics` keeps them out of the semantics
                        // tree (the underlying crash is a Flutter SDK bug, not
                        // our layout) while leaving them fully interactive.
                        Flexible(
                          child: ExcludeSemantics(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth - 32,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 24,
                                  children: [
                                    if (singleMeta == null) ...[
                                      if (state.history.isNotEmpty)
                                        _RecentSearchesSection(
                                          history: state.history,
                                          onSubmit: (value) =>
                                              _submit(context, ref, value),
                                        ),
                                      if (state.recentExtensions.isNotEmpty)
                                        _FrequentExtensionsSection(
                                          extensions: state.recentExtensions,
                                          onTap: (pkg) => _onExtensionChipTap(
                                            context,
                                            ref,
                                            pkg,
                                          ),
                                        ),
                                      _InfoFooter(),
                                    ] else ...[
                                      // Active-filter summary chips (removable),
                                      // mirroring the reference's applied-filter
                                      // row. No _InfoFooter here: the sticky
                                      // _SingleFilterFooter below already ends
                                      // with one, so two would stack.
                                      const _ActiveFilterSummary(),
                                      const ExtensionFilterBody(),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Single-extension footer: source label + Clear/Apply.
                        if (singleMeta != null)
                          ExcludeSemantics(
                            child: _SingleFilterFooter(meta: singleMeta),
                          ),
                      ],
                    ),
                  ); // Added semicolon for return statement in block function
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Removable chips listing every currently-applied filter on the single
/// extension page, matching the reference's active-filter summary row.
class _ActiveFilterSummary extends ConsumerWidget {
  const _ActiveFilterSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageSingleProviderProvider);
    final notifier = ref.read(searchPageSingleProviderProvider.notifier);
    final filters = state.filter;
    final selected = state.selected;
    final order = state.filterOrder;

    final chips = <Widget>[];
    for (final key in order) {
      final raw = filters[key];
      if (raw == null) continue;
      final sel = selected[key] ?? [];
      if (sel.isEmpty) continue;
      if (raw.whichKind() == ExtensionFilter_Kind.range) {
        chips.add(
          _FilterChip(
            label: '${sel[0]} - ${sel[1]}',
            onRemove: () => notifier.resetFilterToDefault(key),
          ),
        );
      } else if (raw.whichKind() == ExtensionFilter_Kind.select) {
        final view = ExtensionFilterView.from(raw);
        final label = view.options.where((o) => o.key == sel.first).isEmpty
            ? sel.first
            : view.options.firstWhere((o) => o.key == sel.first).label;
        chips.add(
          _FilterChip(
            label: label,
            onRemove: () => notifier.clearFilterValue(key),
          ),
        );
      } else {
        // Multi-select: one removable chip per selected option.
        final view = ExtensionFilterView.from(raw);
        final labelByKey = {for (final o in view.options) o.key: o.label};
        for (final k in sel) {
          chips.add(
            _FilterChip(
              label: labelByKey[k] ?? k,
              onRemove: () {
                final next = List<String>.from(sel)..remove(k);
                notifier.setFilterValue(key, next);
              },
            ),
          );
        }
      }
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final primary = context.theme.colors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primary.withAlpha(20),
        border: Border.all(color: primary.withAlpha(80)),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Text(
            label,
            style: context.theme.typography.body.sm.copyWith(color: primary),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(FLucideIcons.x, size: 14, color: primary),
          ),
        ],
      ),
    );
  }
}

/// Footer for the single-extension search dialog: source label plus the
/// Clear / Apply actions that commit (or reset) the filters and refresh.
class _SingleFilterFooter extends ConsumerWidget {
  const _SingleFilterFooter({required this.meta});
  final ExtensionMeta meta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(searchPageSingleProviderProvider.notifier);
    final resultCount = ref.watch(
      searchPageSingleProviderProvider.select((s) => s.result.length),
    );
    void invalidate() => ref.invalidate(
      fetchExtensionSearchLatestProvider.call(
        meta.packageName,
        1,
        query: ref.read(searchPageSingleProviderProvider).query,
        filter: ref.read(searchPageSingleProviderProvider).appliedFilter,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'extension.results_count'.i18n.replaceAll(
                        '{count}',
                        resultCount.toString(),
                      ),
                      style: context.theme.typography.body.sm.copyWith(
                        color: context.theme.colors.primary,
                      ),
                    ),
                    Text(
                      'extension.source'.i18n.replaceAll('{name}', meta.name),
                      style: context.theme.typography.body.xs.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                spacing: 8,
                children: [
                  FButton(
                    variant: .outline,
                    onPress: () async {
                      await notifier.clearFiltersToDefault();
                      invalidate();
                      ref.read(searchPageProvider.notifier).setOpen(false);
                    },
                    child: Text('extension.clear'.i18n),
                  ),
                  FButton(
                    onPress: () {
                      notifier.commitFilters();
                      invalidate();
                      ref.read(searchPageProvider.notifier).setOpen(false);
                    },
                    child: Text('extension.apply'.i18n),
                  ),
                ],
              ),
            ],
          ),
          _InfoFooter(),
        ],
      ),
    );
  }
}

class _RecentSearchesSection extends ConsumerWidget {
  const _RecentSearchesSection({required this.history, required this.onSubmit});

  final List<String> history;
  final void Function(String) onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          children: [
            Text(
              'extension.recent_searches'.i18n,
              style: context.theme.typography.body.xs.copyWith(
                color: context.theme.colors.mutedForeground,
                letterSpacing: 0.5,
                fontSize: 11,
              ),
            ),
            const Spacer(),
            FButton.icon(
              variant: FButtonVariant.ghost,
              onPress: () =>
                  ref.read(searchPageProvider.notifier).clearHistory(),
              child: Icon(FLucideIcons.trash, size: 14),
            ),
          ],
        ),
        ...history.asMap().entries.map((entry) {
          final item = entry.value;
          return _RecentSearchTile(
            key: ValueKey(item),
            query: item,
            onSubmit: onSubmit,
          );
        }),
      ],
    );
  }
}

class _RecentSearchTile extends ConsumerWidget {
  const _RecentSearchTile({
    required this.query,
    required this.onSubmit,
    super.key,
  });

  final String query;
  final void Function(String) onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Try to extract type from pkg prefix
    String? typeLabel;
    final pkgMatch = RegExp(r'^pkg:(\w+)\s').firstMatch(query);
    if (pkgMatch != null) {
      final pkg = pkgMatch.group(1)!;
      final ext = ref
          .read(searchPageProvider.select((s) => s.metaData))
          .where((e) => e.packageName == pkg)
          .firstOrNull;
      if (ext != null) {
        typeLabel = _typeToLabel(context, ext.type);
      }
    }

    return FButton(
      variant: FButtonVariant.ghost,
      onPress: () {
        onSubmit(query);
      },
      child: Row(
        children: [
          Icon(
            FLucideIcons.history,
            size: 18,
            color: context.theme.colors.mutedForeground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              query,
              style: context.theme.typography.body.sm,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (typeLabel != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.theme.colors.muted,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                typeLabel,
                style: context.theme.typography.body.xs.copyWith(fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _typeToLabel(BuildContext context, ExtensionType type) {
    switch (type) {
      case ExtensionType.bangumi:
        return 'media.bangumi'.i18n;
      case ExtensionType.manga:
        return 'media.manga'.i18n;
      case ExtensionType.fikushon:
        return 'media.novel'.i18n;
      default:
        return 'common.all'.i18n;
    }
  }
}

class _FrequentExtensionsSection extends ConsumerWidget {
  const _FrequentExtensionsSection({
    required this.extensions,
    required this.onTap,
  });

  final List<String> extensions;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          'extension.frequent_extensions'.i18n,
          style: context.theme.typography.body.xs.copyWith(
            color: context.theme.colors.mutedForeground,
            letterSpacing: 0.5,
            fontSize: 11,
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3.5,
          ),
          itemCount: extensions.length,
          itemBuilder: (context, index) {
            final pkg = extensions[index];
            final ext = ref
                .read(searchPageProvider.select((s) => s.metaData))
                .where((e) => e.packageName == pkg)
                .firstOrNull;

            return FButton(
              variant: FButtonVariant.outline,
              onPress: () => onTap(pkg),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Icon(
                    FLucideIcons.puzzle,
                    size: 18,
                    color: context.theme.colors.mutedForeground,
                  ),
                  Flexible(
                    child: Text(
                      ext?.name ?? pkg,
                      style: context.theme.typography.body.sm,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _InfoFooter extends StatelessWidget {
  const _InfoFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.theme.colors.border)),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: context.theme.colors.border.withAlpha(50),
            ),
            borderRadius: BorderRadius.circular(8),
            color: context.theme.colors.secondary,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Icon(
                FLucideIcons.info,
                size: 16,
                color: context.theme.colors.primary,
              ),
              Flexible(
                child: Text(
                  'extension.content_from_extensions'.i18n,
                  style: context.theme.typography.body.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
