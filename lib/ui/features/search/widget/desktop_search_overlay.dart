import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/ui/core/core/blur.dart';
import 'package:miru_alpha/ui/core/core/glass_panel.dart';
import 'package:miru_alpha/ui/core/core/search_filter_card.dart';
import 'package:miru_alpha/ui/features/search/widget/global_search_bar.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Desktop top-bar search trigger. Sits in the window header row and opens the
/// [SearchOverlayPopup] on press.
class SearchTrigger extends HookConsumerWidget {
  const SearchTrigger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        ref.read(searchPageProvider.notifier).setOpen(true);
      },
      child: SearchFilterCard(
        child: Row(
          children: [
            Icon(
              FLucideIcons.search,
              size: 18,
              color: context.theme.colors.mutedForeground,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'common.search_globally'.i18n,
                style: context.theme.typography.body.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            ),
          ],
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
            child: Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  ref.read(searchPageProvider.notifier).setOpen(false);
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Shared search bar: type tabs + pinned toggle + input.
                          GlobalSearchBar(
                            autofocus: true,
                            onSubmit: (value) => _submit(context, ref, value),
                          ),
                          // Input → content separator, matching the reference's
                          // subtle `border-surface-container-high` line.
                          Container(
                            height: 1,
                            color: context.theme.colors.border,
                          ),
                          // Content sections - scrollable when needed
                          Flexible(
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ); // Added semicolon for return statement in block function
                  },
                ),
              ),
            ),
          ),
        ),
      ],
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
