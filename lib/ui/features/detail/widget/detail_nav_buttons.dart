import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/detail_nav_provider.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

/// Top-bar previous / next paging through the result list that opened the
/// current detail page. Hidden entirely when off a detail route or when the
/// detail was opened without a result list.
class DetailNavButtons extends HookConsumerWidget {
  const DetailNavButtons({super.key});

  void _go(BuildContext context, WidgetRef ref, int delta) {
    final nav = ref.read(detailNavProvider);
    final items = nav?.items;
    if (nav == null || items == null) return;
    final i = nav.index + delta;
    if (i < 0 || i >= items.length) return;
    context.pushReplacement(
      '/search/single/detail',
      extra: DetailParam(
        meta: nav.meta,
        url: items[i].url,
        items: items,
        index: i,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(detailNavProvider);
    final routeInfo = GoRouter.of(context).routeInformationProvider;
    useListenable(routeInfo);

    final currentLocation =
        GoRouter.of(context).routerDelegate.state.fullPath ??
        GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
    final onDetail = (currentLocation).endsWith('detail');

    final items = nav?.items;
    if (!onDetail || items == null || items.isEmpty) {
      return const SizedBox.shrink();
    }
    final hasPrev = nav!.index > 0;
    final hasNext = nav.index < items.length - 1;

    return Row(
      mainAxisSize: .min,
      children: [
        FButton.icon(
          variant: .ghost,
          onPress: hasPrev ? () => _go(context, ref, -1) : null,
          child: Icon(FLucideIcons.chevronLeft),
        ),
        FButton.icon(
          variant: .ghost,
          onPress: hasNext ? () => _go(context, ref, 1) : null,
          child: Icon(FLucideIcons.chevronRight),
        ),
      ],
    );
  }
}
