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
import 'package:miru_app_new/miru_core/proto/proto.dart' as proto;

class WatchLoadEntry extends StatefulHookConsumerWidget {
  const WatchLoadEntry({super.key, required this.param});
  final WatchParams param;
  @override
  createState() => _WatchLoadEntryState();
}

class _WatchLoadEntryState extends ConsumerState<WatchLoadEntry> {
  late double maxHeight;
  late double maxWidth;
  late EpisodeNotifier _episodeNotifier;
  late EpisodeNotifierProvider _epProvider;
  bool _hasOriented = false;

  @override
  void initState() {
    super.initState();
    _epProvider = episodeProvider(widget.param);
    _episodeNotifier = ref.read(_epProvider.notifier);
  }

  @override
  void dispose() {
    if (_hasOriented) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    _episodeNotifier.saveHistory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    maxWidth = DeviceUtil.getWidth(context);
    maxHeight = DeviceUtil.getHeight(context);

    if (maxWidth < maxHeight && widget.param.type == ExtensionType.bangumi) {
      _hasOriented = true;
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    }
    final epNotifier = ref.watch(_epProvider);
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
          watchProvider(
            url,
            widget.param.detailUrl,
            meta.packageName,
            meta.type,
          ),
        );
        return FTheme(
          data: ref.watch(applicationControllerProvider).themeData,
          child: snapshot.when(
            data: (value) {
              final extra = widget.param;
              if (value is proto.Download) {
                switch (extra.type) {
                  case ExtensionType.bangumi:
                    return MiruVideoPlayer.local(
                      name: extra.name,
                      meta: meta,
                      epProvider: _epProvider,
                      hasOriented: _hasOriented,
                      localPath: value.savePath,
                    );
                  case ExtensionType.manga:
                    return MiruMangaReader.local(
                      name: extra.name,
                      meta: meta,
                      epProvider: _epProvider,
                      localPath: value.savePath,
                    );
                  default:
                    return MiruNovelReader.local(
                      localPath: value.savePath,
                      name: extra.name,
                      meta: meta,
                      epProvider: _epProvider,
                      detailImageUrl: extra.detailImageUrl,
                    );
                }
              }
              switch (extra.type) {
                case ExtensionType.bangumi:
                  final data = value as ExtensionBangumiWatch;
                  return MiruVideoPlayer(
                    name: extra.name,
                    value: data,
                    mediaUrl: url,
                    meta: meta,
                    hasOriented: _hasOriented,
                    epProvider: _epProvider,
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
                    epProvider: _epProvider,
                  );
                default:
                  final data = value as ExtensionFikushonWatch;
                  return MiruNovelReader(
                    meta: meta,
                    name: extra.name,
                    detailImageUrl: extra.detailImageUrl,
                    value: data,
                    epProvider: _epProvider,
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
