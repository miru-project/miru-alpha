import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/watch/view_models/watch_view_model.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/loading_state.dart';
import 'package:miru_alpha/ui/core/error_state.dart';
import 'package:miru_alpha/ui/features/watch/load_entry.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

class WatchView extends HookConsumerWidget {
  const WatchView({super.key, required this.param});

  final WatchParams param;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(
      watchViewModelProvider(param.meta.packageName, param.detailUrl),
    );
    final notifier = ref.read(
      watchViewModelProvider(param.meta.packageName, param.detailUrl).notifier,
    );

    return viewModelAsync.when(
      loading: () => const LoadingState(),
      error: (error, stack) => ErrorState(
        message: 'watch.load_failed'.i18n,
        child: Text(error.toString(), textAlign: TextAlign.center),
      ),
      data: (state) {
        return DeviceUtil.deviceWidget(
          context: context,
          mobile: _WatchViewMobile(param: param, notifier: notifier),
          desktop: _WatchViewDesktop(param: param, notifier: notifier),
        );
      },
    );
  }
}

class _WatchViewMobile extends HookConsumerWidget {
  const _WatchViewMobile({required this.param, required this.notifier});

  final WatchParams param;
  final WatchViewModel notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WatchLoadEntry(param: param);
  }
}

class _WatchViewDesktop extends HookConsumerWidget {
  const _WatchViewDesktop({required this.param, required this.notifier});

  final WatchParams param;
  final WatchViewModel notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WatchLoadEntry(param: param);
  }
}
