import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:miru_alpha/ui/features/search/extension_filter_view.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_chip.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Mobile sticky filter list owning its own scroll.
///
/// Every category is a [SliverPersistentHeader] section. Tapping the pin
/// button (leading, left of the title) sticks that header to the top; at most
/// [kMaxPinnedFilters] stick at once (FIFO eviction of the oldest pin).
/// Pinned headers stack at the top while the rest scrolls underneath.
/// Tapping a header expands its content sliver in place, pushing the sections
/// below downward. The status row shows the remaining sticky slots as
/// `3 - pinned`.
class MobileFilterSliverBody extends ConsumerStatefulWidget {
  const MobileFilterSliverBody({super.key, this.autoCommit = false});

  /// When true (inline mobile bar) every edit commits immediately; when false
  /// (filter dialog) edits stay pending until the dialog confirms.
  final bool autoCommit;

  @override
  ConsumerState<MobileFilterSliverBody> createState() =>
      _MobileFilterSliverBodyState();
}

class _MobileFilterSliverBodyState
    extends ConsumerState<MobileFilterSliverBody> {
  /// Filter keys pinned to the top, in pin order (oldest first).
  final List<String> _pinned = [];

  /// Filter keys currently expanded. `null` means "not yet seeded".
  final Set<String> _expanded = {};

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

  void _toggleExpanded(String key) {
    setState(() {
      if (_expanded.contains(key)) {
        _expanded.remove(key);
      } else {
        _expanded.add(key);
      }
    });
  }

  void _apply(String key, void Function() mutate) {
    mutate();
    if (widget.autoCommit) {
      ref.read(searchPageSingleProviderProvider.notifier).commitFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchPageSingleProviderProvider);
    final notifier = ref.read(searchPageSingleProviderProvider.notifier);
    final order = state.filterOrder;

    if (order.isEmpty) {
      return CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'extension.no_filter'.i18n,
                style: context.theme.typography.body.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            ),
          ),
        ],
      );
    }

    _pinned.removeWhere((k) => !order.contains(k));
    // _expanded ??= order.toSet();
    _expanded.removeWhere((k) => !order.contains(k));
    final displayOrder = [
      ..._pinned.where(order.contains),
      ...order.where((k) => !_pinned.contains(k)),
    ];
    // final slotsLeft = kMaxPinnedFilters - _pinned.length;

    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        // SliverToBoxAdapter(
        //   child: Padding(
        //     padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        //     child: Text(
        //       'Pinned ${_pinned.length}/$kMaxPinnedFilters'
        //       ' · $slotsLeft sticky slot${slotsLeft == 1 ? '' : 's'} left',
        //       style: context.theme.typography.body.xs.copyWith(
        //         color: context.theme.colors.mutedForeground,
        //       ),
        //     ),
        //   ),
        // ),
        for (final key in displayOrder) ...[
          SliverPersistentHeader(
            pinned: _pinned.contains(key),
            delegate: _FilterHeaderDelegate(
              title: _titleFor(state, key),
              selectedCount: (state.selected[key] ?? []).length,
              isPinned: _pinned.contains(key),
              expanded: _expanded.contains(key),
              background: context.theme.colors.background,
              foreground: context.theme.colors.foreground,
              active: context.theme.colors.primary,
              onPin: () => _togglePin(key),
              onToggle: () => _toggleExpanded(key),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOutCubic,
              child: _expanded.contains(key)
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: _contentFor(state, key, notifier),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
      ],
    );
  }

  String _titleFor(SingleSearchPageState state, String key) {
    final raw = state.filter[key];
    if (raw == null) return '';
    return switch (raw.whichKind()) {
      ExtensionFilter_Kind.range => raw.range.title,
      ExtensionFilter_Kind.select => raw.select.title,
      _ => ExtensionFilterView.from(raw).title,
    };
  }

  Widget _contentFor(
    SingleSearchPageState state,
    String key,
    SearchPageSingleProvider notifier,
  ) {
    final raw = state.filter[key];
    final selected = (state.selected[key] ?? []).cast<String>();

    if (raw != null && raw.whichKind() == ExtensionFilter_Kind.range) {
      return _SliverRangeField(
        key: ValueKey('sliver-range-$key'),
        filter: raw.range,
        selected: selected,
        onChanged: (from, to) =>
            _apply(key, () => notifier.setRangeFilter(key, from, to)),
      );
    }
    if (raw != null && raw.whichKind() == ExtensionFilter_Kind.select) {
      final entries = raw.select.options.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(
            label: 'extension.all'.i18n,
            selected: selected.isEmpty,
            onTap: () => _apply(key, () => notifier.clearFilterValue(key)),
          ),
          for (final e in entries)
            FilterChip(
              label: e.value.label,
              selected: selected.contains(e.key),
              onTap: () =>
                  _apply(key, () => notifier.setFilterValue(key, [e.key])),
            ),
        ],
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in [
          ...?filter?.options,
        ]..sort((a, b) => a.key.compareTo(b.key)))
          FilterChip(
            label: option.label,
            selected: selected.contains(option.key),
            onTap: () {
              final next = selected.contains(option.key)
                  ? selected.where((e) => e != option.key).toList()
                  : <String>[...selected, option.key];
              _apply(key, () => notifier.setFilterValue(key, next));
            },
          ),
      ],
    );
  }
}

