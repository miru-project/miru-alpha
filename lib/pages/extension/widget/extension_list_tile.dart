import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/widgets/core/image_widget.dart';

class ExtensionListTile extends StatefulWidget {
  const ExtensionListTile({
    super.key,
    required this.name,
    required this.isNSFW,
    this.icon,
    required this.version,
    required this.author,
    required this.type,
    this.description,
    required this.onInstall,
    required this.onUninstall,
    required this.isInstalled,
    required this.needUpdate,
    this.tags = const [],
  });
  final bool isNSFW;
  final String name;
  final String? icon;
  final String version;
  final String author;
  final String type;
  final String? description;
  final List<String> tags;
  final void Function() onInstall;
  final void Function() onUninstall;
  final bool isInstalled;
  final bool needUpdate;

  @override
  State<ExtensionListTile> createState() => _ExtensionListTileState();
}

class _ExtensionListTileState extends State<ExtensionListTile> {
  @override
  Widget build(BuildContext context) {
    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.theme.colors.muted,
                borderRadius: BorderRadius.circular(24),
              ),
              child: widget.icon != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        widget.icon!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          FLucideIcons.toyBrick,
                          size: 24,
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                    )
                  : Icon(
                      FLucideIcons.toyBrick,
                      size: 24,
                      color: context.theme.colors.mutedForeground,
                    ),
            ),
            const SizedBox(width: 16),
            // Name and badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.type,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Badge(text: widget.version),
                      if (widget.isNSFW) ...[
                        const SizedBox(width: 6),
                        _Badge(text: 'NSFW', isDestructive: true),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Action button
            FButton.icon(
              variant: .ghost,
              onPress: widget.isInstalled
                  ? widget.onUninstall
                  : widget.onInstall,
              child: Icon(
                widget.needUpdate
                    ? FLucideIcons.circleFadingArrowUp
                    : widget.isInstalled
                    ? FLucideIcons.trash2
                    : FLucideIcons.download,
                size: 20,
                color: widget.isInstalled && !widget.needUpdate
                    ? context.theme.colors.mutedForeground
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, this.isDestructive = false});

  final String text;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDestructive
            ? context.theme.colors.error.withAlpha(30)
            : context.theme.colors.muted,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isDestructive
              ? context.theme.colors.error.withAlpha(60)
              : context.theme.colors.mutedForeground.withAlpha(40),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isDestructive
              ? context.theme.colors.error
              : context.theme.colors.mutedForeground,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Desktop grid tile - kept unchanged
class ExtensionGridTile extends StatelessWidget {
  const ExtensionGridTile({
    super.key,
    required this.name,
    required this.isNSFW,
    required this.version,
    required this.author,
    required this.type,
    required this.onInstall,
    required this.onUninstall,
    required this.isInstalled,
    required this.package,
    this.icon,
    this.description,
    required this.needUpdate,
    this.tags = const [],
  });
  final bool isNSFW;
  final String name;
  final String? icon;
  final String version;
  final String author;
  final String type;
  final String package;
  final String? description;
  final List<String> tags;
  final void Function() onInstall;
  final void Function() onUninstall;
  final bool isInstalled;
  final bool needUpdate;

  @override
  Widget build(BuildContext context) {
    final badges = tags
        .map((e) => FBadge(variant: .outline, child: Text(e)))
        .toList();
    if (isNSFW) {
      badges.add(
        FBadge(variant: .destructive, child: Text('extension.nsfw'.i18n)),
      );
    }
    if (needUpdate) {
      badges.add(
        FBadge(
          variant: .outline,
          child: Text('extension.update_available'.i18n),
        ),
      );
    }
    return Center(
      child: SizedBox(
        width: 400,
        height: 240,
        child: FCard.raw(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.only(right: 15),
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: ImageWidget(
                          imageUrl: icon,
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                    FLabel(
                      layout: .vertical,
                      description: Row(
                        children: [
                          FBadge(variant: .secondary, child: Text(version)),
                          SizedBox(width: 5),
                          FBadge(variant: .secondary, child: Text(type)),
                        ],
                      ),
                      child: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 55,
                  child: Wrap(spacing: 5, runSpacing: 5, children: badges),
                ),
                if (isInstalled)
                  Row(
                    spacing: 10,
                    mainAxisSize: .max,
                    children: [
                      Expanded(
                        child: FButton(
                          onPress: onUninstall,
                          prefix: Icon(FLucideIcons.trash2),
                          child: Text('extension.uninstall'.i18n),
                        ),
                      ),
                      if (needUpdate)
                        FButton.icon(
                          onPress: onInstall,
                          child: Icon(FLucideIcons.circleFadingArrowUp),
                        ),
                      FTooltip(
                        tipBuilder: (context, controller) =>
                            Text('common.settings'.i18n),
                        child: FButton.icon(
                          variant: .secondary,
                          onPress: () {
                            context.push(
                              "/extensionSettings",
                              extra: ExtensionSettingParam(
                                pkg: package,
                                name: name,
                              ),
                            );
                          },
                          child: Icon(FLucideIcons.cog),
                        ),
                      ),
                    ],
                  )
                else
                  FButton(
                    onPress: onInstall,
                    prefix: Icon(FLucideIcons.download),
                    child: Text('common.install'.i18n),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
