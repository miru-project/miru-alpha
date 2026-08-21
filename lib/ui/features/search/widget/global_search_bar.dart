import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/ui/core/core/tabbar.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/hook/tab_controller.dart';

/// Shared search bar for the global search surface.
///
/// Used by both the desktop `/search` results page and the command-palette
/// overlay so the two entry points stay visually and behaviorally identical
/// (deduped into one widget). It bundles the type filter tabs, the pinned-scope
/// toggle, and the query input. All persistent state lives in
/// [searchPageProvider]; [onSubmit] fires when the user commits the query.
class GlobalSearchBar extends HookConsumerWidget {
  const GlobalSearchBar({
    super.key,
    required this.onSubmit,
    this.autofocus = false,
  });

  final ValueChanged<String> onSubmit;
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageProvider);
    final controller = useTextEditingController(text: state.query);
    final focusNode = useFocusNode();
    final hasText = useValueListenable(controller).text.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: const _TypeFilterRow(),
        ),
        // Header → input separator, full-bleed (edge-to-edge) to match the
        // reference's `border-surface-container-high` line instead of being
        // inset by padding.
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
                // Kept wrapped in ExcludeSemantics per request; revisit for
                // screen-reader access to the search field.
                child: ExcludeSemantics(
                  child: FTextField(
                    autofocus: autofocus,
                    focusNode: focusNode,
                    control: FTextFieldControl.managed(controller: controller),
                    hint: 'extension.search_across_extensions'.i18n,
                    onSubmit: onSubmit,
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
                          const SizedBox(width: 8),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Type filter tabs (All / Bangumi / Manga / Novel) plus the pinned-scope
/// toggle. Drives [SearchPageState.selectedType] and
/// [SearchPageState.pinnedScope].
class _TypeFilterRow extends HookConsumerWidget {
  const _TypeFilterRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(
      searchPageProvider.select((s) => s.selectedType),
    );
    final pinnedScope = ref.watch(
      searchPageProvider.select((s) => s.pinnedScope),
    );

    final types = [
      ExtensionType.all,
      ExtensionType.bangumi,
      ExtensionType.manga,
      ExtensionType.fikushon,
    ];

    // null maps to the 'All' tab (index 0); no deselect is possible via TabBar.
    final initialIndex = selectedType == null
        ? 0
        : types.indexOf(selectedType).clamp(0, types.length - 1);
    final controller = useMiruTabController(initialLength: types.length);

    useEffect(() {
      // Sync external state into the TabBar when it changes.
      if (controller.index != initialIndex) {
        controller.animateTo(initialIndex);
      }
      void onChanged() {
        final index = controller.index;
        ref.read(searchPageProvider.notifier).setSelectedType(types[index]);
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
              onChange: (value) {
                ref.read(searchPageProvider.notifier).setPinnedScope(value);
              },
            ),
          ],
        ),
      ],
    );
  }
}
