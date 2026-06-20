import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/core/miru_directory.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/widgets/core/toast.dart';
import 'package:path/path.dart' as p;

class MobileDetailTile extends ConsumerWidget {
  const MobileDetailTile({
    super.key,
    required this.item,
    required this.idx,
    required this.selectedGpIndex,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
    required this.history,
    required this.isDownloaded,
  });

  final ExtensionEpisode item;
  final int idx;
  final int selectedGpIndex;
  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider detailPr;
  final History? history;
  final bool isDownloaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key =
        "${meta.packageName}_${detail.episodes?[selectedGpIndex].title}_${item.name}";
    final isLoading = ref.watch(
      downloadProvider.select(
        (s) => s.value?.preparingKeys.contains(key) ?? false,
      ),
    );
    final downloadProgress = ref.watch(
      downloadProvider.select((s) {
        final active = s.value?.active ?? [];
        return active.firstWhereOrNull((e) => e.key == key);
      }),
    );

    return FTile(
      suffix: FTappableGroup.isolate(
        child: FButton.icon(
          variant: .ghost,
          onPress: (isLoading || isDownloaded)
              ? null
              : () => _startDownload(context, ref, key),
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: FCircularProgress(),
                )
              : isDownloaded
              ? Icon(
                  FLucideIcons.folderCheck,
                  color: context.theme.colors.primary,
                )
              : Icon(FLucideIcons.arrowDownToLine),
        ),
      ),
      title: Text(item.name),
      onPress: () {
        final donwloadList = ref.watch(
          detailPr.select((value) => value.downloadList),
        );
        final savePath = donwloadList
            .firstWhereOrNull(
              (element) =>
                  element.key ==
                  "${detail.title}-${detail.episodes?[selectedGpIndex].title}-${item.name}",
            )
            ?.savePath;
        context.push<WatchParams>(
          "/watch",
          extra: WatchParams(
            detailPr: detailPr,
            name: detail.title,
            savePath: savePath,
            detailImageUrl: detail.cover ?? '',
            selectedEpisodeIndex: idx,
            selectedGroupIndex: selectedGpIndex,
            epGroup: detail.episodes,
            detailUrl: detailUrl,
            url: item.url,
            meta: meta,
            type: meta.type,
          ),
        );
      },
      subtitle:
          (history == null && item.update.isEmpty && downloadProgress == null)
          ? SizedBox.shrink()
          : Row(
              children: [
                if (item.update.isNotEmpty) ...[
                  Text(_dateFormatter(DateTime.tryParse(item.update))),
                  Text(' • '),
                ],
                if (history != null) Text(_progressIndicator(history!)),
                if (downloadProgress != null)
                  Text(
                    "${downloadProgress.status.name} - ${(downloadProgress.progress / (downloadProgress.total == 0 ? 1 : downloadProgress.total) * 100).toStringAsFixed(1)}%",
                  ),
              ],
            ),
    );
  }

  Future<void> _startDownload(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) async {
    final notifier = ref.read(downloadProvider.notifier);
    notifier.startPreparing(key);
    try {
      var watchResult = await MiruCoreEndpoint.watch(
        item.url,
        meta.packageName,
        meta,
      );

      // Handle mirrors for V2 flow
      if (meta.api == "2" && watchResult is pb_extension.ExtensionWatch) {
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
            final mirror = (index >= 0 && index < group.mirrors.length)
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

      final tempDir = await MiruDirectory.getTempDownloadDirectory();
      final title =
          "${detail.title}-${detail.episodes?[selectedGpIndex].title}-${item.name}";
      final res = await MiruGrpcClient.downloadClient.download(
        proto.DownloadRequest(
          url: videoUrl,
          downloadPath: p.join(tempDir, title),
          mediaType: videoType,
          package: meta.packageName,
          detailUrl: detailUrl,
          title: title,
          key: key,
          watchUrl: item.url,
        )..headers.addAll(videoHeaders),
      );

      if (res.variantSummary.isNotEmpty) {
        if (!context.mounted) return;
        showFDialog(
          context: context,
          builder: (context, _, animation) => FDialog(
            animation: animation,
            title: Text('media.select_resolution'.i18n),
            body: SizedBox(
              width: 300,
              // height: 300,
              child: FTileGroup.builder(
                count: res.variantSummary.length,
                tileBuilder: (context, index) {
                  final variant = res.variantSummary[index];
                  return FTile(
                    title: Text(variant.resolution),
                    subtitle: Text(variant.codec),
                    onPress: () async {
                      Navigator.of(context).pop();
                      final vRes = await MiruGrpcClient.downloadClient.download(
                        proto.DownloadRequest(
                          url: variant.url,
                          downloadPath: p.join(tempDir, title),
                          mediaType: videoType,
                          package: meta.packageName,
                          detailUrl: detailUrl,
                          title: title,
                          key: key,
                          watchUrl: item.url,
                        )..headers.addAll(videoHeaders),
                      );
                      if (!context.mounted) return;
                      if (vRes.variantSummary.isEmpty) {
                        showSimpleToast('media.download_started'.i18n);
                      }
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
    } catch (e) {
      logger.severe('Failed to start download: $e');
      showSimpleToast('${'media.failed_to_start_download'.i18n}: $e');
    } finally {
      notifier.finishPreparing(key);
    }
  }

  static String _dateFormatter(DateTime? date) {
    if (date == null) return "";
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return "time.just_now".i18n;
        }
        return "time.minutes_ago".fill({"minutes": diff.inMinutes.toString()});
      }
      return "time.hours_ago".fill({"hours": diff.inHours.toString()});
    }
    if (diff.inDays == 1) {
      return "time.yesterday".i18n;
    }
    if (diff.inDays < 7) {
      return "time.days_ago".fill({"days": diff.inDays.toString()});
    }
    if (diff.inDays < 30) {
      return "time.weeks_ago".fill({"weeks": (diff.inDays ~/ 7).toString()});
    }
    if (diff.inDays < 365) {
      return "time.months_ago".fill({"months": (diff.inDays ~/ 30).toString()});
    }
    return "time.years_ago".fill({"years": (diff.inDays ~/ 365).toString()});
  }

  static String _progressIndicator(History h) {
    final type =
        ExtensionType.values.firstWhereOrNull(
          (e) => e.name == h.type || e.toString() == h.type,
        ) ??
        ExtensionType.all;
    switch (type) {
      case ExtensionType.manga:
        return "${h.progress} ${"common.page".i18n} / ${h.totalProgress} ${"common.page".i18n}";
      case ExtensionType.bangumi:
        final dur = Duration(seconds: h.progress);
        final totalDur = Duration(seconds: h.totalProgress);
        return "${_formatDuration(dur)} / ${_formatDuration(totalDur)}";
      case ExtensionType.fikushon:
        return "${h.progress}/${h.totalProgress}";
      default:
        return "";
    }
  }

  static String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
