import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/tracking/view_models/tracking_view_model.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/scaffold/miru_scaffold.dart';
import 'package:miru_alpha/ui/core/loading_state.dart';
import 'package:miru_alpha/ui/core/error_state.dart';
import 'package:miru_alpha/ui/core/empty_state.dart';
import 'package:miru_alpha/ui/core/scaffold/custom_silver_header.dart';
import 'package:miru_alpha/ui/core/scaffold/snapsheet_header.dart';

class TrackingView extends HookConsumerWidget {
  const TrackingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(trackingViewModelProvider);

    return MiruScaffold.mobile(
      sliverHeaders: [
        FlexibleHeaderDelegate(
          scrollPosition: useValueNotifier(0.0),
          maxExtent: 180,
          minExtent: 120,
          builder: (context, shrinkOffset, shrinkProgress) {
            return SnapSheetHeader(title: 'tracking.title'.i18n, suffix: []);
          },
        ),
      ],
      slivers: [
        if (viewModelAsync.isLoading)
          const SliverFillRemaining(child: LoadingState())
        else if (viewModelAsync.hasError)
          SliverFillRemaining(
            child: ErrorState(message: 'tracking.load_failed'.i18n),
          )
        else if (viewModelAsync.value!.anilistAccount == null &&
            viewModelAsync.value!.progress.isEmpty)
          SliverFillRemaining(
            child: EmptyState(
              icon: FLucideIcons.clipboardClock,
              message: 'tracking.empty'.i18n,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = viewModelAsync.value!.progress[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(FLucideIcons.user),
                    title: Text(item.title ?? ''),
                    subtitle: Text(item.progress.toString()),
                  ),
                );
              }, childCount: viewModelAsync.value!.progress.length),
            ),
          ),
      ],
    );
  }
}
