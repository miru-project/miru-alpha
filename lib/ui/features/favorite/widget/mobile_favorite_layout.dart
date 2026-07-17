import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_alpha/ui/features/favorite/widget/mobile_favorite_search_bar.dart';

class MobileFavoriteLayout extends ConsumerStatefulWidget {
  const MobileFavoriteLayout({super.key});

  @override
  ConsumerState<MobileFavoriteLayout> createState() =>
      _MobileFavoriteLayoutState();
}

class _MobileFavoriteLayoutState extends ConsumerState<MobileFavoriteLayout> {
  @override
  Widget build(BuildContext context) {
    final meta = ref.watch(
      extensionPageProvider.select((state) => state.metaData),
    );
    final fav = ref.watch(
      favoritePageProvider.select((state) => state.filteredFavorites),
    );

    return MiruScaffold.mobile(
      sliverHeaders: [
        SimpleSliverHeaderDelegate(
          maxExtent: 100,
          minExtent: 100,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SnapSheetNested.back(
                title: 'favorite.name'.i18n,
                suffix: Consumer(
                  builder: (context, ref, child) {
                    final favGrp = ref.watch(
                      favoritePageProvider.select(
                        (e) => e.selectedFavoriteGroups,
                      ),
                    );
                    Widget badge;
                    if (favGrp.isEmpty) {
                      badge = FBadge(child: Text('common.all'.i18n));
                    } else if (favGrp.length == 1) {
                      badge = FBadge(child: Text(favGrp.first.name));
                    } else {
                      final firstTwo = favGrp.take(2).toList();
                      final remaining = favGrp.length - 2;
                      final suffix = remaining == 0 ? '' : '+$remaining';
                      badge = FBadge(
                        child: Text(
                          '${firstTwo.map((e) => e.name).join(', ')} $suffix',
                        ),
                      );
                    }
                    return FTappable(
                      onPress: () {
                        final groups = ref.read(
                          favoritePageProvider.select((e) => e.favoriteGroups),
                        );
                        final selected = ref.read(
                          favoritePageProvider.select(
                            (e) => e.selectedFavoriteGroups,
                          ),
                        );
                        final notifier = ref.read(
                          favoritePageProvider.notifier,
                        );
                        showMiruDialog(
                          context: context,
                          body: StatefulBuilder(
                            builder: (context, setState) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...groups.map((g) {
                                    final isSelected = selected.contains(g);
                                    return FTile(
                                      prefix: Icon(
                                        isSelected
                                            ? FLucideIcons.check
                                            : FLucideIcons.circle,
                                      ),
                                      title: Text(g.name),
                                      onPress: () {
                                        final newSelected = selected.toList();
                                        if (isSelected) {
                                          newSelected.removeWhere(
                                            (e) => e.id == g.id,
                                          );
                                        } else {
                                          newSelected.add(g);
                                        }
                                        notifier.filterFavoriteGroups(
                                          newSelected,
                                        );
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
                        );
                      },
                      child: badge,
                    );
                  },
                ),
              ),
              Row(children: [Expanded(child: MobileFavoriteSearchBar())]),
            ],
          ),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: fav.length,
              itemBuilder: (context, index) {
                final favorite = fav[index];
                final ExtensionMeta? ext = meta.firstWhereOrNull(
                  (element) => element.packageName == favorite.package,
                );
                return MiruMobileTile(
                  title: favorite.title,
                  subtitle: ext?.name ?? 'common.package_not_found'.i18n,
                  imageUrl: favorite.cover,
                  onTap: () {
                    if (ext == null) return;
                    context.push(
                      '/search/single/detail',
                      extra: DetailParam(meta: ext, url: favorite.url),
                    );
                  },
                  onLongPress: () {
                    showFSheet(
                      context: context,
                      style: .delta(
                        barrierFilter: (value) =>
                            ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      ),
                      builder: (context) => Consumer(
                        builder: (context, ref, child) => MiruCard(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                              left: 10,
                              right: 10,
                              bottom: 20,
                            ),
                            child: FTileGroup(
                              label: Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(favorite.title),
                              ),
                              children: [
                                FTile(
                                  prefix: const Icon(FLucideIcons.heartMinus),
                                  title: Text('common.remove_favorite'.i18n),
                                  onPress: () {
                                    ref
                                        .read(favoritePageProvider.notifier)
                                        .deleteFavorite(favorite);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      side: .btt,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
