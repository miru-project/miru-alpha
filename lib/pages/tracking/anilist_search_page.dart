import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:miru_alpha/widgets/core/image_widget.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class AnilistSearchPage extends HookConsumerWidget {
  final AnilistSearchParam param;
  const AnilistSearchPage({super.key, required this.param});

  AnilistType getAnilistType(ExtensionType type) {
    if (type == ExtensionType.bangumi) return AnilistType.anime;
    return AnilistType.manga;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = useState(param.title);
    final isLoading = useState(false);
    final results = useState<List<AnilistMedia>>([]);
    final anilistType = getAnilistType(param.type);

    final performSearch = useCallback((String q) async {
      if (q.isEmpty) return;
      isLoading.value = true;
      try {
        final res = await AniListProvider.mediaQuerypage(
          searchString: q,
          type: anilistType,
          page: 1,
        );
        if (context.mounted) {
          results.value = res;
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
        }
      } finally {
        if (context.mounted) {
          isLoading.value = false;
        }
      }
    }, [anilistType]);

    useEffect(() {
      performSearch(query.value);
      return null;
    }, []);

    return MiruScaffold(
      mobileHeader: SnapSheetNested.back(title: "search".i18n),
      snappingOffsets: [
        AbsoluteSheetOffset(140),
        ProportionalToViewportSheetOffset(0.5),
        ProportionalToViewportSheetOffset(1.0),
      ],
      snapSheet: [
        Padding(
          padding: const EdgeInsetsGeometry.only(left: 16.0, right: 16.0),
          child: FTextField(
            prefixBuilder: (context, style, states) => Padding(
              padding: EdgeInsetsGeometry.only(left: 12, right: 10),
              child: Icon(FIcons.search),
            ),
            control: .managed(
              initial: TextEditingValue(text: query.value),
              onChange: (val) => query.value = val.text,
            ),
            hint: 'Search...',
            textInputAction: TextInputAction.search,
            onSubmit: (val) {
              query.value = val;
              performSearch(val);
            },
          ),
        ),
      ],
      body: isLoading.value
          ? const Center(child: FCircularProgress.loader())
          : ListView.separated(
              separatorBuilder: (context, index) => SizedBox(height: 10),
              padding: .symmetric(vertical: 40),
              itemCount: results.value.length,
              itemBuilder: (context, index) {
                final item = results.value[index];
                final cover = item.coverImage.large ?? '';
                return FTile(
                  prefix: cover.isNotEmpty
                      ? ImageWidget(imageUrl: cover, width: 70, height: 100)
                      : const SizedBox(width: 70, height: 100),
                  title: Text(
                    item.title.userPreferred ?? item.title.romaji ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.status,
                            style: TextStyle(
                              color: context.theme.colors.mutedForeground,
                              fontSize: 12,
                            ),
                          ),
                          if (item.episodes != null ||
                              item.chapters != null) ...[
                            Text(
                              ' • ',
                              style: TextStyle(
                                color: context.theme.colors.mutedForeground,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${item.episodes ?? item.chapters} ${item.type == 'ANIME' ? 'episodes'.i18n : 'chapters'.i18n}',
                              style: TextStyle(
                                color: context.theme.colors.mutedForeground,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (item.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            item.description!.replaceAll(
                              RegExp(r'<[^>]*>|&[^;]+;'),
                              '',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.theme.colors.mutedForeground,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPress: () {
                    context.go(
                      '/anilistProgress',
                      extra: AnilistProgressParam(
                        mediaId: item.id,
                        detailUrl: param.detailUrl,
                        package: param.package,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
