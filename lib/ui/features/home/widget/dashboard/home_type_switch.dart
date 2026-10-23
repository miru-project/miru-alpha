import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/home/home_dashboard_provider.dart';
import 'package:miru_alpha/ui/core/widget/miru_segmented_control.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';

/// The dashboard's media-type tablist: the shared [MiruSegmentedControl]
/// (forui-styled inset track + FButton segments, forui radius tokens)
/// scoped to this provider.
class HomeTypeSwitch extends ConsumerWidget {
  const HomeTypeSwitch({super.key});

  static const _options = [
    ExtensionType.all,
    ExtensionType.bangumi,
    ExtensionType.manga,
    ExtensionType.fikushon,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(homeDashboardProvider.select((s) => s.type));
    return MiruSegmentedControl<ExtensionType>(
      segments: [
        for (final option in _options)
          MiruSegment(value: option, label: searchExtensionTypeLabel(option)),
      ],
      selected: selected,
      onSelected: (option) =>
          ref.read(homeDashboardProvider.notifier).setType(option),
    );
  }
}
