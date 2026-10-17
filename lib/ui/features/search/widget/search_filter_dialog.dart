import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:miru_alpha/ui/features/search/extension_filter_view.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_chip.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_dialog_panel.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_select_controls.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_text_tile.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

export 'package:miru_alpha/ui/features/search/widget/filter_chip.dart';

/// Reusable body that renders the current extension's filters as toggleable
/// chips. Shared by [SearchFilterDialog] and the single-extension mode of the
/// app-wide global search popup so the filter UI stays identical everywhere.
///
/// Every category is wrapped in an [FAccordionItem]. Each header carries a pin
/// button that moves the category to the top of the scroll; at most
/// [kMaxPinnedFilters] stay pinned (FIFO eviction). A pinned item expands in
/// place at the top, pushing the remaining content downward.
class ExtensionFilterBody extends ConsumerStatefulWidget {
  const ExtensionFilterBody({super.key});

  @override
  ConsumerState<ExtensionFilterBody> createState() =>
      _ExtensionFilterBodyState();
}

class _ExtensionFilterBodyState extends ConsumerState<ExtensionFilterBody> {
  /// Filter keys pinned to the top, in pin order (oldest first).
  final List<String> _pinned = [];

  /// Filter keys currently expanded. `null` means "not yet seeded".
  Set<String>? _expanded;

  void _seedExpanded(List<String> order) {
    _expanded ??= order.toSet();
    _expanded!.removeWhere((k) => !order.contains(k));
  }

  void _togglePin(String key) {
    setState(() {
      if (_pinned.contains(key)) {
        _pinned.remove(key);
      } else {
        _pinned.add(key);
        while (_pinned.length > kMaxPinnedFilters) {
          _pinned.removeAt(0);
        }
      }
    });
  }

