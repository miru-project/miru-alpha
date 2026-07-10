import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/favorite/view_models/favorite_view_model.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/scaffold/miru_scaffold.dart';
import 'package:miru_alpha/ui/core/empty_state.dart';
import 'package:miru_alpha/ui/core/error_state.dart';
import 'package:miru_alpha/ui/core/loading_state.dart';
import 'package:miru_alpha/ui/core/scaffold/custom_silver_header.dart';
import 'package:miru_alpha/ui/core/scaffold/snapsheet_header.dart';

class FavoriteView extends HookConsumerWidget {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(favoriteViewModelProvider);

    return MiruScaffold.mobile(
      sliverHeaders: [
        FlexibleHeaderDelegate(
          scrollPosition: useValueNotifier(0.0),
          maxExtent: 180,
          minExtent: 120,
          builder: (context, shrinkOffset, shrinkProgress) {
            return SizedBox(
              height: 110,
              child: SnapSheetHeader(title: 'favorite.title'.i18n, suffix: []),
            );
          },
        ),
      ],
      slivers: [
        if (viewModelAsync.isLoading)
          const SliverFillRemaining(child: LoadingState())
        else if (viewModelAsync.hasError)
          SliverFillRemaining(
            child: ErrorState(message: 'favorite.load_failed'.i18n),
          )
        else if (viewModelAsync.value!.groups.isEmpty)
          SliverFillRemaining(
            child: EmptyState(
              icon: FLucideIcons.heart,
              message: 'favorite.empty'.i18n,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final favorite = viewModelAsync.value!.favorites[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(FLucideIcons.heart),
                    title: Text(favorite.title),
                    subtitle: Text(favorite.package),
                  ),
                );
              }, childCount: viewModelAsync.value!.favorites.length),
            ),
          ),
      ],
    );
  }
}
