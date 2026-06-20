import 'package:miru_alpha/pages/download/widget/desktop_download_tile_list.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/download_provider.dart';

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
        variant: varient ?? .secondary,
        onPress: () => onTap(context),
        child: Icon(FLucideIcons.download),
      );
    }
    return FButton(
      variant: varient ?? .secondary,
      prefix: Icon(FLucideIcons.download),
      onPress: () => onTap(context),
      child: Text('download.name'.i18n),
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
  @override
  Widget build(BuildContext context) {
    final episodes = widget.detail.episodes;
    return FDialog(
      animation: widget.animation,
      title: Text('common.download'.i18n),
      body: episodes == null || episodes.isEmpty
          ? Text('media.no_episodes'.i18n)
          : SizedBox(
              width: 500,
              height: 400,
              child: FTabs(
                children: episodes.map((group) {
                  return FTabEntry(
                    label: Text(group.title),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 330),
                      child: DesktopTileList(
                        group: group,
                        meta: widget.meta,
                        downloadProvider: downloadProvider,
                        detailUrl: widget.detailUrl,
                        detail: widget.detail,
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
          child: Text('common.cancel'.i18n),
        ),
      ],
    );
  }
}
