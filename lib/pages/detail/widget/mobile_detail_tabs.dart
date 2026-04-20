import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:miru_alpha/utils/tracking/tmdb.dart';
import 'package:miru_alpha/provider/tracking/anilist_track_page_provider.dart';

class MobileDetailTabs extends HookConsumerWidget {
  const MobileDetailTabs({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
  });
  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider detailPr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> tabTitles = [
      'episode.description'.i18n,
      'episode.tracking'.i18n,
      'episode.cast'.i18n,
    ];

    final detailState = ref.watch(detailPr);
    final trackers = detailState.detailInfo?.trackers ?? [];
    final anilistTracker = trackers
        .where((t) => t.provider.toLowerCase() == 'anilist')
        .firstOrNull;

    final anilistTrackState = anilistTracker != null
        ? ref.watch(
            anilistTrackPageProvider(int.parse(anilistTracker.trackerId)),
          )
        : null;

    final List<Widget> tabContent = [
      // Description
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Text(
              detail.desc ?? 'no_description'.i18n,
              textAlign: TextAlign.start,
              style: const TextStyle(height: 1.4, fontWeight: .w600),
            ),
          ),
        ],
      ),
      // Tracking
      Column(
        children: [
          FTile(
            onPress: () {
              context.push(
                '/anilistSearch',
                extra: AnilistSearchParam(
                  title: detail.title,
                  type: meta.type,
                  detailUrl: detailUrl,
                  package: meta.packageName,
                  detailPr: detailPr,
                ),
              );
            },
            prefix: SvgPicture.asset(
              'assets/svg/anilist.svg',
              width: 24,
              height: 24,
              colorFilter: .mode(context.theme.colors.foreground, .srcIn),
            ),
            title: Text('anilist'.i18n),
            suffix: () {
              if (anilistTracker != null) {
                final progress =
                    anilistTrackState?.progress ?? anilistTracker.progress;
                final total =
                    anilistTrackState?.totalProgress ??
                    (anilistTracker.hasTotalProgress()
                        ? anilistTracker.totalProgress
                        : 0);
                return Row(
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: .min,
                  children: [
                    Text(
                      AniListProvider.mediaListStatusToTranslate(
                        AniListProvider.stringToMediaListStatus(
                          anilistTracker.status,
                        ),
                        meta.type == ExtensionType.bangumi
                            ? AnilistType.anime
                            : AnilistType.manga,
                      ),
                      style: context.theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                    Text(
                      ' • ',
                      style: context.theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                    Text(
                      '$progress / ${total != 0 ? total : '?'}',
                      style: context.theme.typography.xs.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                );
              }
              return Text(
                'none'.i18n,
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              );
            }(),
          ),
        ],
      ),
      // Cast
      _MobileCastSection(detailPr: detailPr, mediaTitle: detail.title),
    ];
    return Padding(
      padding: .symmetric(horizontal: 10),
      child: FTabs(
        children: List.generate(
          tabTitles.length,
          (index) => FTabEntry(
            label: Text(tabTitles[index]),
            child: tabContent[index],
          ),
        ),
      ),
    );
  }
}

class _MobileCastSection extends HookConsumerWidget {
  const _MobileCastSection({required this.detailPr, required this.mediaTitle});
  final DetialProvider detailPr;
  final String mediaTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detailPr);
    final isLoading = useState(false);
    final hasAttempted = useState(false);

    useEffect(() {
      if (state.tmdbDetail == null && !hasAttempted.value) {
        isLoading.value = true;
        hasAttempted.value = true;
        Future.microtask(() async {
          final extensionType = ref.read(detailPr.notifier).meta.type;
          final mediaType = extensionType == ExtensionType.bangumi
              ? "tv"
              : "movie";
          await ref
              .read(detailPr.notifier)
              .fetchTMDBDetail(mediaTitle, mediaType);
          if (context.mounted) {
            isLoading.value = false;
          }
        });
      }
      return null;
    }, const []);

    if (isLoading.value) {
      return const Center(child: FCircularProgress.loader());
    }

    if (state.tmdbDetail == null && hasAttempted.value) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text("no_cast_found".i18n),
        ),
      );
    }

    final tmdb = state.tmdbDetail!;
    if (tmdb.casts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text("no_cast_found".i18n),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: tmdb.casts.map((cast) {
          final url = cast.profilePath != null
              ? TMDBProvider.getImageUrl(cast.profilePath!)
              : '';
          return SizedBox(
            width: 80,
            child: Column(
              children: [
                if (cast.profilePath != null && cast.profilePath!.isNotEmpty)
                  FAvatar(
                    image: ExtendedNetworkImageProvider(
                      MiruRequest.proxyUrl(url).toString(),
                    ),
                  )
                else
                  FAvatar.raw(
                    child: Container(color: context.theme.colors.muted),
                  ),
                const SizedBox(height: 4),
                Text(
                  cast.name,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  cast.character,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 9,
                    color: context.theme.colors.mutedForeground,
                    overflow: TextOverflow.ellipsis,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