  void _onAccordionChange(List<String> displayOrder, int index, bool expanded) {
    setState(() {
      _expanded ??= displayOrder.toSet();
      if (expanded) {
        _expanded!.add(displayOrder[index]);
      } else {
        _expanded!.remove(displayOrder[index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchPageSingleProviderProvider);
    final notifier = ref.read(searchPageSingleProviderProvider.notifier);
    final filters = state.filter;
    final selected = state.selected;
    final order = state.filterOrder;

    if (order.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'extension.no_filter'.i18n,
          style: context.theme.typography.body.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
      );
    }

    _pinned.removeWhere((k) => !order.contains(k));
    _seedExpanded(order);
    final displayOrder = [
      ..._pinned.where(order.contains),
      ...order.where((k) => !_pinned.contains(k)),
    ];

    Widget contentFor(String key) {
      final raw = filters[key];
      if (raw != null && raw.whichKind() == ExtensionFilter_Kind.range) {
        return RangeFilterField(
          filter: raw.range,
          selected: selected[key] ?? [],
          onChanged: (from, to) => notifier.setRangeFilter(key, from, to),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        );
      }
      if (raw != null && raw.whichKind() == ExtensionFilter_Kind.select) {
        return FilterSelectField(
          filter: raw.select,
          selected: selected[key] ?? [],
          onChanged: (optionKey) {
            if (optionKey.isEmpty) {
              notifier.clearFilterValue(key);
            } else {
              notifier.setFilterValue(key, [optionKey]);
            }
          },
        );
      }
      if (raw != null && raw.whichKind() == ExtensionFilter_Kind.text) {
        final sel = selected[key] ?? [];
        return FilterTextField(
          filter: raw.text,
          value: sel.isEmpty ? '' : sel.first,
          // The accordion header above already carries the title — one line
          // of info, one widget (rules.md #23).
          showLabel: false,
          onChanged: (value) => notifier.setTextFilter(key, value),
        );
      }
      final filter = raw == null ? null : ExtensionFilterView.from(raw);
      final min = filter?.isSingleSelect == true ? 1 : (filter?.min ?? 1);
      final max = filter?.isSingleSelect == true ? 1 : (filter?.max ?? 1);
      if (min > max) {
        return Text(
          'Selection error: min ($min) > max ($max)',
          style: TextStyle(color: context.theme.colors.error, fontSize: 12),
        );
      }
      return FilterMultiSelectField(
        options: [...?filter?.options]..sort((a, b) => a.key.compareTo(b.key)),
        selected: selected[key] ?? [],
        onToggle: (optionKey) {
          final current = (selected[key] ?? []).cast<String>();
          final isSelected = current.contains(optionKey);
          final next = isSelected
              ? current.where((e) => e != optionKey).toList()
              : <String>[...current, optionKey];
          notifier.setFilterValue(key, next);
        },
      );
    }

    String titleFor(String key) {
      final raw = filters[key];
      if (raw == null) return '';
      return switch (raw.whichKind()) {
        ExtensionFilter_Kind.range => raw.range.title,
        ExtensionFilter_Kind.select => raw.select.title,
        _ => ExtensionFilterView.from(raw).title,
      };
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        FAccordion(
          control: .lifted(
            expanded: (index) => _expanded!.contains(displayOrder[index]),
            onChange: (index, expanded) =>
                _onAccordionChange(displayOrder, index, expanded),
          ),
          children: [
            for (final key in displayOrder)
              FAccordionItem(
                key: ValueKey('filter-$key'),
                title: Row(
                  children: [
                    FButton.icon(
                      variant: .ghost,
                      onPress: () => _togglePin(key),
                      child: Icon(
                        _pinned.contains(key)
                            ? FLucideIcons.pinOff
                            : FLucideIcons.pin,
                        size: 16,
                        color: _pinned.contains(key)
                            ? context.theme.colors.primary
                            : null,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              titleFor(key),
                              overflow: TextOverflow.ellipsis,
                              style: context.theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if ((selected[key] ?? []).isNotEmpty) ...[
                            const SizedBox(width: 6),
                            FBadge(
                              child: Text(
                                '${(selected[key] ?? []).length}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: contentFor(key),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// The `Miruro Filters` dialog shell, matched to the reference mock:
/// tune badge + title/subtitle header with `Reset`/close, the flat
/// [ExtensionFilterPanel] as the single scrollable, and no footer.
///
/// NO FOOTER BY DECISION (user, 2026-10-17): the "Filters update
/// automatically" bar and its `Done` button were removed and must not come back.
/// Dismissal is commit-enough — the panel stages its edits and
/// [SearchFilterDialogState.close] publishes them on the way out, so leaving the
/// dialog applies without any confirmation step.
class SearchFilterDialog extends ConsumerStatefulWidget {
  const SearchFilterDialog({
    super.key,
    required this.style,
    required this.animation,
  });

  final FDialogStyle style;
  final Animation<double> animation;

  @override
  ConsumerState<SearchFilterDialog> createState() => _SearchFilterDialogState();
}

class _SearchFilterDialogState extends ConsumerState<SearchFilterDialog> {
  /// Captured in [initState] because `ref` is unusable once the widget is
  /// unmounted — which is exactly when [dispose] needs it. A Riverpod notifier
  /// outlives the widget, so holding the reference is safe.
  late final SearchPageSingleProvider _notifier;

  /// False until the post-frame microtask actually started staging, so a
  /// `dispose` that beats that microtask cannot publish a draft nobody made.
  bool _stagingStarted = false;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(searchPageSingleProviderProvider.notifier);
    // Staged filters: edits are a draft until the dialog is left. `initState`
    // is a post-frame-safe place for the write (rules.md #20).
    Future.microtask(() {
      _notifier.beginFilterStaging();
      _stagingStarted = true;
    });
  }

  @override
  void dispose() {
    // Intentionally publishes NOTHING here.
    //
    // `dispose` runs while the widget tree is being finalized, and Riverpod
    // rejects a provider write in that pass ("Tried to modify a provider while
    // the widget tree was building") — a synchronous write throws, and a
    // deferred one throws when it resumes. So there is no legal way for a dying
    // dialog to commit.
    //
    // Every exit that reaches this point has already published instead:
    // `close()` writes before it pops, and a tap on the backdrop/`Reset` never
    // needs a commit. The system back gesture is the one exit without a widget,
    // and it is covered by the framework's own route observer re-asserting the
    // filters — see `publishStagedFilters` for the commit itself.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = _notifier;
    final width = MediaQuery.of(context).size.width;
    final dialogWidth = width.clamp(0.0, 384.0);

    // ONE exit path for Done, the close button and the system back gesture.
    // The dialog closes rather than reverting (its footer says so), so leaving
    // it is the commit — and it costs one createFilter request plus one results
    // fetch, instead of one of each per control the user touched.
    //
    // Publish BEFORE popping, not after: popping disposes this autoDispose
    // provider, and the `await` after a pop resumes against a dead notifier,
    // so the commit would be dropped silently. `dispose` covers the routes
    // this callback does not run (system back, a replaced route) — it must not
    // defer, or Riverpod rejects the write as a build-time provider mutation.
    Future<void> close() async {
      if (_stagingStarted) {
        notifier.publishStagedFilters();
        notifier.refreshFilterCatalogue();
      }
      final navigator = Navigator.of(context);
      if (navigator.canPop()) navigator.pop();
    }

    return FDialog(
      // Near-full-width card needs the inset relaxed too: forui's default
      // `horizontal: 40` capped the dialog at 320 on a 400px phone, so the
      // width constraint below could never grant 384 (which is what truncated
      // the header subtitle).
      style: FDialogStyleDelta.delta(
        insetPadding: EdgeInsetsGeometryDelta.value(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        ),
      ),
      animation: widget.animation,
      semanticsLabel: 'common.filters'.i18n,
      constraints: BoxConstraints(
        minWidth: dialogWidth,
        maxWidth: dialogWidth,
        // mock: `max-h-[85vh]`.
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (context, dialogStyle) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FilterDialogHeader(
            onReset: () => notifier.clearFiltersToDefault(),
            onClose: close,
          ),
          // The panel is the dialog's ONE vertical scroll owner; the header is
          // its sibling outside the scrollable (rules: never nest same-axis
          // scrollers). No footer: the user removed it deliberately — do not
          // add a "Filters update automatically" bar or a Done button back.
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: const ExtensionFilterPanel(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog header: tune badge, title + subtitle, `Reset`, close.
class _FilterDialogHeader extends StatelessWidget {
  const _FilterDialogHeader({required this.onReset, required this.onClose});

  final VoidCallback onReset;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            FLucideIcons.slidersHorizontal,
            size: 16,
            color: colors.foreground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: [
                Text(
                  'common.filters'.i18n,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.foreground,
                  ),
                ),
              ],
            ),
          ),
          FButton(
            size: .sm,
            variant: .ghost,
            onPress: onReset,
            child: Text(
              'common.reset'.i18n,
              style: context.theme.typography.body.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: 4),
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: onClose,
            child: Icon(FLucideIcons.check, size: 18),
          ),
        ],
      ),
    );
  }
}
