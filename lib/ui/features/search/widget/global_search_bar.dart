import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/ui/core/core/tabbar.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/hook/tab_controller.dart';

/// Reusable, presentational search bar for the desktop search surface.
///
/// It is intentionally decoupled from any provider: callers pass the current
/// [query] and the callbacks. Depending on the mode it renders either:
///  * the **global** filter row (type tabs + pinned-scope toggle), or
///  * the **single-extension** row (extension chip + refresh).
///
/// Escape is two-stage while this bar is on screen: it clears the query first,
/// and only closes the surrounding overlay once the field is already empty.
class GlobalSearchBar extends HookWidget {
  const GlobalSearchBar({
    super.key,
    required this.controller,
    required this.query,
    required this.onQuerySubmitted,
    this.selectedType,
    this.onSelectedTypeChanged,
    this.pinnedScope = false,
    this.onPinnedScopeChanged,
    this.extensionContext,
    this.onRefresh,
    this.autofocus = false,
  });

  /// Owned by the surrounding overlay so its Escape handler can read/clear it
  /// (two-stage Esc). The bar never calls [TextEditingController.dispose].
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onQuerySubmitted;
  final ExtensionType? selectedType;
  final ValueChanged<ExtensionType?>? onSelectedTypeChanged;
  final bool pinnedScope;
  final ValueChanged<bool>? onPinnedScopeChanged;
  final ExtensionMeta? extensionContext;
  final VoidCallback? onRefresh;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();
    final hasText = useValueListenable(controller).text.isNotEmpty;

    // Keep the field in sync when the query changes from outside (e.g. arriving
    // on the single page with a preset query, or a deep link).
    useEffect(() {
      if (controller.text != query) controller.text = query;
      return null;
    }, [query]);

    final isSingle = extensionContext != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: isSingle
              ? _ExtensionRow(
                  extensionContext: extensionContext!,
                  onRefresh: onRefresh,
                )
              : _TypeFilterRow(
                  selectedType: selectedType,
                  onSelectedTypeChanged: onSelectedTypeChanged,
                  pinnedScope: pinnedScope,
                  onPinnedScopeChanged: onPinnedScopeChanged,
                ),
        ),
        // Header → input separator, full-bleed to match the reference's
        // edge-to-edge `border-surface-container-high` line.
        Container(height: 1, color: context.theme.colors.border),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                FLucideIcons.search,
                size: 20,
                color: context.theme.colors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FTextField(
                  autofocus: autofocus,
                  focusNode: focusNode,
                  control: FTextFieldControl.managed(controller: controller),
                  hint: 'extension.search_across_extensions'.i18n,
                  onSubmit: onQuerySubmitted,
                  suffixBuilder: (context, style, states) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        if (hasText)
                          FButton.icon(
                            variant: FButtonVariant.ghost,
                            onPress: () => controller.clear(),
                            child: Icon(FLucideIcons.x, size: 16),
                          ),
                        if (!isSingle)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: context.theme.colors.border,
                              ),
                              borderRadius: BorderRadius.circular(9999),
                              color: context.theme.colors.secondary,
                            ),
                            child: Text(
                              'Cmd+K',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: context.theme.colors.mutedForeground,
                              ),
                            ),
                          ),
                        if (isSingle)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: context.theme.colors.border,
                              ),
                              borderRadius: BorderRadius.circular(9999),
                              color: context.theme.colors.secondary,
                            ),
                            child: Text(
                              'Esc',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: context.theme.colors.mutedForeground,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Global mode: type filter tabs (All / Bangumi / Manga / Novel) plus the
/// pinned-scope toggle.
class _TypeFilterRow extends HookWidget {
  const _TypeFilterRow({
    required this.selectedType,
    required this.onSelectedTypeChanged,
    required this.pinnedScope,
    required this.onPinnedScopeChanged,
  });

  final ExtensionType? selectedType;
  final ValueChanged<ExtensionType?>? onSelectedTypeChanged;
  final bool pinnedScope;
  final ValueChanged<bool>? onPinnedScopeChanged;

  @override
  Widget build(BuildContext context) {
    final types = [
      ExtensionType.all,
      ExtensionType.bangumi,
      ExtensionType.manga,
      ExtensionType.fikushon,
    ];

    final initialIndex = selectedType == null
        ? 0
        : types.indexOf(selectedType!).clamp(0, types.length - 1);
    final controller = useMiruTabController(initialLength: types.length);

    useEffect(() {
      if (controller.index != initialIndex) {
        controller.animateTo(initialIndex);
      }
      void onChanged() {
        final index = controller.index;
        onSelectedTypeChanged?.call(types[index]);
      }

      controller.addListener(onChanged);
      return () => controller.removeListener(onChanged);
    }, [initialIndex]);

    return Row(
      children: [
        SizedBox(
          width: 400,
          height: 30,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: context.theme.colors.border),
              borderRadius: BorderRadius.circular(8),
              color: context.theme.colors.secondary,
            ),
            child: MiruTabBar(
              controller: controller,
              tabs: [
                for (final type in types)
                  Tab(
                    text: switch (type) {
                      ExtensionType.all => 'common.all'.i18n,
                      ExtensionType.bangumi => 'media.bangumi'.i18n,
                      ExtensionType.manga => 'media.manga'.i18n,
                      ExtensionType.fikushon => 'media.novel'.i18n,
                    },
                  ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'extension.search_with_pinned_extensions'.i18n,
                style: context.theme.typography.body.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            FSwitch(
              value: pinnedScope,
              onChange: (value) => onPinnedScopeChanged?.call(value),
            ),
          ],
        ),
      ],
    );
  }
}

/// Single-extension mode: a chip identifying the extension and an optional
/// refresh button. Filters are edited inline in the popup body below.
class _ExtensionRow extends StatelessWidget {
  const _ExtensionRow({required this.extensionContext, this.onRefresh});

  final ExtensionMeta extensionContext;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: context.theme.colors.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              if (extensionContext.icon != null &&
                  extensionContext.icon!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    MiruRequest.proxyUrl(extensionContext.icon!).toString(),
                    width: 18,
                    height: 18,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      FLucideIcons.puzzle,
                      size: 16,
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                )
              else
                Icon(
                  FLucideIcons.puzzle,
                  size: 16,
                  color: context.theme.colors.mutedForeground,
                ),
              Text(
                extensionContext.name,
                style: context.theme.typography.body.sm,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Spacer(),
        if (onRefresh != null)
          FButton.icon(
            variant: FButtonVariant.secondary,
            onPress: onRefresh,
            child: const Icon(FLucideIcons.refreshCcw),
          ),
      ],
    );
  }
}