/// Fixed-height sticky header for one filter section.
///
/// Layout: pin button leading (left of the title) → title + selection-count
/// badge → expand chevron. Tapping the pin sticks/unsticks the header;
/// tapping the rest toggles expansion.
class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FilterHeaderDelegate({
    required this.title,
    required this.selectedCount,
    required this.isPinned,
    required this.expanded,
    required this.background,
    required this.foreground,
    required this.active,
    required this.onPin,
    required this.onToggle,
  });

  final String title;
  final int selectedCount;
  final bool isPinned;
  final bool expanded;
  final Color background;
  final Color foreground;
  final Color active;
  final VoidCallback onPin;
  final VoidCallback onToggle;

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          SizedBox(height: 32),
          // FButton.icon(
          //   variant: .ghost,
          //   onPress: onPin,
          //   child: Icon(
          //     isPinned ? FLucideIcons.pinOff : FLucideIcons.pin,
          //     size: 16,
          //     color: isPinned ? active : null,
          //   ),
          // ),
          Expanded(
            child: FTappable(
              onPress: onToggle,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.bold,
                        color: foreground,
                      ),
                    ),
                  ),
                  if (selectedCount > 0) ...[
                    const SizedBox(width: 6),
                    FBadge(
                      child: Text(
                        '$selectedCount',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(FLucideIcons.chevronDown, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) {
    return title != oldDelegate.title ||
        selectedCount != oldDelegate.selectedCount ||
        isPinned != oldDelegate.isPinned ||
        expanded != oldDelegate.expanded ||
        background != oldDelegate.background;
  }
}

class _SliverRangeField extends StatefulWidget {
  const _SliverRangeField({
    super.key,
    required this.filter,
    required this.selected,
    required this.onChanged,
  });

  final RangeFilter filter;
  final List<String> selected;
  final void Function(int from, int to) onChanged;

  @override
  State<_SliverRangeField> createState() => _SliverRangeFieldState();
}

class _SliverRangeFieldState extends State<_SliverRangeField> {
  late final TextEditingController fromCtrl;
  late final TextEditingController toCtrl;

  @override
  void initState() {
    super.initState();
    fromCtrl = TextEditingController(
      text: widget.selected.isNotEmpty
          ? widget.selected[0]
          : widget.filter.defaultMin.toString(),
    );
    toCtrl = TextEditingController(
      text: widget.selected.length > 1
          ? widget.selected[1]
          : widget.filter.defaultMax.toString(),
    );
  }

  @override
  void dispose() {
    fromCtrl.dispose();
    toCtrl.dispose();
    super.dispose();
  }

  void _commit() => widget.onChanged(
    int.tryParse(fromCtrl.text) ?? widget.filter.min,
    int.tryParse(toCtrl.text) ?? widget.filter.max,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FTextField(
            keyboardType: TextInputType.number,
            control: FTextFieldControl.managed(controller: fromCtrl),
            hint: widget.filter.min.toString(),
            onSubmit: (_) => _commit(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '-',
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ),
        Expanded(
          child: FTextField(
            keyboardType: TextInputType.number,
            control: FTextFieldControl.managed(controller: toCtrl),
            hint: widget.filter.max.toString(),
            onSubmit: (_) => _commit(),
          ),
        ),
      ],
    );
  }
}
