import 'package:collection/collection.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/utils/core/miru_directory.dart';
import 'package:miru_alpha/widgets/core/toast.dart';
import 'package:path/path.dart' as p;
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;

class DesktopTileList extends ConsumerWidget {
  final ExtensionEpisodeGroup group;
  final ExtensionMeta meta;
  final DownloadNotifierProvider downloadProvider;
  final String detailUrl;
  final Detail detail;
  const DesktopTileList({
    super.key,
    required this.group,
    required this.meta,
    required this.downloadProvider,
    required this.detailUrl,
    required this.detail,
  });

  Future<void> _startDownload({
    required String url,
    required String title,
    required String key,
    required Map<String, String> headers,
    required ExtensionWatchBangumiType type,
    required String watchUrl,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      final tempDir = await MiruDirectory.getTempDownloadDirectory();
      final res = await MiruGrpcClient.downloadClient.download(
        proto.DownloadRequest(
          url: url,
          downloadPath: p.join(tempDir, title),
          mediaType: type.name,
          package: meta.packageName,
          detailUrl: detailUrl,
          title: title,
          key: key,
          watchUrl: watchUrl,
        )..headers.addAll(headers),
      );

      if (res.variantSummary.isNotEmpty) {
        if (!context.mounted) return;
        // Show variant selection dialog
        showFDialog(
          context: context,
          builder: (context, _, animation) => FDialog(
            animation: animation,
            title: Text('media.select_resolution'.i18n),
            body: SizedBox(
              width: 300,
              height: 300,
              child: FTileGroup.builder(
                count: res.variantSummary.length,
                tileBuilder: (context, index) {
                  final variant = res.variantSummary[index];
                  return FTile(
                    title: Text(variant.resolution),
                    subtitle: Text(variant.codec),
                    onPress: () async {
                      Navigator.of(context).pop();
                      await _startDownload(
                        watchUrl: watchUrl,
                        type: type,
                        url: variant.url,
                        title: title,
                        key: key,
                        context: context,
                        headers: headers,
                        ref: ref,
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              FButton(
                variant: .outline,
                onPress: () => Navigator.of(context).pop(),
                child: Text('common.cancel'.i18n),
              ),
            ],
          ),
        );
        return;
      }

      showSimpleToast('media.download_started'.i18n);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      logger.severe('Failed to start download: $e');
      showSimpleToast('${'media.failed_to_start_download'.i18n}: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: FTileGroup.builder(
        physics: const NeverScrollableScrollPhysics(),
        count: group.urls.length,
        tileBuilder: (context, index) {
          final url = group.urls[index];
          final key = "${meta.packageName}_${group.title}_${url.name}";

          // Watch active downloads for this key
          final progress = ref.watch(
            downloadProvider.select((s) {
              final active = s.value?.active ?? [];
              return active.firstWhereOrNull((element) => element.key == key);
            }),
          );

          // Watch download history for this key
          final history = ref.watch(
            downloadProvider.select((s) {
              final history = s.value?.history ?? [];
              return history.firstWhereOrNull((element) => element.key == key);
            }),
          );

          // Watch preparing (loading) state from the provider
          final isLoading = ref.watch(
            downloadProvider.select(
              (s) => s.value?.preparingKeys.contains(key) ?? false,
            ),
          );

          final isDownloaded = history != null;

          return FTile(
            title: Text(url.name),
            subtitle: progress != null
                ? Text(
                    "${progress.status.name} - ${(progress.progress / (progress.total == 0 ? 1 : progress.total) * 100).toStringAsFixed(1)}%",
                  )
                : (isDownloaded ? Text("media.downloaded".i18n) : null),
            suffix: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: FCircularProgress(),
                  )
                : (progress != null || isDownloaded
                      ? Icon(
                          FLucideIcons.check,
                          color: context.theme.colors.primary,
                        )
                      : null),
            onPress: isLoading
                ? null
                : () async {
                    final notifier = ref.read(downloadProvider.notifier);
                    notifier.startPreparing(key);
                    try {
                      var watchResult = await MiruCoreEndpoint.watch(
                        url.url,
                        meta.packageName,
                        meta,
                      );

                      // Handle mirrors for V2 flow
                      if (meta.api == "2" &&
                          watchResult is pb_extension.ExtensionWatch) {
                        if (watchResult.groups.isNotEmpty) {
                          final group = watchResult.groups.firstWhere(
                            (e) =>
                                watchResult.hasDefaultGroup() &&
                                e.title == watchResult.defaultGroup,
                            orElse: () => watchResult.groups.first,
                          );
                          if (group.mirrors.isNotEmpty) {
                            final index = watchResult.hasDefaultIndex()
                                ? watchResult.defaultIndex
                                : 0;
                            final mirror =
                                (index >= 0 && index < group.mirrors.length)
                                ? group.mirrors[index]
                                : group.mirrors.first;

                            watchResult = await MiruCoreEndpoint.mirror(
                              meta.packageName,
                              mirror.url,
                            );
                          }
                        }
                      }

                      String videoUrl = "";
                      Map<String, String> videoHeaders = {};
                      String videoType = "";

                      if (watchResult is pb_extension.ExtensionBangumiWatch) {
                        videoUrl = watchResult.url;
                        videoHeaders = watchResult.headers;
                        videoType = watchResult.type;
                      }
                      if (!context.mounted) return;
                      if (videoUrl.isEmpty) {
                        showSimpleToast('media.failed_to_fetch_video_url'.i18n);
                        return;
                      }

                      await _startDownload(
                        context: context,
                        type: ExtensionWatchBangumiType.values.firstWhere(
                          (e) => e.name == videoType,
                          orElse: () => ExtensionWatchBangumiType.hls,
                        ),
                        watchUrl: url.url,
                        url: videoUrl,
                        title: "${detail.title}-${group.title}-${url.name}",
                        key: key,
                        headers: videoHeaders,
                        ref: ref,
                      );
                    } finally {
                      notifier.finishPreparing(key);
                    }
                  },
          );
        },
      ),
    );
  }
}
