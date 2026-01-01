import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/miru_core/proto/proto.dart' as proto;
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/utils/core/miru_directory.dart';
import 'package:miru_app_new/widgets/core/toast.dart';
import 'package:path/path.dart' as p;
import 'package:miru_app_new/utils/core/log.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.isIcon,
    required this.detail,
    required this.meta,
    this.style,
  });

  final bool isIcon;
  final ExtensionDetail detail;
  final ExtensionMeta meta;
  final dynamic style;

  @override
  Widget build(BuildContext context) {
    if (isIcon) {
      return FButton.icon(
        style: style ?? FButtonStyle.secondary(),
        onPress: () => onTap(context),
        child: Icon(FIcons.download),
      );
    }
    return FButton(
      style: style ?? FButtonStyle.secondary(),
      prefix: Icon(FIcons.download),
      onPress: () => onTap(context),
      child: const Text('Download'),
    );
  }

  void onTap(BuildContext context) {
    showFDialog(
      context: context,
      builder: (context, _, animation) =>
          _DownloadDialog(detail, meta, animation),
    );
  }
}

class _DownloadDialog extends StatefulWidget {
  const _DownloadDialog(this.detail, this.meta, this.animation);
  final ExtensionDetail detail;
  final ExtensionMeta meta;
  final Animation<double> animation;
  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog>
    with TickerProviderStateMixin {
  Future<void> _startDownload({
    required String url,
    required String title,
    required String key,
    required Map<String, String> headers,
    required ExtensionWatchBangumiType type,
  }) async {
    try {
      final tempDir = await MiruDirectory.getTempDownloadDirectory();
      final res = await MiruGrpcClient.downloadClient.download(
        proto.DownloadRequest(
          url: url,
          downloadPath: p.join(tempDir, title),
          mediaType: type.name,
          package: widget.meta.packageName,
          title: title,
          key: key,
        )..header.addAll(headers),
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
                style: FButtonStyle.outline(),
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
                    child: FTileGroup.builder(
                      // shrinkWrap: true,
                      count: group.urls.length,
                      tileBuilder: (context, index) {
                        final url = group.urls[index];
                        return FTile(
                          title: Text(url.name),
                          onPress: () async {
                            final videoWatch =
                                await MiruCoreEndpoint.watch(
                                      url.url,
                                      widget.meta.packageName,
                                      widget.meta.type,
                                    )
                                    as ExtensionBangumiWatch?;

                            if (videoWatch == null) return;
                            await _startDownload(
                              type: videoWatch.type,
                              url: videoWatch.url,
                              title:
                                  "${widget.detail.title}-${group.title}-${url.name}",
                              key:
                                  "${widget.meta.packageName}_${group.title}_${url.name}",
                              headers: videoWatch.headers ?? {},
                            );
                          },
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
      actions: [
        FButton(
          style: FButtonStyle.outline(),
          onPress: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
