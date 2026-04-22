import 'package:extended_image/extended_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_alpha/model/tmdb_model.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/tracking/tmdb.dart';
import 'package:miru_alpha/widgets/core/outter_card.dart';
import 'package:miru_alpha/widgets/core/tabbar.dart';

class DetailTrackingBox extends HookConsumerWidget {
  const DetailTrackingBox({
    super.key,
    required this.detailPr,
    required this.mediaTitle,
  });
  final DetialProvider detailPr;
  final String mediaTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detailPr);
    final tabController = useTabController(initialLength: 3);
    return OutterCard(
      title: "media.cast".i18n,
      trailing: SizedBox(
        width: 300,
        height: 40,
        child: MiruTabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'None'),
            Tab(text: 'TMDB'),
            Tab(text: 'AniList'),
          ],
        ),
      ),
      child: SizedBox(
        height: 100,
        child: TabBarView(
          controller: tabController,
          children: [
            Center(
              child: Text(
                'Select the Provider',
                style: TextStyle(fontSize: 18, fontWeight: .bold),
              ),
            ),
            KeepAliveWrapper(
              child: _TMDBSection(
                state: state,
                detailPr: detailPr,
                mediaTitle: mediaTitle,
                meta: state.tmdbDetail,
              ),
            ),
            KeepAliveWrapper(child: _AnilistSection(detailPr: detailPr)),
          ],
        ),
      ),
    );
  }
}

class _AnilistSection extends HookConsumerWidget {
  const _AnilistSection({required this.detailPr});
  final DetialProvider detailPr;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SizedBox.shrink();
}

class _TMDBSection extends HookConsumerWidget {
  const _TMDBSection({
    required this.state,
    required this.detailPr,
    required this.mediaTitle,
    required this.meta,
  });
  final DetialState state;
  final DetialProvider detailPr;
  final String mediaTitle;
  final TMDBDetail? meta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      return Center(child: Text("media.no_cast_found".i18n));
    }

    final tmdb = state.tmdbDetail!;
    if (tmdb.casts.isEmpty) return Text("media.no_cast_found".i18n);

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tmdb.casts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cast = tmdb.casts[index];
          final url = TMDBProvider.getImageUrl(cast.profilePath ?? '');
          return Column(
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
              SizedBox(
                width: 80,
                child: Text(
                  cast.name,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  cast.character,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 9,
                    color: context.theme.colors.mutedForeground,
                    overflow: TextOverflow.ellipsis,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
