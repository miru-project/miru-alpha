import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_track_page_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:miru_alpha/widgets/core/image_widget.dart';
import 'package:miru_alpha/widgets/core/toast.dart';
import 'anilist_tracking_dialog.dart';

class AnilistSearchDialog extends HookConsumerWidget {
  final String title;
  final ExtensionType type;
  final String detailUrl;
  final String package;
  final DetialProvider detailPr;
  final Animation<double> animation;
  final FDialogStyle style;

  const AnilistSearchDialog({
    super.key,
    required this.title,
    required this.type,
    required this.detailUrl,
    required this.package,
    required this.detailPr,
    required this.animation,
    required this.style,
  });

  AnilistType getAnilistType(ExtensionType type) {
    if (type == ExtensionType.bangumi) return AnilistType.anime;
    return AnilistType.manga;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = useState(title);
    final isLoading = useState(false);
    final results = useState<List<AnilistMedia>>([]);
    final anilistType = getAnilistType(type);

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
        // Silently fail or show toast
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

    return FDialog(
      style: style,
      animation: animation,
      title: Text('search'.i18n),
      body: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            FTextField(
              prefixBuilder: (context, style, states) => const Padding(
                padding: EdgeInsets.only(left: 12, right: 10),
                child: Icon(FIcons.search, size: 16),
              ),
              control: FTextFieldControl.managed(
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
            const SizedBox(height: 16),
            Expanded(
              child: isLoading.value
                  ? const Center(child: FCircularProgress.loader())
                  : results.value.isEmpty
                  ? Center(child: Text('no_results'.i18n))
                  : ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemCount: results.value.length,
                      itemBuilder: (context, index) {
                        final item = results.value[index];
                        final cover = item.coverImage.large ?? '';
                        return FTile(
                          prefix: cover.isNotEmpty
                              ? ImageWidget(
                                  imageUrl: cover,
                                  width: 50,
                                  height: 75,
                                )
                              : const SizedBox(width: 50, height: 75),
                          title: Text(
                            item.title.userPreferred ??
                                item.title.romaji ??
                                'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${item.status} • ${item.episodes ?? item.chapters ?? "?"} ${item.type == 'ANIME' ? 'episodes'.i18n : 'chapters'.i18n}',
                            style: TextStyle(
                              color: context.theme.colors.mutedForeground,
                              fontSize: 12,
                            ),
                          ),
                          onPress: () async {
                            // Check if tracker already exists in local DB
                            final dState = ref.read(detailPr);
                            final trackers = dState.detailInfo?.trackers ?? [];
                            final existing = trackers
                                .where(
                                  (t) => t.provider.toLowerCase() == 'anilist',
                                )
                                .firstOrNull;

                            if (existing != null) {
                              // If exist, don't prompt user, just use the existing one and update ID
                              isLoading.value = true;
                              try {
                                final notifier = ref.read(
                                  anilistTrackPageProvider(item.id).notifier,
                                );
                                notifier.setProgress(existing.progress);
                                notifier.setStatus(
                                  AniListProvider.stringToMediaListStatus(
                                    existing.status,
                                  ),
                                );
                                if (existing.hasScore()) {
                                  notifier.setScore(existing.score.toDouble());
                                }

                                await notifier.saveProgress(
                                  detailUrl: detailUrl,
                                  package: package,
                                  title: item.title.userPreferred ?? 'Unknown',
                                );
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              } catch (e) {
                                showSimpleToast(e.toString());
                              } finally {
                                isLoading.value = false;
                              }
                              return;
                            }

                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                            showFDialog(
                              context: context,
                              builder: (context, style, animation) =>
                                  AnilistTrackingDialog(
                                    param: AnilistProgressParam(
                                      mediaId: item.id,
                                      detailUrl: detailUrl,
                                      package: package,
                                    ),
                                    detailPr: detailPr,
                                    animation: animation,
                                    style: style,
                                  ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [],
    );
  }
}
