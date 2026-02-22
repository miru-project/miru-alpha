import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/miru_core/proto/proto.dart' as proto;
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/utils/core/miru_directory.dart';
import 'package:miru_app_new/widgets/core/toast.dart';
import 'package:path/path.dart' as p;
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/provider/download_provider.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.isIcon,
    required this.detail,
    required this.meta,
    this.varient,
    required this.detailUrl,
  });

  final bool isIcon;
  final Detail detail;
  final ExtensionMeta meta;
  final FButtonVariant? varient;
  final String detailUrl;

  @override
  Widget build(BuildContext context) {
    if (isIcon) {
      return FButton.icon(
        variant: varient ?? FButtonVariant.secondary,
        onPress: () => onTap(context),
        child: Icon(FIcons.download),
      );
    }
    return FButton(
      variant: varient ?? .secondary,
      prefix: Icon(FIcons.download),
      onPress: () => onTap(context),
      child: const Text('Download'),
    );
  }

  void onTap(BuildContext context) {
    showFDialog(
      context: context,
      builder: (context, _, animation) =>
          _DownloadDialog(detail, meta, animation, detailUrl),
    );
  }
}

class _DownloadDialog extends ConsumerStatefulWidget {
  const _DownloadDialog(this.detail, this.meta, this.animation, this.detailUrl);
  final Detail detail;
  final ExtensionMeta meta;
  final Animation<double> animation;
  final String detailUrl;
  @override
  ConsumerState<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends ConsumerState<_DownloadDialog>
    with TickerProviderStateMixin {
  final Map<String, bool> _loadingTasks = {};

  Future<void> _startDownload({
    required String url,
    required String title,
    required String key,
    required Map<String, String> headers,
    required ExtensionWatchBangumiType type,
    required String watchUrl,
  }) async {
    try {
      final tempDir = await MiruDirectory.getTempDownloadDirectory();
      final res = await MiruGrpcClient.downloadClient.download(
        proto.DownloadRequest(
          url: url,
          downloadPath: p.join(tempDir, title),
          mediaType: type.name,
          package: widget.meta.packageName,
          detailUrl: widget.detailUrl,
          title: title,
          key: key,
          watchUrl: watchUrl,
        )..headers.addAll(headers),
      );

      if (res.variantSummary.isNotEmpty) {
        if (!mounted) return;
        // Show variant selection dialog
        showFDialog(
          context: context,
          builder: (context, _, animation) => FDialog(
            animation: animation,
            title: const Text('Select Resolution'),
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
                        headers: headers,
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
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
        return;
      }

      showSimpleToast('Download started');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      logger.severe('Failed to start download: $e');
      showSimpleToast('Failed to start download: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final episodes = widget.detail.episodes;
    return FDialog(
      animation: widget.animation,
      title: const Text('Download'),
      body: episodes == null || episodes.isEmpty
          ? const Text('No episodes available')
          : SizedBox(
              width: 500,
              height: 400,
              child: FTabs(
                children: episodes.map((group) {
                  return FTabEntry(
                    label: Text(group.title),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 330),
                      child: SingleChildScrollView(
                        child: FTileGroup.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          count: group.urls.length,
                          tileBuilder: (context, index) {
                            final url = group.urls[index];
                            final key =
                                "${widget.meta.packageName}_${group.title}_${url.name}";

                            // Use select to optimize rebuilds
                            final progress = ref.watch(
                              downloadProvider.select((s) {
                                final active = s.value?.active ?? [];
                                return active.firstWhereOrNull(
                                  (element) => element.key == key,
                                );
                              }),
                            );

                            final history = ref.watch(
                              downloadProvider.select((s) {
                                final history = s.value?.history ?? [];
                                return history.firstWhereOrNull(
                                  (element) => element.key == key,
                                );
                              }),
                            );

                            final isLoading = _loadingTasks[key] ?? false;
                            final isDownloaded = history != null;

                            return FTile(
                              title: Text(url.name),
                              subtitle: progress != null
                                  ? Text(
                                      "${progress.status} - ${(progress.progress / (progress.total == 0 ? 1 : progress.total) * 100).toStringAsFixed(1)}%",
                                    )
                                  : (isDownloaded
                                        ? const Text("Downloaded")
                                        : null),
                              suffix: isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: FCircularProgress(),
                                    )
                                  : (progress != null || isDownloaded
                                        ? Icon(
                                            FIcons.check,
                                            color: context.theme.colors.primary,
                                          )
                                        : null),
                              onPress: isLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        _loadingTasks[key] = true;
                                      });
                                      try {
                                        final videoWatch =
                                            await MiruCoreEndpoint.watch(
                                                  url.url,
                                                  widget.meta.packageName,
                                                  widget.meta.type,
                                                )
                                                as ExtensionBangumiWatch?;

                                        if (videoWatch == null) {
                                          if (mounted) {
                                            showSimpleToast(
                                              'Failed to fetch video URL',
                                            );
                                          }
                                          return;
                                        }
                                        await _startDownload(
                                          type: ExtensionWatchBangumiType.values
                                              .firstWhere(
                                                (e) =>
                                                    e.name == videoWatch.type,
                                                orElse: () =>
                                                    ExtensionWatchBangumiType
                                                        .hls,
                                              ),
                                          watchUrl: url.url,
                                          url: videoWatch.url,
                                          title:
                                              "${widget.detail.title}-${group.title}-${url.name}",
                                          key: key,
                                          headers: videoWatch.headers,
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _loadingTasks[key] = false;
                                          });
                                        }
                                      }
                                    },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
      actions: [
        FButton(
          variant: .outline,
          onPress: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
