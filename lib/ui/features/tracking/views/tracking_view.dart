import 'package:flutter/material.dart';
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
      body: viewModelAsync.when(
        loading: () => const LoadingState(),
        error: (error, stack) =>
            ErrorState(message: 'tracking.load_failed'.i18n),
        data: (state) {
          final account = state.anilistAccount;
          final progress = state.progress;

          if (account == null && progress.isEmpty) {
            return EmptyState(
              icon: FLucideIcons.clipboardClock,
              message: 'tracking.empty'.i18n,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: progress.length,
            itemBuilder: (context, index) {
              final item = progress[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(FLucideIcons.user),
                  title: Text(item.title ?? ''),
                  subtitle: Text(item.progress.toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
