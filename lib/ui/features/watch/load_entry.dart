import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:forui/forui.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/manga_reader.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_reader.dart';
import 'package:miru_alpha/ui/features/watch/video_player/video_player.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/ui/core/error.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;
import 'package:wakelock_plus/wakelock_plus.dart';

// The Go engine returns the resolved watch result as a raw `Map`/`String` for
// V2 ("api == 2" / raw) extensions (see `MiruCoreEndpoint.mirror`). The player
// widgets however expect a typed protobuf object. Normalize the raw data here
// so a `Map`/`String` does not crash the widget tree with a _TypeError
// ("type 'X' is not a subtype of type 'Y'") during build.
ExtensionBangumiWatch _toBangumiWatch(dynamic data) {
  if (data is ExtensionBangumiWatch) return data;
  if (data is String) return ExtensionBangumiWatch()..url = data;
  if (data is List) return _bangumiFromList(data);
  if (data is Map) {
    return ExtensionBangumiWatch()..mergeFromProto3Json(
      Map<String, dynamic>.from(data),
      ignoreUnknownFields: true,
    );
  }
  throw Exception('Unsupported bangumi watch data type: ${data.runtimeType}');
}

// The Go engine may resolve a mirror into a list of candidate sources
// (e.g. multiple qualities / mirrors). Pick the first usable one.
ExtensionBangumiWatch _bangumiFromList(List list) {
  for (final item in list) {
    if (item is String && item.isNotEmpty) {
      return ExtensionBangumiWatch()..url = item;
    }
    if (item is Map && item['url'] != null) {
      return ExtensionBangumiWatch()..mergeFromProto3Json(
        Map<String, dynamic>.from(item),
        ignoreUnknownFields: true,
      );
    }
  }
  if (list.isNotEmpty) return ExtensionBangumiWatch(url: list.first.toString());
  throw Exception('Empty watch data list');
}

ExtensionMangaWatch _toMangaWatch(dynamic data) {
  if (data is ExtensionMangaWatch) return data;
  if (data is List) {
    final urls = <String>[];
    for (final item in data) {
      if (item is String && item.isNotEmpty) {
        urls.add(item);
      } else if (item is Map && item['url'] != null) {
        urls.add(item['url'].toString());
      }
    }
    return ExtensionMangaWatch()..urls.addAll(urls);
  }
  if (data is Map) {
    return ExtensionMangaWatch()..mergeFromProto3Json(
      Map<String, dynamic>.from(data),
      ignoreUnknownFields: true,
    );
  }
  throw Exception('Unsupported manga watch data type: ${data.runtimeType}');
}

ExtensionFikushonWatch _toNovelWatch(dynamic data) {
  if (data is ExtensionFikushonWatch) return data;
  if (data is List) {
    final content = <String>[];
    for (final item in data) {
      if (item is String && item.isNotEmpty) {
        content.add(item);
      } else if (item is Map && item['content'] != null) {
        content.add(item['content'].toString());
      }
    }
    return ExtensionFikushonWatch()..content.addAll(content);
  }
  if (data is Map) {
    return ExtensionFikushonWatch()..mergeFromProto3Json(
      Map<String, dynamic>.from(data),
      ignoreUnknownFields: true,
    );
  }
  throw Exception('Unsupported novel watch data type: ${data.runtimeType}');
}

// An "all" extension (golang) returns an ExtensionAllWatch that bundles the
// bangumi/manga/fikushon shapes. Unwrap it to the single shape that matches
// the extension's declared @type so the existing typed readers can consume it.
dynamic _unwrapAll(dynamic data, ExtensionType type) {
  if (data is! pb_extension.ExtensionAllWatch) return data;
  switch (type) {
    case ExtensionType.bangumi:
      return data.bangumi;
    case ExtensionType.manga:
      return data.manga;
    case ExtensionType.fikushon:
      return data.fikushon;
    case ExtensionType.all:
      // No single declared shape; prefer bangumi, then manga, then fikushon.
      if (data.hasBangumi()) return data.bangumi;
      if (data.hasManga()) return data.manga;
      if (data.hasFikushon()) return data.fikushon;
      return data;
  }
}

class WatchLoadEntry extends StatefulHookConsumerWidget {
  const WatchLoadEntry({super.key, required this.param});
  final WatchParams param;
  @override
  createState() => _WatchLoadEntryState();
}

class _WatchLoadEntryState extends ConsumerState<WatchLoadEntry> {
  late double maxHeight;
  late double maxWidth;
  late EpisodeNotifierProvider _epProvider;
  bool _hasOriented = false;

  @override
  void initState() {
    super.initState();
    _epProvider = episodeProvider(widget.param);
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    if (_hasOriented) {
      Future.microtask(() async {
        await Future.delayed(const Duration(microseconds: 100));
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    maxWidth = DeviceUtil.getWidth(context);
    maxHeight = DeviceUtil.getHeight(context);

    if (maxWidth < maxHeight && widget.param.type == ExtensionType.bangumi) {
      _hasOriented = true;
      Future.microtask(() async {
        await Future.delayed(const Duration(microseconds: 100));
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
        ]);
      });
    }
    final epNotifier = ref.watch(_epProvider);
    if (epNotifier.epGroup.isEmpty) {
      return Center(
        child: Column(
          children: [
            Text('media.no_episodes_found'.i18n),
            FButton.icon(
              child: Text('common.back'.i18n),
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
          watchProvider(url, widget.param.detailUrl, meta),
        );
        return FTheme(
          data: ref.watch(applicationControllerProvider).themeData,
          child: snapshot.when(
            data: (value) {
              final extra = widget.param;
              if (value.data is proto.Download) {
                final downloadData = value.data as proto.Download;
                switch (extra.type) {
                  case ExtensionType.bangumi:
                    return MiruVideoPlayer.local(
                      name: extra.name,
                      meta: meta,
                      epProvider: _epProvider,
                      hasOriented: _hasOriented,
                      localPath: downloadData.savePath,
                    );
                  case ExtensionType.manga:
                    return MiruMangaReader.local(
                      name: extra.name,
                      meta: meta,
                      epProvider: _epProvider,
                      localPath: downloadData.savePath,
                    );
                  default:
                    return MiruNovelReader.local(
                      localPath: downloadData.savePath,
                      name: extra.name,
                      meta: meta,
                      epProvider: _epProvider,
                      detailImageUrl: extra.detailImageUrl,
                    );
                }
              }
              switch (extra.type) {
                case ExtensionType.bangumi:
                  final data = _toBangumiWatch(
                    _unwrapAll(value.data, extra.type),
                  );
                  return MiruVideoPlayer(
                    name: extra.name,
                    value: data,
                    mediaUrl: url,
                    meta: meta,
                    hasOriented: _hasOriented,
                    epProvider: _epProvider,
                    torrent: data.torrent,
                    v2watch: value.v2watch,
                  );
                case ExtensionType.manga:
                  final data = _toMangaWatch(
                    _unwrapAll(value.data, extra.type),
                  );
                  return MiruMangaReader(
                    name: extra.name,
                    value: data,
                    url: url,
                    meta: meta,
                    // detailImageUrl: extra.detailImageUrl,
                    epProvider: _epProvider,
                  );
                default:
                  final data = _toNovelWatch(
                    _unwrapAll(value.data, extra.type),
                  );
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
                    variant: .ghost,
                    prefix: Icon(FLucideIcons.undo2),
                    onPress: () {
                      context.pop();
                    },
                    child: Text('common.return_text'.i18n),
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
