import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/pages/watch/manga_reader/manga_reader.dart';
import 'package:miru_app_new/pages/watch/novel_reader/novel_reader.dart';
import 'package:miru_app_new/pages/watch/video_player/video_player.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/widgets/error.dart';

class WatchLoadEntry extends StatefulHookConsumerWidget {
  const WatchLoadEntry({super.key, required this.param});
  final WatchParams param;
  @override
  createState() => _WatchLoadEntryState();
}

class _WatchLoadEntryState extends ConsumerState<WatchLoadEntry> {
  late double maxHeight;
  late double maxWidth;
  bool _hasOriented = false;
  @override
  void dispose() {
    if (_hasOriented) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final epProvider = episodeProvider(
      widget.param.selectedGroupIndex,
      widget.param.selectedEpisodeIndex,
      widget.param.epGroup ?? [],
      widget.param.name,
      false,
      widget.param.detailImageUrl,
      widget.param.detailUrl,
      widget.param.type,
      widget.param.meta.packageName,
    );

    maxWidth = DeviceUtil.getWidth(context);
    maxHeight = DeviceUtil.getHeight(context);

    if (maxWidth < maxHeight && widget.param.type == ExtensionType.bangumi) {
      _hasOriented = true;
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    }
    final epNotifier = ref.watch(epProvider);
    if (epNotifier.epGroup.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Text('Error: No episodes found'),
            FButton.icon(
              child: const Text('back'),
              onPress: () {
                context.pop();
              },
            ),
          ],
        ),
      );
    }
    final url = epNotifier
        .epGroup[epNotifier.selectedGroupIndex]
        .urls[epNotifier.selectedEpisodeIndex]
        .url;
    final meta = widget.param.meta;
    return Consumer(
      builder: (context, ref, child) {
        final snapshot = ref.watch(
          watchProvider(url, meta.packageName, meta.type),
        );
        return FTheme(
          data: ref.watch(applicationControllerProvider).themeData,
          child: snapshot.when(
            data: (value) {
              final extra = widget.param;
              switch (extra.type) {
                case ExtensionType.bangumi:
                  final data = value as ExtensionBangumiWatch;
                  return MiruVideoPlayer(
                    name: extra.name,
                    value: data,
                    url: url,
                    meta: meta,
                    hasOriented: _hasOriented,
                    epProvider: epProvider,
                    torrent: data.torrent,
                  );
                case ExtensionType.manga:
                  final data = value as ExtensionMangaWatch;
                  return MiruMangaReader(
                    name: extra.name,
                    value: data,
                    url: url,
                    meta: meta,
                    // detailImageUrl: extra.detailImageUrl,
                    epProvider: epProvider,
                  );
                default:
                  final data = value as ExtensionFikushonWatch;
                  return MiruNovelReader(
                    meta: meta,
                    name: extra.name,
                    detailImageUrl: extra.detailImageUrl,
                    value: data,
                    epProvider: epProvider,
                    url: url,
                  );
              }
            },
            error: (error, trace) => FScaffold(
              child: Center(
                child: ErrorDisplay.grpc(
                  err: error,
                  stack: trace,
                  prefix: FButton(
                    style: FButtonStyle.ghost(),
                    prefix: Icon(FIcons.undo2),
                    onPress: () {
                      context.pop();
                    },
                    child: Text('Return'),
                  ),
                ),
              ),
            ),
            loading: () => const Center(child: FCircularProgress()),
          ),
        );
      },
    );
  }
}
