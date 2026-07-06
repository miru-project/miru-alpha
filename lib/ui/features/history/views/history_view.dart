import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/history/view_models/history_view_model.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/scaffold/miru_scaffold.dart';
import 'package:miru_alpha/ui/core/empty_state.dart';
import 'package:miru_alpha/ui/core/error_state.dart';
import 'package:miru_alpha/ui/core/loading_state.dart';
import 'package:miru_alpha/ui/core/scaffold/custom_silver_header.dart';
import 'package:miru_alpha/ui/core/scaffold/snapsheet_header.dart';

class HistoryView extends HookConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(historyViewModelProvider);
    final notifier = ref.read(historyViewModelProvider.notifier);

    return MiruScaffold.mobile(
      sliverHeaders: [
        FlexibleHeaderDelegate(
          scrollPosition: useValueNotifier(0.0),
          maxExtent: 180,
          minExtent: 120,
          builder: (context, shrinkOffset, shrinkProgress) {
            return SnapSheetHeader(
              title: 'history.title'.i18n,
              suffix: [
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  onPress: () async {
                    await notifier.clearHistory('all');
                  },
                  child: const Icon(FLucideIcons.trash2),
                ),
              ],
            );
          },
        ),
      ],
      body: viewModelAsync.when(
        loading: () => const LoadingState(),
        error: (error, stack) =>
            ErrorState(message: 'history.load_failed'.i18n),
        data: (history) {
          if (history.isEmpty) {
            return EmptyState(
              icon: FLucideIcons.clock,
              message: 'history.empty'.i18n,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(FLucideIcons.clock),
                  title: Text(item.title),
                  subtitle: Text(item.package),
                  trailing: Text(item.progress.toStringAsFixed(2)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
